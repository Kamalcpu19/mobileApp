# Netlify Deployment Guide

Deploy the **Workshop Service Advisor web app** on Netlify. The backend API must be hosted separately (Netlify cannot run Node.js + SQL Server).

## What Netlify hosts

| Component | Netlify? |
|-----------|----------|
| Flutter web UI | Yes |
| Node.js API | No — use Azure, Render, or Railway |
| SQL Server database | No — use Azure SQL or Docker VPS |

## Step 1: Deploy the API first (required)

The web app needs a live API URL. Options:

- **Azure App Service** + **Azure SQL** (best for SQL Server)
- **Render / Railway** with SQL Server connection string

Note your API URL, e.g. `https://your-api.azurewebsites.net/api`

## Step 2: Connect Netlify to GitHub

1. Go to [https://app.netlify.com](https://app.netlify.com) and sign in
2. Click **Add new site** → **Import an existing project**
3. Choose **GitHub** → authorize → select **`Kamalcpu19/mobileApp`**
4. Netlify reads `netlify.toml` automatically:
   - **Base directory:** `mobile`
   - **Build command:** `bash scripts/netlify-build.sh`
   - **Publish directory:** `build/web`

## Step 3: Set environment variable

In Netlify: **Site configuration** → **Environment variables** → **Add variable**

| Key | Value |
|-----|--------|
| `API_BASE_URL` | Your live API URL, e.g. `https://your-api.azurewebsites.net/api` |

Redeploy after saving.

## Step 4: Deploy

Click **Deploy site**. First build takes ~5–10 minutes (downloads Flutter).

Your site will be live at: `https://random-name.netlify.app`

Rename under **Domain management** → **Options** → **Edit site name**.

## Step 5: Test

1. Open your Netlify URL
2. Login: `advisor` / `password123` (change in production)
3. If login fails, check:
   - `API_BASE_URL` is correct
   - API is running and reachable
   - API `CORS_ORIGIN` allows your Netlify domain (or `*`)

## Custom domain (optional)

**Domain management** → **Add a domain** → follow DNS instructions.

## Mobile app (Android/iPhone)

Netlify deploys the **browser version** only. For native mobile:

```powershell
cd mobile
flutter build apk --dart-define=API_BASE_URL=https://your-api-url.com/api
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Build fails on Flutter install | Retry deploy; check Netlify build logs |
| Blank page after deploy | Check browser console; verify `base href` in `web/index.html` |
| Login / API errors | Set `API_BASE_URL`; ensure API is live with HTTPS |
| 404 on refresh | `netlify.toml` redirects should handle this |
