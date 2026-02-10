# United Nations Workflow Management System - ER Diagram & Documentation

## Project Overview

The UN Workflow Management System is a comprehensive database application for managing UN bureaucratic operations across six principal organs:
- **GA**: General Assembly
- **SC**: Security Council  
- **ECOSOC**: Economic and Social Council
- **ICJ**: International Court of Justice
- **SEC**: Secretariat
- **TC**: Trusteeship Council

The system tracks matters, voting, resolutions, ICJ cases, directives, and oversight reports with complete audit trails.

---

## Entity-Relationship Diagram (Text Representation)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    UN WORKFLOW MANAGEMENT SYSTEM                             │
│                            DATABASE SCHEMA                                  │
└─────────────────────────────────────────────────────────────────────────────┘

                        ╔═══════════════════════════╗
                        ║      UN_ORGAN (6 items)   ║
                        ║  ├─ organ_id (PK)         ║
                        ║  ├─ organ_code (UK)       ║
                        ║  ├─ organ_name            ║
                        ║  ├─ organ_description     ║
                        ║  ├─ established_year      ║
                        ║  ├─ headquarters_location ║
                        ║  └─ is_active             ║
                        ╚═════════════╤═════════════╝
                                      │
                ┌─────────────────────┼──────────────────────┐
                │                     │                      │
                │ 1:N                 │ 1:N                  │ 1:N
                ▼                     ▼                      ▼
        ╔═══════════════╗  ╔════════════════╗  ╔═══════════════════╗
        ║    OFFICER    ║  ║   DELEGATE     ║  ║     MATTER        ║
        ║               ║  ║                ║  ║                   ║
        ║ ├─officer_id  ║  ║ ├─delegate_id  ║  ║ ├─matter_id (PK)  ║
        ║ ├─employee#   ║  ║ ├─delegate_code║  ║ ├─matter_number   ║
        ║ ├─first_name  ║  ║ ├─first_name   ║  ║ ├─title           ║
        ║ ├─last_name   ║  ║ ├─last_name    ║  ║ ├─description     ║
        ║ ├─email (UK)  ║  ║ ├─title        ║  ║ ├─matter_type     ║
        ║ ├─role_id(FK) ║  ║ ├─state_id(FK) ║  ║ ├─organ_id (FK)   ║
        ║ ├─department_id
        ║ ├─organ_id(FK)║  ║ ├─organ_id(FK) ║  ║ ├─submitted_by_   ║
        ║ ├─hire_date   ║  ║ ├─credential   ║  ║ │  delegate_id(FK)║
        ║ ├─employment  ║  ║ ├─is_perm_rep  ║  ║ ├─submitted_by_   ║
        ║ │  _status    ║  ║ ├─voting_auth  ║  ║ │  officer_id(FK) ║
        ║ └─security_   ║  ║ ├─email        ║  ║ ├─priority        ║
        ║   clearance   ║  ║ └─status       ║  ║ ├─status          ║
        ╚═════╤═════╤═╧══╝  ╚════════╤═════╝  ║ ├─submission_date ║
              │     │                 │        ║ ├─target_comp_date║
              │     │                 │        ║ ├─requires_voting ║
              │     └─────────────────┼────────┼─┼─ ─voting_threshold
              │                       │        ║ └─session_number  ║
              │ 1:N                   │ 1:N    ╚═════╤═════════╤═══╝
              │                       │              │         │
              │                       │              │         │
              │                       │      ┌───────┘         │
              │                       │      │ 1:N              │ 1:N
              │                       │      ▼                 ▼
              │                       │  ╔═══════════════╗  ╔══════════════╗
              │                       │  ║ MATTER_       ║  ║    APPROVAL  ║
              │                       │  ║ WORKFLOW      ║  ║              ║
              │                       │  ║               ║  ║ ├─approval_id║
              │                       │  ║ ├─workflow_id ║  ║ ├─matter_id  ║
              │                       │  ║ ├─matter_id   ║  ║ ├─approver_  ║
              │                       │  ║ ├─stage_number║  ║ │  officer_id║
              │                       │  ║ ├─stage_name  ║  ║ ├─approval_  ║
              │                       │  ║ ├─stage_status║  ║ │  level     ║
              │                       │  ║ ├─assigned_   ║  ║ ├─status     ║
              │                       │  ║ │  officer_id ║  ║ ├─decision_  ║
              │                       │  ║ └─timestamps  ║  ║ │  date      ║
              │                       │  ╚═══════════════╝  ║ └─comments   ║
              │                       │                     ╚══════════════╝
              │                       │
              │ 1:N                   │ 1:N
              │                       └────────────────┬────────────┐
              │                                        │            │
              │                                   ╔════▼══════╗  ╔══▼═══════╗
              │                                   ║   VOTE    ║  ║RESOLUTION║
              │                                   ║           ║  ║           ║
              │                                   ║ ├─vote_id ║  ║ ├─res_id  ║
              │                                   ║ ├─matter_ ║  ║ ├─matter_ ║
              │                                   ║ │  id(FK) ║  ║ │  id(FK) ║
              │                                   ║ ├─state_id║  ║ ├─organ_  ║
              │                                   ║ ├─delegate║  ║ │  id(FK) ║
              │                                   ║ │  _id(FK)║  ║ ├─title   ║
              │                                   ║ ├─vote_val║  ║ ├─preamble║
              │                                   ║ ├─vote_   ║  ║ ├─operati ║
              │                                   ║ │  weight ║  ║ │  ve_text║
              │                                   ║ ├─is_valid║  ║ ├─adoption║
              │                                   ║ └─timestamp  ║ │ _date    ║
              │                                   ╚════╤══════╝  ║ ├─yes/no/ ║
              │                                        │         ║ │  abstain ║
              │                                        │         ║ ├─is_bind ║
              │ 1:N                                     │         ║ └─status  ║
              │                                        │         ╚════┬══════╝
              │ FK RELATIONSHIP                        │              │
              │                                     1:N│              │
              │                    ╔═════════════════════════════╗    │
              │                    ║      MEMBER_STATE           ║    │
              │                    ║                             ║    │
              │                    ║ ├─state_id (PK)            ║    │
              │                    ║ ├─state_code (UK)          ║    │
              │                    ║ ├─state_name               ║    │
              │                    ║ ├─region                   ║    │
              │                    ║ ├─admission_date           ║    │
              │                    ║ ├─is_sc_permanent_member   ║    │
              │                    ║ └─contribution_percentage  ║    │
              │                    ╚═════════════════════════════╝    │
              │                                                       │
              │                                                    1:N│
              │                                                       │
              │                                    ┌──────────────────┘
              │                                    │
              │          ┌──────────────────────┬──┴──────────────────────┐
              │          │ 1:N                  │ 1:N                     │ 1:N
              │          ▼                      ▼                         ▼
              │      ╔═════════════╗        ╔═════════════╗         ╔═══════════╗
              │      ║ DIRECTIVE   ║        ║  ICJ_CASE   ║         ║TRUSTEESHIP║
              │      ║             ║        ║             ║         ║_REPORT    ║
              │      ║ ├─directive ║        ║ ├─case_id   ║         ║           ║
              │      ║ │  _id      ║        ║ ├─case_numb ║         ║ ├─report_ ║
              │      ║ ├─directive ║        ║ ├─case_title║         ║ │  id     ║
              │      ║ │  _number  ║        ║ ├─case_type ║         ║ ├─report_ ║
              │      ║ ├─directive ║        ║ ├─applicant ║         ║ │  number ║
              │      ║ │  _type    ║        ║ │  _state_id║         ║ ├─territo ║
              │      ║ ├─title     ║        ║ ├─respondent║         ║ │  ry_id  ║
              │      ║ ├─content   ║        ║ │  _state_id║         ║ ├─report_ ║
              │      ║ ├─issuing_  ║        ║ ├─requesting║         ║ │  type   ║
              │      ║ │  dept_id  ║        ║ │  _organ_id ║         ║ ├─report_ ║
              │      ║ ├─target_   ║        ║ ├─filing_   ║         ║ │  year   ║
              │      ║ │  dept_id  ║        ║ │  date     ║         ║ ├─reporting║
              │      ║ ├─issued_by ║        ║ ├─subject_  ║         ║ │  _officer║
              │      ║ │  _officer ║        ║ │  matter   ║         ║ ├─submissio║
              │      ║ ├─dates     ║        ║ ├─status    ║         ║ │  n_date  ║
              │      ║ └─requires_ ║        ║ └─matter_id ║         ║ ├─review_  ║
              │      ║   ack       ║        ╚═════╤═══════╝         ║ │  status  ║
              │      ╚═════╤═══════╝              │                 ║ └─findings ║
              │            │ 1:N                  │ 1:N             ╚═╤═════════╝
              │            │                      │                 │
              │            ▼                      │                 │ 1:N
              │   ╔═════════════════╗             │                 │
              │   ║DIRECTIVE_       ║             │                 │ FK
              │   ║ACKNOWLEDGMENT   ║             │                 │
              │   ║                 ║             │      ┌──────────┘
              │   ║ ├─acknowledge   ║             │      │
              │   ║ │  _id          ║             ▼      ▼
              │   ║ ├─directive_id  ║         ╔════════════════╗
              │   ║ ├─officer_id(FK)║         ║TRUSTEESHIP_    ║
              │   ║ ├─ack_timestamp ║         ║TERRITORY       ║
              │   ║ └─notes         ║         ║                ║
              │   ╚═════════════════╝         ║ ├─territory_id ║
              │                               ║ ├─territory_   ║
              │                               ║ │  code        ║
              │                               ║ ├─territory_   ║
              │                               ║ │  name        ║
              │                               ║ ├─administer   ║
              │                               ║ │  ing_state   ║
              │                               ║ ├─trust_agree  ║
              │                               ║ │  ment_date   ║
              │                               ║ ├─independent  ║
              │                               ║ │  ce_date     ║
              │                               ║ ├─current_     ║
              │                               ║ │  status      ║
              │                               ║ └─population   ║
              │                               ╚════════════════╝
              │
              │ 1:N
              │
              │     ╔═══════════════════════════════╗
              │     ║      ROLE                     ║
              │     ║                               ║
              │     ║ ├─role_id (PK)                ║
              │     ║ ├─role_code (UK)              ║
              │     ║ ├─role_name                   ║
              │     ║ ├─role_description            ║
              │     ║ ├─permission_level (1-10)     ║
              │     ║ ├─can_approve (boolean)       ║
              │     ║ ├─can_vote (boolean)          ║
              │     ║ └─can_issue_resolution        ║
              │     ╚═══════════════════════════════╝
              │
              └─► REFERENCES IN OFFICER TABLE
                  (one_to_many relationship)


