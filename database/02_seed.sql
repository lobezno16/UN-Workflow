-- ============================================================================
-- UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
-- 02_seed.sql - Sample Data (DML)
-- ============================================================================
-- Updated March 2026 with current events and expanded data for comprehensive
-- query demonstrations covering constraints, aggregates, sets, subqueries,
-- joins, views, triggers, and cursors.
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
-- MEMBER STATES (All 193 UN Member States)
-- ============================================================================
-- First 20 states (state_id 1-20) - ORDER IS CRITICAL, referenced by FK
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
('CAN', 'Canada', 'Western Europe and Others', '1945-11-09', FALSE, 2.628),
('KOR', 'Republic of Korea', 'Asia-Pacific', '1991-09-17', FALSE, 2.574),
('SAU', 'Saudi Arabia', 'Asia-Pacific', '1945-10-24', FALSE, 1.184),
('ARG', 'Argentina', 'Latin America and Caribbean', '1945-10-24', FALSE, 0.719),
('IDN', 'Indonesia', 'Asia-Pacific', '1950-09-28', FALSE, 0.549),
('POL', 'Poland', 'Eastern Europe', '1945-10-24', FALSE, 0.837);

-- Remaining 173 states (state_id 21-193) - alphabetical
-- ── AFRICA (remaining 51) ──
INSERT INTO member_state (state_code, state_name, region, admission_date, is_sc_permanent_member, contribution_percentage) VALUES
('DZA', 'Algeria', 'Africa', '1962-10-08', FALSE, 0.109),
('AGO', 'Angola', 'Africa', '1976-12-01', FALSE, 0.010),
('BEN', 'Benin', 'Africa', '1960-09-20', FALSE, 0.005),
('BWA', 'Botswana', 'Africa', '1966-10-17', FALSE, 0.015),
('BFA', 'Burkina Faso', 'Africa', '1960-09-20', FALSE, 0.004),
('BDI', 'Burundi', 'Africa', '1962-09-18', FALSE, 0.001),
('CPV', 'Cabo Verde', 'Africa', '1975-09-16', FALSE, 0.001),
('CMR', 'Cameroon', 'Africa', '1960-09-20', FALSE, 0.013),
('CAF', 'Central African Republic', 'Africa', '1960-09-20', FALSE, 0.001),
('TCD', 'Chad', 'Africa', '1960-09-20', FALSE, 0.004),
('COM', 'Comoros', 'Africa', '1975-11-12', FALSE, 0.001),
('COG', 'Congo', 'Africa', '1960-09-20', FALSE, 0.006),
('CIV', 'Côte d''Ivoire', 'Africa', '1960-09-20', FALSE, 0.018),
('COD', 'Democratic Republic of the Congo', 'Africa', '1960-09-20', FALSE, 0.010),
('DJI', 'Djibouti', 'Africa', '1977-09-20', FALSE, 0.001),
('GNQ', 'Equatorial Guinea', 'Africa', '1968-11-12', FALSE, 0.012),
('ERI', 'Eritrea', 'Africa', '1993-05-28', FALSE, 0.001),
('SWZ', 'Eswatini', 'Africa', '1968-09-24', FALSE, 0.002),
('ETH', 'Ethiopia', 'Africa', '1945-11-13', FALSE, 0.010),
('GAB', 'Gabon', 'Africa', '1960-09-20', FALSE, 0.013),
('GMB', 'Gambia', 'Africa', '1965-09-21', FALSE, 0.001),
('GHA', 'Ghana', 'Africa', '1957-03-08', FALSE, 0.024),
('GIN', 'Guinea', 'Africa', '1958-12-12', FALSE, 0.003),
('GNB', 'Guinea-Bissau', 'Africa', '1974-09-17', FALSE, 0.001),
('KEN', 'Kenya', 'Africa', '1963-12-16', FALSE, 0.030),
('LSO', 'Lesotho', 'Africa', '1966-10-17', FALSE, 0.001),
('LBR', 'Liberia', 'Africa', '1945-11-02', FALSE, 0.001),
('LBY', 'Libya', 'Africa', '1955-12-14', FALSE, 0.018),
('MDG', 'Madagascar', 'Africa', '1960-09-20', FALSE, 0.004),
('MWI', 'Malawi', 'Africa', '1964-12-01', FALSE, 0.002),
('MLI', 'Mali', 'Africa', '1960-09-28', FALSE, 0.004),
('MRT', 'Mauritania', 'Africa', '1961-10-27', FALSE, 0.002),
('MUS', 'Mauritius', 'Africa', '1968-04-24', FALSE, 0.011),
('MAR', 'Morocco', 'Africa', '1956-11-12', FALSE, 0.055),
('MOZ', 'Mozambique', 'Africa', '1975-09-16', FALSE, 0.004),
('NAM', 'Namibia', 'Africa', '1990-04-23', FALSE, 0.009),
('NER', 'Niger', 'Africa', '1960-09-20', FALSE, 0.002),
('RWA', 'Rwanda', 'Africa', '1962-09-18', FALSE, 0.003),
('STP', 'São Tomé and Príncipe', 'Africa', '1975-09-16', FALSE, 0.001),
('SEN', 'Senegal', 'Africa', '1960-09-28', FALSE, 0.007),
('SYC', 'Seychelles', 'Africa', '1976-09-21', FALSE, 0.002),
('SLE', 'Sierra Leone', 'Africa', '1961-09-27', FALSE, 0.001),
('SOM', 'Somalia', 'Africa', '1960-09-20', FALSE, 0.001),
('SSD', 'South Sudan', 'Africa', '2011-07-14', FALSE, 0.002),
('SDN', 'Sudan', 'Africa', '1956-11-12', FALSE, 0.010),
('TZA', 'United Republic of Tanzania', 'Africa', '1961-12-14', FALSE, 0.010),
('TGO', 'Togo', 'Africa', '1960-09-20', FALSE, 0.002),
('TUN', 'Tunisia', 'Africa', '1956-11-12', FALSE, 0.019),
('UGA', 'Uganda', 'Africa', '1962-10-25', FALSE, 0.008),
('ZMB', 'Zambia', 'Africa', '1964-12-01', FALSE, 0.006),
('ZWE', 'Zimbabwe', 'Africa', '1980-08-25', FALSE, 0.007);

