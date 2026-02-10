-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 02_seed.sql - Sample Data (DML)
-- ============================================================================
USE un_workflow_db;

-- ============================================================================
-- UN ORGANS (The 6 Principal Organs)
-- ============================================================================
INSERT INTO un_organ (organ_code, organ_name, organ_description, established_year, headquarters_location) VALUES
('GA', 'General Assembly', 'The main deliberative, policymaking, and representative organ of the UN. All 193 Member States have equal representation.', 1945, 'New York, USA'),
('SC', 'Security Council', 'Primary responsibility for the maintenance of international peace and security. Has 15 members including 5 permanent members with veto power.', 1945, 'New York, USA'),
('ECOSOC', 'Economic and Social Council', 'Principal body for coordination, policy review, policy dialogue, and recommendations on economic, social, and environmental issues.', 1945, 'New York, USA'),
('ICJ', 'International Court of Justice', 'The principal judicial organ of the United Nations. Settles legal disputes between States and gives advisory opinions.', 1945, 'The Hague, Netherlands'),
('SEC', 'United Nations Secretariat', 'Carries out the day-to-day work of the Organization. Headed by the Secretary-General.', 1945, 'New York, USA'),
('TC', 'Trusteeship Council', 'Established to provide international supervision for Trust Territories. Suspended operations in 1994 after Palau independence.', 1945, 'New York, USA');

-- ============================================================================
-- MEMBER STATES (Sample of 15 key member states)
-- ============================================================================
INSERT INTO member_state (state_code, state_name, region, admission_date, is_sc_permanent_member, contribution_percentage) VALUES
('USA', 'United States of America', 'Western Europe and Others', '1945-10-24', TRUE, 22.000),
('CHN', 'China', 'Asia-Pacific', '1945-10-24', TRUE, 15.254),
('RUS', 'Russian Federation', 'Eastern Europe', '1945-10-24', TRUE, 2.405),
('GBR', 'United Kingdom', 'Western Europe and Others', '1945-10-24', TRUE, 4.567),
('FRA', 'France', 'Western Europe and Others', '1945-10-24', TRUE, 4.318),
('DEU', 'Germany', 'Western Europe and Others', '1973-09-18', FALSE, 6.111),
('JPN', 'Japan', 'Asia-Pacific', '1956-12-18', FALSE, 8.033),
('IND', 'India', 'Asia-Pacific', '1945-10-30', FALSE, 1.044),
('BRA', 'Brazil', 'Latin America and Caribbean', '1945-10-24', FALSE, 2.013),
('NGA', 'Nigeria', 'Africa', '1960-10-07', FALSE, 0.182),
('ZAF', 'South Africa', 'Africa', '1945-11-07', FALSE, 0.244),
('EGY', 'Egypt', 'Africa', '1945-10-24', FALSE, 0.139),
('MEX', 'Mexico', 'Latin America and Caribbean', '1945-11-07', FALSE, 1.221),
('AUS', 'Australia', 'Asia-Pacific', '1945-11-01', FALSE, 2.111),
('CAN', 'Canada', 'Western Europe and Others', '1945-11-09', FALSE, 2.628);

-- ============================================================================
-- ROLES
-- ============================================================================
INSERT INTO role (role_code, role_name, role_description, permission_level, can_approve, can_vote, can_issue_resolution) VALUES
('SG', 'Secretary-General', 'Chief administrative officer of the United Nations', 10, TRUE, FALSE, TRUE),
('DSG', 'Deputy Secretary-General', 'Assists the Secretary-General in managing Secretariat operations', 9, TRUE, FALSE, TRUE),
('USG', 'Under-Secretary-General', 'Heads major departments and offices', 8, TRUE, FALSE, TRUE),
('ASG', 'Assistant Secretary-General', 'Assists Under-Secretaries-General', 7, TRUE, FALSE, FALSE),
('DIR', 'Director', 'Manages divisions within departments', 6, TRUE, FALSE, FALSE),
('CHIEF', 'Chief of Section', 'Manages sections within divisions', 5, TRUE, FALSE, FALSE),
('OFFICER', 'Programme Officer', 'Professional staff handling substantive work', 4, FALSE, FALSE, FALSE),
('ANALYST', 'Research Analyst', 'Conducts research and analysis', 3, FALSE, FALSE, FALSE),
('ADMIN', 'Administrative Officer', 'Handles administrative functions', 3, FALSE, FALSE, FALSE),
('CLERK', 'Clerk', 'Provides clerical support', 2, FALSE, FALSE, FALSE),
('JUDGE', 'ICJ Judge', 'Member of the International Court of Justice', 10, FALSE, FALSE, FALSE),
('REGISTRAR', 'ICJ Registrar', 'Chief administrative officer of the ICJ', 8, TRUE, FALSE, FALSE);

