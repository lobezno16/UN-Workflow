// ============================================================================
// routes/announcements.js
// Public GET + Admin POST/PUT/DELETE for news & updates
// ============================================================================
const express = require('express');
const router  = express.Router();
const { query } = require('../config/db');
const { requireAdmin } = require('../middleware/auth');

// GET all announcements (public)
router.get('/', async (req, res) => {
    try {
        const { organ, limit = 20 } = req.query;
        let sql = `
            SELECT a.*, o.organ_code, o.organ_name
            FROM announcement a
            LEFT JOIN un_organ o ON a.organ_id = o.organ_id
            WHERE 1=1
        `;
        const params = [];
        if (organ) { sql += ' AND o.organ_code = ?'; params.push(organ); }
        sql += ` ORDER BY a.is_pinned DESC, a.created_at DESC LIMIT ${Math.min(parseInt(limit)||20, 100)}`;
        const rows = await query(sql, params);
        res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST create announcement (admin only)
router.post('/', requireAdmin, async (req, res) => {
    try {
        const { organ_id, title, content, category = 'NEWS', is_pinned = 0 } = req.body;
        if (!title || !content) return res.status(400).json({ error: 'title and content are required.' });
        const result = await query(
            `INSERT INTO announcement (organ_id, title, content, category, published_by, is_pinned)
             VALUES (?, ?, ?, ?, 'admin', ?)`,
            [organ_id || null, title, content, category, is_pinned ? 1 : 0]
        );
        res.status(201).json({ announcement_id: result.insertId, message: 'Announcement posted.' });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// DELETE announcement (admin only)
router.delete('/:id', requireAdmin, async (req, res) => {
    try {
        await query('DELETE FROM announcement WHERE announcement_id = ?', [req.params.id]);
        res.json({ message: 'Announcement deleted.' });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// PATCH pin/unpin (admin only)
router.patch('/:id/pin', requireAdmin, async (req, res) => {
    try {
        const { is_pinned } = req.body;
        await query('UPDATE announcement SET is_pinned = ? WHERE announcement_id = ?', [is_pinned ? 1 : 0, req.params.id]);
        res.json({ message: 'Updated.' });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

module.exports = router;
