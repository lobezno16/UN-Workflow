# United Nations Bureaucratic Workflow Management System

A complete DBMS mini project modeling the six principal organs of the United Nations with a bureaucratic workflow management system. Features an immersive, cinematic 3D scroll-based frontend with GSAP animations, parallax effects, and glassmorphism design.

---

## Project Structure

```
un-workflow-system/
├── database/                   # MySQL Scripts
│   ├── 01_schema.sql                # DDL — 21 tables
│   ├── 02_seed.sql                  # DML — Sample data
│   ├── 03_views.sql                 # 8 database views
│   ├── 04_triggers.sql              # 9 triggers
│   ├── 05_procedures_cursors.sql    # 5 stored procedures
│   ├── 06_transactions_concurrency_demo.sql
│   └── 07_queries_chapter3.sql      # 24+ queries + Relational Algebra
├── backend/                    # Node.js Express API
│   ├── server.js
│   ├── config/db.js
│   └── routes/                      # 9 API route files
├── frontend/                   # Immersive 3D Web UI
│   ├── index.html                   # Homepage — hero, global pulse, organs, ICJ spotlight
│   ├── css/
│   │   ├── main.css                 # Design system (tokens, typography, glass, 3D)
│   │   ├── pages.css                # Homepage section styles
│   │   └── organ-page.css           # Shared organ page layout
│   ├── js/
│   │   ├── app.js                   # Main initializer (Lenis, GSAP, custom cursor)
│   │   ├── animations.js            # GSAP engine (scroll reveals, parallax, 3D tilt, counters)
│   │   ├── hero.js                  # Canvas particle system (golden particles)
│   │   └── nav.js                   # Navigation (scroll-direction hide/show, hamburger)
│   ├── organs/                      # Individual organ pages
│   │   ├── general-assembly.html
│   │   ├── security-council.html
│   │   ├── ecosoc.html
│   │   ├── icj.html
│   │   ├── secretariat.html
│   │   └── trusteeship.html
│   └── images/                      # AI-generated + curated images
└── report/                     # Project Report
```

---

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

### 3. Frontend Only (No Database Required)
To view just the frontend UI without database/backend:
```bash
cd frontend
npx -y http-server ./ -p 3000 -c-1 --cors
```
Then open **http://localhost:3000** in your browser.

### 4. Full Application
With the backend running:
Open **http://localhost:3000** in your browser.

---

## Features

### Frontend
- **Immersive 3D Scroll Experience** — Cinematic hero section with golden particle canvas animation
- **GSAP + ScrollTrigger Animations** — Scroll-triggered reveals, parallax depth layers, mask reveals, counter animations
- **3D Tilt Cards** — Mouse-tracking perspective transforms on organ cards and pulse cards
- **Glassmorphism UI** — Dark theme with frosted glass panels and subtle blur effects
- **Global Pulse Dashboard** — Latest activity cards with organ-colored glow effects (GA=blue, SC=red, ECOSOC=teal, SEC=purple)
- **6 Organ Pages** — Dedicated pages for each UN principal organ with unique content and stats
- **ICJ Spotlight** — Featured section for International Court of Justice cases
- **Lenis Smooth Scrolling** — Buttery-smooth scroll behavior across the entire site
- **Responsive Design** — Mobile hamburger menu, fluid typography, and adaptive layouts

### Backend & Database
- **6 UN Organs**: General Assembly, Security Council, ECOSOC, ICJ, Secretariat, Trusteeship Council
- **Matter Workflow**: Draft → Review → Approval → Voting → Resolution
- **Voting System**: Yes/No/Abstain with threshold validation
- **ICJ Cases**: Cases, hearings, judgments
- **Secretariat**: Directives, departments, officers
- **Audit Trail**: Complete action logging

---

## Technologies

| Layer | Stack |
|---|---|
| **Database** | MySQL 8.0 |
| **Backend** | Node.js, Express, mysql2 |
| **Frontend** | HTML5, CSS3, Vanilla JavaScript |
| **Animations** | GSAP 3.12 + ScrollTrigger |
| **Smooth Scroll** | Lenis |
| **Typography** | Playfair Display, Inter, JetBrains Mono (Google Fonts) |
| **Design** | Dark theme, glassmorphism, 3D transforms, parallax |

---

## Design Highlights

- **Color Palette**: Deep navy backgrounds (`#0a0e17`) with gold accents (`#c9a84c`) and organ-specific colors
- **Typography**: Playfair Display for headings (serif elegance), Inter for body (clean readability), JetBrains Mono for labels
- **3D Effects**: CSS `transform-style: preserve-3d` with GSAP-driven mouse-tracking tilt
- **Particles**: Custom HTML5 Canvas particle system with connecting lines on the hero section
- **Organ Colors**: Blue (GA), Red (SC), Teal (ECOSOC), Gold (ICJ), Purple (Secretariat), Green (Trusteeship)
