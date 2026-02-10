# CHAPTER 3
## COMPLEX QUERIES BASED ON CONSTRAINTS, SETS, JOINS, VIEWS, TRIGGERS AND CURSORS

### 3.1 Adding Constraints and Queries Based on Constraints

**Q1: Add a CHECK constraint to ensure voting threshold is between 0 and 100**
```sql
ALTER TABLE matter ADD CONSTRAINT chk_voting_threshold 
CHECK (voting_threshold >= 0 AND voting_threshold <= 100);
```
**Output**: Query OK, 0 rows affected

**Q2: Add a UNIQUE constraint to prevent duplicate resolution numbers**
```sql
ALTER TABLE resolution ADD CONSTRAINT unique_resolution_number 
UNIQUE (resolution_number);
```

**Q3: Query matters that have proper voting threshold using constraint**
```sql
SELECT matter_number, title, voting_threshold
FROM matter
WHERE voting_threshold BETWEEN 50 AND 67
ORDER BY voting_threshold DESC;
```
| matter_number | title | voting_threshold |
|---------------|-------|------------------|
| GA/PROP/2024/001 | Climate Action Resolution | 67 |
| SC/PROP/2024/002 | Peacekeeping Mission | 50 |

**Relational Algebra**: σ(voting_threshold≥50 ∧ voting_threshold≤67)(matter)

### 3.2 Queries Based on Aggregate Functions

**Q1: Count total matters by organ with average approval time**
```sql
SELECT o.organ_code, o.organ_name,
       COUNT(m.matter_id) AS total_matters,
       AVG(DATEDIFF(m.actual_completion_date, m.submission_date)) AS avg_days
FROM un_organ o
LEFT JOIN matter m ON o.organ_id = m.organ_id
GROUP BY o.organ_id;
```
| organ_code | organ_name | total_matters | avg_days |
|------------|------------|---------------|----------|
| GA | General Assembly | 15 | 45.2 |
| SC | Security Council | 8 | 12.5 |

**Q2: Calculate vote distribution for each matter**
```sql
SELECT m.matter_number, m.title,
       SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_votes,
       SUM(CASE WHEN v.vote_value = 'NO' THEN 1 ELSE 0 END) AS no_votes,
       SUM(CASE WHEN v.vote_value = 'ABSTAIN' THEN 1 ELSE 0 END) AS abstentions,
       COUNT(*) AS total_votes
FROM matter m
LEFT JOIN vote v ON m.matter_id = v.matter_id
WHERE m.requires_voting = TRUE
GROUP BY m.matter_id;
```

**Q3: Find officers with maximum workload (pending approvals)**
```sql
SELECT o.officer_id, CONCAT(o.first_name, ' ', o.last_name) AS officer_name,
       COUNT(a.approval_id) AS pending_count
FROM officer o
LEFT JOIN approval a ON o.officer_id = a.approver_officer_id AND a.approval_status = 'PENDING'
GROUP BY o.officer_id
HAVING pending_count > 0
ORDER BY pending_count DESC
LIMIT 5;
```

**Relational Algebra**: π(officer_id, COUNT(approval_id))(γ(officer_id; COUNT(approval_id))(officer ⨝ approval))

### 3.3 Complex Queries Based on Sets

**Q1: Find states that voted YES in GA but NO in SC (using EXCEPT)**
```sql
SELECT DISTINCT ms.state_name
FROM member_state ms
JOIN vote v ON ms.state_id = v.state_id
JOIN matter m ON v.matter_id = m.matter_id
JOIN un_organ o ON m.organ_id = o.organ_id
WHERE o.organ_code = 'GA' AND v.vote_value = 'YES'
AND ms.state_id NOT IN (
    SELECT v2.state_id FROM vote v2
    JOIN matter m2 ON v2.matter_id = m2.matter_id
    JOIN un_organ o2 ON m2.organ_id = o2.organ_id
    WHERE o2.organ_code = 'SC' AND v2.vote_value = 'YES'
);
```

