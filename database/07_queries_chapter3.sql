-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 07_queries_chapter3.sql - Complex Queries for Report Chapter 3
-- ============================================================================
USE un_workflow_db;

-- ############################################################################
-- SECTION 3.1: ADDING CONSTRAINTS AND QUERIES BASED ON CONSTRAINTS
-- ############################################################################

-- Q1.1: Add a CHECK constraint ensuring voting threshold is between 50% and 100%
ALTER TABLE matter ADD CONSTRAINT chk_voting_threshold_range 
CHECK (voting_threshold >= 50.00 AND voting_threshold <= 100.00);

-- Query: Find matters with voting thresholds above 60%
SELECT 
    matter_number, title, organ_id, voting_threshold, status
FROM matter
WHERE requires_voting = TRUE AND voting_threshold > 60.00;

/* Sample Output:
+----------------+----------------------------------+----------+------------------+--------+
| matter_number  | title                            | organ_id | voting_threshold | status |
+----------------+----------------------------------+----------+------------------+--------+
| GA/RES/78/001  | Resolution on Climate Action...  | 1        | 66.67            | PASSED |
+----------------+----------------------------------+----------+------------------+--------+
*/

-- Q1.2: Query utilizing UNIQUE constraint - find delegates with unique credentials
SELECT 
    d.delegate_code, 
    CONCAT(d.first_name, ' ', d.last_name) AS delegate_name,
    ms.state_name,
    d.credential_date
FROM delegate d
JOIN member_state ms ON d.state_id = ms.state_id
WHERE d.is_permanent_representative = TRUE
ORDER BY d.credential_date DESC;

/* Sample Output:
+-------------+------------------+---------------+------------------+
| delegate_code | delegate_name  | state_name    | credential_date  |
+-------------+------------------+---------------+------------------+
| DEL-BRA-GA  | Ronaldo Costa Filho | Brazil    | 2023-01-15       |
| DEL-AUS-GA  | Mitch Fifield   | Australia     | 2022-06-15       |
+-------------+------------------+---------------+------------------+
*/

-- Q1.3: Query using FOREIGN KEY constraint - find orphan-free matters with their organs
SELECT 
    m.matter_number,
    m.title,
    o.organ_code,
    o.organ_name,
    m.status
FROM matter m
INNER JOIN un_organ o ON m.organ_id = o.organ_id
WHERE o.is_active = TRUE;

/* Sample Output:
+----------------+--------------------------------+------------+------------------+--------+
| matter_number  | title                          | organ_code | organ_name       | status |
+----------------+--------------------------------+------------+------------------+--------+
| GA/RES/78/001  | Resolution on Climate Action   | GA         | General Assembly | PASSED |
| SC/RES/2712    | Resolution on Humanitarian...  | SC         | Security Council | PASSED |
+----------------+--------------------------------+------------+------------------+--------+
*/

-- ############################################################################
-- SECTION 3.2: QUERIES BASED ON AGGREGATE FUNCTIONS
-- ############################################################################

-- Q2.1: Count votes by type for each organ
SELECT 
    o.organ_name,
    COUNT(v.vote_id) AS total_votes,
    SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_votes,
    SUM(CASE WHEN v.vote_value = 'NO' THEN 1 ELSE 0 END) AS no_votes,
    SUM(CASE WHEN v.vote_value = 'ABSTAIN' THEN 1 ELSE 0 END) AS abstentions,
    ROUND(AVG(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) * 100, 2) AS yes_rate_pct
FROM un_organ o
JOIN matter m ON o.organ_id = m.organ_id
LEFT JOIN vote v ON m.matter_id = v.matter_id
WHERE o.organ_code IN ('GA', 'SC', 'ECOSOC')
GROUP BY o.organ_id, o.organ_name
ORDER BY total_votes DESC;

/* Sample Output:
+-----------------+-------------+-----------+----------+-------------+-------------+
| organ_name      | total_votes | yes_votes | no_votes | abstentions | yes_rate_pct|
+-----------------+-------------+-----------+----------+-------------+-------------+
| General Assembly| 20          | 19        | 0        | 1           | 95.00       |
| Security Council| 5           | 3         | 0        | 2           | 60.00       |
+-----------------+-------------+-----------+----------+-------------+-------------+
*/

