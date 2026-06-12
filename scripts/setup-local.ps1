# Workshop Service Advisor - Local Setup Script (Windows)
# Run: powershell -ExecutionPolicy Bypass -File scripts\setup-local.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Backend = Join-Path $Root "backend"

Write-Host "=== Workshop Service Advisor - Local Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "[OK] Node.js $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Node.js not found. Install from https://nodejs.org" -ForegroundColor Red
    exit 1
}

# Check SQL Server service
$sqlService = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
if ($sqlService -and $sqlService.Status -eq "Running") {
    Write-Host "[OK] SQL Server is running" -ForegroundColor Green
} else {
    Write-Host "[WARN] SQL Server not detected or not running" -ForegroundColor Yellow
    Write-Host "       Install SQL Server Express and create database 'workshop_advisor'" -ForegroundColor Yellow
    Write-Host "       See LOCAL_SETUP.md Step 1" -ForegroundColor Yellow
}

# Check Flutter
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "[OK] Flutter installed" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Flutter not installed - needed to run mobile app" -ForegroundColor Yellow
    Write-Host "       See LOCAL_SETUP.md Step 4" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Setting up backend..." -ForegroundColor Cyan

Set-Location $Backend

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Created backend/.env from .env.example" -ForegroundColor Green
} else {
    Write-Host "backend/.env already exists" -ForegroundColor Gray
}

Write-Host "Installing npm packages..."
npm install

Write-Host ""
Write-Host "Running database migration..."
try {
    npm run migrate
    Write-Host "[OK] Migration complete" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Migration failed - is SQL Server running with database 'workshop_advisor'?" -ForegroundColor Red
    Write-Host "       Create database in SSMS: CREATE DATABASE workshop_advisor;" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Seeding sample data..."
try {
    npm run seed
    Write-Host "[OK] Seed complete" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Seed failed (migration may have failed first)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Setup complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Start the API:" -ForegroundColor White
Write-Host "  cd backend" -ForegroundColor Gray
Write-Host "  npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "Start the app (after Flutter installed):" -ForegroundColor White
Write-Host "  cd mobile" -ForegroundColor Gray
Write-Host "  flutter pub get" -ForegroundColor Gray
Write-Host "  flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api" -ForegroundColor Gray
Write-Host ""
Write-Host "Login: advisor / password123" -ForegroundColor Green
Write-Host "Full guide: LOCAL_SETUP.md" -ForegroundColor Gray