╔═══════════════════════════════════════════════════════════════════════════════╗
║                          ICJ-SPECIFIC RELATIONSHIPS                           ║
╚═══════════════════════════════════════════════════════════════════════════════╝

              ╔═════════════════╗
              ║   ICJ_JUDGE     ║
              ║                 ║
              ║ ├─judge_id      ║
              ║ ├─judge_code    ║
              ║ ├─first_name    ║
              ║ ├─last_name     ║
              ║ ├─nationality_  ║
              ║ │  state_id(FK) ║
              ║ ├─appointment   ║
              ║ │  _date        ║
              ║ ├─term_end_date ║
              ║ ├─is_president  ║
              ║ ├─is_vice_pres  ║
              ║ ├─specialization║
              ║ └─status        ║
              ╚────────┬────────╝
                       │ 1:N (judges assigned to cases)
                       │
              ╔────────▼────────╗
              ║ ICJ_CASE_JUDGE  ║
              ║ (many-to-many)  ║
              ║                 ║
              ║ ├─case_judge_id ║
              ║ ├─case_id(FK)   ║
              ║ ├─judge_id(FK)  ║
              ║ ├─is_ad_hoc     ║
              ║ └─appointed_by_ ║
              ║    state_id     ║
              ╚────────┬────────╝
                       │
                       │ References both:
                       │ • ICJ_CASE (via case_id)
                       │ • ICJ_JUDGE (via judge_id)
                       │
              ╔────────▼────────┐
              │ ICJ_HEARING     │
              │                 │
              │ ├─hearing_id    │
              │ ├─case_id(FK)   │
              │ ├─hearing_number│
              │ ├─hearing_type  │
              │ ├─scheduled_date│
              │ ├─actual_date   │
              │ ├─presiding_    │
              │ │  judge_id(FK) │
              │ ├─status        │
              │ └─transcript_   │
              │    available    │
              └────────┬────────┘
                       │
              ╔────────▼────────┐
              │ ICJ_JUDGMENT    │
              │                 │
              │ ├─judgment_id   │
              │ ├─judgment_number│
              │ ├─case_id(FK)   │
              │ ├─judgment_type │
              │ ├─judgment_date │
              │ ├─summary       │
              │ ├─full_text     │
              │ ├─votes_in_favor│
              │ ├─votes_against │
              │ ├─is_unanimous  │
              │ ├─binding_on_   │
              │ │  parties      │
              │ └─compliance_   │
              │    status       │
              └─────────────────┘