-- ============================================================================
-- DEPARTMENTS (Secretariat)
-- ============================================================================
INSERT INTO department (department_code, department_name, head_title, established_date, parent_department_id) VALUES
('EOSG', 'Executive Office of the Secretary-General', 'Chef de Cabinet', '1945-10-24', NULL),
('DPPA', 'Department of Political and Peacebuilding Affairs', 'Under-Secretary-General', '2019-01-01', NULL),
('DPO', 'Department of Peace Operations', 'Under-Secretary-General', '2019-01-01', NULL),
('OCHA', 'Office for the Coordination of Humanitarian Affairs', 'Under-Secretary-General', '1991-12-19', NULL),
('DESA', 'Department of Economic and Social Affairs', 'Under-Secretary-General', '1997-01-01', NULL),
('OLA', 'Office of Legal Affairs', 'Under-Secretary-General', '1946-01-01', NULL),
('DGC', 'Department of Global Communications', 'Under-Secretary-General', '2019-01-01', NULL),
('DOS', 'Department of Operational Support', 'Under-Secretary-General', '2019-01-01', NULL),
('DSS', 'Department of Safety and Security', 'Under-Secretary-General', '2005-01-01', NULL),
('OIOS', 'Office of Internal Oversight Services', 'Under-Secretary-General', '1994-07-29', NULL);

-- ============================================================================
-- OFFICERS
-- ============================================================================
INSERT INTO officer (employee_number, first_name, last_name, email, role_id, department_id, organ_id, hire_date, employment_status, security_clearance_level) VALUES
('UN-SG-001', 'António', 'Guterres', 'sg@un.org', 1, 1, 5, '2017-01-01', 'ACTIVE', 5),
('UN-DSG-001', 'Amina', 'Mohammed', 'dsg@un.org', 2, 1, 5, '2017-01-01', 'ACTIVE', 5),
('UN-USG-001', 'Rosemary', 'DiCarlo', 'rdicarlo@un.org', 3, 2, 5, '2018-05-01', 'ACTIVE', 4),
('UN-USG-002', 'Jean-Pierre', 'Lacroix', 'jplacroix@un.org', 3, 3, 5, '2017-04-01', 'ACTIVE', 4),
('UN-USG-003', 'Martin', 'Griffiths', 'mgriffiths@un.org', 3, 4, 5, '2021-06-01', 'ACTIVE', 4),
('UN-DIR-001', 'Maria', 'Santos', 'msantos@un.org', 5, 2, 5, '2015-03-15', 'ACTIVE', 3),
('UN-DIR-002', 'Ahmed', 'Hassan', 'ahassan@un.org', 5, 5, 5, '2012-07-20', 'ACTIVE', 3),
('UN-OFF-001', 'Sarah', 'Johnson', 'sjohnson@un.org', 7, 2, 5, '2018-09-01', 'ACTIVE', 2),
('UN-OFF-002', 'Michael', 'Chen', 'mchen@un.org', 7, 5, 5, '2019-02-15', 'ACTIVE', 2),
('UN-OFF-003', 'Elena', 'Petrova', 'epetrova@un.org', 7, 6, 5, '2017-06-01', 'ACTIVE', 2),
('UN-GA-001', 'James', 'Wilson', 'jwilson@un.org', 5, 1, 1, '2016-01-10', 'ACTIVE', 3),
('UN-SC-001', 'Lisa', 'Kumar', 'lkumar@un.org', 5, 2, 2, '2014-08-25', 'ACTIVE', 4),
('UN-EC-001', 'Robert', 'Okafor', 'rokafor@un.org', 5, 5, 3, '2013-11-30', 'ACTIVE', 3),
('UN-TC-001', 'Patricia', 'Mendez', 'pmendez@un.org', 5, 1, 6, '2010-05-12', 'ACTIVE', 3),
('UN-REG-001', 'Philippe', 'Gautier', 'pgautier@icj.org', 12, NULL, 4, '2019-08-01', 'ACTIVE', 4);

