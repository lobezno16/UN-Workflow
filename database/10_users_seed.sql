-- ============================================================================
-- 10_users_seed.sql - User Authentication Data (auto-generated)
-- DO NOT edit manually. Re-run generate-user-seed.js to regenerate.
-- ============================================================================
USE un_workflow_db;

-- Create users table if not exists
CREATE TABLE IF NOT EXISTS users (
    user_id       INT PRIMARY KEY AUTO_INCREMENT,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          ENUM('admin', 'delegate') NOT NULL DEFAULT 'delegate',
    delegate_id   INT NULL,
    is_active     BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_delegate FOREIGN KEY (delegate_id)
        REFERENCES delegate(delegate_id) ON DELETE SET NULL
);

-- Clear existing data (idempotent)
DELETE FROM users;

-- Wipe partial votes on GA Matter #2 (Digital Cooperation)
-- so all 15 GA delegates can vote fresh during the demo
DELETE FROM vote WHERE matter_id = 2;

-- Reset Matter #2 status to IN_VOTING (it already is, but ensure clean state)
UPDATE matter SET status = 'IN_VOTING', actual_completion_date = NULL WHERE matter_id = 2;

-- Make SC Matter #5 (Peacekeeping Extension) ready for demo
-- Admin will push to IN_VOTING live. SC Matter #6 (Non-Proliferation) already REJECTED.

-- INSERT users with bcrypt-hashed passwords
INSERT INTO users (username, password_hash, role, delegate_id) VALUES
    ('admin', '$2b$10$UWxd44icePaPEW9/AxWf6.mWPmERteXkLnMMcObLgi23.DxI.O6ZC', 'admin', NULL),
    ('usa.ga', '$2b$10$kVB7mquzSTNdWWS36qtiM.4B2n6Qwlpqf3S9W0Dz5ED4yN192mD/m', 'delegate', 1),
    ('china.ga', '$2b$10$OlDaS2KC4N.3Hgug24RVRuuEbHNpRU9iOmya8KrpY25VEMi7x4QFK', 'delegate', 2),
    ('russia.ga', '$2b$10$pgzLi8K2FUfjR9qOmnSO0OH6AspgX.OjKgmj8zho4E.y7tn7xxTGe', 'delegate', 3),
    ('uk.ga', '$2b$10$RHoziAFmHFfeFItpUYjEZuNVR3qDpVRyymzMbmgfp1IyD3Pwppik2', 'delegate', 4),
    ('france.ga', '$2b$10$f9nl8yHp1tlnUBQfJPpdoeqcbORsc40D1JqAPM5zQP57lrVNYTH4u', 'delegate', 5),
    ('germany.ga', '$2b$10$mkpL2T8OKWXcT0yorSSS/edF4O89q6vClTPVj9KPNg4zyHCMTBDs6', 'delegate', 6),
    ('japan.ga', '$2b$10$I2PxiuxqWugIgMswotazzu/qcMJakh/jFWL4.2SvQdUxT4eu0vPqe', 'delegate', 7),
    ('india.ga', '$2b$10$sgz78p8f2blIxpV.zyhl3OxZcYJQK6Su0t1Txdr/dqFoZBpdeg1..', 'delegate', 8),
    ('brazil.ga', '$2b$10$uSW3IPjcdWtsVldn8kbsA.WqtV1CUm1JNspPJ63rWuy5sfDEGWhku', 'delegate', 9),
    ('nigeria.ga', '$2b$10$GqcRH.VSrT8SOKBEt7ck6eWi9ANQ5a3OBATjjB.1xkLc8Dby3vBl6', 'delegate', 10),
    ('safrica.ga', '$2b$10$zWdLPwxHJDB8AyEgroPJD.mvhBjBfwybXrpInp0WfwQrPOdNVCZY.', 'delegate', 11),
    ('egypt.ga', '$2b$10$wV9JzWesLOPboDgs72dCaeDTKGDXkNnKEk.jF8QU4tEjkc1Dzm58a', 'delegate', 12),
    ('mexico.ga', '$2b$10$v3TyKMV8F7WSBY7sjIxaruGzTi0V6fV4UjrRvgZ.ABmgcyVx6jQte', 'delegate', 13),
    ('australia.ga', '$2b$10$F.8QpqWvTxpGOWrxjGvuaeQ2wSiEdLPScSmKL8TCkPaQ.G8dF6hkG', 'delegate', 14),
    ('canada.ga', '$2b$10$BBrCSN86SJC90xdOkEsK/eBlFC1ud5w0vsy076XCUtQ0agpolpMzS', 'delegate', 15),
    ('usa.sc', '$2b$10$GxT6HAMlxWrW9cKphzLXoeBqw9O0J6s2tyncRgdHNQ11rqjRKRp1S', 'delegate', 16),
    ('china.sc', '$2b$10$dDwJCIYd3dUuhSG/36v7U.GULLHQiiLgFZPDiAKKgYeM.Z8Q1bGsK', 'delegate', 17),
    ('russia.sc', '$2b$10$ULcL.6XjKzOQe6zL4T3vweE7NTNldJjgIynCcolFcMbq.YXX1Eila', 'delegate', 18),
    ('uk.sc', '$2b$10$SEgkDnoXiXsMPpD0I8trxeGlOHS5A1a2K3Ss.00wgD.3RqrsgmI.2', 'delegate', 19),
    ('france.sc', '$2b$10$42y3Kz522RBMYPm.SRHq/uFZ6ldy/aaoFVlZgq2g0iVd6PPnYEona', 'delegate', 20),
    ('japan.sc', '$2b$10$42wiiDOjry0kTQNgBIlxRuWHt3OLD43gmr9yZhdQ9XB4qBZ416pEq', 'delegate', 21),
    ('korea.sc', '$2b$10$ICB/0g5znnLJEI1I7sXrW.mLs4hsdRUWsBWpfQVPSj11j.H5SAmQG', 'delegate', 22),
    ('india.sc', '$2b$10$8PtFGYqN9kbw3BJZn1Mi9ebPyF3YrIrKoIkzv/dQJ5tWmyxgsabv2', 'delegate', 23),
    ('nigeria.sc', '$2b$10$7dczXFp/3zY4yzgJw3LtdefvgUoAMFxKQp/6EfeFTFjlgt7V/4jQW', 'delegate', 24),
    ('argentina.sc', '$2b$10$7fslUd0IsVO5Hw8sYnA3LOgil0rwb1GeTDeOLbgwsc0vB7Z7b6TA2', 'delegate', 25),
    ('usa.ga.2', '$2b$10$V7U4pS5r3ZW.y6VcYVw4BOIP92NoYJn1G50thQw6NMUHUUj1vAcDa', 'delegate', 31),
    ('china.ga.2', '$2b$10$VcofJbPFZ..NZvW0CUjuVe8jE/9W.vbO/07EnAG/x0WtOdWR9eoDq', 'delegate', 32),
    ('russia.ga.2', '$2b$10$2ZzQlyxOartYEva/iNEggeq7r/4ERlTHawdbv6F7zoolq7SaUpCfK', 'delegate', 33),
    ('india.ga.2', '$2b$10$G8mW71AJAbKB92V2pNeGzexnoUnnfGHWYrZ52uBt216fR6LvQd3Ve', 'delegate', 34),
    ('brazil.ga.2', '$2b$10$G1rv.fFT65IDvvdU7v2iX.jSoqWua64Qaby13xfNmiVX8QijeLGg6', 'delegate', 35),
    ('nigeria.ga.2', '$2b$10$u7K4MD6qhsIRiMXEb2FNfOQD5p/7gZ2uqHAhLndT6hs1pAhvgr2GK', 'delegate', 36),
    ('germany.ga.2', '$2b$10$lmG39V9.qG/IfNBpLqWkeOavJvIVzQAThQystP37cFa1ksEJa0MHy', 'delegate', 37),
    ('france.ga.2', '$2b$10$w0wlwBnaDqMZIN/lLPDi9.cFXtcag0AtEpRUCI8cOQeI5QZOeKTBa', 'delegate', 38),
    ('uk.ga.2', '$2b$10$8stJm80d6VzcsiF6ScD6T.9K5CqYakaH3QHJOSs4jq.f0xfTgqIkS', 'delegate', 39),
    ('usa.sc.2', '$2b$10$kfsle81fA704oBZO0FstyepquGEvptt43bnHLjJtjQHpG3xFi.wp2', 'delegate', 40),
    ('china.sc.2', '$2b$10$VleQVg7sx0ofHJmafKPaeeNk0m.tXCYk699DMO9e.1IrTXZ3rGOCu', 'delegate', 41),
    ('russia.sc.2', '$2b$10$NpjZ2Xfu4IZm1yhHlhkXQen59kvAK9/7yWnluKdG4FdJG5hl/Cb2q', 'delegate', 42),
    ('uk.sc.2', '$2b$10$zBqxfHN18vMM50Y1dfwS3u1IAQgECuCL4EBij.Nz1LgTfldPa6jmq', 'delegate', 43),
    ('france.sc.2', '$2b$10$uH7gjKToNTQNP8kgBDexMOg1eaemsuKhlpjMUbuP8VyybgtQREl4y', 'delegate', 44);

