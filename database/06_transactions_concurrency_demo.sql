-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 06_transactions_concurrency_demo.sql - Transactions and Concurrency Control
-- ============================================================================
USE un_workflow_db;

-- ============================================================================
-- SECTION 1: ACID PROPERTIES DEMONSTRATION
-- ============================================================================
/*
ACID Properties in Database Transactions:

1. ATOMICITY: All operations in a transaction complete successfully, or none do.
2. CONSISTENCY: Database remains in a valid state before and after transaction.
3. ISOLATION: Concurrent transactions don't interfere with each other.
4. DURABILITY: Once committed, changes persist even after system failure.
*/

-- ============================================================================
-- TRANSACTION 1: Complete Matter Submission with Workflow Creation
-- Demonstrates ATOMICITY - all inserts succeed or all rollback
-- ============================================================================
DELIMITER //
CREATE PROCEDURE demo_transaction_matter_submission()
BEGIN
    DECLARE v_matter_id INT;
    DECLARE v_error_occurred BOOLEAN DEFAULT FALSE;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_error_occurred = TRUE;
    
    START TRANSACTION;
    
    -- Step 1: Insert the matter
    INSERT INTO matter (
        matter_number, title, description, matter_type, organ_id,
        submitted_by_delegate_id, priority, status, submission_date, requires_voting
    ) VALUES (
        'GA/DEMO/2024/001', 'Demo Resolution on Peace', 
        'Demonstration of atomic transaction for matter submission',
        'RESOLUTION', 1, 1, 'MEDIUM', 'SUBMITTED', CURRENT_DATE, TRUE
    );
    
    SET v_matter_id = LAST_INSERT_ID();
    
    -- Step 2: Create workflow stages (part of same atomic unit)
    INSERT INTO matter_workflow (matter_id, stage_number, stage_name, stage_status) VALUES
    (v_matter_id, 1, 'SUBMISSION', 'IN_PROGRESS'),
    (v_matter_id, 2, 'INITIAL_REVIEW', 'PENDING'),
    (v_matter_id, 3, 'COMMITTEE_REVIEW', 'PENDING'),
    (v_matter_id, 4, 'APPROVAL', 'PENDING'),
    (v_matter_id, 5, 'VOTING', 'PENDING'),
    (v_matter_id, 6, 'RESOLUTION_ISSUANCE', 'PENDING');
    
    -- Step 3: Create initial approval request
    INSERT INTO approval (matter_id, approver_officer_id, approval_level, approval_status)
    VALUES (v_matter_id, 6, 1, 'PENDING');
    
    IF v_error_occurred THEN
        ROLLBACK;
        SELECT 'Transaction ROLLED BACK due to error' AS result;
    ELSE
        COMMIT;
        SELECT CONCAT('Transaction COMMITTED. Matter ID: ', v_matter_id) AS result;
    END IF;
END//
DELIMITER ;

-- Execute and then cleanup
-- CALL demo_transaction_matter_submission();
-- DELETE FROM matter WHERE matter_number = 'GA/DEMO/2024/001';

-- ============================================================================
-- TRANSACTION 2: Vote Casting with Validation
-- Demonstrates CONSISTENCY - ensures valid state after vote
-- ============================================================================
DELIMITER //
CREATE PROCEDURE demo_transaction_voting(
    IN p_matter_id INT,
    IN p_state_id INT,
    IN p_delegate_id INT,
    IN p_vote_value VARCHAR(10)
)
BEGIN
    DECLARE v_matter_status VARCHAR(50);
    DECLARE v_existing_vote INT;
    DECLARE v_organ_code VARCHAR(10);
    
    START TRANSACTION;
    
    -- Validate matter is in voting stage
    SELECT m.status, o.organ_code INTO v_matter_status, v_organ_code
    FROM matter m
    JOIN un_organ o ON m.organ_id = o.organ_id
    WHERE m.matter_id = p_matter_id
    FOR UPDATE; -- Lock the row
    
    IF v_matter_status != 'IN_VOTING' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Matter is not in voting stage';
    END IF;
    
    IF v_organ_code NOT IN ('GA', 'SC', 'ECOSOC') THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only GA, SC, ECOSOC matters can be voted on';
    END IF;
    
    -- Check for existing vote (prevent duplicate)
    SELECT COUNT(*) INTO v_existing_vote
    FROM vote
    WHERE matter_id = p_matter_id AND state_id = p_state_id;
    
    IF v_existing_vote > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'This state has already voted on this matter';
    END IF;
    
    -- Cast the vote
    INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
    VALUES (p_matter_id, p_state_id, p_delegate_id, p_vote_value);
    
    COMMIT;
    SELECT CONCAT('Vote recorded: ', p_vote_value) AS result;
END//
DELIMITER ;