-- ============================================================================
-- DELEGATES
-- ============================================================================
INSERT INTO delegate (delegate_code, first_name, last_name, title, state_id, organ_id, credential_date, credential_expiry_date, is_permanent_representative, voting_authority) VALUES
('DEL-USA-GA', 'Linda', 'Thomas-Greenfield', 'Ambassador', 1, 1, '2021-02-25', '2026-02-25', TRUE, TRUE),
('DEL-CHN-GA', 'Zhang', 'Jun', 'Ambassador', 2, 1, '2019-07-28', '2024-07-28', TRUE, TRUE),
('DEL-RUS-GA', 'Vassily', 'Nebenzia', 'Ambassador', 3, 1, '2017-07-26', '2025-07-26', TRUE, TRUE),
('DEL-GBR-GA', 'Barbara', 'Woodward', 'Ambassador', 4, 1, '2020-09-14', '2025-09-14', TRUE, TRUE),
('DEL-FRA-GA', 'Nicolas', 'de Rivière', 'Ambassador', 5, 1, '2019-09-02', '2024-09-02', TRUE, TRUE),
('DEL-DEU-GA', 'Antje', 'Leendertse', 'Ambassador', 6, 1, '2022-03-01', '2027-03-01', TRUE, TRUE),
('DEL-JPN-GA', 'Ishikane', 'Kimihiro', 'Ambassador', 7, 1, '2022-09-01', '2027-09-01', TRUE, TRUE),
('DEL-IND-GA', 'Ruchira', 'Kamboj', 'Ambassador', 8, 1, '2022-06-01', '2027-06-01', TRUE, TRUE),
('DEL-BRA-GA', 'Ronaldo', 'Costa Filho', 'Ambassador', 9, 1, '2023-01-15', '2028-01-15', TRUE, TRUE),
('DEL-NGA-GA', 'Tijjani', 'Muhammad-Bande', 'Ambassador', 10, 1, '2019-09-17', '2024-09-17', TRUE, TRUE),
('DEL-ZAF-GA', 'Mathu', 'Joyini', 'Ambassador', 11, 1, '2020-01-20', '2025-01-20', TRUE, TRUE),
('DEL-EGY-GA', 'Osama', 'Abdelkhalek', 'Ambassador', 12, 1, '2021-08-01', '2026-08-01', TRUE, TRUE),
('DEL-MEX-GA', 'Juan', 'Ramón de la Fuente', 'Ambassador', 13, 1, '2019-02-01', '2024-02-01', TRUE, TRUE),
('DEL-AUS-GA', 'Mitch', 'Fifield', 'Ambassador', 14, 1, '2022-06-15', '2027-06-15', TRUE, TRUE),
('DEL-CAN-GA', 'Bob', 'Rae', 'Ambassador', 15, 1, '2020-07-06', '2025-07-06', TRUE, TRUE);

-- ============================================================================
-- MATTERS (Sample proposals and cases)
-- ============================================================================
INSERT INTO matter (matter_number, title, description, matter_type, organ_id, submitted_by_delegate_id, priority, status, submission_date, session_number, agenda_item_number, requires_voting, voting_threshold) VALUES
('GA/RES/78/001', 'Resolution on Climate Action Acceleration', 'Calls upon all Member States to accelerate efforts to combat climate change and implement the Paris Agreement goals.', 'RESOLUTION', 1, 1, 'HIGH', 'PASSED', '2024-09-15', '78', '12', TRUE, 66.67),
('GA/RES/78/002', 'Resolution on Digital Cooperation', 'Promotes international cooperation on digital technology governance and bridging the digital divide.', 'RESOLUTION', 1, 6, 'MEDIUM', 'IN_VOTING', '2024-10-01', '78', '23', TRUE, 50.00),
('SC/RES/2712', 'Resolution on Humanitarian Pause', 'Calls for humanitarian pauses and corridors throughout conflict zones.', 'RESOLUTION', 2, 1, 'CRITICAL', 'PASSED', '2024-11-15', NULL, NULL, TRUE, 60.00),
('SC/RES/2713', 'Resolution on Peacekeeping Mission Extension', 'Extends the mandate of peacekeeping operations in designated regions.', 'RESOLUTION', 2, 4, 'HIGH', 'PENDING_APPROVAL', '2024-12-01', NULL, NULL, TRUE, 60.00),
('ECOSOC/DEC/2024/201', 'Decision on Sustainable Development Goals Review', 'Reviews progress on SDGs and recommends accelerated action.', 'DECISION', 3, 8, 'HIGH', 'UNDER_REVIEW', '2024-07-10', '2024', '5', TRUE, 50.00);