-- ============================================================================
-- DEMO CREDENTIAL SHEET (keep this safe)
-- ============================================================================
-- ADMIN
-- username: admin              password: UN@dm1n#2026
--
-- GA DELEGATES (vote on Matter #2 — Digital Cooperation)
-- usa.ga        L1b3rty@UN26     china.ga     Gr8W@ll#2026
-- russia.ga     V0lga@Peace6     uk.ga        BigB3n@UN26!
-- france.ga     Eiff3l@UN26!     germany.ga   Brandenb@UN6
-- japan.ga      Fuji@P3ace26     india.ga     Gandhi@UN26!
-- brazil.ga     Amaz0n@UN26!     nigeria.ga   Abuja@P3ace6
-- safrica.ga    Ubuntu@UN26!     egypt.ga     Pyram1d@UN26
-- mexico.ga     Azt3c@Peace6     australia.ga Koal@UN2026!
-- canada.ga     Maple@UN26!!
--
-- SC DELEGATES (vote on SC Matter #5 — after admin sets to IN_VOTING)
-- usa.sc        W00dSC@UN26!     china.sc     Shuang@SC26!
-- russia.sc     Polyan@SC26!     uk.sc        Karuk1@SC26!
-- france.sc     Broad@SC2026     japan.sc     Yamaz@SC2026
-- korea.sc      Hw@ngSC2026!     india.sc     Har1sh@SC26!
-- nigeria.sc    Malam1@SC26!     argentina.sc Lagor1@SC26!
-- ============================================================================