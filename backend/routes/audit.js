// ============================================================================
// Audit Routes - Audit log viewing and filtering
// ============================================================================

const express = require('express');
const router = express.Router();
const { query } = require('../config/db');

// GET audit logs with filtering
router.get('/', async (req, res) => {
    try {
        const { table, action, from_date, to_date, officer, limit = 100 } = req.query;
        let sql = `
            SELECT 
                al.*,
                COALESCE(
                    CONCAT(o.first_name, ' ', o.last_name),
                    CONCAT(d.first_name, ' ', d.last_name),
                    'System'
                ) AS performed_by_name,
                CASE 
                    WHEN al.performed_by_officer_id IS NOT NULL THEN 'Officer'
                    WHEN al.performed_by_delegate_id IS NOT NULL THEN 'Delegate'
                    ELSE 'System'
                END AS performer_type
            FROM audit_log al
            LEFT JOIN officer o ON al.performed_by_officer_id = o.officer_id
            LEFT JOIN delegate d ON al.performed_by_delegate_id = d.delegate_id
            WHERE 1=1
        `;
        const params = [];

        if (table) {
            sql += ' AND al.table_name = ?';
            params.push(table);
        }
        if (action) {
            sql += ' AND al.action_type = ?';
            params.push(action);
        }
        if (from_date) {
            sql += ' AND DATE(al.action_timestamp) >= ?';
            params.push(from_date);
        }
        if (to_date) {
            sql += ' AND DATE(al.action_timestamp) <= ?';
            params.push(to_date);
        }
        if (officer) {
            sql += ' AND al.performed_by_officer_id = ?';
            params.push(officer);
        }

        const limitNum = Math.min(Math.max(1, parseInt(limit) || 100), 500);
        sql += ` ORDER BY al.action_timestamp DESC LIMIT ${limitNum}`;

        const logs = await query(sql, params);
        res.json(logs);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET audit log for specific record
router.get('/record/:table/:id', async (req, res) => {
    try {
        const logs = await query(`
            SELECT 
                al.*,
                COALESCE(
                    CONCAT(o.first_name, ' ', o.last_name),
                    CONCAT(d.first_name, ' ', d.last_name),
                    'System'
                ) AS performed_by_name
            FROM audit_log al
            LEFT JOIN officer o ON al.performed_by_officer_id = o.officer_id
            LEFT JOIN delegate d ON al.performed_by_delegate_id = d.delegate_id
            WHERE al.table_name = ? AND al.record_id = ?
            ORDER BY al.action_timestamp DESC
        `, [req.params.table, req.params.id]);
        res.json(logs);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET audit statistics
router.get('/stats', async (req, res) => {
    try {
        const stats = await query(`
            SELECT 
                table_name,
                action_type,
                COUNT(*) AS count,
                MAX(action_timestamp) AS last_action
            FROM audit_log
            WHERE action_timestamp >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            GROUP BY table_name, action_type
            ORDER BY count DESC
        `);

        const activityByDay = await query(`
            SELECT 
                DATE(action_timestamp) AS date,
                COUNT(*) AS count
            FROM audit_log
            WHERE action_timestamp >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            GROUP BY DATE(action_timestamp)
            ORDER BY date DESC
        `);

        const topUsers = await query(`
            SELECT 
                COALESCE(
                    CONCAT(o.first_name, ' ', o.last_name),
                    CONCAT(d.first_name, ' ', d.last_name)
                ) AS user_name,
                COUNT(*) AS action_count
            FROM audit_log al
            LEFT JOIN officer o ON al.performed_by_officer_id = o.officer_id
            LEFT JOIN delegate d ON al.performed_by_delegate_id = d.delegate_id
            WHERE al.action_timestamp >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            AND (al.performed_by_officer_id IS NOT NULL OR al.performed_by_delegate_id IS NOT NULL)
            GROUP BY al.performed_by_officer_id, al.performed_by_delegate_id
            ORDER BY action_count DESC
            LIMIT 10
        `);

        res.json({ stats, activityByDay, topUsers });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET distinct tables for filter dropdown
router.get('/tables', async (req, res) => {
    try {
        const tables = await query('SELECT DISTINCT table_name FROM audit_log ORDER BY table_name');
        res.json(tables.map(t => t.table_name));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET distinct action types for filter dropdown
router.get('/actions', async (req, res) => {
    try {
        const actions = await query('SELECT DISTINCT action_type FROM audit_log ORDER BY action_type');
        res.json(actions.map(a => a.action_type));
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
