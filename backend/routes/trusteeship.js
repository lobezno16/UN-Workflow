// ============================================================================
// Trusteeship Routes - Territories and oversight reports
// ============================================================================

const express = require('express');
const router = express.Router();
const { query } = require('../config/db');

// GET all territories
router.get('/territories', async (req, res) => {
    try {
        const territories = await query(`
            SELECT 
                t.*,
                ms.state_name AS administering_authority,
                (SELECT COUNT(*) FROM trusteeship_report tr 
                 WHERE tr.territory_id = t.territory_id) AS report_count
            FROM trusteeship_territory t
            JOIN member_state ms ON t.administering_state_id = ms.state_id
            ORDER BY t.territory_name
        `);
        res.json(territories);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single territory with reports
router.get('/territories/:id', async (req, res) => {
    try {
        const [territory] = await query(`
            SELECT 
                t.*,
                ms.state_name AS administering_authority
            FROM trusteeship_territory t
            JOIN member_state ms ON t.administering_state_id = ms.state_id
            WHERE t.territory_id = ?
        `, [req.params.id]);

        if (!territory) {
            return res.status(404).json({ error: 'Territory not found' });
        }

        const reports = await query(`
            SELECT 
                tr.*,
                CONCAT(o.first_name, ' ', o.last_name) AS reporting_officer_name
            FROM trusteeship_report tr
            JOIN officer o ON tr.reporting_officer_id = o.officer_id
            WHERE tr.territory_id = ?
            ORDER BY tr.report_year DESC
        `, [req.params.id]);

        res.json({ ...territory, reports });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET all reports
router.get('/reports', async (req, res) => {
    try {
        const { territory, type, status, limit = 50 } = req.query;
        let sql = `
            SELECT 
                tr.*,
                tt.territory_name,
                tt.current_status AS territory_status,
                ms.state_name AS administering_authority,
                CONCAT(o.first_name, ' ', o.last_name) AS reporting_officer_name
            FROM trusteeship_report tr
            JOIN trusteeship_territory tt ON tr.territory_id = tt.territory_id
            JOIN member_state ms ON tt.administering_state_id = ms.state_id
            JOIN officer o ON tr.reporting_officer_id = o.officer_id
            WHERE 1=1
        `;
        const params = [];

        if (territory) {
            sql += ' AND tr.territory_id = ?';
            params.push(territory);
        }
        if (type) {
            sql += ' AND tr.report_type = ?';
            params.push(type);
        }
        if (status) {
            sql += ' AND tr.review_status = ?';
            params.push(status);
        }

        sql += ' ORDER BY tr.report_year DESC, tr.submission_date DESC LIMIT ?';
        params.push(parseInt(limit));

        const reports = await query(sql, params);
        res.json(reports);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single report
router.get('/reports/:id', async (req, res) => {
    try {
        const [report] = await query(`
            SELECT 
                tr.*,
                tt.territory_name,
                ms.state_name AS administering_authority,
                CONCAT(o.first_name, ' ', o.last_name) AS reporting_officer_name
            FROM trusteeship_report tr
            JOIN trusteeship_territory tt ON tr.territory_id = tt.territory_id
            JOIN member_state ms ON tt.administering_state_id = ms.state_id
            JOIN officer o ON tr.reporting_officer_id = o.officer_id
            WHERE tr.report_id = ?
        `, [req.params.id]);

        if (!report) {
            return res.status(404).json({ error: 'Report not found' });
        }

        res.json(report);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST create report
router.post('/reports', async (req, res) => {
    try {
        const { territory_id, report_type, report_year, reporting_officer_id,
            findings, recommendations } = req.body;

        // Generate report number
        const year = new Date().getFullYear();
        const [result] = await query(`
            INSERT INTO trusteeship_report (
                report_number, territory_id, report_type, report_year,
                reporting_officer_id, submission_date, review_status,
                findings, recommendations
            ) VALUES (
                CONCAT('TC/REP/', ?, '/', ?), ?, ?, ?,
                ?, CURDATE(), 'SUBMITTED', ?, ?
            )
        `, [year, Date.now() % 10000, territory_id, report_type, report_year,
            reporting_officer_id, findings, recommendations]);

        res.status(201).json({ report_id: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT update report decision
router.put('/reports/:id/decision', async (req, res) => {
    try {
        const { review_status, decision } = req.body;
        await query(`
            UPDATE trusteeship_report 
            SET review_status = ?, decision = ?, decision_date = CURDATE()
            WHERE report_id = ?
        `, [review_status, decision, req.params.id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET trusteeship statistics
router.get('/stats', async (req, res) => {
    try {
        const stats = await query(`
            SELECT 
                COUNT(DISTINCT tt.territory_id) AS total_territories,
                SUM(CASE WHEN tt.current_status = 'INDEPENDENT' THEN 1 ELSE 0 END) AS independent,
                SUM(CASE WHEN tt.current_status = 'FREE_ASSOCIATION' THEN 1 ELSE 0 END) AS free_association,
                COUNT(DISTINCT tr.report_id) AS total_reports,
                MAX(tr.report_year) AS last_report_year
            FROM trusteeship_territory tt
            LEFT JOIN trusteeship_report tr ON tt.territory_id = tr.territory_id
        `);
        res.json(stats[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
