-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 03_views.sql - Database Views
-- ============================================================================
USE un_workflow_db;

-- ============================================================================
-- VIEW 1: v_matter_overview
-- Comprehensive view of all matters with related information
-- ============================================================================
CREATE OR REPLACE VIEW v_matter_overview AS
SELECT 
    m.matter_id,
    m.matter_number,
    m.title,
    m.description,
    m.matter_type,
    o.organ_code,
    o.organ_name,
    CASE 
        WHEN m.submitted_by_delegate_id IS NOT NULL THEN 
            CONCAT(d.first_name, ' ', d.last_name, ' (', ms.state_name, ')')
        ELSE 
            CONCAT(off.first_name, ' ', off.last_name, ' (', dept.department_name, ')')
    END AS submitted_by,
    m.priority,
    m.status,
    m.submission_date,
    m.target_completion_date,
    m.requires_voting,
    m.voting_threshold,
    m.session_number,
    m.agenda_item_number,
    (SELECT COUNT(*) FROM approval a WHERE a.matter_id = m.matter_id AND a.approval_status = 'APPROVED') AS approvals_count,
    (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) AS votes_cast,
    m.created_at,
    m.updated_at
FROM matter m
JOIN un_organ o ON m.organ_id = o.organ_id
LEFT JOIN delegate d ON m.submitted_by_delegate_id = d.delegate_id
LEFT JOIN member_state ms ON d.state_id = ms.state_id
LEFT JOIN officer off ON m.submitted_by_officer_id = off.officer_id
LEFT JOIN department dept ON off.department_id = dept.department_id;

-- ============================================================================
-- VIEW 2: v_vote_summary
-- Aggregated voting results by matter
-- ============================================================================
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

-- ============================================================================
-- VIEW 3: v_officer_workload
-- Officer workload report showing pending assignments
-- ============================================================================
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

-- ============================================================================
-- VIEW 4: v_icj_case_status
-- ICJ cases with hearing and judgment status
-- ============================================================================
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

-- ============================================================================
-- VIEW 5: v_directive_status
-- Secretariat directives with acknowledgment tracking
-- ============================================================================
CREATE OR REPLACE VIEW v_directive_status AS
SELECT 
    d.directive_id,
    d.directive_number,
    d.directive_type,
    d.title,
    iss_dept.department_name AS issuing_department,
    COALESCE(tgt_dept.department_name, 'All Departments') AS target_department,
    CONCAT(off.first_name, ' ', off.last_name) AS issued_by,
    d.issue_date,
    d.effective_date,
    d.expiry_date,
    d.priority,
    d.status,
    d.requires_acknowledgment,
    (SELECT COUNT(*) FROM directive_acknowledgment da WHERE da.directive_id = d.directive_id) AS acknowledgments_received,
    CASE 
        WHEN d.status = 'EXPIRED' THEN 'EXPIRED'
        WHEN d.expiry_date IS NOT NULL AND d.expiry_date < CURRENT_DATE THEN 'PAST DUE'
        WHEN d.status = 'IN_EFFECT' THEN 'ACTIVE'
        ELSE d.status
    END AS current_status
FROM directive d
JOIN department iss_dept ON d.issuing_department_id = iss_dept.department_id
LEFT JOIN department tgt_dept ON d.target_department_id = tgt_dept.department_id
JOIN officer off ON d.issued_by_officer_id = off.officer_id;

-- ============================================================================
-- VIEW 6: v_resolution_registry
-- Complete resolution registry
-- ============================================================================
CREATE OR REPLACE VIEW v_resolution_registry AS
SELECT 
    r.resolution_id,
    r.resolution_number,
    r.title,
    o.organ_code,
    o.organ_name,
    m.matter_number AS source_matter,
    r.adoption_date,
    r.yes_votes,
    r.no_votes,
    r.abstentions,
    (r.yes_votes + r.no_votes + r.abstentions) AS total_votes,
    ROUND((r.yes_votes * 100.0) / NULLIF((r.yes_votes + r.no_votes), 0), 2) AS approval_percentage,
    r.is_binding,
    r.implementation_deadline,
    r.status,
    DATEDIFF(r.implementation_deadline, CURRENT_DATE) AS days_to_deadline
FROM resolution r
JOIN un_organ o ON r.organ_id = o.organ_id
JOIN matter m ON r.matter_id = m.matter_id;

-- ============================================================================
-- VIEW 7: v_trusteeship_summary
-- Trusteeship territory status (historical)
-- ============================================================================
CREATE OR REPLACE VIEW v_trusteeship_summary AS
SELECT 
    t.territory_id,
    t.territory_code,
    t.territory_name,
    ms.state_name AS administering_authority,
    t.trust_agreement_date,
    t.independence_date,
    t.current_status,
    t.population_at_trust,
    t.area_sq_km,
    (SELECT COUNT(*) FROM trusteeship_report tr WHERE tr.territory_id = t.territory_id) AS total_reports,
    (SELECT MAX(tr.report_year) FROM trusteeship_report tr WHERE tr.territory_id = t.territory_id) AS last_report_year,
    CASE 
        WHEN t.current_status = 'INDEPENDENT' THEN 
            CONCAT('Independent since ', DATE_FORMAT(t.independence_date, '%Y'))
        WHEN t.current_status = 'FREE_ASSOCIATION' THEN 
            CONCAT('Free association since ', DATE_FORMAT(t.independence_date, '%Y'))
        ELSE t.current_status
    END AS status_description
FROM trusteeship_territory t
JOIN member_state ms ON t.administering_state_id = ms.state_id;

-- ============================================================================
-- VIEW 8: v_audit_trail
-- Formatted audit log for reports
-- ============================================================================
CREATE OR REPLACE VIEW v_audit_trail AS
SELECT 
    al.log_id,
    al.table_name,
    al.record_id,
    al.action_type,
    al.action_description,
    CASE 
        WHEN al.performed_by_officer_id IS NOT NULL THEN 
            CONCAT(off.first_name, ' ', off.last_name, ' (Officer)')
        WHEN al.performed_by_delegate_id IS NOT NULL THEN 
            CONCAT(del.first_name, ' ', del.last_name, ' (Delegate - ', ms.state_name, ')')
        ELSE 'System'
    END AS performed_by,
    al.ip_address,
    al.action_timestamp,
    DATE(al.action_timestamp) AS action_date,
    TIME(al.action_timestamp) AS action_time
FROM audit_log al
LEFT JOIN officer off ON al.performed_by_officer_id = off.officer_id
LEFT JOIN delegate del ON al.performed_by_delegate_id = del.delegate_id
LEFT JOIN member_state ms ON del.state_id = ms.state_id
ORDER BY al.action_timestamp DESC;

-- ============================================================================
-- END OF VIEWS
-- ============================================================================
