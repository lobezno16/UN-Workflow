# United Nations Bureaucratic Workflow Management System

A complete DBMS mini project modeling the six principal organs of the United Nations with a bureaucratic workflow management system.

## Project Structure
```
un-workflow-system/
├── database/           # MySQL Scripts
│   ├── 01_schema.sql        # DDL - 21 tables
│   ├── 02_seed.sql          # DML - Sample data
│   ├── 03_views.sql         # 8 database views
│   ├── 04_triggers.sql      # 9 triggers
│   ├── 05_procedures_cursors.sql  # 5 stored procedures
│   ├── 06_transactions_concurrency_demo.sql
│   └── 07_queries_chapter3.sql    # 24+ queries + RA
├── backend/            # Node.js Express API
│   ├── server.js
│   ├── config/db.js
│   └── routes/         # 9 API route files
├── frontend/           # Premium Web UI
│   ├── index.html
│   ├── css/styles.css
│   └── js/
└── report/            # Project Report
```

## Quick Start

### 1. Database Setup (MySQL Workbench)
1. Open MySQL Workbench and connect to your server
2. Run scripts in order: `01_schema.sql` → `02_seed.sql` → ... → `07_queries_chapter3.sql`

### 2. Backend Setup
```bash
cd backend
npm install
# Create .env file from .env.example with your MySQL credentials
npm start
```

### 3. Access Application
Open http://localhost:3000 in your browser

## Features
- **6 UN Organs**: GA, SC, ECOSOC, ICJ, Secretariat, Trusteeship Council
- **Matter Workflow**: Draft → Review → Approval → Voting → Resolution
- **Voting System**: Yes/No/Abstain with threshold validation
- **ICJ Cases**: Cases, hearings, judgments
- **Secretariat**: Directives, departments, officers
- **Audit Trail**: Complete action logging

## Technologies
- **Database**: MySQL 8.0
- **Backend**: Node.js, Express, mysql2
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Design**: Dark theme, glassmorphism, responsive
