# UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM

## DATABASE MANAGEMENT SYSTEMS - MINI PROJECT REPORT

---

**STUDENT1 NAME [REG NO]**

**STUDENT2 NAME [REG NO]**

---

**Guide: GUIDE NAME / DESIGNATION**

**Specialization: SPECIALIZATION**

**Department of Computer Science and Engineering**

**SRM Institute of Science and Technology**

**Year: 2026**

---

## BONAFIDE CERTIFICATE

This is to certify that this project report titled **"United Nations Bureaucratic Workflow Management System"** is the bonafide work of *STUDENT1 NAME (REG NO)* and *STUDENT2 NAME (REG NO)* who carried out the project work under my supervision.

**SIGNATURE**

GUIDE NAME  
DESIGNATION  
Department of Computer Science

---

## ABSTRACT

The United Nations Bureaucratic Workflow Management System is a comprehensive database management system designed to model and automate the administrative workflows across the six principal organs of the United Nations: the General Assembly (GA), Security Council (SC), Economic and Social Council (ECOSOC), International Court of Justice (ICJ), United Nations Secretariat, and Trusteeship Council. Each organ handles specific types of bureaucratic matters with distinct procedural requirements.

This system facilitates the complete lifecycle management of UN matters including proposal/case submission, multi-step approval workflows, voting procedures (for GA/SC/ECOSOC), judgment issuance (for ICJ), directive management (for Secretariat), and oversight report handling (for Trusteeship Council). The database schema comprises 21 interconnected tables with comprehensive referential integrity, supporting entities such as member states, delegates, officers, matters, votes, resolutions, ICJ cases, directives, and audit logs.

The implementation includes advanced database features including MySQL stored procedures with cursors for vote computation, triggers for audit trail maintenance and business rule enforcement, and views for aggregated reporting. Transaction handling is implemented using proper ACID principles with concurrency control through row-level locking to prevent issues such as double-voting. The frontend provides a premium dark-themed interface with real-time data visualization, workflow tracking, and comprehensive matter management capabilities.

*Keywords: Database Management, UN Workflow, Multi-step Approval, Voting System, Audit Trail, MySQL*

---

## TABLE OF CONTENTS

1. CHAPTER 1: Problem Understanding, Entity Identification, ER Model
2. CHAPTER 2: Relational Schema, Database and Table Creation
3. CHAPTER 3: Complex Queries
4. CHAPTER 4: Normalization Analysis
5. CHAPTER 5: Concurrency Control and Recovery
6. CHAPTER 6: Frontend and Backend Code
7. CHAPTER 7: Results and Discussions

---

## LIST OF FIGURES

1. Figure 1.1: ER Diagram of UN Bureaucratic Workflow Management System
2. Figure 2.1: Relational Schema Diagram
3. Figure 7.1: Dashboard Screenshot
4. Figure 7.2: UN Organs Page
5. Figure 7.3: Matters Management Page
6. Figure 7.4: Voting Results Page
7. Figure 7.5: ICJ Cases Page
8. Figure 7.6: Database Schema in MySQL Workbench

---

## LIST OF TABLES

1. Table 2.1: un_organ Table Structure
2. Table 2.2: member_state Table Structure
3. Table 2.3: delegate Table Structure
4. Table 2.4: role Table Structure
5. Table 2.5: department Table Structure
6. Table 2.6: officer Table Structure
7. Table 2.7: matter Table Structure
8. Table 2.8: matter_workflow Table Structure
9. Table 2.9: approval Table Structure
10. Table 2.10: vote Table Structure
11. Table 2.11: resolution Table Structure
12. Table 2.12: icj_judge Table Structure
13. Table 2.13: icj_case Table Structure
14. Table 2.14: icj_hearing Table Structure
15. Table 2.15: icj_judgment Table Structure
16. Table 2.16: icj_case_judge Table Structure
17. Table 2.17: directive Table Structure
18. Table 2.18: directive_acknowledgment Table Structure
19. Table 2.19: trusteeship_territory Table Structure
20. Table 2.20: trusteeship_report Table Structure
21. Table 2.21: audit_log Table Structure

---

# CHAPTER 1
## PROBLEM UNDERSTANDING, IDENTIFICATION OF ENTITY AND RELATIONSHIPS, CONSTRUCTION OF DB USING ER MODEL FOR THE UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM

### 1.1 Introduction