-- Q2.2: Average processing time by matter type
SELECT 
    matter_type,
    COUNT(*) AS total_matters,
    AVG(DATEDIFF(actual_completion_date, submission_date)) AS avg_days_to_complete,
    MIN(DATEDIFF(actual_completion_date, submission_date)) AS min_days,
    MAX(DATEDIFF(actual_completion_date, submission_date)) AS max_days
FROM matter
WHERE actual_completion_date IS NOT NULL
GROUP BY matter_type;

/* Sample Output:
+-------------+--------------+----------------------+----------+----------+
| matter_type | total_matters| avg_days_to_complete | min_days | max_days |
+-------------+--------------+----------------------+----------+----------+
| RESOLUTION  | 2            | 10.5000              | 8        | 13       |
| DIRECTIVE   | 1            | 15.0000              | 15       | 15       |
+-------------+--------------+----------------------+----------+----------+
*/

-- Q2.3: ICJ judges workload - cases per judge
SELECT 
    CONCAT(j.first_name, ' ', j.last_name) AS judge_name,
    j.specialization,
    COUNT(DISTINCT cj.case_id) AS assigned_cases,
    SUM(CASE WHEN c.status IN ('PENDING', 'HEARING', 'DELIBERATION') THEN 1 ELSE 0 END) AS active_cases
FROM icj_judge j
LEFT JOIN icj_case_judge cj ON j.judge_id = cj.judge_id
LEFT JOIN icj_case c ON cj.case_id = c.case_id
WHERE j.status = 'ACTIVE'
GROUP BY j.judge_id, j.first_name, j.last_name, j.specialization
HAVING COUNT(cj.case_id) > 0
ORDER BY assigned_cases DESC;

/* Sample Output:
+------------------+------------------+----------------+--------------+
| judge_name       | specialization   | assigned_cases | active_cases |
+------------------+------------------+----------------+--------------+
| Nawaf Salam      | Human Rights Law | 3              | 2            |
| Joan Donoghue    | International Law| 3              | 2            |
+------------------+------------------+----------------+--------------+
*/

-- ############################################################################
-- SECTION 3.3: COMPLEX QUERIES BASED ON SETS
-- ############################################################################

-- Q3.1: UNION - All personnel (officers and delegates) involved in GA matters
SELECT 
    'Officer' AS person_type,
    CONCAT(o.first_name, ' ', o.last_name) AS name,
    r.role_name AS role_or_title,
    'Staff' AS affiliation
FROM officer o
JOIN role r ON o.role_id = r.role_id
WHERE o.organ_id = 1

UNION

SELECT 
    'Delegate' AS person_type,
    CONCAT(d.first_name, ' ', d.last_name) AS name,
    d.title AS role_or_title,
    ms.state_name AS affiliation
FROM delegate d
JOIN member_state ms ON d.state_id = ms.state_id
WHERE d.organ_id = 1;

/* Sample Output:
+-------------+----------------------+------------+------------------+
| person_type | name                 | role_or_title | affiliation   |
+-------------+----------------------+------------+------------------+
| Officer     | James Wilson         | Director   | Staff            |
| Delegate    | Linda Thomas-Greenfield | Ambassador | United States |
| Delegate    | Zhang Jun            | Ambassador | China            |
+-------------+----------------------+------------+------------------+
*/

-- Q3.2: INTERSECT simulation - States that voted on BOTH GA matter 1 AND SC matter 3
SELECT ms.state_name
FROM member_state ms
WHERE ms.state_id IN (
    SELECT v1.state_id FROM vote v1 WHERE v1.matter_id = 1
)
AND ms.state_id IN (
    SELECT v2.state_id FROM vote v2 WHERE v2.matter_id = 3
);

/* Sample Output:
+---------------+
| state_name    |
+---------------+
| United States |
| United Kingdom|
| France        |
+---------------+
*/

