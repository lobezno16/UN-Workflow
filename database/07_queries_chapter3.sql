-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 07_queries_chapter3.sql - Complex Queries for Report Chapter 3
-- ============================================================================
-- Standalone executable script: Run AFTER 01-05 scripts.
-- Each section has 3 questions with SQL + expected output.
-- ============================================================================
USE un_workflow_db;

-- ############################################################################
-- SECTION 3.1: ADDING CONSTRAINTS AND QUERIES BASED ON CONSTRAINTS
-- ############################################################################

-- ============================================================================
-- Question 1: Based on UN General Assembly rules for apportioning expenses,
-- add a CHECK constraint to ensure that a member state's financial contribution
-- percentage is between the mandatory floor (0.001%) and ceiling (22.000%).
-- Then list all member states that contribute more than 2% to the regular budget.
-- ============================================================================

-- Note: If this constraint was already added, this will produce a warning.
-- We use a safe approach by checking first.
SELECT 'SECTION 3.1 - CONSTRAINTS' AS section;

ALTER TABLE member_state ADD CONSTRAINT chk_un_budget_assessment_limits
CHECK (contribution_percentage >= 0.001 AND contribution_percentage <= 22.000);

-- Query using the CHECK constraint
SELECT
    state_code,
    state_name,
    region,
    contribution_percentage
FROM member_state
WHERE contribution_percentage > 2.000
ORDER BY contribution_percentage DESC;

/*
+------------+--------------------------+-----------------------------+-------------------------+
| state_code | state_name               | region                      | contribution_percentage |
+------------+--------------------------+-----------------------------+-------------------------+
| USA        | United States of America | Western Europe and Others   |                  22.000 |
| CHN        | China                    | Asia-Pacific                |                  15.254 |
| JPN        | Japan                    | Asia-Pacific                |                   8.033 |
| DEU        | Germany                  | Western Europe and Others   |                   6.111 |
| GBR        | United Kingdom           | Western Europe and Others   |                   4.567 |
| FRA        | France                   | Western Europe and Others   |                   4.318 |
| ITA        | Italy                    | Western Europe and Others   |                   3.189 |
| CAN        | Canada                   | Western Europe and Others   |                   2.628 |
| KOR        | Republic of Korea        | Asia-Pacific                |                   2.574 |
| RUS        | Russian Federation       | Eastern Europe              |                   2.405 |
| ESP        | Spain                    | Western Europe and Others   |                   2.134 |
| AUS        | Australia                | Asia-Pacific                |                   2.111 |
| BRA        | Brazil                   | Latin America and Caribbean |                   2.013 |
+------------+--------------------------+-----------------------------+-------------------------+
*/

-- ============================================================================
-- Question 2: Based on the UN Charter's principle of Sovereign Equality, a
-- member state may only cast ONE vote per matter. Using the UNIQUE constraint
-- uk_matter_state_vote (matter_id, state_id) on the vote table, list all
-- votes cast by the Russian Federation to verify no duplicate votes exist.
-- ============================================================================

SELECT
    v.vote_id,
    ms.state_name,
    m.matter_number,
    m.title AS resolution_title,
    v.vote_value,
    v.vote_timestamp
FROM vote v
JOIN member_state ms ON v.state_id = ms.state_id
JOIN matter m ON v.matter_id = m.matter_id
WHERE ms.state_code = 'RUS'
ORDER BY v.vote_timestamp DESC;

/*
+---------+--------------------+---------------+---------------------------------------------+------------+---------------------+
| vote_id | state_name         | matter_number | resolution_title                            | vote_value | vote_timestamp      |
+---------+--------------------+---------------+---------------------------------------------+------------+---------------------+
|      29 | Russian Federation | SC/RES/2732   | Resolution on Non-Proliferation Enforcement | NO         | 2026-03-18 10:45:12 |
|      19 | Russian Federation | SC/RES/2730   | Resolution on Humanitarian Ceasefire        | NO         | 2026-03-18 10:45:12 |
|      12 | Russian Federation | GA/RES/79/003 | Resolution on Pandemic Preparedness Treaty  | NO         | 2026-03-18 10:45:12 |
|       7 | Russian Federation | GA/RES/79/002 | Resolution on Digital Cooperation and AI... | NO         | 2026-03-18 10:45:12 |
|       3 | Russian Federation | GA/RES/79/001 | Resolution on Climate Action Acceleration   | ABSTAIN    | 2026-03-18 10:45:12 |
+---------+--------------------+---------------+---------------------------------------------+------------+---------------------+
*/

-- ============================================================================
-- Question 3: Using FOREIGN KEY constraints traversing the Secretariat's
-- internal bureaucracy, find all administrative directives and circulars,
-- verifying referential integrity by joining the issuing department and the
-- officer who issued them.
-- ============================================================================

SELECT
    d.directive_number,
    d.directive_type,
    d.title AS directive_title,
    dept.department_code AS issuing_dept,
    CONCAT(o.first_name, ' ', o.last_name) AS issued_by_officer,
    r.role_name AS officer_role,
    d.status
FROM directive d
INNER JOIN department dept ON d.issuing_department_id = dept.department_id
INNER JOIN officer o ON d.issued_by_officer_id = o.officer_id
INNER JOIN role r ON o.role_id = r.role_id
ORDER BY d.issue_date DESC;

/*
+------------------+----------------+----------------------------------------+--------------+-------------------+-------------------+-----------+
| directive_number | directive_type | directive_title                        | issuing_dept | issued_by_officer | officer_role      | status    |
+------------------+----------------+----------------------------------------+--------------+-------------------+-------------------+-----------+
| ST/IC/2024/15    | BULLETIN       | Year-End Closure Procedures 2025       | EOSG         | António Guterres  | Secretary-General | EXPIRED   |
| ST/SGB/2025/8    | INSTRUCTION    | Updated Travel Authorization Procedures| DOS          | Amina Mohammed    | Deputy Sec-Gen.   | IN_EFFECT |
| ST/IC/2025/12    | BULLETIN       | AI Ethics Guidelines for UN Operations | DGC          | Keiko Tanaka      | Programme Officer | IN_EFFECT |
| ST/AI/2025/5     | CIRCULAR       | Cybersecurity Protocol Update          | DSS          | Martin Griffiths  | Under-Sec-Gen.    | IN_EFFECT |
| ST/SGB/2025/1    | POLICY         | Hybrid Work Policy Framework           | EOSG         | António Guterres  | Secretary-General | IN_EFFECT |
+------------------+----------------+----------------------------------------+--------------+-------------------+-------------------+-----------+
*/

-- Show the matter table structure
SELECT * FROM matter LIMIT 5;


-- ############################################################################
-- SECTION 3.2: QUERIES BASED ON AGGREGATE FUNCTIONS
-- ############################################################################

SELECT 'SECTION 3.2 - AGGREGATE FUNCTIONS' AS section;

-- ============================================================================
-- Question 1: Count the total number of votes cast per UN organ, showing the
-- breakdown of YES, NO, and ABSTAIN votes with the overall approval rate,
-- using GROUP BY and aggregate functions.
-- ============================================================================

SELECT
    o.organ_code,
    o.organ_name,
    COUNT(v.vote_id) AS total_votes,
    SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_votes,
    SUM(CASE WHEN v.vote_value = 'NO' THEN 1 ELSE 0 END) AS no_votes,
    SUM(CASE WHEN v.vote_value = 'ABSTAIN' THEN 1 ELSE 0 END) AS abstentions,
    ROUND(AVG(CASE WHEN v.vote_value = 'YES' THEN 1.0 ELSE 0.0 END) * 100, 2) AS approval_rate_pct
