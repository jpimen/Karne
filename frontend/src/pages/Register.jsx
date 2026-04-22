import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../utils/api'

function Register() {
  const [username, setUsername] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [message, setMessage] = useState(null)
  const navigate = useNavigate()

  const handleSubmit = async (event) => {
    event.preventDefault()
    try {
      await api.post('/auth/register/', { username, email, password })
      setMessage('Account created successfully. Redirecting...')
      setTimeout(() => navigate('/login'), 1200)
    } catch (err) {
      setMessage('Registration failed. Please check your input.')
    }
  }

  return (
    <div className="min-h-screen grid place-items-center px-4 py-12">
      <form onSubmit={handleSubmit} className="w-full max-w-md rounded-3xl border border-zinc-800 bg-surface2 p-8 shadow-xl">
        <h1 className="text-3xl font-black uppercase tracking-widest text-gold">Register</h1>
        <p className="mt-2 text-sm text-zinc-400">Create a Laboratory account for training and analytics.</p>

        <div className="mt-8 space-y-4">
          <label className="block text-sm uppercase tracking-[0.2em] text-zinc-400">
            Username
            <input value={username} onChange={(e) => setUsername(e.target.value)} className="mt-2 w-full rounded-2xl border border-zinc-800 bg-bg p-3 text-white" />
          </label>
          <label className="block text-sm uppercase tracking-[0.2em] text-zinc-400">
            Email
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} className="mt-2 w-full rounded-2xl border border-zinc-800 bg-bg p-3 text-white" />
          </label>
          <label className="block text-sm uppercase tracking-[0.2em] text-zinc-400">
            Password
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="mt-2 w-full rounded-2xl border border-zinc-800 bg-bg p-3 text-white" />
          </label>
        </div>

        {message ? <p className="mt-4 text-sm text-zinc-300">{message}</p> : null}

        <button type="submit" className="mt-8 w-full rounded-2xl bg-gold py-3 font-bold uppercase text-black transition hover:bg-yellow-500">
          Create Account
        </button>
      </form>
    </div>
  )
}

export default Register
