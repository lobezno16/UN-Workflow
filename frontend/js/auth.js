/* ============================================================================
   AUTH.JS — Client-side JWT authentication helper
   ============================================================================ */

const API_BASE = '/api';

const Auth = {
    // ─── Storage ────────────────────────────────────────────────────────────
    getToken() { return localStorage.getItem('un_token'); },
    getProfile() {
        try { return JSON.parse(localStorage.getItem('un_profile')); }
        catch { return null; }
    },
    setSession(token, profile) {
        localStorage.setItem('un_token', token);
        localStorage.setItem('un_profile', JSON.stringify(profile));
    },
    clearSession() {
        localStorage.removeItem('un_token');
        localStorage.removeItem('un_profile');
    },
    isLoggedIn() { return !!this.getToken(); },
    isAdmin()    { return this.getProfile()?.role === 'admin'; },
    isDelegate() { return this.getProfile()?.role === 'delegate'; },

    // ─── Auth header for fetch ───────────────────────────────────────────────
    headers() {
        return {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.getToken()}`
        };
    },

    // ─── Login ────────────────────────────────────────────────────────────────
    async login(username, password) {
        const res = await fetch(`${API_BASE}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Login failed');
        this.setSession(data.token, data.profile);
        return data.profile;
    },

    // ─── Logout ───────────────────────────────────────────────────────────────
    logout() {
        this.clearSession();
        window.location.href = '/login.html';
    },

    // ─── Route guards ────────────────────────────────────────────────────────
    requireAuth(role) {
        if (!this.isLoggedIn()) {
            window.location.href = '/login.html';
            return false;
        }
        if (role === 'admin' && !this.isAdmin()) {
            window.location.href = '/login.html';
            return false;
        }
        if (role === 'delegate' && !this.isDelegate()) {
            window.location.href = '/login.html';
            return false;
        }
        return true;
    },

    // ─── Authenticated fetch ──────────────────────────────────────────────────
    async fetch(url, options = {}) {
        const res = await fetch(url, {
            ...options,
            headers: { ...this.headers(), ...(options.headers || {}) }
        });
        if (res.status === 401) { this.logout(); return; }
        return res;
    }
};
