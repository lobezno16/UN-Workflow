-- =============================================================================
-- 09_anomalies_demo.sql
-- UN Workflow Management System — Anomaly Demonstration (Isolated)
-- This script uses a SEPARATE demo table (UN_Anomaly_Demo) to demonstrate
-- Insertion, Update, and Deletion anomalies WITHOUT touching the real database.
-- =============================================================================

USE un_workflow_db;

-- Fixation command (Clean up before)
DROP TABLE IF EXISTS UN_Anomaly_Demo;

-- 1. Create the isolated anomaly demo table
CREATE TABLE UN_Anomaly_Demo (
    matter_id INT, matter_number VARCHAR(20), title VARCHAR(100), organ_code VARCHAR(10), organ_name VARCHAR(50),
    delegate_code VARCHAR(20), delegate_name VARCHAR(50), state_code VARCHAR(3), state_region VARCHAR(50),
    vote_value VARCHAR(10), co_sponsors VARCHAR(100)
);

-- 2. Insert the mock data (as seen in the UNF table in Section 4.1)
INSERT INTO UN_Anomaly_Demo VALUES
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-USA-GA', 'Linda Thomas-Greenfield', 'USA', 'Western Europe and Others', 'YES', 'FRA, GBR, BRA'),
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-CHN-GA', 'Fu Cong', 'CHN', 'Asia-Pacific', 'YES', 'FRA, GBR, BRA'),
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-RUS-GA', 'Vassily Nebenzia', 'RUS', 'Eastern Europe', 'ABSTAIN', 'FRA, GBR, BRA'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-USA-SC', 'Robert Wood', 'USA', 'Western Europe and Others', 'YES', 'GBR, JPN, DEU'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-CHN-SC', 'Geng Shuang', 'CHN', 'Asia-Pacific', 'ABSTAIN', 'GBR, JPN, DEU'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-FRA-SC', 'Nathalie Broadhurst', 'FRA', 'Western Europe and Others', 'YES', 'GBR, JPN, DEU');

-- 3. UPDATE ANOMALY DEMONSTRATION
-- Attempting to rename 'General Assembly' to 'UN General Assembly' but missing rows creates data inconsistency!
UPDATE UN_Anomaly_Demo SET organ_name = 'UN General Assembly' WHERE delegate_code = 'DEL-USA-GA';
SELECT matter_id, organ_code, organ_name, delegate_code FROM UN_Anomaly_Demo WHERE organ_code = 'GA';

-- 4. DELETE ANOMALY DEMONSTRATION
-- Deleting Matter 4 entirely erases all record of France's delegate (Nathalie Broadhurst) from the system!
DELETE FROM UN_Anomaly_Demo WHERE matter_id = 4;
SELECT delegate_name, state_code FROM UN_Anomaly_Demo WHERE state_code = 'FRA';

-- 5. INSERT ANOMALY DEMONSTRATION
-- Attempting to add a UK Delegate without an active matter forces us to use NULL values, breaking entity integrity.
INSERT INTO UN_Anomaly_Demo (delegate_code, delegate_name, state_code, state_region) 
VALUES ('DEL-GBR-GA', 'Barbara Woodward', 'GBR', 'Western Europe and Others');
SELECT * FROM UN_Anomaly_Demo WHERE delegate_code = 'DEL-GBR-GA';

-- Fixation command (Clean up after execution)
DROP TABLE IF EXISTS UN_Anomaly_Demo;
