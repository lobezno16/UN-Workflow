// Main Application - UN Workflow Management System
const App = {
    currentPage: 'dashboard',
    init() {
        this.bindEvents();
        this.handleRoute();
        window.addEventListener('hashchange', () => this.handleRoute());
    },
    bindEvents() {
        document.getElementById('sidebar-toggle').addEventListener('click', () => {
            document.getElementById('sidebar').classList.toggle('collapsed');
        });
        document.getElementById('modal-close').addEventListener('click', () => this.closeModal());
        document.getElementById('modal-overlay').addEventListener('click', (e) => {
            if (e.target.id === 'modal-overlay') this.closeModal();
        });
    },
    handleRoute() {
        const hash = window.location.hash.slice(1) || 'dashboard';
        this.navigateTo(hash);
    },
    navigateTo(page) {
        this.currentPage = page;
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.toggle('active', link.dataset.page === page);
        });
        const titles = { dashboard: 'Dashboard', organs: 'UN Organs', matters: 'Matters', voting: 'Voting', resolutions: 'Resolutions', icj: 'ICJ Cases', secretariat: 'Secretariat', trusteeship: 'Trusteeship', audit: 'Audit Log' };
        document.getElementById('page-title').textContent = titles[page] || page;
        document.getElementById('breadcrumb').textContent = `Home / ${titles[page] || page}`;
        this.loadPage(page);
    },
    async loadPage(page) {
        const content = document.getElementById('content-area');
        content.innerHTML = '<div class="loading-spinner"><div class="spinner"></div><span>Loading...</span></div>';
        try {
            const pages = { dashboard: this.renderDashboard, organs: this.renderOrgans, matters: this.renderMatters, voting: this.renderVoting, resolutions: this.renderResolutions, icj: this.renderICJ, secretariat: this.renderSecretariat, trusteeship: this.renderTrusteeship, audit: this.renderAudit };
            if (pages[page]) await pages[page].call(this);
            else content.innerHTML = '<div class="empty-state"><div class="empty-icon">🚧</div><h3>Page Not Found</h3></div>';
        } catch (error) {
            content.innerHTML = `<div class="empty-state"><div class="empty-icon">❌</div><h3>Error Loading Page</h3><p>${error.message}</p></div>`;
        }
    },
    async renderDashboard() {
        const [stats, activity, mattersByOrgan, pending] = await Promise.all([API.dashboard.getStats(), API.dashboard.getActivity(), API.dashboard.getMattersByOrgan(), API.dashboard.getPending()]);
        document.getElementById('content-area').innerHTML = `
            <div class="stats-grid">
                <div class="stat-card"><div class="stat-icon">📋</div><div class="stat-content"><div class="stat-value">${stats.total_matters || 0}</div><div class="stat-label">Total Matters</div></div></div>
                <div class="stat-card"><div class="stat-icon">⏳</div><div class="stat-content"><div class="stat-value">${stats.pending_matters || 0}</div><div class="stat-label">Pending Matters</div></div></div>
                <div class="stat-card"><div class="stat-icon">📜</div><div class="stat-content"><div class="stat-value">${stats.total_resolutions || 0}</div><div class="stat-label">Resolutions</div></div></div>
                <div class="stat-card"><div class="stat-icon">⚖️</div><div class="stat-content"><div class="stat-value">${stats.active_icj_cases || 0}</div><div class="stat-label">Active ICJ Cases</div></div></div>
                <div class="stat-card"><div class="stat-icon">📑</div><div class="stat-content"><div class="stat-value">${stats.active_directives || 0}</div><div class="stat-label">Active Directives</div></div></div>
                <div class="stat-card"><div class="stat-icon">👥</div><div class="stat-content"><div class="stat-value">${stats.active_officers || 0}</div><div class="stat-label">Officers</div></div></div>
            </div>
            <div class="dashboard-grid">
                <div class="card col-8"><div class="card-header"><h3 class="card-title">Matters by Organ</h3></div><div class="data-table-container"><table class="data-table"><thead><tr><th>Organ</th><th>Total</th><th>Passed</th><th>Voting</th><th>Processing</th></tr></thead><tbody>${mattersByOrgan.map(o => `<tr><td><span class="badge badge-primary">${o.organ_code}</span> ${o.organ_name}</td><td>${o.total}</td><td class="text-success">${o.passed}</td><td class="text-warning">${o.in_voting}</td><td>${o.processing}</td></tr>`).join('')}</tbody></table></div></div>
                <div class="card col-4"><div class="card-header"><h3 class="card-title">Recent Activity</h3></div><ul class="activity-feed">${activity.slice(0, 8).map(a => `<li class="activity-item"><div class="activity-icon">${this.getActionIcon(a.action_type)}</div><div class="activity-content"><div class="activity-text"><strong>${a.performed_by}</strong> ${a.action_description || a.action_type}</div><div class="activity-time">${this.formatDate(a.action_timestamp)}</div></div></li>`).join('')}</ul></div>
                <div class="card col-6"><div class="card-header"><h3 class="card-title">Pending Approvals</h3></div>${pending.pendingApprovals?.length ? `<div class="data-table-container"><table class="data-table"><thead><tr><th>Matter</th><th>Organ</th><th>Level</th><th>Approver</th></tr></thead><tbody>${pending.pendingApprovals.map(a => `<tr><td>${a.matter_number}</td><td><span class="badge badge-primary">${a.organ_code}</span></td><td>Level ${a.approval_level}</td><td>${a.approver_name}</td></tr>`).join('')}</tbody></table></div>` : '<div class="empty-state"><p>No pending approvals</p></div>'}</div>
                <div class="card col-6"><div class="card-header"><h3 class="card-title">Matters in Voting</h3></div>${pending.mattersInVoting?.length ? `<div class="data-table-container"><table class="data-table"><thead><tr><th>Matter</th><th>Title</th><th>Votes</th></tr></thead><tbody>${pending.mattersInVoting.map(m => `<tr><td><span class="badge badge-warning">${m.organ_code}</span> ${m.matter_number}</td><td>${m.title.substring(0, 40)}...</td><td>${m.votes_cast} cast</td></tr>`).join('')}</tbody></table></div>` : '<div class="empty-state"><p>No matters in voting</p></div>'}</div>
            </div>`;
    },
    async renderOrgans() {
        const organs = await API.organs.getAll();
        const icons = { GA: '🌐', SC: '🛡️', ECOSOC: '📊', ICJ: '⚖️', SEC: '🏢', TC: '🗺️' };
        document.getElementById('content-area').innerHTML = `<div class="organ-grid">${organs.map(o => `<div class="organ-card" onclick="App.showOrganDetail(${o.organ_id})"><div class="organ-header"><div class="organ-icon">${icons[o.organ_code] || '🏛️'}</div><div><div class="organ-name">${o.organ_name}</div><div class="organ-code">${o.organ_code}</div></div></div><p>${o.description || 'No description available'}</p><div class="organ-stats"><div class="organ-stat"><div class="organ-stat-value">${o.matter_count || 0}</div><div class="organ-stat-label">Matters</div></div><div class="organ-stat"><div class="organ-stat-value">${o.officer_count || 0}</div><div class="organ-stat-label">Officers</div></div><div class="organ-stat"><div class="organ-stat-value">${o.established_year || 1945}</div><div class="organ-stat-label">Est.</div></div></div></div>`).join('')}</div>`;
    },
    async renderMatters() {
        const [matters, organs] = await Promise.all([API.matters.getAll(), API.organs.getAll()]);
        document.getElementById('content-area').innerHTML = `<div class="filters-bar"><select class="form-control" id="filter-organ" onchange="App.filterMatters()"><option value="">All Organs</option>${organs.map(o => `<option value="${o.organ_code}">${o.organ_name}</option>`).join('')}</select><select class="form-control" id="filter-status" onchange="App.filterMatters()"><option value="">All Statuses</option><option value="DRAFT">Draft</option><option value="SUBMITTED">Submitted</option><option value="UNDER_REVIEW">Under Review</option><option value="PENDING_APPROVAL">Pending Approval</option><option value="IN_VOTING">In Voting</option><option value="PASSED">Passed</option><option value="REJECTED">Rejected</option></select><button class="btn btn-primary" onclick="App.showCreateMatterModal()">+ New Matter</button></div><div class="data-table-container"><table class="data-table"><thead><tr><th>Number</th><th>Title</th><th>Organ</th><th>Type</th><th>Status</th><th>Submitted</th><th>Actions</th></tr></thead><tbody id="matters-tbody">${matters.map(m => this.renderMatterRow(m)).join('')}</tbody></table></div>`;
    },
    renderMatterRow(m) {
        const statusBadge = { DRAFT: 'badge-muted', SUBMITTED: 'badge-info', UNDER_REVIEW: 'badge-info', PENDING_APPROVAL: 'badge-warning', IN_VOTING: 'badge-warning', PASSED: 'badge-success', REJECTED: 'badge-danger' };
        return `<tr><td><strong>${m.matter_number}</strong></td><td>${m.title.substring(0, 50)}${m.title.length > 50 ? '...' : ''}</td><td><span class="badge badge-primary">${m.organ_code}</span></td><td>${m.matter_type}</td><td><span class="badge ${statusBadge[m.status] || 'badge-muted'}">${m.status}</span></td><td>${this.formatDate(m.submission_date)}</td><td><button class="btn btn-sm btn-secondary" onclick="App.showMatterDetail(${m.matter_id})">View</button></td></tr>`;
    },
    async renderVoting() {
        const matters = await API.matters.getAll({ status: 'IN_VOTING' });
        document.getElementById('content-area').innerHTML = matters.length ? `<div class="stats-grid">${matters.map(m => `<div class="stat-card" onclick="App.showVotingDetail(${m.matter_id})" style="cursor:pointer"><div class="stat-icon">🗳️</div><div class="stat-content"><div class="stat-value">${m.matter_number}</div><div class="stat-label">${m.title.substring(0, 30)}...</div><div class="stat-change"><span class="badge badge-primary">${m.organ_code}</span> ${m.vote_count || 0} votes cast</div></div></div>`).join('')}</div><h3 style="margin:24px 0 16px">All Voting Matters</h3><div class="data-table-container"><table class="data-table"><thead><tr><th>Matter</th><th>Title</th><th>Organ</th><th>Votes</th><th>Actions</th></tr></thead><tbody>${matters.map(m => `<tr><td>${m.matter_number}</td><td>${m.title}</td><td><span class="badge badge-primary">${m.organ_code}</span></td><td>${m.vote_count || 0}</td><td><button class="btn btn-sm btn-primary" onclick="App.showVotingDetail(${m.matter_id})">Vote Details</button></td></tr>`).join('')}</tbody></table></div>` : '<div class="empty-state"><div class="empty-icon">🗳️</div><h3>No Matters in Voting</h3><p>There are currently no matters in the voting stage.</p></div>';
    },
    async renderResolutions() {
        const resolutions = await API.resolutions.getAll();
        document.getElementById('content-area').innerHTML = `<div class="filters-bar"><select class="form-control" id="filter-res-organ"><option value="">All Organs</option><option value="GA">General Assembly</option><option value="SC">Security Council</option><option value="ECOSOC">ECOSOC</option></select><button class="btn btn-secondary">Export List</button></div><div class="data-table-container"><table class="data-table"><thead><tr><th>Number</th><th>Title</th><th>Organ</th><th>Adopted</th><th>Votes</th><th>Status</th></tr></thead><tbody>${resolutions.map(r => `<tr><td><strong>${r.resolution_number}</strong></td><td>${r.title}</td><td><span class="badge badge-primary">${r.organ_code}</span></td><td>${this.formatDate(r.adoption_date)}</td><td>Y:${r.yes_votes} N:${r.no_votes} A:${r.abstentions}</td><td><span class="badge ${r.status === 'IN_FORCE' ? 'badge-success' : 'badge-muted'}">${r.status}</span></td></tr>`).join('')}</tbody></table></div>`;
    },
    async renderICJ() {
        const cases = await API.icj.getCases();
        document.getElementById('content-area').innerHTML = `<div class="filters-bar"><button class="btn btn-primary" onclick="App.showCreateCaseModal()">+ New Case</button></div><div class="data-table-container"><table class="data-table"><thead><tr><th>Number</th><th>Title</th><th>Type</th><th>Parties</th><th>Status</th><th>Filed</th></tr></thead><tbody>${cases.map(c => `<tr><td><strong>${c.case_number}</strong></td><td>${c.case_title}</td><td>${c.case_type}</td><td>${c.applicant_name || c.requesting_organ_name || 'N/A'} ${c.respondent_name ? 'v. ' + c.respondent_name : ''}</td><td><span class="badge ${c.status === 'JUDGMENT_ISSUED' ? 'badge-success' : 'badge-warning'}">${c.status}</span></td><td>${this.formatDate(c.filing_date)}</td></tr>`).join('')}</tbody></table></div>`;
    },
    async renderSecretariat() {
        const [directives, departments] = await Promise.all([API.secretariat.getDirectives(), API.secretariat.getDepartments()]);
        document.getElementById('content-area').innerHTML = `<div class="filters-bar"><select class="form-control" id="filter-dir-type"><option value="">All Types</option><option value="POLICY">Policy</option><option value="CIRCULAR">Circular</option><option value="BULLETIN">Bulletin</option></select><button class="btn btn-primary">+ New Directive</button></div><div class="dashboard-grid"><div class="card col-8"><div class="card-header"><h3 class="card-title">Directives</h3></div><div class="data-table-container"><table class="data-table"><thead><tr><th>Number</th><th>Title</th><th>Type</th><th>Department</th><th>Status</th></tr></thead><tbody>${directives.map(d => `<tr><td>${d.directive_number}</td><td>${d.title}</td><td>${d.directive_type}</td><td>${d.issuing_department}</td><td><span class="badge ${d.status === 'IN_EFFECT' ? 'badge-success' : 'badge-muted'}">${d.status}</span></td></tr>`).join('')}</tbody></table></div></div><div class="card col-4"><div class="card-header"><h3 class="card-title">Departments</h3></div><ul class="activity-feed">${departments.map(d => `<li class="activity-item"><div class="activity-icon">🏢</div><div class="activity-content"><div class="activity-text"><strong>${d.department_name}</strong></div><div class="activity-time">${d.officer_count || 0} officers</div></div></li>`).join('')}</ul></div></div>`;
    },
    async renderTrusteeship() {
        const [territories, stats] = await Promise.all([API.trusteeship.getTerritories(), API.trusteeship.getStats()]);
        document.getElementById('content-area').innerHTML = `<div class="stats-grid"><div class="stat-card"><div class="stat-icon">🗺️</div><div class="stat-content"><div class="stat-value">${stats.total_territories || 0}</div><div class="stat-label">Territories</div></div></div><div class="stat-card"><div class="stat-icon">🏴</div><div class="stat-content"><div class="stat-value">${stats.independent || 0}</div><div class="stat-label">Independent</div></div></div><div class="stat-card"><div class="stat-icon">📑</div><div class="stat-content"><div class="stat-value">${stats.total_reports || 0}</div><div class="stat-label">Reports</div></div></div></div><div class="data-table-container"><table class="data-table"><thead><tr><th>Territory</th><th>Administering Authority</th><th>Status</th><th>Reports</th></tr></thead><tbody>${territories.map(t => `<tr><td><strong>${t.territory_name}</strong></td><td>${t.administering_authority}</td><td><span class="badge ${t.current_status === 'INDEPENDENT' ? 'badge-success' : 'badge-warning'}">${t.current_status}</span></td><td>${t.report_count || 0}</td></tr>`).join('')}</tbody></table></div>`;
    },
    async renderAudit() {
        const logs = await API.audit.getLogs({ limit: 50 });
        document.getElementById('content-area').innerHTML = `<div class="filters-bar"><input type="date" class="form-control" id="filter-date-from" placeholder="From"><input type="date" class="form-control" id="filter-date-to" placeholder="To"><select class="form-control" id="filter-action"><option value="">All Actions</option><option value="INSERT">Insert</option><option value="UPDATE">Update</option><option value="DELETE">Delete</option></select></div><div class="data-table-container"><table class="data-table"><thead><tr><th>Time</th><th>Table</th><th>Action</th><th>Description</th><th>Performed By</th></tr></thead><tbody>${logs.map(l => `<tr><td>${this.formatDate(l.action_timestamp)}</td><td>${l.table_name}</td><td><span class="badge ${l.action_type === 'INSERT' ? 'badge-success' : l.action_type === 'DELETE' ? 'badge-danger' : 'badge-warning'}">${l.action_type}</span></td><td>${l.action_description || '-'}</td><td>${l.performed_by_name}</td></tr>`).join('')}</tbody></table></div>`;
    },
    showModal(title, content, footer = '') {
        document.getElementById('modal-title').textContent = title;
        document.getElementById('modal-body').innerHTML = content;
        document.getElementById('modal-footer').innerHTML = footer;
        document.getElementById('modal-overlay').classList.add('active');
    },
    closeModal() { document.getElementById('modal-overlay').classList.remove('active'); },
    async showMatterDetail(id) {
        const matter = await API.matters.getById(id);
        this.showModal(`Matter: ${matter.matter_number}`, `<div class="form-group"><label class="form-label">Title</label><p>${matter.title}</p></div><div class="form-group"><label class="form-label">Description</label><p>${matter.description}</p></div><div class="form-group"><label class="form-label">Status</label><span class="badge badge-primary">${matter.status}</span></div><div class="form-group"><label class="form-label">Organ</label><p>${matter.organ_name}</p></div><h4 style="margin:20px 0 10px">Workflow</h4><div class="timeline">${matter.workflow?.map(w => `<div class="timeline-item ${w.stage_status === 'COMPLETED' ? 'completed' : ''}"><div class="timeline-marker"></div><div class="timeline-content"><div class="timeline-title">${w.stage_name}</div><div class="timeline-date">${w.stage_status}</div></div></div>`).join('') || '<p>No workflow data</p>'}</div>`);
    },
    async showVotingDetail(id) {
        const data = await API.voting.getMatterVotes(id);
        this.showModal(`Voting: ${data.summary.matter_number}`, `<h3>${data.summary.title}</h3><div class="vote-summary"><div class="vote-stat yes"><div class="vote-count">${data.summary.yes_votes || 0}</div><div class="vote-label">Yes</div></div><div class="vote-stat no"><div class="vote-count">${data.summary.no_votes || 0}</div><div class="vote-label">No</div></div><div class="vote-stat abstain"><div class="vote-count">${data.summary.abstentions || 0}</div><div class="vote-label">Abstain</div></div></div><h4>Individual Votes</h4><div class="data-table-container"><table class="data-table"><thead><tr><th>State</th><th>Delegate</th><th>Vote</th></tr></thead><tbody>${data.votes.map(v => `<tr><td>${v.state_name}</td><td>${v.delegate_name}</td><td><span class="badge ${v.vote_value === 'YES' ? 'badge-success' : v.vote_value === 'NO' ? 'badge-danger' : 'badge-warning'}">${v.vote_value}</span></td></tr>`).join('')}</tbody></table></div>`);
    },
    async showOrganDetail(id) {
        const organ = await API.organs.getById(id);
        const stats = await API.organs.getStats(id);
        this.showModal(organ.organ_name, `<p>${organ.description || 'No description'}</p><div class="stats-grid" style="margin-top:20px"><div class="stat-card"><div class="stat-content"><div class="stat-value">${stats.total_matters || 0}</div><div class="stat-label">Total Matters</div></div></div><div class="stat-card"><div class="stat-content"><div class="stat-value">${stats.passed_matters || 0}</div><div class="stat-label">Passed</div></div></div><div class="stat-card"><div class="stat-content"><div class="stat-value">${stats.resolutions_issued || 0}</div><div class="stat-label">Resolutions</div></div></div></div>`);
    },
    showToast(type, title, message) {
        const icons = { success: '✅', error: '❌', warning: '⚠️', info: 'ℹ️' };
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.innerHTML = `<span class="toast-icon">${icons[type]}</span><div class="toast-content"><div class="toast-title">${title}</div><div class="toast-message">${message}</div></div>`;
        document.getElementById('toast-container').appendChild(toast);
        setTimeout(() => toast.remove(), 5000);
    },
    getActionIcon(action) { return { INSERT: '➕', UPDATE: '✏️', DELETE: '🗑️', VOTE: '🗳️', APPROVE: '✅' }[action] || '📝'; },
    formatDate(date) { if (!date) return '-'; return new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }); }
};
document.addEventListener('DOMContentLoaded', () => App.init());