-- ── ASIA-PACIFIC (remaining 44) ──
INSERT INTO member_state (state_code, state_name, region, admission_date, is_sc_permanent_member, contribution_percentage) VALUES
('AFG', 'Afghanistan', 'Asia-Pacific', '1946-11-19', FALSE, 0.006),
('BHR', 'Bahrain', 'Asia-Pacific', '1971-09-21', FALSE, 0.054),
('BGD', 'Bangladesh', 'Asia-Pacific', '1974-09-17', FALSE, 0.010),
('BTN', 'Bhutan', 'Asia-Pacific', '1971-09-21', FALSE, 0.001),
('BRN', 'Brunei Darussalam', 'Asia-Pacific', '1984-09-21', FALSE, 0.021),
('KHM', 'Cambodia', 'Asia-Pacific', '1955-12-14', FALSE, 0.006),
('CYP', 'Cyprus', 'Asia-Pacific', '1960-09-20', FALSE, 0.036),
('PRK', 'Democratic People''s Republic of Korea', 'Asia-Pacific', '1991-09-17', FALSE, 0.005),
('FJI', 'Fiji', 'Asia-Pacific', '1970-10-13', FALSE, 0.004),
('IRN', 'Iran (Islamic Republic of)', 'Asia-Pacific', '1945-10-24', FALSE, 0.371),
('IRQ', 'Iraq', 'Asia-Pacific', '1945-12-21', FALSE, 0.128),
('JOR', 'Jordan', 'Asia-Pacific', '1955-12-14', FALSE, 0.022),
('KAZ', 'Kazakhstan', 'Asia-Pacific', '1992-03-02', FALSE, 0.133),
('KIR', 'Kiribati', 'Asia-Pacific', '1999-09-14', FALSE, 0.001),
('KWT', 'Kuwait', 'Asia-Pacific', '1963-05-14', FALSE, 0.234),
('KGZ', 'Kyrgyzstan', 'Asia-Pacific', '1992-03-02', FALSE, 0.002),
('LAO', 'Lao People''s Democratic Republic', 'Asia-Pacific', '1955-12-14', FALSE, 0.007),
('LBN', 'Lebanon', 'Asia-Pacific', '1945-10-24', FALSE, 0.024),
('MYS', 'Malaysia', 'Asia-Pacific', '1957-09-17', FALSE, 0.348),
('MDV', 'Maldives', 'Asia-Pacific', '1965-09-21', FALSE, 0.004),
('MHL', 'Marshall Islands', 'Asia-Pacific', '1991-09-17', FALSE, 0.001),
('FSM', 'Micronesia (Federated States of)', 'Asia-Pacific', '1991-09-17', FALSE, 0.001),
('MNG', 'Mongolia', 'Asia-Pacific', '1961-10-27', FALSE, 0.005),
('MMR', 'Myanmar', 'Asia-Pacific', '1948-04-19', FALSE, 0.010),
('NRU', 'Nauru', 'Asia-Pacific', '1999-09-14', FALSE, 0.001),
('NPL', 'Nepal', 'Asia-Pacific', '1955-12-14', FALSE, 0.007),
('NZL', 'New Zealand', 'Asia-Pacific', '1945-10-24', FALSE, 0.291),
('OMN', 'Oman', 'Asia-Pacific', '1971-10-07', FALSE, 0.111),
('PAK', 'Pakistan', 'Asia-Pacific', '1947-09-30', FALSE, 0.115),
('PLW', 'Palau', 'Asia-Pacific', '1994-12-15', FALSE, 0.001),
('PNG', 'Papua New Guinea', 'Asia-Pacific', '1975-10-10', FALSE, 0.010),
('PHL', 'Philippines', 'Asia-Pacific', '1945-10-24', FALSE, 0.212),
('QAT', 'Qatar', 'Asia-Pacific', '1971-09-21', FALSE, 0.269),
('WSM', 'Samoa', 'Asia-Pacific', '1976-12-15', FALSE, 0.001),
('SGP', 'Singapore', 'Asia-Pacific', '1965-09-21', FALSE, 0.504),
('SLB', 'Solomon Islands', 'Asia-Pacific', '1978-09-19', FALSE, 0.001),
('LKA', 'Sri Lanka', 'Asia-Pacific', '1955-12-14', FALSE, 0.044),
('SYR', 'Syrian Arab Republic', 'Asia-Pacific', '1945-10-24', FALSE, 0.009),
('TJK', 'Tajikistan', 'Asia-Pacific', '1992-03-02', FALSE, 0.002),
('THA', 'Thailand', 'Asia-Pacific', '1946-12-16', FALSE, 0.307),
('TLS', 'Timor-Leste', 'Asia-Pacific', '2002-09-27', FALSE, 0.001),
('TON', 'Tonga', 'Asia-Pacific', '1999-09-14', FALSE, 0.001),
('TKM', 'Turkmenistan', 'Asia-Pacific', '1992-03-02', FALSE, 0.034),
('TUV', 'Tuvalu', 'Asia-Pacific', '2000-09-05', FALSE, 0.001),
('ARE', 'United Arab Emirates', 'Asia-Pacific', '1971-12-09', FALSE, 0.635),
('UZB', 'Uzbekistan', 'Asia-Pacific', '1992-03-02', FALSE, 0.027),
('VUT', 'Vanuatu', 'Asia-Pacific', '1981-09-15', FALSE, 0.001),
('VNM', 'Viet Nam', 'Asia-Pacific', '1977-09-20', FALSE, 0.093),
('YEM', 'Yemen', 'Asia-Pacific', '1947-09-30', FALSE, 0.008);

-- ── EASTERN EUROPE (remaining 22) ──
INSERT INTO member_state (state_code, state_name, region, admission_date, is_sc_permanent_member, contribution_percentage) VALUES
('ALB', 'Albania', 'Eastern Europe', '1955-12-14', FALSE, 0.008),
('ARM', 'Armenia', 'Eastern Europe', '1992-03-02', FALSE, 0.007),
('AZE', 'Azerbaijan', 'Eastern Europe', '1992-03-09', FALSE, 0.049),
('BLR', 'Belarus', 'Eastern Europe', '1945-10-24', FALSE, 0.041),
('BIH', 'Bosnia and Herzegovina', 'Eastern Europe', '1992-05-22', FALSE, 0.012),
('BGR', 'Bulgaria', 'Eastern Europe', '1955-12-14', FALSE, 0.056),
('HRV', 'Croatia', 'Eastern Europe', '1992-05-22', FALSE, 0.077),
('CZE', 'Czechia', 'Eastern Europe', '1993-01-19', FALSE, 0.340),
('EST', 'Estonia', 'Eastern Europe', '1991-09-17', FALSE, 0.039),
('GEO', 'Georgia', 'Eastern Europe', '1992-07-31', FALSE, 0.008),
('HUN', 'Hungary', 'Eastern Europe', '1955-12-14', FALSE, 0.228),
('LVA', 'Latvia', 'Eastern Europe', '1991-09-17', FALSE, 0.031),
('LTU', 'Lithuania', 'Eastern Europe', '1991-09-17', FALSE, 0.041),
('MDA', 'Republic of Moldova', 'Eastern Europe', '1992-03-02', FALSE, 0.005),
('MNE', 'Montenegro', 'Eastern Europe', '2006-06-28', FALSE, 0.004),
('MKD', 'North Macedonia', 'Eastern Europe', '1993-04-08', FALSE, 0.007),
('ROU', 'Romania', 'Eastern Europe', '1955-12-14', FALSE, 0.198),
('SRB', 'Serbia', 'Eastern Europe', '2000-11-01', FALSE, 0.032),
('SVK', 'Slovakia', 'Eastern Europe', '1993-01-19', FALSE, 0.155),
('SVN', 'Slovenia', 'Eastern Europe', '1992-05-22', FALSE, 0.079),
('UKR', 'Ukraine', 'Eastern Europe', '1945-10-24', FALSE, 0.056);