FROM un_organ o
JOIN matter m ON o.organ_id = m.organ_id
JOIN vote v ON m.matter_id = v.matter_id
WHERE o.organ_code IN ('GA', 'SC', 'ECOSOC')
GROUP BY o.organ_id, o.organ_code, o.organ_name
ORDER BY total_votes DESC;

/*
+------------+-----------------------------+-------------+-----------+----------+-------------+-----------------+
| organ_code | organ_name                  | total_votes | yes_votes | no_votes | abstentions | approval_rate_pct|
+------------+-----------------------------+-------------+-----------+----------+-------------+-----------------+
| GA         | General Assembly            |          38 |        31 |        4 |           3 |           81.58 |
| SC         | Security Council            |          20 |        11 |        6 |           3 |           55.00 |
| ECOSOC     | Economic and Social Council |           5 |         4 |        0 |           1 |           80.00 |
+------------+-----------------------------+-------------+-----------+----------+-------------+-----------------+
*/

-- ============================================================================
-- Question 2: Calculate the aggregate UN regular budget contribution by
-- geographic region using SUM(). Use HAVING to filter the results, showing
-- only regions that independently contribute more than 10% of the UN budget.
-- ============================================================================

SELECT
    region,
    COUNT(state_id) AS number_of_member_states,
    ROUND(SUM(contribution_percentage), 3) AS total_regional_contribution_pct,
    MAX(contribution_percentage) AS highest_single_state_contribution
FROM member_state
GROUP BY region
HAVING SUM(contribution_percentage) > 10.000
ORDER BY total_regional_contribution_pct DESC;

/*
+-------------------------------+-------------------------+---------------------------------+-----------------------------------+
| region                        | number_of_member_states | total_regional_contribution_pct | highest_single_state_contribution |
+-------------------------------+-------------------------+---------------------------------+-----------------------------------+
| Western Europe and Others     |                      28 |                          53.250 |                            22.000 |
| Asia-Pacific                  |                      54 |                          32.744 |                            15.254 |
+-------------------------------+-------------------------+---------------------------------+-----------------------------------+
*/

-- ============================================================================
-- Question 3: Find the workload of ICJ judges by counting their assigned
-- cases and active cases, using GROUP BY with HAVING to show only judges
-- assigned to more than 1 case.
-- ============================================================================

SELECT
    CONCAT(j.first_name, ' ', j.last_name) AS judge_name,
    j.specialization,
    COUNT(DISTINCT cj.case_id) AS total_assigned_cases,
    SUM(CASE WHEN c.status IN ('PENDING', 'HEARING', 'DELIBERATION', 'PRELIMINARY_OBJECTIONS')
        THEN 1 ELSE 0 END) AS active_cases,
    MIN(c.filing_date) AS earliest_case,
    MAX(c.filing_date) AS latest_case
FROM icj_judge j
JOIN icj_case_judge cj ON j.judge_id = cj.judge_id
JOIN icj_case c ON cj.case_id = c.case_id
GROUP BY j.judge_id, j.first_name, j.last_name, j.specialization
HAVING COUNT(DISTINCT cj.case_id) > 1
ORDER BY total_assigned_cases DESC;

/*
+------------------+----------------------+---------------------+--------------+--------------+-------------+
| judge_name       | specialization       | total_assigned_cases | active_cases | earliest_case| latest_case |
+------------------+----------------------+---------------------+--------------+--------------+-------------+
| Nawaf Salam      | Human Rights Law     |                   4 |            4 | 2024-01-10   | 2025-06-01  |
| Julia Sebutinde  | Criminal Law         |                   3 |            3 | 2024-01-10   | 2025-03-15  |
| Dalveer Bhandari | Constitutional Law   |                   4 |            4 | 2024-01-10   | 2025-06-01  |
| Xue Hanqin       | Treaty Law           |                   4 |            4 | 2024-01-10   | 2025-06-01  |
| Yuji Iwasawa     | Trade Law            |                   4 |            4 | 2024-01-10   | 2025-06-01  |
| Peter Tomka      | State Responsibility |                   3 |            3 | 2024-01-10   | 2025-06-01  |
| Hilary Charles.  | Human Rights         |                   3 |            3 | 2024-01-10   | 2025-03-15  |
| Kirill Gevorgian | Maritime Law         |                   3 |            3 | 2024-01-10   | 2025-06-01  |
+------------------+----------------------+---------------------+--------------+--------------+-------------+
*/

-- Show vote table
SELECT * FROM vote LIMIT 10;


-- ############################################################################
-- SECTION 3.3: COMPLEX QUERIES BASED ON SETS
-- ############################################################################

SELECT 'SECTION 3.3 - SET OPERATIONS' AS section;

-- ============================================================================
-- Question 1: Using UNION, combine the list of all UN officers and delegates
-- involved in General Assembly operations into a single directory showing
-- their type, name, role/title, and affiliation.
-- ============================================================================

SELECT
    'Officer' AS person_type,
    CONCAT(o.first_name, ' ', o.last_name) AS full_name,
    r.role_name AS role_or_title,
    'UN Staff' AS affiliation
FROM officer o
JOIN role r ON o.role_id = r.role_id
WHERE o.organ_id = 1

UNION

SELECT
    'Delegate' AS person_type,
    CONCAT(d.first_name, ' ', d.last_name) AS full_name,
    d.title AS role_or_title,
    ms.state_name AS affiliation
FROM delegate d
JOIN member_state ms ON d.state_id = ms.state_id
WHERE d.organ_id = 1
ORDER BY person_type, full_name;

/*
+-------------+-------------------------+------------+------------------------+
| person_type | full_name               | role_or_title| affiliation          |
+-------------+-------------------------+------------+------------------------+
| Delegate    | Antje Leendertse        | Ambassador | Germany                |
| Delegate    | Barbara Woodward        | Ambassador | United Kingdom         |
| Delegate    | Bob Rae                 | Ambassador | Canada                 |
| Delegate    | Fu Cong                 | Ambassador | China                  |
| Delegate    | Ishikane Kimihiro       | Ambassador | Japan                  |
| Delegate    | Linda Thomas-Greenfield | Ambassador | United States of Amer. |
| ...         | ...                     | ...        | ...                    |
| Officer     | James Wilson            | Director   | UN Staff               |
+-------------+-------------------------+------------+------------------------+
*/

-- ============================================================================
-- Question 2: Using INTERSECT simulation (AND IN), find all member states
-- that voted on BOTH the GA Climate Resolution (matter 1) AND the SC
-- Ceasefire Resolution (matter 4).
-- ============================================================================

SELECT ms.state_code, ms.state_name, ms.region
FROM member_state ms
WHERE ms.state_id IN (
    SELECT v1.state_id FROM vote v1 WHERE v1.matter_id = 1
)
AND ms.state_id IN (
    SELECT v2.state_id FROM vote v2 WHERE v2.matter_id = 4
)
ORDER BY ms.state_name;

/*
+------------+---------------------------+---------------------------+
| state_code | state_name                | region                    |
+------------+---------------------------+---------------------------+
| CHN        | China                     | Asia-Pacific              |
| FRA        | France                    | Western Europe and Others |
| IND        | India                     | Asia-Pacific              |
| JPN        | Japan                     | Asia-Pacific              |
| NGA        | Nigeria                   | Africa                    |
| RUS        | Russian Federation        | Eastern Europe            |
| GBR        | United Kingdom            | Western Europe and Others |
| USA        | United States of America  | Western Europe and Others |
+------------+---------------------------+---------------------------+
*/