**Q2: Find all states with delegates in both GA and SC (INTERSECT)**
```sql
SELECT state_name FROM member_state
WHERE state_id IN (SELECT state_id FROM delegate WHERE organ_id = 1)
AND state_id IN (SELECT state_id FROM delegate WHERE organ_id = 2);
```

**Q3: Combine all ICJ cases and trusteeship reports (UNION)**
```sql
SELECT case_number AS reference, case_title AS title, 'ICJ' AS type FROM icj_case
UNION
SELECT report_number, CONCAT('Territory: ', t.territory_name), 'TC' 
FROM trusteeship_report tr
JOIN trusteeship_territory t ON tr.territory_id = t.territory_id;
```

**Relational Algebra**: π(state_name)(delegate ⨝(organ_id=1) member_state) ∩ π(state_name)(delegate ⨝(organ_id=2) member_state)

### 3.4 Complex Queries Based on Subqueries

**Q1: Find matters with votes exceeding average vote count**
```sql
SELECT matter_number, title, (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) AS vote_count
FROM matter m
WHERE (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) > 
      (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM vote GROUP BY matter_id) AS avg_votes);
```

**Q2: Find delegates who haven't voted on any pending matter**
```sql
SELECT d.delegate_id, CONCAT(d.first_name, ' ', d.last_name) AS delegate_name
FROM delegate d
WHERE d.delegate_id NOT IN (
    SELECT v.delegate_id FROM vote v
    JOIN matter m ON v.matter_id = m.matter_id
    WHERE m.status = 'IN_VOTING'
);
```

**Q3: Get resolutions where yes_votes exceed twice the no_votes**
```sql
SELECT resolution_number, title, yes_votes, no_votes
FROM resolution
WHERE yes_votes > (SELECT 2 * no_votes FROM resolution r2 WHERE r2.resolution_id = resolution.resolution_id);
```

**Relational Algebra**: σ(yes_votes > 2×no_votes)(resolution)

### 3.5 Complex Queries Based on Joins

**Q1: Join all tables to get complete matter details with votes (INNER JOIN)**
```sql
SELECT m.matter_number, m.title, o.organ_name,
       CONCAT(d.first_name, ' ', d.last_name) AS submitter,
       ms.state_name, v.vote_value
FROM matter m
INNER JOIN un_organ o ON m.organ_id = o.organ_id
INNER JOIN delegate d ON m.submitted_by_delegate_id = d.delegate_id
INNER JOIN member_state ms ON d.state_id = ms.state_id
LEFT JOIN vote v ON m.matter_id = v.matter_id;
```

**Q2: Find organs with and without matters (LEFT OUTER JOIN)**
```sql
SELECT o.organ_code, o.organ_name, COUNT(m.matter_id) AS matter_count
FROM un_organ o
LEFT OUTER JOIN matter m ON o.organ_id = m.organ_id
GROUP BY o.organ_id;
```

**Q3: Self-join to find departments with parent departments**
```sql
SELECT d1.department_name AS department, d2.department_name AS parent
FROM department d1
LEFT JOIN department d2 ON d1.parent_department_id = d2.department_id;
```

**Relational Algebra**: un_organ ⟕(organ_id) matter

### 3.6 Complex Queries Based on Views

**Q1: Create view for vote summary by matter**
```sql
CREATE VIEW vw_vote_summary AS
SELECT m.matter_id, m.matter_number, m.title, o.organ_code,
       SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_votes,
       SUM(CASE WHEN v.vote_value = 'NO' THEN 1 ELSE 0 END) AS no_votes,
       SUM(CASE WHEN v.vote_value = 'ABSTAIN' THEN 1 ELSE 0 END) AS abstentions
FROM matter m
JOIN un_organ o ON m.organ_id = o.organ_id
LEFT JOIN vote v ON m.matter_id = v.matter_id
GROUP BY m.matter_id;

-- Query the view
SELECT * FROM vw_vote_summary WHERE organ_code = 'GA';
```