The United Nations (UN) is an intergovernmental organization established in 1945 with 193 member states. The UN's principal organs—General Assembly, Security Council, Economic and Social Council, International Court of Justice, Secretariat, and Trusteeship Council—handle diverse bureaucratic processes including legislative matters, judicial proceedings, administrative directives, and oversight functions.

Currently, these workflows are managed through disparate systems with inconsistent tracking mechanisms. This project develops a unified Database Management System (DBMS) to standardize, automate, and audit all bureaucratic workflows across the six principal organs, ensuring transparency, accountability, and operational efficiency.

### 1.2 Motivation

The motivation for developing this system stems from several critical needs:

1. **Workflow Standardization**: Different UN organs follow varied procedural requirements. A unified system must accommodate these differences while maintaining consistent data management.

2. **Voting Integrity**: The General Assembly, Security Council, and ECOSOC conduct voting on resolutions. Preventing double-voting and ensuring accurate vote computation requires robust concurrency control.

3. **Judicial Record Management**: The ICJ handles complex cases requiring systematic tracking of hearings, judges, and judgments.

4. **Audit Trail**: All actions taken within the UN bureaucratic system must be logged for accountability and transparency.

5. **Multi-step Approval Workflows**: Matters progress through multiple approval stages, requiring systematic workflow state management.

### 1.3 Scope

**Included in Scope:**
- Database schema for all six UN principal organs
- Matter lifecycle management (draft → review → approval → voting → resolution)
- Voting system with threshold validation for GA, SC, and ECOSOC
- ICJ case management including judges, hearings, and judgments
- Secretariat directive issuance and acknowledgment tracking
- Trusteeship oversight reports and territory management
- Complete audit trail for all database operations
- Full-stack web application with premium UI

**Excluded from Scope:**
- Real-time video conferencing integration
- Document management system (attachment storage)
- Multi-language translation services
- External API integrations with member state systems

### 1.4 Problem Statement

Design and implement a comprehensive database management system that models the administrative workflows of the six principal United Nations organs, supporting matter submission, multi-step approvals, voting procedures with configurable thresholds, judicial proceedings, directive management, and oversight reporting while maintaining complete audit trails and ensuring concurrent operation integrity.

### 1.5 Project Requirements

#### 1.5.1 Functional Requirements

1. **UN Organ Management**: Store and manage details of all six principal UN organs with their establishment dates, descriptions, and operational status.

2. **Member State Management**: Maintain records of all 193 member states including admission dates, permanent/non-permanent status, and voting eligibility.

3. **Delegate Management**: Track delegates representing member states at various organs with their voting authority and credentials.

4. **Officer Management**: Manage UN officers across all organs with role-based permissions and department assignments.

5. **Matter Workflow**: Support complete matter lifecycle from submission through approval stages to voting and resolution issuance.

6. **Voting System**: Implement voting for GA/SC/ECOSOC with:
   - Vote values: YES, NO, ABSTAIN
   - Unique constraint: one vote per state per matter
   - Configurable voting thresholds (simple majority, two-thirds)
   - Veto power for SC permanent members

7. **Resolution Issuance**: Automatically generate resolutions upon successful voting with proper numbering schemes.

8. **ICJ Case Management**: Handle contentious cases and advisory opinions with judge assignments, hearing scheduling, and judgment issuance.

9. **Directive Management**: Support Secretariat directives with department-level acknowledgment tracking.

10. **Trusteeship Reporting**: Manage trust territories and oversight reports with review and decision procedures.

11. **Audit Logging**: Automatically log all INSERT, UPDATE, and DELETE operations with timestamp and user tracking.

#### 1.5.2 Non-Functional Requirements

1. **Data Integrity**: Enforce referential integrity through foreign key constraints.
2. **Concurrency Control**: Prevent race conditions during voting using row-level locking.
3. **Scalability**: Support 193 member states with thousands of matters and votes.
4. **Performance**: Response time under 2 seconds for standard queries.
5. **Auditability**: Complete trail of all system actions.
6. **Usability**: Intuitive web interface with modern design aesthetics.

### 1.6 Identification of Entity and Relationships

#### 1.6.1 Entity List

