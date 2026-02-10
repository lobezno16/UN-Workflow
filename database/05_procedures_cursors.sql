-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 05_procedures_cursors.sql - Stored Procedures and Cursors
-- ============================================================================
USE un_workflow_db;

-- ============================================================================
-- PROCEDURE 1: sp_compute_vote_outcome
-- Uses cursor to iterate through votes and compute outcome
-- Returns yes/no/abstain totals and whether matter passes
-- ============================================================================
DELIMITER //
CREATE PROCEDURE sp_compute_vote_outcome(
    IN p_matter_id INT,
    OUT p_yes_count INT,
    OUT p_no_count INT,
    OUT p_abstain_count INT,
    OUT p_total_votes INT,
    OUT p_yes_percentage DECIMAL(5,2),
    OUT p_outcome VARCHAR(20)
)
BEGIN
    DECLARE v_vote_value VARCHAR(10);
    DECLARE v_threshold DECIMAL(5,2);
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor declaration
    DECLARE vote_cursor CURSOR FOR 
        SELECT vote_value 
        FROM vote 
        WHERE matter_id = p_matter_id AND is_valid = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Initialize counters
    SET p_yes_count = 0;
    SET p_no_count = 0;
    SET p_abstain_count = 0;
    SET p_total_votes = 0;
    
    -- Get voting threshold
    SELECT voting_threshold INTO v_threshold
    FROM matter WHERE matter_id = p_matter_id;
    
    -- Open cursor and iterate
    OPEN vote_cursor;
    
    vote_loop: LOOP
        FETCH vote_cursor INTO v_vote_value;
        IF done THEN
            LEAVE vote_loop;
        END IF;
        
        SET p_total_votes = p_total_votes + 1;
        
        CASE v_vote_value
            WHEN 'YES' THEN SET p_yes_count = p_yes_count + 1;
            WHEN 'NO' THEN SET p_no_count = p_no_count + 1;
            WHEN 'ABSTAIN' THEN SET p_abstain_count = p_abstain_count + 1;
        END CASE;
    END LOOP;
    
    CLOSE vote_cursor;
    
    -- Calculate percentage (abstentions don't count)
    IF (p_yes_count + p_no_count) > 0 THEN
        SET p_yes_percentage = (p_yes_count * 100.0) / (p_yes_count + p_no_count);
    ELSE
        SET p_yes_percentage = 0;
    END IF;
    
    -- Determine outcome
    IF p_yes_percentage >= v_threshold THEN
        SET p_outcome = 'PASSED';
    ELSE
        SET p_outcome = 'FAILED';
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- PROCEDURE 2: sp_advance_workflow
-- Advances a matter to the next workflow stage
-- ============================================================================
DELIMITER //
CREATE PROCEDURE sp_advance_workflow(
    IN p_matter_id INT,
    IN p_officer_id INT,
    OUT p_new_stage VARCHAR(50),
    OUT p_result_message VARCHAR(500)
)
BEGIN
    DECLARE v_current_stage INT;
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_next_stage INT;
    DECLARE v_next_stage_name VARCHAR(50);
    DECLARE v_matter_exists INT;
    
    -- Check if matter exists
    SELECT COUNT(*) INTO v_matter_exists FROM matter WHERE matter_id = p_matter_id;
    
    IF v_matter_exists = 0 THEN
        SET p_new_stage = NULL;
        SET p_result_message = 'ERROR: Matter not found';
    ELSE
        -- Get current active workflow stage
        SELECT MAX(stage_number), stage_status INTO v_current_stage, v_current_status
        FROM matter_workflow 
        WHERE matter_id = p_matter_id AND stage_status IN ('IN_PROGRESS', 'PENDING')
        GROUP BY stage_status
        ORDER BY stage_status = 'IN_PROGRESS' DESC
        LIMIT 1;
        
        IF v_current_stage IS NULL THEN
            SET p_new_stage = NULL;
            SET p_result_message = 'No active workflow stage found for this matter';
        ELSE
            -- Complete current stage
            UPDATE matter_workflow 
            SET stage_status = 'COMPLETED', 
                completed_at = CURRENT_TIMESTAMP
            WHERE matter_id = p_matter_id AND stage_number = v_current_stage;
            
            -- Activate next stage
            SET v_next_stage = v_current_stage + 1;
            
            SELECT stage_name INTO v_next_stage_name
            FROM matter_workflow
            WHERE matter_id = p_matter_id AND stage_number = v_next_stage;
            
            IF v_next_stage_name IS NOT NULL THEN
                UPDATE matter_workflow 
                SET stage_status = 'IN_PROGRESS', 
                    started_at = CURRENT_TIMESTAMP,
                    assigned_officer_id = p_officer_id
                WHERE matter_id = p_matter_id AND stage_number = v_next_stage;
                
                SET p_new_stage = v_next_stage_name;
                SET p_result_message = CONCAT('Workflow advanced to stage: ', v_next_stage_name);
            ELSE
                SET p_new_stage = 'COMPLETED';
                SET p_result_message = 'All workflow stages completed';
            END IF;
        END IF;
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- PROCEDURE 3: sp_create_resolution
-- Creates a resolution from a passed matter
-- ============================================================================
DELIMITER //
CREATE PROCEDURE sp_create_resolution(
    IN p_matter_id INT,
    IN p_preamble TEXT,
    IN p_operative_text TEXT,
    OUT p_resolution_number VARCHAR(30),
    OUT p_result_message VARCHAR(500)
)
BEGIN
    DECLARE v_yes_count INT;
    DECLARE v_no_count INT;
    DECLARE v_abstain_count INT;
    DECLARE v_total_votes INT;
    DECLARE v_yes_pct DECIMAL(5,2);
    DECLARE v_outcome VARCHAR(20);
    DECLARE v_organ_id INT;
    DECLARE v_organ_code VARCHAR(10);
    DECLARE v_matter_title VARCHAR(255);
    DECLARE v_matter_status VARCHAR(50);
    DECLARE v_next_res_num INT;
    DECLARE v_resolution_exists INT;
    
    -- Check if resolution already exists
    SELECT COUNT(*) INTO v_resolution_exists FROM resolution WHERE matter_id = p_matter_id;
    
    IF v_resolution_exists > 0 THEN
        SELECT resolution_number INTO p_resolution_number FROM resolution WHERE matter_id = p_matter_id;
        SET p_result_message = 'Resolution already exists for this matter';
    ELSE
        -- Get matter details
        SELECT m.organ_id, o.organ_code, m.title, m.status
        INTO v_organ_id, v_organ_code, v_matter_title, v_matter_status
        FROM matter m
        JOIN un_organ o ON m.organ_id = o.organ_id
        WHERE m.matter_id = p_matter_id;
        
        -- Compute vote outcome
        CALL sp_compute_vote_outcome(p_matter_id, v_yes_count, v_no_count, v_abstain_count, v_total_votes, v_yes_pct, v_outcome);
        
        IF v_outcome = 'PASSED' OR v_matter_status = 'PASSED' THEN
            -- Generate resolution number
            SELECT COALESCE(MAX(resolution_id), 0) + 1 INTO v_next_res_num FROM resolution;
            
            CASE v_organ_code
                WHEN 'GA' THEN SET p_resolution_number = CONCAT('A/RES/', YEAR(CURRENT_DATE), '/', v_next_res_num);
                WHEN 'SC' THEN SET p_resolution_number = CONCAT('S/RES/', 2700 + v_next_res_num);
                WHEN 'ECOSOC' THEN SET p_resolution_number = CONCAT('E/RES/', YEAR(CURRENT_DATE), '/', v_next_res_num);
                ELSE SET p_resolution_number = CONCAT('RES/', YEAR(CURRENT_DATE), '/', v_next_res_num);
            END CASE;
            
            -- Insert resolution
            INSERT INTO resolution (
                resolution_number, matter_id, organ_id, title, preamble, operative_text,
                adoption_date, yes_votes, no_votes, abstentions, 
                is_binding, status
            ) VALUES (
                p_resolution_number, p_matter_id, v_organ_id, v_matter_title, p_preamble, p_operative_text,
                CURRENT_DATE, v_yes_count, v_no_count, v_abstain_count,
                (v_organ_code = 'SC'), 'ADOPTED'
            );
            
            -- Update matter status
            UPDATE matter SET status = 'PASSED', actual_completion_date = CURRENT_DATE
            WHERE matter_id = p_matter_id;
            
            SET p_result_message = CONCAT('Resolution ', p_resolution_number, ' created successfully');
        ELSE
            SET p_resolution_number = NULL;
            SET p_result_message = CONCAT('Cannot create resolution: Vote outcome is ', v_outcome, ' (', v_yes_pct, '%)');
        END IF;
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- PROCEDURE 4: sp_generate_workload_report
-- Uses cursor to generate officer workload summary
-- ============================================================================
DELIMITER //
CREATE PROCEDURE sp_generate_workload_report()
BEGIN
    DECLARE v_officer_id INT;
    DECLARE v_officer_name VARCHAR(100);
    DECLARE v_active_count INT;
    DECLARE v_pending_count INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE officer_cursor CURSOR FOR 
        SELECT officer_id, CONCAT(first_name, ' ', last_name) 
        FROM officer 
        WHERE employment_status = 'ACTIVE';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Create temp table for results
    DROP TEMPORARY TABLE IF EXISTS temp_workload;
    CREATE TEMPORARY TABLE temp_workload (
        officer_id INT,
        officer_name VARCHAR(100),
        active_workflows INT,
        pending_approvals INT,
        workload_level VARCHAR(20)
    );
    
    OPEN officer_cursor;
    
    officer_loop: LOOP
        FETCH officer_cursor INTO v_officer_id, v_officer_name;
        IF done THEN
            LEAVE officer_loop;
        END IF;
        
        -- Count active workflows
        SELECT COUNT(*) INTO v_active_count
        FROM matter_workflow
        WHERE assigned_officer_id = v_officer_id AND stage_status = 'IN_PROGRESS';
        
        -- Count pending approvals
        SELECT COUNT(*) INTO v_pending_count
        FROM approval
        WHERE approver_officer_id = v_officer_id AND approval_status = 'PENDING';
        
        INSERT INTO temp_workload VALUES (
            v_officer_id,
            v_officer_name,
            v_active_count,
            v_pending_count,
            CASE 
                WHEN (v_active_count + v_pending_count) > 10 THEN 'OVERLOADED'
                WHEN (v_active_count + v_pending_count) > 5 THEN 'HIGH'
                WHEN (v_active_count + v_pending_count) > 2 THEN 'MEDIUM'
                ELSE 'LOW'
            END
        );
    END LOOP;
    
    CLOSE officer_cursor;
    
    -- Return results
    SELECT * FROM temp_workload ORDER BY (active_workflows + pending_approvals) DESC;
    
    DROP TEMPORARY TABLE temp_workload;
END//
DELIMITER ;

-- ============================================================================
-- PROCEDURE 5: sp_submit_matter
-- Submits a new matter and creates initial workflow stages
-- ============================================================================
DELIMITER //
CREATE PROCEDURE sp_submit_matter(
    IN p_title VARCHAR(255),
    IN p_description TEXT,
    IN p_matter_type VARCHAR(50),
    IN p_organ_code VARCHAR(10),
    IN p_submitted_by_delegate_id INT,
    IN p_priority VARCHAR(20),
    OUT p_matter_number VARCHAR(30),
    OUT p_matter_id INT,
    OUT p_result_message VARCHAR(500)
)
BEGIN
    DECLARE v_organ_id INT;
    DECLARE v_next_seq INT;
    DECLARE v_requires_voting BOOLEAN DEFAULT FALSE;
    
    -- Get organ ID
    SELECT organ_id INTO v_organ_id FROM un_organ WHERE organ_code = p_organ_code;
    
    IF v_organ_id IS NULL THEN
        SET p_result_message = 'ERROR: Invalid organ code';
        SET p_matter_id = NULL;
        SET p_matter_number = NULL;
    ELSE
        -- Generate matter number
        SELECT COALESCE(MAX(matter_id), 0) + 1 INTO v_next_seq FROM matter;
        
        CASE p_organ_code
            WHEN 'GA' THEN 
                SET p_matter_number = CONCAT('GA/PROP/', YEAR(CURRENT_DATE), '/', LPAD(v_next_seq, 3, '0'));
                SET v_requires_voting = TRUE;
            WHEN 'SC' THEN 
                SET p_matter_number = CONCAT('SC/PROP/', YEAR(CURRENT_DATE), '/', LPAD(v_next_seq, 3, '0'));
                SET v_requires_voting = TRUE;
            WHEN 'ECOSOC' THEN 
                SET p_matter_number = CONCAT('E/PROP/', YEAR(CURRENT_DATE), '/', LPAD(v_next_seq, 3, '0'));
                SET v_requires_voting = TRUE;
            WHEN 'ICJ' THEN 
                SET p_matter_number = CONCAT('ICJ/CASE/', YEAR(CURRENT_DATE), '/', LPAD(v_next_seq, 3, '0'));
            WHEN 'SECRETARIAT' THEN 
                SET p_matter_number = CONCAT('ST/', YEAR(CURRENT_DATE), '/', LPAD(v_next_seq, 3, '0'));
            WHEN 'TC' THEN 
                SET p_matter_number = CONCAT('TC/REP/', YEAR(CURRENT_DATE), '/', LPAD(v_next_seq, 3, '0'));
        END CASE;
        
        -- Insert matter
        INSERT INTO matter (
            matter_number, title, description, matter_type, organ_id,
            submitted_by_delegate_id, priority, status, submission_date,
            requires_voting
        ) VALUES (
            p_matter_number, p_title, p_description, p_matter_type, v_organ_id,
            p_submitted_by_delegate_id, p_priority, 'SUBMITTED', CURRENT_DATE,
            v_requires_voting
        );
        
        SET p_matter_id = LAST_INSERT_ID();
        
        -- Create workflow stages based on organ type
        IF p_organ_code IN ('GA', 'SC', 'ECOSOC') THEN
            INSERT INTO matter_workflow (matter_id, stage_number, stage_name) VALUES
            (p_matter_id, 1, 'SUBMISSION'),
            (p_matter_id, 2, 'INITIAL_REVIEW'),
            (p_matter_id, 3, 'COMMITTEE_REVIEW'),
            (p_matter_id, 4, 'APPROVAL'),
            (p_matter_id, 5, 'VOTING'),
            (p_matter_id, 6, 'RESOLUTION_ISSUANCE');
        ELSEIF p_organ_code = 'ICJ' THEN
            INSERT INTO matter_workflow (matter_id, stage_number, stage_name) VALUES
            (p_matter_id, 1, 'FILING'),
            (p_matter_id, 2, 'PRELIMINARY_EXAMINATION'),
            (p_matter_id, 3, 'HEARING_SCHEDULING'),
            (p_matter_id, 4, 'HEARINGS'),
            (p_matter_id, 5, 'DELIBERATION'),
            (p_matter_id, 6, 'JUDGMENT');
        ELSEIF p_organ_code = 'SECRETARIAT' THEN
            INSERT INTO matter_workflow (matter_id, stage_number, stage_name) VALUES
            (p_matter_id, 1, 'DRAFTING'),
            (p_matter_id, 2, 'LEGAL_REVIEW'),
            (p_matter_id, 3, 'APPROVAL'),
            (p_matter_id, 4, 'ISSUANCE');
        ELSE -- TC
            INSERT INTO matter_workflow (matter_id, stage_number, stage_name) VALUES
            (p_matter_id, 1, 'SUBMISSION'),
            (p_matter_id, 2, 'REVIEW'),
            (p_matter_id, 3, 'DECISION');
        END IF;
        
        -- Start first workflow stage
        UPDATE matter_workflow 
        SET stage_status = 'IN_PROGRESS', started_at = CURRENT_TIMESTAMP
        WHERE matter_id = p_matter_id AND stage_number = 1;
        
        SET p_result_message = CONCAT('Matter ', p_matter_number, ' submitted successfully');
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- FUNCTION 1: fn_get_matter_status_label
-- Returns human-readable status label
-- ============================================================================
DELIMITER //
CREATE FUNCTION fn_get_matter_status_label(p_status VARCHAR(50))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    RETURN CASE p_status
        WHEN 'DRAFT' THEN 'Draft - Not Submitted'
        WHEN 'SUBMITTED' THEN 'Submitted - Awaiting Review'
        WHEN 'UNDER_REVIEW' THEN 'Under Review'
        WHEN 'PENDING_APPROVAL' THEN 'Pending Approval'
        WHEN 'APPROVED' THEN 'Approved - Awaiting Vote'
        WHEN 'IN_VOTING' THEN 'Voting in Progress'
        WHEN 'VOTED' THEN 'Voting Completed'
        WHEN 'PASSED' THEN 'Passed - Resolution Issued'
        WHEN 'REJECTED' THEN 'Rejected'
        WHEN 'CLOSED' THEN 'Closed'
        WHEN 'ARCHIVED' THEN 'Archived'
        ELSE p_status
    END;
END//
DELIMITER ;

-- ============================================================================
-- FUNCTION 2: fn_calculate_vote_percentage
-- Calculates YES vote percentage for a matter
-- ============================================================================
DELIMITER //
CREATE FUNCTION fn_calculate_vote_percentage(p_matter_id INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_yes INT DEFAULT 0;
    DECLARE v_no INT DEFAULT 0;
    DECLARE v_pct DECIMAL(5,2);
    
    SELECT 
        SUM(CASE WHEN vote_value = 'YES' THEN 1 ELSE 0 END),
        SUM(CASE WHEN vote_value = 'NO' THEN 1 ELSE 0 END)
    INTO v_yes, v_no
    FROM vote
    WHERE matter_id = p_matter_id AND is_valid = TRUE;
    
    IF (v_yes + v_no) > 0 THEN
        SET v_pct = (v_yes * 100.0) / (v_yes + v_no);
    ELSE
        SET v_pct = 0.00;
    END IF;
    
    RETURN v_pct;
END//
DELIMITER ;

-- ============================================================================
-- END OF PROCEDURES AND CURSORS
-- ============================================================================
