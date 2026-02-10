// ============================================================================
// UN Organs Routes - CRUD operations for the 6 principal UN organs
// ============================================================================

const express = require('express');
const router = express.Router();
const { query } = require('../config/db');

// GET all organs
router.get('/', async (req, res) => {
    try {
        const organs = await query(`
            SELECT 
                o.*,
                (SELECT COUNT(*) FROM matter m WHERE m.organ_id = o.organ_id) AS matter_count,
                (SELECT COUNT(*) FROM officer off WHERE off.organ_id = o.organ_id) AS officer_count
            FROM un_organ o
            ORDER BY o.organ_id
        `);
        res.json(organs);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single organ by ID
router.get('/:id', async (req, res) => {
    try {
        const [organ] = await query(
            'SELECT * FROM un_organ WHERE organ_id = ?',
            [req.params.id]
        );
        if (!organ) {
            return res.status(404).json({ error: 'Organ not found' });
        }
        res.json(organ);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET organ statistics
router.get('/:id/stats', async (req, res) => {
    try {
        const stats = await query(`
            SELECT 
                o.organ_code,
                o.organ_name,
                COUNT(DISTINCT m.matter_id) AS total_matters,
                SUM(CASE WHEN m.status = 'PASSED' THEN 1 ELSE 0 END) AS passed_matters,
                SUM(CASE WHEN m.status = 'IN_VOTING' THEN 1 ELSE 0 END) AS voting_matters,
                SUM(CASE WHEN m.status IN ('DRAFT', 'SUBMITTED', 'UNDER_REVIEW') THEN 1 ELSE 0 END) AS pending_matters,
                COUNT(DISTINCT r.resolution_id) AS resolutions_issued
            FROM un_organ o
            LEFT JOIN matter m ON o.organ_id = m.organ_id
            LEFT JOIN resolution r ON o.organ_id = r.organ_id
            WHERE o.organ_id = ?
            GROUP BY o.organ_id
        `, [req.params.id]);
        res.json(stats[0] || {});
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET delegates for an organ
router.get('/:id/delegates', async (req, res) => {
    try {
        const delegates = await query(`
            SELECT 
                d.*,
                ms.state_name,
                ms.state_code
            FROM delegate d
            JOIN member_state ms ON d.state_id = ms.state_id
            WHERE d.organ_id = ? AND d.status = 'ACTIVE'
            ORDER BY ms.state_name
        `, [req.params.id]);
        res.json(delegates);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET officers for an organ
router.get('/:id/officers', async (req, res) => {
    try {
        const officers = await query(`
            SELECT 
                o.*,
                r.role_name,
                d.department_name
            FROM officer o
            JOIN role r ON o.role_id = r.role_id
            LEFT JOIN department d ON o.department_id = d.department_id
            WHERE o.organ_id = ? AND o.employment_status = 'ACTIVE'
            ORDER BY r.permission_level DESC, o.last_name
        `, [req.params.id]);
        res.json(officers);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
