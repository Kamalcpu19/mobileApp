# Workshop Service Advisor

Production-ready cross-platform mobile application for automobile workshop service advisors.

**Stack:** Flutter · Node.js/Express · SQL Server · JWT · OpenAI · AWS S3

## Project Structure

```
workshop-service-advisor/
├── backend/          # Node.js REST API + SQL Server
├── mobile/           # Flutter app (Riverpod + GoRouter + Clean Architecture)
└── README.md
```

## Features

- **Authentication** — JWT login for service advisors
- **Dashboard** — Dynamic counts for messages, appointments, vehicle attention, pending payments
- **Appointments** — Search, filter by category (AM/PM/APP/Call In/Auto Reminder), create RO
- **Create RO Workflow** — Vehicle detection (OCR + manual), image capture, pre-inspection, complaints, AI recommendations, job card
- **Vehicle Required Attention** — Stage tracking from estimation through delivery
- **Estimation** — AI quote agent, manual parts/services, approval workflow
- **Approval** — Customer secure link with swipe approve/reject
- **Invoice & Payments** — PDF generation, sharing (WhatsApp/Email/SMS), payment links, AI reminders
- **Profile** — Workshop info, automation settings (read-only), workspace settings (language/theme)

## Quick Start

### Prerequisites

- Node.js 20+
- SQL Server 2019+ (or Docker)
- Flutter 3.16+ (for mobile)
- Docker (optional)

### Backend

```powershell
cd backend
copy .env.example .env
npm install

# Start SQL Server (Docker)
docker compose up -d sqlserver

# Create database (first time only - wait ~30s for SQL Server to start)
# Run backend/scripts/create-database.sql in Azure Data Studio or sqlcmd:
# CREATE DATABASE workshop_advisor;

# Migrate and seed database
npm run migrate
npm run seed

# Start API server
npm run dev
```

API runs at `http://localhost:3000`

**Default login:** `advisor` / `password123`

### Mobile App

```powershell
cd mobile
flutter pub get
flutter create . --project-name workshop_service_advisor
flutter run
```

For Android emulator, the API base URL automatically maps `localhost` to `10.0.2.2`.

Override with:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:3000/api
```

### Docker (Full Stack)

```powershell
cd backend
docker compose up --build
```

## API Endpoints

| Module | Endpoint |
|--------|----------|
| Auth | `POST /api/auth/login`, `GET /api/auth/profile` |
| Dashboard | `GET /api/dashboard/counts` |
| Appointments | `GET /api/appointments` |
| Repair Orders | `GET/POST /api/repair-orders`, `PATCH /api/repair-orders/:id/stage` |
| Vehicles | `GET /api/vehicles/lookup/:reg`, `POST /api/vehicles/ocr` |
| Inspections | `GET/POST /api/inspections/:roId` |
| Complaints | `GET/POST /api/complaints/:roId`, `POST .../analyze` |
| AI | `GET /api/ai/settings`, `POST /api/ai/estimate/:roId` |
| Estimates | `GET/POST /api/estimates/:roId`, `POST .../submit` |
| Invoices | `GET /api/invoices/pending`, `POST .../generate` |

## Environment Variables

See `backend/.env.example` for:

- `DB_SERVER`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` — SQL Server connection
- `JWT_SECRET` — Token signing key
- `OPENAI_API_KEY` — AI features (complaints, estimates, OCR)
- `AWS_*` — S3 file uploads
- `VAHAN_API_KEY` — India vehicle lookup

## Testing

```powershell
# Backend
cd backend
npm test

# Mobile
cd mobile
flutter test
```

## Architecture

### Flutter (Clean Architecture)

```
features/
  auth/
    domain/       # entities, repository interfaces
    data/         # models, datasources, repository impl
    presentation/ # screens, providers, widgets
```

State management: **Riverpod**  
Navigation: **GoRouter**  
Networking: **Dio** with JWT interceptor

### Backend

```
src/
  routes/       # Express route definitions
  services/     # Business logic
  db/           # PostgreSQL schema, migrations, seed
  middleware/   # JWT auth, validation
```

## Firebase (Optional)

The app uses JWT authentication via the Node.js API. To add Firebase Cloud Messaging for push notifications:

1. Create a Firebase project
2. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Add `firebase_core` and `firebase_messaging` to `pubspec.yaml`

## License

Proprietary — Workshop Service Advisor
