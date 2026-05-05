// ============================================================================
// Auth Middleware — JWT Verification
// ============================================================================

const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'un-workflow-secret-2026';

/**
 * Verifies JWT from Authorization header.
 * Attaches req.user = { user_id, username, role, delegate_id } on success.
 */
function requireAuth(req, res, next) {
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Authentication required. Please log in.' });
    }

    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        if (err.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Session expired. Please log in again.' });
        }
        return res.status(401).json({ error: 'Invalid token. Please log in.' });
    }
}

/**
 * Requires admin role. Must be used after requireAuth.
 */
function requireAdmin(req, res, next) {
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Admin access required.' });
    }
    next();
}

/**
 * Requires delegate role. Must be used after requireAuth.
 */
function requireDelegate(req, res, next) {
    if (!req.user || req.user.role !== 'delegate') {
        return res.status(403).json({ error: 'Delegate access required.' });
    }
    next();
}

module.exports = { requireAuth, requireAdmin, requireDelegate, JWT_SECRET };
