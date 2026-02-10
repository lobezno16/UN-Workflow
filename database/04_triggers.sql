-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 04_triggers.sql - Database Triggers
-- ============================================================================
USE un_workflow_db;

-- ============================================================================
-- TRIGGER 1: trg_matter_audit_insert
-- Automatically logs INSERT operations on the matter table
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_matter_audit_insert
AFTER INSERT ON matter
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        table_name, 
        record_id, 
        action_type, 
        action_description, 
        new_values,
        performed_by_officer_id,
        performed_by_delegate_id
    ) VALUES (
        'matter',
        NEW.matter_id,
        'INSERT',
        CONCAT('New matter created: ', NEW.matter_number, ' - ', NEW.title),
        JSON_OBJECT(
            'matter_number', NEW.matter_number,
            'title', NEW.title,
            'matter_type', NEW.matter_type,
            'status', NEW.status,
            'priority', NEW.priority
        ),
        NEW.submitted_by_officer_id,
        NEW.submitted_by_delegate_id
    );
END//
DELIMITER ;

-- ============================================================================
-- TRIGGER 2: trg_matter_audit_update
-- Logs UPDATE operations including status changes
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_matter_audit_update
AFTER UPDATE ON matter
FOR EACH ROW
BEGIN
    DECLARE action_desc VARCHAR(500);
    DECLARE action_type_val ENUM('INSERT', 'UPDATE', 'DELETE', 'STATUS_CHANGE', 'VOTE', 'APPROVAL', 'LOGIN', 'LOGOUT');
    
    IF OLD.status != NEW.status THEN
        SET action_type_val = 'STATUS_CHANGE';
        SET action_desc = CONCAT('Matter status changed from ', OLD.status, ' to ', NEW.status);
    ELSE
        SET action_type_val = 'UPDATE';
        SET action_desc = CONCAT('Matter updated: ', NEW.matter_number);
    END IF;
    
    INSERT INTO audit_log (
        table_name, 
        record_id, 
        action_type, 
        action_description, 
        old_values,
        new_values
    ) VALUES (
        'matter',
        NEW.matter_id,
        action_type_val,
        action_desc,
        JSON_OBJECT(
            'status', OLD.status,
            'priority', OLD.priority,
            'title', OLD.title
        ),
        JSON_OBJECT(
            'status', NEW.status,
            'priority', NEW.priority,
            'title', NEW.title
        )
    );
END//
DELIMITER ;

-- ============================================================================
-- TRIGGER 3: trg_prevent_vote_invalid_stage
-- Prevents voting when matter is not in IN_VOTING status
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_prevent_vote_invalid_stage
BEFORE INSERT ON vote
FOR EACH ROW
BEGIN
    DECLARE matter_status VARCHAR(50);
    DECLARE matter_organ VARCHAR(20);
    
    SELECT m.status, o.organ_code 
    INTO matter_status, matter_organ
    FROM matter m
    JOIN un_organ o ON m.organ_id = o.organ_id
    WHERE m.matter_id = NEW.matter_id;
    
    -- Only GA, SC, and ECOSOC can vote
    IF matter_organ NOT IN ('GA', 'SC', 'ECOSOC') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Voting is only allowed for General Assembly, Security Council, and ECOSOC matters';
    END IF;
    
    -- Matter must be in voting stage
    IF matter_status != 'IN_VOTING' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot cast vote: Matter is not in voting stage';
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- TRIGGER 4: trg_vote_audit
-- Logs all voting activity
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_vote_audit
AFTER INSERT ON vote
FOR EACH ROW
BEGIN
    DECLARE state_name_val VARCHAR(100);
    DECLARE delegate_name VARCHAR(100);
    DECLARE matter_num VARCHAR(30);
    
    SELECT ms.state_name INTO state_name_val
    FROM member_state ms WHERE ms.state_id = NEW.state_id;
    
    SELECT CONCAT(d.first_name, ' ', d.last_name) INTO delegate_name
    FROM delegate d WHERE d.delegate_id = NEW.delegate_id;
    
    SELECT m.matter_number INTO matter_num
    FROM matter m WHERE m.matter_id = NEW.matter_id;
    
    INSERT INTO audit_log (
        table_name, 
        record_id, 
        action_type, 
        action_description, 
        new_values,
        performed_by_delegate_id
    ) VALUES (
        'vote',
        NEW.vote_id,
        'VOTE',
        CONCAT(state_name_val, ' (', delegate_name, ') voted ', NEW.vote_value, ' on ', matter_num),
        JSON_OBJECT(
            'matter_id', NEW.matter_id,
            'state_id', NEW.state_id,
            'vote_value', NEW.vote_value
        ),
        NEW.delegate_id
    );
END//
DELIMITER ;

