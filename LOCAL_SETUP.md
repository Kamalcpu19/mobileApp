# Local Setup Guide (Windows)

Follow these steps to run **Workshop Service Advisor** on your PC.

## What you need

| Tool | Purpose | Install |
|------|---------|---------|
| Node.js 20+ | Backend API | Already installed |
| SQL Server | Database | Step 1 below |
| Flutter 3.16+ | Mobile / web app | Step 4 below |

---

## Step 1: SQL Server (already on your PC)

You already have **SQL Server 2022** installed and running. The app uses **Windows Authentication** automatically — no password needed.

The database `workshop_advisor` is created automatically on first run.

If you use **SSMS**, you can verify the database exists under Databases → `workshop_advisor`.

---

## Step 2: Start the backend API

Open **PowerShell** in the project folder:

```powershell
cd "C:\Users\kamal\OneDrive\Desktop\New mobile app\backend"
npm install
npm run migrate
npm run seed
npm run dev
```

You should see:

```text
Workshop Service Advisor API running on port 3000
```

Test in browser: [http://localhost:3000/health](http://localhost:3000/health)

**Login credentials:** `advisor` / `password123`

### Quick setup script

```powershell
cd "C:\Users\kamal\OneDrive\Desktop\New mobile app"
powershell -ExecutionPolicy Bypass -File scripts\setup-local.ps1
```

---

## Step 3: Run the app in browser (no Flutter install)

If Flutter is not installed, you can still test via **Netlify** after API is running, or install Flutter (Step 4).

---

## Step 4: Install Flutter

1. Download Flutter SDK: [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)

2. Extract to `C:\flutter` and add to PATH:
   - Windows Search → **Environment Variables**
   - Edit **Path** → Add `C:\flutter\bin`

3. Open a **new** PowerShell window:

```powershell
flutter doctor
flutter config --enable-web
```

---

## Step 5: Run the mobile app

### Option A — Chrome (web, easiest)

```powershell
cd "C:\Users\kamal\OneDrive\Desktop\New mobile app\mobile"
flutter pub get
flutter create . --project-name workshop_service_advisor --platforms=web
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

### Option B — Android phone / emulator

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

(`10.0.2.2` is localhost from Android emulator)

### Option C — Windows desktop

```powershell
flutter create . --platforms=windows
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:3000/api
```

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `ECONNREFUSED` / database connection failed | SQL Server not running. Start **SQL Server (MSSQLSERVER)** in Services |
| Login failed for user `sa` | Wrong password in `backend/.env` |
| Database `workshop_advisor` does not exist | Run `CREATE DATABASE workshop_advisor;` in SSMS |
| `flutter` not recognized | Install Flutter and restart PowerShell |
| App can't reach API on phone | Use your PC IP instead of localhost, e.g. `http://192.168.1.5:3000/api` |
| Port 3000 in use | Change `PORT=3001` in `backend/.env` |

---

## Daily workflow

**Terminal 1 — API:**

```powershell
cd backend
npm run dev
```

**Terminal 2 — App:**

```powershell
cd mobile
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

---

## Project structure

```text
New mobile app/
├── backend/     ← API (Node.js + SQL Server)
├── mobile/      ← Flutter app
└── scripts/     ← setup-local.ps1
```
