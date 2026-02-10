// ============================================================================
// UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM
// server.js - Main Express Server
// ============================================================================

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

// Import routes
const organsRoutes = require('./routes/organs');
const mattersRoutes = require('./routes/matters');
const votingRoutes = require('./routes/voting');
const resolutionsRoutes = require('./routes/resolutions');
const icjRoutes = require('./routes/icj');
const secretariatRoutes = require('./routes/secretariat');
const trusteeshipRoutes = require('./routes/trusteeship');
const auditRoutes = require('./routes/audit');
const dashboardRoutes = require('./routes/dashboard');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from frontend
app.use(express.static(path.join(__dirname, '../frontend')));

// API Routes
app.use('/api/organs', organsRoutes);
app.use('/api/matters', mattersRoutes);
app.use('/api/voting', votingRoutes);
app.use('/api/resolutions', resolutionsRoutes);
app.use('/api/icj', icjRoutes);
app.use('/api/secretariat', secretariatRoutes);
app.use('/api/trusteeship', trusteeshipRoutes);
app.use('/api/audit', auditRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Catch-all route for SPA
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server Error:', err);
    res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`
╔══════════════════════════════════════════════════════════════╗
║     UNITED NATIONS WORKFLOW MANAGEMENT SYSTEM                ║
║     Server running on http://localhost:${PORT}                   ║
╚══════════════════════════════════════════════════════════════╝
    `);
});

module.exports = app;
