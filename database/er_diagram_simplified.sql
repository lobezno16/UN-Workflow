-- ============================================================================
-- SIMPLIFIED ER DIAGRAM SCHEMA
-- (Temporary file - safe to delete after generating the diagram)
-- ============================================================================
-- UN = Main Entity → 6 Organs = Sub-Entities (with attributes, no extra tables)
-- ============================================================================

DROP DATABASE IF EXISTS un_er_diagram_db;
CREATE DATABASE un_er_diagram_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE un_er_diagram_db;

-- ============================================================================
-- MAIN ENTITY: United Nations
-- ============================================================================
CREATE TABLE united_nations (
    un_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL DEFAULT 'United Nations',
    established_year INT NOT NULL DEFAULT 1945,
    headquarters VARCHAR(100) DEFAULT 'New York, USA',
    total_member_states INT DEFAULT 193,
    charter_signed_date DATE
);

-- ============================================================================
-- SUB-ENTITY 1: General Assembly
-- ============================================================================
CREATE TABLE general_assembly (
    ga_id INT PRIMARY KEY AUTO_INCREMENT,
    un_id INT NOT NULL,
    session_number INT,
    session_year INT,
    president_name VARCHAR(100),
    total_members INT DEFAULT 193,
    resolutions_adopted INT,
    voting_system VARCHAR(50) DEFAULT 'One State One Vote',
    CONSTRAINT fk_ga_un FOREIGN KEY (un_id) REFERENCES united_nations(un_id)
);

-- ============================================================================
-- SUB-ENTITY 2: Security Council
-- ============================================================================
CREATE TABLE security_council (
    sc_id INT PRIMARY KEY AUTO_INCREMENT,
    un_id INT NOT NULL,
    total_members INT DEFAULT 15,
    permanent_members INT DEFAULT 5,
    non_permanent_members INT DEFAULT 10,
    has_veto_power BOOLEAN DEFAULT TRUE,
    resolutions_adopted INT,
    binding_authority BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_sc_un FOREIGN KEY (un_id) REFERENCES united_nations(un_id)
);

-- ============================================================================
-- SUB-ENTITY 3: Economic and Social Council (ECOSOC)
-- ============================================================================
CREATE TABLE economic_and_social_council (
    ecosoc_id INT PRIMARY KEY AUTO_INCREMENT,
    un_id INT NOT NULL,
    total_members INT DEFAULT 54,
    session_year INT,
    president_name VARCHAR(100),
    subsidiary_bodies INT,
    resolutions_adopted INT,
    CONSTRAINT fk_ecosoc_un FOREIGN KEY (un_id) REFERENCES united_nations(un_id)
);

-- ============================================================================
-- SUB-ENTITY 4: International Court of Justice (ICJ)
-- ============================================================================
CREATE TABLE international_court_of_justice (
    icj_id INT PRIMARY KEY AUTO_INCREMENT,
    un_id INT NOT NULL,
    seat VARCHAR(100) DEFAULT 'The Hague, Netherlands',
    total_judges INT DEFAULT 15,
    president_name VARCHAR(100),
    pending_cases INT,
    judgments_delivered INT,
    advisory_opinions_given INT,
    CONSTRAINT fk_icj_un FOREIGN KEY (un_id) REFERENCES united_nations(un_id)
);

-- ============================================================================
-- SUB-ENTITY 5: UN Secretariat
-- ============================================================================
CREATE TABLE un_secretariat (
    sec_id INT PRIMARY KEY AUTO_INCREMENT,
    un_id INT NOT NULL,
    secretary_general_name VARCHAR(100),
    total_staff INT,
    total_departments INT,
    directives_issued INT,
    administrative_role VARCHAR(100) DEFAULT 'Chief Administrative Officer',
    CONSTRAINT fk_sec_un FOREIGN KEY (un_id) REFERENCES united_nations(un_id)
);

-- ============================================================================
-- SUB-ENTITY 6: Trusteeship Council
-- ============================================================================
CREATE TABLE trusteeship_council (
    tc_id INT PRIMARY KEY AUTO_INCREMENT,
    un_id INT NOT NULL,
    established_year INT DEFAULT 1945,
    suspended_year INT DEFAULT 1994,
    territories_administered INT,
    territories_independent INT,
    reports_submitted INT,
    current_status VARCHAR(50) DEFAULT 'Suspended',
    CONSTRAINT fk_tc_un FOREIGN KEY (un_id) REFERENCES united_nations(un_id)
);

-- ============================================================================
-- END OF SIMPLIFIED SCHEMA (7 tables total)
-- united_nations ──┬── general_assembly
--                  ├── security_council
--                  ├── economic_and_social_council
--                  ├── international_court_of_justice
--                  ├── un_secretariat
--                  └── trusteeship_council
-- ============================================================================
