// ============================================================================
// ICJ Routes - International Court of Justice cases, hearings, judgments
// ============================================================================

const express = require('express');
const router = express.Router();
const { query, withTransaction } = require('../config/db');

// GET all ICJ cases
router.get('/cases', async (req, res) => {
    try {
        const { status, type, limit = 50 } = req.query;
        let sql = `
            SELECT 
                c.*,
                app.state_name AS applicant_name,
                resp.state_name AS respondent_name,
                o.organ_name AS requesting_organ_name,
                (SELECT COUNT(*) FROM icj_hearing h WHERE h.case_id = c.case_id) AS hearing_count,
                (SELECT COUNT(*) FROM icj_judgment j WHERE j.case_id = c.case_id) AS judgment_count
            FROM icj_case c
            LEFT JOIN member_state app ON c.applicant_state_id = app.state_id
            LEFT JOIN member_state resp ON c.respondent_state_id = resp.state_id
            LEFT JOIN un_organ o ON c.requesting_organ_id = o.organ_id
            WHERE 1=1
        `;
        const params = [];

        if (status) {
            sql += ' AND c.status = ?';
            params.push(status);
        }
        if (type) {
            sql += ' AND c.case_type = ?';
            params.push(type);
        }

        const limitNum = Math.min(Math.max(1, parseInt(limit) || 50), 500);
        sql += ` ORDER BY c.filing_date DESC LIMIT ${limitNum}`;

        const cases = await query(sql, params);
        res.json(cases);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single case with full details
router.get('/cases/:id', async (req, res) => {
    try {
        const [caseData] = await query(`
            SELECT 
                c.*,
                app.state_name AS applicant_name,
                resp.state_name AS respondent_name
            FROM icj_case c
            LEFT JOIN member_state app ON c.applicant_state_id = app.state_id
            LEFT JOIN member_state resp ON c.respondent_state_id = resp.state_id
            WHERE c.case_id = ?
        `, [req.params.id]);

        if (!caseData) {
            return res.status(404).json({ error: 'Case not found' });
        }

        // Get assigned judges
        const judges = await query(`
            SELECT 
                j.*,
                cj.is_ad_hoc,
                ms.state_name AS nationality
            FROM icj_case_judge cj
            JOIN icj_judge j ON cj.judge_id = j.judge_id
            JOIN member_state ms ON j.nationality_state_id = ms.state_id
            WHERE cj.case_id = ?
            ORDER BY j.is_president DESC, j.is_vice_president DESC, j.last_name
        `, [req.params.id]);

        // Get hearings
        const hearings = await query(`
            SELECT 
                h.*,
                CONCAT(j.first_name, ' ', j.last_name) AS presiding_judge_name
            FROM icj_hearing h
            LEFT JOIN icj_judge j ON h.presiding_judge_id = j.judge_id
            WHERE h.case_id = ?
            ORDER BY h.hearing_number
        `, [req.params.id]);

        // Get judgments
        const judgments = await query(`
            SELECT * FROM icj_judgment WHERE case_id = ? ORDER BY judgment_date
        `, [req.params.id]);

        res.json({ ...caseData, judges, hearings, judgments });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST create new ICJ case
router.post('/cases', async (req, res) => {
    try {
        const result = await withTransaction(async (connection) => {
            const { case_title, case_type, applicant_state_id, respondent_state_id,
                requesting_organ_id, subject_matter } = req.body;

            // Generate case number
            const [[{ next_id }]] = await connection.execute(
                'SELECT COALESCE(MAX(case_id), 0) + 1 AS next_id FROM icj_case'
            );
            const year = new Date().getFullYear();
            const case_number = `ICJ/${year}/${String(next_id).padStart(3, '0')}`;

            const [insertResult] = await connection.execute(`
                INSERT INTO icj_case (
                    case_number, case_title, case_type, applicant_state_id,
                    respondent_state_id, requesting_organ_id, filing_date, 
                    subject_matter, status
                ) VALUES (?, ?, ?, ?, ?, ?, CURDATE(), ?, 'PENDING')
            `, [case_number, case_title, case_type, applicant_state_id,
                respondent_state_id, requesting_organ_id, subject_matter]);

            return { case_id: insertResult.insertId, case_number };
        });

        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT update case status
router.put('/cases/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        await query(
            'UPDATE icj_case SET status = ? WHERE case_id = ?',
            [status, req.params.id]
        );
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST schedule hearing
router.post('/cases/:id/hearings', async (req, res) => {
    try {
        const { hearing_type, scheduled_date, presiding_judge_id } = req.body;

        // Get next hearing number
        const [hearings] = await query(
            'SELECT COALESCE(MAX(hearing_number), 0) + 1 AS next_num FROM icj_hearing WHERE case_id = ?',
            [req.params.id]
        );

        const [result] = await query(`
            INSERT INTO icj_hearing (case_id, hearing_number, hearing_type, scheduled_date, presiding_judge_id, status)
            VALUES (?, ?, ?, ?, ?, 'SCHEDULED')
        `, [req.params.id, hearings[0].next_num, hearing_type, scheduled_date, presiding_judge_id]);

        res.status(201).json({ hearing_id: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST issue judgment
router.post('/cases/:id/judgments', async (req, res) => {
    try {
        const result = await withTransaction(async (connection) => {
            const { judgment_type, summary, full_text, votes_in_favor, votes_against } = req.body;

            // Generate judgment number
            const [[{ next_id }]] = await connection.execute(
                'SELECT COALESCE(MAX(judgment_id), 0) + 1 AS next_id FROM icj_judgment'
            );
            const year = new Date().getFullYear();
            const judgment_number = `ICJ/JUD/${year}/${String(next_id).padStart(3, '0')}`;

            const [insertResult] = await connection.execute(`
                INSERT INTO icj_judgment (
                    judgment_number, case_id, judgment_type, judgment_date,
                    summary, full_text, votes_in_favor, votes_against, is_unanimous
                ) VALUES (?, ?, ?, CURDATE(), ?, ?, ?, ?, ?)
            `, [judgment_number, req.params.id, judgment_type, summary, full_text,
                votes_in_favor, votes_against, votes_against === 0]);

            // Update case status
            await connection.execute(
                "UPDATE icj_case SET status = 'JUDGMENT_ISSUED' WHERE case_id = ?",
                [req.params.id]
            );

            return { judgment_id: insertResult.insertId, judgment_number };
        });

        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET all judges
router.get('/judges', async (req, res) => {
    try {
        const judges = await query(`
            SELECT 
                j.*,
                ms.state_name AS nationality,
                (SELECT COUNT(*) FROM icj_case_judge cj WHERE cj.judge_id = j.judge_id) AS case_count
            FROM icj_judge j
            JOIN member_state ms ON j.nationality_state_id = ms.state_id
            WHERE j.status = 'ACTIVE'
            ORDER BY j.is_president DESC, j.is_vice_president DESC, j.last_name
        `);
        res.json(judges);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