-- ── LATIN AMERICA AND CARIBBEAN (remaining 31) ──
INSERT INTO member_state (state_code, state_name, region, admission_date, is_sc_permanent_member, contribution_percentage) VALUES
('ATG', 'Antigua and Barbuda', 'Latin America and Caribbean', '1981-11-11', FALSE, 0.002),
('BHS', 'Bahamas', 'Latin America and Caribbean', '1973-09-18', FALSE, 0.019),
('BRB', 'Barbados', 'Latin America and Caribbean', '1966-12-09', FALSE, 0.008),
('BLZ', 'Belize', 'Latin America and Caribbean', '1981-09-25', FALSE, 0.001),
('BOL', 'Bolivia (Plurinational State of)', 'Latin America and Caribbean', '1945-11-14', FALSE, 0.016),
('CHL', 'Chile', 'Latin America and Caribbean', '1945-10-24', FALSE, 0.407),
('COL', 'Colombia', 'Latin America and Caribbean', '1945-11-05', FALSE, 0.246),
('CRI', 'Costa Rica', 'Latin America and Caribbean', '1945-11-02', FALSE, 0.069),
('CUB', 'Cuba', 'Latin America and Caribbean', '1945-10-24', FALSE, 0.095),
('DMA', 'Dominica', 'Latin America and Caribbean', '1978-12-18', FALSE, 0.001),
('DOM', 'Dominican Republic', 'Latin America and Caribbean', '1945-10-24', FALSE, 0.067),
('ECU', 'Ecuador', 'Latin America and Caribbean', '1945-12-21', FALSE, 0.077),
('SLV', 'El Salvador', 'Latin America and Caribbean', '1945-10-24', FALSE, 0.013),
('GRD', 'Grenada', 'Latin America and Caribbean', '1974-09-17', FALSE, 0.001),
('GTM', 'Guatemala', 'Latin America and Caribbean', '1945-11-21', FALSE, 0.036),
('GUY', 'Guyana', 'Latin America and Caribbean', '1966-09-20', FALSE, 0.004),
('HTI', 'Haiti', 'Latin America and Caribbean', '1945-10-24', FALSE, 0.006),
('HND', 'Honduras', 'Latin America and Caribbean', '1945-12-17', FALSE, 0.012),
('JAM', 'Jamaica', 'Latin America and Caribbean', '1962-09-18', FALSE, 0.009),
('NIC', 'Nicaragua', 'Latin America and Caribbean', '1945-10-24', FALSE, 0.005),
('PAN', 'Panama', 'Latin America and Caribbean', '1945-11-13', FALSE, 0.090),
('PRY', 'Paraguay', 'Latin America and Caribbean', '1945-10-24', FALSE, 0.014),
('PER', 'Peru', 'Latin America and Caribbean', '1945-10-31', FALSE, 0.163),
('KNA', 'Saint Kitts and Nevis', 'Latin America and Caribbean', '1983-09-23', FALSE, 0.002),
('LCA', 'Saint Lucia', 'Latin America and Caribbean', '1979-09-18', FALSE, 0.002),
('VCT', 'Saint Vincent and the Grenadines', 'Latin America and Caribbean', '1980-09-16', FALSE, 0.001),
('SUR', 'Suriname', 'Latin America and Caribbean', '1975-12-04', FALSE, 0.003),
('TTO', 'Trinidad and Tobago', 'Latin America and Caribbean', '1962-09-18', FALSE, 0.037),
('URY', 'Uruguay', 'Latin America and Caribbean', '1945-12-18', FALSE, 0.087),
('VEN', 'Venezuela (Bolivarian Republic of)', 'Latin America and Caribbean', '1945-11-15', FALSE, 0.175);

-- ── WESTERN EUROPE AND OTHERS (remaining 18) ──
INSERT INTO member_state (state_code, state_name, region, admission_date, is_sc_permanent_member, contribution_percentage) VALUES
('AND', 'Andorra', 'Western Europe and Others', '1993-07-28', FALSE, 0.005),
('AUT', 'Austria', 'Western Europe and Others', '1955-12-14', FALSE, 0.679),
('BEL', 'Belgium', 'Western Europe and Others', '1945-12-27', FALSE, 0.828),
('DNK', 'Denmark', 'Western Europe and Others', '1945-10-24', FALSE, 0.553),
('FIN', 'Finland', 'Western Europe and Others', '1955-12-14', FALSE, 0.417),
('GRC', 'Greece', 'Western Europe and Others', '1945-10-25', FALSE, 0.325),
('ISL', 'Iceland', 'Western Europe and Others', '1946-11-19', FALSE, 0.028),
('IRL', 'Ireland', 'Western Europe and Others', '1955-12-14', FALSE, 0.439),
('ISR', 'Israel', 'Western Europe and Others', '1949-05-11', FALSE, 0.561),
('ITA', 'Italy', 'Western Europe and Others', '1955-12-14', FALSE, 3.189),
('LIE', 'Liechtenstein', 'Western Europe and Others', '1990-09-18', FALSE, 0.010),
('LUX', 'Luxembourg', 'Western Europe and Others', '1945-10-24', FALSE, 0.068),
('MLT', 'Malta', 'Western Europe and Others', '1964-12-01', FALSE, 0.019),
('MCO', 'Monaco', 'Western Europe and Others', '1993-05-28', FALSE, 0.011),
('NLD', 'Netherlands', 'Western Europe and Others', '1945-12-10', FALSE, 1.377),
('NOR', 'Norway', 'Western Europe and Others', '1945-11-27', FALSE, 0.679),
('PRT', 'Portugal', 'Western Europe and Others', '1955-12-14', FALSE, 0.353),
('SMR', 'San Marino', 'Western Europe and Others', '1992-03-02', FALSE, 0.002),
('ESP', 'Spain', 'Western Europe and Others', '1955-12-14', FALSE, 2.134),
('SWE', 'Sweden', 'Western Europe and Others', '1946-11-19', FALSE, 0.871),
('CHE', 'Switzerland', 'Western Europe and Others', '2002-09-10', FALSE, 1.134),
('TUR', 'Türkiye', 'Western Europe and Others', '1945-10-24', FALSE, 1.376);

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

-- Add sub-departments for hierarchy
UPDATE department SET parent_department_id = 2 WHERE department_code = 'DPO';
UPDATE department SET parent_department_id = 5 WHERE department_code = 'DGC';

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
('UN-REG-001', 'Philippe', 'Gautier', 'pgautier@icj.org', 12, NULL, 4, '2019-08-01', 'ACTIVE', 4),
('UN-OFF-004', 'Keiko', 'Tanaka', 'ktanaka@un.org', 7, 7, 5, '2020-03-01', 'ACTIVE', 2),
('UN-OFF-005', 'Carlos', 'Rivera', 'crivera@un.org', 8, 5, 5, '2021-09-15', 'ACTIVE', 2),
('UN-CHIEF-001', 'Fatima', 'Al-Rashid', 'falrashid@un.org', 6, 4, 5, '2019-01-10', 'ACTIVE', 3);

-- ============================================================================
-- DELEGATES
-- GA delegates (15), SC delegates (10), ECOSOC delegates (5)
-- ============================================================================

-- GA Delegates (state_id 1-15)
INSERT INTO delegate (delegate_code, first_name, last_name, title, state_id, organ_id, credential_date, credential_expiry_date, is_permanent_representative, voting_authority) VALUES
('DEL-USA-GA', 'Linda', 'Thomas-Greenfield', 'Ambassador', 1, 1, '2021-02-25', '2027-02-25', TRUE, TRUE),
('DEL-CHN-GA', 'Fu', 'Cong', 'Ambassador', 2, 1, '2024-01-15', '2029-01-15', TRUE, TRUE),
('DEL-RUS-GA', 'Vassily', 'Nebenzia', 'Ambassador', 3, 1, '2017-07-26', '2027-07-26', TRUE, TRUE),
('DEL-GBR-GA', 'Barbara', 'Woodward', 'Ambassador', 4, 1, '2020-09-14', '2027-09-14', TRUE, TRUE),
('DEL-FRA-GA', 'Nicolas', 'de Rivière', 'Ambassador', 5, 1, '2019-09-02', '2027-09-02', TRUE, TRUE),
('DEL-DEU-GA', 'Antje', 'Leendertse', 'Ambassador', 6, 1, '2022-03-01', '2027-03-01', TRUE, TRUE),
('DEL-JPN-GA', 'Ishikane', 'Kimihiro', 'Ambassador', 7, 1, '2022-09-01', '2027-09-01', TRUE, TRUE),
('DEL-IND-GA', 'Ruchira', 'Kamboj', 'Ambassador', 8, 1, '2022-06-01', '2027-06-01', TRUE, TRUE),
('DEL-BRA-GA', 'Ronaldo', 'Costa Filho', 'Ambassador', 9, 1, '2023-01-15', '2028-01-15', TRUE, TRUE),
('DEL-NGA-GA', 'Tijjani', 'Muhammad-Bande', 'Ambassador', 10, 1, '2019-09-17', '2027-09-17', TRUE, TRUE),
('DEL-ZAF-GA', 'Mathu', 'Joyini', 'Ambassador', 11, 1, '2020-01-20', '2027-01-20', TRUE, TRUE),
('DEL-EGY-GA', 'Osama', 'Abdelkhalek', 'Ambassador', 12, 1, '2021-08-01', '2026-08-01', TRUE, TRUE),
('DEL-MEX-GA', 'Juan', 'Ramón de la Fuente', 'Ambassador', 13, 1, '2019-02-01', '2027-02-01', TRUE, TRUE),
('DEL-AUS-GA', 'Mitch', 'Fifield', 'Ambassador', 14, 1, '2022-06-15', '2027-06-15', TRUE, TRUE),
('DEL-CAN-GA', 'Bob', 'Rae', 'Ambassador', 15, 1, '2020-07-06', '2027-07-06', TRUE, TRUE);

