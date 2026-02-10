---
description: Deploy the UN Workflow System locally
---

# Deploy UN Workflow System

## Prerequisites
- MySQL 8.0 installed and running
- Node.js 18+ installed
- Database created and seeded (run SQL scripts in `database/` folder in order)

## Steps

// turbo-all

1. Navigate to the backend directory
```bash
cd backend
```

2. Install dependencies (if not already installed)
```bash
npm install
```

3. Verify `.env` file exists with correct MySQL credentials:
```env
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=un_workflow_db
```

4. Start the backend server
```bash
npm start
```

5. Open the application in your browser
   - Navigate to: http://localhost:3000

## Verification
- Health check: http://localhost:3000/api/health
- Dashboard stats: http://localhost:3000/api/dashboard/stats

## Troubleshooting
- If database connection fails, verify MySQL is running and credentials in `.env` are correct
- If port 3000 is in use, change `PORT` in `.env` or stop the conflicting process
