// API Module - Backend communication layer
const API = {
    baseUrl: '/api',
    async request(endpoint, options = {}) {
        const response = await fetch(`${this.baseUrl}${endpoint}`, {
            headers: { 'Content-Type': 'application/json', ...options.headers },
            ...options
        });
        if (!response.ok) {
            const error = await response.json().catch(() => ({ error: 'Request failed' }));
            throw new Error(error.error || 'Request failed');
        }
        return await response.json();
    },
    get(endpoint) { return this.request(endpoint); },
    post(endpoint, data) { return this.request(endpoint, { method: 'POST', body: JSON.stringify(data) }); },
    put(endpoint, data) { return this.request(endpoint, { method: 'PUT', body: JSON.stringify(data) }); },
    dashboard: {
        getStats: () => API.get('/dashboard/stats'),
        getActivity: () => API.get('/dashboard/activity'),
        getMattersByOrgan: () => API.get('/dashboard/matters-by-organ'),
        getPending: () => API.get('/dashboard/pending')
    },
    organs: {
        getAll: () => API.get('/organs'),
        getById: (id) => API.get(`/organs/${id}`),
        getStats: (id) => API.get(`/organs/${id}/stats`)
    },
    matters: {
        getAll: (params = {}) => { const q = new URLSearchParams(params).toString(); return API.get(`/matters${q ? '?' + q : ''}`); },
        getById: (id) => API.get(`/matters/${id}`),
        create: (data) => API.post('/matters', data),
        getTimeline: (id) => API.get(`/matters/${id}/timeline`)
    },
    voting: {
        getMatterVotes: (id) => API.get(`/voting/matter/${id}`),
        castVote: (data) => API.post('/voting', data),
        computeOutcome: (id, data) => API.post(`/voting/matter/${id}/compute`, data)
    },
    resolutions: {
        getAll: (params = {}) => { const q = new URLSearchParams(params).toString(); return API.get(`/resolutions${q ? '?' + q : ''}`); },
        getById: (id) => API.get(`/resolutions/${id}`)
    },
    icj: {
        getCases: () => API.get('/icj/cases'),
        getCaseById: (id) => API.get(`/icj/cases/${id}`),
        getJudges: () => API.get('/icj/judges')
    },
    secretariat: {
        getDirectives: () => API.get('/secretariat/directives'),
        getDepartments: () => API.get('/secretariat/departments'),
        getOfficers: () => API.get('/secretariat/officers')
    },
    trusteeship: {
        getTerritories: () => API.get('/trusteeship/territories'),
        getReports: () => API.get('/trusteeship/reports'),
        getStats: () => API.get('/trusteeship/stats')
    },
    audit: {
        getLogs: (params = {}) => { const q = new URLSearchParams(params).toString(); return API.get(`/audit${q ? '?' + q : ''}`); },
        getStats: () => API.get('/audit/stats')
    }
};
window.API = API;