-- SC Delegates (P5 + 5 elected)
INSERT INTO delegate (delegate_code, first_name, last_name, title, state_id, organ_id, credential_date, credential_expiry_date, is_permanent_representative, voting_authority) VALUES
('DEL-USA-SC', 'Robert', 'Wood', 'Deputy Ambassador', 1, 2, '2023-01-01', '2027-01-01', TRUE, TRUE),
('DEL-CHN-SC', 'Geng', 'Shuang', 'Deputy Ambassador', 2, 2, '2023-06-01', '2028-06-01', TRUE, TRUE),
('DEL-RUS-SC', 'Dmitry', 'Polyanskiy', 'Deputy Ambassador', 3, 2, '2022-01-15', '2027-01-15', TRUE, TRUE),
('DEL-GBR-SC', 'James', 'Kariuki', 'Deputy Ambassador', 4, 2, '2022-09-01', '2027-09-01', TRUE, TRUE),
('DEL-FRA-SC', 'Nathalie', 'Broadhurst', 'Deputy Ambassador', 5, 2, '2023-03-01', '2028-03-01', TRUE, TRUE),
('DEL-JPN-SC', 'Yamazaki', 'Kazuyuki', 'Ambassador', 7, 2, '2025-01-01', '2027-01-01', FALSE, TRUE),
('DEL-KOR-SC', 'Hwang', 'Joonkook', 'Ambassador', 16, 2, '2025-01-01', '2027-01-01', FALSE, TRUE),
('DEL-IND-SC', 'Parvathaneni', 'Harish', 'Ambassador', 8, 2, '2025-01-01', '2027-01-01', FALSE, TRUE),
('DEL-NGA-SC', 'Abubakar', 'Malami', 'Ambassador', 10, 2, '2025-01-01', '2027-01-01', FALSE, TRUE),
('DEL-ARG-SC', 'Ricardo', 'Lagorio', 'Ambassador', 18, 2, '2025-01-01', '2027-01-01', FALSE, TRUE);

-- ECOSOC Delegates
INSERT INTO delegate (delegate_code, first_name, last_name, title, state_id, organ_id, credential_date, credential_expiry_date, is_permanent_representative, voting_authority) VALUES
('DEL-IND-EC', 'Sanjay', 'Verma', 'Ambassador', 8, 3, '2024-01-01', '2027-01-01', FALSE, TRUE),
('DEL-BRA-EC', 'Marcos', 'Galvão', 'Ambassador', 9, 3, '2024-01-01', '2027-01-01', FALSE, TRUE),
('DEL-DEU-EC', 'Friedrich', 'Merkel', 'Ambassador', 6, 3, '2024-01-01', '2027-01-01', FALSE, TRUE),
('DEL-NGA-EC', 'Chioma', 'Okonkwo', 'Ambassador', 10, 3, '2024-01-01', '2027-01-01', FALSE, TRUE),
('DEL-IDN-EC', 'Dian', 'Triansyah Djani', 'Ambassador', 19, 3, '2024-01-01', '2027-01-01', FALSE, TRUE);

-- ============================================================================
-- MATTERS (12 proposals and cases across all organs, 2024-2026)
-- ============================================================================

-- GA Matters (delegate-submitted)
INSERT INTO matter (matter_number, title, description, matter_type, organ_id, submitted_by_delegate_id, priority, status, submission_date, session_number, agenda_item_number, requires_voting, voting_threshold) VALUES
('GA/RES/79/001', 'Resolution on Climate Action Acceleration', 'Calls upon all Member States to accelerate efforts to combat climate change and implement the Paris Agreement goals with enhanced NDCs by 2030.', 'RESOLUTION', 1, 1, 'HIGH', 'PASSED', '2025-09-15', '79', '12', TRUE, 66.67),
('GA/RES/79/002', 'Resolution on Digital Cooperation and AI Governance', 'Promotes international cooperation on artificial intelligence governance, data protection, and bridging the digital divide.', 'RESOLUTION', 1, 6, 'MEDIUM', 'IN_VOTING', '2025-10-01', '79', '23', TRUE, 50.00),
('GA/RES/79/003', 'Resolution on Pandemic Preparedness Treaty', 'Urges Member States to finalize negotiations on a binding pandemic preparedness agreement under WHO framework.', 'RESOLUTION', 1, 8, 'HIGH', 'PASSED', '2025-11-05', '79', '14', TRUE, 50.00);

-- SC Matters (delegate-submitted)
INSERT INTO matter (matter_number, title, description, matter_type, organ_id, submitted_by_delegate_id, priority, status, submission_date, requires_voting, voting_threshold) VALUES
('SC/RES/2730', 'Resolution on Humanitarian Ceasefire', 'Calls for an immediate humanitarian ceasefire and unimpeded humanitarian access in all active conflict zones.', 'RESOLUTION', 2, 16, 'CRITICAL', 'PASSED', '2025-11-15', TRUE, 60.00),
('SC/RES/2731', 'Resolution on Peacekeeping Mission Extension - UNMISS', 'Extends the mandate of UNMISS in South Sudan until March 2027 with revised troop ceiling.', 'RESOLUTION', 2, 19, 'HIGH', 'PENDING_APPROVAL', '2026-01-10', TRUE, 60.00),
('SC/RES/2732', 'Resolution on Non-Proliferation Enforcement', 'Strengthens sanctions regime regarding nuclear non-proliferation in the Korean Peninsula.', 'RESOLUTION', 2, 16, 'CRITICAL', 'REJECTED', '2025-12-05', TRUE, 60.00);

-- ECOSOC Matter (delegate-submitted)
INSERT INTO matter (matter_number, title, description, matter_type, organ_id, submitted_by_delegate_id, priority, status, submission_date, session_number, agenda_item_number, requires_voting, voting_threshold) VALUES
('ECOSOC/DEC/2025/201', 'Decision on Sustainable Development Goals Accelerated Review', 'Reviews progress on SDGs and recommends accelerated action on poverty eradication and clean energy targets.', 'DECISION', 3, 26, 'HIGH', 'UNDER_REVIEW', '2025-07-10', '2025', '5', TRUE, 50.00),
('ECOSOC/DEC/2025/202', 'Decision on Global Health Equity Framework', 'Establishes framework for equitable distribution of health resources and pandemic preparedness across developing nations.', 'DECISION', 3, 28, 'HIGH', 'PASSED', '2025-09-20', '2025', '8', TRUE, 50.00);

