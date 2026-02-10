// ============================================================================
// Secretariat Routes - Directives, departments, and officers
// ============================================================================

const express = require('express');
const router = express.Router();
const { query, withTransaction } = require('../config/db');

// GET all directives
router.get('/directives', async (req, res) => {
    try {
        const { type, status, department, limit = 50 } = req.query;
        let sql = `
            SELECT 
                d.*,
                iss.department_name AS issuing_department,
                tgt.department_name AS target_department,
                CONCAT(o.first_name, ' ', o.last_name) AS issued_by_name,
                (SELECT COUNT(*) FROM directive_acknowledgment da 
                 WHERE da.directive_id = d.directive_id) AS acknowledgment_count
            FROM directive d
            JOIN department iss ON d.issuing_department_id = iss.department_id
            LEFT JOIN department tgt ON d.target_department_id = tgt.department_id
            JOIN officer o ON d.issued_by_officer_id = o.officer_id
            WHERE 1=1
        `;
        const params = [];

        if (type) {
            sql += ' AND d.directive_type = ?';
            params.push(type);
        }
        if (status) {
            sql += ' AND d.status = ?';
            params.push(status);
        }
        if (department) {
            sql += ' AND d.issuing_department_id = ?';
            params.push(department);
        }

        const limitNum = Math.min(Math.max(1, parseInt(limit) || 50), 500);
        sql += ` ORDER BY d.issue_date DESC LIMIT ${limitNum}`;

        const directives = await query(sql, params);
        res.json(directives);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET single directive
router.get('/directives/:id', async (req, res) => {
    try {
        const [directive] = await query(`
            SELECT 
                d.*,
                iss.department_name AS issuing_department,
                tgt.department_name AS target_department,
                CONCAT(o.first_name, ' ', o.last_name) AS issued_by_name
            FROM directive d
            JOIN department iss ON d.issuing_department_id = iss.department_id
            LEFT JOIN department tgt ON d.target_department_id = tgt.department_id
            JOIN officer o ON d.issued_by_officer_id = o.officer_id
            WHERE d.directive_id = ?
        `, [req.params.id]);

        if (!directive) {
            return res.status(404).json({ error: 'Directive not found' });
        }

        // Get acknowledgments
        const acknowledgments = await query(`
            SELECT 
                da.*,
                CONCAT(o.first_name, ' ', o.last_name) AS officer_name,
                dept.department_name
            FROM directive_acknowledgment da
            JOIN officer o ON da.officer_id = o.officer_id
            LEFT JOIN department dept ON o.department_id = dept.department_id
            WHERE da.directive_id = ?
            ORDER BY da.acknowledged_at
        `, [req.params.id]);

        res.json({ ...directive, acknowledgments });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST create directive
router.post('/directives', async (req, res) => {
    try {
        const result = await withTransaction(async (connection) => {
            const { directive_type, title, content, issuing_department_id,
                target_department_id, issued_by_officer_id, effective_date,
                expiry_date, priority, requires_acknowledgment } = req.body;

            // Generate directive number
            const year = new Date().getFullYear();
            const [[{ next_id }]] = await connection.execute(
                'SELECT COALESCE(MAX(directive_id), 0) + 1 AS next_id FROM directive'
            );

            const typePrefix = {
                'POLICY': 'ST/SGB',
                'CIRCULAR': 'ST/AI',
                'BULLETIN': 'ST/IC',
                'ADMINISTRATIVE': 'ST/ADM',
                'INSTRUCTION': 'ST/INS'
            };
            const directive_number = `${typePrefix[directive_type] || 'ST'}/${year}/${next_id}`;

            const [insertResult] = await connection.execute(`
                INSERT INTO directive (
                    directive_number, directive_type, title, content,
                    issuing_department_id, target_department_id, issued_by_officer_id,
                    issue_date, effective_date, expiry_date, priority, status,
                    requires_acknowledgment
                ) VALUES (?, ?, ?, ?, ?, ?, ?, CURDATE(), ?, ?, ?, 'ISSUED', ?)
            `, [directive_number, directive_type, title, content,
                issuing_department_id, target_department_id, issued_by_officer_id,
                effective_date, expiry_date, priority, requires_acknowledgment]);

            return { directive_id: insertResult.insertId, directive_number };
        });

        res.status(201).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// PUT update directive status
router.put('/directives/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        await query(
            'UPDATE directive SET status = ? WHERE directive_id = ?',
            [status, req.params.id]
        );
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST acknowledge directive
router.post('/directives/:id/acknowledge', async (req, res) => {
    try {
        const { officer_id, notes } = req.body;
        const [result] = await query(`
            INSERT INTO directive_acknowledgment (directive_id, officer_id, notes)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE acknowledged_at = NOW(), notes = VALUES(notes)
        `, [req.params.id, officer_id, notes]);
        res.status(201).json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET all departments
router.get('/departments', async (req, res) => {
    try {
        const departments = await query(`
            SELECT 
                d.*,
                p.department_name AS parent_department_name,
                (SELECT COUNT(*) FROM officer o WHERE o.department_id = d.department_id) AS officer_count,
                (SELECT COUNT(*) FROM directive dir WHERE dir.issuing_department_id = d.department_id) AS directive_count
            FROM department d
            LEFT JOIN department p ON d.parent_department_id = p.department_id
            WHERE d.is_active = TRUE
            ORDER BY d.department_name
        `);
        res.json(departments);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET officers
router.get('/officers', async (req, res) => {
    try {
        const { department, role, limit = 100 } = req.query;
        let sql = `
            SELECT 
                o.*,
                r.role_name,
                r.permission_level,
                d.department_name,
                org.organ_name
            FROM officer o
            JOIN role r ON o.role_id = r.role_id
            LEFT JOIN department d ON o.department_id = d.department_id
            JOIN un_organ org ON o.organ_id = org.organ_id
            WHERE o.employment_status = 'ACTIVE'
        `;
        const params = [];

        if (department) {
            sql += ' AND o.department_id = ?';
            params.push(department);
        }
        if (role) {
            sql += ' AND o.role_id = ?';
            params.push(role);
        }

        const limitNum = Math.min(Math.max(1, parseInt(limit) || 100), 500);
        sql += ` ORDER BY r.permission_level DESC, o.last_name LIMIT ${limitNum}`;

        const officers = await query(sql, params);
        res.json(officers);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET roles
router.get('/roles', async (req, res) => {
    try {
        const roles = await query('SELECT * FROM role ORDER BY permission_level DESC');
        res.json(roles);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
