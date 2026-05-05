// ============================================================================
// Auth Routes — Login, Me, Logout
// ============================================================================

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query } = require('../config/db');
const { requireAuth, JWT_SECRET } = require('../middleware/auth');

// POST /api/auth/login
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ error: 'Username and password are required.' });
        }

        // Fetch user with delegate info joined
        const rows = await query(`
            SELECT 
                u.user_id,
                u.username,
                u.password_hash,
                u.role,
                u.delegate_id,
                u.is_active,
                d.first_name,
                d.last_name,
                d.title,
                d.organ_id,
                ms.state_name,
                ms.state_code,
                ms.is_sc_permanent_member,
                o.organ_code,
                o.organ_name
            FROM users u
            LEFT JOIN delegate d ON u.delegate_id = d.delegate_id
            LEFT JOIN member_state ms ON d.state_id = ms.state_id
            LEFT JOIN un_organ o ON d.organ_id = o.organ_id
            WHERE u.username = ?
        `, [username]);

        if (rows.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials.' });
        }

        const user = rows[0];

        if (!user.is_active) {
            return res.status(403).json({ error: 'Account is deactivated.' });
        }

        const passwordMatch = await bcrypt.compare(password, user.password_hash);
        if (!passwordMatch) {
            return res.status(401).json({ error: 'Invalid credentials.' });
        }

        // Build token payload
        const payload = {
            user_id: user.user_id,
            username: user.username,
            role: user.role,
            delegate_id: user.delegate_id || null,
        };

        const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '8h' });

        // Build profile response
        const profile = {
            user_id: user.user_id,
            username: user.username,
            role: user.role,
        };

        if (user.role === 'delegate') {
            profile.delegate = {
                delegate_id: user.delegate_id,
                first_name: user.first_name,
                last_name: user.last_name,
                title: user.title,
                state_name: user.state_name,
                state_code: user.state_code,
                is_sc_permanent_member: user.is_sc_permanent_member,
                organ_id: user.organ_id,
                organ_code: user.organ_code,
                organ_name: user.organ_name,
            };
        }

        res.json({ token, profile });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Login failed. Please try again.' });
    }
});

// GET /api/auth/me — returns current user profile from token
router.get('/me', requireAuth, async (req, res) => {
    try {
        const rows = await query(`
            SELECT 
                u.user_id, u.username, u.role, u.delegate_id,
                d.first_name, d.last_name, d.title, d.organ_id,
                ms.state_name, ms.state_code, ms.is_sc_permanent_member,
                o.organ_code, o.organ_name
            FROM users u
            LEFT JOIN delegate d ON u.delegate_id = d.delegate_id
            LEFT JOIN member_state ms ON d.state_id = ms.state_id
            LEFT JOIN un_organ o ON d.organ_id = o.organ_id
            WHERE u.user_id = ?
        `, [req.user.user_id]);

        if (rows.length === 0) {
            return res.status(404).json({ error: 'User not found.' });
        }

        const user = rows[0];
        const profile = { user_id: user.user_id, username: user.username, role: user.role };

        if (user.role === 'delegate') {
            profile.delegate = {
                delegate_id: user.delegate_id,
                first_name: user.first_name,
                last_name: user.last_name,
                title: user.title,
                state_name: user.state_name,
                state_code: user.state_code,
                is_sc_permanent_member: user.is_sc_permanent_member,
                organ_id: user.organ_id,
                organ_code: user.organ_code,
                organ_name: user.organ_name,
            };
        }

        res.json(profile);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