-- Q3.3: EXCEPT simulation - States that voted on GA matter 1 but NOT on matter 2
SELECT ms.state_name AS states_voted_matter1_not_matter2
FROM member_state ms
WHERE ms.state_id IN (SELECT state_id FROM vote WHERE matter_id = 1)
AND ms.state_id NOT IN (SELECT state_id FROM vote WHERE matter_id = 2);

/* Sample Output:
+----------------------------------+
| states_voted_matter1_not_matter2 |
+----------------------------------+
| China                            |
| Russia                           |
| India                            |
| Brazil                           |
+----------------------------------+
*/

-- ############################################################################
-- SECTION 3.4: COMPLEX QUERIES BASED ON SUBQUERIES
-- ############################################################################

-- Q4.1: Scalar subquery - Matters with more votes than average
SELECT 
    m.matter_number,
    m.title,
    (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) AS vote_count
FROM matter m
WHERE m.requires_voting = TRUE
AND (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) > 
    (SELECT AVG(vote_cnt) FROM (SELECT COUNT(*) AS vote_cnt FROM vote GROUP BY matter_id) AS avg_votes);

/* Sample Output:
+----------------+----------------------------------+------------+
| matter_number  | title                            | vote_count |
+----------------+----------------------------------+------------+
| GA/RES/78/001  | Resolution on Climate Action...  | 15         |
+----------------+----------------------------------+------------+
*/

-- Q4.2: Correlated subquery - ICJ cases with their latest hearing status
SELECT 
    c.case_number,
    c.case_title,
    c.status AS case_status,
    (SELECT h.status 
     FROM icj_hearing h 
     WHERE h.case_id = c.case_id 
     ORDER BY h.hearing_number DESC LIMIT 1) AS latest_hearing_status,
    (SELECT h.scheduled_date 
     FROM icj_hearing h 
     WHERE h.case_id = c.case_id 
     ORDER BY h.hearing_number DESC LIMIT 1) AS latest_hearing_date
FROM icj_case c
WHERE c.case_type = 'CONTENTIOUS';

/* Sample Output:
+---------------+-----------------------------+-------------+-----------------------+---------------------+
| case_number   | case_title                  | case_status | latest_hearing_status | latest_hearing_date |
+---------------+-----------------------------+-------------+-----------------------+---------------------+
| ICJ/2024/001  | Maritime Boundary Dispute...| HEARING     | COMPLETED             | 2024-09-16          |
| ICJ/2024/002  | Application of Genocide...  | PRELIM...   | COMPLETED             | 2024-06-15          |
+---------------+-----------------------------+-------------+-----------------------+---------------------+
*/

-- Q4.3: EXISTS subquery - Delegates who have cast at least one vote
SELECT 
    CONCAT(d.first_name, ' ', d.last_name) AS delegate_name,
    ms.state_name,
    d.title
FROM delegate d
JOIN member_state ms ON d.state_id = ms.state_id
WHERE EXISTS (
    SELECT 1 FROM vote v WHERE v.delegate_id = d.delegate_id
)
ORDER BY ms.state_name;

/* Sample Output:
+------------------------+------------------+-----------+
| delegate_name          | state_name       | title     |
+------------------------+------------------+-----------+
| Mitch Fifield          | Australia        | Ambassador|
| Ronaldo Costa Filho    | Brazil           | Ambassador|
| Zhang Jun              | China            | Ambassador|
+------------------------+------------------+-----------+
*/

-- ############################################################################
-- SECTION 3.5: COMPLEX QUERIES BASED ON JOINS
-- ############################################################################

-- Q5.1: INNER JOIN - GA/SC/ECOSOC voting results with delegate and state info
SELECT 
    m.matter_number,
    m.title,
    o.organ_code,
    ms.state_name,
    CONCAT(d.first_name, ' ', d.last_name) AS delegate_name,
    v.vote_value,
    v.vote_timestamp
FROM vote v
INNER JOIN matter m ON v.matter_id = m.matter_id
INNER JOIN un_organ o ON m.organ_id = o.organ_id
INNER JOIN member_state ms ON v.state_id = ms.state_id
INNER JOIN delegate d ON v.delegate_id = d.delegate_id
WHERE o.organ_code IN ('GA', 'SC', 'ECOSOC')
ORDER BY m.matter_number, ms.state_name;