╔═══════════════════════════════════════════════════════════════════════════════╗
║                    SECRETARIAT & DEPARTMENTS RELATIONSHIPS                    ║
╚═══════════════════════════════════════════════════════════════════════════════╝

              ╔════════════════════╗
              ║    DEPARTMENT      ║
              ║                    ║
              ║ ├─department_id    ║
              ║ ├─department_code  ║
              ║ ├─department_name  ║
              ║ ├─parent_dept_id   ║◄─┐ (self-referencing 1:N)
              ║ ├─head_title       ║  │
              ║ ├─established_date ║  │
              ║ └─is_active        ║  │
              ╚────┬──────┬────────╝  │
                   │      │          │
                   │      └──────────┴─(parent-child relationship)
                   │
              1:N ├─► DIRECTIVE.issuing_department_id
                   │
              1:N ├─► DIRECTIVE.target_department_id
                   │
              1:N └─► OFFICER.department_id
                      (officers belong to departments)


╔═══════════════════════════════════════════════════════════════════════════════╗
║                         AUDIT LOG RELATIONSHIPS                              ║
╚═══════════════════════════════════════════════════════════════════════════════╝

              ╔═════════════════════════╗
              ║      AUDIT_LOG          ║
              ║                         ║
              ║ ├─log_id (PK)           ║
              ║ ├─table_name            ║
              ║ ├─record_id             ║
              ║ ├─action_type           ║
              ║ ├─action_description    ║
              ║ ├─old_values (JSON)     ║
              ║ ├─new_values (JSON)     ║
              ║ ├─performed_by_         ║
              ║ │  officer_id(FK)       ║
              ║ ├─performed_by_         ║
              ║ │  delegate_id(FK)      ║
              ║ ├─ip_address            ║
              ║ ├─user_agent            ║
              ║ └─action_timestamp      ║
              ╚────┬──────────┬─────────╝
                   │          │
              1:N  │          │ 1:N
                   ▼          ▼
            ┌─────────────┬─────────────┐
            │   OFFICER   │   DELEGATE  │
            │   (logged   │   (logged   │
            │    by)      │     by)     │
            └─────────────┴─────────────┘