**Q2: Create view for officer workload**
```sql
CREATE VIEW vw_officer_workload AS
SELECT o.officer_id, CONCAT(o.first_name, ' ', o.last_name) AS officer_name,
       r.role_name, COUNT(a.approval_id) AS pending_approvals
FROM officer o
JOIN role r ON o.role_id = r.role_id
LEFT JOIN approval a ON o.officer_id = a.approver_officer_id AND a.approval_status = 'PENDING'
GROUP BY o.officer_id;

SELECT * FROM vw_officer_workload ORDER BY pending_approvals DESC;
```

**Q3: Create view for ICJ case status**
```sql
CREATE VIEW vw_icj_case_status AS
SELECT c.case_number, c.case_title, c.status,
       app.state_name AS applicant, resp.state_name AS respondent,
       COUNT(h.hearing_id) AS hearings, COUNT(j.judgment_id) AS judgments
FROM icj_case c
LEFT JOIN member_state app ON c.applicant_state_id = app.state_id
LEFT JOIN member_state resp ON c.respondent_state_id = resp.state_id
LEFT JOIN icj_hearing h ON c.case_id = h.case_id
LEFT JOIN icj_judgment j ON c.case_id = j.case_id
GROUP BY c.case_id;
```

### 3.7 Complex Queries Based on Triggers

**Q1: Trigger to log matter status changes**
```sql
DELIMITER //
CREATE TRIGGER trg_matter_status_audit
AFTER UPDATE ON matter
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_log (table_name, record_id, action_type, action_description, old_value, new_value)
        VALUES ('matter', NEW.matter_id, 'UPDATE', 
                CONCAT('Status changed for matter ', NEW.matter_number),
                OLD.status, NEW.status);
    END IF;
END//
DELIMITER ;

-- Test trigger
UPDATE matter SET status = 'IN_VOTING' WHERE matter_id = 1;
SELECT * FROM audit_log WHERE table_name = 'matter' ORDER BY log_id DESC LIMIT 1;
```

**Q2: Trigger to prevent voting when matter not in voting stage**
```sql
DELIMITER //
CREATE TRIGGER trg_validate_vote
BEFORE INSERT ON vote
FOR EACH ROW
BEGIN
    DECLARE matter_status VARCHAR(20);
    SELECT status INTO matter_status FROM matter WHERE matter_id = NEW.matter_id;
    IF matter_status <> 'IN_VOTING' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot vote: Matter is not in voting stage';
    END IF;
END//
DELIMITER ;
```

**Q3: Trigger to auto-create resolution when voting passes**
```sql
DELIMITER //
CREATE TRIGGER trg_create_resolution
AFTER UPDATE ON matter
FOR EACH ROW
BEGIN
    DECLARE yes_count INT;
    DECLARE total_votes INT;
    IF NEW.status = 'PASSED' AND OLD.status = 'IN_VOTING' THEN
        SELECT COUNT(*) INTO yes_count FROM vote WHERE matter_id = NEW.matter_id AND vote_value = 'YES';
        SELECT COUNT(*) INTO total_votes FROM vote WHERE matter_id = NEW.matter_id;
        INSERT INTO resolution (resolution_number, matter_id, organ_id, title, adoption_date, yes_votes, no_votes)
        VALUES (CONCAT('RES/', NEW.matter_number), NEW.matter_id, NEW.organ_id, NEW.title, CURDATE(), yes_count, total_votes - yes_count);
    END IF;
END//
DELIMITER ;
```

### 3.8 Complex Queries Based on Cursors

