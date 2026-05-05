// ============================================================================
// Matters Routes - CRUD and workflow operations for UN matters
// ============================================================================

const express = require('express');
const router = express.Router();
const { query, withTransaction, pool } = require('../config/db');
const { requireAuth, requireAdmin } = require('../middleware/auth');
console.log('[matters.js] MODULE LOADED v7 from:', __filename);


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


// PUT update matter status — admin only
router.put('/:id/status', requireAuth, requireAdmin, async (req, res) => {
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

// POST create a new matter (admin only)
router.post('/', requireAuth, requireAdmin, async (req, res) => {
    const fs = require('fs');
    const os = require('os');
    const logFile = require('path').join(os.tmpdir(), 'matter_debug.txt');
    const log = msg => { try { fs.appendFileSync(logFile, msg + '\n'); } catch(e){} };
    log('=== POST /api/matters ===');
    try {
        const {
            matter_number, title, description, organ_code,
            matter_type, priority, voting_threshold,
            session_number, agenda_item_number, submission_date
        } = req.body;

        log('body: ' + JSON.stringify(req.body));


        if (!matter_number || !title || !organ_code) {
            return res.status(400).json({ error: 'matter_number, title, and organ_code are required.' });
        }

        // Block Trusteeship Council
        if (organ_code.toUpperCase() === 'TC') {
            return res.status(403).json({ error: 'Matters cannot be created for the Trusteeship Council.' });
        }

        // Resolve organ_id
        log('querying organ...');
        const [organ] = await query('SELECT organ_id FROM un_organ WHERE organ_code = ?', [organ_code.toUpperCase()]);
        log('organ: ' + JSON.stringify(organ));
        if (!organ) return res.status(404).json({ error: `Organ '${organ_code}' not found.` });

        // Null-safe helpers
        const safeStr = (v, fallback = null) =>
            (v === undefined || v === null || v === '') ? fallback : String(v);
        const safeInt = (v, def = null) => {
            if (v === null || v === undefined || v === '') return def;
            const n = parseInt(v, 10);
            return isNaN(n) ? def : n;
        };

        // ICJ cases are adjudicated by judges — threshold is NULL/not applicable
        const isICJ = organ_code.toUpperCase() === 'ICJ';
        const threshold = isICJ ? null : safeInt(voting_threshold, 50);
        log('threshold: ' + threshold + ' isICJ: ' + isICJ);

        // Satisfy chk_submitter constraint — attribute to first Secretariat officer
        log('querying officer...');
        const [officer] = await query('SELECT officer_id FROM officer ORDER BY officer_id ASC LIMIT 1');
        log('officer: ' + JSON.stringify(officer));
        const officerId = officer ? officer.officer_id : null;

        // Only allow ENUM-valid values
        const VALID_TYPES = ['RESOLUTION', 'CASE', 'DIRECTIVE', 'CIRCULAR', 'OVERSIGHT_REPORT', 'DECISION'];
        const VALID_PRIOS = ['LOW', 'MEDIUM', 'HIGH', 'URGENT', 'CRITICAL'];
        const resolvedType = VALID_TYPES.includes(matter_type) ? matter_type : 'RESOLUTION';
        const resolvedPrio = VALID_PRIOS.includes(priority)    ? priority    : 'MEDIUM';

        // description is NOT NULL in schema — use fallback string
        const safeDesc = safeStr(description, '(No description provided)');

        const sqlParams = [
            safeStr(matter_number),
            safeStr(title),
            safeDesc,
            organ.organ_id,
            resolvedType,
            resolvedPrio,
            threshold,
            officerId,
            safeStr(session_number),
            safeStr(agenda_item_number),
            safeStr(submission_date) || new Date().toISOString().slice(0, 10)
        ];

        log('sqlParams: ' + JSON.stringify(sqlParams));
        sqlParams.forEach((p, i) => { if (p === undefined) log('  !! UNDEFINED at index ' + i); });

        // Nuclear safety net: undefined → null so mysql2 never rejects
        const cleanParams = sqlParams.map(p => p === undefined ? null : p);
        log('cleanParams: ' + JSON.stringify(cleanParams));

        // Use pool.query (text protocol)
        log('about to pool.query...');
        const [result] = await pool.query(
            `INSERT INTO matter
               (matter_number, title, description, organ_id, matter_type, priority,
                voting_threshold, submitted_by_officer_id,
                session_number, agenda_item_number, submission_date, status)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'SUBMITTED')`,
            cleanParams
        );
        log('INSERT success, id: ' + result.insertId);

        res.status(201).json({ matter_id: result.insertId, message: 'Matter created successfully.' });
    } catch (error) {
        log('ERROR: ' + error.message);
        console.error('[POST /api/matters] ERROR:', error.message);
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ error: 'A matter with that number already exists.' });
        }
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
