# Company App — Auth & Verification System

Production-ready full-stack authentication backend (Node.js + Express + MongoDB)
with email + password and phone + OTP flows, plus a brand-matched HTML
frontend that integrates out-of-the-box and is easy to wire into any
existing HTML prototype.

> **Note:** This repo's primary app is a Flutter project (in `lib/`).
> The auth system added here lives in `backend/` and `frontend/` and is
> independent — it can serve the Flutter app or any HTML prototype.

---

## 1. Project structure

```
.
├── backend/
│   ├── src/
│   │   ├── config/          # db connection
│   │   ├── controllers/     # auth + user controllers
│   │   ├── middleware/      # auth, validate, rateLimit, errorHandler
│   │   ├── models/          # User, Otp (Mongoose)
│   │   ├── routes/          # auth.routes, user.routes
│   │   ├── services/        # email, sms, otp, token services
│   │   ├── templates/email/ # verification, welcome, reset, otp HTML
│   │   ├── utils/           # logger, ApiError, asyncHandler
│   │   ├── app.js           # express app
│   │   └── server.js        # entry point
│   ├── .env.example
│   ├── package.json
│   ├── vercel.json | render.yaml | railway.json | Procfile
└── frontend/
    ├── index.html
    ├── signup.html · login.html
    ├── verify-email.html · verify-otp.html
    ├── forgot-password.html · reset-password.html
    ├── dashboard.html
    ├── config.js            # set API_BASE
    ├── css/style.css
    ├── js/api.js · js/ui.js
    └── netlify.toml | vercel.json
```

---

## 2. Features

- **Email + Password** signup/login with bcrypt hashing (12 rounds)
- **Phone + OTP** signup/login via Twilio SMS (5-min expiry, max 5 attempts, 60s resend cooldown)
- **Email verification** via tokenized link (24h expiry)
- **Password reset** via tokenized link (1h expiry)
- **JWT** access (15m) + refresh (7d) tokens, signed httpOnly cookies + Bearer header support
- **Brute force lockout** (5 failed logins → 15 min lock)
- **Rate limiting** per route group (global, auth, OTP issue, OTP verify)
- **Security middleware:** Helmet, CORS allow-list, mongo-sanitize, xss-clean, hpp, hpp, input validation (express-validator)
- **Pluggable SMTP**: Gmail / SendGrid / Mailgun
- **Branded responsive email templates** (navy + gold)
- **Mobile-friendly Poppins UI** matching the existing Flutter brand

---

## 3. Installation

### Prerequisites
- Node.js 18+
- MongoDB (local or Atlas)
- SMTP account (Gmail App Password, SendGrid API key, or Mailgun)
- Twilio account with a verified sender number (optional in dev — SMS is logged to console)

### Steps
```bash
cd backend
cp .env.example .env
# Edit .env with your real secrets (see section 4)
npm install
npm run dev    # starts on http://localhost:5000

# Frontend (any static server works)
cd ../frontend
# Option A: open index.html directly in browser
# Option B: serve with a static server
npx serve .   # http://localhost:3000
```

Update `frontend/config.js` to point at your backend:
```js
window.API_BASE = 'http://localhost:5000/api';
```

---

## 4. Environment variables

All keys with examples live in `backend/.env.example`. Highlights:

| Key | Purpose |
|---|---|
| `MONGO_URI` | Mongo connection string |
| `JWT_SECRET` / `JWT_REFRESH_SECRET` | Token signing keys (≥32 chars) |
| `COOKIE_SECRET` | Signed cookie secret |
| `SMTP_HOST` / `SMTP_PORT` / `SMTP_USER` / `SMTP_PASS` | Email transport |
| `EMAIL_FROM_NAME` / `EMAIL_FROM_ADDRESS` | Email sender identity |
| `TWILIO_ACCOUNT_SID` / `TWILIO_AUTH_TOKEN` / `TWILIO_PHONE_NUMBER` | SMS |
| `CLIENT_URL` | Comma-separated allowed CORS origins; also used to build verify/reset links |
| `OTP_EXPIRES_IN_MINUTES` | OTP TTL (default 5) |

