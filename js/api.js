(function () {
  const API_BASE = window.API_BASE || 'http://localhost:5000/api';
  const TOKEN_KEY = 'access_token';
  const REFRESH_KEY = 'refresh_token';
  const useMock = () => !!window.DEMO_MODE && window.MOCK_API;

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

    const res = await fetch(`${API_BASE}${path}`, opts);
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

  function wrap(realFn, mockFn) {
    return (...args) => (useMock() ? mockFn(...args) : realFn(...args));
  }

  window.API = {
    base: API_BASE,
    setTokens, clearTokens, getAccessToken, getRefreshToken,
    isDemo: () => !!window.DEMO_MODE,

    signupEmail: wrap(
      (p) => request('/auth/signup/email', { method: 'POST', body: p }),
      (p) => MOCK_API.signupEmail(p)
    ),
    signupPhone: wrap(
      (p) => request('/auth/signup/phone', { method: 'POST', body: p }),
      (p) => MOCK_API.signupPhone(p)
    ),
    verifyPhone: wrap(
      (p) => request('/auth/verify/phone', { method: 'POST', body: p }),
      (p) => MOCK_API.verifyPhone(p)
    ),
    verifyEmail: wrap(
      (token) => request('/auth/verify/email', { method: 'POST', body: { token } }),
      (token) => MOCK_API.verifyEmail(token)
    ),
    resendVerification: wrap(
      (email) => request('/auth/verify/email/resend', { method: 'POST', body: { email } }),
      (email) => MOCK_API.resendVerification(email)
    ),
    loginEmail: wrap(
      (p) => request('/auth/login/email', { method: 'POST', body: p }),
      (p) => MOCK_API.loginEmail(p)
    ),
    requestPhoneOtp: wrap(
      (phone) => request('/auth/login/phone/request', { method: 'POST', body: { phone } }),
      (phone) => MOCK_API.requestPhoneOtp(phone)
    ),
    loginPhone: wrap(
      (p) => request('/auth/login/phone/verify', { method: 'POST', body: p }),
      (p) => MOCK_API.loginPhone(p)
    ),
    forgotPassword: wrap(
      (email) => request('/auth/forgot-password', { method: 'POST', body: { email } }),
      (email) => MOCK_API.forgotPassword(email)
    ),
    resetPassword: wrap(
      (p) => request('/auth/reset-password', { method: 'POST', body: p }),
      (p) => MOCK_API.resetPassword(p)
    ),
    logout: wrap(
      () => request('/auth/logout', { method: 'POST' }),
      () => MOCK_API.logout()
    ),
    me: wrap(
      () => request('/auth/me', { auth: true }),
      () => MOCK_API.me(getAccessToken())
    ),
  };
})();
