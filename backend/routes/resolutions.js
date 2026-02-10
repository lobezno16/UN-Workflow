// ============================================================================
// Resolutions Routes - Resolution registry and management
// ============================================================================

const express = require('express');
const router = express.Router();
const { query } = require('../config/db');

// GET all resolutions
router.get('/', async (req, res) => {
    try {
        const { organ, status, year, limit = 50 } = req.query;
        let sql = `
            SELECT 
                r.*,
                o.organ_code,
                o.organ_name,
                m.matter_number
            FROM resolution r
            JOIN un_organ o ON r.organ_id = o.organ_id
            JOIN matter m ON r.matter_id = m.matter_id
            WHERE 1=1
        `;
        const params = [];

        if (organ) {
            sql += ' AND o.organ_code = ?';
            params.push(organ);
        }
        if (status) {
            sql += ' AND r.status = ?';
            params.push(status);
        }
        if (year) {
            sql += ' AND YEAR(r.adoption_date) = ?';
            params.push(year);
        }

        const limitNum = Math.min(Math.max(1, parseInt(limit) || 50), 500);
        sql += ` ORDER BY r.adoption_date DESC LIMIT ${limitNum}`;

        const resolutions = await query(sql, params);
        res.json(resolutions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single resolution
router.get('/:id', async (req, res) => {
    try {
        const [resolution] = await query(`
            SELECT 
                r.*,
                o.organ_code,
                o.organ_name,
                m.matter_number,
                m.description AS matter_description
            FROM resolution r
            JOIN un_organ o ON r.organ_id = o.organ_id
            JOIN matter m ON r.matter_id = m.matter_id
            WHERE r.resolution_id = ?
        `, [req.params.id]);

        if (!resolution) {
            return res.status(404).json({ error: 'Resolution not found' });
        }

        res.json(resolution);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET resolution by number
router.get('/number/:resNumber', async (req, res) => {
    try {
        const [resolution] = await query(`
            SELECT * FROM resolution WHERE resolution_number = ?
        `, [req.params.resNumber]);

        if (!resolution) {
            return res.status(404).json({ error: 'Resolution not found' });
        }

        res.json(resolution);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT update resolution status
router.put('/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        await query(
            'UPDATE resolution SET status = ? WHERE resolution_id = ?',
            [status, req.params.id]
        );
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET resolution statistics
router.get('/stats/overview', async (req, res) => {
    try {
        const stats = await query(`
            SELECT 
                o.organ_code,
                o.organ_name,
                COUNT(r.resolution_id) AS total_resolutions,
                SUM(CASE WHEN r.status = 'IN_FORCE' THEN 1 ELSE 0 END) AS in_force,
                SUM(CASE WHEN r.is_binding = TRUE THEN 1 ELSE 0 END) AS binding_resolutions,
                AVG(r.yes_votes) AS avg_yes_votes,
                AVG(r.yes_votes * 100.0 / NULLIF(r.yes_votes + r.no_votes, 0)) AS avg_approval_rate
            FROM un_organ o
            LEFT JOIN resolution r ON o.organ_id = r.organ_id
            WHERE o.organ_code IN ('GA', 'SC', 'ECOSOC')
            GROUP BY o.organ_id
        `);
        res.json(stats);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
