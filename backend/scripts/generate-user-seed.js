// ============================================================================
// Generate User Seed SQL with bcrypt-hashed passwords
// Run: node backend/scripts/generate-user-seed.js
// Output: database/10_users_seed.sql
// ============================================================================

const bcrypt = require('bcryptjs');
const fs = require('fs');
const path = require('path');

const SALT_ROUNDS = 10;

// User definitions: [username, plaintext_password, role, delegate_id | null]
const users = [
    // Admin
    ['admin',      'UN@dm1n#2026',   'admin',    null],

    // GA Delegates (delegate_id 1–15 from seed)
    ['usa.ga',     'L1b3rty@UN26',   'delegate', 1],
    ['china.ga',   'Gr8W@ll#2026',   'delegate', 2],
    ['russia.ga',  'V0lga@Peace6',   'delegate', 3],
    ['uk.ga',      'BigB3n@UN26!',   'delegate', 4],
    ['france.ga',  'Eiff3l@UN26!',   'delegate', 5],
    ['germany.ga', 'Brandenb@UN6',   'delegate', 6],
    ['japan.ga',   'Fuji@P3ace26',   'delegate', 7],
    ['india.ga',   'Gandhi@UN26!',   'delegate', 8],
    ['brazil.ga',  'Amaz0n@UN26!',   'delegate', 9],
    ['nigeria.ga', 'Abuja@P3ace6',   'delegate', 10],
    ['safrica.ga', 'Ubuntu@UN26!',   'delegate', 11],
    ['egypt.ga',   'Pyram1d@UN26',   'delegate', 12],
    ['mexico.ga',  'Azt3c@Peace6',   'delegate', 13],
    ['australia.ga','Koal@UN2026!',  'delegate', 14],
    ['canada.ga',  'Maple@UN26!!',   'delegate', 15],

    // SC Delegates (delegate_id 16–25 from seed)
    ['usa.sc',      'W00dSC@UN26!',  'delegate', 16],
    ['china.sc',    'Shuang@SC26!',  'delegate', 17],
    ['russia.sc',   'Polyan@SC26!',  'delegate', 18],
    ['uk.sc',       'Karuk1@SC26!',  'delegate', 19],
    ['france.sc',   'Broad@SC2026',  'delegate', 20],
    ['japan.sc',    'Yamaz@SC2026',  'delegate', 21],
    ['korea.sc',    'Hw@ngSC2026!',  'delegate', 22],
    ['india.sc',    'Har1sh@SC26!',  'delegate', 23],
    ['nigeria.sc',  'Malam1@SC26!',  'delegate', 24],
    ['argentina.sc','Lagor1@SC26!',  'delegate', 25],

    // ── ALT GA DELEGATES (for concurrency race demo — delegate_id 31–39)
    ['usa.ga.2',     'Alt@USA-GA26!', 'delegate', 31],
    ['china.ga.2',   'Alt@CHN-GA26!', 'delegate', 32],
    ['russia.ga.2',  'Alt@RUS-GA26!', 'delegate', 33],
    ['india.ga.2',   'Alt@IND-GA26!', 'delegate', 34],
    ['brazil.ga.2',  'Alt@BRA-GA26!', 'delegate', 35],
    ['nigeria.ga.2', 'Alt@NGA-GA26!', 'delegate', 36],
    ['germany.ga.2', 'Alt@DEU-GA26!', 'delegate', 37],
    ['france.ga.2',  'Alt@FRA-GA26!', 'delegate', 38],
    ['uk.ga.2',      'Alt@GBR-GA26!', 'delegate', 39],

    // ── ALT SC DELEGATES — P5 only (delegate_id 40–44)
    ['usa.sc.2',     'Alt@USA-SC26!', 'delegate', 40],
    ['china.sc.2',   'Alt@CHN-SC26!', 'delegate', 41],
    ['russia.sc.2',  'Alt@RUS-SC26!', 'delegate', 42],
    ['uk.sc.2',      'Alt@GBR-SC26!', 'delegate', 43],
    ['france.sc.2',  'Alt@FRA-SC26!', 'delegate', 44],
];