-- Secretariat Matters (officer-submitted)
INSERT INTO matter (matter_number, title, description, matter_type, organ_id, submitted_by_officer_id, priority, status, submission_date, requires_voting) VALUES
('ST/SGB/2025/01', 'Staff Regulations Amendment - Hybrid Work', 'Amendments to the Staff Regulations concerning hybrid work policies for UN Secretariat staff worldwide.', 'DIRECTIVE', 5, 1, 'MEDIUM', 'APPROVED', '2025-03-01', FALSE),
('ST/AI/2025/05', 'Administrative Instruction on Cybersecurity', 'Updated procedures for cybersecurity protocols, mandatory training, and incident response across all offices.', 'CIRCULAR', 5, 2, 'HIGH', 'APPROVED', '2025-04-15', FALSE);

-- TC Matter (officer-submitted)
INSERT INTO matter (matter_number, title, description, matter_type, organ_id, submitted_by_officer_id, priority, status, submission_date, requires_voting) VALUES
('TC/REP/2025/01', 'Historical Review - 30th Anniversary of Trusteeship Completion', 'Comprehensive review marking 30 years since the last Trust Territory gained independence.', 'OVERSIGHT_REPORT', 6, 14, 'MEDIUM', 'CLOSED', '2025-01-15', FALSE);

-- ============================================================================
-- MATTER WORKFLOW
-- ============================================================================
INSERT INTO matter_workflow (matter_id, stage_number, stage_name, stage_status, assigned_officer_id, started_at, completed_at) VALUES
-- Matter 1: GA Climate (PASSED)
(1, 1, 'SUBMISSION', 'COMPLETED', 11, '2025-09-15 09:00:00', '2025-09-15 09:30:00'),
(1, 2, 'INITIAL_REVIEW', 'COMPLETED', 11, '2025-09-15 10:00:00', '2025-09-16 14:00:00'),
(1, 3, 'COMMITTEE_REVIEW', 'COMPLETED', 11, '2025-09-17 09:00:00', '2025-09-25 17:00:00'),
(1, 4, 'APPROVAL', 'COMPLETED', 1, '2025-09-26 09:00:00', '2025-09-26 12:00:00'),
(1, 5, 'VOTING', 'COMPLETED', 11, '2025-09-27 10:00:00', '2025-09-27 18:00:00'),
(1, 6, 'RESOLUTION_ISSUANCE', 'COMPLETED', 11, '2025-09-28 09:00:00', '2025-09-28 10:00:00'),
-- Matter 2: GA Digital (IN_VOTING)
(2, 1, 'SUBMISSION', 'COMPLETED', 11, '2025-10-01 09:00:00', '2025-10-01 09:30:00'),
(2, 2, 'INITIAL_REVIEW', 'COMPLETED', 11, '2025-10-01 10:00:00', '2025-10-03 14:00:00'),
(2, 3, 'COMMITTEE_REVIEW', 'COMPLETED', 11, '2025-10-04 09:00:00', '2025-10-15 17:00:00'),
(2, 4, 'APPROVAL', 'COMPLETED', 1, '2025-10-16 09:00:00', '2025-10-16 12:00:00'),
(2, 5, 'VOTING', 'IN_PROGRESS', 11, '2025-10-20 10:00:00', NULL),
-- Matter 3: GA Pandemic (PASSED)
(3, 1, 'SUBMISSION', 'COMPLETED', 11, '2025-11-05 09:00:00', '2025-11-05 09:30:00'),
(3, 2, 'INITIAL_REVIEW', 'COMPLETED', 11, '2025-11-06 10:00:00', '2025-11-08 14:00:00'),
(3, 3, 'COMMITTEE_REVIEW', 'COMPLETED', 6, '2025-11-09 09:00:00', '2025-11-20 17:00:00'),
(3, 4, 'APPROVAL', 'COMPLETED', 1, '2025-11-21 09:00:00', '2025-11-21 15:00:00'),
(3, 5, 'VOTING', 'COMPLETED', 11, '2025-11-25 10:00:00', '2025-11-25 18:00:00'),
(3, 6, 'RESOLUTION_ISSUANCE', 'COMPLETED', 11, '2025-11-26 09:00:00', '2025-11-26 10:00:00'),
-- Matter 4: SC Ceasefire (PASSED)
(4, 1, 'SUBMISSION', 'COMPLETED', 12, '2025-11-15 09:00:00', '2025-11-15 09:30:00'),
(4, 2, 'INITIAL_REVIEW', 'COMPLETED', 12, '2025-11-15 10:00:00', '2025-11-16 14:00:00'),
(4, 3, 'COMMITTEE_REVIEW', 'COMPLETED', 12, '2025-11-17 09:00:00', '2025-11-18 17:00:00'),
(4, 4, 'APPROVAL', 'COMPLETED', 1, '2025-11-19 09:00:00', '2025-11-19 12:00:00'),
(4, 5, 'VOTING', 'COMPLETED', 12, '2025-11-20 10:00:00', '2025-11-20 18:00:00'),
(4, 6, 'RESOLUTION_ISSUANCE', 'COMPLETED', 12, '2025-11-21 09:00:00', '2025-11-21 10:00:00'),
-- Matter 5: SC Peacekeeping (PENDING_APPROVAL)
(5, 1, 'SUBMISSION', 'COMPLETED', 12, '2026-01-10 09:00:00', '2026-01-10 09:30:00'),
(5, 2, 'INITIAL_REVIEW', 'COMPLETED', 12, '2026-01-11 10:00:00', '2026-01-13 14:00:00'),
(5, 3, 'COMMITTEE_REVIEW', 'IN_PROGRESS', 12, '2026-01-14 09:00:00', NULL),
-- Matter 8: ECOSOC Health (PASSED)
(8, 1, 'SUBMISSION', 'COMPLETED', 13, '2025-09-20 09:00:00', '2025-09-20 09:30:00'),
(8, 2, 'INITIAL_REVIEW', 'COMPLETED', 13, '2025-09-21 10:00:00', '2025-09-25 14:00:00'),
(8, 3, 'COMMITTEE_REVIEW', 'COMPLETED', 13, '2025-09-26 09:00:00', '2025-10-05 17:00:00'),
(8, 4, 'APPROVAL', 'COMPLETED', 1, '2025-10-06 09:00:00', '2025-10-06 12:00:00'),
(8, 5, 'VOTING', 'COMPLETED', 13, '2025-10-10 10:00:00', '2025-10-10 18:00:00'),
(8, 6, 'RESOLUTION_ISSUANCE', 'COMPLETED', 13, '2025-10-11 09:00:00', '2025-10-11 10:00:00');