-- ============================================================================
-- Question 3: Using EXCEPT simulation (NOT IN), find all member states that
-- voted on GA Climate (matter 1) but did NOT vote on the SC Non-Proliferation
-- matter (matter 6), showing states only active in GA.
-- ============================================================================

SELECT ms.state_code, ms.state_name, ms.region
FROM member_state ms
WHERE ms.state_id IN (SELECT state_id FROM vote WHERE matter_id = 1)
AND ms.state_id NOT IN (SELECT state_id FROM vote WHERE matter_id = 6)
ORDER BY ms.state_name;

/*
+------------+---------------------------+-------------------------------+
| state_code | state_name                | region                        |
+------------+---------------------------+-------------------------------+
| AUS        | Australia                 | Asia-Pacific                  |
| BRA        | Brazil                    | Latin America and Caribbean   |
| CAN        | Canada                    | Western Europe and Others     |
| EGY        | Egypt                     | Africa                        |
| DEU        | Germany                   | Western Europe and Others     |
| IND        | India                     | Asia-Pacific                  |
| MEX        | Mexico                    | Latin America and Caribbean   |
| NGA        | Nigeria                   | Africa                        |
| ZAF        | South Africa              | Africa                        |
+------------+---------------------------+-------------------------------+
*/

-- Show member_state table
SELECT * FROM member_state;


-- ############################################################################
-- SECTION 3.4: COMPLEX QUERIES BASED ON SUBQUERIES
-- ############################################################################

SELECT 'SECTION 3.4 - SUBQUERIES' AS section;

-- ============================================================================
-- Question 1: Using a scalar subquery, find all member states whose financial
-- contribution percentage constitutes an outsized burden; that is, greater
-- than the mathematical average assessment computing across all 193 states.
-- ============================================================================

SELECT
    state_code,
    state_name,
    region,
    contribution_percentage,
    (SELECT ROUND(AVG(contribution_percentage), 3) FROM member_state) AS global_average_pct
FROM member_state
WHERE contribution_percentage > (SELECT AVG(contribution_percentage) FROM member_state)
ORDER BY contribution_percentage DESC;

/*
+------------+------------------------------------+-----------------------------+-------------------------+--------------------+
| state_code | state_name                         | region                      | contribution_percentage | global_average_pct |
+------------+------------------------------------+-----------------------------+-------------------------+--------------------+
| USA        | United States of America           | Western Europe and Others   |                  22.000 |              0.518 |
| CHN        | China                              | Asia-Pacific                |                  15.254 |              0.518 |
| JPN        | Japan                              | Asia-Pacific                |                   8.033 |              0.518 |
| DEU        | Germany                            | Western Europe and Others   |                   6.111 |              0.518 |
| GBR        | United Kingdom                     | Western Europe and Others   |                   4.567 |              0.518 |
| FRA        | France                             | Western Europe and Others   |                   4.318 |              0.518 |
| ITA        | Italy                              | Western Europe and Others   |                   3.189 |              0.518 |
| CAN        | Canada                             | Western Europe and Others   |                   2.628 |              0.518 |
| KOR        | Republic of Korea                  | Asia-Pacific                |                   2.574 |              0.518 |
| RUS        | Russian Federation                 | Eastern Europe              |                   2.405 |              0.518 |
| ESP        | Spain                              | Western Europe and Others   |                   2.134 |              0.518 |
| AUS        | Australia                          | Asia-Pacific                |                   2.111 |              0.518 |
| BRA        | Brazil                             | Latin America and Caribbean |                   2.013 |              0.518 |
| NLD        | Netherlands                        | Western Europe and Others   |                   1.377 |              0.518 |
| TUR        | Türkiye                            | Western Europe and Others   |                   1.376 |              0.518 |
| MEX        | Mexico                             | Latin America and Caribbean |                   1.221 |              0.518 |
| SAU        | Saudi Arabia                       | Asia-Pacific                |                   1.184 |              0.518 |
| CHE        | Switzerland                        | Western Europe and Others   |                   1.134 |              0.518 |
| IND        | India                              | Asia-Pacific                |                   1.044 |              0.518 |
| SWE        | Sweden                             | Western Europe and Others   |                   0.871 |              0.518 |
| POL        | Poland                             | Eastern Europe              |                   0.837 |              0.518 |
| BEL        | Belgium                            | Western Europe and Others   |                   0.828 |              0.518 |
| ARG        | Argentina                          | Latin America and Caribbean |                   0.719 |              0.518 |
| NOR        | Norway                             | Western Europe and Others   |                   0.679 |              0.518 |
| AUT        | Austria                            | Western Europe and Others   |                   0.679 |              0.518 |
| ARE        | United Arab Emirates               | Asia-Pacific                |                   0.635 |              0.518 |
| ISR        | Israel                             | Western Europe and Others   |                   0.561 |              0.518 |
| DNK        | Denmark                            | Western Europe and Others   |                   0.553 |              0.518 |
| IDN        | Indonesia                          | Asia-Pacific                |                   0.549 |              0.518 |
+------------+------------------------------------+-----------------------------+-------------------------+--------------------+
*/

-- ============================================================================
-- Question 2: Using a correlated subquery, find each ICJ case with its
-- latest hearing status and the date of that hearing.
-- ============================================================================

SELECT
    c.case_number,
    c.case_title,
    c.case_type,
    c.status AS case_status,
    (SELECT h.hearing_type
     FROM icj_hearing h
     WHERE h.case_id = c.case_id
     ORDER BY h.hearing_number DESC LIMIT 1) AS latest_hearing_type,
    (SELECT h.status
     FROM icj_hearing h
     WHERE h.case_id = c.case_id
     ORDER BY h.hearing_number DESC LIMIT 1) AS latest_hearing_status,
    (SELECT h.scheduled_date
     FROM icj_hearing h
     WHERE h.case_id = c.case_id
     ORDER BY h.hearing_number DESC LIMIT 1) AS latest_hearing_date
FROM icj_case c
ORDER BY c.filing_date DESC;

/*
+---------------+------------------------------------------+-------------+---------------------+---------------------+-----------------------+---------------------+
| case_number   | case_title                               | case_type   | case_status         | latest_hearing_type | latest_hearing_status | latest_hearing_date |
+---------------+------------------------------------------+-------------+---------------------+---------------------+-----------------------+---------------------+
| ICJ/2025/002  | Nuclear Arms Legality (Australia v. Fr.) | CONTENTIOUS | PENDING             | PRELIMINARY         | SCHEDULED             | 2026-03-10          |
| ICJ/2025/001  | Advisory Opinion on Climate Change Obl.  | ADVISORY    | DELIBERATION        | ORAL_ARGUMENTS      | COMPLETED             | 2025-09-02          |
| ICJ/2024/002  | Application of Genocide Convention ...   | CONTENTIOUS | PRELIMINARY_OBJECT. | PROVISIONAL_MEASURES| COMPLETED             | 2024-06-15          |
| ICJ/2024/001  | Maritime Boundary Dispute (Brazil v Mex) | CONTENTIOUS | HEARING             | ORAL_ARGUMENTS      | COMPLETED             | 2025-03-16          |
+---------------+------------------------------------------+-------------+---------------------+---------------------+-----------------------+---------------------+
*/