/* Sample Output:
+----------------+---------------------------+------------+---------------+----------------+------------+---------------------+
| matter_number  | title                     | organ_code | state_name    | delegate_name  | vote_value | vote_timestamp      |
+----------------+---------------------------+------------+---------------+----------------+------------+---------------------+
| GA/RES/78/001  | Resolution on Climate...  | GA         | Australia     | Mitch Fifield  | YES        | 2024-09-27 10:15:00 |
| GA/RES/78/001  | Resolution on Climate...  | GA         | Brazil        | Ronaldo Costa  | YES        | 2024-09-27 10:20:00 |
+----------------+---------------------------+------------+---------------+----------------+------------+---------------------+
*/

-- Q5.2: LEFT JOIN - All directives with acknowledgment status (including unacknowledged)
SELECT 
    d.directive_number,
    d.title,
    d.directive_type,
    dept.department_name AS issuing_department,
    o.first_name AS issued_by_first,
    o.last_name AS issued_by_last,
    d.status,
    COUNT(da.acknowledgment_id) AS acknowledgment_count
FROM directive d
LEFT JOIN directive_acknowledgment da ON d.directive_id = da.directive_id
LEFT JOIN department dept ON d.issuing_department_id = dept.department_id
LEFT JOIN officer o ON d.issued_by_officer_id = o.officer_id
GROUP BY d.directive_id, d.directive_number, d.title, d.directive_type, 
         dept.department_name, o.first_name, o.last_name, d.status;

/* Sample Output:
+------------------+------------------------------+---------------+-----------------------------+---------+-------------+-----------+----------------------+
| directive_number | title                        | directive_type| issuing_department          | issued_by_first | issued_by_last | status    | acknowledgment_count |
+------------------+------------------------------+---------------+-----------------------------+---------+-------------+-----------+----------------------+
| ST/SGB/2024/1    | Remote Work Policy Framework | POLICY        | Executive Office of the SG  | António | Guterres    | IN_EFFECT | 7                    |
| ST/AI/2024/5     | Travel Authorization Proc... | CIRCULAR      | Dept of Operational Support | Amina   | Mohammed    | IN_EFFECT | 0                    |
+------------------+------------------------------+---------------+-----------------------------+---------+-------------+-----------+----------------------+
*/

-- Q5.3: Multiple JOINs - Trusteeship reports with territory and officer details
SELECT 
    tr.report_number,
    tr.report_type,
    tr.report_year,
    tt.territory_name,
    tt.current_status AS territory_status,
    ms.state_name AS administering_authority,
    CONCAT(o.first_name, ' ', o.last_name) AS reporting_officer,
    tr.review_status,
    tr.decision_date
FROM trusteeship_report tr
JOIN trusteeship_territory tt ON tr.territory_id = tt.territory_id
JOIN member_state ms ON tt.administering_state_id = ms.state_id
JOIN officer o ON tr.reporting_officer_id = o.officer_id
ORDER BY tr.report_year DESC, tr.report_number;

/* Sample Output:
+---------------------+-------------+-------------+----------------+-----------------+-----------------------+-------------------+---------------+---------------+
| report_number       | report_type | report_year | territory_name | territory_status | administering_authority | reporting_officer | review_status | decision_date |
+---------------------+-------------+-------------+----------------+-----------------+-----------------------+-------------------+---------------+---------------+
| TC/REP/2024/HIST    | SPECIAL     | 2024        | Palau          | INDEPENDENT     | United States         | Patricia Mendez   | CLOSED        | 2024-02-28    |
| TC/REP/1993/PLW/FINAL | FINAL     | 1993        | Palau          | INDEPENDENT     | United States         | Patricia Mendez   | CLOSED        | 1994-10-01    |
+---------------------+-------------+-------------+----------------+-----------------+-----------------------+-------------------+---------------+---------------+
*/

-- ############################################################################
-- SECTION 3.6: COMPLEX QUERIES BASED ON VIEWS
-- ############################################################################