INSERT INTO matter (matter_number, title, description, matter_type, organ_id, submitted_by_officer_id, priority, status, submission_date, requires_voting) VALUES
('ST/SGB/2024/01', 'Staff Regulations Amendment', 'Amendments to the Staff Regulations concerning remote work policies.', 'DIRECTIVE', 5, 1, 'MEDIUM', 'APPROVED', '2024-03-01', FALSE),
('ST/AI/2024/05', 'Administrative Instruction on Travel', 'Updated procedures for official travel authorization and reimbursement.', 'CIRCULAR', 5, 2, 'LOW', 'APPROVED', '2024-04-15', FALSE),
('TC/REP/2024/01', 'Final Oversight Report - Historical Review', 'Comprehensive historical review of trusteeship system achievements.', 'OVERSIGHT_REPORT', 6, 14, 'MEDIUM', 'CLOSED', '2024-01-15', FALSE);

-- ============================================================================
-- MATTER WORKFLOW
-- ============================================================================
INSERT INTO matter_workflow (matter_id, stage_number, stage_name, stage_status, assigned_officer_id, started_at, completed_at) VALUES
(1, 1, 'SUBMISSION', 'COMPLETED', 11, '2024-09-15 09:00:00', '2024-09-15 09:30:00'),
(1, 2, 'INITIAL_REVIEW', 'COMPLETED', 11, '2024-09-15 10:00:00', '2024-09-16 14:00:00'),
(1, 3, 'COMMITTEE_REVIEW', 'COMPLETED', 11, '2024-09-17 09:00:00', '2024-09-25 17:00:00'),
(1, 4, 'APPROVAL', 'COMPLETED', 1, '2024-09-26 09:00:00', '2024-09-26 12:00:00'),
(1, 5, 'VOTING', 'COMPLETED', 11, '2024-09-27 10:00:00', '2024-09-27 18:00:00'),
(1, 6, 'RESOLUTION_ISSUANCE', 'COMPLETED', 11, '2024-09-28 09:00:00', '2024-09-28 10:00:00'),
(2, 1, 'SUBMISSION', 'COMPLETED', 11, '2024-10-01 09:00:00', '2024-10-01 09:30:00'),
(2, 2, 'INITIAL_REVIEW', 'COMPLETED', 11, '2024-10-01 10:00:00', '2024-10-03 14:00:00'),
(2, 3, 'COMMITTEE_REVIEW', 'COMPLETED', 11, '2024-10-04 09:00:00', '2024-10-15 17:00:00'),
(2, 4, 'APPROVAL', 'COMPLETED', 1, '2024-10-16 09:00:00', '2024-10-16 12:00:00'),
(2, 5, 'VOTING', 'IN_PROGRESS', 11, '2024-10-20 10:00:00', NULL);

-- ============================================================================
-- APPROVALS
-- ============================================================================
INSERT INTO approval (matter_id, approver_officer_id, approval_level, approval_status, decision_date, comments) VALUES
(1, 6, 1, 'APPROVED', '2024-09-20 14:00:00', 'Initial review completed. Forwarding to committee.'),
(1, 3, 2, 'APPROVED', '2024-09-25 16:00:00', 'Committee review favorable. Recommend for voting.'),
(1, 1, 3, 'APPROVED', '2024-09-26 12:00:00', 'Approved for General Assembly vote.'),
(2, 6, 1, 'APPROVED', '2024-10-05 10:00:00', 'Substantive review completed.'),
(2, 3, 2, 'APPROVED', '2024-10-15 15:00:00', 'Committee endorses with minor amendments.'),
(2, 1, 3, 'APPROVED', '2024-10-16 12:00:00', 'Proceed to voting phase.'),
(3, 12, 1, 'APPROVED', '2024-11-10 09:00:00', 'Urgent humanitarian matter. Fast-track approved.'),
(3, 1, 2, 'APPROVED', '2024-11-12 11:00:00', 'Secretary-General endorsement for immediate action.'),
(4, 12, 1, 'PENDING', NULL, 'Under review by Security Council Affairs.');