-- ============================================================================
-- TRANSACTION 3: Resolution Creation with Vote Verification
-- Demonstrates multiple table updates in single transaction
-- ============================================================================
DELIMITER //
CREATE PROCEDURE demo_transaction_resolution_creation(
    IN p_matter_id INT
)
BEGIN
    DECLARE v_yes_votes INT;
    DECLARE v_no_votes INT;
    DECLARE v_abstentions INT;
    DECLARE v_threshold DECIMAL(5,2);
    DECLARE v_yes_pct DECIMAL(5,2);
    DECLARE v_organ_id INT;
    DECLARE v_title VARCHAR(255);
    DECLARE v_res_num VARCHAR(30);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction failed and rolled back' AS result;
    END;
    
    START TRANSACTION;
    
    -- Lock matter for update
    SELECT voting_threshold, organ_id, title 
    INTO v_threshold, v_organ_id, v_title
    FROM matter 
    WHERE matter_id = p_matter_id
    FOR UPDATE;
    
    -- Calculate votes
    SELECT 
        SUM(CASE WHEN vote_value = 'YES' THEN 1 ELSE 0 END),
        SUM(CASE WHEN vote_value = 'NO' THEN 1 ELSE 0 END),
        SUM(CASE WHEN vote_value = 'ABSTAIN' THEN 1 ELSE 0 END)
    INTO v_yes_votes, v_no_votes, v_abstentions
    FROM vote
    WHERE matter_id = p_matter_id AND is_valid = TRUE;
    
    SET v_yes_pct = (v_yes_votes * 100.0) / NULLIF(v_yes_votes + v_no_votes, 0);
    
    IF v_yes_pct >= v_threshold THEN
        -- Generate resolution number
        SET v_res_num = CONCAT('A/RES/DEMO/', p_matter_id);
        
        -- Update matter status
        UPDATE matter SET status = 'PASSED', actual_completion_date = CURRENT_DATE
        WHERE matter_id = p_matter_id;
        
        -- Create resolution
        INSERT INTO resolution (
            resolution_number, matter_id, organ_id, title, 
            operative_text, adoption_date, yes_votes, no_votes, abstentions
        ) VALUES (
            v_res_num, p_matter_id, v_organ_id, v_title,
            'Operative text here', CURRENT_DATE, v_yes_votes, v_no_votes, v_abstentions
        );
        
        COMMIT;
        SELECT CONCAT('Resolution created: ', v_res_num) AS result;
    ELSE
        -- Update matter as rejected
        UPDATE matter SET status = 'REJECTED'
        WHERE matter_id = p_matter_id;
        
        COMMIT;
        SELECT CONCAT('Matter rejected. Yes: ', v_yes_pct, '% < Threshold: ', v_threshold, '%') AS result;
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- TRANSACTION 4: Multi-Level Approval with Savepoints
-- Demonstrates SAVEPOINT and partial ROLLBACK
-- ============================================================================
DELIMITER //
CREATE PROCEDURE demo_transaction_approval_with_savepoints(
    IN p_matter_id INT
)
BEGIN
    DECLARE v_level1_ok BOOLEAN DEFAULT TRUE;
    DECLARE v_level2_ok BOOLEAN DEFAULT TRUE;
    
    START TRANSACTION;
    
    -- Level 1 Approval
    SAVEPOINT level1_approval;
    
    UPDATE approval 
    SET approval_status = 'APPROVED', decision_date = CURRENT_TIMESTAMP
    WHERE matter_id = p_matter_id AND approval_level = 1;
    
    SELECT 'Level 1 approved' AS step;
    
    -- Level 2 Approval
    SAVEPOINT level2_approval;
    
    UPDATE approval 
    SET approval_status = 'APPROVED', decision_date = CURRENT_TIMESTAMP
    WHERE matter_id = p_matter_id AND approval_level = 2;
    
    SELECT 'Level 2 approved' AS step;
    
    -- Simulate a condition that requires partial rollback
    -- In real scenario, this would be based on business logic
    IF v_level2_ok = FALSE THEN
        ROLLBACK TO SAVEPOINT level2_approval;
        SELECT 'Level 2 rolled back to savepoint' AS step;
    END IF;
    
    IF v_level1_ok = FALSE THEN
        ROLLBACK TO SAVEPOINT level1_approval;
        SELECT 'Level 1 rolled back to savepoint' AS step;
    END IF;
    
    COMMIT;
    SELECT 'Transaction committed' AS result;
END//
DELIMITER ;