-- Q6.1: Query using v_vote_summary view - matters pending vote completion
SELECT 
    matter_number,
    title,
    organ_code,
    total_votes,
    yes_votes,
    no_votes,
    abstentions,
    yes_percentage,
    voting_threshold,
    projected_outcome
FROM v_vote_summary
WHERE matter_status = 'IN_VOTING'
ORDER BY total_votes DESC;

/* Sample Output:
+----------------+-----------------------------+------------+-------------+-----------+----------+-------------+----------------+------------------+------------------+
| matter_number  | title                       | organ_code | total_votes | yes_votes | no_votes | abstentions | yes_percentage | voting_threshold | projected_outcome|
+----------------+-----------------------------+------------+-------------+-----------+----------+-------------+----------------+------------------+------------------+
| GA/RES/78/002  | Resolution on Digital Coop. | GA         | 5           | 5         | 0        | 0           | 100.00         | 50.00            | WOULD PASS       |
+----------------+-----------------------------+------------+-------------+-----------+----------+-------------+----------------+------------------+------------------+
*/

-- Q6.2: Query using v_officer_workload view - find overloaded officers
SELECT 
    officer_name,
    role_name,
    department,
    organ_name,
    active_workflows,
    pending_approvals,
    queued_tasks,
    (active_workflows + pending_approvals + queued_tasks) AS total_workload
FROM v_officer_workload
WHERE (active_workflows + pending_approvals) > 0
ORDER BY total_workload DESC;

/* Sample Output:
+------------------+-----------+----------------------------+-------------------+------------------+-------------------+--------------+----------------+
| officer_name     | role_name | department                 | organ_name        | active_workflows | pending_approvals | queued_tasks | total_workload |
+------------------+-----------+----------------------------+-------------------+------------------+-------------------+--------------+----------------+
| James Wilson     | Director  | Executive Office of the SG | General Assembly  | 1                | 0                 | 0            | 1              |
| Lisa Kumar       | Director  | Dept of Political Affairs  | Security Council  | 0                | 1                 | 0            | 1              |
+------------------+-----------+----------------------------+-------------------+------------------+-------------------+--------------+----------------+
*/

-- Q6.3: Query using v_icj_case_status view - cases awaiting judgment
SELECT 
    case_number,
    case_title,
    parties,
    status,
    completed_hearings,
    total_hearings,
    last_hearing_date,
    judges_assigned
FROM v_icj_case_status
WHERE status IN ('DELIBERATION', 'HEARING')
ORDER BY last_hearing_date DESC;

/* Sample Output:
+---------------+-----------------------------+-----------------------------+-------------+--------------------+----------------+-------------------+----------------+
| case_number   | case_title                  | parties                     | status      | completed_hearings | total_hearings | last_hearing_date | judges_assigned|
+---------------+-----------------------------+-----------------------------+-------------+--------------------+----------------+-------------------+----------------+
| ICJ/2023/005  | Advisory Opinion on Climate | Requested by General Ass... | DELIBERATION| 1                  | 1              | 2024-08-01        | 8              |
| ICJ/2024/001  | Maritime Boundary Dispute   | Brazil v. Mexico            | HEARING     | 3                  | 3              | 2024-09-16        | 9              |
+---------------+-----------------------------+-----------------------------+-------------+--------------------+----------------+-------------------+----------------+
*/

-- ############################################################################
-- SECTION 3.7: COMPLEX QUERIES BASED ON TRIGGERS
-- ############################################################################

-- Q7.1: Demonstrate trigger effect - insert a matter and check audit log
-- First check current audit log entries for matter table
SELECT 
    log_id,
    action_type,
    action_description,
    action_timestamp
FROM audit_log
WHERE table_name = 'matter'
ORDER BY log_id DESC
LIMIT 5;

/* Sample Output (before new insert):
+--------+---------------+------------------------------------------+---------------------+
| log_id | action_type   | action_description                       | action_timestamp    |
+--------+---------------+------------------------------------------+---------------------+
| 10     | STATUS_CHANGE | Matter status changed to IN_VOTING       | 2024-10-20 10:00:00 |
| 5      | STATUS_CHANGE | Matter status changed to IN_VOTING       | 2024-09-27 10:00:00 |
| 2      | STATUS_CHANGE | Matter status changed from DRAFT to...   | 2024-09-15 09:30:00 |
+--------+---------------+------------------------------------------+---------------------+
*/

