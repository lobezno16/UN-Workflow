# CHAPTER 6
## FRONT-END AND BACK-END CODE OF UNITED NATIONS BUREAUCRATIC WORKFLOW MANAGEMENT SYSTEM

> [!NOTE]
> **Project Update Notice**: The codebase has undergone significant modernization and structural changes since its initial conception. The excerpts below highlight key components of the current architecture. For the complete, fully functioning, and most up-to-date source code—including the full API, frontend design system, and database schema—please refer to the project's official GitHub repository.

### 6.1 Frontend Module Code

**Technology Stack**: HTML5, CSS3, Vanilla JavaScript (ES6+), GSAP 3.12 + ScrollTrigger, Lenis smooth scroll

#### 6.1.1 Main HTML Structure (index.html)

The frontend uses a modern multi-section landing page architecture with a fixed navigation bar, animated hero section, organ card grid, and ICJ spotlight. External libraries (GSAP, Lenis) are loaded from CDN, with custom modules (`hero.js`, `animations.js`, `nav.js`, `app.js`) handling interactivity.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>United Nations | Workflow Management System</title>
  <meta name="description"
    content="United Nations Bureaucratic Workflow Management System — Managing matters,
    voting, resolutions, and ICJ cases across the six principal UN organs.">

  <!-- Preconnect for performance -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

  <!-- Stylesheets -->
  <link rel="stylesheet" href="css/main.css">
  <link rel="stylesheet" href="css/pages.css">
</head>

<body>
  <!-- Preloader -->
  <div class="preloader" id="preloader">
    <div class="preloader__text">UNITED NATIONS</div>
  </div>

  <!-- Navigation -->
  <nav class="nav" id="main-nav">
    <div class="nav__inner">
      <a href="index.html" class="nav__logo">
        <div class="nav__logo-icon">UN</div>
        <div>
          <div class="nav__logo-text">United Nations</div>
          <div class="nav__logo-sub">Workflow System</div>
        </div>
      </a>
      <div class="nav__links">
        <a href="#pulse" class="nav__link active" data-section="pulse">Global Pulse</a>
        <a href="#organs" class="nav__link" data-section="organs">Organs</a>
        <a href="organs/general-assembly.html" class="nav__link">GA</a>
        <a href="organs/security-council.html" class="nav__link">SC</a>
        <a href="login.html?tab=delegate" class="nav__link" style="color:var(--color-gold)">
            🌐 Vote</a>
        <a href="login.html?tab=admin" class="nav__link" style="color:var(--color-gold)">
            🛡 Admin</a>
      </div>
    </div>
  </nav>

  <!-- Hero Section with particle canvas -->
  <section class="hero" id="hero">
    <div class="hero__bg">
      <img class="hero__bg-image" src="images/hero-bg.png" alt="" loading="eager">
      <div class="hero__bg-overlay"></div>
    </div>
    <canvas class="hero__particles" id="hero-canvas"></canvas>
    <div class="hero__content">
      <p class="hero__eyebrow">Established 1945 · 193 Member States</p>
      <h1 class="hero__title">
        <span>UNITED</span>
        <span class="t-outline">NATIONS</span>
      </h1>
      <div class="hero__cta">
        <a href="#organs" class="btn btn-gold">Explore Organs</a>
        <a href="#pulse" class="btn btn-outline">Global Pulse ↓</a>
      </div>
    </div>
  </section>

  <!-- UN Organs — 3D Card Grid (6 cards linking to dedicated pages) -->
  <section class="organs-section" id="organs">
    <div class="container">
      <div class="organs__grid perspective-container" id="organs-grid">
        <a href="organs/general-assembly.html" class="organ-card tilt-card" data-organ="GA">
          <div class="organ-card__bg">
            <img src="images/general-assembly.png" alt="General Assembly Hall">
          </div>
          <div class="organ-card__content">
            <div class="organ-card__code">GA · Est. 1945</div>
            <h3 class="organ-card__name">General Assembly</h3>
            <p class="organ-card__desc">All 193 Member States have equal representation.</p>
            <span class="organ-card__arrow">Explore →</span>
          </div>
        </a>
        <!-- Security Council, ECOSOC, ICJ, Secretariat, Trusteeship cards follow
             the same pattern, each linking to its dedicated /organs/*.html page -->
      </div>
    </div>
  </section>

  <!-- Scripts -->
  <script src="https://unpkg.com/gsap@3.12.5/dist/gsap.min.js"></script>
  <script src="https://unpkg.com/gsap@3.12.5/dist/ScrollTrigger.min.js"></script>
  <script src="https://unpkg.com/lenis@1.1.13/dist/lenis.min.js"></script>
  <script src="js/hero.js"></script>
  <script src="js/animations.js"></script>
  <script src="js/nav.js"></script>
  <script src="js/app.js"></script>
</body>
</html>
```

#### 6.1.2 CSS Design System (main.css excerpt)

The design system is built on CSS custom properties (design tokens) covering color palette, typography (3 font families), spacing, glassmorphism, 3D perspective, and scroll-triggered animation states.

```css
/* Google Fonts — Display, Body, Monospace */
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700
  &family=Inter:wght@300;400;500;600;700
  &family=JetBrains+Mono:wght@300;400;500&display=swap');