| Entity | Description |
|--------|-------------|
| un_organ | Six principal organs of the UN |
| member_state | 193 UN member countries |
| delegate | Representatives of member states |
| role | Permission-based roles for officers |
| department | Secretariat departments |
| officer | UN employees with specific roles |
| matter | Case files/proposals processed by organs |
| matter_workflow | Stages in matter processing |
| approval | Approval decisions at each level |
| vote | Individual votes cast on matters |
| resolution | Passed resolutions from voting organs |
| icj_judge | International Court of Justice judges |
| icj_case | Cases before the ICJ |
| icj_hearing | Court hearings for cases |
| icj_judgment | Final judgments issued |
| icj_case_judge | Judge assignments to cases |
| directive | Secretariat administrative orders |
| directive_acknowledgment | Department acknowledgments |
| trusteeship_territory | Trust territories under TC |
| trusteeship_report | Oversight reports for territories |
| audit_log | System action audit trail |

#### 1.6.2 Relationship List with Cardinalities

| Relationship | Entities | Cardinality |
|--------------|----------|-------------|
| Organ has Matters | un_organ → matter | 1:N |
| Organ has Officers | un_organ → officer | 1:N |
| State has Delegates | member_state → delegate | 1:N |
| State administers Territories | member_state → trusteeship_territory | 1:N |
| Delegate represents at Organ | delegate → un_organ | N:1 |
| Officer has Role | officer → role | N:1 |
| Officer belongs to Department | officer → department | N:1 |
| Matter has Workflow Stages | matter → matter_workflow | 1:N |
| Matter requires Approvals | matter → approval | 1:N |
| Matter receives Votes | matter → vote | 1:N |
| Matter produces Resolution | matter → resolution | 1:1 |
| Vote cast by State | vote → member_state | N:1 |
| Vote cast by Delegate | vote → delegate | N:1 |
| Case has Hearings | icj_case → icj_hearing | 1:N |
| Case has Judgments | icj_case → icj_judgment | 1:N |
| Case assigned Judges | icj_case ↔ icj_judge | M:N |
| Directive issued by Department | directive → department | N:1 |
| Directive acknowledged by Officers | directive ↔ officer | M:N |
| Territory has Reports | trusteeship_territory → trusteeship_report | 1:N |

### 1.7 Construction of DB Using ER Model

#### Figure 1.1: ER Diagram Description

The ER diagram for the UN Bureaucratic Workflow Management System consists of the following components:

**Central Entities:**
- `un_organ` (rectangle) at the center, connected to all organ-specific entities
- `matter` (rectangle) connected to workflow, approval, vote, and resolution entities

**Relationships (diamonds):**
- "processes" connecting un_organ to matter (1:N)
- "submits" connecting delegate to matter (N:1)
- "casts" connecting delegate to vote with vote entity (1:N)
- "approves" connecting officer to approval (1:N)
- "produces" connecting matter to resolution (1:1)

**Attributes (ovals):**
- Primary keys underlined (organ_id, matter_id, vote_id, etc.)
- Multi-valued attributes with double ovals (none in this schema)
- Derived attributes with dashed ovals (vote_count in matter as calculated)

**Cardinality Notation:**
- 1 on "one" side of relationships
- N on "many" side of relationships
- M:N for many-to-many (icj_case_judge, directive_acknowledgment)

**Weak Entities (double rectangle):**
- matter_workflow (depends on matter)
- icj_hearing (depends on icj_case)

**Specialization/Generalization:**
- matter specializes into PROPOSAL (for GA/SC/ECOSOC), CASE_REFERRAL (for ICJ), DIRECTIVE_REQUEST (for SEC), OVERSIGHT_MATTER (for TC)

*The ER diagram should be created in MySQL Workbench using the EER Diagram tool, placing un_organ at the center with spoke connections to each organ-specific entity cluster.*

---

# CHAPTER 2
## DESIGN OF RELATIONAL SCHEMAS, CREATION OF DATABASE AND TABLES FOR UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM

### 2.1 Relational Schema

#### Figure 2.1: Schema Diagram Description

The relational schema diagram shows all 21 tables with their primary keys (PK marked), foreign keys (FK marked), and relationships:

```
un_organ(organ_id PK, organ_code, organ_name, headquarters, established_year, is_active)
    ↓ 1:N
member_state(state_id PK, state_code, state_name, capital_city, admission_date, region, is_permanent_sc_member)
    ↓ 1:N
delegate(delegate_id PK, state_id FK, organ_id FK, first_name, last_name, title, credentials, voting_authority)
    ↓ N:1
role(role_id PK, role_name, permission_level, can_approve, can_vote)
    ↓ 1:N
department(department_id PK, department_name, parent_department_id FK)
    ↓ 1:N
officer(officer_id PK, organ_id FK, department_id FK, role_id FK, first_name, last_name, email, hire_date)
    ↓ 1:N
matter(matter_id PK, matter_number, title, organ_id FK, submitted_by_delegate_id FK, status, requires_voting)
    ↓ 1:N
matter_workflow(workflow_id PK, matter_id FK, stage_number, stage_name, stage_status)
    ↓ 1:N
approval(approval_id PK, matter_id FK, approver_officer_id FK, approval_level, approval_status)
    ↓ 1:N
vote(vote_id PK, matter_id FK, state_id FK, delegate_id FK, vote_value, vote_timestamp)
    UNIQUE(matter_id, state_id)
    ↓ 1:1
resolution(resolution_id PK, resolution_number, matter_id FK, organ_id FK, adoption_date, yes_votes, no_votes)
```