Tracks all system changes for:
• MATTER (INSERT, UPDATE, DELETE, STATUS_CHANGE)
• VOTE (VOTE action)
• APPROVAL (APPROVAL action)
• OFFICER (LOGIN, LOGOUT)
• RESOLUTION
• ICJ_CASE
• DIRECTIVE
```

---

## Detailed Entity Documentation

### 1. **UN_ORGAN** (Core Reference)
Master list of UN's six principal organs

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| organ_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| organ_code | VARCHAR(15) | UK, CHECK | GA, SC, ECOSOC, ICJ, SEC, TC |
| organ_name | VARCHAR(100) | NOT NULL | Full name of organ |
| organ_description | TEXT | | Description and role |
| established_year | INT | NOT NULL | Year founded (1945) |
| headquarters_location | VARCHAR(100) | | Geographic location |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| updated_at | TIMESTAMP | ON UPDATE CURRENT | Audit field |

**Relationships**: 1 organ has many officers, delegates, and matters

---

### 2. **MEMBER_STATE** (Reference Data)
UN member states - nations represented in the organization

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| state_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| state_code | VARCHAR(3) | UK | ISO 3166-1 alpha-3 (USA, CHN, etc.) |
| state_name | VARCHAR(100) | NOT NULL | Official state name |
| region | VARCHAR(50) | NOT NULL, CHECK | Africa, Asia-Pacific, etc. |
| admission_date | DATE | NOT NULL | Date joined UN |
| is_sc_permanent_member | BOOLEAN | DEFAULT FALSE | P5 status |
| contribution_percentage | DECIMAL(5,3) | DEFAULT 0 | Budget contribution % |
| is_active | BOOLEAN | DEFAULT TRUE | Currently active member |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |

**Relationships**: 
- Referenced by DELEGATE (state representatives)
- Referenced by VOTE (states voting)
- Referenced by ICJ_JUDGE (nationality)
- Referenced by ICJ_CASE (applicant/respondent)
- Referenced by TRUSTEESHIP_TERRITORY (administering state)

---

### 3. **ROLE** (Reference Data)
Predefined roles for UN staff with permission levels

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| role_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| role_code | VARCHAR(20) | UK | SG, DSG, USG, DIR, OFFICER, etc. |
| role_name | VARCHAR(100) | NOT NULL | Human-readable role name |
| role_description | TEXT | | Role responsibilities |
| permission_level | INT | NOT NULL, CHECK 1-10 | Hierarchical authorization level |
| can_approve | BOOLEAN | DEFAULT FALSE | Authority to approve matters |
| can_vote | BOOLEAN | DEFAULT FALSE | Authority to vote |
| can_issue_resolution | BOOLEAN | DEFAULT FALSE | Authority to issue resolutions |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |

**Relationships**: 1 role has many officers

---

### 4. **DEPARTMENT** (Organizational)
Secretariat departments and sub-units

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| department_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| department_code | VARCHAR(20) | UK | DPPA, DPO, OCHA, etc. |
| department_name | VARCHAR(150) | NOT NULL | Full department name |
| parent_department_id | INT | FK, NULLABLE | Self-referencing for hierarchy |
| head_title | VARCHAR(100) | | Title of department head |
| established_date | DATE | | Date created |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |

**Relationships**: 
- Self-referencing (hierarchical: parent-child departments)
- 1 department has many officers
- 1 department issues many directives

---

### 5. **OFFICER** (Personnel)
UN staff members and officials

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| officer_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| employee_number | VARCHAR(20) | UK | Unique employee ID |
| first_name | VARCHAR(50) | NOT NULL | Given name |
| last_name | VARCHAR(50) | NOT NULL | Family name |
| email | VARCHAR(100) | UK, NOT NULL | Official email |
| role_id | INT | FK, NOT NULL | References ROLE |
| department_id | INT | FK, NULLABLE | References DEPARTMENT |
| organ_id | INT | FK, NOT NULL | References UN_ORGAN |
| hire_date | DATE | NOT NULL | Employment start date |
| employment_status | ENUM | DEFAULT ACTIVE | ACTIVE, ON_LEAVE, TERMINATED, RETIRED |
| security_clearance_level | INT | CHECK 1-5 | Security level (1-5) |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| updated_at | TIMESTAMP | ON UPDATE CURRENT | Audit field |

**Relationships**: 
- Many officers per role
- Many officers per department
- Many officers per organ
- Officers approve matters (APPROVAL)
- Officers assign to workflow stages (MATTER_WORKFLOW)
- Officers issue directives (DIRECTIVE)
- Officers report on trusteeship (TRUSTEESHIP_REPORT)
- Officers perform audit log actions (AUDIT_LOG)

---

### 6. **DELEGATE** (Personnel)
Representatives from member states to UN organs

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| delegate_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| delegate_code | VARCHAR(20) | UK | DEL-USA-GA format |
| first_name | VARCHAR(50) | NOT NULL | Given name |
| last_name | VARCHAR(50) | NOT NULL | Family name |
| title | VARCHAR(50) | | Ambassador, Representative, etc. |
| state_id | INT | FK, NOT NULL | References MEMBER_STATE |
| organ_id | INT | FK, NOT NULL | References UN_ORGAN |
| credential_date | DATE | NOT NULL | Accreditation date |
| credential_expiry_date | DATE | | Expiration of credentials |
| is_permanent_representative | BOOLEAN | DEFAULT FALSE | Permanent or temporary |
| voting_authority | BOOLEAN | DEFAULT TRUE | Can cast votes |
| email | VARCHAR(100) | | Contact email |
| status | ENUM | DEFAULT ACTIVE | ACTIVE, SUSPENDED, EXPIRED |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| updated_at | TIMESTAMP | ON UPDATE CURRENT | Audit field |

**Relationships**: 
- Many delegates per member state
- Many delegates per organ
- Delegates submit matters (MATTER)
- Delegates cast votes (VOTE)
- Delegates perform audit actions (AUDIT_LOG)

---

### 7. **MATTER** (Core - Main Business Entity)
Master records for all matters processed by UN organs

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| matter_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| matter_number | VARCHAR(30) | UK, NOT NULL | Unique identifier (GA/RES/78/001) |
| title | VARCHAR(255) | NOT NULL | Matter title |
| description | TEXT | NOT NULL | Full description |
| matter_type | ENUM | NOT NULL | RESOLUTION, CASE, DIRECTIVE, etc. |
| organ_id | INT | FK, NOT NULL | References UN_ORGAN |
| submitted_by_delegate_id | INT | FK, NULLABLE | References DELEGATE (if delegate submission) |
| submitted_by_officer_id | INT | FK, NULLABLE | References OFFICER (if officer submission) |
| priority | ENUM | DEFAULT MEDIUM | LOW, MEDIUM, HIGH, URGENT, CRITICAL |
| status | ENUM | DEFAULT DRAFT | DRAFT→SUBMITTED→UNDER_REVIEW→APPROVED→IN_VOTING→PASSED/REJECTED |
| submission_date | DATE | | When submitted |
| target_completion_date | DATE | | Target completion |
| actual_completion_date | DATE | | When actually completed |
| session_number | VARCHAR(20) | | UN session number |
| agenda_item_number | VARCHAR(20) | | Agenda item reference |
| requires_voting | BOOLEAN | DEFAULT FALSE | Whether voting required |
| voting_threshold | DECIMAL(5,2) | DEFAULT 50.00 | % needed to pass |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| updated_at | TIMESTAMP | ON UPDATE CURRENT | Audit field |

**Relationships**: 
- 1 organ has many matters
- Matter created by delegate or officer
- Matter has workflow stages (MATTER_WORKFLOW)
- Matter may have approvals (APPROVAL)
- Matter may have votes (VOTE)
- Matter may result in resolution (RESOLUTION)
- Matter may relate to ICJ_CASE
- Matter may relate to DIRECTIVE
- Matter may relate to TRUSTEESHIP_REPORT
- Matter tracked in AUDIT_LOG

---

### 8. **MATTER_WORKFLOW** (Process)
Tracks progression of matters through workflow stages

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| workflow_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| matter_id | INT | FK, NOT NULL | References MATTER (CASCADE DELETE) |
| stage_number | INT | NOT NULL | Sequential stage (1, 2, 3...) |
| stage_name | VARCHAR(50) | NOT NULL | Name of workflow stage |
| stage_status | ENUM | DEFAULT PENDING | PENDING, IN_PROGRESS, COMPLETED, SKIPPED, FAILED |
| assigned_officer_id | INT | FK, NULLABLE | References OFFICER handling this stage |
| started_at | TIMESTAMP | NULLABLE | When stage started |
| completed_at | TIMESTAMP | NULLABLE | When stage completed |
| notes | TEXT | | Stage-specific notes |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| **UK** | UNIQUE | (matter_id, stage_number) | One stage per matter |

**Relationships**: 
- Multiple stages per matter
- Each stage assigned to an officer
- Enables tracking matter progression

---

### 9. **APPROVAL** (Process)
Multi-level approval records for matters requiring authorization

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| approval_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| matter_id | INT | FK, NOT NULL | References MATTER (CASCADE DELETE) |
| approver_officer_id | INT | FK, NOT NULL | References OFFICER (approver) |
| approval_level | INT | NOT NULL, DEFAULT 1 | Hierarchical level (1=first, 2=second, etc.) |
| approval_status | ENUM | DEFAULT PENDING | PENDING, APPROVED, REJECTED, DEFERRED |
| decision_date | TIMESTAMP | NULLABLE | When decision made |
| comments | TEXT | | Approval comments |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| **UK** | UNIQUE | (matter_id, approver_officer_id, approval_level) | One approval per officer per level |

**Relationships**: 
- Multiple approval levels per matter
- Each level has responsible officer
- Tracks complete approval chain

---

### 10. **VOTE** (Process)
Voting records for matters in GA, SC, or ECOSOC

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| vote_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| matter_id | INT | FK, NOT NULL | References MATTER (CASCADE DELETE) |
| state_id | INT | FK, NOT NULL | References MEMBER_STATE |
| delegate_id | INT | FK, NOT NULL | References DELEGATE (who cast vote) |
| vote_value | ENUM | NOT NULL | YES, NO, ABSTAIN |
| vote_weight | DECIMAL(5,2) | DEFAULT 1.00 | Weighted voting support |
| vote_timestamp | TIMESTAMP | DEFAULT CURRENT | When vote cast |
| is_valid | BOOLEAN | DEFAULT TRUE | Vote validity flag |
| invalidation_reason | TEXT | | Why vote invalidated (if applicable) |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| **UK** | UNIQUE | (matter_id, state_id) | One vote per state per matter |

**Relationships**: 
- Many votes per matter
- Each vote from one state/delegate
- Supports weighted voting systems

---

### 11. **RESOLUTION** (Outcome)
Formal resolutions passed by organs

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| resolution_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| resolution_number | VARCHAR(30) | UK, NOT NULL | Official resolution number |
| matter_id | INT | FK, UK, NOT NULL | References MATTER (1:1 relationship) |
| organ_id | INT | FK, NOT NULL | References UN_ORGAN |
| title | VARCHAR(255) | NOT NULL | Resolution title |
| preamble | TEXT | | Preambular clauses |
| operative_text | TEXT | NOT NULL | Main operative clauses |
| adoption_date | DATE | NOT NULL | Date adopted |
| yes_votes | INT | NOT NULL, DEFAULT 0 | Count of YES votes |
| no_votes | INT | NOT NULL, DEFAULT 0 | Count of NO votes |
| abstentions | INT | NOT NULL, DEFAULT 0 | Count of ABSTAIN votes |
| is_binding | BOOLEAN | DEFAULT FALSE | Legally binding status |
| implementation_deadline | DATE | | By when to implement |
| status | ENUM | DEFAULT ADOPTED | ADOPTED, IN_FORCE, SUPERSEDED, EXPIRED |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| updated_at | TIMESTAMP | ON UPDATE CURRENT | Audit field |

**Relationships**: 
- 1:1 with MATTER (one resolution per matter)
- Multiple resolutions per organ
- Outcome of voting process

---

### 12. **ICJ_JUDGE** (Personnel)
International Court of Justice judges

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| judge_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| judge_code | VARCHAR(20) | UK, NOT NULL | Judge identifier |
| first_name | VARCHAR(50) | NOT NULL | Given name |
| last_name | VARCHAR(50) | NOT NULL | Family name |
| nationality_state_id | INT | FK, NOT NULL | References MEMBER_STATE |
| appointment_date | DATE | NOT NULL | Date appointed to ICJ |
| term_end_date | DATE | NOT NULL | Term expiration date |
| is_president | BOOLEAN | DEFAULT FALSE | Is presiding officer |
| is_vice_president | BOOLEAN | DEFAULT FALSE | Is vice president |
| specialization | VARCHAR(100) | | Area of expertise |
| status | ENUM | DEFAULT ACTIVE | ACTIVE, RETIRED, DECEASED |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |

**Relationships**: 
- Many judges per ICJ
- Each has one nationality state
- Assigned to many cases (via ICJ_CASE_JUDGE)
- Presides over hearings (ICJ_HEARING)

---

### 13. **ICJ_CASE** (Core)
Cases before the International Court of Justice

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| case_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| case_number | VARCHAR(30) | UK, NOT NULL | Official case number |
| case_title | VARCHAR(255) | NOT NULL | Case title |
| case_type | ENUM | NOT NULL | CONTENTIOUS or ADVISORY |
| applicant_state_id | INT | FK, NULLABLE | References MEMBER_STATE (for contentious) |
| respondent_state_id | INT | FK, NULLABLE | References MEMBER_STATE (for contentious) |
| requesting_organ_id | INT | FK, NULLABLE | References UN_ORGAN (for advisory) |
| filing_date | DATE | NOT NULL | Date case filed |
| subject_matter | TEXT | NOT NULL | Legal questions presented |
| status | ENUM | DEFAULT PENDING | PENDING→PRELIMINARY_OBJECTIONS→MERITS→HEARING→JUDGMENT_ISSUED |
| matter_id | INT | FK, NULLABLE | References MATTER (if related) |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| updated_at | TIMESTAMP | ON UPDATE CURRENT | Audit field |

**Relationships**: 
- Contentious cases: applicant & respondent states
- Advisory cases: requesting organ
- Related to MATTER (optional)
- Has many hearings (ICJ_HEARING)
- Has many judgments (ICJ_JUDGMENT)
- Assigned multiple judges (via ICJ_CASE_JUDGE)

---

### 14. **ICJ_HEARING** (Process)
Oral arguments and hearings in ICJ cases

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| hearing_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| case_id | INT | FK, NOT NULL | References ICJ_CASE (CASCADE DELETE) |
| hearing_number | INT | NOT NULL | Sequential number |
| hearing_type | ENUM | NOT NULL | ORAL_ARGUMENTS, PRELIMINARY, PROVISIONAL_MEASURES, JUDGMENT_READING |
| scheduled_date | DATE | NOT NULL | Planned hearing date |
| actual_date | DATE | | Actual hearing date |
| start_time | TIME | | Hearing start time |
| end_time | TIME | | Hearing end time |
| location | VARCHAR(100) | DEFAULT Peace Palace | Hearing location |
| presiding_judge_id | INT | FK, NULLABLE | References ICJ_JUDGE (presiding) |
| status | ENUM | DEFAULT SCHEDULED | SCHEDULED, IN_PROGRESS, COMPLETED, POSTPONED, CANCELLED |
| transcript_available | BOOLEAN | DEFAULT FALSE | Transcript published |
| notes | TEXT | | Hearing notes |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| **UK** | UNIQUE | (case_id, hearing_number) | One sequence per case |

**Relationships**: 
- Multiple hearings per case
- Each hearing presided by a judge
- Tracks complete hearing schedule/results

---

### 15. **ICJ_JUDGMENT** (Outcome)
Court judgments and advisory opinions

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| judgment_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| judgment_number | VARCHAR(30) | UK, NOT NULL | Official judgment number |
| case_id | INT | FK, NOT NULL | References ICJ_CASE |
| judgment_type | ENUM | NOT NULL | PRELIMINARY_OBJECTIONS, MERITS, PROVISIONAL_MEASURES, ADVISORY_OPINION, INTERPRETATION, REVISION |
| judgment_date | DATE | NOT NULL | Date judgment issued |
| summary | TEXT | NOT NULL | Summary of judgment |
| full_text | TEXT | | Complete text |
| votes_in_favor | INT | NOT NULL | Judges voting for |
| votes_against | INT | NOT NULL | Judges voting against |
| is_unanimous | BOOLEAN | DEFAULT FALSE | Unanimous decision |
| binding_on_parties | BOOLEAN | DEFAULT TRUE | Binding force |
| compliance_status | ENUM | DEFAULT PENDING | PENDING, COMPLIED, PARTIAL_COMPLIANCE, NON_COMPLIANCE, NOT_APPLICABLE |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |

**Relationships**: 
- Multiple judgments per case
- Tracks all judicial decisions

---

### 16. **ICJ_CASE_JUDGE** (Association)
Many-to-many relationship: judges assigned to cases

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| case_judge_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| case_id | INT | FK, NOT NULL | References ICJ_CASE (CASCADE DELETE) |
| judge_id | INT | FK, NOT NULL | References ICJ_JUDGE |
| is_ad_hoc | BOOLEAN | DEFAULT FALSE | Ad hoc judge status |
| appointed_by_state_id | INT | FK, NULLABLE | References MEMBER_STATE (for ad hoc) |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| **UK** | UNIQUE | (case_id, judge_id) | One judge per case |

**Relationships**: 
- Links ICJ_CASE to ICJ_JUDGE
- Supports ad hoc judge appointments
- Enables case panel composition

---

### 17. **DIRECTIVE** (Business Document)
Secretariat directives, circulars, and policy statements

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| directive_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| directive_number | VARCHAR(30) | UK, NOT NULL | Official number |
| directive_type | ENUM | NOT NULL | ADMINISTRATIVE, POLICY, CIRCULAR, BULLETIN, INSTRUCTION |
| title | VARCHAR(255) | NOT NULL | Directive title |
| content | TEXT | NOT NULL | Full directive content |
| issuing_department_id | INT | FK, NOT NULL | References DEPARTMENT (issuer) |
| target_department_id | INT | FK, NULLABLE | References DEPARTMENT (if specific; NULL=all) |
| issued_by_officer_id | INT | FK, NOT NULL | References OFFICER (who issued) |
| issue_date | DATE | NOT NULL | Official issue date |
| effective_date | DATE | NOT NULL | When takes effect |
| expiry_date | DATE | NULLABLE | When expires (if applicable) |
| priority | ENUM | DEFAULT MEDIUM | LOW, MEDIUM, HIGH, URGENT |
| status | ENUM | DEFAULT DRAFT | DRAFT, ISSUED, IN_EFFECT, SUPERSEDED, EXPIRED, WITHDRAWN |
| requires_acknowledgment | BOOLEAN | DEFAULT FALSE | Must be acknowledged |
| matter_id | INT | FK, NULLABLE | References MATTER (if related) |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| updated_at | TIMESTAMP | ON UPDATE CURRENT | Audit field |

**Relationships**: 
- Issued by one department
- May target specific department
- Issued by one officer
- May relate to a matter
- Officers acknowledge (DIRECTIVE_ACKNOWLEDGMENT)

---

### 18. **DIRECTIVE_ACKNOWLEDGMENT** (Tracking)
Tracks acknowledgment of directives by officers

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| acknowledgment_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| directive_id | INT | FK, NOT NULL | References DIRECTIVE (CASCADE DELETE) |
| officer_id | INT | FK, NOT NULL | References OFFICER |
| acknowledged_at | TIMESTAMP | DEFAULT CURRENT | When acknowledged |
| notes | TEXT | | Acknowledgment notes |
| **UK** | UNIQUE | (directive_id, officer_id) | One acknowledgment per officer |

**Relationships**: 
- Tracks who acknowledged which directives
- Enforces single acknowledgment per officer

---

### 19. **TRUSTEESHIP_TERRITORY** (Reference - Historical)
UN Trust Territories under Trusteeship Council

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| territory_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| territory_code | VARCHAR(10) | UK, NOT NULL | Territory code |
| territory_name | VARCHAR(100) | NOT NULL | Territory name |
| administering_state_id | INT | FK, NOT NULL | References MEMBER_STATE (administering power) |
| trust_agreement_date | DATE | NOT NULL | When trust established |
| independence_date | DATE | NULLABLE | Date became independent |
| current_status | ENUM | NOT NULL | TRUST_TERRITORY, INDEPENDENT, INTEGRATED, FREE_ASSOCIATION |
| population_at_trust | INT | | Population when placed under trust |
| area_sq_km | DECIMAL(12,2) | | Territory area |
| notes | TEXT | | Historical notes |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |

**Relationships**: 
- One administering state per territory
- Multiple territories per state
- Subject of trusteeship reports (TRUSTEESHIP_REPORT)

---

### 20. **TRUSTEESHIP_REPORT** (Process/Outcome)
Reports from Trusteeship Council on territories

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| report_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| report_number | VARCHAR(30) | UK, NOT NULL | Official report number |
| territory_id | INT | FK, NOT NULL | References TRUSTEESHIP_TERRITORY |
| report_type | ENUM | NOT NULL | ANNUAL, SPECIAL, VISITING_MISSION, PETITION_REVIEW, FINAL |
| report_year | INT | NOT NULL | Reporting year |
| reporting_officer_id | INT | FK, NOT NULL | References OFFICER (who prepared) |
| submission_date | DATE | NOT NULL | When submitted |
| review_status | ENUM | DEFAULT SUBMITTED | SUBMITTED, UNDER_REVIEW, REVIEWED, DECISION_PENDING, CLOSED |
| findings | TEXT | | Key findings |
| recommendations | TEXT | | Recommendations |
| decision | TEXT | | Council decision |
| decision_date | DATE | | When decision made |
| matter_id | INT | FK, NULLABLE | References MATTER (if related) |
| created_at | TIMESTAMP | DEFAULT CURRENT | Audit field |
| updated_at | TIMESTAMP | ON UPDATE CURRENT | Audit field |

**Relationships**: 
- Many reports per territory
- Each prepared by officer
- Related to matter (optional)
- Tracked in AUDIT_LOG

---

### 21. **AUDIT_LOG** (System)
Complete system audit trail for accountability and compliance

| Attribute | Type | Constraint | Notes |
|-----------|------|-----------|-------|
| log_id | INT | PK, AUTO_INCREMENT | Primary identifier |
| table_name | VARCHAR(50) | NOT NULL | Which table affected |
| record_id | INT | NOT NULL | Which record in that table |
| action_type | ENUM | NOT NULL | INSERT, UPDATE, DELETE, STATUS_CHANGE, VOTE, APPROVAL, LOGIN, LOGOUT |
| action_description | TEXT | NOT NULL | Human-readable description |
| old_values | JSON | | Previous values (for UPDATE/DELETE) |
| new_values | JSON | | New values (for INSERT/UPDATE) |
| performed_by_officer_id | INT | FK, NULLABLE | References OFFICER (if officer action) |
| performed_by_delegate_id | INT | FK, NULLABLE | References DELEGATE (if delegate action) |
| ip_address | VARCHAR(45) | | Source IP address |
| user_agent | VARCHAR(255) | | Browser/client info |
| action_timestamp | TIMESTAMP | DEFAULT CURRENT | When action occurred |
| **Indexes** | | | (table_name, record_id), (action_timestamp), (performed_by_officer_id) |

**Relationships**: 
- Audit trail for all entities
- Links to officer or delegate performing action
- Complete history maintenance

---

## Key Relationship Patterns

### 1. **One-to-Many (1:N)**
- UN_ORGAN → OFFICER
- UN_ORGAN → DELEGATE
- UN_ORGAN → MATTER
- MEMBER_STATE → DELEGATE
- MEMBER_STATE → VOTE
- MEMBER_STATE → ICJ_JUDGE
- MEMBER_STATE → ICJ_CASE (applicant/respondent)
- MATTER → MATTER_WORKFLOW
- MATTER → APPROVAL
- MATTER → VOTE
- ROLE → OFFICER
- DEPARTMENT → OFFICER
- DEPARTMENT → DIRECTIVE
- OFFICER → MATTER_WORKFLOW (assigned)
- OFFICER → APPROVAL (approver)
- OFFICER → DIRECTIVE (issued)
- OFFICER → TRUSTEESHIP_REPORT (prepared)
- DELEGATE → MATTER (submitted)
- DELEGATE → VOTE (casts)
- ICJ_JUDGE → ICJ_HEARING (presides)
- ICJ_CASE → ICJ_HEARING
- ICJ_CASE → ICJ_JUDGMENT
- TRUSTEESHIP_TERRITORY → TRUSTEESHIP_REPORT

### 2. **One-to-One (1:1)**
- MATTER ↔ RESOLUTION (one resolution per matter)

### 3. **Many-to-Many (M:N)**
- ICJ_CASE ↔ ICJ_JUDGE (via ICJ_CASE_JUDGE junction table)
- DIRECTIVE ↔ OFFICER (via DIRECTIVE_ACKNOWLEDGMENT junction table)

### 4. **Hierarchical (Self-Referencing)**
- DEPARTMENT.parent_department_id → DEPARTMENT.department_id

### 5. **Audit Trail**
- All major entities tracked in AUDIT_LOG
- Links back to OFFICER or DELEGATE performing action

---

## Data Flow & Key Workflows

### Workflow: Matter Resolution Process
```
MATTER (DRAFT)
    ↓ (submitted)