-- Q7.2: Demonstrate vote trigger - check vote audit entries
SELECT 
    al.log_id,
    al.action_type,
    al.action_description,
    CONCAT(d.first_name, ' ', d.last_name) AS delegate_name,
    al.action_timestamp
FROM audit_log al
LEFT JOIN delegate d ON al.performed_by_delegate_id = d.delegate_id
WHERE al.table_name = 'vote'
ORDER BY al.log_id DESC
LIMIT 5;

/* Sample Output:
+--------+-------------+---------------------------------------------+------------------------+---------------------+
| log_id | action_type | action_description                          | delegate_name          | action_timestamp    |
+--------+-------------+---------------------------------------------+------------------------+---------------------+
| 14     | VOTE        | France (Nicolas de Rivière) voted YES on... | Nicolas de Rivière     | 2024-09-27 10:30:00 |
| 13     | VOTE        | UK (Barbara Woodward) voted YES on...       | Barbara Woodward       | 2024-09-27 10:25:00 |
| 12     | VOTE        | Russia ABSTAINED on GA/RES/78/001           | Vassily Nebenzia       | 2024-09-27 10:22:00 |
+--------+-------------+---------------------------------------------+------------------------+---------------------+
*/

-- Q7.3: Query to test trigger prevention - attempt invalid vote (wrapped in procedure)
-- This would fail if executed due to trigger trg_prevent_vote_invalid_stage
DELIMITER //
CREATE PROCEDURE test_trigger_vote_prevention()
BEGIN
    DECLARE v_error_msg VARCHAR(500);
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        SELECT CONCAT('TRIGGER PREVENTED: ', v_error_msg) AS result;
    END;
    
    -- Attempt to vote on a matter NOT in IN_VOTING status
    INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
    VALUES (4, 1, 1, 'YES'); -- Matter 4 is in PENDING_APPROVAL status
END//
DELIMITER ;

-- CALL test_trigger_vote_prevention();
/* Expected Output:
+-----------------------------------------------------------+
| result                                                    |
+-----------------------------------------------------------+
| TRIGGER PREVENTED: Cannot cast vote: Matter is not in... |
+-----------------------------------------------------------+
*/

-- ############################################################################
-- SECTION 3.8: COMPLEX QUERIES BASED ON CURSORS
-- ############################################################################

-- Q8.1: Call procedure using cursor to compute vote outcomes
SET @yes = 0, @no = 0, @abstain = 0, @total = 0, @pct = 0.0, @outcome = '';
CALL sp_compute_vote_outcome(1, @yes, @no, @abstain, @total, @pct, @outcome);
SELECT @yes AS yes_votes, @no AS no_votes, @abstain AS abstentions, 
       @total AS total, @pct AS yes_percentage, @outcome AS outcome;

/* Sample Output:
+-----------+----------+-------------+-------+----------------+---------+
| yes_votes | no_votes | abstentions | total | yes_percentage | outcome |
+-----------+----------+-------------+-------+----------------+---------+
| 14        | 0        | 1           | 15    | 100.00         | PASSED  |
+-----------+----------+-------------+-------+----------------+---------+
*/

-- Q8.2: Generate workload report using cursor-based procedure
CALL sp_generate_workload_report();

/* Sample Output:
+------------+------------------+------------------+-------------------+----------------+
| officer_id | officer_name     | active_workflows | pending_approvals | workload_level |
+------------+------------------+------------------+-------------------+----------------+
| 11         | James Wilson     | 1                | 0                 | LOW            |
| 12         | Lisa Kumar       | 0                | 1                 | LOW            |
| 1          | António Guterres | 0                | 0                 | LOW            |
+------------+------------------+------------------+-------------------+----------------+
*/