*Additional ICJ, Secretariat, Trusteeship, and Audit tables connect similarly based on their foreign key relationships.*

### 2.2 Description of Tables

#### Table 2.1: un_organ

| Column | Data Type | Size | Constraints |
|--------|-----------|------|-------------|
| organ_id | INT | - | PRIMARY KEY, AUTO_INCREMENT |
| organ_code | VARCHAR | 10 | NOT NULL, UNIQUE |
| organ_name | VARCHAR | 100 | NOT NULL |
| headquarters | VARCHAR | 100 | DEFAULT 'New York' |
| established_year | INT | - | NOT NULL, CHECK (>= 1945) |
| description | TEXT | - | - |
| is_active | BOOLEAN | - | DEFAULT TRUE |
| created_at | TIMESTAMP | - | DEFAULT CURRENT_TIMESTAMP |

#### Table 2.7: matter

| Column | Data Type | Size | Constraints |
|--------|-----------|------|-------------|
| matter_id | INT | - | PRIMARY KEY, AUTO_INCREMENT |
| matter_number | VARCHAR | 50 | NOT NULL, UNIQUE |
| title | VARCHAR | 255 | NOT NULL |
| description | TEXT | - | - |
| matter_type | ENUM | - | 'PROPOSAL', 'CASE_REFERRAL', 'DIRECTIVE_REQUEST', 'OVERSIGHT_MATTER' |
| organ_id | INT | - | FOREIGN KEY → un_organ |
| submitted_by_delegate_id | INT | - | FOREIGN KEY → delegate |
| submitted_by_officer_id | INT | - | FOREIGN KEY → officer |
| priority | ENUM | - | 'LOW', 'NORMAL', 'HIGH', 'URGENT' |
| status | ENUM | - | 'DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'PENDING_APPROVAL', 'IN_VOTING', 'PASSED', 'REJECTED' |
| submission_date | DATE | - | NOT NULL |
| requires_voting | BOOLEAN | - | DEFAULT FALSE |
| voting_threshold | INT | - | DEFAULT 50 |

#### Table 2.10: vote

| Column | Data Type | Size | Constraints |
|--------|-----------|------|-------------|
| vote_id | INT | - | PRIMARY KEY, AUTO_INCREMENT |
| matter_id | INT | - | FOREIGN KEY → matter, NOT NULL |
| state_id | INT | - | FOREIGN KEY → member_state, NOT NULL |
| delegate_id | INT | - | FOREIGN KEY → delegate, NOT NULL |
| vote_value | ENUM | - | 'YES', 'NO', 'ABSTAIN', NOT NULL |
| vote_timestamp | TIMESTAMP | - | DEFAULT CURRENT_TIMESTAMP |
| is_valid | BOOLEAN | - | DEFAULT TRUE |
| invalidation_reason | VARCHAR | 255 | - |
| - | CONSTRAINT | - | UNIQUE(matter_id, state_id) |

*Similar detailed table structures exist for all 21 tables in the database.*

### 2.3 Creation of Database and Tables – DDL Commands

