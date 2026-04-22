import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api, { setAuthToken } from '../utils/api'

function Login() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState(null)
  const navigate = useNavigate()

  const handleSubmit = async (event) => {
    event.preventDefault()
    try {
      const response = await api.post('/auth/login/', { username, password })
      const token = response.data.access
      setAuthToken(token)
      localStorage.setItem('lab_access_token', token)
      navigate('/app')
    } catch (err) {
      setError('Login failed. Check your credentials.')
    }
  }

  return (
    <div className="min-h-screen grid place-items-center px-4 py-12">
      <form onSubmit={handleSubmit} className="w-full max-w-md rounded-3xl border border-zinc-800 bg-surface2 p-8 shadow-xl">
        <h1 className="text-3xl font-black uppercase tracking-widest text-gold">Sign in</h1>
        <p className="mt-2 text-sm text-zinc-400">Use your Laboratory credentials to access the dashboard.</p>

        <div className="mt-8 space-y-4">
          <label className="block text-sm uppercase tracking-[0.2em] text-zinc-400">
            Username
            <input value={username} onChange={(e) => setUsername(e.target.value)} className="mt-2 w-full rounded-2xl border border-zinc-800 bg-bg p-3 text-white" />
          </label>
          <label className="block text-sm uppercase tracking-[0.2em] text-zinc-400">
            Password
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="mt-2 w-full rounded-2xl border border-zinc-800 bg-bg p-3 text-white" />
          </label>
        </div>

        {error ? <p className="mt-4 text-sm text-rose-500">{error}</p> : null}

        <button type="submit" className="mt-8 w-full rounded-2xl bg-gold py-3 font-bold uppercase text-black transition hover:bg-yellow-500">
          Login
        </button>
      </form>
    </div>
  )
}

export default Login
