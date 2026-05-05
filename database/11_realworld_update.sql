-- ============================================================================
-- 11_realworld_update.sql
-- Updates all matter content to current real-world UN events (May 2026)
-- Adds alternate/second delegates for concurrency demonstration
-- ============================================================================
USE un_workflow_db;

-- ============================================================================
-- UPDATE MATTERS — Real-world 2025-2026 content
-- ============================================================================

-- Matter 1: GA PASSED — Gaza emergency resolution
UPDATE matter SET
  matter_number   = 'A/ES-10/L.30/Rev.2',
  title           = 'Immediate Humanitarian Ceasefire in Gaza and Restoration of Humanitarian Aid',
  description     = 'Demands an immediate, permanent humanitarian ceasefire in Gaza, unconditional release of all hostages and detainees, and unimpeded access for humanitarian aid. Calls upon all parties to respect international humanitarian law and protect civilian infrastructure. Reaffirms the right of the Palestinian people to self-determination.',
  priority        = 'CRITICAL',
  session_number  = '80',
  agenda_item_number = '5',
  submission_date = '2025-09-15'
WHERE matter_id = 1;

-- Matter 2: GA IN_VOTING — AI Governance (our live demo matter)
UPDATE matter SET
  matter_number   = 'GA/RES/80/002',
  title           = 'International Framework Convention on Artificial Intelligence Safety and Governance',
  description     = 'Establishes a binding international framework for the responsible development and deployment of artificial intelligence systems. Calls for mandatory AI impact assessments, algorithmic transparency obligations, prohibition of autonomous lethal AI weapons, and creation of an independent UN AI Safety Supervisory Board. Addresses the AI divide between developed and developing nations through technology transfer commitments.',
  priority        = 'HIGH',
  session_number  = '80',
  agenda_item_number = '22',
  submission_date = '2025-10-01'
WHERE matter_id = 2;

-- Matter 3: GA PASSED — Debt relief
UPDATE matter SET
  matter_number   = 'GA/RES/80/001',
  title           = 'Global Sovereign Debt Relief and Development Financing Reform',
  description     = 'Calls for immediate debt relief for 54 heavily indebted developing nations, reform of the international sovereign debt restructuring framework, and IMF/World Bank lending reform. Urges creditor nations and multilateral institutions to implement a debt cancellation programme for Least Developed Countries and establish a UN-based sovereign debt authority to ensure equitable and transparent debt resolution.',
  priority        = 'HIGH',
  session_number  = '80',
  agenda_item_number = '17',
  submission_date = '2025-11-05'
WHERE matter_id = 3;

-- Matter 4: SC PASSED — Haiti MSSM Phase II
UPDATE matter SET
  matter_number   = 'S/RES/2793',
  title           = 'Authorization of Multinational Security Support Mission in Haiti — Phase II Extension',
  description     = 'Extends the mandate of the Multinational Security Support Mission (MSSM) in Haiti for an additional 12 months, led by Kenya with contributions from 15 Member States. Authorizes expansion of the troop ceiling to 5,000 personnel, approves additional funding through voluntary contributions, and mandates the Mission to support the Haitian National Police in combating armed gang control in Port-au-Prince.',
  priority        = 'CRITICAL',
  submission_date = '2025-11-15'
WHERE matter_id = 4;

-- Matter 5: SC PENDING_APPROVAL — Sudan humanitarian corridors (admin enables live)
UPDATE matter SET
  matter_number   = 'S/RES/2794',
  title           = 'Establishment of Humanitarian Corridors and Protection of Civilians in Sudan',
  description     = 'Demands all parties to the conflict in Sudan — the Sudanese Armed Forces (SAF) and Rapid Support Forces (RSF) — to establish and maintain unimpeded humanitarian corridors. Authorizes UN OCHA and humanitarian agencies to operate without restriction in Darfur and Khartoum. Calls for an immediate cessation of attacks on civilian infrastructure, hospitals, and water systems. Over 25 million people currently face acute food insecurity.',
  priority        = 'CRITICAL',
  submission_date = '2026-01-10'
WHERE matter_id = 5;

-- Matter 6: SC REJECTED — Ukraine (Russia veto)
UPDATE matter SET
  matter_number   = 'S/RES/2795',
  title           = 'Ceasefire Monitoring and International Observer Mission in Ukraine',
  description     = 'Demands a comprehensive and unconditional ceasefire along all lines of contact in Ukraine, withdrawal of forces to pre-February 2022 internationally recognized borders, and deployment of a 2,000-strong UN Observer Mission to monitor compliance. Calls for immediate release of all prisoners of war and civilian detainees. Resolution vetoed by the Russian Federation. The United States, United Kingdom, France, Japan, and 10 elected members voted in favour.',
  priority        = 'CRITICAL',
  submission_date = '2025-12-05'
WHERE matter_id = 6;

-- Matter 7: ECOSOC UNDER_REVIEW — Digital economy
UPDATE matter SET
  matter_number   = 'ECOSOC/RES/2026/1',
  title           = 'Digital Economy Development Framework and Bridging the AI Divide',
  description     = 'Reviews the 2030 Digital Cooperation Roadmap implementation and proposes a new financing framework to bridge the technology divide. Recommends $50 billion in digital infrastructure investments for Sub-Saharan Africa and South Asia, expanded internet access via low-Earth orbit satellite schemes, and universal digital ID systems aligned with SDG 16.9. Examines AI-driven job displacement and recommends social protection floor adjustments.',
  priority        = 'HIGH',
  submission_date = '2026-02-10'