```sql
-- Create Database
CREATE DATABASE IF NOT EXISTS un_workflow_db;
USE un_workflow_db;

-- Table: un_organ
CREATE TABLE un_organ (
    organ_id INT AUTO_INCREMENT PRIMARY KEY,
    organ_code VARCHAR(10) NOT NULL UNIQUE,
    organ_name VARCHAR(100) NOT NULL,
    headquarters VARCHAR(100) DEFAULT 'New York, USA',
    established_year INT NOT NULL CHECK (established_year >= 1945),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: member_state
CREATE TABLE member_state (
    state_id INT AUTO_INCREMENT PRIMARY KEY,
    state_code VARCHAR(5) NOT NULL UNIQUE,
    state_name VARCHAR(100) NOT NULL,
    capital_city VARCHAR(100),
    admission_date DATE NOT NULL,
    region VARCHAR(50),
    is_permanent_sc_member BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Table: matter (with all constraints)
CREATE TABLE matter (
    matter_id INT AUTO_INCREMENT PRIMARY KEY,
    matter_number VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    matter_type ENUM('PROPOSAL', 'CASE_REFERRAL', 'DIRECTIVE_REQUEST', 'OVERSIGHT_MATTER'),
    organ_id INT NOT NULL,
    submitted_by_delegate_id INT,
    submitted_by_officer_id INT,
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL',
    status ENUM('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'PENDING_APPROVAL', 'IN_VOTING', 'PASSED', 'REJECTED', 'CLOSED') DEFAULT 'DRAFT',
    submission_date DATE NOT NULL,
    requires_voting BOOLEAN DEFAULT FALSE,
    voting_threshold INT DEFAULT 50 CHECK (voting_threshold >= 0 AND voting_threshold <= 100),
    FOREIGN KEY (organ_id) REFERENCES un_organ(organ_id),
    FOREIGN KEY (submitted_by_delegate_id) REFERENCES delegate(delegate_id),
    FOREIGN KEY (submitted_by_officer_id) REFERENCES officer(officer_id)
);

-- Table: vote (with UNIQUE constraint to prevent double voting)
CREATE TABLE vote (
    vote_id INT AUTO_INCREMENT PRIMARY KEY,
    matter_id INT NOT NULL,
    state_id INT NOT NULL,
    delegate_id INT NOT NULL,
    vote_value ENUM('YES', 'NO', 'ABSTAIN') NOT NULL,
    vote_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT TRUE,
    invalidation_reason VARCHAR(255),
    FOREIGN KEY (matter_id) REFERENCES matter(matter_id),
    FOREIGN KEY (state_id) REFERENCES member_state(state_id),
    FOREIGN KEY (delegate_id) REFERENCES delegate(delegate_id),
    UNIQUE KEY unique_vote (matter_id, state_id)
);
```

*Complete DDL for all 21 tables is available in database/01_schema.sql*

### 2.4 Insertion of Tuples – DML Commands

```sql
-- Insert UN Organs
INSERT INTO un_organ (organ_code, organ_name, headquarters, established_year, description) VALUES
('GA', 'General Assembly', 'New York, USA', 1945, 'The main deliberative, policymaking, and representative organ'),
('SC', 'Security Council', 'New York, USA', 1945, 'Primary responsibility for international peace and security'),
('ECOSOC', 'Economic and Social Council', 'New York, USA', 1945, 'Coordination of economic and social work'),
('ICJ', 'International Court of Justice', 'The Hague, Netherlands', 1945, 'Principal judicial organ'),
('SEC', 'United Nations Secretariat', 'New York, USA', 1945, 'Administrative functions'),
('TC', 'Trusteeship Council', 'New York, USA', 1945, 'Oversight of trust territories');

-- Insert Member States (sample)
INSERT INTO member_state (state_code, state_name, capital_city, admission_date, region, is_permanent_sc_member) VALUES
('USA', 'United States of America', 'Washington, D.C.', '1945-10-24', 'Americas', TRUE),
('GBR', 'United Kingdom', 'London', '1945-10-24', 'Europe', TRUE),
('FRA', 'France', 'Paris', '1945-10-24', 'Europe', TRUE),
('RUS', 'Russian Federation', 'Moscow', '1945-10-24', 'Europe', TRUE),
('CHN', 'China', 'Beijing', '1945-10-24', 'Asia-Pacific', TRUE),
('IND', 'India', 'New Delhi', '1945-10-30', 'Asia-Pacific', FALSE),
('BRA', 'Brazil', 'Brasília', '1945-10-24', 'Americas', FALSE),
('GER', 'Germany', 'Berlin', '1973-09-18', 'Europe', FALSE),
('JPN', 'Japan', 'Tokyo', '1956-12-18', 'Asia-Pacific', FALSE);

-- Insert Votes (sample)
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES
(1, 1, 1, 'YES'),   -- USA votes YES on matter 1
(1, 2, 2, 'YES'),   -- UK votes YES on matter 1
(1, 3, 3, 'YES'),   -- France votes YES on matter 1
(1, 4, 4, 'NO'),    -- Russia votes NO on matter 1
(1, 5, 5, 'ABSTAIN'); -- China abstains on matter 1
```

*Complete DML for all tables with sample data is available in database/02_seed.sql*

---

*[Report continues in subsequent chapters...]*