**Q1: Cursor to compute vote outcomes for all pending matters**
```sql
DELIMITER //
CREATE PROCEDURE sp_compute_all_votes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE m_id INT;
    DECLARE m_threshold INT;
    DECLARE yes_count, no_count, total INT;
    
    DECLARE matter_cursor CURSOR FOR 
        SELECT matter_id, voting_threshold FROM matter WHERE status = 'IN_VOTING';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN matter_cursor;
    read_loop: LOOP
        FETCH matter_cursor INTO m_id, m_threshold;
        IF done THEN LEAVE read_loop; END IF;
        
        SELECT COUNT(*) INTO yes_count FROM vote WHERE matter_id = m_id AND vote_value = 'YES';
        SELECT COUNT(*) INTO total FROM vote WHERE matter_id = m_id WHERE vote_value IN ('YES', 'NO');
        
        IF total > 0 AND (yes_count * 100 / total) >= m_threshold THEN
            UPDATE matter SET status = 'PASSED' WHERE matter_id = m_id;
        END IF;
    END LOOP;
    CLOSE matter_cursor;
END//
DELIMITER ;

CALL sp_compute_all_votes();
```

**Q2: Cursor to generate workload report for officers**
```sql
DELIMITER //
CREATE PROCEDURE sp_workload_report()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE o_id INT;
    DECLARE o_name VARCHAR(100);
    DECLARE approval_count INT;
    
    DECLARE officer_cursor CURSOR FOR 
        SELECT officer_id, CONCAT(first_name, ' ', last_name) FROM officer WHERE employment_status = 'ACTIVE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_workload (officer_name VARCHAR(100), pending_approvals INT);
    
    OPEN officer_cursor;
    read_loop: LOOP
        FETCH officer_cursor INTO o_id, o_name;
        IF done THEN LEAVE read_loop; END IF;
        
        SELECT COUNT(*) INTO approval_count FROM approval WHERE approver_officer_id = o_id AND approval_status = 'PENDING';
        INSERT INTO temp_workload VALUES (o_name, approval_count);
    END LOOP;
    CLOSE officer_cursor;
    
    SELECT * FROM temp_workload ORDER BY pending_approvals DESC;
    DROP TEMPORARY TABLE temp_workload;
END//
DELIMITER ;

CALL sp_workload_report();
```

**Q3: Cursor to compute vote totals and return yes/no/abstain counts**
```sql
DELIMITER //
CREATE PROCEDURE sp_vote_tally(IN p_matter_id INT, OUT p_yes INT, OUT p_no INT, OUT p_abstain INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_value VARCHAR(10);
    
    DECLARE vote_cursor CURSOR FOR 
        SELECT vote_value FROM vote WHERE matter_id = p_matter_id AND is_valid = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    SET p_yes = 0; SET p_no = 0; SET p_abstain = 0;
    
    OPEN vote_cursor;
    tally_loop: LOOP
        FETCH vote_cursor INTO v_value;
        IF done THEN LEAVE tally_loop; END IF;
        
        CASE v_value
            WHEN 'YES' THEN SET p_yes = p_yes + 1;
            WHEN 'NO' THEN SET p_no = p_no + 1;
            WHEN 'ABSTAIN' THEN SET p_abstain = p_abstain + 1;
        END CASE;
    END LOOP;
    CLOSE vote_cursor;
END//
DELIMITER ;

-- Test the procedure
CALL sp_vote_tally(1, @yes, @no, @abstain);
SELECT @yes AS yes_votes, @no AS no_votes, @abstain AS abstentions;
```

---

# CHAPTER 4
## ANALYSING THE PITFALLS, IDENTIFYING THE DEPENDENCIES, AND APPLYING NORMALIZATIONS

### 4.1 Analyse Pitfalls in Relations

**Initial Denormalized Table: UN_Matter_Master**

Consider a hypothetical denormalized table combining matter, organ, delegate, state, and vote information:

```
UN_Matter_Master (
    matter_id, matter_number, title, description, status,
    organ_id, organ_code, organ_name, organ_headquarters,
    delegate_id, delegate_first_name, delegate_last_name,
    state_id, state_code, state_name, state_region,
    vote_id, vote_value, vote_timestamp,
    approval_officer_id, approval_officer_name, approval_status
)
```

**Anomalies in this table:**
- **Insertion Anomaly**: Cannot add a new organ without a matter
- **Update Anomaly**: Changing organ headquarters requires updating all related rows
- **Deletion Anomaly**: Deleting the last matter of an organ loses organ information

