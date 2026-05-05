-- ============================================================================
-- 13_announcements.sql
-- Announcement / News table for admin-posted updates per organ
-- ============================================================================
USE un_workflow_db;

CREATE TABLE IF NOT EXISTS announcement (
  announcement_id  INT AUTO_INCREMENT PRIMARY KEY,
  organ_id         INT,
  title            VARCHAR(255) NOT NULL,
  content          TEXT         NOT NULL,
  category         ENUM('NEWS','UPDATE','STATEMENT','PRESS_RELEASE') DEFAULT 'NEWS',
  published_by     VARCHAR(100) DEFAULT 'admin',
  is_pinned        TINYINT(1)   DEFAULT 0,
  created_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (organ_id) REFERENCES un_organ(organ_id) ON DELETE SET NULL
);

-- Sample announcements so the public page isn't empty
INSERT INTO announcement (organ_id, title, content, category, published_by, is_pinned) VALUES
(1, 'General Assembly Convenes Emergency Special Session on Gaza',
 'The UN General Assembly convened its 11th Emergency Special Session under resolution ES-10 to address the ongoing humanitarian crisis in Gaza. The session adopted resolution A/ES-10/L.30/Rev.2 demanding an immediate and permanent ceasefire, with 143 votes in favour, 9 against, and 18 abstentions. Member States called for unimpeded humanitarian access and urged all parties to comply with international humanitarian law.',
 'NEWS', 'admin', 1),

(2, 'Security Council Extends Haiti MSSM Mandate',
 'The Security Council unanimously adopted resolution S/RES/2793 extending the mandate of the Kenya-led Multinational Security Support Mission in Haiti for an additional 12 months. The Mission is authorized to expand its troop ceiling to 5,000 personnel to address the severe gang violence affecting Port-au-Prince and surrounding areas. Secretary-General António Guterres welcomed the extension as a critical step toward restoring security in Haiti.',
 'STATEMENT', 'admin', 1),

(3, 'ECOSOC Endorses WHO Pandemic Agreement',
 'The Economic and Social Council formally endorsed the historic WHO Pandemic Agreement finalized in May 2025, urging all 196 WHO Member States to ratify the treaty by December 2026. The Agreement establishes binding obligations on pathogen sharing, equitable vaccine distribution, and health system strengthening for low- and middle-income countries.',
 'UPDATE', 'admin', 0),

(1, 'High-Level Week Summary — 80th General Assembly Session',
 'World leaders gathered in New York for the High-Level General Debate of the 80th General Assembly session. Key themes included AI governance, climate finance, and global debt relief. Secretary-General Guterres called for reform of international financial institutions and a "Sustainable Development Goals rescue plan" for developing nations.',
 'PRESS_RELEASE', 'admin', 0),

(NULL, 'UN Workflow System — Live Demo Now Active',
 'The UN Bureaucratic Workflow Management System is now live for demonstration purposes. Delegates from Member States may log in to cast their votes on active resolutions. The public may view all ongoing proceedings, vote tallies, and recent resolutions on the Live Updates page without requiring an account.',
 'UPDATE', 'admin', 0);