-- ============================================================================
-- VOTES (Sample voting records)
-- ============================================================================
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES
-- GA/RES/78/001 Voting (Climate Action - PASSED)
(1, 1, 1, 'YES'),
(1, 2, 2, 'YES'),
(1, 3, 3, 'ABSTAIN'),
(1, 4, 4, 'YES'),
(1, 5, 5, 'YES'),
(1, 6, 6, 'YES'),
(1, 7, 7, 'YES'),
(1, 8, 8, 'YES'),
(1, 9, 9, 'YES'),
(1, 10, 10, 'YES'),
(1, 11, 11, 'YES'),
(1, 12, 12, 'YES'),
(1, 13, 13, 'YES'),
(1, 14, 14, 'YES'),
(1, 15, 15, 'YES'),
-- GA/RES/78/002 Voting (Digital Cooperation - IN PROGRESS)
(2, 1, 1, 'YES'),
(2, 4, 4, 'YES'),
(2, 5, 5, 'YES'),
(2, 6, 6, 'YES'),
(2, 7, 7, 'YES'),
-- SC/RES/2712 Voting (Humanitarian - PASSED)
(3, 1, 1, 'YES'),
(3, 2, 2, 'ABSTAIN'),
(3, 3, 3, 'ABSTAIN'),
(3, 4, 4, 'YES'),
(3, 5, 5, 'YES');

-- ============================================================================
-- RESOLUTIONS
-- ============================================================================
INSERT INTO resolution (resolution_number, matter_id, organ_id, title, preamble, operative_text, adoption_date, yes_votes, no_votes, abstentions, is_binding, status) VALUES
('A/RES/78/1', 1, 1, 'Climate Action Acceleration', 
'The General Assembly,\n\nRecalling the Paris Agreement and its goals,\nDeeply concerned by the accelerating impacts of climate change,\nRecognizing the need for urgent and ambitious action,',
'1. Calls upon all Member States to enhance their nationally determined contributions;\n2. Urges developed countries to fulfill climate finance commitments;\n3. Encourages technology transfer for climate adaptation;\n4. Requests the Secretary-General to report on implementation progress.',
'2024-09-28', 14, 0, 1, FALSE, 'IN_FORCE'),
('S/RES/2712', 3, 2, 'Humanitarian Pause in Conflict Zones',
'The Security Council,\n\nGravely concerned by the humanitarian situation,\nReaffirming its commitment to international humanitarian law,',
'1. Calls for immediate humanitarian pauses;\n2. Demands safe passage for humanitarian aid;\n3. Urges all parties to protect civilians;\n4. Decides to remain actively seized of the matter.',
'2024-11-15', 13, 0, 2, TRUE, 'IN_FORCE');

-- ============================================================================
-- ICJ JUDGES
-- ============================================================================
INSERT INTO icj_judge (judge_code, first_name, last_name, nationality_state_id, appointment_date, term_end_date, is_president, is_vice_president, specialization) VALUES
('ICJ-J-001', 'Joan', 'Donoghue', 1, '2010-09-06', '2024-02-05', FALSE, FALSE, 'International Law'),
('ICJ-J-002', 'Kirill', 'Gevorgian', 3, '2015-02-06', '2024-02-05', FALSE, FALSE, 'Maritime Law'),
('ICJ-J-003', 'Julia', 'Sebutinde', 10, '2012-02-06', '2030-02-05', FALSE, FALSE, 'Criminal Law'),
('ICJ-J-004', 'Dalveer', 'Bhandari', 8, '2012-11-27', '2027-02-05', FALSE, FALSE, 'Constitutional Law'),
('ICJ-J-005', 'Nawaf', 'Salam', 12, '2018-02-06', '2027-02-05', TRUE, FALSE, 'Human Rights Law'),
('ICJ-J-006', 'Yuji', 'Iwasawa', 7, '2018-02-06', '2027-02-05', FALSE, FALSE, 'Trade Law'),
('ICJ-J-007', 'Xue', 'Hanqin', 2, '2010-06-29', '2030-02-05', FALSE, TRUE, 'Treaty Law'),
('ICJ-J-008', 'Peter', 'Tomka', 3, '2003-02-06', '2030-02-05', FALSE, FALSE, 'State Responsibility'),
('ICJ-J-009', 'Mohamed', 'Bennouna', 12, '2006-02-06', '2024-02-05', FALSE, FALSE, 'Use of Force'),
('ICJ-J-010', 'Hilary', 'Charlesworth', 14, '2021-02-06', '2030-02-05', FALSE, FALSE, 'Human Rights');