### 4.2 First Normal Form (1NF)

**Requirement**: Eliminate repeating groups, ensure atomic values

**Before 1NF**: UN_Matter_Master with multi-valued vote_values
```
matter_id | organ_code | votes
1         | GA         | YES, YES, NO, ABSTAIN
```

**After 1NF**: Each vote is a separate row
```
matter_id | organ_code | vote_value
1         | GA         | YES
1         | GA         | YES
1         | GA         | NO
1         | GA         | ABSTAIN
```

**Functional Dependencies Identified**:
- matter_id → {title, description, status, organ_id}
- organ_id → {organ_code, organ_name, headquarters}
- state_id → {state_code, state_name, region}

### 4.3 Second Normal Form (2NF)

**Requirement**: 1NF + No partial dependencies (all non-key attributes depend on entire primary key)

**Partial Dependency Identified**:
In UN_Matter_Master with composite key (matter_id, vote_id):
- organ_name depends only on matter_id (partial dependency)

**Decomposition to 2NF**:

Table: matter
```
matter_id (PK) | title | description | status | organ_id (FK)
```

Table: vote
```
vote_id (PK) | matter_id (FK) | state_id (FK) | vote_value | vote_timestamp
```

Table: un_organ
```
organ_id (PK) | organ_code | organ_name | headquarters
```

### 4.4 Third Normal Form (3NF)

**Requirement**: 2NF + No transitive dependencies

**Transitive Dependency Identified**:
matter_id → organ_id → organ_name
(organ_name transitively depends on matter_id through organ_id)

**Already in 3NF after 2NF decomposition** since organ information is in separate table.

**Additional Transitive Dependency in Delegate Table**:
delegate_id → state_id → state_name

**Decomposition to 3NF**:

Table: delegate (after)
```
delegate_id (PK) | first_name | last_name | state_id (FK) | organ_id (FK)
```

Table: member_state
```
state_id (PK) | state_code | state_name | capital_city | region
```

### 4.5 Boyce-Codd Normal Form (BCNF)

**Requirement**: 3NF + Every determinant is a candidate key

**Checking icj_case_judge table**:
```
case_id (PK) | judge_id (PK) | is_ad_hoc | assigned_date
```

Candidate key: (case_id, judge_id)
Determinants: (case_id, judge_id) → {is_ad_hoc, assigned_date}

**Result**: Already in BCNF as only determinant is the candidate key.

### 4.6 Fourth Normal Form (4NF)

**Requirement**: BCNF + No multi-valued dependencies

**Multi-valued Dependency Check in directive**:
A directive might have multiple target departments independently of its acknowledgments.

**Before 4NF**:
```
directive_id | target_department_id | acknowledging_officer_id
1            | 10                   | 101
1            | 11                   | 101
1            | 10                   | 102
```

**Decomposition to 4NF**:

Table: directive_target
```
directive_id (FK) | target_department_id (FK)
```

Table: directive_acknowledgment
```
directive_id (FK) | officer_id (FK) | acknowledged_at
```

### 4.7 Fifth Normal Form (5NF)

**Requirement**: 4NF + No join dependencies

**Join Dependency Check**:
In the icj_case_judge assignment, if we had a three-way relationship:
- Judge can be assigned to Case
- Case can request Judge from State
- State can provide Judge

**Already in 5NF** as our schema separates:
- icj_case_judge (case ↔ judge)
- icj_judge (judge ↔ nationality_state)

No spurious tuples are created on joining.

### 4.8 Summary of Normalization

| Normal Form | Dependencies Removed | Tables Created |
|-------------|---------------------|----------------|
| 1NF | Multi-valued attributes | vote table separated |
| 2NF | Partial dependencies | organ, state tables |
| 3NF | Transitive dependencies | delegate → state linked by FK |
| BCNF | Non-candidate key determinants | Already satisfied |
| 4NF | Multi-valued dependencies | directive_target separated |
| 5NF | Join dependencies | Already satisfied |