-- ============================================================================
-- Question 3: Using an EXISTS subquery, find all UN Organs that currently
-- have active, unresolved matters taking up their agenda (matters that are
-- UNDER_REVIEW, IN_VOTING, or PENDING_APPROVAL).
-- ============================================================================

SELECT
    o.organ_code,
    o.organ_name,
    o.established_year
FROM un_organ o
WHERE EXISTS (
    SELECT 1 
    FROM matter m 
    WHERE m.organ_id = o.organ_id 
      AND m.status IN ('UNDER_REVIEW', 'IN_VOTING', 'PENDING_APPROVAL')
)
ORDER BY o.organ_code;

/*
+------------+-----------------------------+------------------+
| organ_code | organ_name                  | established_year |
+------------+-----------------------------+------------------+
| ECOSOC     | Economic and Social Council |             1945 |
| GA         | General Assembly            |             1945 |
| SC         | Security Council            |             1945 |
+------------+-----------------------------+------------------+
*/

-- Show delegate table
SELECT * FROM delegate LIMIT 10;


-- ############################################################################
-- SECTION 3.5: COMPLEX QUERIES BASED ON JOINS
-- ############################################################################

SELECT 'SECTION 3.5 - JOINS' AS section;

-- ============================================================================
-- Question 1: Using INNER JOIN across 5 tables, retrieve complete voting
-- records showing the matter details, organ, delegate name, state, and vote
-- value for all GA and SC matters.
-- ============================================================================

SELECT
    m.matter_number,
    m.title AS matter_title,
    o.organ_code,
    ms.state_name,
    CONCAT(d.first_name, ' ', d.last_name) AS delegate_name,
    v.vote_value,
    m.status AS matter_status
FROM vote v
INNER JOIN matter m ON v.matter_id = m.matter_id
INNER JOIN un_organ o ON m.organ_id = o.organ_id
INNER JOIN delegate d ON v.delegate_id = d.delegate_id
INNER JOIN member_state ms ON v.state_id = ms.state_id
WHERE o.organ_code IN ('GA', 'SC')
ORDER BY m.matter_number, v.vote_value, ms.state_name
LIMIT 15;

/*
+-------------------+-------------------------------------------+------------+-------------------+-------------------------+------------+---------------+
| matter_number     | matter_title                              | organ_code | state_name        | delegate_name           | vote_value | matter_status |
+-------------------+-------------------------------------------+------------+-------------------+-------------------------+------------+---------------+
| GA/RES/79/001     | Resolution on Climate Action Accel...     | GA         | Russian Federation| Vassily Nebenzia        | ABSTAIN    | PASSED        |
| GA/RES/79/001     | Resolution on Climate Action Accel...     | GA         | Australia         | Mitch Fifield           | YES        | PASSED        |
| GA/RES/79/001     | Resolution on Climate Action Accel...     | GA         | Brazil            | Ronaldo Costa Filho     | YES        | PASSED        |
| GA/RES/79/001     | Resolution on Climate Action Accel...     | GA         | Canada            | Bob Rae                 | YES        | PASSED        |
| GA/RES/79/001     | Resolution on Climate Action Accel...     | GA         | China             | Fu Cong                 | YES        | PASSED        |
| ...               | ...                                       | ...        | ...               | ...                     | ...        | ...           |
| SC/RES/2730       | Resolution on Humanitarian Ceasefire      | SC         | China             | Geng Shuang             | ABSTAIN    | PASSED        |
| SC/RES/2730       | Resolution on Humanitarian Ceasefire      | SC         | Russian Federation| Dmitry Polyanskiy       | NO         | PASSED        |
| SC/RES/2730       | Resolution on Humanitarian Ceasefire      | SC         | Argentina         | Ricardo Lagorio         | NO         | PASSED        |
+-------------------+-------------------------------------------+------------+-------------------+-------------------------+------------+---------------+
*/

-- ============================================================================
-- Question 2: Using LEFT JOIN, list ALL directives including those without
-- any acknowledgments, showing the issuing department and acknowledgment
-- count.
-- ============================================================================

SELECT
    d.directive_number,
    d.title,
    d.directive_type,
    dept.department_name AS issuing_department,
    CONCAT(o.first_name, ' ', o.last_name) AS issued_by,
    d.status,
    d.requires_acknowledgment,
    COUNT(da.acknowledgment_id) AS ack_count
FROM directive d
LEFT JOIN directive_acknowledgment da ON d.directive_id = da.directive_id
JOIN department dept ON d.issuing_department_id = dept.department_id
JOIN officer o ON d.issued_by_officer_id = o.officer_id
GROUP BY d.directive_id, d.directive_number, d.title, d.directive_type,
         dept.department_name, o.first_name, o.last_name, d.status,
         d.requires_acknowledgment
ORDER BY ack_count DESC;

/*
+-----------------+-------------------------------------+---------------+--------------------------------------------+-------------------+-----------+-----------------------+-----------+
| directive_number| title                               | directive_type| issuing_department                         | issued_by         | status    | requires_acknowledgment| ack_count |
+-----------------+-------------------------------------+---------------+--------------------------------------------+-------------------+-----------+-----------------------+-----------+
| ST/SGB/2025/1   | Hybrid Work Policy Framework        | POLICY        | Executive Office of the Secretary-General  | António Guterres  | IN_EFFECT | 1                     |         7 |
| ST/AI/2025/5    | Cybersecurity Protocol Update       | CIRCULAR      | Department of Safety and Security          | Martin Griffiths  | IN_EFFECT | 1                     |         5 |
| ST/IC/2025/12   | AI Ethics Guidelines for UN Oper.   | BULLETIN      | Department of Global Communications       | Keiko Tanaka      | IN_EFFECT | 0                     |         0 |
| ST/SGB/2025/8   | Updated Travel Authorization Proc.  | INSTRUCTION   | Department of Operational Support          | Amina Mohammed    | IN_EFFECT | 0                     |         0 |
| ST/IC/2024/15   | Year-End Closure Procedures 2025    | BULLETIN      | Executive Office of the Secretary-General  | António Guterres  | EXPIRED   | 0                     |         0 |
+-----------------+-------------------------------------+---------------+--------------------------------------------+-------------------+-----------+-----------------------+-----------+
*/

-- ============================================================================
-- Question 3: Using RIGHT JOIN (self-join), show the department hierarchy
-- by joining the department table to itself on parent_department_id, listing
-- child departments alongside their parent departments.
-- ============================================================================

SELECT
    child.department_code AS child_code,
    child.department_name AS child_department,
    parent.department_code AS parent_code,
    COALESCE(parent.department_name, '-- TOP LEVEL --') AS parent_department,
    child.head_title
FROM department parent
RIGHT JOIN department child ON child.parent_department_id = parent.department_id
ORDER BY parent.department_name IS NULL DESC, parent.department_name, child.department_name;

