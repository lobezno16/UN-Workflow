// ============================================================================
// Voting Routes - Vote submission and results for GA/SC/ECOSOC
// ============================================================================

const express = require('express');
const router = express.Router();
const { query, withTransaction, pool } = require('../config/db');

// GET vote summary for a matter
router.get('/matter/:matterId', async (req, res) => {
    try {
        const summary = await query(`
            SELECT 
                m.matter_number,
                m.title,
                m.voting_threshold,
                m.status,
                o.organ_code,
                COUNT(v.vote_id) AS total_votes,
                SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_votes,
                SUM(CASE WHEN v.vote_value = 'NO' THEN 1 ELSE 0 END) AS no_votes,
                SUM(CASE WHEN v.vote_value = 'ABSTAIN' THEN 1 ELSE 0 END) AS abstentions
            FROM matter m
            JOIN un_organ o ON m.organ_id = o.organ_id
            LEFT JOIN vote v ON m.matter_id = v.matter_id AND v.is_valid = TRUE
            WHERE m.matter_id = ?
            GROUP BY m.matter_id
        `, [req.params.matterId]);

        // Get individual votes
        const votes = await query(`
            SELECT 
                v.*,
                ms.state_name,
                ms.state_code,
                CONCAT(d.first_name, ' ', d.last_name) AS delegate_name
            FROM vote v
            JOIN member_state ms ON v.state_id = ms.state_id
            JOIN delegate d ON v.delegate_id = d.delegate_id
            WHERE v.matter_id = ?
            ORDER BY v.vote_timestamp
        `, [req.params.matterId]);

        res.json({ summary: summary[0], votes });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST cast a vote (with concurrency protection)
router.post('/', async (req, res) => {
    try {
        const result = await withTransaction(async (connection) => {
            const { matter_id, state_id, delegate_id, vote_value } = req.body;

            // Lock the matter row to check status
            const [[matter]] = await connection.execute(
                'SELECT status, requires_voting FROM matter WHERE matter_id = ? FOR UPDATE',
                [matter_id]
            );

            if (!matter) {
                throw new Error('Matter not found');
            }
            if (matter.status !== 'IN_VOTING') {
                throw new Error('Matter is not in voting stage');
            }

            // Check for existing vote (with lock)
            const [[existingVote]] = await connection.execute(
                'SELECT vote_id FROM vote WHERE matter_id = ? AND state_id = ? FOR UPDATE',
                [matter_id, state_id]
            );

            if (existingVote) {
                throw new Error('This state has already voted on this matter');
            }

            // Cast the vote
            const [insertResult] = await connection.execute(`
                INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
                VALUES (?, ?, ?, ?)
            `, [matter_id, state_id, delegate_id, vote_value]);

            return { vote_id: insertResult.insertId, vote_value };
        });

        res.status(201).json(result);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// PUT invalidate a vote
router.put('/:voteId/invalidate', async (req, res) => {
    try {
        const { reason } = req.body;
        await query(`
            UPDATE vote 
            SET is_valid = FALSE, invalidation_reason = ?
            WHERE vote_id = ?
        `, [reason, req.params.voteId]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST compute vote outcome and potentially create resolution
router.post('/matter/:matterId/compute', async (req, res) => {
    try {
        const result = await withTransaction(async (connection) => {
            const matterId = req.params.matterId;

            // Get matter details
            const [[matter]] = await connection.execute(`
                SELECT m.*, o.organ_code 
                FROM matter m 
                JOIN un_organ o ON m.organ_id = o.organ_id
                WHERE m.matter_id = ? FOR UPDATE
            `, [matterId]);

            if (!matter) {
                throw new Error('Matter not found');
            }

            // Compute votes
            const [[votes]] = await connection.execute(`
                SELECT 
                    SUM(CASE WHEN vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_count,
                    SUM(CASE WHEN vote_value = 'NO' THEN 1 ELSE 0 END) AS no_count,
                    SUM(CASE WHEN vote_value = 'ABSTAIN' THEN 1 ELSE 0 END) AS abstain_count
                FROM vote
                WHERE matter_id = ? AND is_valid = TRUE
            `, [matterId]);

            const yesCount = votes.yes_count || 0;
            const noCount = votes.no_count || 0;
            const abstainCount = votes.abstain_count || 0;
            const totalVoting = yesCount + noCount;
            const yesPercentage = totalVoting > 0 ? (yesCount * 100) / totalVoting : 0;
            const passed = yesPercentage >= matter.voting_threshold;

            // Update matter status
            const newStatus = passed ? 'PASSED' : 'REJECTED';
            await connection.execute(
                'UPDATE matter SET status = ?, actual_completion_date = CURDATE() WHERE matter_id = ?',
                [newStatus, matterId]
            );

            // If passed, create resolution
            let resolution_number = null;
            if (passed) {
                const [[{ next_id }]] = await connection.execute(
                    'SELECT COALESCE(MAX(resolution_id), 0) + 1 AS next_id FROM resolution'
                );
                const year = new Date().getFullYear();

                switch (matter.organ_code) {
                    case 'GA':
                        resolution_number = `A/RES/${year}/${next_id}`;
                        break;
                    case 'SC':
                        resolution_number = `S/RES/${2700 + next_id}`;
                        break;
                    case 'ECOSOC':
                        resolution_number = `E/RES/${year}/${next_id}`;
                        break;
                }

                const { preamble, operative_text } = req.body;
                await connection.execute(`
                    INSERT INTO resolution (
                        resolution_number, matter_id, organ_id, title,
                        preamble, operative_text, adoption_date,
                        yes_votes, no_votes, abstentions, is_binding
                    ) VALUES (?, ?, ?, ?, ?, ?, CURDATE(), ?, ?, ?, ?)
                `, [
                    resolution_number, matterId, matter.organ_id, matter.title,
                    preamble || '', operative_text || '',
                    yesCount, noCount, abstainCount,
                    matter.organ_code === 'SC'
                ]);
            }

            return {
                outcome: passed ? 'PASSED' : 'REJECTED',
                yes_votes: yesCount,
                no_votes: noCount,
                abstentions: abstainCount,
                yes_percentage: yesPercentage.toFixed(2),
                threshold: matter.voting_threshold,
                resolution_number
            };
        });

        res.json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET eligible voters for a matter (states that haven't voted yet)
router.get('/matter/:matterId/eligible', async (req, res) => {
    try {
        const eligible = await query(`
            SELECT 
                ms.state_id,
                ms.state_name,
                ms.state_code,
                d.delegate_id,
                CONCAT(d.first_name, ' ', d.last_name) AS delegate_name
            FROM member_state ms
            JOIN delegate d ON ms.state_id = d.state_id
            JOIN matter m ON d.organ_id = m.organ_id
            WHERE m.matter_id = ?
            AND d.status = 'ACTIVE'
            AND d.voting_authority = TRUE
            AND ms.state_id NOT IN (
                SELECT state_id FROM vote WHERE matter_id = ?
            )
            ORDER BY ms.state_name
        `, [req.params.matterId, req.params.matterId]);
        res.json(eligible);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