*Final schema contains 21 tables, all in 5NF.*

---

# CHAPTER 5
## IMPLEMENTATION OF CONCURRENCY CONTROL AND RECOVERY MECHANISMS

### 5.1 Introduction to Transactions

**ACID Properties:**
- **Atomicity**: All operations complete or none do
- **Consistency**: Database moves from one valid state to another
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed changes persist

**Transaction States:**
1. Active → Partially Committed → Committed
2. Active → Failed → Aborted

### 5.2 Transaction Control Language (TCL)

**SAVEPOINT**: Create rollback points within transaction
**COMMIT**: Make changes permanent
**ROLLBACK**: Undo changes

### 5.3 Transaction Examples for the Project

**Transaction 1: Submit Matter with Workflow Stages**
```sql
START TRANSACTION;
SAVEPOINT before_insert;

INSERT INTO matter (matter_number, title, organ_id, status, submission_date, requires_voting)
VALUES ('GA/PROP/2024/050', 'New Climate Initiative', 1, 'SUBMITTED', CURDATE(), TRUE);

SET @matter_id = LAST_INSERT_ID();

INSERT INTO matter_workflow (matter_id, stage_number, stage_name, stage_status)
VALUES (@matter_id, 1, 'SUBMISSION', 'COMPLETED'),
       (@matter_id, 2, 'INITIAL_REVIEW', 'IN_PROGRESS'),
       (@matter_id, 3, 'APPROVAL', 'PENDING'),
       (@matter_id, 4, 'VOTING', 'PENDING');

COMMIT;
```

**Transaction 2: Cast Vote with Validation**
```sql
START TRANSACTION;

-- Lock matter row to check status
SELECT status INTO @status FROM matter WHERE matter_id = 1 FOR UPDATE;

IF @status = 'IN_VOTING' THEN
    INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
    VALUES (1, 6, 6, 'YES');
    COMMIT;
ELSE
    ROLLBACK;
    SELECT 'Cannot vote: Matter not in voting stage' AS error;
END IF;
```

**Transaction 3: Process Approval with Rollback Point**
```sql
START TRANSACTION;
SAVEPOINT before_approval;

UPDATE approval SET approval_status = 'APPROVED', decision_date = NOW()
WHERE approval_id = 5;

-- Check if all approvals are complete
SELECT COUNT(*) INTO @pending FROM approval WHERE matter_id = 1 AND approval_status = 'PENDING';

IF @pending = 0 THEN
    UPDATE matter SET status = 'IN_VOTING' WHERE matter_id = 1;
    COMMIT;
ELSE
    ROLLBACK TO before_approval;
    SELECT 'More approvals pending' AS message;
END IF;
```

**Transaction 4: Issue ICJ Judgment**
```sql
START TRANSACTION;

INSERT INTO icj_judgment (judgment_number, case_id, judgment_type, judgment_date, summary, is_unanimous)
VALUES ('ICJ/JUD/2024/001', 1, 'FINAL', CURDATE(), 'Court finds in favor of applicant', TRUE);

UPDATE icj_case SET status = 'JUDGMENT_ISSUED' WHERE case_id = 1;

COMMIT;
```

**Transaction 5: Create Resolution After Voting Passes**
```sql
START TRANSACTION;
SAVEPOINT before_resolution;

-- Calculate votes
SELECT 
    SUM(CASE WHEN vote_value = 'YES' THEN 1 ELSE 0 END),
    SUM(CASE WHEN vote_value = 'NO' THEN 1 ELSE 0 END),
    SUM(CASE WHEN vote_value = 'ABSTAIN' THEN 1 ELSE 0 END)
INTO @yes, @no, @abstain
FROM vote WHERE matter_id = 1;

-- Check if passed
IF (@yes * 100 / (@yes + @no)) >= 50 THEN
    UPDATE matter SET status = 'PASSED' WHERE matter_id = 1;
    
    INSERT INTO resolution (resolution_number, matter_id, organ_id, title, adoption_date, yes_votes, no_votes, abstentions)
    SELECT 'A/RES/2024/001', 1, organ_id, title, CURDATE(), @yes, @no, @abstain
    FROM matter WHERE matter_id = 1;
    
    COMMIT;
ELSE
    UPDATE matter SET status = 'REJECTED' WHERE matter_id = 1;
    COMMIT;
END IF;
```

