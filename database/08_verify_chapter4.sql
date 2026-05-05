-- ============================================================================
-- CHAPTER 4 & 5 VERIFICATION SCRIPT
-- Run this to visually verify the outputs for the redesigned report.
-- ============================================================================

USE un_workflow_db;

-- ============================================================
-- CHAPTER 4: NORMALIZATION
-- ============================================================

SELECT '--- 4.1 & 4.2.1 Before 1NF (Simulated UNF View) ---' AS section;
-- We simulate the UNF table format using actual data but aggregating the workflow stages into a comma-separated string.
-- Note: We limit to specific matters and delegates to keep the pedagogical table readable.
SELECT 
    m.matter_id, 
    m.matter_number, 
    m.title, 
    o.organ_code, 
    o.organ_name, 
    d.delegate_code, 
    CONCAT(d.first_name, ' ', d.last_name) AS delegate_name, 
    ms.state_code, 
    ms.region AS state_region, 
    v.vote_value, 
    (SELECT GROUP_CONCAT(stage_name ORDER BY stage_number SEPARATOR ', ') 
     FROM matter_workflow mw WHERE mw.matter_id = m.matter_id AND mw.stage_number IN (1, 4)) AS workflow_stages
FROM matter m
JOIN un_organ o ON m.organ_id = o.organ_id
JOIN vote v ON m.matter_id = v.matter_id
JOIN delegate d ON v.delegate_id = d.delegate_id
JOIN member_state ms ON d.state_id = ms.state_id
WHERE m.matter_id IN (1, 4) AND d.delegate_id IN (1, 2, 16)
ORDER BY m.matter_id, d.delegate_id;

SELECT '--- 4.2.2 After 1NF ---' AS section;
-- 1NF explodes the comma-separated workflow_stages.
SELECT 
    m.matter_id, 
    m.matter_number, 
    m.title, 
    o.organ_code, 
    o.organ_name, 
    d.delegate_code, 
    CONCAT(d.first_name, ' ', d.last_name) AS delegate_name, 
    ms.state_code, 
    ms.region AS state_region, 
    v.vote_value, 
    mw.stage_number, 
    mw.stage_name
FROM matter m
JOIN un_organ o ON m.organ_id = o.organ_id
JOIN vote v ON m.matter_id = v.matter_id
JOIN delegate d ON v.delegate_id = d.delegate_id
JOIN member_state ms ON d.state_id = ms.state_id
JOIN matter_workflow mw ON m.matter_id = mw.matter_id
WHERE m.matter_id IN (1, 4) AND d.delegate_id IN (1, 2, 16) AND mw.stage_number IN (1, 4)
ORDER BY m.matter_id, d.delegate_id, mw.stage_number;

SELECT '--- 4.3.2 After 2NF (Decomposed Tables) ---' AS section;
SELECT '-> Matter Table' as tbl;
SELECT matter_id, matter_number, title, organ_code, organ_name 
FROM matter m JOIN un_organ o ON m.organ_id = o.organ_id 
WHERE matter_id IN (1, 4);

SELECT '-> Delegate Table' as tbl;
SELECT d.delegate_code, CONCAT(d.first_name, ' ', d.last_name) AS delegate_name, ms.state_code, ms.region AS state_region 
FROM delegate d JOIN member_state ms ON d.state_id = ms.state_id 
WHERE d.delegate_id IN (1, 2, 16);

SELECT '-> Vote Table' as tbl;
SELECT matter_id, delegate_code, vote_value 
FROM vote v JOIN delegate d ON v.delegate_id = d.delegate_id 
WHERE matter_id IN (1, 4) AND v.delegate_id IN (1, 2, 16);

SELECT '-> Workflow Table' as tbl;
SELECT matter_id, stage_number, stage_name 
FROM matter_workflow 
WHERE matter_id IN (1, 4) AND stage_number IN (1, 4)
ORDER BY matter_id, stage_number;


SELECT '--- 4.4.2 After 3NF (Transitive Dependencies Removed) ---' AS section;
SELECT '-> Matter Table' as tbl;
SELECT matter_id, matter_number, title, organ_code FROM matter m JOIN un_organ o ON m.organ_id = o.organ_id WHERE matter_id IN (1, 4);

SELECT '-> Organ Table' as tbl;
SELECT organ_code, organ_name FROM un_organ WHERE organ_code IN ('GA', 'SC');

SELECT '-> Delegate Table' as tbl;
SELECT delegate_code, CONCAT(first_name, ' ', last_name) AS delegate_name, state_code 
FROM delegate d JOIN member_state ms ON d.state_id = ms.state_id WHERE delegate_id IN (1, 2, 16);

SELECT '-> State Table' as tbl;
SELECT state_code, region AS state_region FROM member_state WHERE state_code IN ('USA', 'CHN');


SELECT '--- 4.5.1 BCNF (Violation in UN_Session_Vote) ---' AS section;
-- Unnormalized BCNF view: (matter_id, state_id, delegate_id) where delegate_id -> state_id
SELECT v.matter_id, ms.state_id, ms.state_code, d.delegate_id, d.delegate_code, v.vote_value
FROM vote v
JOIN delegate d ON v.delegate_id = d.delegate_id
JOIN member_state ms ON v.state_id = ms.state_id
WHERE v.matter_id = 1 AND d.delegate_id IN (1, 2, 3)
ORDER BY v.matter_id, ms.state_id;


SELECT '--- 4.6.1 4NF (Multivalued MVD Cross-Product) ---' AS section;
-- What happens if we try to track Delegates and Stages in one unnormalized table?
SELECT a.matter_id, a.delegate_code, b.stage_name
FROM (
  SELECT m.matter_id, d.delegate_code FROM vote v JOIN delegate d ON v.delegate_id = d.delegate_id JOIN matter m ON v.matter_id = m.matter_id WHERE m.matter_id = 1 AND d.delegate_id IN (1,2)
) a
JOIN (
  SELECT m.matter_id, mw.stage_name FROM matter_workflow mw JOIN matter m ON mw.matter_id = m.matter_id WHERE m.matter_id = 1 AND mw.stage_number IN (1, 4)
) b ON a.matter_id = b.matter_id
ORDER BY a.delegate_code, b.stage_name;


SELECT '--- 4.7.1 5NF (ICJ Join Dependency) ---' AS section;
-- Showing the Case-Judge-State cyclic relation
SELECT cj.case_id, cj.judge_id, j.nationality_state_id AS state_id
FROM icj_case_judge cj
JOIN icj_judge j ON cj.judge_id = j.judge_id
WHERE cj.case_id = 1 AND cj.judge_id IN (1, 3);
