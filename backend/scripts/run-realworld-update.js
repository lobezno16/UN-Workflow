// Apply 11_realworld_update.sql using the backend DB connection
const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const mysql = require('mysql2/promise');

async function run() {
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'un_workflow_db',
        port: process.env.DB_PORT || 3306,
        multipleStatements: true
    });
    console.log('✓ Connected');
    const sql = fs.readFileSync(path.join(__dirname, '../../database/11_realworld_update.sql'), 'utf8')
        .split('\n').filter(l => !l.trim().startsWith('USE ')).join('\n');
    await conn.query(sql);
    console.log('✅ 11_realworld_update.sql applied — matters updated, alt delegates inserted.');
    await conn.end();
}

run().catch(e => { console.error('Fatal:', e.message); process.exit(1); });