### 5.4 Concurrency Control with Locking

**Row-Level Locking with SELECT FOR UPDATE:**

```sql
-- Session 1: Lock matter for voting
START TRANSACTION;
SELECT * FROM matter WHERE matter_id = 1 FOR UPDATE;
-- Matter is now locked for this session
```

```sql
-- Session 2: Attempts to read same matter (blocks until Session 1 commits)
START TRANSACTION;
SELECT * FROM matter WHERE matter_id = 1 FOR UPDATE;
-- Waits for Session 1 to release lock
```

### 5.5 Concurrency Scenario: Double Vote Prevention

**Problem**: Two delegates from same state attempt to vote simultaneously

**Solution using SELECT FOR UPDATE:**

```sql
-- Delegate A (Session 1)
START TRANSACTION;

-- Lock the state's voting record for this matter
SELECT * FROM vote WHERE matter_id = 1 AND state_id = 5 FOR UPDATE;

-- Check if vote exists
SELECT COUNT(*) INTO @exists FROM vote WHERE matter_id = 1 AND state_id = 5;

IF @exists = 0 THEN
    INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES (1, 5, 10, 'YES');
    COMMIT;
ELSE
    ROLLBACK;
    SELECT 'State has already voted' AS error;
END IF;
```

```sql
-- Delegate B (Session 2) - runs simultaneously
START TRANSACTION;

-- Blocks here until Session 1 completes
SELECT * FROM vote WHERE matter_id = 1 AND state_id = 5 FOR UPDATE;

-- Now Session 1 has inserted, this check finds existing vote
SELECT COUNT(*) INTO @exists FROM vote WHERE matter_id = 1 AND state_id = 5;
-- @exists = 1, so vote is rejected
ROLLBACK;
```

### 5.6 Concurrency Scenario: Approval Conflict

**Problem**: Two officers attempt to approve same matter simultaneously

```sql
-- Officer A (Session 1)
START TRANSACTION;
SELECT * FROM approval WHERE approval_id = 10 FOR UPDATE;
UPDATE approval SET approval_status = 'APPROVED', approver_officer_id = 1 WHERE approval_id = 10;
COMMIT;
```

```sql
-- Officer B (Session 2)
START TRANSACTION;
SELECT * FROM approval WHERE approval_id = 10 FOR UPDATE;
-- Waits for Session 1
-- After Session 1 commits, sees approval_status = 'APPROVED'
ROLLBACK; -- Cannot approve again
```

### 5.7 Recovery Mechanism

**Recovery after failure using SAVEPOINT and ROLLBACK:**

```sql
START TRANSACTION;

-- Create multiple save points
SAVEPOINT sp_start;

INSERT INTO matter (matter_number, title, organ_id, status, submission_date)
VALUES ('TEST/001', 'Test Matter', 1, 'DRAFT', CURDATE());

SAVEPOINT sp_after_matter;

INSERT INTO matter_workflow (matter_id, stage_number, stage_name, stage_status)
VALUES (LAST_INSERT_ID(), 1, 'SUBMISSION', 'IN_PROGRESS');

-- Simulate failure after workflow insert
SAVEPOINT sp_after_workflow;

-- Attempt something that fails
INSERT INTO approval (matter_id, approver_officer_id, approval_level)
VALUES (9999, 1, 1); -- Fails due to FK constraint

-- Rollback to specific savepoint
ROLLBACK TO sp_after_matter;

-- Can still commit the matter without workflow
COMMIT;
```

---

*[Report continues with Chapters 6 and 7...]*