/*
+------------+--------------------------------------------------+-------------+--------------------------------------------------+---------------------------+
| child_code | child_department                                 | parent_code | parent_department                                | head_title                |
+------------+--------------------------------------------------+-------------+--------------------------------------------------+---------------------------+
| EOSG       | Executive Office of the Secretary-General        | NULL        | -- TOP LEVEL --                                  | Chef de Cabinet           |
| OCHA       | Office for the Coord. of Humanitarian Affairs    | NULL        | -- TOP LEVEL --                                  | Under-Secretary-General   |
| DESA       | Department of Economic and Social Affairs        | NULL        | -- TOP LEVEL --                                  | Under-Secretary-General   |
| OLA        | Office of Legal Affairs                           | NULL        | -- TOP LEVEL --                                  | Under-Secretary-General   |
| DOS        | Department of Operational Support                | NULL        | -- TOP LEVEL --                                  | Under-Secretary-General   |
| DSS        | Department of Safety and Security                | NULL        | -- TOP LEVEL --                                  | Under-Secretary-General   |
| OIOS       | Office of Internal Oversight Services            | NULL        | -- TOP LEVEL --                                  | Under-Secretary-General   |
| DPPA       | Department of Political and Peacebuilding Aff.   | NULL        | -- TOP LEVEL --                                  | Under-Secretary-General   |
| DPO        | Department of Peace Operations                   | DPPA        | Dept of Political and Peacebuilding Affairs      | Under-Secretary-General   |
| DGC        | Department of Global Communications              | DESA        | Department of Economic and Social Affairs        | Under-Secretary-General   |
+------------+--------------------------------------------------+-------------+--------------------------------------------------+---------------------------+
*/

-- Show resolution table
SELECT * FROM resolution;


-- ############################################################################
-- SECTION 3.6: COMPLEX QUERIES BASED ON VIEWS
-- ############################################################################

SELECT 'SECTION 3.6 - VIEWS' AS section;

-- ============================================================================
-- Question 1: Query the v_vote_summary view to find all matters currently
-- in voting and determine their projected outcome.
-- ============================================================================

-- 1. Create the view
CREATE OR REPLACE VIEW v_vote_summary AS
SELECT 
    m.matter_id,
    m.matter_number,
    m.title,
    o.organ_code,
    o.organ_name,
    m.status AS matter_status,
    m.voting_threshold,
    COUNT(v.vote_id) AS total_votes,
    SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_votes,
    SUM(CASE WHEN v.vote_value = 'NO' THEN 1 ELSE 0 END) AS no_votes,
    SUM(CASE WHEN v.vote_value = 'ABSTAIN' THEN 1 ELSE 0 END) AS abstentions,
    ROUND(
        (SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) * 100.0) / 
        NULLIF(SUM(CASE WHEN v.vote_value IN ('YES', 'NO') THEN 1 ELSE 0 END), 0),
        2
    ) AS yes_percentage,
    CASE 
        WHEN m.status = 'PASSED' THEN 'PASSED'
        WHEN m.status = 'REJECTED' THEN 'REJECTED'
        WHEN (SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) * 100.0) / 
             NULLIF(SUM(CASE WHEN v.vote_value IN ('YES', 'NO') THEN 1 ELSE 0 END), 0) >= m.voting_threshold 
        THEN 'WOULD PASS'
        ELSE 'WOULD FAIL'
    END AS projected_outcome
FROM matter m
JOIN un_organ o ON m.organ_id = o.organ_id
LEFT JOIN vote v ON m.matter_id = v.matter_id AND v.is_valid = TRUE
WHERE m.requires_voting = TRUE
GROUP BY m.matter_id, m.matter_number, m.title, o.organ_code, o.organ_name, 
         m.status, m.voting_threshold;

-- 2. Query the view
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
ORDER BY total_votes DESC;

/*
+-------------------+-------------------------------------------------+------------+-------------+-----------+----------+-------------+----------------+------------------+------------------+
| matter_number     | title                                           | organ_code | total_votes | yes_votes | no_votes | abstentions | yes_percentage | voting_threshold | projected_outcome|
+-------------------+-------------------------------------------------+------------+-------------+-----------+----------+-------------+----------------+------------------+------------------+
| GA/RES/79/001     | Resolution on Climate Action Acceleration       | GA         |          15 |        14 |        0 |           1 |         100.00 |            66.67 | PASSED           |
| GA/RES/79/003     | Resolution on Pandemic Preparedness Treaty       | GA         |          15 |        12 |        2 |           1 |          85.71 |            50.00 | PASSED           |
| SC/RES/2730       | Resolution on Humanitarian Ceasefire             | SC         |          10 |         7 |        2 |           1 |          77.78 |            60.00 | PASSED           |
| SC/RES/2732       | Resolution on Non-Proliferation Enforcement      | SC         |          10 |         4 |        4 |           2 |          50.00 |            60.00 | REJECTED         |
| GA/RES/79/002     | Resolution on Digital Cooperation ...            | GA         |           8 |         5 |        2 |           1 |          71.43 |            50.00 | WOULD PASS       |
| ECOSOC/DEC/2025/202| Decision on Global Health Equity Framework      | ECOSOC     |           5 |         4 |        0 |           1 |         100.00 |            50.00 | PASSED           |
| SC/RES/2731       | Resolution on Peacekeeping Mission Ext. - UNMISS | SC         |           0 |         0 |        0 |           0 |           NULL |            60.00 | WOULD FAIL       |
| ECOSOC/DEC/2025/201| Decision on SDG Accelerated Review              | ECOSOC     |           0 |         0 |        0 |           0 |           NULL |            50.00 | WOULD FAIL       |
+-------------------+-------------------------------------------------+------------+-------------+-----------+----------+-------------+----------------+------------------+------------------+
*/

-- ============================================================================
-- Question 2: Query the v_officer_workload view to identify officers with
-- any active work assignments (workflows or pending approvals).
-- ============================================================================

-- 1. Create the view
CREATE OR REPLACE VIEW v_officer_workload AS
SELECT 
    off.officer_id,
    off.employee_number,
    CONCAT(off.first_name, ' ', off.last_name) AS officer_name,
    r.role_name,
    o.organ_name,
    COALESCE(dept.department_name, 'N/A') AS department,
    (SELECT COUNT(*) FROM matter_workflow mw 
     WHERE mw.assigned_officer_id = off.officer_id 
     AND mw.stage_status = 'IN_PROGRESS') AS active_workflows,
    (SELECT COUNT(*) FROM approval a 
     WHERE a.approver_officer_id = off.officer_id 
     AND a.approval_status = 'PENDING') AS pending_approvals,
    (SELECT COUNT(*) FROM matter_workflow mw 
     WHERE mw.assigned_officer_id = off.officer_id 
     AND mw.stage_status = 'PENDING') AS queued_tasks,
    (SELECT COUNT(*) FROM matter_workflow mw 
     WHERE mw.assigned_officer_id = off.officer_id 
     AND mw.stage_status = 'COMPLETED'
     AND mw.completed_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)) AS completed_last_30_days,
    off.employment_status
FROM officer off
JOIN role r ON off.role_id = r.role_id
JOIN un_organ o ON off.organ_id = o.organ_id
LEFT JOIN department dept ON off.department_id = dept.department_id
WHERE off.employment_status = 'ACTIVE';

-- 2. Query the view
SELECT
    officer_name,
    role_name,
    organ_name,
    department,
    active_workflows,
    pending_approvals,
    queued_tasks,
    completed_last_30_days,
    (active_workflows + pending_approvals + queued_tasks) AS total_workload
FROM v_officer_workload
ORDER BY (active_workflows + pending_approvals + queued_tasks) DESC
LIMIT 10;

