-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 01_schema.sql - Database Schema (DDL)
-- ============================================================================
-- This script creates the complete database schema for managing UN matters,
-- voting, resolutions, ICJ cases, Secretariat directives, and Trusteeship reports.
-- ============================================================================

-- Drop database if exists and create fresh
DROP DATABASE IF EXISTS un_workflow_db;
CREATE DATABASE un_workflow_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE un_workflow_db;

-- ============================================================================
-- TABLE 1: un_organ
-- Stores the six principal organs of the United Nations
-- ============================================================================
CREATE TABLE un_organ (
    organ_id INT PRIMARY KEY AUTO_INCREMENT,
    organ_code VARCHAR(15) NOT NULL UNIQUE,
    organ_name VARCHAR(100) NOT NULL,
    organ_description TEXT,
    established_year INT NOT NULL,
    headquarters_location VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_organ_code CHECK (organ_code IN ('GA', 'SC', 'ECOSOC', 'ICJ', 'SEC', 'TC'))
);

-- ============================================================================
-- TABLE 2: member_state
-- Stores UN member states
-- ============================================================================
CREATE TABLE member_state (
    state_id INT PRIMARY KEY AUTO_INCREMENT,
    state_code VARCHAR(3) NOT NULL UNIQUE COMMENT 'ISO 3166-1 alpha-3 code',
    state_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    admission_date DATE NOT NULL,
    is_sc_permanent_member BOOLEAN DEFAULT FALSE,
    contribution_percentage DECIMAL(5,3) DEFAULT 0.000,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_region CHECK (region IN ('Africa', 'Asia-Pacific', 'Eastern Europe', 'Latin America and Caribbean', 'Western Europe and Others'))
);

-- ============================================================================
-- TABLE 3: role
-- Defines roles for officers within the UN system
-- ============================================================================
CREATE TABLE role (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_code VARCHAR(20) NOT NULL UNIQUE,
    role_name VARCHAR(100) NOT NULL,
    role_description TEXT,
    permission_level INT NOT NULL DEFAULT 1,
    can_approve BOOLEAN DEFAULT FALSE,
    can_vote BOOLEAN DEFAULT FALSE,
    can_issue_resolution BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_permission_level CHECK (permission_level BETWEEN 1 AND 10)
);

-- ============================================================================
-- TABLE 4: department
-- Secretariat departments
-- ============================================================================
CREATE TABLE department (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_code VARCHAR(20) NOT NULL UNIQUE,
    department_name VARCHAR(150) NOT NULL,
    parent_department_id INT NULL,
    head_title VARCHAR(100),
    established_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_parent_department FOREIGN KEY (parent_department_id) 
        REFERENCES department(department_id) ON DELETE SET NULL
);

-- ============================================================================
-- TABLE 5: officer
-- UN staff members and officials
-- ============================================================================
CREATE TABLE officer (
    officer_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role_id INT NOT NULL,
    department_id INT,
    organ_id INT NOT NULL,
    hire_date DATE NOT NULL,
    employment_status ENUM('ACTIVE', 'ON_LEAVE', 'TERMINATED', 'RETIRED') DEFAULT 'ACTIVE',
    security_clearance_level INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_officer_role FOREIGN KEY (role_id) REFERENCES role(role_id),
    CONSTRAINT fk_officer_department FOREIGN KEY (department_id) REFERENCES department(department_id),
    CONSTRAINT fk_officer_organ FOREIGN KEY (organ_id) REFERENCES un_organ(organ_id),
    CONSTRAINT chk_security_level CHECK (security_clearance_level BETWEEN 1 AND 5)
);