-- ============================================================================
-- TRANSACTION 5: ICJ Case Update with Hearing Scheduling
-- Demonstrates transaction across related tables
-- ============================================================================
DELIMITER //
CREATE PROCEDURE demo_transaction_icj_scheduling(
    IN p_case_id INT,
    IN p_hearing_date DATE,
    IN p_presiding_judge_id INT
)
BEGIN
    DECLARE v_hearing_num INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ICJ scheduling transaction failed' AS result;
    END;
    
    START TRANSACTION;
    
    -- Lock case record
    SELECT case_id FROM icj_case WHERE case_id = p_case_id FOR UPDATE;
    
    -- Get next hearing number
    SELECT COALESCE(MAX(hearing_number), 0) + 1 INTO v_hearing_num
    FROM icj_hearing WHERE case_id = p_case_id;
    
    -- Create hearing
    INSERT INTO icj_hearing (
        case_id, hearing_number, hearing_type, scheduled_date,
        presiding_judge_id, status
    ) VALUES (
        p_case_id, v_hearing_num, 'ORAL_ARGUMENTS', p_hearing_date,
        p_presiding_judge_id, 'SCHEDULED'
    );
    
    -- Update case status
    UPDATE icj_case SET status = 'HEARING'
    WHERE case_id = p_case_id AND status IN ('PENDING', 'PRELIMINARY_OBJECTIONS', 'MERITS');
    
    COMMIT;
    SELECT CONCAT('Hearing ', v_hearing_num, ' scheduled for ', p_hearing_date) AS result;
END//
DELIMITER ;

-- ============================================================================
-- SECTION 2: CONCURRENCY CONTROL DEMONSTRATIONS
-- ============================================================================

-- ============================================================================
-- SCENARIO 1: Concurrent Voting Prevention
-- Demonstrates SELECT ... FOR UPDATE to prevent race conditions
-- ============================================================================
/*
Scenario: Two delegates try to vote for the same state at the same time.
Without proper locking, both might succeed creating duplicate votes.

Session 1:
-----------
START TRANSACTION;
SELECT * FROM vote 
WHERE matter_id = 2 AND state_id = 2 
FOR UPDATE;  -- Acquires exclusive lock

-- At this point, Session 2 is blocked if trying same query with FOR UPDATE
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
VALUES (2, 2, 2, 'YES');

COMMIT;  -- Releases lock

Session 2:
-----------
START TRANSACTION;
SELECT * FROM vote 
WHERE matter_id = 2 AND state_id = 2 
FOR UPDATE;  -- WAITS until Session 1 commits

-- After Session 1 commits, this will find the vote exists
-- The INSERT would fail due to UNIQUE constraint
ROLLBACK;  -- Or handle the duplicate scenario
*/

-- Procedure to demonstrate concurrent voting with locking
DELIMITER //
CREATE PROCEDURE demo_concurrent_voting_safe(
    IN p_matter_id INT,
    IN p_state_id INT,
    IN p_delegate_id INT,
    IN p_vote_value VARCHAR(10)
)
BEGIN
    DECLARE v_lock_timeout INT DEFAULT 5;
    DECLARE v_existing INT;
    
    -- Set lock wait timeout
    SET SESSION innodb_lock_wait_timeout = v_lock_timeout;
    
    START TRANSACTION;
    
    -- Acquire lock on any existing vote for this matter+state
    SELECT COUNT(*) INTO v_existing
    FROM vote
    WHERE matter_id = p_matter_id AND state_id = p_state_id
    FOR UPDATE;
    
    IF v_existing > 0 THEN
        ROLLBACK;
        SELECT 'BLOCKED: Vote already exists for this state' AS result;
    ELSE
        -- Safe to insert - we have the lock
        INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
        VALUES (p_matter_id, p_state_id, p_delegate_id, p_vote_value);
        COMMIT;
        SELECT 'SUCCESS: Vote recorded' AS result;
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- SCENARIO 2: Concurrent Approval Prevention
-- Prevents two officers from approving the same matter simultaneously
-- ============================================================================
/*
Scenario: Two officers attempt to approve the same matter at approval level 2.

Without locking:
- Both read approval as PENDING
- Both update to APPROVED
- Inconsistent audit trail

With FOR UPDATE:
- First officer locks the row
- Second officer waits
- After first commits, second sees already APPROVED
*/