-- ============================================================================
-- ICJ CASES
-- ============================================================================
INSERT INTO icj_case (case_number, case_title, case_type, applicant_state_id, respondent_state_id, filing_date, subject_matter, status) VALUES
('ICJ/2024/001', 'Maritime Boundary Dispute (Country A v. Country B)', 'CONTENTIOUS', 9, 13, '2024-03-15', 'Dispute concerning the delimitation of maritime boundaries in the South Atlantic region.', 'HEARING'),
('ICJ/2024/002', 'Application of Genocide Convention', 'CONTENTIOUS', 11, 3, '2024-01-10', 'Allegations concerning violations of obligations under the Convention on the Prevention and Punishment of Genocide.', 'PRELIMINARY_OBJECTIONS'),
('ICJ/2023/005', 'Advisory Opinion on Climate Obligations', 'ADVISORY', NULL, NULL, '2023-12-01', 'Request for advisory opinion on the obligations of States with respect to climate change.', 'DELIBERATION');

-- Update ICJ cases with requesting organ for advisory opinion
UPDATE icj_case SET requesting_organ_id = 1 WHERE case_number = 'ICJ/2023/005';

-- ============================================================================
-- ICJ CASE-JUDGE ASSIGNMENTS
-- ============================================================================
INSERT INTO icj_case_judge (case_id, judge_id, is_ad_hoc) VALUES
(1, 1, FALSE), (1, 3, FALSE), (1, 4, FALSE), (1, 5, FALSE), (1, 6, FALSE),
(1, 7, FALSE), (1, 8, FALSE), (1, 9, FALSE), (1, 10, FALSE),
(2, 1, FALSE), (2, 2, FALSE), (2, 3, FALSE), (2, 4, FALSE), (2, 5, FALSE),
(2, 6, FALSE), (2, 7, FALSE), (2, 8, FALSE), (2, 9, FALSE), (2, 10, FALSE),
(3, 1, FALSE), (3, 3, FALSE), (3, 4, FALSE), (3, 5, FALSE), (3, 6, FALSE),
(3, 7, FALSE), (3, 8, FALSE), (3, 10, FALSE);

-- ============================================================================
-- ICJ HEARINGS
-- ============================================================================
INSERT INTO icj_hearing (case_id, hearing_number, hearing_type, scheduled_date, actual_date, start_time, end_time, presiding_judge_id, status, transcript_available) VALUES
(1, 1, 'PRELIMINARY', '2024-05-10', '2024-05-10', '10:00:00', '13:00:00', 5, 'COMPLETED', TRUE),
(1, 2, 'ORAL_ARGUMENTS', '2024-09-15', '2024-09-15', '10:00:00', '17:00:00', 5, 'COMPLETED', TRUE),
(1, 3, 'ORAL_ARGUMENTS', '2024-09-16', '2024-09-16', '10:00:00', '17:00:00', 5, 'COMPLETED', TRUE),
(2, 1, 'PRELIMINARY', '2024-04-20', '2024-04-20', '10:00:00', '12:00:00', 5, 'COMPLETED', TRUE),
(2, 2, 'PROVISIONAL_MEASURES', '2024-06-15', '2024-06-15', '10:00:00', '16:00:00', 5, 'COMPLETED', TRUE),
(3, 1, 'ORAL_ARGUMENTS', '2024-08-01', '2024-08-01', '10:00:00', '17:00:00', 5, 'COMPLETED', TRUE);

