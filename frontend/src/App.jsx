import { Routes, Route, Navigate } from 'react-router-dom'
import Home from './pages/Home'
import Features from './pages/Features'
import Pricing from './pages/Pricing'
import Dashboard from './pages/Dashboard'
import ProgramBuilder from './pages/ProgramBuilder'
import TrainingLog from './pages/TrainingLog'
import Analytics from './pages/Analytics'
import Inventory from './pages/Inventory'
import Login from './pages/Login'
import Register from './pages/Register'

function App() {
  return (
    <div className="min-h-screen bg-bg text-white">
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/features" element={<Features />} />
        <Route path="/pricing" element={<Pricing />} />
        <Route path="/app" element={<Dashboard />} />
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