MATTER (SUBMITTED) → MATTER_WORKFLOW stages (PENDING/IN_PROGRESS/COMPLETED)
    ↓
APPROVAL (chain of approvals)
    ↓
MATTER (APPROVED)
    ↓
MATTER (IN_VOTING) → VOTE records collected
    ↓
VOTE counting determines outcome
    ↓
RESOLUTION created (if passed)
    ↓
MATTER (PASSED/REJECTED)
```

### Workflow: ICJ Case Process
```
ICJ_CASE (PENDING)
    ↓
ICJ_CASE (PRELIMINARY_OBJECTIONS)
    ├── ICJ_HEARING records
    └── ICJ_JUDGMENT (preliminary)
    ↓
ICJ_CASE (MERITS)
    ├── ICJ_HEARING records
    └── ICJ_JUDGMENT (merits)
    ↓
ICJ_CASE (JUDGMENT_ISSUED)
    └── compliance tracking
```

### Workflow: Directive Distribution
```
DIRECTIVE (DRAFT)
    ↓ (issued)
DIRECTIVE (ISSUED)
    ↓
DIRECTIVE_ACKNOWLEDGMENT collected from OFFICERs
    ↓
DIRECTIVE (IN_EFFECT or all acknowledged)
    ↓ (when expiry_date reached)