async function generateSeed() {
    console.log('Generating bcrypt hashes (this may take a few seconds)...');

    const lines = [
        '-- ============================================================================',
        '-- 10_users_seed.sql - User Authentication Data (auto-generated)',
        '-- DO NOT edit manually. Re-run generate-user-seed.js to regenerate.',
        '-- ============================================================================',
        'USE un_workflow_db;',
        '',
        '-- Create users table if not exists',
        'CREATE TABLE IF NOT EXISTS users (',
        '    user_id       INT PRIMARY KEY AUTO_INCREMENT,',
        '    username      VARCHAR(50)  NOT NULL UNIQUE,',
        '    password_hash VARCHAR(255) NOT NULL,',
        '    role          ENUM(\'admin\', \'delegate\') NOT NULL DEFAULT \'delegate\',',
        '    delegate_id   INT NULL,',
        '    is_active     BOOLEAN DEFAULT TRUE,',
        '    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,',
        '    CONSTRAINT fk_user_delegate FOREIGN KEY (delegate_id)',
        '        REFERENCES delegate(delegate_id) ON DELETE SET NULL',
        ');',
        '',
        '-- Clear existing data (idempotent)',
        'DELETE FROM users;',
        '',
        '-- Wipe partial votes on GA Matter #2 (Digital Cooperation)',
        '-- so all 15 GA delegates can vote fresh during the demo',
        'DELETE FROM vote WHERE matter_id = 2;',
        '',
        '-- Reset Matter #2 status to IN_VOTING (it already is, but ensure clean state)',
        "UPDATE matter SET status = 'IN_VOTING', actual_completion_date = NULL WHERE matter_id = 2;",
        '',
        '-- Make SC Matter #5 (Peacekeeping Extension) ready for demo',
        "-- Admin will push to IN_VOTING live. SC Matter #6 (Non-Proliferation) already REJECTED.",
        '',
        '-- INSERT users with bcrypt-hashed passwords',
        'INSERT INTO users (username, password_hash, role, delegate_id) VALUES',
    ];

    const valueLines = [];
    for (const [username, password, role, delegate_id] of users) {
        const hash = await bcrypt.hash(password, SALT_ROUNDS);
        const del = delegate_id === null ? 'NULL' : delegate_id;
        valueLines.push(`    ('${username}', '${hash}', '${role}', ${del})`);
        console.log(`  ✓ ${username.padEnd(14)} → hashed`);
    }

    lines.push(valueLines.join(',\n') + ';');
    lines.push('');
    lines.push('-- ============================================================================');
    lines.push('-- DEMO CREDENTIAL SHEET (keep this safe)');
    lines.push('-- ============================================================================');
    lines.push('-- ADMIN');
    lines.push('-- username: admin              password: UN@dm1n#2026');
    lines.push('--');
    lines.push('-- GA DELEGATES (vote on Matter #2 — Digital Cooperation)');
    lines.push('-- usa.ga        L1b3rty@UN26     china.ga     Gr8W@ll#2026');
    lines.push('-- russia.ga     V0lga@Peace6     uk.ga        BigB3n@UN26!');
    lines.push('-- france.ga     Eiff3l@UN26!     germany.ga   Brandenb@UN6');
    lines.push('-- japan.ga      Fuji@P3ace26     india.ga     Gandhi@UN26!');
    lines.push('-- brazil.ga     Amaz0n@UN26!     nigeria.ga   Abuja@P3ace6');
    lines.push('-- safrica.ga    Ubuntu@UN26!     egypt.ga     Pyram1d@UN26');
    lines.push('-- mexico.ga     Azt3c@Peace6     australia.ga Koal@UN2026!');
    lines.push('-- canada.ga     Maple@UN26!!');
    lines.push('--');
    lines.push('-- SC DELEGATES (vote on SC Matter #5 — after admin sets to IN_VOTING)');
    lines.push('-- usa.sc        W00dSC@UN26!     china.sc     Shuang@SC26!');
    lines.push('-- russia.sc     Polyan@SC26!     uk.sc        Karuk1@SC26!');
    lines.push('-- france.sc     Broad@SC2026     japan.sc     Yamaz@SC2026');
    lines.push('-- korea.sc      Hw@ngSC2026!     india.sc     Har1sh@SC26!');
    lines.push('-- nigeria.sc    Malam1@SC26!     argentina.sc Lagor1@SC26!');
    lines.push('-- ============================================================================');

    const outPath = path.join(__dirname, '../../database/10_users_seed.sql');
    fs.writeFileSync(outPath, lines.join('\n'), 'utf8');
    console.log(`\n✅ Seed SQL written to: ${outPath}`);
}

generateSeed().catch(console.error);
