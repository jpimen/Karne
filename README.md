# The Laboratory

A full-stack fitness performance tracking application with web, mobile, and backend components.

## Architecture

- Backend: Django + Django REST Framework + PostgreSQL + JWT Authentication
- Web: React + Vite + Tailwind CSS + Recharts
- Mobile: Flutter + Provider + Dio + Shared Preferences

## Getting Started

### Backend

1. Create a Python virtual environment and activate it.
2. Install dependencies:
   ```bash
   pip install -r backend/requirements.txt
   ```
3. Create a `.env` in `backend/` and set the database and secret values.
4. Run migrations:
   ```bash
   python backend/manage.py migrate
   ```
5. Start the server:
   ```bash
   python backend/manage.py runserver
   ```

### Web

1. Install dependencies:
   ```bash
   cd frontend
   npm install
   ```
2. Start the dev server:
   ```bash
   npm run dev
   ```

### Mobile

1. Install Flutter SDK.
2. From `mobile/`, run:
   ```bash
   flutter pub get
   flutter run
   ```

## API Endpoints

- `POST /api/auth/register/`
- `POST /api/auth/login/`
- `POST /api/auth/token/refresh/`
- `GET/POST /api/programs/`
- `GET/PUT/DELETE /api/programs/{id}/`
- `GET/POST /api/sessions/`
- `GET/PUT/DELETE /api/sessions/{id}/`
- `GET/POST /api/exercises/`
- `GET /api/analytics/weekly-volume/`
- `GET /api/analytics/prs/`
- `GET /api/dashboard/`