-- ============================================================================
-- ICJ JUDGMENTS
-- ============================================================================
INSERT INTO icj_judgment (judgment_number, case_id, judgment_type, judgment_date, summary, votes_in_favor, votes_against, is_unanimous, binding_on_parties, compliance_status) VALUES
('ICJ/JUD/2024/PM/001', 2, 'PROVISIONAL_MEASURES', '2024-07-01', 
'The Court orders provisional measures requiring the respondent to take all measures within its power to prevent acts that could constitute genocide.',
15, 2, FALSE, TRUE, 'PARTIAL_COMPLIANCE');

-- ============================================================================
-- TRUSTEESHIP TERRITORIES (Historical)
-- ============================================================================
INSERT INTO trusteeship_territory (territory_code, territory_name, administering_state_id, trust_agreement_date, independence_date, current_status, population_at_trust, area_sq_km) VALUES
('PLW', 'Palau', 1, '1947-07-18', '1994-10-01', 'INDEPENDENT', 15000, 459.00),
('FSM', 'Federated States of Micronesia', 1, '1947-07-18', '1986-11-03', 'FREE_ASSOCIATION', 90000, 702.00),
('MHL', 'Marshall Islands', 1, '1947-07-18', '1986-10-21', 'FREE_ASSOCIATION', 40000, 181.00),
('NRU', 'Nauru', 14, '1947-11-01', '1968-01-31', 'INDEPENDENT', 6000, 21.00),
('WSM', 'Western Samoa', 14, '1946-12-13', '1962-01-01', 'INDEPENDENT', 100000, 2831.00);

-- ============================================================================
-- TRUSTEESHIP REPORTS
-- ============================================================================
INSERT INTO trusteeship_report (report_number, territory_id, report_type, report_year, reporting_officer_id, submission_date, review_status, findings, recommendations, decision, decision_date) VALUES
('TC/REP/1993/PLW/FINAL', 1, 'FINAL', 1993, 14, '1993-11-15', 'CLOSED', 
'Palau has successfully completed all conditions for self-determination. The population voted for free association with the United States. All institutional frameworks are in place for independence.',
'The Trusteeship Council recommends termination of the trusteeship agreement upon Palaus independence.',
'Trusteeship terminated. Palau admitted as UN Member State.', '1994-10-01'),
('TC/REP/1985/FSM/ANN', 2, 'ANNUAL', 1985, 14, '1985-06-30', 'CLOSED',
'Significant progress in economic development and political institution building. Educational and healthcare systems expanding.',
'Continue support for infrastructure development. Prepare transition plan for compact of free association.',
'Report noted. Continued oversight approved.', '1985-09-15'),
('TC/REP/2024/HIST', 1, 'SPECIAL', 2024, 14, '2024-01-15', 'CLOSED',
'Comprehensive historical review of the trusteeship system documenting achievements and lessons learned.',
'Archive all trusteeship records for historical reference.',
'Historical review accepted. Archives transferred to UN Archives.', '2024-02-28');

-- ============================================================================
-- DIRECTIVES (Secretariat)
-- ============================================================================
INSERT INTO directive (directive_number, directive_type, title, content, issuing_department_id, target_department_id, issued_by_officer_id, issue_date, effective_date, expiry_date, priority, status, requires_acknowledgment, matter_id) VALUES
('ST/SGB/2024/1', 'POLICY', 'Remote Work Policy Framework', 
'1. Purpose: Establishes guidelines for remote work arrangements.\n2. Scope: Applies to all Secretariat staff.\n3. Eligibility: Staff may request remote work for up to 2 days per week.\n4. Approval: Supervisor approval required.\n5. Equipment: Standard IT equipment provided.\n6. Connectivity: Reliable internet required.\n7. Reporting: Regular check-ins mandatory.',
1, NULL, 1, '2024-03-15', '2024-04-01', '2026-03-31', 'HIGH', 'IN_EFFECT', TRUE, 6),
('ST/AI/2024/5', 'CIRCULAR', 'Travel Authorization Procedures', 
'1. All official travel must be pre-approved.\n2. Submit requests 14 days in advance.\n3. Economy class for flights under 9 hours.\n4. Per diem rates apply per location.\n5. Receipts required for expenses over $75.\n6. Submit claims within 30 days of return.',
8, NULL, 2, '2024-04-20', '2024-05-01', NULL, 'MEDIUM', 'IN_EFFECT', FALSE, 7),
('ST/IC/2024/12', 'BULLETIN', 'Cybersecurity Awareness Update', 
'Reminder: All staff must complete annual cybersecurity training by end of Q2. New phishing simulation exercises will be conducted. Report suspicious emails to security@un.org.',
9, NULL, 3, '2024-02-01', '2024-02-01', '2024-06-30', 'HIGH', 'EXPIRED', FALSE, NULL);

