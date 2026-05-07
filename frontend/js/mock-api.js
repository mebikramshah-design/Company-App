// Browser-only mock backend. Persists data in localStorage so the app
// is fully interactive without a real server. Used when DEMO_MODE = true.

(function () {
  const KEY_USERS = 'demo_users';
  const KEY_OTPS = 'demo_otps';
  const KEY_TOKENS = 'demo_tokens';

  const load = (k, def) => {
    try { return JSON.parse(localStorage.getItem(k)) ?? def; } catch { return def; }
  };
  const save = (k, v) => localStorage.setItem(k, JSON.stringify(v));

  const wait = (ms) => new Promise((r) => setTimeout(r, ms));
  const uid = () => Math.random().toString(36).slice(2) + Date.now().toString(36);
  const now = () => Date.now();

  function getUsers() { return load(KEY_USERS, []); }
  function setUsers(list) { save(KEY_USERS, list); }
  function getOtps() { return load(KEY_OTPS, {}); }
  function setOtps(map) { save(KEY_OTPS, map); }

  function findUser({ email, phone, id }) {
    const users = getUsers();
    if (id) return users.find((u) => u.id === id);
    if (email) return users.find((u) => u.email === email.toLowerCase());
    if (phone) return users.find((u) => u.phone === phone);
    return null;
  }

  function publicUser(u) {
    if (!u) return null;
    const { password, ...safe } = u;
    return safe;
  }

  function makeTokens(user) {
    const accessToken = 'demo.' + uid();
    const refreshToken = 'demo.' + uid();
    const tokens = load(KEY_TOKENS, {});
    tokens[accessToken] = { userId: user.id, exp: now() + 24 * 60 * 60 * 1000 };
    tokens[refreshToken] = { userId: user.id, exp: now() + 7 * 24 * 60 * 60 * 1000 };
    save(KEY_TOKENS, tokens);
    return { accessToken, refreshToken };
  }

  function userByToken(token) {
    if (!token) return null;
    const tokens = load(KEY_TOKENS, {});
    const t = tokens[token];
    if (!t || t.exp < now()) return null;
    return findUser({ id: t.userId });
  }

  function genCode() {
    return String(Math.floor(100000 + Math.random() * 900000));
  }

  function showDemoOtp(channel, target, code) {
    const banner = document.getElementById('demo-otp-banner') || (() => {
      const el = document.createElement('div');
      el.id = 'demo-otp-banner';
      el.style.cssText = 'position:fixed;bottom:16px;left:50%;transform:translateX(-50%);background:#1B3A5B;color:#C5A84C;padding:14px 22px;border-radius:10px;font-family:Poppins,sans-serif;font-size:15px;font-weight:600;box-shadow:0 8px 24px rgba(0,0,0,.2);z-index:9999;max-width:90vw;text-align:center;';
      document.body.appendChild(el);
      return el;
    })();
    banner.innerHTML = `Demo ${channel.toUpperCase()} to <span style="color:#fff">${target}</span> &nbsp;·&nbsp; Code: <span style="background:#fff;color:#1B3A5B;padding:2px 10px;border-radius:6px;letter-spacing:3px;">${code}</span>`;
    setTimeout(() => banner.remove(), 30000);
  }

  function ok(message, data) { return { success: true, message, data }; }
  function err(status, message) { const e = new Error(message); e.status = status; throw e; }

  const Mock = {
    async signupEmail({ name, email, password }) {
      await wait(300);
      if (!name || !email || !password) err(400, 'All fields required');
      if (password.length < 8) err(400, 'Password must be at least 8 characters');
      email = email.toLowerCase();
      if (findUser({ email })) err(409, 'Email already registered');
      const token = uid() + uid();
      const user = {
        id: uid(), name, email, password, phone: null, role: 'user',
        isEmailVerified: false, isPhoneVerified: false, isActive: true,
        emailVerificationToken: token,
        createdAt: new Date().toISOString(),
      };
      const users = getUsers(); users.push(user); setUsers(users);
      const link = `${location.pathname.replace(/[^/]*$/, '')}verify-email.html?token=${token}&email=${encodeURIComponent(email)}`;
      showDemoOtp('email-link', email, 'check banner →');
      // Show clickable verification link
      setTimeout(() => {
        const banner = document.getElementById('demo-otp-banner');
        if (banner) {
          banner.innerHTML = `Demo verification email sent to <strong style="color:#fff">${email}</strong><br><a href="${link}" style="color:#C5A84C;text-decoration:underline;">Click to verify your email</a>`;
        }
      }, 50);
      return ok('Account created. Check the demo banner to verify.', { userId: user.id, email });
    },

    async verifyEmail(token) {
      await wait(200);
      const users = getUsers();
      const u = users.find((x) => x.emailVerificationToken === token);
      if (!u) err(400, 'Invalid or expired verification link');
      u.isEmailVerified = true;
      u.emailVerificationToken = null;
      setUsers(users);
      const tokens = makeTokens(u);
      return ok('Email verified', { user: publicUser(u), ...tokens });
    },

    async resendVerification(email) {
      await wait(200);
      email = email.toLowerCase();
      const users = getUsers();
      const u = users.find((x) => x.email === email);
      if (!u) err(404, 'No account with that email');
      if (u.isEmailVerified) err(400, 'Email already verified');
      u.emailVerificationToken = uid() + uid();
      setUsers(users);
      const link = `${location.pathname.replace(/[^/]*$/, '')}verify-email.html?token=${u.emailVerificationToken}&email=${encodeURIComponent(email)}`;
      showDemoOtp('email-link', email, '');
      setTimeout(() => {
        const banner = document.getElementById('demo-otp-banner');
        if (banner) banner.innerHTML = `New verification link for <strong style="color:#fff">${email}</strong>:<br><a href="${link}" style="color:#C5A84C;text-decoration:underline;">Click to verify</a>`;
      }, 50);
      return ok('Verification email sent');
    },

    async signupPhone({ name, phone }) {
      await wait(300);
      if (!name || !phone) err(400, 'All fields required');
      if (!/^\+[1-9]\d{6,14}$/.test(phone)) err(400, 'Phone must be E.164 format like +14155551234');
      let users = getUsers();
      let u = users.find((x) => x.phone === phone);
      if (u && u.isPhoneVerified) err(409, 'Phone already registered');
      if (!u) {
        u = {
          id: uid(), name, phone, email: null, password: null, role: 'user',
          isEmailVerified: false, isPhoneVerified: false, isActive: true,
          createdAt: new Date().toISOString(),
        };
        users.push(u); setUsers(users);
      }
      const code = genCode();
      const otps = getOtps();
      otps[`signup:${phone}`] = { code, exp: now() + 5 * 60 * 1000 };
      setOtps(otps);
      showDemoOtp('sms', phone, code);
      return ok('OTP sent (demo). Code shown in banner.', { userId: u.id, phone });
    },

    async verifyPhone({ phone, code }) {
      await wait(200);
      const otps = getOtps();
      const rec = otps[`signup:${phone}`];
      if (!rec) err(400, 'No active code');
      if (rec.exp < now()) err(400, 'Code expired');
      if (rec.code !== code) err(400, 'Invalid verification code');
      delete otps[`signup:${phone}`]; setOtps(otps);
      const users = getUsers();
      const u = users.find((x) => x.phone === phone);
      if (!u) err(404, 'User not found');
      u.isPhoneVerified = true;
      setUsers(users);
      const tokens = makeTokens(u);
      return ok('Phone verified', { user: publicUser(u), ...tokens });
    },

    async loginEmail({ email, password }) {
      await wait(300);
      email = (email || '').toLowerCase();
      const u = findUser({ email });
      if (!u || u.password !== password) err(401, 'Invalid credentials');
      if (!u.isEmailVerified) err(403, 'Please verify your email before logging in');
      const tokens = makeTokens(u);
      return ok('Login successful', { user: publicUser(u), ...tokens });
    },

    async requestPhoneOtp(phone) {
      await wait(300);
      const u = findUser({ phone });
      if (!u) err(404, 'No account with that phone');
      const code = genCode();
      const otps = getOtps();
      otps[`login:${phone}`] = { code, exp: now() + 5 * 60 * 1000 };
      setOtps(otps);
      showDemoOtp('sms', phone, code);
      return ok('OTP sent (demo). Code shown in banner.', {});
    },

    async loginPhone({ phone, code }) {
      await wait(200);
      const otps = getOtps();
      const rec = otps[`login:${phone}`];
      if (!rec) err(400, 'No active code');
      if (rec.exp < now()) err(400, 'Code expired');
      if (rec.code !== code) err(400, 'Invalid verification code');
      delete otps[`login:${phone}`]; setOtps(otps);
      const u = findUser({ phone });
      const tokens = makeTokens(u);
      return ok('Login successful', { user: publicUser(u), ...tokens });
    },

    async forgotPassword(email) {
      await wait(300);
      email = (email || '').toLowerCase();
      const users = getUsers();
      const u = users.find((x) => x.email === email);
      if (u) {
        u.passwordResetToken = uid() + uid();
        u.passwordResetExpires = now() + 60 * 60 * 1000;
        setUsers(users);
        const link = `${location.pathname.replace(/[^/]*$/, '')}reset-password.html?token=${u.passwordResetToken}&email=${encodeURIComponent(email)}`;
        showDemoOtp('email-link', email, '');
        setTimeout(() => {
          const banner = document.getElementById('demo-otp-banner');
          if (banner) banner.innerHTML = `Demo reset link for <strong style="color:#fff">${email}</strong>:<br><a href="${link}" style="color:#C5A84C;text-decoration:underline;">Click to reset password</a>`;
        }, 50);
      }
      return ok('If that email is registered, a reset link has been sent.');
    },

    async resetPassword({ token, password }) {
      await wait(200);
      const users = getUsers();
      const u = users.find((x) => x.passwordResetToken === token && x.passwordResetExpires > now());
      if (!u) err(400, 'Invalid or expired reset token');
      u.password = password;
      u.passwordResetToken = null;
      u.passwordResetExpires = null;
      setUsers(users);
      const tokens = makeTokens(u);
      return ok('Password reset successful', { user: publicUser(u), ...tokens });
    },

    async me(token) {
      await wait(100);
      const u = userByToken(token);
      if (!u) err(401, 'Authentication required');
      return ok('OK', { user: publicUser(u) });
    },

    async logout() {
      await wait(50);
      return ok('Logged out');
    },
  };

  window.MOCK_API = Mock;
})();