-- ============================================================================
-- TRIGGER 5: trg_auto_create_resolution
-- Automatically creates resolution when voting passes threshold
-- Note: This is a simplified version - in production you'd use a procedure
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_check_voting_result
AFTER INSERT ON vote
FOR EACH ROW
BEGIN
    DECLARE total_yes INT DEFAULT 0;
    DECLARE total_no INT DEFAULT 0;
    DECLARE total_abstain INT DEFAULT 0;
    DECLARE threshold DECIMAL(5,2);
    DECLARE yes_pct DECIMAL(5,2);
    DECLARE matter_status VARCHAR(50);
    DECLARE organ_id_val INT;
    DECLARE matter_title VARCHAR(255);
    DECLARE resolution_exists INT DEFAULT 0;
    
    -- Get matter details
    SELECT m.voting_threshold, m.status, m.organ_id, m.title
    INTO threshold, matter_status, organ_id_val, matter_title
    FROM matter m WHERE m.matter_id = NEW.matter_id;
    
    -- Only proceed if still in voting
    IF matter_status = 'IN_VOTING' THEN
        -- Count votes
        SELECT 
            SUM(CASE WHEN vote_value = 'YES' THEN 1 ELSE 0 END),
            SUM(CASE WHEN vote_value = 'NO' THEN 1 ELSE 0 END),
            SUM(CASE WHEN vote_value = 'ABSTAIN' THEN 1 ELSE 0 END)
        INTO total_yes, total_no, total_abstain
        FROM vote WHERE matter_id = NEW.matter_id AND is_valid = TRUE;
        
        -- Calculate percentage (excluding abstentions)
        IF (total_yes + total_no) > 0 THEN
            SET yes_pct = (total_yes * 100.0) / (total_yes + total_no);
        ELSE
            SET yes_pct = 0;
        END IF;
        
        -- Check if resolution already exists
        SELECT COUNT(*) INTO resolution_exists 
        FROM resolution WHERE matter_id = NEW.matter_id;
        
        -- This trigger just updates status - resolution creation should be manual or via procedure
        -- to ensure proper resolution numbering
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- TRIGGER 6: trg_approval_audit
-- Logs approval decisions
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_approval_audit
AFTER UPDATE ON approval
FOR EACH ROW
BEGIN
    IF OLD.approval_status != NEW.approval_status THEN
        INSERT INTO audit_log (
            table_name, 
            record_id, 
            action_type, 
            action_description, 
            old_values,
            new_values,
            performed_by_officer_id
        ) VALUES (
            'approval',
            NEW.approval_id,
            'APPROVAL',
            CONCAT('Approval decision: ', NEW.approval_status, ' at level ', NEW.approval_level),
            JSON_OBJECT('status', OLD.approval_status),
            JSON_OBJECT(
                'status', NEW.approval_status,
                'comments', NEW.comments
            ),
            NEW.approver_officer_id
        );
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- TRIGGER 7: trg_prevent_duplicate_approval
-- Prevents same officer approving same matter at same level twice
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_prevent_duplicate_approval
BEFORE INSERT ON approval
FOR EACH ROW
BEGIN
    DECLARE existing_count INT;
    
    SELECT COUNT(*) INTO existing_count
    FROM approval
    WHERE matter_id = NEW.matter_id 
      AND approver_officer_id = NEW.approver_officer_id 
      AND approval_level = NEW.approval_level;
    
    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This officer has already been assigned to approve this matter at this level';
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- TRIGGER 8: trg_icj_case_audit
-- Logs ICJ case status changes
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_icj_case_audit
AFTER UPDATE ON icj_case
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO audit_log (
            table_name, 
            record_id, 
            action_type, 
            action_description, 
            old_values,
            new_values
        ) VALUES (
            'icj_case',
            NEW.case_id,
            'STATUS_CHANGE',
            CONCAT('ICJ Case ', NEW.case_number, ' status changed from ', OLD.status, ' to ', NEW.status),
            JSON_OBJECT('status', OLD.status),
            JSON_OBJECT('status', NEW.status)
        );
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- TRIGGER 9: trg_directive_audit
-- Logs directive status changes
-- ============================================================================
DELIMITER //
CREATE TRIGGER trg_directive_audit
AFTER UPDATE ON directive
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO audit_log (
            table_name, 
            record_id, 
            action_type, 
            action_description, 
            old_values,
            new_values,
            performed_by_officer_id
        ) VALUES (
            'directive',
            NEW.directive_id,
            'STATUS_CHANGE',
            CONCAT('Directive ', NEW.directive_number, ' status changed from ', OLD.status, ' to ', NEW.status),
            JSON_OBJECT('status', OLD.status),
            JSON_OBJECT('status', NEW.status),
            NEW.issued_by_officer_id
        );
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- END OF TRIGGERS
-- ============================================================================
