(function () {
  const API_BASE = window.API_BASE || 'http://localhost:5000/api';
  const TOKEN_KEY = 'access_token';
  const REFRESH_KEY = 'refresh_token';

  function setTokens({ accessToken, refreshToken }) {
    if (accessToken) localStorage.setItem(TOKEN_KEY, accessToken);
    if (refreshToken) localStorage.setItem(REFRESH_KEY, refreshToken);
  }
  function clearTokens() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(REFRESH_KEY);
  }
  function getAccessToken() { return localStorage.getItem(TOKEN_KEY); }
  function getRefreshToken() { return localStorage.getItem(REFRESH_KEY); }

  async function request(path, { method = 'GET', body, auth = false, headers = {} } = {}) {
    const opts = {
      method,
      credentials: 'include',
      headers: { 'Content-Type': 'application/json', ...headers },
    };
    if (auth) {
      const t = getAccessToken();
      if (t) opts.headers.Authorization = `Bearer ${t}`;
    }
    if (body !== undefined) opts.body = JSON.stringify(body);

    let res = await fetch(`${API_BASE}${path}`, opts);
    if (res.status === 401 && auth) {
      const refreshed = await tryRefresh();
      if (refreshed) {
        opts.headers.Authorization = `Bearer ${getAccessToken()}`;
        res = await fetch(`${API_BASE}${path}`, opts);
      }
    }
    let data = {};
    try { data = await res.json(); } catch (_) {}
    if (!res.ok) {
      const err = new Error(data.message || `Request failed (${res.status})`);
      err.status = res.status;
      err.details = data.details;
      throw err;
    }
    return data;
  }

  async function tryRefresh() {
    try {
      const refreshToken = getRefreshToken();
      const res = await fetch(`${API_BASE}/auth/refresh`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });
      if (!res.ok) return false;
      const data = await res.json();
      if (data.data) setTokens(data.data);
      return true;
    } catch { return false; }
  }

  window.API = {
    base: API_BASE,
    setTokens, clearTokens, getAccessToken, getRefreshToken,

    signupEmail: (payload) => request('/auth/signup/email', { method: 'POST', body: payload }),
    signupPhone: (payload) => request('/auth/signup/phone', { method: 'POST', body: payload }),
    verifyPhone: (payload) => request('/auth/verify/phone', { method: 'POST', body: payload }),
    verifyEmail: (token) => request('/auth/verify/email', { method: 'POST', body: { token } }),
    resendVerification: (email) => request('/auth/verify/email/resend', { method: 'POST', body: { email } }),
    loginEmail: (payload) => request('/auth/login/email', { method: 'POST', body: payload }),
    requestPhoneOtp: (phone) => request('/auth/login/phone/request', { method: 'POST', body: { phone } }),
    loginPhone: (payload) => request('/auth/login/phone/verify', { method: 'POST', body: payload }),
    forgotPassword: (email) => request('/auth/forgot-password', { method: 'POST', body: { email } }),
    resetPassword: (payload) => request('/auth/reset-password', { method: 'POST', body: payload }),
    logout: () => request('/auth/logout', { method: 'POST' }),
    me: () => request('/auth/me', { auth: true }),
  };
})();