-- ============================================================================
-- APPROVALS
-- ============================================================================
INSERT INTO approval (matter_id, approver_officer_id, approval_level, approval_status, decision_date, comments) VALUES
-- Matter 1: GA Climate
(1, 6, 1, 'APPROVED', '2025-09-20 14:00:00', 'Initial review completed. Forwarding to committee.'),
(1, 3, 2, 'APPROVED', '2025-09-25 16:00:00', 'Committee review favorable. Recommend for voting.'),
(1, 1, 3, 'APPROVED', '2025-09-26 12:00:00', 'Approved for General Assembly vote.'),
-- Matter 2: GA Digital
(2, 6, 1, 'APPROVED', '2025-10-05 10:00:00', 'Substantive review completed.'),
(2, 3, 2, 'APPROVED', '2025-10-15 15:00:00', 'Committee endorses with minor amendments.'),
(2, 1, 3, 'APPROVED', '2025-10-16 12:00:00', 'Proceed to voting phase.'),
-- Matter 3: GA Pandemic
(3, 6, 1, 'APPROVED', '2025-11-10 10:00:00', 'Pandemic preparedness review completed.'),
(3, 3, 2, 'APPROVED', '2025-11-20 16:00:00', 'Committee strongly endorses.'),
(3, 1, 3, 'APPROVED', '2025-11-21 15:00:00', 'Approved for General Assembly vote.'),
-- Matter 4: SC Ceasefire
(4, 12, 1, 'APPROVED', '2025-11-16 09:00:00', 'Urgent humanitarian matter. Fast-track approved.'),
(4, 1, 2, 'APPROVED', '2025-11-19 12:00:00', 'Secretary-General endorsement for immediate action.'),
-- Matter 5: SC Peacekeeping
(5, 12, 1, 'PENDING', NULL, 'Under review by Security Council Affairs.'),
-- Matter 8: ECOSOC Health
(8, 7, 1, 'APPROVED', '2025-09-28 10:00:00', 'DESA review completed favorably.'),
(8, 13, 2, 'APPROVED', '2025-10-05 14:00:00', 'ECOSOC committee endorses framework.'),
(8, 1, 3, 'APPROVED', '2025-10-06 12:00:00', 'Approved for ECOSOC vote.');

-- ============================================================================
-- VOTES
-- ============================================================================

-- Matter 1: GA/RES/79/001 Climate Action (PASSED, 14 YES, 0 NO, 1 ABSTAIN)
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES
(1, 1, 1, 'YES'), (1, 2, 2, 'YES'), (1, 3, 3, 'ABSTAIN'),
(1, 4, 4, 'YES'), (1, 5, 5, 'YES'), (1, 6, 6, 'YES'),
(1, 7, 7, 'YES'), (1, 8, 8, 'YES'), (1, 9, 9, 'YES'),
(1, 10, 10, 'YES'), (1, 11, 11, 'YES'), (1, 12, 12, 'YES'),
(1, 13, 13, 'YES'), (1, 14, 14, 'YES'), (1, 15, 15, 'YES');

-- Matter 2: GA/RES/79/002 Digital Cooperation (IN_VOTING, partial votes)
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES
(2, 1, 1, 'YES'), (2, 4, 4, 'YES'), (2, 5, 5, 'YES'),
(2, 6, 6, 'YES'), (2, 7, 7, 'YES'), (2, 2, 2, 'NO'),
(2, 3, 3, 'NO'), (2, 8, 8, 'ABSTAIN');

-- Matter 3: GA/RES/79/003 Pandemic Preparedness (PASSED, 12 YES, 2 NO, 1 ABSTAIN)
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES
(3, 1, 1, 'YES'), (3, 4, 4, 'YES'), (3, 5, 5, 'YES'),
(3, 6, 6, 'YES'), (3, 7, 7, 'YES'), (3, 8, 8, 'YES'),
(3, 9, 9, 'YES'), (3, 10, 10, 'YES'), (3, 11, 11, 'YES'),
(3, 12, 12, 'YES'), (3, 14, 14, 'YES'), (3, 15, 15, 'YES'),
(3, 2, 2, 'NO'), (3, 3, 3, 'NO'), (3, 13, 13, 'ABSTAIN');

-- Matter 4: SC/RES/2730 Ceasefire (PASSED, 7 YES, 2 NO, 1 ABSTAIN, P5 voted)
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES
(4, 1, 16, 'YES'), (4, 4, 19, 'YES'), (4, 5, 20, 'YES'),
(4, 2, 17, 'ABSTAIN'), (4, 3, 18, 'NO'),
(4, 7, 21, 'YES'), (4, 16, 22, 'YES'), (4, 8, 23, 'YES'),
(4, 10, 24, 'YES'), (4, 18, 25, 'NO');

-- Matter 6: SC/RES/2732 Non-Proliferation (REJECTED, 4 YES, 4 NO, 2 ABSTAIN - Russia & China vetoed)
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES
(6, 1, 16, 'YES'), (6, 4, 19, 'YES'), (6, 5, 20, 'YES'),
(6, 7, 21, 'YES'),
(6, 2, 17, 'NO'), (6, 3, 18, 'NO'), (6, 18, 25, 'NO'), (6, 10, 24, 'NO'),
(6, 16, 22, 'ABSTAIN'), (6, 8, 23, 'ABSTAIN');

-- Matter 8: ECOSOC Health (PASSED, 4 YES, 0 NO, 1 ABSTAIN)
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES
(8, 8, 26, 'YES'), (8, 9, 27, 'YES'), (8, 6, 28, 'YES'),
(8, 10, 29, 'YES'), (8, 19, 30, 'ABSTAIN');

-- ============================================================================
-- RESOLUTIONS
-- ============================================================================
INSERT INTO resolution (resolution_number, matter_id, organ_id, title, preamble, operative_text, adoption_date, yes_votes, no_votes, abstentions, is_binding, status) VALUES
('A/RES/79/1', 1, 1, 'Climate Action Acceleration',
'The General Assembly,\n\nRecalling the Paris Agreement and its goals,\nDeeply concerned by the accelerating impacts of climate change,\nRecognizing the need for urgent and ambitious action by 2030,',
'1. Calls upon all Member States to enhance their nationally determined contributions;\n2. Urges developed countries to fulfill climate finance commitments of $100 billion;\n3. Encourages technology transfer for climate adaptation;\n4. Requests the Secretary-General to report on implementation progress.',
'2025-09-28', 14, 0, 1, FALSE, 'IN_FORCE'),

('A/RES/79/3', 3, 1, 'Pandemic Preparedness Treaty',
'The General Assembly,\n\nRecognizing the devastating impact of the COVID-19 pandemic,\nReaffirming the need for global health cooperation,',
'1. Urges Member States to finalize the WHO Pandemic Treaty;\n2. Calls for equitable distribution of medical countermeasures;\n3. Requests establishment of a Global Pandemic Early Warning System.',
'2025-11-26', 12, 2, 1, FALSE, 'IN_FORCE'),

('S/RES/2730', 4, 2, 'Humanitarian Ceasefire in Conflict Zones',
'The Security Council,\n\nGravely concerned by the humanitarian crisis,\nReaffirming its commitment to international humanitarian law,',
'1. Calls for an immediate humanitarian ceasefire;\n2. Demands safe passage for humanitarian aid;\n3. Urges all parties to protect civilians and civilian infrastructure;\n4. Decides to remain actively seized of the matter.',
'2025-11-21', 7, 2, 1, TRUE, 'IN_FORCE'),

('E/RES/2025/1', 8, 3, 'Global Health Equity Framework',
'The Economic and Social Council,\n\nRecognizing health disparities across nations,\nReaffirming commitment to SDG 3 (Good Health),',
'1. Establishes Global Health Equity Framework;\n2. Calls for enhanced health financing for developing nations;\n3. Urges WHO coordination on pandemic preparedness.',
'2025-10-11', 4, 0, 1, FALSE, 'ADOPTED');