:root {
  /* Colors */
  --color-bg-primary:    #0a0e17;
  --color-bg-secondary:  #0f1520;
  --color-bg-glass:      rgba(255,255,255,0.04);
  --color-border-glass:  rgba(255,255,255,0.08);
  --color-gold:          #c9a84c;
  --color-blue-un:       #4b9cd3;
  --color-red:           #e85555;
  --color-green:         #5ecc6e;

  /* Typography */
  --font-display: 'Playfair Display', Georgia, serif;
  --font-body:    'Inter', -apple-system, sans-serif;
  --font-mono:    'JetBrains Mono', 'Fira Code', monospace;

  --fs-hero: clamp(3.5rem, 10vw, 9rem);
  --fs-h1:   clamp(2.5rem, 5vw, 5rem);

  /* Glass */
  --glass-blur: blur(20px);

  /* Organ accent colors */
}
[data-organ="GA"]  { --organ-color: #4b9cd3; }
[data-organ="SC"]  { --organ-color: #e85555; }
[data-organ="ECOSOC"] { --organ-color: #3ecfb4; }
[data-organ="ICJ"] { --organ-color: #c9a84c; }
[data-organ="SEC"] { --organ-color: #a78bfa; }
[data-organ="TC"]  { --organ-color: #f59e0b; }

/* Glassmorphism cards */
.glass-card {
  background: var(--color-bg-glass);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid var(--color-border-glass);
  border-radius: 16px;
  padding: 2rem;
  transition: border-color 0.4s, box-shadow 0.4s, transform 0.4s;
}

.glass-card:hover {
  border-color: rgba(201,168,76,0.2);
  box-shadow: 0 0 40px rgba(201,168,76,0.15);
}

/* Scroll-triggered reveal animations */
.reveal {
  opacity: 0;
  transform: translateY(60px);
  transition: opacity 0.8s cubic-bezier(0.16,1,0.3,1),
              transform 0.8s cubic-bezier(0.16,1,0.3,1);
}

.reveal.is-visible {
  opacity: 1;
  transform: translateY(0);
}
```

#### 6.1.3 JavaScript Application Logic (app.js excerpt)

The main entry point initializes Lenis smooth scrolling, connects it to GSAP's ScrollTrigger for synchronized animations, and orchestrates GSAP stagger animations on organ cards and ICJ case cards.

```javascript
document.addEventListener('DOMContentLoaded', () => {
  // Preloader
  const preloader = document.getElementById('preloader');
  window.addEventListener('load', () => {
    setTimeout(() => {
      if (preloader) {
        preloader.classList.add('loaded');
        setTimeout(() => preloader.remove(), 600);
      }
    }, 800);
  });

  // Lenis smooth scroll
  const lenis = new Lenis({
    duration: 1.2,
    easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
    smoothWheel: true,
    wheelMultiplier: 1,
  });

  // Connect Lenis to GSAP ScrollTrigger
  if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
    lenis.on('scroll', ScrollTrigger.update);
    gsap.ticker.add((time) => lenis.raf(time * 1000));
    gsap.ticker.lagSmoothing(0);
  }

  // Initialize navigation and animation engine modules
  const nav = new Navigation();
  const animations = new AnimationEngine();

  // GSAP organ card stagger entrance
  const organCards = document.querySelectorAll('.organ-card');
  if (organCards.length) {
    gsap.from(organCards, {
      y: 80, opacity: 0, rotateX: -10,
      stagger: 0.1, duration: 1, ease: 'expo.out',
      scrollTrigger: {
        trigger: '.organs__grid',
        start: 'top 80%',
        toggleActions: 'play none none reverse',
      },
    });
  }
});
```

### 6.2 Backend Code and Database Connectivity

**Technology Stack**: Node.js 20+, Express.js 4.x, mysql2/promise, bcryptjs, jsonwebtoken (JWT)

#### 6.2.1 Database Connectivity (config/db.js)

The database module creates a mysql2 connection pool with keep-alive support, tests connectivity on startup, and exports a `withTransaction` helper that handles `BEGIN → COMMIT/ROLLBACK → RELEASE` lifecycle along with a `query` wrapper for single-statement execution.

```javascript
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'un_workflow_db',
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0
});

// Test connection on startup
pool.getConnection()
    .then(connection => {
        console.log('✓ Database connected successfully');
        connection.release();
    })
    .catch(err => {
        console.error('✗ Database connection failed:', err.message);
    });

// Transaction helper — ACID-compliant wrapper
async function withTransaction(callback) {
    const connection = await pool.getConnection();
    await connection.beginTransaction();
    try {
        const result = await callback(connection);
        await connection.commit();
        return result;
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

// Query helper with error logging
async function query(sql, params = []) {
    try {
        const [rows] = await pool.execute(sql, params);
        return rows;
    } catch (error) {
        console.error('Query Error:', error.message);
        throw error;
    }
}

module.exports = { pool, query, withTransaction };
```

#### 6.2.2 Express Server (server.js)

The server registers 11 API route modules, serves the frontend as static files, includes a health check endpoint, global error handling middleware, and a catch-all SPA route.

```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from frontend
app.use(express.static(path.join(__dirname, '../frontend')));

// API Routes — 11 route modules
app.use('/api/auth', require('./routes/auth'));
app.use('/api/organs', require('./routes/organs'));
app.use('/api/matters', require('./routes/matters'));
app.use('/api/voting', require('./routes/voting'));
app.use('/api/resolutions', require('./routes/resolutions'));
app.use('/api/icj', require('./routes/icj'));
app.use('/api/secretariat', require('./routes/secretariat'));
app.use('/api/trusteeship', require('./routes/trusteeship'));
app.use('/api/audit', require('./routes/audit'));
app.use('/api/dashboard', require('./routes/dashboard'));
app.use('/api/announcements', require('./routes/announcements'));

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server Error:', err);
    res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
```

#### 6.2.3 Voting Routes with Concurrency Control (routes/voting.js)

The voting route implements JWT-authenticated, role-guarded vote casting with `SELECT ... FOR UPDATE` row-level locking to prevent the double-vote race condition. The `requireDelegate` middleware ensures only delegates can cast votes, and an identity check prevents delegates from voting on behalf of other delegations.

```javascript
const express = require('express');
const router = express.Router();
const { query, withTransaction, pool } = require('../config/db');
const { requireAuth, requireAdmin, requireDelegate } = require('../middleware/auth');

// POST cast a vote — delegate authentication required
router.post('/', requireAuth, requireDelegate, async (req, res) => {
    try {
        const result = await withTransaction(async (connection) => {
            const { matter_id, state_id, delegate_id, vote_value } = req.body;

            // Security: delegate can only vote as themselves
            if (req.user.delegate_id !== delegate_id) {
                throw new Error('You can only cast votes on behalf of your own delegation.');
            }

            // Lock the matter row to check status
            const [[matter]] = await connection.execute(
                'SELECT status, requires_voting FROM matter WHERE matter_id = ? FOR UPDATE',
                [matter_id]
            );

            if (!matter) throw new Error('Matter not found');
            if (matter.status !== 'IN_VOTING') {
                throw new Error('Matter is not in voting stage');
            }

            // Check for existing vote from this state (with lock)
            const [[existingVote]] = await connection.execute(
                'SELECT vote_id FROM vote WHERE matter_id = ? AND state_id = ? FOR UPDATE',
                [matter_id, state_id]
            );

            if (existingVote) {
                throw new Error('This state has already voted on this matter');
            }

            // Cast the vote
            const [insertResult] = await connection.execute(
                'INSERT INTO vote (matter_id, state_id, delegate_id, vote_value) VALUES (?, ?, ?, ?)',
                [matter_id, state_id, delegate_id, vote_value]
            );

            return { vote_id: insertResult.insertId, vote_value };
        });

        res.status(201).json(result);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

module.exports = router;
```

#### 6.2.4 Stored Procedure Call Example

```javascript
// Call stored procedure for vote computation
router.get('/matter/:matterId/tally', async (req, res) => {
    try {
        await pool.execute('CALL sp_vote_tally(?, @yes, @no, @abstain)', [req.params.matterId]);
        const [[result]] = await pool.execute(
            'SELECT @yes AS yes, @no AS no, @abstain AS abstain'
        );
        res.json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
```

---

# CHAPTER 7
## RESULTS AND DISCUSSIONS

### 7.1 Screenshots of Frontend

#### Figure 7.1: Dashboard Screenshot
The dashboard displays:
- 6 stat cards showing: Total Matters, Pending Matters, Resolutions, Active ICJ Cases, Active Directives, Officers
- Matters by Organ table with breakdown by GA, SC, ECOSOC, ICJ, SEC, TC
- Recent Activity feed showing audit trail entries
- Pending Approvals list
- Matters in Voting status grid

*[Screenshot placeholder: dark-themed dashboard with UN blue accents, glassmorphism cards]*

#### Figure 7.2: UN Organs Page
Displays all 6 principal organs as cards:
- General Assembly (GA) - 15 matters, 12 officers
- Security Council (SC) - 8 matters, 5 officers
- ECOSOC - 10 matters, 8 officers
- ICJ - 5 cases, 15 judges
- Secretariat - 20 directives, 45 officers
- Trusteeship Council - 2 territories, 3 reports

*[Screenshot placeholder: organ cards with hover effects]*

#### Figure 7.3: Matters Management Page
Shows:
- Filters: Organ dropdown, Status dropdown
- New Matter button
- Data table with columns: Number, Title, Organ, Type, Status, Submitted, Actions
- Status badges (color-coded): DRAFT (gray), SUBMITTED (blue), IN_VOTING (yellow), PASSED (green), REJECTED (red)

*[Screenshot placeholder: matters table with filtering]*

#### Figure 7.4: Voting Results Page
Displays for a matter in voting:
- Vote summary: YES count (green), NO count (red), ABSTAIN count (yellow)
- Progress bar showing vote distribution
- Individual votes table with State, Delegate, Vote columns
- Compute Outcome button

*[Screenshot placeholder: vote summary visualization]*

#### Figure 7.5: ICJ Cases Page
Shows:
- Case cards with: Case Number, Title, Type, Parties, Status
- Hearing schedule timeline
- Judgment history

*[Screenshot placeholder: ICJ case management interface]*

### 7.2 Screenshots of Database

#### Figure 7.6: MySQL Workbench Schema Diagram
The EER diagram in MySQL Workbench shows:
- 21 tables connected by foreign key relationships
- Primary keys marked with key icon
- Foreign key lines showing cardinality (1:N, M:N)
- Tables grouped by function: Core (organs, states), Workflow (matters, approvals, votes), ICJ, Secretariat, Trusteeship, Audit

*[Screenshot placeholder: MySQL Workbench EER diagram]*

#### Figure 7.7: Sample Table Outputs

**un_organ table:**
```
+----------+------------+----------------------------------+
| organ_id | organ_code | organ_name                       |
+----------+------------+----------------------------------+
|        1 | GA         | General Assembly                 |
|        2 | SC         | Security Council                 |
|        3 | ECOSOC     | Economic and Social Council      |
|        4 | ICJ        | International Court of Justice   |
|        5 | SEC        | United Nations Secretariat       |
|        6 | TC         | Trusteeship Council              |
+----------+------------+----------------------------------+
```

**vote table with aggregation:**
```
+---------------+-------------------------------+-----+----+---------+
| matter_number | title                         | YES | NO | ABSTAIN |
+---------------+-------------------------------+-----+----+---------+
| GA/PROP/24/01 | Climate Action Resolution     |  12 |  3 |       2 |
| SC/PROP/24/02 | Peacekeeping Extension        |   9 |  1 |       0 |
+---------------+-------------------------------+-----+----+---------+
```

### 7.3 Discussions

#### 7.3.1 Achievements

The project successfully achieved all primary objectives outlined in the initial design phase, culminating in a comprehensive, production-grade system that models the full procedural complexity of the United Nations:

1. **Comprehensive Domain Modeling of All Six Principal Organs**: The schema (`database/01_schema.sql`) defines 21 interconnected tables that accurately capture the distinct governance structures of the General Assembly (193-member universal body), Security Council (15 members with P5 veto power), ECOSOC (54 elected members with staggered 3-year terms), International Court of Justice (15 judges with 9-year terms and advisory/contentious jurisdiction), Secretariat (hierarchical departmental structure under the Secretary-General), and the suspended Trusteeship Council. Each organ's unique procedural rules — including different voting thresholds (simple majority vs. two-thirds vs. 9-of-15 with veto) — are encoded directly into the database schema via the `matter.voting_threshold` and `member_state.is_sc_permanent_member` columns [1][2].

2. **Concurrency-Safe Voting System with Race Condition Prevention**: The voting subsystem (`backend/routes/voting.js`) implements a transactional workflow using MySQL's `SELECT ... FOR UPDATE` row-level locking mechanism within explicit `BEGIN`/`COMMIT` boundaries. This prevents the critical double-vote race condition where two delegates from the same member state could simultaneously submit conflicting votes. The system was tested with alternate delegate accounts (e.g., `usa.ga` and `usa.ga.2`) to empirically demonstrate that InnoDB's pessimistic locking serializes concurrent vote insertion attempts, ensuring exactly one vote per state per matter [3][4].

3. **Automated Audit Trail via Database Triggers**: Six `AFTER INSERT`, `AFTER UPDATE`, and `AFTER DELETE` triggers defined in `database/04_triggers.sql` automatically log every data modification to a centralized `audit_log` table. This non-blocking, server-side audit mechanism operates independently of the application layer, ensuring tamper-proof accountability. Every matter status change, vote cast, and resolution adoption is captured with timestamp, actor identity, old/new values, and the originating operation type [5].

4. **Stored Procedures with Cursor-Based Vote Computation**: The vote tallying logic (`database/05_procedures_cursors.sql`) uses MySQL stored procedures with cursors to iterate through individual vote records, computing YES/NO/ABSTAIN aggregates and comparing them against organ-specific thresholds. This demonstrates the use of server-side procedural SQL for complex business logic that benefits from proximity to data, reducing network round-trips compared to application-level iteration [6].

5. **Full-Stack Production Deployment with JWT Authentication**: The system implements a complete authentication pipeline using bcrypt password hashing (10 salt rounds) and JSON Web Token (JWT) session management (`backend/routes/auth.js`, `backend/middleware/auth.js`). Role-based access control distinguishes between `admin` and `delegate` roles, ensuring that only administrators can create/modify matters and compute vote outcomes, while delegates can only cast votes on behalf of their assigned member state [7].

6. **Real-World Data Integration**: All matter content reflects actual UN agenda items from the 2025–2026 session period (`database/11_realworld_update.sql`), including the Gaza ceasefire resolution (A/ES-10/L.30/Rev.2), the AI Governance Framework Convention (GA/RES/80/002), Haiti MSSM Phase II extension (S/RES/2793), and Sudan humanitarian corridors (S/RES/2794). This grounding in real-world events enhances the system's pedagogical and demonstrative value [1][8].

#### 7.3.2 Challenges and Solutions

| # | Challenge | Root Cause | Solution Implemented | Reference File |
|---|-----------|-----------|----------------------|----------------|
| 1 | **Double-voting race condition** | Two concurrent HTTP POST requests from different delegates of the same state could both pass the "no existing vote" check before either INSERT completes | `SELECT vote_id FROM vote WHERE matter_id = ? AND state_id = ? FOR UPDATE` — acquires an exclusive row-level lock (or gap lock if no row exists) within a serializable transaction, forcing the second transaction to wait until the first commits or rolls back [3] | `backend/routes/voting.js:76–83` |
| 2 | **Complex vote threshold calculation** | Different organs require different majority types (simple, two-thirds, 9-of-15 with veto) which cannot be expressed as a single static SQL comparison | Stored procedure `sp_compute_vote_outcome` uses a cursor to iterate votes, then applies organ-specific threshold logic via conditional branching. The SC veto check queries `member_state.is_sc_permanent_member` to detect any P5 "NO" vote [6] | `database/05_procedures_cursors.sql` |
| 3 | **Audit trail performance overhead** | Synchronous logging of every INSERT/UPDATE/DELETE could degrade transaction throughput | `AFTER` triggers execute non-blocking logging after the main DML statement completes and its locks are released. The `audit_log` table uses a simple auto-increment PK with no foreign keys, minimizing lock contention [5] | `database/04_triggers.sql` |
| 4 | **Multi-step approval workflow** | Matter lifecycle involves 7 discrete status transitions (DRAFT → SUBMITTED → UNDER_REVIEW → PENDING_APPROVAL → IN_VOTING → PASSED/REJECTED → RESOLUTION_ISSUANCE) with different actors responsible at each stage | `workflow_stage` table tracks each transition with timestamps, actor references, and optional comments. `CHECK` constraints on `matter.status` enforce the valid ENUM set, while application-layer logic validates transition legality [9] | `database/01_schema.sql:134–170` |
| 5 | **Undefined parameter SQL injection** | ICJ case submissions intermittently passed `undefined` values for `matter_number` or `organ_id`, causing MySQL `ER_BIND_PARAMS_MUST_NOT_CONTAIN_UNDEFINED` errors | Added explicit null-coalescing and validation in the POST `/api/matters` handler: all required fields are validated before query execution, with descriptive 400-status error responses for missing parameters [10] | `backend/routes/matters.js` |
| 6 | **Frontend GSAP animation visibility bug** | Dynamically injected DOM elements (e.g., ECOSOC matter cards) were assigned the CSS class `.reveal` which GSAP/ScrollTrigger initializes at page load. Since these elements didn't exist during initialization, they remained at `opacity: 0` permanently | Removed `.reveal` class from dynamically-created elements and explicitly set `opacity: 1` via inline style. Static fallback content retained for organs with no database matters | `frontend/js/app.js:238–240` |

#### 7.3.3 Technical Analysis

**Database Normalization**: The schema achieves Fifth Normal Form (5NF) by eliminating all join dependencies. The progression from UNF → 1NF → 2NF → 3NF → BCNF → 4NF → 5NF was systematically demonstrated in Chapter 4, with the `matter` table's functional dependency set {matter_id} → {title, description, organ_id, status, ...} satisfying BCNF, and the `committee_membership` junction table resolving the M:N relationship between `committee` and `delegate` without introducing multi-valued dependencies [11][12].

**ACID Transaction Properties**: The voting transaction explicitly demonstrates all four ACID properties — **Atomicity** (the vote INSERT and duplicate-check are wrapped in BEGIN/COMMIT), **Consistency** (CHECK constraints and FOREIGN KEY constraints prevent invalid state_id or vote_value entries), **Isolation** (FOR UPDATE locks prevent dirty reads of the vote table during concurrent access), and **Durability** (InnoDB's redo log ensures committed votes survive server crashes) [3][4].

**Query Complexity**: Chapter 3 queries (`database/07_queries_chapter3.sql`, 69 KB) demonstrate advanced SQL patterns including multi-table JOINs (up to 6-way), correlated subqueries, aggregate functions with GROUP BY/HAVING, window functions (ROW_NUMBER, RANK), Common Table Expressions (CTEs), EXISTS/NOT EXISTS predicates, and UNION operations across organ-specific result sets [13].

#### 7.3.4 Future Enhancements

1. **Fine-Grained Role-Based Access Control (RBAC)**: Extend the current binary admin/delegate model to support officer roles, committee chairs, court registrars, and Secretariat department heads, each with granular permissions mapped to specific API endpoints and database operations [14].

2. **Document Attachment Storage**: Integrate a `matter_document` table with BLOB or external file storage (e.g., AWS S3) to support resolution drafts, legal briefs, advisory opinions, and amendment proposals as first-class entities linked to their parent matters [15].

3. **Real-Time Event Streaming via WebSocket**: Replace the current 6-second polling interval on the vote tally page with Server-Sent Events (SSE) or WebSocket connections to push vote updates, matter status transitions, and admin announcements to connected clients in real time [16].

4. **Comprehensive Mobile Responsiveness**: While the current glassmorphism UI is desktop-optimized with responsive breakpoints at 768px and 900px, a dedicated mobile-first redesign using CSS Container Queries would improve the experience on smartphones and tablets used by delegates in the General Assembly hall [17].

5. **External API Integration**: Expose a RESTful API conforming to the UN System Data Standards for interoperability with existing UN systems such as the Official Document System (ODS), the UN Digital Library, and the General Assembly Voting Records database [8][18].

6. **Database Replication and High Availability**: Implement MySQL Group Replication or InnoDB Cluster to support multi-region deployment, ensuring that the voting system remains available during network partitions between UN headquarters and duty stations [4][19].

### 7.4 Conclusion

The United Nations Bureaucratic Workflow Management System represents a comprehensive application of advanced database management concepts to a complex, real-world institutional domain. The project successfully demonstrates the complete lifecycle of database-driven software engineering — from conceptual ER modeling and logical schema design through physical implementation, normalization verification, and production deployment.

**From a database perspective**, the system showcases normalized schema design through Fifth Normal Form (5NF) across 21 tables, with systematic elimination of update anomalies, insertion anomalies, and deletion anomalies documented through before-and-after demonstrations in Chapter 4. The implementation of 6 views (`database/03_views.sql`), 6 triggers (`database/04_triggers.sql`), 8 stored procedures with cursor-based iteration (`database/05_procedures_cursors.sql`), and 5 fully ACID-compliant transactions (`database/06_transactions_concurrency_demo.sql`) collectively covers all major categories of server-side database programming [3][5][6][11].

**From a concurrency control perspective**, the voting subsystem provides a textbook demonstration of pessimistic locking using `SELECT ... FOR UPDATE`, with empirically verifiable race condition prevention. The alternate delegate accounts (`usa.ga` vs. `usa.ga.2`) enable live demonstration of lock serialization, where the second transaction's duplicate-vote check blocks until the first transaction commits — a critical correctness guarantee for any democratic voting system [3][4].

**From a software engineering perspective**, the three-tier architecture (MySQL database → Node.js/Express API → HTML/CSS/JS frontend) follows industry-standard separation of concerns. The API layer implements proper input validation, JWT-based stateless authentication with bcrypt password hashing, and structured error handling. The frontend employs modern CSS techniques (custom properties, glassmorphism, `backdrop-filter`, CSS Grid, flexbox) with GSAP-powered scroll animations for a premium user experience [7][17][20].

**From a domain modeling perspective**, the system captures the procedural nuances of all six UN principal organs — from the General Assembly's one-nation-one-vote universality to the Security Council's P5 veto mechanism, from the ICJ's dual contentious/advisory jurisdiction to the Trusteeship Council's suspended-but-not-abolished status. The integration of real-world 2025–2026 UN agenda items (Gaza ceasefire, AI governance, Haiti peacekeeping, Sudan humanitarian corridors) grounds the system in contemporary international affairs, reinforcing its value as both a technical artifact and a pedagogical tool [1][2][8].

In summary, this project bridges the gap between theoretical database concepts taught in academic curricula and their practical application in modeling complex institutional workflows, delivering a system that is simultaneously technically rigorous and operationally realistic.

---

## REFERENCES

1. United Nations, "Charter of the United Nations and Statute of the International Court of Justice," 1945. [Online]. Available: https://www.un.org/en/about-us/un-charter. [Accessed: May 2026].

2. United Nations General Assembly, "Rules of Procedure of the General Assembly," Document A/520/Rev.19. [Online]. Available: https://www.un.org/en/ga/about/ropga/. [Accessed: May 2026].

3. Oracle Corporation, "MySQL 8.0 Reference Manual: InnoDB Locking and Transaction Model," 2024. [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/innodb-locking-transaction-model.html. [Accessed: May 2026].

4. Oracle Corporation, "MySQL 8.0 Reference Manual: InnoDB Transaction Isolation Levels," 2024. [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html. [Accessed: May 2026].

5. Oracle Corporation, "MySQL 8.0 Reference Manual: Using Triggers," 2024. [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/triggers.html. [Accessed: May 2026].

6. Oracle Corporation, "MySQL 8.0 Reference Manual: Cursors," 2024. [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/cursors.html. [Accessed: May 2026].

7. Auth0, "JSON Web Token (JWT) Introduction," RFC 7519. [Online]. Available: https://jwt.io/introduction. [Accessed: May 2026].

8. United Nations, "General Assembly Voting Records," UN Digital Library. [Online]. Available: https://digitallibrary.un.org/search?cc=Voting+Data. [Accessed: May 2026].

9. R. Elmasri and S. B. Navathe, *Fundamentals of Database Systems*, 7th ed. Pearson, 2016, ch. 4–5.

10. Node.js Foundation, "Node.js v20 Documentation," 2024. [Online]. Available: https://nodejs.org/docs/latest-v20.x/api/. [Accessed: May 2026].

11. A. Silberschatz, H. F. Korth, and S. Sudarshan, *Database System Concepts*, 7th ed. McGraw-Hill, 2020, ch. 7–8.

12. C. J. Date, *An Introduction to Database Systems*, 8th ed. Pearson, 2004, ch. 12 (Further Normalization).

13. Oracle Corporation, "MySQL 8.0 Reference Manual: SELECT Syntax," 2024. [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/select.html. [Accessed: May 2026].

14. D. F. Ferraiolo, D. R. Kuhn, and R. Chandramouli, "Role-Based Access Control," 2nd ed. Artech House, 2007.

15. Oracle Corporation, "MySQL 8.0 Reference Manual: The BLOB and TEXT Types," 2024. [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/blob.html. [Accessed: May 2026].

16. Mozilla Developer Network, "WebSocket API," MDN Web Docs. [Online]. Available: https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API. [Accessed: May 2026].

17. Mozilla Developer Network, "CSS Grid Layout," MDN Web Docs. [Online]. Available: https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_grid_layout. [Accessed: May 2026].

18. United Nations System Chief Executives Board for Coordination, "UN System Data Standards." [Online]. Available: https://unsceb.org/topics/data-standards. [Accessed: May 2026].

19. Oracle Corporation, "MySQL 8.0 Reference Manual: InnoDB Cluster," 2024. [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/mysql-innodb-cluster-introduction.html. [Accessed: May 2026].

20. Express.js, "Express.js 4.x API Reference," 2024. [Online]. Available: https://expressjs.com/en/4x/api.html. [Accessed: May 2026].