-- ============================================================================
-- TABLE 6: delegate
-- Representatives from member states
-- ============================================================================
CREATE TABLE delegate (
    delegate_id INT PRIMARY KEY AUTO_INCREMENT,
    delegate_code VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    title VARCHAR(50),
    state_id INT NOT NULL,
    organ_id INT NOT NULL,
    credential_date DATE NOT NULL,
    credential_expiry_date DATE,
    is_permanent_representative BOOLEAN DEFAULT FALSE,
    voting_authority BOOLEAN DEFAULT TRUE,
    email VARCHAR(100),
    status ENUM('ACTIVE', 'SUSPENDED', 'EXPIRED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_delegate_state FOREIGN KEY (state_id) REFERENCES member_state(state_id),
    CONSTRAINT fk_delegate_organ FOREIGN KEY (organ_id) REFERENCES un_organ(organ_id)
);

-- ============================================================================
-- TABLE 7: matter
-- Master case files/proposals processed by UN organs
-- ============================================================================
CREATE TABLE matter (
    matter_id INT PRIMARY KEY AUTO_INCREMENT,
    matter_number VARCHAR(30) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    matter_type ENUM('RESOLUTION', 'CASE', 'DIRECTIVE', 'CIRCULAR', 'OVERSIGHT_REPORT', 'DECISION') NOT NULL,
    organ_id INT NOT NULL,
    submitted_by_delegate_id INT,
    submitted_by_officer_id INT,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT', 'CRITICAL') DEFAULT 'MEDIUM',
    status ENUM('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'PENDING_APPROVAL', 'APPROVED', 'IN_VOTING', 'VOTED', 'PASSED', 'REJECTED', 'CLOSED', 'ARCHIVED') DEFAULT 'DRAFT',
    submission_date DATE,
    target_completion_date DATE,
    actual_completion_date DATE,
    session_number VARCHAR(20),
    agenda_item_number VARCHAR(20),
    requires_voting BOOLEAN DEFAULT FALSE,
    voting_threshold DECIMAL(5,2) DEFAULT 50.00 COMMENT 'Percentage required to pass',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_matter_organ FOREIGN KEY (organ_id) REFERENCES un_organ(organ_id),
    CONSTRAINT fk_matter_delegate FOREIGN KEY (submitted_by_delegate_id) REFERENCES delegate(delegate_id),
    CONSTRAINT fk_matter_officer FOREIGN KEY (submitted_by_officer_id) REFERENCES officer(officer_id),
    CONSTRAINT chk_submitter CHECK (
        (submitted_by_delegate_id IS NOT NULL AND submitted_by_officer_id IS NULL) OR
        (submitted_by_delegate_id IS NULL AND submitted_by_officer_id IS NOT NULL)
    )
);

-- ============================================================================
-- TABLE 8: matter_workflow
-- Tracks workflow stages for each matter
-- ============================================================================
CREATE TABLE matter_workflow (
    workflow_id INT PRIMARY KEY AUTO_INCREMENT,
    matter_id INT NOT NULL,
    stage_number INT NOT NULL,
    stage_name VARCHAR(50) NOT NULL,
    stage_status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED', 'FAILED') DEFAULT 'PENDING',
    assigned_officer_id INT,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_workflow_matter FOREIGN KEY (matter_id) REFERENCES matter(matter_id) ON DELETE CASCADE,
    CONSTRAINT fk_workflow_officer FOREIGN KEY (assigned_officer_id) REFERENCES officer(officer_id),
    CONSTRAINT uk_matter_stage UNIQUE (matter_id, stage_number)
);

-- ============================================================================
-- TABLE 9: approval
-- Approval records for matters requiring multi-step approval
-- ============================================================================
CREATE TABLE approval (
    approval_id INT PRIMARY KEY AUTO_INCREMENT,
    matter_id INT NOT NULL,
    approver_officer_id INT NOT NULL,
    approval_level INT NOT NULL DEFAULT 1,
    approval_status ENUM('PENDING', 'APPROVED', 'REJECTED', 'DEFERRED') DEFAULT 'PENDING',
    decision_date TIMESTAMP NULL,
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_approval_matter FOREIGN KEY (matter_id) REFERENCES matter(matter_id) ON DELETE CASCADE,
    CONSTRAINT fk_approval_officer FOREIGN KEY (approver_officer_id) REFERENCES officer(officer_id),
    CONSTRAINT uk_matter_approver UNIQUE (matter_id, approver_officer_id, approval_level)
);

-- ============================================================================
-- TABLE 10: vote
-- Voting records for GA/SC/ECOSOC matters
-- ============================================================================
CREATE TABLE vote (
    vote_id INT PRIMARY KEY AUTO_INCREMENT,
    matter_id INT NOT NULL,
    state_id INT NOT NULL,
    delegate_id INT NOT NULL,
    vote_value ENUM('YES', 'NO', 'ABSTAIN') NOT NULL,
    vote_weight DECIMAL(5,2) DEFAULT 1.00 COMMENT 'For weighted voting systems',
    vote_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT TRUE,
    invalidation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vote_matter FOREIGN KEY (matter_id) REFERENCES matter(matter_id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_state FOREIGN KEY (state_id) REFERENCES member_state(state_id),
    CONSTRAINT fk_vote_delegate FOREIGN KEY (delegate_id) REFERENCES delegate(delegate_id),
    CONSTRAINT uk_matter_state_vote UNIQUE (matter_id, state_id) COMMENT 'One vote per state per matter'
);

-- ============================================================================
-- TABLE 11: resolution
-- Passed resolutions from GA/SC/ECOSOC
-- ============================================================================
CREATE TABLE resolution (
    resolution_id INT PRIMARY KEY AUTO_INCREMENT,
    resolution_number VARCHAR(30) NOT NULL UNIQUE,
    matter_id INT NOT NULL UNIQUE,
    organ_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    preamble TEXT,
    operative_text TEXT NOT NULL,
    adoption_date DATE NOT NULL,
    yes_votes INT NOT NULL DEFAULT 0,
    no_votes INT NOT NULL DEFAULT 0,
    abstentions INT NOT NULL DEFAULT 0,
    is_binding BOOLEAN DEFAULT FALSE,
    implementation_deadline DATE,
    status ENUM('ADOPTED', 'IN_FORCE', 'SUPERSEDED', 'EXPIRED') DEFAULT 'ADOPTED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_resolution_matter FOREIGN KEY (matter_id) REFERENCES matter(matter_id),
    CONSTRAINT fk_resolution_organ FOREIGN KEY (organ_id) REFERENCES un_organ(organ_id)
);

-- ============================================================================
-- TABLE 12: icj_judge
-- Judges of the International Court of Justice
-- ============================================================================
CREATE TABLE icj_judge (
    judge_id INT PRIMARY KEY AUTO_INCREMENT,
    judge_code VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    nationality_state_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    term_end_date DATE NOT NULL,
    is_president BOOLEAN DEFAULT FALSE,
    is_vice_president BOOLEAN DEFAULT FALSE,
    specialization VARCHAR(100),
    status ENUM('ACTIVE', 'RETIRED', 'DECEASED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_judge_nationality FOREIGN KEY (nationality_state_id) REFERENCES member_state(state_id)
);

-- ============================================================================
-- TABLE 13: icj_case
-- Cases before the International Court of Justice
-- ============================================================================
CREATE TABLE icj_case (
    case_id INT PRIMARY KEY AUTO_INCREMENT,
    case_number VARCHAR(30) NOT NULL UNIQUE,
    case_title VARCHAR(255) NOT NULL,
    case_type ENUM('CONTENTIOUS', 'ADVISORY') NOT NULL,
    applicant_state_id INT,
    respondent_state_id INT,
    requesting_organ_id INT COMMENT 'For advisory opinions',
    filing_date DATE NOT NULL,
    subject_matter TEXT NOT NULL,
    status ENUM('PENDING', 'PRELIMINARY_OBJECTIONS', 'MERITS', 'HEARING', 'DELIBERATION', 'JUDGMENT_ISSUED', 'CLOSED') DEFAULT 'PENDING',
    matter_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_icj_applicant FOREIGN KEY (applicant_state_id) REFERENCES member_state(state_id),
    CONSTRAINT fk_icj_respondent FOREIGN KEY (respondent_state_id) REFERENCES member_state(state_id),
    CONSTRAINT fk_icj_requesting_organ FOREIGN KEY (requesting_organ_id) REFERENCES un_organ(organ_id),
    CONSTRAINT fk_icj_matter FOREIGN KEY (matter_id) REFERENCES matter(matter_id)
);

-- ============================================================================
-- TABLE 14: icj_hearing
-- Hearings for ICJ cases
-- ============================================================================
CREATE TABLE icj_hearing (
    hearing_id INT PRIMARY KEY AUTO_INCREMENT,
    case_id INT NOT NULL,
    hearing_number INT NOT NULL,
    hearing_type ENUM('ORAL_ARGUMENTS', 'PRELIMINARY', 'PROVISIONAL_MEASURES', 'JUDGMENT_READING') NOT NULL,
    scheduled_date DATE NOT NULL,
    actual_date DATE,
    start_time TIME,
    end_time TIME,
    location VARCHAR(100) DEFAULT 'Peace Palace, The Hague',
    presiding_judge_id INT,
    status ENUM('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'POSTPONED', 'CANCELLED') DEFAULT 'SCHEDULED',
    transcript_available BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hearing_case FOREIGN KEY (case_id) REFERENCES icj_case(case_id) ON DELETE CASCADE,
    CONSTRAINT fk_hearing_judge FOREIGN KEY (presiding_judge_id) REFERENCES icj_judge(judge_id),
    CONSTRAINT uk_case_hearing UNIQUE (case_id, hearing_number)
);

-- ============================================================================
-- TABLE 15: icj_judgment
-- Judgments issued by the ICJ
-- ============================================================================
CREATE TABLE icj_judgment (
    judgment_id INT PRIMARY KEY AUTO_INCREMENT,
    judgment_number VARCHAR(30) NOT NULL UNIQUE,
    case_id INT NOT NULL,
    judgment_type ENUM('PRELIMINARY_OBJECTIONS', 'MERITS', 'PROVISIONAL_MEASURES', 'ADVISORY_OPINION', 'INTERPRETATION', 'REVISION') NOT NULL,
    judgment_date DATE NOT NULL,
    summary TEXT NOT NULL,
    full_text TEXT,
    votes_in_favor INT NOT NULL,
    votes_against INT NOT NULL,
    is_unanimous BOOLEAN DEFAULT FALSE,
    binding_on_parties BOOLEAN DEFAULT TRUE,
    compliance_status ENUM('PENDING', 'COMPLIED', 'PARTIAL_COMPLIANCE', 'NON_COMPLIANCE', 'NOT_APPLICABLE') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_judgment_case FOREIGN KEY (case_id) REFERENCES icj_case(case_id)
);

-- ============================================================================
-- TABLE 16: icj_case_judge
-- Many-to-many relationship between cases and judges (panel assignment)
-- ============================================================================
CREATE TABLE icj_case_judge (
    case_judge_id INT PRIMARY KEY AUTO_INCREMENT,
    case_id INT NOT NULL,
    judge_id INT NOT NULL,
    is_ad_hoc BOOLEAN DEFAULT FALSE,
    appointed_by_state_id INT COMMENT 'For ad hoc judges',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cj_case FOREIGN KEY (case_id) REFERENCES icj_case(case_id) ON DELETE CASCADE,
    CONSTRAINT fk_cj_judge FOREIGN KEY (judge_id) REFERENCES icj_judge(judge_id),
    CONSTRAINT fk_cj_state FOREIGN KEY (appointed_by_state_id) REFERENCES member_state(state_id),
    CONSTRAINT uk_case_judge UNIQUE (case_id, judge_id)
);

-- ============================================================================
-- TABLE 17: directive
-- Secretariat directives and circulars
-- ============================================================================
CREATE TABLE directive (
    directive_id INT PRIMARY KEY AUTO_INCREMENT,
    directive_number VARCHAR(30) NOT NULL UNIQUE,
    directive_type ENUM('ADMINISTRATIVE', 'POLICY', 'CIRCULAR', 'BULLETIN', 'INSTRUCTION') NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    issuing_department_id INT NOT NULL,
    target_department_id INT COMMENT 'NULL means all departments',
    issued_by_officer_id INT NOT NULL,
    issue_date DATE NOT NULL,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    status ENUM('DRAFT', 'ISSUED', 'IN_EFFECT', 'SUPERSEDED', 'EXPIRED', 'WITHDRAWN') DEFAULT 'DRAFT',
    requires_acknowledgment BOOLEAN DEFAULT FALSE,
    matter_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_directive_issuing_dept FOREIGN KEY (issuing_department_id) REFERENCES department(department_id),
    CONSTRAINT fk_directive_target_dept FOREIGN KEY (target_department_id) REFERENCES department(department_id),
    CONSTRAINT fk_directive_officer FOREIGN KEY (issued_by_officer_id) REFERENCES officer(officer_id),
    CONSTRAINT fk_directive_matter FOREIGN KEY (matter_id) REFERENCES matter(matter_id)
);

-- ============================================================================
-- TABLE 18: directive_acknowledgment
-- Tracks acknowledgments of directives by officers
-- ============================================================================
CREATE TABLE directive_acknowledgment (
    acknowledgment_id INT PRIMARY KEY AUTO_INCREMENT,
    directive_id INT NOT NULL,
    officer_id INT NOT NULL,
    acknowledged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_ack_directive FOREIGN KEY (directive_id) REFERENCES directive(directive_id) ON DELETE CASCADE,
    CONSTRAINT fk_ack_officer FOREIGN KEY (officer_id) REFERENCES officer(officer_id),
    CONSTRAINT uk_directive_officer UNIQUE (directive_id, officer_id)
);

-- ============================================================================
-- TABLE 19: trusteeship_territory
-- Trust territories (historical - Trusteeship Council)
-- ============================================================================
CREATE TABLE trusteeship_territory (
    territory_id INT PRIMARY KEY AUTO_INCREMENT,
    territory_code VARCHAR(10) NOT NULL UNIQUE,
    territory_name VARCHAR(100) NOT NULL,
    administering_state_id INT NOT NULL,
    trust_agreement_date DATE NOT NULL,
    independence_date DATE,
    current_status ENUM('TRUST_TERRITORY', 'INDEPENDENT', 'INTEGRATED', 'FREE_ASSOCIATION') NOT NULL,
    population_at_trust INT,
    area_sq_km DECIMAL(12,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_territory_admin FOREIGN KEY (administering_state_id) REFERENCES member_state(state_id)
);

-- ============================================================================
-- TABLE 20: trusteeship_report
-- Oversight reports from the Trusteeship Council
-- ============================================================================
CREATE TABLE trusteeship_report (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    report_number VARCHAR(30) NOT NULL UNIQUE,
    territory_id INT NOT NULL,
    report_type ENUM('ANNUAL', 'SPECIAL', 'VISITING_MISSION', 'PETITION_REVIEW', 'FINAL') NOT NULL,
    report_year INT NOT NULL,
    reporting_officer_id INT NOT NULL,
    submission_date DATE NOT NULL,
    review_status ENUM('SUBMITTED', 'UNDER_REVIEW', 'REVIEWED', 'DECISION_PENDING', 'CLOSED') DEFAULT 'SUBMITTED',
    findings TEXT,
    recommendations TEXT,
    decision TEXT,
    decision_date DATE,
    matter_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_report_territory FOREIGN KEY (territory_id) REFERENCES trusteeship_territory(territory_id),
    CONSTRAINT fk_report_officer FOREIGN KEY (reporting_officer_id) REFERENCES officer(officer_id),
    CONSTRAINT fk_report_matter FOREIGN KEY (matter_id) REFERENCES matter(matter_id)
);

-- ============================================================================
-- TABLE 21: audit_log
-- System audit trail for accountability
-- ============================================================================
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE', 'STATUS_CHANGE', 'VOTE', 'APPROVAL', 'LOGIN', 'LOGOUT') NOT NULL,
    action_description TEXT NOT NULL,
    old_values JSON,
    new_values JSON,
    performed_by_officer_id INT,
    performed_by_delegate_id INT,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_action_timestamp (action_timestamp),
    INDEX idx_performed_by_officer (performed_by_officer_id),
    CONSTRAINT fk_audit_officer FOREIGN KEY (performed_by_officer_id) REFERENCES officer(officer_id),
    CONSTRAINT fk_audit_delegate FOREIGN KEY (performed_by_delegate_id) REFERENCES delegate(delegate_id)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================
CREATE INDEX idx_matter_status ON matter(status);
CREATE INDEX idx_matter_organ ON matter(organ_id);
CREATE INDEX idx_matter_type ON matter(matter_type);
CREATE INDEX idx_vote_matter ON vote(matter_id);
CREATE INDEX idx_resolution_organ ON resolution(organ_id);
CREATE INDEX idx_icj_case_status ON icj_case(status);
CREATE INDEX idx_directive_status ON directive(status);
CREATE INDEX idx_directive_dept ON directive(issuing_department_id);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
