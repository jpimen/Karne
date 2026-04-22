import { Routes, Route, Navigate } from 'react-router-dom'
import {
  Home,
  Features,
  Pricing,
  Dashboard,
  ProgramBuilder,
  TrainingLog,
  Analytics,
  Inventory,
  Clients,
  Login,
  Register,
} from './pages'

function App() {
  return (
    <div className="min-h-screen bg-bg text-white">
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/features" element={<Features />} />
        <Route path="/pricing" element={<Pricing />} />
        <Route path="/app" element={<Dashboard />} />
        <Route path="/app/clients" element={<Clients />} />
        <Route path="/app/program-builder" element={<ProgramBuilder />} />
        <Route path="/app/training-log" element={<TrainingLog />} />
        <Route path="/app/analytics" element={<Analytics />} />
        <Route path="/app/inventory" element={<Inventory />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </div>
  )
}

export default App