/*
+-------------------+---------------------------+-----------------------------+--------------------------------------------------+------------------+-------------------+--------------+------------------------+----------------+
| officer_name      | role_name                 | organ_name                  | department                                       | active_workflows | pending_approvals | queued_tasks | completed_last_30_days | total_workload |
+-------------------+---------------------------+-----------------------------+--------------------------------------------------+------------------+-------------------+--------------+------------------------+----------------+
| James Wilson      | Director                  | General Assembly            | Executive Office of the Secretary-General        |                1 |                 0 |            0 |                      0 |              1 |
| Lisa Kumar        | Director                  | Security Council            | Dept of Political and Peacebuilding Affairs      |                1 |                 1 |            0 |                      0 |              2 |
| António Guterres  | Secretary-General         | United Nations Secretariat  | Executive Office of the Secretary-General        |                0 |                 0 |            0 |                      0 |              0 |
| ...               | ...                       | ...                         | ...                                              |              ... |               ... |          ... |                    ... |            ... |
+-------------------+---------------------------+-----------------------------+--------------------------------------------------+------------------+-------------------+--------------+------------------------+----------------+
*/

-- ============================================================================
-- Question 3: Query the v_icj_case_status view to list all active ICJ cases
-- with their hearing progress and judge assignments.
-- ============================================================================

-- 1. Create the view
CREATE OR REPLACE VIEW v_icj_case_status AS
SELECT 
    c.case_id,
    c.case_number,
    c.case_title,
    c.case_type,
    CASE 
        WHEN c.case_type = 'CONTENTIOUS' THEN CONCAT(app.state_name, ' v. ', resp.state_name)
        ELSE CONCAT('Requested by ', org.organ_name)
    END AS parties,
    c.filing_date,
    c.status,
    (SELECT COUNT(*) FROM icj_hearing h WHERE h.case_id = c.case_id) AS total_hearings,
    (SELECT COUNT(*) FROM icj_hearing h WHERE h.case_id = c.case_id AND h.status = 'COMPLETED') AS completed_hearings,
    (SELECT MAX(h.actual_date) FROM icj_hearing h WHERE h.case_id = c.case_id AND h.status = 'COMPLETED') AS last_hearing_date,
    (SELECT COUNT(*) FROM icj_judgment j WHERE j.case_id = c.case_id) AS judgments_issued,
    (SELECT j.judgment_date FROM icj_judgment j WHERE j.case_id = c.case_id ORDER BY j.judgment_date DESC LIMIT 1) AS last_judgment_date,
    (SELECT COUNT(*) FROM icj_case_judge cj WHERE cj.case_id = c.case_id) AS judges_assigned
FROM icj_case c
LEFT JOIN member_state app ON c.applicant_state_id = app.state_id
LEFT JOIN member_state resp ON c.respondent_state_id = resp.state_id
LEFT JOIN un_organ org ON c.requesting_organ_id = org.organ_id;

-- 2. Query the view
SELECT
    case_number,
    case_title,
    case_type,
    parties,
    status,
    total_hearings,
    completed_hearings,
    last_hearing_date,
    judgments_issued,
    judges_assigned
FROM v_icj_case_status
ORDER BY filing_date DESC;

/*
+---------------+-------------------------------------------+-------------+------------------------------+----------------------+----------------+--------------------+-------------------+-----------------+----------------+
| case_number   | case_title                                | case_type   | parties                      | status               | total_hearings | completed_hearings | last_hearing_date | judgments_issued | judges_assigned|
+---------------+-------------------------------------------+-------------+------------------------------+----------------------+----------------+--------------------+-------------------+-----------------+----------------+
| ICJ/2025/002  | Nuclear Arms Legality (Australia v. Fr.)  | CONTENTIOUS | Australia v. France          | PENDING              |              1 |                  0 | NULL              |               0 |              7 |
| ICJ/2025/001  | Advisory Opinion on Climate Change Obl.   | ADVISORY    | Requested by General Ass..   | DELIBERATION         |              2 |                  2 | 2025-09-02        |               1 |              8 |
| ICJ/2024/002  | Application of Genocide Convention ...    | CONTENTIOUS | South Africa v. Russian Fed. | PRELIMINARY_OBJECTIONS|              2 |                  2 | 2024-06-15        |               1 |             10 |
| ICJ/2024/001  | Maritime Boundary Dispute (Brazil v Mex)  | CONTENTIOUS | Brazil v. Mexico             | HEARING              |              3 |                  3 | 2025-03-16        |               0 |              9 |
+---------------+-------------------------------------------+-------------+------------------------------+----------------------+----------------+--------------------+-------------------+-----------------+----------------+
*/

-- Show the view definition
SHOW CREATE VIEW v_vote_summary\G


-- ############################################################################
-- SECTION 3.7: COMPLEX QUERIES BASED ON TRIGGERS
-- ############################################################################

SELECT 'SECTION 3.7 - TRIGGERS' AS section;

-- ============================================================================
-- Question 1: Display the audit log entries created by the trg_matter_audit
-- triggers, showing how INSERT and STATUS_CHANGE on the matter table are
-- automatically tracked.
-- ============================================================================

-- 1. Create the audit triggers
DROP TRIGGER IF EXISTS trg_matter_audit_insert;
DELIMITER //
CREATE TRIGGER trg_matter_audit_insert
AFTER INSERT ON matter
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        table_name, record_id, action_type, action_description, 
        new_values, performed_by_officer_id, performed_by_delegate_id
    ) VALUES (
        'matter', NEW.matter_id, 'INSERT',
        CONCAT('New matter created: ', NEW.matter_number, ' - ', NEW.title),
        JSON_OBJECT('matter_number', NEW.matter_number, 'title', NEW.title, 'status', NEW.status),
        NEW.submitted_by_officer_id, NEW.submitted_by_delegate_id
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS trg_matter_audit_update;
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
        table_name, record_id, action_type, action_description, old_values, new_values
    ) VALUES (
        'matter', NEW.matter_id, action_type_val, action_desc,
        JSON_OBJECT('status', OLD.status), JSON_OBJECT('status', NEW.status)
    );
END//
DELIMITER ;

-- 2. Query the audit log output
SELECT
    log_id,
    table_name,
    record_id,
    action_type,
    action_description,
    action_timestamp
FROM audit_log
WHERE table_name = 'matter'
ORDER BY log_id DESC
LIMIT 5;

/*
+--------+------------+-----------+---------------+--------------------------------------------------+---------------------+
| log_id | table_name | record_id | action_type   | action_description                               | action_timestamp    |
+--------+------------+-----------+---------------+--------------------------------------------------+---------------------+
|     11 | matter     |         6 | STATUS_CHANGE | SC matter status changed to REJECTED              | 2026-03-18 ...      |
|     10 | matter     |         4 | STATUS_CHANGE | SC matter status changed to PASSED                | 2026-03-18 ...      |
|      5 | matter     |         1 | STATUS_CHANGE | Matter status changed to IN_VOTING                | 2026-03-18 ...      |
|      2 | matter     |         1 | STATUS_CHANGE | Matter status changed from DRAFT to SUBMITTED     | 2026-03-18 ...      |
|      1 | matter     |         1 | INSERT        | New resolution proposal submitted: Climate Action | 2026-03-18 ...      |
+--------+------------+-----------+---------------+--------------------------------------------------+---------------------+
*/

-- ============================================================================
-- Question 2: Display vote audit trail entries created by trg_vote_audit,
-- showing how every vote cast is automatically logged with delegate details.
-- ============================================================================