DELIMITER //
CREATE PROCEDURE demo_concurrent_approval_safe(
    IN p_matter_id INT,
    IN p_officer_id INT,
    IN p_approval_level INT,
    IN p_decision VARCHAR(20),
    IN p_comments TEXT
)
BEGIN
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_approval_id INT;
    
    START TRANSACTION;
    
    -- Lock the approval record
    SELECT approval_id, approval_status 
    INTO v_approval_id, v_current_status
    FROM approval
    WHERE matter_id = p_matter_id 
      AND approver_officer_id = p_officer_id 
      AND approval_level = p_approval_level
    FOR UPDATE;
    
    IF v_current_status IS NULL THEN
        ROLLBACK;
        SELECT 'ERROR: No pending approval found for this officer' AS result;
    ELSEIF v_current_status != 'PENDING' THEN
        ROLLBACK;
        SELECT CONCAT('ERROR: Approval already ', v_current_status) AS result;
    ELSE
        UPDATE approval
        SET approval_status = p_decision,
            decision_date = CURRENT_TIMESTAMP,
            comments = p_comments
        WHERE approval_id = v_approval_id;
        
        COMMIT;
        SELECT CONCAT('SUCCESS: Approval ', p_decision) AS result;
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- SCENARIO 3: Deadlock Prevention with Consistent Lock Ordering
-- ============================================================================
/*
Deadlock scenario (BAD):
Session 1: Locks matter A, then tries to lock matter B
Session 2: Locks matter B, then tries to lock matter A
Result: DEADLOCK

Prevention: Always lock resources in the same order (by ID)
*/

DELIMITER //
CREATE PROCEDURE demo_multi_matter_update_safe(
    IN p_matter_id_1 INT,
    IN p_matter_id_2 INT,
    IN p_new_priority VARCHAR(20)
)
BEGIN
    DECLARE v_first_id INT;
    DECLARE v_second_id INT;
    
    -- Always lock in ascending ID order to prevent deadlock
    IF p_matter_id_1 < p_matter_id_2 THEN
        SET v_first_id = p_matter_id_1;
        SET v_second_id = p_matter_id_2;
    ELSE
        SET v_first_id = p_matter_id_2;
        SET v_second_id = p_matter_id_1;
    END IF;
    
    START TRANSACTION;
    
    -- Lock first (lower ID)
    SELECT matter_id FROM matter WHERE matter_id = v_first_id FOR UPDATE;
    
    -- Lock second (higher ID)
    SELECT matter_id FROM matter WHERE matter_id = v_second_id FOR UPDATE;
    
    -- Now safe to update
    UPDATE matter SET priority = p_new_priority WHERE matter_id IN (v_first_id, v_second_id);
    
    COMMIT;
    SELECT 'Both matters updated safely' AS result;
END//
DELIMITER ;

-- ============================================================================
-- SECTION 3: RECOVERY DEMONSTRATION
-- ============================================================================

-- ============================================================================
-- Recovery Scenario: Failure After Savepoint, Rollback to Savepoint
-- ============================================================================
DELIMITER //
CREATE PROCEDURE demo_recovery_with_savepoint()
BEGIN
    DECLARE v_step INT DEFAULT 0;
    
    -- Simulate a multi-step workflow update
    START TRANSACTION;
    
    -- Step 1: Mark submission complete
    SAVEPOINT step1_complete;
    UPDATE matter_workflow SET stage_status = 'COMPLETED' 
    WHERE matter_id = 1 AND stage_number = 1;
    SET v_step = 1;
    SELECT CONCAT('Step ', v_step, ' completed') AS progress;
    
    -- Step 2: Start review
    SAVEPOINT step2_complete;
    UPDATE matter_workflow SET stage_status = 'IN_PROGRESS' 
    WHERE matter_id = 1 AND stage_number = 2;
    SET v_step = 2;
    SELECT CONCAT('Step ', v_step, ' completed') AS progress;
    
    -- Step 3: Simulate failure
    SAVEPOINT step3_start;
    -- Imagine an error occurs here...
    -- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Simulated failure';
    
    -- Recovery: Rollback to step 2
    ROLLBACK TO SAVEPOINT step2_complete;
    SELECT 'Rolled back to step 2 savepoint' AS recovery;
    
    -- Continue from known good state
    COMMIT;
    SELECT 'Transaction completed with partial recovery' AS result;
END//
DELIMITER ;

-- ============================================================================
-- TCL Summary Commands (for reference)
-- ============================================================================
/*
Transaction Control Language (TCL) Commands:

1. START TRANSACTION / BEGIN
   - Starts a new transaction

2. COMMIT
   - Saves all changes made during the transaction
   - Makes changes permanent and visible to other sessions

3. ROLLBACK
   - Undoes all changes made during the transaction
   - Returns database to state before transaction started

4. SAVEPOINT savepoint_name
   - Creates a named point within a transaction
   - Allows partial rollback to this point

5. ROLLBACK TO SAVEPOINT savepoint_name
   - Rolls back to the named savepoint
   - Changes after savepoint are undone
   - Transaction remains active

6. RELEASE SAVEPOINT savepoint_name
   - Removes a savepoint
   - Cannot rollback to it after release

7. SET TRANSACTION
   - Sets transaction characteristics
   - Examples: isolation level, read-only mode
*/

-- ============================================================================
-- END OF TRANSACTIONS AND CONCURRENCY DEMO
-- ============================================================================
