# Karne Backend

This is the backend service for the Karne application, built with Django and Django Rest Framework.

## Prerequisites

- Python 3.8 or higher
- pip (Python package installer)
- virtualenv or venv

## Setup and Installation

### 1. Navigate to the Backend Directory
```powershell
cd backend
```

### 2. Set Up a Virtual Environment
It is recommended to use a virtual environment to manage dependencies.

**On Windows:**
```powershell
python -m venv .venv
.\.venv\Scripts\activate
```

**On macOS/Linux:**
```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Install Dependencies
```powershell
pip install -r requirements.txt
```

### 4. Environment Variables
Copy the `.env.example` file to `.env` and update the values as needed.
```powershell
copy .env.example .env
```

By default, the project is configured to use SQLite. If you wish to use PostgreSQL, set `USE_SQLITE=False` in your `.env` file and provide the database credentials.

### 5. Run Database Migrations
```powershell
python manage.py migrate
```

### 6. Create a Superuser (Optional)
To access the Django Admin interface:
```powershell
python manage.py createsuperuser
```

## Running the Server

Start the development server:
```powershell
python manage.py runserver
```

The API will be available at `http://127.0.0.1:8000/`.

## API Endpoints

- **Authentication:**
  - `POST /api/auth/register/` - Register a new user
  - `POST /api/auth/login/` - Obtain JWT tokens
  - `POST /api/auth/token/refresh/` - Refresh JWT tokens
  - `GET /api/auth/profile/` - Get current user profile
- **Core Resources:**
  - `/api/programs/` - Training programs
  - `/api/clients/` - Client management
  - `/api/assignments/` - Program assignments
  - `/api/sessions/` - Training sessions
- **Dashboard:**
  - `GET /api/dashboard/` - Summary statistics
- **Admin:**
  - `/admin/` - Django Administration interface