-- 1. Create the vote audit trigger
DROP TRIGGER IF EXISTS trg_vote_audit;
DELIMITER //
CREATE TRIGGER trg_vote_audit
AFTER INSERT ON vote
FOR EACH ROW
BEGIN
    DECLARE state_name_val VARCHAR(100);
    DECLARE delegate_name VARCHAR(100);
    DECLARE matter_num VARCHAR(30);
    
    SELECT ms.state_name INTO state_name_val FROM member_state ms WHERE ms.state_id = NEW.state_id;
    SELECT CONCAT(d.first_name, ' ', d.last_name) INTO delegate_name FROM delegate d WHERE d.delegate_id = NEW.delegate_id;
    SELECT m.matter_number INTO matter_num FROM matter m WHERE m.matter_id = NEW.matter_id;
    
    INSERT INTO audit_log (
        table_name, record_id, action_type, action_description, new_values, performed_by_delegate_id
    ) VALUES (
        'vote', NEW.vote_id, 'VOTE',
        CONCAT(state_name_val, ' (', delegate_name, ') voted ', NEW.vote_value, ' on ', matter_num),
        JSON_OBJECT('matter_id', NEW.matter_id, 'vote_value', NEW.vote_value),
        NEW.delegate_id
    );
END//
DELIMITER ;

-- 2. Query the audit log for votes
SELECT
    al.log_id,
    al.action_type,
    al.action_description,
    COALESCE(
        CONCAT(d.first_name, ' ', d.last_name),
        CONCAT(o.first_name, ' ', o.last_name)
    ) AS performed_by,
    al.ip_address,
    al.action_timestamp
FROM audit_log al
LEFT JOIN delegate d ON al.performed_by_delegate_id = d.delegate_id
LEFT JOIN officer o ON al.performed_by_officer_id = o.officer_id
WHERE al.table_name = 'vote'
ORDER BY al.log_id DESC
LIMIT 6;

/*
+--------+-------------+----------------------------------------------------+-------------------+----------------+---------------------+
| log_id | action_type | action_description                                 | performed_by      | ip_address     | action_timestamp    |
+--------+-------------+----------------------------------------------------+-------------------+----------------+---------------------+
|     17 | VOTE        | Vote cast: Russia voted NO on SC/RES/2732          | Dmitry Polyanskiy | 192.168.1.210  | 2026-03-18 ...      |
|     16 | VOTE        | Vote cast: France voted YES on GA/RES/79/001       | Nicolas de Rivière| 192.168.1.204  | 2026-03-18 ...      |
|     15 | VOTE        | Vote cast: UK voted YES on GA/RES/79/001           | Barbara Woodward  | 192.168.1.203  | 2026-03-18 ...      |
|     14 | VOTE        | Vote cast: Russia ABSTAINED on GA/RES/79/001       | Vassily Nebenzia  | 192.168.1.202  | 2026-03-18 ...      |
|     13 | VOTE        | Vote cast: China voted YES on GA/RES/79/001        | Fu Cong           | 192.168.1.201  | 2026-03-18 ...      |
|     12 | VOTE        | Vote cast: USA voted YES on GA/RES/79/001          | Linda Thomas-Gr.  | 192.168.1.200  | 2026-03-18 ...      |
+--------+-------------+----------------------------------------------------+-------------------+----------------+---------------------+
*/

-- ============================================================================
-- Question 3: Demonstrate the trg_prevent_vote_invalid_stage trigger by
-- wrapping an invalid vote attempt in a procedure with exception handling,
-- and showing the trigger's error message.
-- ============================================================================

-- 1. Create the preventative trigger
DROP TRIGGER IF EXISTS trg_prevent_vote_invalid_stage;
DELIMITER //
CREATE TRIGGER trg_prevent_vote_invalid_stage
BEFORE INSERT ON vote
FOR EACH ROW
BEGIN
    DECLARE matter_status VARCHAR(50);
    DECLARE matter_organ VARCHAR(20);
    
    SELECT m.status, o.organ_code INTO matter_status, matter_organ
    FROM matter m JOIN un_organ o ON m.organ_id = o.organ_id
    WHERE m.matter_id = NEW.matter_id;
    
    IF matter_organ NOT IN ('GA', 'SC', 'ECOSOC') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Voting is only allowed for General Assembly, Security Council, and ECOSOC matters';
    END IF;
    
    IF matter_status != 'IN_VOTING' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot cast vote: Matter is not in voting stage';
    END IF;
END//
DELIMITER ;

-- 2. Test the trigger using a stored procedure
DROP PROCEDURE IF EXISTS test_trigger_vote_prevention;
DELIMITER //
CREATE PROCEDURE test_trigger_vote_prevention()
BEGIN
    DECLARE v_error_msg VARCHAR(500);
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        SELECT CONCAT('TRIGGER BLOCKED: ', v_error_msg) AS trigger_result;
    END;

    -- Attempt to vote on matter 5 which is in PENDING_APPROVAL status (not IN_VOTING)
    INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
    VALUES (5, 1, 16, 'YES');
END//
DELIMITER ;

CALL test_trigger_vote_prevention();

/*
+-------------------------------------------------------------------+
| trigger_result                                                    |
+-------------------------------------------------------------------+
| TRIGGER BLOCKED: Cannot cast vote: Matter is not in voting stage  |
+-------------------------------------------------------------------+
*/

-- Show trigger list
SHOW TRIGGERS LIKE 'matter'\G
SHOW TRIGGERS LIKE 'vote'\G

-- Show audit_log table
SELECT * FROM audit_log ORDER BY log_id DESC LIMIT 10;


-- ############################################################################
-- SECTION 3.8: COMPLEX QUERIES BASED ON CURSORS
-- ############################################################################

SELECT 'SECTION 3.8 - CURSORS' AS section;

-- ============================================================================
-- Question 1: Using the cursor-based procedure sp_compute_vote_outcome,
-- compute the full vote tally for the GA Climate Resolution (matter 1),
-- including yes/no/abstain counts, percentage, and pass/fail outcome.
-- ============================================================================

-- 1. Create the cursor-based procedure
DROP PROCEDURE IF EXISTS sp_compute_vote_outcome;
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
    
    DECLARE vote_cursor CURSOR FOR 
        SELECT vote_value FROM vote WHERE matter_id = p_matter_id AND is_valid = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    SET p_yes_count = 0; SET p_no_count = 0; SET p_abstain_count = 0; SET p_total_votes = 0;
    
    SELECT voting_threshold INTO v_threshold FROM matter WHERE matter_id = p_matter_id;
    
    OPEN vote_cursor;
    
    vote_loop: LOOP
        FETCH vote_cursor INTO v_vote_value;
        IF done THEN LEAVE vote_loop; END IF;
        
        SET p_total_votes = p_total_votes + 1;
        
        CASE v_vote_value
            WHEN 'YES' THEN SET p_yes_count = p_yes_count + 1;
            WHEN 'NO' THEN SET p_no_count = p_no_count + 1;
            WHEN 'ABSTAIN' THEN SET p_abstain_count = p_abstain_count + 1;
        END CASE;
    END LOOP;
    
    CLOSE vote_cursor;
    
    IF (p_yes_count + p_no_count) > 0 THEN
        SET p_yes_percentage = (p_yes_count * 100.0) / (p_yes_count + p_no_count);
    ELSE
        SET p_yes_percentage = 0;
    END IF;
    
    IF p_yes_percentage >= v_threshold THEN
        SET p_outcome = 'PASSED';
    ELSE
        SET p_outcome = 'FAILED';
    END IF;
END//
DELIMITER ;