-- ============================================================================
-- ICJ JUDGES (10 judges with current ICJ composition)
-- ============================================================================
INSERT INTO icj_judge (judge_code, first_name, last_name, nationality_state_id, appointment_date, term_end_date, is_president, is_vice_president, specialization) VALUES
('ICJ-J-001', 'Nawaf', 'Salam', 12, '2018-02-06', '2027-02-05', TRUE, FALSE, 'Human Rights Law'),
('ICJ-J-002', 'Kirill', 'Gevorgian', 3, '2015-02-06', '2033-02-05', FALSE, FALSE, 'Maritime Law'),
('ICJ-J-003', 'Julia', 'Sebutinde', 10, '2012-02-06', '2030-02-05', FALSE, FALSE, 'Criminal Law'),
('ICJ-J-004', 'Dalveer', 'Bhandari', 8, '2012-11-27', '2027-02-05', FALSE, FALSE, 'Constitutional Law'),
('ICJ-J-005', 'Xue', 'Hanqin', 2, '2010-06-29', '2030-02-05', FALSE, TRUE, 'Treaty Law'),
('ICJ-J-006', 'Yuji', 'Iwasawa', 7, '2018-02-06', '2027-02-05', FALSE, FALSE, 'Trade Law'),
('ICJ-J-007', 'Peter', 'Tomka', 20, '2003-02-06', '2030-02-05', FALSE, FALSE, 'State Responsibility'),
('ICJ-J-008', 'Hilary', 'Charlesworth', 14, '2021-02-06', '2030-02-05', FALSE, FALSE, 'Human Rights'),
('ICJ-J-009', 'Georg', 'Nolte', 6, '2021-02-06', '2030-02-05', FALSE, FALSE, 'International Treaties'),
('ICJ-J-010', 'Leonardo', 'Nemer Caldeira Brant', 9, '2024-02-06', '2033-02-05', FALSE, FALSE, 'Environmental Law');

-- ============================================================================
-- ICJ CASES (4 cases reflecting current events)
-- ============================================================================
INSERT INTO icj_case (case_number, case_title, case_type, applicant_state_id, respondent_state_id, filing_date, subject_matter, status) VALUES
('ICJ/2024/001', 'Maritime Boundary Dispute (Brazil v. Mexico)', 'CONTENTIOUS', 9, 13, '2024-03-15', 'Dispute concerning the delimitation of maritime boundaries in Atlantic waters between the two states.', 'HEARING'),
('ICJ/2024/002', 'Application of Genocide Convention (South Africa v. Russia)', 'CONTENTIOUS', 11, 3, '2024-01-10', 'Allegations concerning violations of obligations under the Convention on the Prevention and Punishment of Genocide.', 'PRELIMINARY_OBJECTIONS'),
('ICJ/2025/001', 'Advisory Opinion on Climate Change Obligations', 'ADVISORY', NULL, NULL, '2025-03-15', 'Request for advisory opinion on the obligations of States under international law with respect to climate change.', 'DELIBERATION'),
('ICJ/2025/002', 'Nuclear Arms Legality (Australia v. France)', 'CONTENTIOUS', 14, 5, '2025-06-01', 'Application concerning the legality of nuclear testing in the South Pacific region.', 'PENDING');

-- Update advisory case with requesting organ
UPDATE icj_case SET requesting_organ_id = 1 WHERE case_number = 'ICJ/2025/001';

-- ============================================================================
-- ICJ CASE-JUDGE ASSIGNMENTS
-- ============================================================================
INSERT INTO icj_case_judge (case_id, judge_id, is_ad_hoc) VALUES
-- Case 1: Maritime Boundary (9 judges)
(1, 1, FALSE), (1, 2, FALSE), (1, 3, FALSE), (1, 4, FALSE), (1, 5, FALSE),
(1, 6, FALSE), (1, 7, FALSE), (1, 8, FALSE), (1, 10, FALSE),
-- Case 2: Genocide Convention (10 judges)
(2, 1, FALSE), (2, 2, FALSE), (2, 3, FALSE), (2, 4, FALSE), (2, 5, FALSE),
(2, 6, FALSE), (2, 7, FALSE), (2, 8, FALSE), (2, 9, FALSE), (2, 10, FALSE),
-- Case 3: Climate Advisory (8 judges)
(3, 1, FALSE), (3, 3, FALSE), (3, 4, FALSE), (3, 5, FALSE),
(3, 6, FALSE), (3, 7, FALSE), (3, 8, FALSE), (3, 9, FALSE),
-- Case 4: Nuclear Arms (7 judges, excluding French judge Nolte for recusal)
(4, 1, FALSE), (4, 2, FALSE), (4, 3, FALSE), (4, 4, FALSE),
(4, 5, FALSE), (4, 6, FALSE), (4, 10, FALSE);

-- ============================================================================
-- ICJ HEARINGS
-- ============================================================================
INSERT INTO icj_hearing (case_id, hearing_number, hearing_type, scheduled_date, actual_date, start_time, end_time, presiding_judge_id, status, transcript_available) VALUES
(1, 1, 'PRELIMINARY', '2024-05-10', '2024-05-10', '10:00:00', '13:00:00', 1, 'COMPLETED', TRUE),
(1, 2, 'ORAL_ARGUMENTS', '2025-03-15', '2025-03-15', '10:00:00', '17:00:00', 1, 'COMPLETED', TRUE),
(1, 3, 'ORAL_ARGUMENTS', '2025-03-16', '2025-03-16', '10:00:00', '17:00:00', 1, 'COMPLETED', TRUE),
(2, 1, 'PRELIMINARY', '2024-04-20', '2024-04-20', '10:00:00', '12:00:00', 1, 'COMPLETED', TRUE),
(2, 2, 'PROVISIONAL_MEASURES', '2024-06-15', '2024-06-15', '10:00:00', '16:00:00', 1, 'COMPLETED', TRUE),
(3, 1, 'ORAL_ARGUMENTS', '2025-09-01', '2025-09-01', '10:00:00', '17:00:00', 1, 'COMPLETED', TRUE),
(3, 2, 'ORAL_ARGUMENTS', '2025-09-02', '2025-09-02', '10:00:00', '17:00:00', 1, 'COMPLETED', TRUE),
(4, 1, 'PRELIMINARY', '2026-03-10', NULL, '10:00:00', NULL, 1, 'SCHEDULED', FALSE);

-- ============================================================================
-- ICJ JUDGMENTS
-- ============================================================================
INSERT INTO icj_judgment (judgment_number, case_id, judgment_type, judgment_date, summary, votes_in_favor, votes_against, is_unanimous, binding_on_parties, compliance_status) VALUES
('ICJ/JUD/2024/PM/001', 2, 'PROVISIONAL_MEASURES', '2024-07-01',
'The Court orders provisional measures requiring the respondent to take all measures within its power to prevent acts falling within the scope of the Genocide Convention.',
13, 2, FALSE, TRUE, 'PARTIAL_COMPLIANCE'),
('ICJ/JUD/2025/AO/001', 3, 'ADVISORY_OPINION', '2025-12-15',
'The Court advises that States have clear obligations under international law to prevent climate change and reduce greenhouse gas emissions in accordance with the principle of common but differentiated responsibilities.',
14, 1, FALSE, FALSE, 'NOT_APPLICABLE');

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
'Palau has successfully completed all conditions for self-determination. The population voted for free association with the United States.',
'The Trusteeship Council recommends termination of the trusteeship agreement upon Palau independence.',
'Trusteeship terminated. Palau admitted as UN Member State.', '1994-10-01'),
('TC/REP/1985/FSM/ANN', 2, 'ANNUAL', 1985, 14, '1985-06-30', 'CLOSED',
'Significant progress in economic development and political institution building.',
'Continue support for infrastructure development. Prepare transition plan.',
'Report noted. Continued oversight approved.', '1985-09-15'),
('TC/REP/1967/NRU/ANN', 4, 'ANNUAL', 1967, 14, '1967-06-30', 'CLOSED',
'Nauru approaching readiness for independence. Phosphate mining revenues sustaining economy.',
'Recommend independence timeline within 18 months.',
'Independence approved for January 1968.', '1967-12-15'),
('TC/REP/2025/HIST', 1, 'SPECIAL', 2025, 14, '2025-01-15', 'CLOSED',
'30th anniversary review of trusteeship system completion. All 11 original trust territories have achieved self-determination.',
'Archive all trusteeship records for historical reference. Publish commemorative report.',
'Historical review accepted. Archives transferred to UN Digital Library.', '2025-02-28');