-- ============================================================================
-- DIRECTIVE ACKNOWLEDGMENTS
-- ============================================================================
INSERT INTO directive_acknowledgment (directive_id, officer_id, acknowledged_at) VALUES
(1, 2, '2024-04-02 09:15:00'),
(1, 3, '2024-04-02 10:30:00'),
(1, 4, '2024-04-03 08:45:00'),
(1, 5, '2024-04-03 14:20:00'),
(1, 6, '2024-04-04 09:00:00'),
(1, 7, '2024-04-04 11:30:00'),
(1, 8, '2024-04-05 10:00:00');

-- ============================================================================
-- AUDIT LOG (Sample entries)
-- ============================================================================
INSERT INTO audit_log (table_name, record_id, action_type, action_description, new_values, performed_by_officer_id, ip_address) VALUES
('matter', 1, 'INSERT', 'New resolution proposal submitted: Climate Action Acceleration', '{"status": "DRAFT", "priority": "HIGH"}', 11, '192.168.1.100'),
('matter', 1, 'STATUS_CHANGE', 'Matter status changed from DRAFT to SUBMITTED', '{"old_status": "DRAFT", "new_status": "SUBMITTED"}', 11, '192.168.1.100'),
('approval', 1, 'INSERT', 'Approval request created for matter GA/RES/78/001', '{"approval_level": 1, "status": "PENDING"}', 11, '192.168.1.100'),
('approval', 1, 'APPROVAL', 'Matter approved at level 1 by Director Santos', '{"status": "APPROVED"}', 6, '192.168.1.105'),
('matter', 1, 'STATUS_CHANGE', 'Matter status changed to IN_VOTING', '{"old_status": "APPROVED", "new_status": "IN_VOTING"}', 11, '192.168.1.100'),
('vote', 1, 'VOTE', 'Vote cast: USA voted YES on GA/RES/78/001', '{"vote_value": "YES"}', NULL, '192.168.1.200'),
('resolution', 1, 'INSERT', 'Resolution A/RES/78/1 created after successful vote', '{"yes_votes": 14, "no_votes": 0, "abstentions": 1}', 11, '192.168.1.100'),
('icj_case', 1, 'INSERT', 'New ICJ case filed: Maritime Boundary Dispute', '{"status": "PENDING", "case_type": "CONTENTIOUS"}', 15, '192.168.2.50'),
('directive', 1, 'INSERT', 'New policy directive issued: Remote Work Policy', '{"status": "DRAFT"}', 1, '192.168.1.1'),
('directive', 1, 'STATUS_CHANGE', 'Directive status changed to IN_EFFECT', '{"old_status": "ISSUED", "new_status": "IN_EFFECT"}', 1, '192.168.1.1');

-- Update audit log with delegate information
INSERT INTO audit_log (table_name, record_id, action_type, action_description, new_values, performed_by_delegate_id, ip_address) VALUES
('vote', 2, 'VOTE', 'Vote cast: China voted YES on GA/RES/78/001', '{"vote_value": "YES"}', 2, '192.168.1.201'),
('vote', 3, 'VOTE', 'Vote cast: Russia ABSTAINED on GA/RES/78/001', '{"vote_value": "ABSTAIN"}', 3, '192.168.1.202'),
('vote', 4, 'VOTE', 'Vote cast: UK voted YES on GA/RES/78/001', '{"vote_value": "YES"}', 4, '192.168.1.203'),
('vote', 5, 'VOTE', 'Vote cast: France voted YES on GA/RES/78/001', '{"vote_value": "YES"}', 5, '192.168.1.204');

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