DIRECTIVE (EXPIRED)
```

---

## Constraints & Validations

### CHECK Constraints
- `chk_organ_code`: organ_code must be in ('GA', 'SC', 'ECOSOC', 'ICJ', 'SEC', 'TC')
- `chk_region`: region must be in defined list
- `chk_permission_level`: 1-10 only
- `chk_security_level`: 1-5 only
- `chk_voting_threshold_range`: 50-100%

### UNIQUE Constraints
- `uk_matter_stage`: One stage number per matter
- `uk_matter_approver`: One approval per officer per matter per level
- `uk_matter_state_vote`: One vote per state per matter
- `uk_case_hearing`: One hearing number per case
- `uk_case_judge`: One judge assignment per case
- `uk_directive_officer`: One acknowledgment per officer per directive

### Foreign Key Cascades
- CASCADE DELETE on: MATTER_WORKFLOW, APPROVAL, VOTE, ICJ_HEARING, ICJ_CASE_JUDGE, DIRECTIVE_ACKNOWLEDGMENT
- SET NULL on: department.parent_department_id, officer.department_id, directive.target_department_id

### Submitted By Validation (MATTER)
```
CHECK (
    (submitted_by_delegate_id IS NOT NULL AND submitted_by_officer_id IS NULL) OR
    (submitted_by_delegate_id IS NULL AND submitted_by_officer_id IS NOT NULL)
)
```
Ensures either delegate OR officer submitted, never both or neither.

---

## Database Indexes

**Performance Indexes Created:**
- `idx_matter_status` on matter(status)
- `idx_matter_organ` on matter(organ_id)
- `idx_matter_type` on matter(matter_type)
- `idx_vote_matter` on vote(matter_id)
- `idx_resolution_organ` on resolution(organ_id)
- `idx_icj_case_status` on icj_case(status)
- `idx_directive_status` on directive(status)
- `idx_directive_dept` on directive(issuing_department_id)
- **AUDIT_LOG**: (table_name, record_id), (action_timestamp), (performed_by_officer_id)

---

## Project Structure

```
un-workflow-system/
├── database/
│   ├── 01_schema.sql          # DDL (this diagram source)
│   ├── 02_seed.sql            # Sample data
│   ├── 03_views.sql           # 8 reporting views
│   ├── 04_triggers.sql        # 9 automated triggers
│   ├── 05_procedures_cursors.sql  # 5 stored procedures + 2 functions
│   ├── 06_transactions_concurrency_demo.sql  # ACID demonstrations
│   └── 07_queries_chapter3.sql  # Complex analytics queries
├── backend/
│   ├── server.js              # Node.js Express server
│   ├── package.json           # Dependencies
│   ├── config/
│   │   └── db.js              # Database connection
│   └── routes/                # API endpoints
│       ├── audit.js
│       ├── dashboard.js
│       ├── icj.js
│       ├── matters.js
│       ├── organs.js
│       ├── resolutions.js
│       ├── secretariat.js
│       ├── trusteeship.js
│       └── voting.js
├── frontend/
│   ├── index.html
│   ├── css/
│   │   └── styles.css
│   └── js/
│       ├── api.js
│       └── app.js
└── report/
    ├── REPORT_CHAPTERS_1_2.md
    ├── REPORT_CHAPTERS_3_5.md
    └── REPORT_CHAPTERS_6_7.md
```

---

## Summary Statistics

| Aspect | Count |
|--------|-------|
| **Tables** | 21 |
| **Primary Keys** | 21 |
| **Foreign Keys** | 30+ |
| **Unique Constraints** | 12+ |
| **Check Constraints** | 5+ |
| **Views** | 8 |
| **Stored Procedures** | 5 |
| **Functions** | 2 |
| **Triggers** | 9 |
| **Audit Log Tracked** | All major entities |
| **Supported Languages** | English (UTF-8) |

---

## Notes

- The system uses **UTF-8mb4** for full Unicode support including special characters
- Timestamps track all record creation and modification
- Soft-delete patterns could be added (is_active flags)
- JSON columns store old/new values for comprehensive audit trails
- Supports weighted voting for different organizational structures
- Comprehensive audit trail via triggers for compliance/accountability
- Self-referencing department hierarchy supports organizational depth
- Ad hoc judge appointments supported in ICJ cases
