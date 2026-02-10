// ============================================================================
// Matters Routes - CRUD and workflow operations for UN matters
// ============================================================================

const express = require('express');
const router = express.Router();
const { query, withTransaction, pool } = require('../config/db');

// GET all matters with filtering
router.get('/', async (req, res) => {
    try {
        const { organ, status, type, limit = 50 } = req.query;
        let sql = `
            SELECT 
                m.*,
                o.organ_code,
                o.organ_name,
                COALESCE(
                    CONCAT(d.first_name, ' ', d.last_name),
                    CONCAT(off.first_name, ' ', off.last_name)
                ) AS submitted_by_name,
                (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) AS vote_count,
                (SELECT COUNT(*) FROM approval a WHERE a.matter_id = m.matter_id AND a.approval_status = 'APPROVED') AS approval_count
            FROM matter m
            JOIN un_organ o ON m.organ_id = o.organ_id
            LEFT JOIN delegate d ON m.submitted_by_delegate_id = d.delegate_id
            LEFT JOIN officer off ON m.submitted_by_officer_id = off.officer_id
            WHERE 1=1
        `;
        const params = [];

        if (organ) {
            sql += ' AND o.organ_code = ?';
            params.push(organ);
        }
        if (status) {
            sql += ' AND m.status = ?';
            params.push(status);
        }
        if (type) {
            sql += ' AND m.matter_type = ?';
            params.push(type);
        }

        const limitNum = Math.min(Math.max(1, parseInt(limit) || 50), 500);
        sql += ` ORDER BY m.created_at DESC LIMIT ${limitNum}`;

        const matters = await query(sql, params);
        res.json(matters);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single matter with full details
router.get('/:id', async (req, res) => {
    try {
        const [matter] = await query(`
            SELECT 
                m.*,
                o.organ_code,
                o.organ_name,
                COALESCE(
                    CONCAT(d.first_name, ' ', d.last_name),
                    CONCAT(off.first_name, ' ', off.last_name)
                ) AS submitted_by_name,
                ms.state_name AS submitter_state
            FROM matter m
            JOIN un_organ o ON m.organ_id = o.organ_id
            LEFT JOIN delegate d ON m.submitted_by_delegate_id = d.delegate_id
            LEFT JOIN member_state ms ON d.state_id = ms.state_id
            LEFT JOIN officer off ON m.submitted_by_officer_id = off.officer_id
            WHERE m.matter_id = ?
        `, [req.params.id]);

        if (!matter) {
            return res.status(404).json({ error: 'Matter not found' });
        }

        // Get workflow stages
        const workflow = await query(`
            SELECT 
                mw.*,
                CONCAT(o.first_name, ' ', o.last_name) AS assigned_officer_name
            FROM matter_workflow mw
            LEFT JOIN officer o ON mw.assigned_officer_id = o.officer_id
            WHERE mw.matter_id = ?
            ORDER BY mw.stage_number
        `, [req.params.id]);

        // Get approvals
        const approvals = await query(`
            SELECT 
                a.*,
                CONCAT(o.first_name, ' ', o.last_name) AS approver_name,
                r.role_name
            FROM approval a
            JOIN officer o ON a.approver_officer_id = o.officer_id
            JOIN role r ON o.role_id = r.role_id
            WHERE a.matter_id = ?
            ORDER BY a.approval_level
        `, [req.params.id]);

        res.json({ ...matter, workflow, approvals });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST create new matter
router.post('/', async (req, res) => {
    try {
        const result = await withTransaction(async (connection) => {
            const { title, description, matter_type, organ_id, submitted_by_delegate_id, priority } = req.body;

            // Get organ code for matter number generation
            const [[organ]] = await connection.execute(
                'SELECT organ_code FROM un_organ WHERE organ_id = ?',
                [organ_id]
            );

            // Generate matter number
            const [[{ next_id }]] = await connection.execute(
                'SELECT COALESCE(MAX(matter_id), 0) + 1 AS next_id FROM matter'
            );

            const year = new Date().getFullYear();
            let matter_number;
            let requires_voting = false;

            switch (organ.organ_code) {
                case 'GA':
                    matter_number = `GA/PROP/${year}/${String(next_id).padStart(3, '0')}`;
                    requires_voting = true;
                    break;
                case 'SC':
                    matter_number = `SC/PROP/${year}/${String(next_id).padStart(3, '0')}`;
                    requires_voting = true;
                    break;
                case 'ECOSOC':
                    matter_number = `E/PROP/${year}/${String(next_id).padStart(3, '0')}`;
                    requires_voting = true;
                    break;
                default:
                    matter_number = `${organ.organ_code}/${year}/${String(next_id).padStart(3, '0')}`;
            }

            // Insert matter
            const [insertResult] = await connection.execute(`
                INSERT INTO matter (
                    matter_number, title, description, matter_type, organ_id,
                    submitted_by_delegate_id, priority, status, submission_date, requires_voting
                ) VALUES (?, ?, ?, ?, ?, ?, ?, 'SUBMITTED', CURDATE(), ?)
            `, [matter_number, title, description, matter_type, organ_id, submitted_by_delegate_id, priority, requires_voting]);

            const matter_id = insertResult.insertId;

            // Create workflow stages
            const stages = requires_voting
                ? ['SUBMISSION', 'INITIAL_REVIEW', 'COMMITTEE_REVIEW', 'APPROVAL', 'VOTING', 'RESOLUTION_ISSUANCE']
                : ['SUBMISSION', 'REVIEW', 'APPROVAL', 'ISSUANCE'];

            for (let i = 0; i < stages.length; i++) {
                await connection.execute(`
                    INSERT INTO matter_workflow (matter_id, stage_number, stage_name, stage_status)
                    VALUES (?, ?, ?, ?)
                `, [matter_id, i + 1, stages[i], i === 0 ? 'IN_PROGRESS' : 'PENDING']);
            }

            return { matter_id, matter_number };
        });

        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT update matter status
router.put('/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        await query(
            'UPDATE matter SET status = ? WHERE matter_id = ?',
            [status, req.params.id]
        );
        res.json({ success: true, status });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST add approval
router.post('/:id/approvals', async (req, res) => {
    try {
        const { approver_officer_id, approval_level } = req.body;
        const [result] = await pool.execute(`
            INSERT INTO approval (matter_id, approver_officer_id, approval_level, approval_status)
            VALUES (?, ?, ?, 'PENDING')
        `, [req.params.id, approver_officer_id, approval_level]);
        res.status(201).json({ approval_id: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT process approval decision
router.put('/:id/approvals/:approvalId', async (req, res) => {
    try {
        const { approval_status, comments } = req.body;
        await query(`
            UPDATE approval 
            SET approval_status = ?, decision_date = NOW(), comments = ?
            WHERE approval_id = ? AND matter_id = ?
        `, [approval_status, comments, req.params.approvalId, req.params.id]);

        // If approved at final level, advance matter status
        if (approval_status === 'APPROVED') {
            const [matter] = await query(
                'SELECT requires_voting FROM matter WHERE matter_id = ?',
                [req.params.id]
            );
            if (matter?.requires_voting) {
                await query(
                    "UPDATE matter SET status = 'IN_VOTING' WHERE matter_id = ?",
                    [req.params.id]
                );
            }
        }

        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET matter workflow timeline
router.get('/:id/timeline', async (req, res) => {
    try {
        const timeline = await query(`
            SELECT 
                'workflow' AS event_type,
                mw.stage_name AS event_name,
                mw.stage_status AS status,
                mw.started_at AS event_date,
                CONCAT(o.first_name, ' ', o.last_name) AS performed_by
            FROM matter_workflow mw
            LEFT JOIN officer o ON mw.assigned_officer_id = o.officer_id
            WHERE mw.matter_id = ?
            
            UNION ALL
            
            SELECT 
                'approval' AS event_type,
                CONCAT('Level ', a.approval_level, ' Approval') AS event_name,
                a.approval_status AS status,
                a.decision_date AS event_date,
                CONCAT(o.first_name, ' ', o.last_name) AS performed_by
            FROM approval a
            JOIN officer o ON a.approver_officer_id = o.officer_id
            WHERE a.matter_id = ?
            
            UNION ALL
            
            SELECT 
                'vote' AS event_type,
                CONCAT(ms.state_name, ' voted ', v.vote_value) AS event_name,
                'COMPLETED' AS status,
                v.vote_timestamp AS event_date,
                CONCAT(d.first_name, ' ', d.last_name) AS performed_by
            FROM vote v
            JOIN member_state ms ON v.state_id = ms.state_id
            JOIN delegate d ON v.delegate_id = d.delegate_id
            WHERE v.matter_id = ?
            
            ORDER BY event_date DESC
        `, [req.params.id, req.params.id, req.params.id]);

        res.json(timeline);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