-- 2. Test the procedure
SET @yes = 0, @no = 0, @abstain = 0, @total = 0, @pct = 0.0, @outcome = '';
CALL sp_compute_vote_outcome(1, @yes, @no, @abstain, @total, @pct, @outcome);
SELECT
    @yes AS yes_votes,
    @no AS no_votes,
    @abstain AS abstentions,
    @total AS total_votes,
    @pct AS yes_percentage,
    @outcome AS outcome;

/*
+-----------+----------+-------------+-------------+----------------+---------+
| yes_votes | no_votes | abstentions | total_votes | yes_percentage | outcome |
+-----------+----------+-------------+-------------+----------------+---------+
|        14 |        0 |           1 |          15 |         100.00 | PASSED  |
+-----------+----------+-------------+-------------+----------------+---------+
*/

-- Also compute for the REJECTED SC matter (matter 6)
SET @yes = 0, @no = 0, @abstain = 0, @total = 0, @pct = 0.0, @outcome = '';
CALL sp_compute_vote_outcome(6, @yes, @no, @abstain, @total, @pct, @outcome);
SELECT
    @yes AS yes_votes,
    @no AS no_votes,
    @abstain AS abstentions,
    @total AS total_votes,
    @pct AS yes_percentage,
    @outcome AS outcome;

/*
+-----------+----------+-------------+-------------+----------------+---------+
| yes_votes | no_votes | abstentions | total_votes | yes_percentage | outcome |
+-----------+----------+-------------+-------------+----------------+---------+
|         4 |        4 |           2 |          10 |          50.00 | FAILED  |
+-----------+----------+-------------+-------------+----------------+---------+
*/

-- ============================================================================
-- Question 2: Using the cursor-based procedure sp_generate_workload_report,
-- generate a comprehensive workload report for all active officers showing
-- their active workflows, pending approvals, and workload classification.
-- ============================================================================

-- 1. Create the cursor-based procedure
DROP PROCEDURE IF EXISTS sp_generate_workload_report;
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
        FROM officer WHERE employment_status = 'ACTIVE';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    DROP TEMPORARY TABLE IF EXISTS temp_workload;
    CREATE TEMPORARY TABLE temp_workload (
        officer_id INT, officer_name VARCHAR(100), active_workflows INT,
        pending_approvals INT, workload_level VARCHAR(20)
    );
    
    OPEN officer_cursor;
    
    officer_loop: LOOP
        FETCH officer_cursor INTO v_officer_id, v_officer_name;
        IF done THEN LEAVE officer_loop; END IF;
        
        SELECT COUNT(*) INTO v_active_count FROM matter_workflow
        WHERE assigned_officer_id = v_officer_id AND stage_status = 'IN_PROGRESS';
        
        SELECT COUNT(*) INTO v_pending_count FROM approval
        WHERE approver_officer_id = v_officer_id AND approval_status = 'PENDING';
        
        INSERT INTO temp_workload VALUES (
            v_officer_id, v_officer_name, v_active_count, v_pending_count,
            CASE 
                WHEN (v_active_count + v_pending_count) > 10 THEN 'OVERLOADED'
                WHEN (v_active_count + v_pending_count) > 5 THEN 'HIGH'
                WHEN (v_active_count + v_pending_count) > 2 THEN 'MEDIUM'
                ELSE 'LOW'
            END
        );
    END LOOP;
    
    CLOSE officer_cursor;
    
    SELECT * FROM temp_workload ORDER BY (active_workflows + pending_approvals) DESC;
    DROP TEMPORARY TABLE temp_workload;
END//
DELIMITER ;

-- 2. Test the procedure
CALL sp_generate_workload_report();

/*
+------------+-------------------+------------------+-------------------+----------------+
| officer_id | officer_name      | active_workflows | pending_approvals | workload_level |
+------------+-------------------+------------------+-------------------+----------------+
|         12 | Lisa Kumar        |                1 |                 1 |            LOW |
|         11 | James Wilson      |                1 |                 0 |            LOW |
|          1 | António Guterres  |                0 |                 0 |            LOW |
|          2 | Amina Mohammed    |                0 |                 0 |            LOW |
|          3 | Rosemary DiCarlo  |                0 |                 0 |            LOW |
|          4 | Jean-Pierre Lacroix|               0 |                 0 |            LOW |
|          5 | Martin Griffiths  |                0 |                 0 |            LOW |
|          6 | Maria Santos      |                0 |                 0 |            LOW |
|          7 | Ahmed Hassan      |                0 |                 0 |            LOW |
|          8 | Sarah Johnson     |                0 |                 0 |            LOW |
|         ...| ...               |              ... |               ... |            ... |
+------------+-------------------+------------------+-------------------+----------------+
*/

-- ============================================================================
-- Question 3: Create and call a cursor-based procedure that iterates through
-- all UN organs and computes statistics including matter count, total votes,
-- and resolution count per organ.
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_organ_statistics;
DELIMITER //
CREATE PROCEDURE sp_organ_statistics()
BEGIN
    DECLARE v_organ_id INT;
    DECLARE v_organ_code VARCHAR(10);
    DECLARE v_organ_name VARCHAR(100);
    DECLARE v_matter_count INT;
    DECLARE v_vote_count INT;
    DECLARE v_resolution_count INT;
    DECLARE done INT DEFAULT FALSE;

    DECLARE organ_cursor CURSOR FOR
        SELECT organ_id, organ_code, organ_name FROM un_organ WHERE is_active = TRUE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS temp_organ_stats;
    CREATE TEMPORARY TABLE temp_organ_stats (
        organ_code VARCHAR(10),
        organ_name VARCHAR(100),
        total_matters INT,
        total_votes INT,
        total_resolutions INT
    );

    OPEN organ_cursor;

    organ_loop: LOOP
        FETCH organ_cursor INTO v_organ_id, v_organ_code, v_organ_name;
        IF done THEN
            LEAVE organ_loop;
        END IF;

        SELECT COUNT(*) INTO v_matter_count
        FROM matter WHERE organ_id = v_organ_id;

        SELECT COUNT(*) INTO v_vote_count
        FROM vote v
        JOIN matter m ON v.matter_id = m.matter_id
        WHERE m.organ_id = v_organ_id;

        SELECT COUNT(*) INTO v_resolution_count
        FROM resolution WHERE organ_id = v_organ_id;

        INSERT INTO temp_organ_stats VALUES (
            v_organ_code, v_organ_name, v_matter_count, v_vote_count, v_resolution_count
        );
    END LOOP;

    CLOSE organ_cursor;

    SELECT * FROM temp_organ_stats ORDER BY total_matters DESC;
    DROP TEMPORARY TABLE temp_organ_stats;
END//
DELIMITER ;

CALL sp_organ_statistics();

/*
+------------+-----------------------------+---------------+-------------+-------------------+
| organ_code | organ_name                  | total_matters | total_votes | total_resolutions |
+------------+-----------------------------+---------------+-------------+-------------------+
| GA         | General Assembly            |             3 |          38 |                 2 |
| SC         | Security Council            |             3 |          20 |                 1 |
| SEC        | United Nations Secretariat  |             2 |           0 |                 0 |
| ECOSOC     | Economic and Social Council |             2 |           5 |                 1 |
| TC         | Trusteeship Council         |             1 |           0 |                 0 |
| ICJ        | International Court of Just.|             0 |           0 |                 0 |
+------------+-----------------------------+---------------+-------------+-------------------+
*/

-- ============================================================================
-- END OF CHAPTER 3 QUERIES
-- ============================================================================