### SMTP setup tips
- **Gmail:** Enable 2FA, then create an [App Password](https://myaccount.google.com/apppasswords). Use port 587, `secure=false`.
- **SendGrid:** `SMTP_USER=apikey`, `SMTP_PASS=<your SG.xxxxxx key>`, host `smtp.sendgrid.net`.
- **Mailgun:** Create an SMTP credential under Domain Settings; host `smtp.mailgun.org`.

### Twilio setup
1. Buy a phone number in the Twilio console.
2. Copy SID + Auth Token from the dashboard.
3. Recipients in trial accounts must be verified numbers — upgrade for arbitrary recipients.
4. Without Twilio credentials, OTP codes are logged to the server console (handy for local dev).

---

## 5. API documentation

Base URL: `${API_BASE}/api`

All bodies are JSON. All responses follow:
```json
{ "success": true|false, "message": "...", "data": { ... } }
```

### Auth

| Method | Path | Body | Description |
|---|---|---|---|
| POST | `/auth/signup/email` | `{ name, email, password }` | Create account, send verify email |
| POST | `/auth/signup/phone` | `{ name, phone }` | Create account, send SMS OTP (E.164) |
| POST | `/auth/verify/phone` | `{ phone, code }` | Verify phone, returns tokens |
| POST | `/auth/verify/email` | `{ token }` | Verify email, returns tokens, sends welcome |
| POST | `/auth/verify/email/resend` | `{ email }` | Resend verification email |
| POST | `/auth/login/email` | `{ email, password }` | Returns tokens (requires verified email) |
| POST | `/auth/login/phone/request` | `{ phone }` | Send login OTP |
| POST | `/auth/login/phone/verify` | `{ phone, code }` | Verify OTP, returns tokens |
| POST | `/auth/forgot-password` | `{ email }` | Send reset link (always 200) |
| POST | `/auth/reset-password` | `{ token, password }` | Reset password, returns tokens |
| POST | `/auth/refresh` | `{ refreshToken? }` | Rotate access/refresh tokens |
| POST | `/auth/logout` | — | Clears auth cookies |
| GET  | `/auth/me` | — *(auth)* | Current user |
| POST | `/auth/change-password` | `{ currentPassword, newPassword }` *(auth)* | Update password |

### Users

| Method | Path | Description |
|---|---|---|
| GET | `/users/me` | Get profile |
| PATCH | `/users/me` | Update profile (name) |
| DELETE | `/users/me` | Deactivate account |

Authenticated requests can use either:
- `Authorization: Bearer <accessToken>` header, **or**
- `access_token` httpOnly signed cookie (set automatically on login)

### Example
```bash
curl -X POST http://localhost:5000/api/auth/signup/email \
  -H 'Content-Type: application/json' \
  -d '{"name":"Jane","email":"jane@example.com","password":"Str0ngPass!"}'
```

---

## 6. Security hardening (already applied)

- Bcrypt password hashing (configurable rounds, default 12)
- OTP codes hashed with bcrypt at rest (never stored in plaintext)
- JWT short-lived access tokens + rotated refresh tokens
- httpOnly + signed + sameSite=none/lax cookies
- Helmet (CSP-friendly defaults), CORS allow-list, HPP, XSS sanitization, mongo injection sanitization
- express-rate-limit on global + auth + OTP routes
- Account lockout on 5 failed logins (15 min)
- OTP attempt cap (5) and resend cooldown (60s)
- Constant-time-ish "always 200" response on `/forgot-password` to avoid email enumeration
- Validation via express-validator on every public route

---

## 7. Deployment

### Backend on **Render**
1. New → Web Service → connect this repo, set root dir `backend`.
2. Render auto-detects `render.yaml`. Fill in all `sync: false` env vars in the dashboard.
3. Deploy. Health check at `/api/health`.

### Backend on **Railway**
1. New Project → Deploy from GitHub → root `backend`.
2. Add MongoDB Atlas plugin or set `MONGO_URI` to your Atlas string.
3. Add all env vars from `.env.example`. Deploy.

### Backend on **Vercel** (serverless)
- `cd backend && vercel`. `vercel.json` routes everything to `src/server.js`.
- Note: Mongo connections are pooled poorly on serverless cold starts; prefer Render/Railway for sustained load.

### Frontend on **Netlify**
1. New site → connect repo → publish dir `frontend`.
2. Update `frontend/config.js` `window.API_BASE` to your backend URL **before** deploying, or set via build env.
3. `netlify.toml` already configured.

### Frontend on **Vercel**
- `cd frontend && vercel`. Static deploy with `vercel.json`.

### CORS
Set `CLIENT_URL` on the backend to your deployed frontend origin (comma-separated for multiple).
Example: `CLIENT_URL=https://app.example.com,https://www.example.com`

---

## 8. Testing steps

```bash
# 1. Signup
curl -X POST $API/auth/signup/email -H 'Content-Type: application/json' \
  -d '{"name":"Test","email":"you@example.com","password":"Str0ngPass!"}'

# 2. Click verify link in your inbox → loads /verify-email.html?token=...

# 3. Login
curl -X POST $API/auth/login/email -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"Str0ngPass!"}'

# 4. /me with returned accessToken
curl $API/auth/me -H "Authorization: Bearer $ACCESS_TOKEN"

# 5. Phone OTP flow (without Twilio, code prints to backend logs)
curl -X POST $API/auth/signup/phone -H 'Content-Type: application/json' \
  -d '{"name":"Test","phone":"+14155550100"}'
# read code from server log
curl -X POST $API/auth/verify/phone -H 'Content-Type: application/json' \
  -d '{"phone":"+14155550100","code":"123456"}'

# 6. Forgot password
curl -X POST $API/auth/forgot-password -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com"}'
```

Or open `frontend/index.html` in a browser (with the backend running on localhost:5000) and walk the flows visually.

---

## 9. Integrating with your existing HTML prototype

If you have an existing prototype (e.g. `darwish_interserve_app_prototype.html`), you can wire it to this backend in 3 steps:

1. **Include the API client** before your closing `</body>`:
   ```html
   <script src="path/to/frontend/config.js"></script>
   <script src="path/to/frontend/js/api.js"></script>
   <script src="path/to/frontend/js/ui.js"></script>
   ```
2. **Hook your existing forms** to the API helpers:
   ```js
   document.querySelector('#yourSignupForm').addEventListener('submit', async (e) => {
     e.preventDefault();
     try {
       await API.signupEmail({ name, email, password });
       location.href = `verify-email.html?email=${encodeURIComponent(email)}`;
     } catch (err) {
       alert(err.message);
     }
   });
   ```
3. **Set `window.API_BASE`** in your prototype to the backend URL.

The standalone `frontend/*.html` pages are fully functional drop-ins for verify-email, verify-otp, forgot/reset password if your prototype lacks those screens.

---

## 10. Notes & next steps

- The Mongoose `Otp` collection uses a TTL index — expired records auto-delete.
- All controllers use a single `asyncHandler` wrapper so you never have to write `try/catch` for thrown ApiErrors.
- For mass-volume SMS, swap `services/smsService.js` for Twilio Verify (`TWILIO_VERIFY_SERVICE_SID` is already in `.env.example`) — it adds carrier-grade fraud detection.
- For social login (Google/Apple), add Passport strategies under `services/oauth/` and mount on `/auth/oauth/*`.