-- ============================================================================
-- DIRECTIVES (Secretariat)
-- ============================================================================
INSERT INTO directive (directive_number, directive_type, title, content, issuing_department_id, target_department_id, issued_by_officer_id, issue_date, effective_date, expiry_date, priority, status, requires_acknowledgment, matter_id) VALUES
('ST/SGB/2025/1', 'POLICY', 'Hybrid Work Policy Framework',
'1. Purpose: Establishes guidelines for hybrid work arrangements.\n2. Scope: Applies to all Secretariat staff.\n3. Eligibility: Staff may request hybrid work for up to 3 days per week.\n4. Approval: Supervisor approval required.\n5. Equipment: Standard IT equipment provided.\n6. Connectivity: Reliable internet required.\n7. Reporting: Regular check-ins mandatory.',
1, NULL, 1, '2025-03-15', '2025-04-01', '2027-03-31', 'HIGH', 'IN_EFFECT', TRUE, 9),

('ST/AI/2025/5', 'CIRCULAR', 'Cybersecurity Protocol Update',
'1. All staff must complete cybersecurity training by Q2 2025.\n2. Multi-factor authentication mandatory for all systems.\n3. Report suspicious emails to security@un.org.\n4. VPN required for remote access.\n5. USB devices prohibited on classified networks.',
9, NULL, 5, '2025-04-20', '2025-05-01', NULL, 'HIGH', 'IN_EFFECT', TRUE, 10),

('ST/IC/2025/12', 'BULLETIN', 'AI Ethics Guidelines for UN Operations',
'Guidelines for responsible use of artificial intelligence in UN operations, data analysis, and decision-making processes.',
7, NULL, 16, '2025-06-01', '2025-07-01', '2026-12-31', 'MEDIUM', 'IN_EFFECT', FALSE, NULL),

('ST/SGB/2025/8', 'INSTRUCTION', 'Updated Travel Authorization Procedures',
'1. All official travel must be pre-approved via Umoja.\n2. Submit requests 21 days in advance.\n3. Economy class for flights under 9 hours.\n4. Per diem rates updated per ICSC standards.\n5. Carbon offset mandatory for all flights.',
8, NULL, 2, '2025-08-01', '2025-09-01', NULL, 'MEDIUM', 'IN_EFFECT', FALSE, NULL),

('ST/IC/2024/15', 'BULLETIN', 'Year-End Closure Procedures 2025',
'Office closure schedule and procedures for end of year 2025.',
1, NULL, 1, '2025-11-15', '2025-12-01', '2026-01-05', 'LOW', 'EXPIRED', FALSE, NULL);

-- ============================================================================
-- DIRECTIVE ACKNOWLEDGMENTS
-- ============================================================================
INSERT INTO directive_acknowledgment (directive_id, officer_id, acknowledged_at) VALUES
-- Directive 1: Hybrid Work (7 officers acknowledged)
(1, 2, '2025-04-02 09:15:00'),
(1, 3, '2025-04-02 10:30:00'),
(1, 4, '2025-04-03 08:45:00'),
(1, 5, '2025-04-03 14:20:00'),
(1, 6, '2025-04-04 09:00:00'),
(1, 7, '2025-04-04 11:30:00'),
(1, 8, '2025-04-05 10:00:00'),
-- Directive 2: Cybersecurity (5 officers acknowledged)
(2, 3, '2025-05-02 09:00:00'),
(2, 6, '2025-05-02 14:00:00'),
(2, 8, '2025-05-03 10:00:00'),
(2, 9, '2025-05-03 15:00:00'),
(2, 10, '2025-05-04 09:00:00');

-- ============================================================================
-- AUDIT LOG (Sample entries)
-- ============================================================================
INSERT INTO audit_log (table_name, record_id, action_type, action_description, new_values, performed_by_officer_id, ip_address) VALUES
('matter', 1, 'INSERT', 'New resolution proposal submitted: Climate Action Acceleration', '{"status": "DRAFT", "priority": "HIGH"}', 11, '192.168.1.100'),
('matter', 1, 'STATUS_CHANGE', 'Matter status changed from DRAFT to SUBMITTED', '{"old_status": "DRAFT", "new_status": "SUBMITTED"}', 11, '192.168.1.100'),
('approval', 1, 'INSERT', 'Approval request created for matter GA/RES/79/001', '{"approval_level": 1, "status": "PENDING"}', 11, '192.168.1.100'),
('approval', 1, 'APPROVAL', 'Matter approved at level 1 by Director Santos', '{"status": "APPROVED"}', 6, '192.168.1.105'),
('matter', 1, 'STATUS_CHANGE', 'Matter status changed to IN_VOTING', '{"old_status": "APPROVED", "new_status": "IN_VOTING"}', 11, '192.168.1.100'),
('resolution', 1, 'INSERT', 'Resolution A/RES/79/1 created after successful vote', '{"yes_votes": 14, "no_votes": 0, "abstentions": 1}', 11, '192.168.1.100'),
('icj_case', 1, 'INSERT', 'New ICJ case filed: Maritime Boundary Dispute', '{"status": "PENDING", "case_type": "CONTENTIOUS"}', 15, '192.168.2.50'),
('directive', 1, 'INSERT', 'New policy directive issued: Hybrid Work Policy', '{"status": "DRAFT"}', 1, '192.168.1.1'),
('directive', 1, 'STATUS_CHANGE', 'Directive status changed to IN_EFFECT', '{"old_status": "ISSUED", "new_status": "IN_EFFECT"}', 1, '192.168.1.1'),
('matter', 4, 'STATUS_CHANGE', 'SC matter status changed to PASSED', '{"old_status": "IN_VOTING", "new_status": "PASSED"}', 12, '192.168.1.120'),
('matter', 6, 'STATUS_CHANGE', 'SC matter status changed to REJECTED', '{"old_status": "IN_VOTING", "new_status": "REJECTED"}', 12, '192.168.1.120');

-- Delegate audit entries
INSERT INTO audit_log (table_name, record_id, action_type, action_description, new_values, performed_by_delegate_id, ip_address) VALUES
('vote', 1, 'VOTE', 'Vote cast: USA voted YES on GA/RES/79/001', '{"vote_value": "YES"}', 1, '192.168.1.200'),
('vote', 2, 'VOTE', 'Vote cast: China voted YES on GA/RES/79/001', '{"vote_value": "YES"}', 2, '192.168.1.201'),
('vote', 3, 'VOTE', 'Vote cast: Russia ABSTAINED on GA/RES/79/001', '{"vote_value": "ABSTAIN"}', 3, '192.168.1.202'),
('vote', 4, 'VOTE', 'Vote cast: UK voted YES on GA/RES/79/001', '{"vote_value": "YES"}', 4, '192.168.1.203'),
('vote', 5, 'VOTE', 'Vote cast: France voted YES on GA/RES/79/001', '{"vote_value": "YES"}', 5, '192.168.1.204'),
('vote', 6, 'VOTE', 'Vote cast: Russia voted NO on SC/RES/2732', '{"vote_value": "NO"}', 18, '192.168.1.210');

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
