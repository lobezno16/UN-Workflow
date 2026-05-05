// Run users seed using the same DB connection as the backend
const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const mysql = require('mysql2/promise');

async function runSeed() {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'un_workflow_db',
        port: process.env.DB_PORT || 3306,
        multipleStatements: true
    });

    console.log('✓ Connected to MySQL');

    const sql = fs.readFileSync(path.join(__dirname, '../../database/10_users_seed.sql'), 'utf8');

    // Remove the USE statement (we already connected to the DB)
    // and execute everything else as a multi-statement query
    const cleaned = sql
        .split('\n')
        .filter(line => !line.trim().startsWith('USE '))
        .join('\n');

    const conn2 = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'un_workflow_db',
        port: process.env.DB_PORT || 3306,
        multipleStatements: true
    });

    await conn.end();

    try {
        await conn2.query(cleaned);
        console.log('✅ Seed executed successfully!');
    } finally {
        await conn2.end();
    }
}

runSeed().catch(e => { console.error('Fatal:', e.message); process.exit(1); });
