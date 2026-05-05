const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const mysql = require('mysql2/promise');

const SQL_FILES = [
    '01_schema.sql',
    '02_seed.sql',
    '03_views.sql',
    '04_triggers.sql',
    '05_procedures_cursors.sql',
    '10_users_seed.sql',
    '11_realworld_update.sql',
    '13_announcements.sql'
];

async function initDB() {
    console.log('⏳ Connecting to Database...');
    const conn = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        port: process.env.DB_PORT || 3306,
        multipleStatements: true
    });

    try {
        const dbName = process.env.DB_NAME || 'un_workflow_db';
        
        // Ensure Database Exists
        await conn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
        await conn.query(`USE \`${dbName}\`;`);
        console.log(`✓ Database '${dbName}' selected.`);

        for (const file of SQL_FILES) {
            console.log(`⏳ Executing ${file}...`);
            const filePath = path.join(__dirname, '../../database', file);
            if (!fs.existsSync(filePath)) {
                console.warn(`⚠️ Warning: ${file} not found. Skipping.`);
                continue;
            }

            const sql = fs.readFileSync(filePath, 'utf8');
            // Remove USE database statements to prevent conflicts in cloud managed DBs
            const cleanedSQL = sql.split('\n')
                                  .filter(line => !line.trim().toUpperCase().startsWith('USE '))
                                  .join('\n');
            
            await conn.query(cleanedSQL);
            console.log(`✓ ${file} executed successfully.`);
        }

        console.log('✅ Production Database Initialized Successfully!');
    } catch (error) {
        console.error('❌ Database Initialization Failed:', error.message);
        process.exit(1);
    } finally {
        await conn.end();
    }
}

initDB();
