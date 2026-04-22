# Karne Frontend

The web-based user interface for the Karne application, built with React, Vite, and Tailwind CSS.

## Prerequisites

- Node.js (v18 or higher recommended)
- npm or yarn

## Setup and Installation

### 1. Navigate to the Frontend Directory
```bash
cd frontend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Variables (Optional)
If the backend is not running on the default `http://localhost:8000`, you may need to configure the API base URL in the source code or via a `.env` file (if implemented).

## Running the Application

### Development Mode
Start the Vite development server:
```bash
npm run dev
```
The application will be available at `http://localhost:5173/` (or the port specified in the terminal).

### Production Build
To create a production-ready build:
```bash
npm run build
```
The output will be in the `dist/` directory.

### Preview Build
To preview the production build locally:
```bash
npm run preview
```

## Technologies Used

- **React**: UI library
- **Vite**: Build tool and dev server
- **Tailwind CSS**: Utility-first CSS framework
- **React Router**: Client-side routing
- **Recharts**: Data visualization for fitness progress
- **Axios**: HTTP client for API requests