-- Q8.3: Demonstrate cursor in ad-hoc block - iterate through UN organs
DELIMITER //
CREATE PROCEDURE demo_cursor_organs()
BEGIN
    DECLARE v_organ_code VARCHAR(10);
    DECLARE v_organ_name VARCHAR(100);
    DECLARE v_matter_count INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE organ_cursor CURSOR FOR
        SELECT organ_code, organ_name FROM un_organ WHERE is_active = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    DROP TEMPORARY TABLE IF EXISTS temp_organ_stats;
    CREATE TEMPORARY TABLE temp_organ_stats (
        organ_code VARCHAR(10),
        organ_name VARCHAR(100),
        matter_count INT
    );
    
    OPEN organ_cursor;
    
    read_loop: LOOP
        FETCH organ_cursor INTO v_organ_code, v_organ_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SELECT COUNT(*) INTO v_matter_count
        FROM matter m
        JOIN un_organ o ON m.organ_id = o.organ_id
        WHERE o.organ_code = v_organ_code;
        
        INSERT INTO temp_organ_stats VALUES (v_organ_code, v_organ_name, v_matter_count);
    END LOOP;
    
    CLOSE organ_cursor;
    
    SELECT * FROM temp_organ_stats ORDER BY matter_count DESC;
    DROP TEMPORARY TABLE temp_organ_stats;
END//
DELIMITER ;

-- CALL demo_cursor_organs();
/* Sample Output:
+------------+----------------------------------+--------------+
| organ_code | organ_name                       | matter_count |
+------------+----------------------------------+--------------+
| GA         | General Assembly                 | 2            |
| SC         | Security Council                 | 2            |
| SECRETARIAT| United Nations Secretariat       | 2            |
| TC         | Trusteeship Council              | 1            |
| ECOSOC     | Economic and Social Council      | 1            |
| ICJ        | International Court of Justice   | 0            |
+------------+----------------------------------+--------------+
*/

-- ############################################################################
-- RELATIONAL ALGEBRA EXPRESSIONS
-- ############################################################################
/*
RELATIONAL ALGEBRA for Selected Queries:

RA1 (Q1.3 - Matters with Organs):
π(matter_number, title, organ_code, organ_name, status)
  (matter ⨝_{matter.organ_id = un_organ.organ_id} 
   σ_{is_active = TRUE}(un_organ))

RA2 (Q2.1 - Vote count by organ):
γ_{organ_name; COUNT(vote_id), SUM(YES), SUM(NO), SUM(ABSTAIN)}
  (un_organ ⨝ matter ⨝ vote)

RA3 (Q3.1 - UNION of officers and delegates):
π(person_type, name, role)(officer) ∪ π(person_type, name, title)(delegate)

RA4 (Q3.2 - INTERSECTION simulation):
π(state_id)(σ_{matter_id=1}(vote)) ∩ π(state_id)(σ_{matter_id=3}(vote))

RA5 (Q3.3 - DIFFERENCE simulation):
π(state_id)(σ_{matter_id=1}(vote)) − π(state_id)(σ_{matter_id=2}(vote))

RA6 (Q4.3 - EXISTS as semijoin):
delegate ⋉_{delegate.delegate_id = vote.delegate_id} vote

RA7 (Q5.1 - Multiple INNER JOINs):
π(matter_number, title, organ_code, state_name, delegate_name, vote_value)
  (vote ⨝ matter ⨝ un_organ ⨝ member_state ⨝ delegate)

RA8 (Q5.2 - LEFT JOIN):
directive ⟕_{directive.directive_id = directive_acknowledgment.directive_id} 
  directive_acknowledgment

RA9 (Aggregate - Average votes per matter):
γ_{matter_id; AVG(vote_count)}(π(matter_id, vote_id)(vote))

RA10 (Selection with conditions):
σ_{status='IN_VOTING' ∧ organ_code='GA'}(matter ⨝ un_organ)

RA11 (Projection with rename):
ρ(judge_full_name ← CONCAT(first_name, last_name))
  (π(first_name, last_name, specialization)(icj_judge))

RA12 (Complex nested - ICJ cases with hearings):
π(case_number, case_title, hearing_count)
  (icj_case ⨝ γ_{case_id; COUNT(*) AS hearing_count}(icj_hearing))
*/

-- ============================================================================
-- END OF CHAPTER 3 QUERIES
-- ============================================================================