WHERE matter_id = 7;

-- Matter 8: ECOSOC PASSED — Health equity
UPDATE matter SET
  matter_number   = 'ECOSOC/RES/2026/2',
  title           = 'Global Health Security and Pandemic Prevention Preparedness Framework',
  description     = 'Endorses the WHO Pandemic Agreement (finalized May 2025) and calls on all Member States to ratify it by December 2026. Establishes a Pandemic Prevention Fund at the World Bank with an initial capitalization of $10 billion. Mandates equitable pathogen sharing and benefit-sharing mechanisms to prevent vaccine nationalism. Reviews lessons from COVID-19 with particular focus on healthcare system resilience in Low- and Middle-Income Countries.',
  priority        = 'HIGH',
  submission_date = '2025-09-20'
WHERE matter_id = 8;

-- Secretariat matters
UPDATE matter SET
  title       = 'Staff Regulations Amendment — AI-Assisted Work and Remote Modalities',
  description = 'Amendments to Staff Regulations 1.1 and 4.3 governing the use of AI-assisted tools in UN Secretariat operations, establishment of human oversight requirements, and updated policies for hybrid and remote work arrangements following the 2024 Global Mobility Review.'
WHERE matter_id = 9;

UPDATE matter SET
  matter_number = 'ST/AI/2026/03',
  title       = 'Administrative Instruction on Cybersecurity and AI System Integrity',
  description = 'Updated mandatory cybersecurity protocols for all UN offices globally, including requirements for multi-factor authentication, AI system audit trails, incident response timelines, and data sovereignty compliance under the new UN Data Governance Framework (A/RES/79/240).'
WHERE matter_id = 10;

-- TC historical matter
UPDATE matter SET
  title       = 'Historical Review — 30th Anniversary of Palau Independence and Trusteeship Completion',
  description = 'Commemorative review marking the 30th anniversary of the dissolution of the Trust Territory of the Pacific Islands and independence of Palau in 1994, representing the completion of the UN Trusteeship System''s decolonization mandate.'
WHERE matter_id = 11;

-- ============================================================================
-- ADD ALTERNATE DELEGATES — for concurrency demonstration
-- Two reps per key country (same state_id, same organ_id, different person)
-- ============================================================================

-- GA Alternate Delegates (delegate_id auto: will be 31-39)
INSERT INTO delegate (delegate_code, first_name, last_name, title, state_id, organ_id, credential_date, credential_expiry_date, is_permanent_representative, voting_authority) VALUES
('DEL-USA-GA-2', 'Dorothy',    'Shea',          'Deputy Representative',      1,  1, '2025-06-01', '2027-06-01', FALSE, TRUE),
('DEL-CHN-GA-2', 'Wang',       'Yiwei',          'Counsellor',                2,  1, '2025-07-01', '2027-07-01', FALSE, TRUE),
('DEL-RUS-GA-2', 'Alexei',     'Polkov',         'First Secretary',           3,  1, '2025-03-01', '2027-03-01', FALSE, TRUE),
('DEL-IND-GA-2', 'Priya',      'Menon',          'Joint Secretary',           8,  1, '2025-01-15', '2027-01-15', FALSE, TRUE),
('DEL-BRA-GA-2', 'Ana',        'Lima',           'Second Secretary',          9,  1, '2025-04-01', '2027-04-01', FALSE, TRUE),
('DEL-NGA-GA-2', 'Chidera',    'Obi',            'Counsellor',               10,  1, '2025-05-01', '2027-05-01', FALSE, TRUE),
('DEL-DEU-GA-2', 'Klaus',      'Weber',          'Counsellor',                6,  1, '2025-02-01', '2027-02-01', FALSE, TRUE),
('DEL-FRA-GA-2', 'Pierre',     'Dubois',         'Attaché',                  5,  1, '2025-08-01', '2027-08-01', FALSE, TRUE),
('DEL-GBR-GA-2', 'James',      'Harrison',       'Deputy Representative',     4,  1, '2025-09-01', '2027-09-01', FALSE, TRUE);

-- SC Alternate Delegates — P5 nations only (delegate_id: 40-44)
INSERT INTO delegate (delegate_code, first_name, last_name, title, state_id, organ_id, credential_date, credential_expiry_date, is_permanent_representative, voting_authority) VALUES
('DEL-USA-SC-2', 'David',      'Cohen',          'Alternate Representative',  1,  2, '2025-06-01', '2027-06-01', FALSE, TRUE),
('DEL-CHN-SC-2', 'Zhang',      'Wei',            'Counsellor',               2,  2, '2025-07-01', '2027-07-01', FALSE, TRUE),
('DEL-RUS-SC-2', 'Dmitri',     'Volkov',         'First Secretary',           3,  2, '2025-03-01', '2027-03-01', FALSE, TRUE),
('DEL-GBR-SC-2', 'Eleanor',    'Blackwood',      'Deputy Representative',     4,  2, '2025-09-01', '2027-09-01', FALSE, TRUE),
('DEL-FRA-SC-2', 'Marie',      'Leclerc',        'Counsellor',               5,  2, '2025-08-01', '2027-08-01', FALSE, TRUE);
