// ============================================================================
// Dashboard Routes - Aggregated data for main dashboard
// ============================================================================

const express = require('express');
const router = express.Router();
const { query } = require('../config/db');

// GET main dashboard statistics
router.get('/stats', async (req, res) => {
    try {
        // Overall counts
        const [counts] = await query(`
            SELECT 
                (SELECT COUNT(*) FROM matter) AS total_matters,
                (SELECT COUNT(*) FROM matter WHERE status IN ('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'PENDING_APPROVAL', 'IN_VOTING')) AS pending_matters,
                (SELECT COUNT(*) FROM resolution) AS total_resolutions,
                (SELECT COUNT(*) FROM icj_case WHERE status NOT IN ('CLOSED', 'JUDGMENT_ISSUED')) AS active_icj_cases,
                (SELECT COUNT(*) FROM directive WHERE status = 'IN_EFFECT') AS active_directives,
                (SELECT COUNT(*) FROM officer WHERE employment_status = 'ACTIVE') AS active_officers,
                (SELECT COUNT(*) FROM delegate WHERE status = 'ACTIVE') AS active_delegates,
                (SELECT COUNT(*) FROM member_state WHERE is_active = TRUE) AS member_states
        `);

        res.json(counts);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET recent activity
router.get('/activity', async (req, res) => {
    try {
        const activity = await query(`
            SELECT 
                al.log_id,
                al.table_name,
                al.action_type,
                al.action_description,
                al.action_timestamp,
                COALESCE(
                    CONCAT(o.first_name, ' ', o.last_name),
                    CONCAT(d.first_name, ' ', d.last_name),
                    'System'
                ) AS performed_by
            FROM audit_log al
            LEFT JOIN officer o ON al.performed_by_officer_id = o.officer_id
            LEFT JOIN delegate d ON al.performed_by_delegate_id = d.delegate_id
            ORDER BY al.action_timestamp DESC
            LIMIT 20
        `);
        res.json(activity);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET matters by organ
router.get('/matters-by-organ', async (req, res) => {
    try {
        const data = await query(`
            SELECT 
                o.organ_code,
                o.organ_name,
                COUNT(m.matter_id) AS total,
                SUM(CASE WHEN m.status = 'PASSED' THEN 1 ELSE 0 END) AS passed,
                SUM(CASE WHEN m.status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected,
                SUM(CASE WHEN m.status = 'IN_VOTING' THEN 1 ELSE 0 END) AS in_voting,
                SUM(CASE WHEN m.status IN ('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'PENDING_APPROVAL') THEN 1 ELSE 0 END) AS processing
            FROM un_organ o
            LEFT JOIN matter m ON o.organ_id = m.organ_id
            GROUP BY o.organ_id
            ORDER BY o.organ_id
        `);
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET recent votes
router.get('/recent-votes', async (req, res) => {
    try {
        const votes = await query(`
            SELECT 
                v.vote_id,
                m.matter_number,
                m.title AS matter_title,
                ms.state_name,
                v.vote_value,
                v.vote_timestamp,
                o.organ_code
            FROM vote v
            JOIN matter m ON v.matter_id = m.matter_id
            JOIN member_state ms ON v.state_id = ms.state_id
            JOIN un_organ o ON m.organ_id = o.organ_id
            ORDER BY v.vote_timestamp DESC
            LIMIT 15
        `);
        res.json(votes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET pending items (approvals, reviews)
router.get('/pending', async (req, res) => {
    try {
        const pendingApprovals = await query(`
            SELECT 
                a.approval_id,
                m.matter_number,
                m.title,
                o.organ_code,
                a.approval_level,
                CONCAT(off.first_name, ' ', off.last_name) AS approver_name,
                a.created_at
            FROM approval a
            JOIN matter m ON a.matter_id = m.matter_id
            JOIN un_organ o ON m.organ_id = o.organ_id
            JOIN officer off ON a.approver_officer_id = off.officer_id
            WHERE a.approval_status = 'PENDING'
            ORDER BY a.created_at
            LIMIT 10
        `);

        const mattersInVoting = await query(`
            SELECT 
                m.matter_id,
                m.matter_number,
                m.title,
                o.organ_code,
                (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) AS votes_cast,
                m.voting_threshold
            FROM matter m
            JOIN un_organ o ON m.organ_id = o.organ_id
            WHERE m.status = 'IN_VOTING'
            ORDER BY m.updated_at DESC
        `);

        res.json({ pendingApprovals, mattersInVoting });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET member states with representatives
router.get('/member-states', async (req, res) => {
    try {
        const states = await query(`
            SELECT 
                ms.*,
                (SELECT COUNT(*) FROM delegate d 
                 WHERE d.state_id = ms.state_id AND d.status = 'ACTIVE') AS delegate_count,
                (SELECT COUNT(*) FROM vote v 
                 WHERE v.state_id = ms.state_id) AS total_votes
            FROM member_state ms
            WHERE ms.is_active = TRUE
            ORDER BY ms.state_name
        `);
        res.json(states);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
