import { useEffect, useMemo, useState } from 'react'
import api from '../utils/api'
import { AppShell } from '../components'
import { LineChart, Line, CartesianGrid, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'

const metricCards = (summary, currentProgram) => [
  { label: 'Weekly Volume', value: `${summary?.weekly_volume_kg || 0} kg` },
  { label: 'Sessions', value: `${summary?.session_count || 0} / 5` },
  { label: 'Current Program', value: currentProgram?.name || 'No active block' },
  { label: 'Max Velocity', value: '0.82 m/s' },
]

function Dashboard() {
  const [dashboard, setDashboard] = useState(null)
  const [chartData, setChartData] = useState([])

  useEffect(() => {
    api.get('/dashboard/').then((res) => setDashboard(res.data)).catch(() => {})
    api.get('/analytics/weekly-volume/').then((res) => setChartData(res.data)).catch(() => {})
  }, [])

  const recentSession = dashboard?.recent_sessions?.[0]
  const nextExercise = useMemo(() => {
    const firstDay = dashboard?.current_program?.days?.[0]
    return firstDay?.exercises?.[0]
  }, [dashboard])

  return (
    <AppShell title="Dashboard" subtitle="Performance schematic">
      <div className="space-y-8">
        <section className="grid gap-4 xl:grid-cols-4">
          {metricCards(dashboard?.summary || {}, dashboard?.current_program).map((item) => (
            <article key={item.label} className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-6 shadow-xl">
              <p className="text-xs uppercase tracking-[0.4em] text-zinc-400">{item.label}</p>
              <p className="mt-4 text-3xl font-black uppercase tracking-[-0.03em] text-white">{item.value}</p>
            </article>
          ))}
        </section>

        <section className="grid gap-6 xl:grid-cols-[2fr_1fr]">
          <div className="space-y-6">
            <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-6 shadow-xl">
              <div className="mb-6 flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-bold uppercase tracking-[0.05em] text-white">Weekly training calendar</h3>
                  <p className="text-sm text-zinc-500">October 23 - 29</p>
                </div>
              </div>
              <div className="grid gap-4 sm:grid-cols-5">
                {['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((day) => (
                  <div key={day} className="rounded-3xl border border-zinc-800 bg-[#141414] p-4 text-center">
                    <p className="text-xs uppercase tracking-[0.3em] text-zinc-500">{day}</p>
                    <p className="mt-3 text-sm font-semibold text-white">{day === 'Wed' ? 'REST' : day === 'Fri' ? 'Lower Body Power' : day === 'Thu' ? 'Pull A' : day === 'Tue' ? 'Push A' : 'Legs A'}</p>
                  </div>
                ))}
              </div>
            </div>

            <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-6 shadow-xl">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-bold uppercase tracking-[0.05em] text-white">Recent performance log</h3>
                <button className="rounded-full border border-zinc-700 px-4 py-2 text-xs uppercase tracking-[0.25em] text-zinc-400 hover:border-gold hover:text-gold">View history</button>
              </div>
              <div className="space-y-4">
                {dashboard?.recent_sessions?.map((session) => (
                  <div key={session.id} className="rounded-3xl bg-[#141414] p-4">
                    <div className="flex items-start justify-between gap-4">
                      <div>
                        <p className="text-sm uppercase tracking-[0.25em] text-zinc-400">{session.date}</p>
                        <p className="mt-2 text-lg font-bold text-white">{session.notes || 'Performance session'}</p>
                      </div>
                      <div className="space-y-1 text-right text-sm text-zinc-300">
                        <p>Volume {session.total_volume_kg} kg</p>
                        <p>Duration {session.duration_minutes} min</p>
                      </div>
                    </div>
                  </div>
                ))}
                {!dashboard?.recent_sessions?.length && <p className="text-sm text-zinc-400">No sessions logged yet.</p>}
              </div>
            </div>
          </div>

          <aside className="space-y-6">
            <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-6 shadow-xl">
              <h3 className="text-lg font-bold uppercase tracking-[0.05em] text-white">Next mission preview</h3>
              <div className="mt-6 space-y-4">
                {nextExercise ? (
                  <>
                    <div className="rounded-3xl bg-[#141414] p-4">
                      <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">Target</p>
                      <p className="mt-2 text-xl font-bold text-white">{nextExercise.exercise.name}</p>
                    </div>
                    <div className="grid gap-3">
                      <div className="rounded-3xl bg-[#141414] p-4">
                        <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">Load</p>
                        <p className="mt-2 text-base text-white">{nextExercise.sets} x {nextExercise.reps} @ {nextExercise.target_weight}kg</p>
                      </div>
                      <button className="w-full rounded-3xl bg-gold px-4 py-4 text-sm font-bold uppercase tracking-[0.2em] text-black transition hover:bg-yellow-500">Initialize session</button>
                    </div>
                  </>
                ) : (
                  <p className="text-sm text-zinc-400">Select or create a program to preview your next session.</p>
                )}
              </div>
            </div>

            <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-6 shadow-xl">
              <h3 className="text-lg font-bold uppercase tracking-[0.05em] text-white">Personal record progress</h3>
              <div className="mt-6 space-y-4">
                {dashboard?.prs?.map((pr) => (
                  <div key={pr.id} className="space-y-2">
                    <div className="flex items-center justify-between text-sm uppercase tracking-[0.25em] text-zinc-400">
                      <span>{pr.exercise.name}</span>
                      <span>{pr.weight_kg} kg</span>
                    </div>
                    <div className="h-3 overflow-hidden rounded-full bg-zinc-900">
                      <div className="h-3 rounded-full bg-gold" style={{ width: `${Math.min((pr.weight_kg / 300) * 100, 100)}%` }} />
                    </div>
                  </div>
                ))}
                {!dashboard?.prs?.length && <p className="text-sm text-zinc-400">No personal records found.</p>}
              </div>
            </div>
          </aside>
        </section>

        <section className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-6 shadow-xl">
          <h3 className="text-lg font-bold uppercase tracking-[0.05em] text-white">Volume trend</h3>
          <div className="mt-6 h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid stroke="#2a2a2a" />
                <XAxis dataKey="date" stroke="#9ca3af" />
                <YAxis stroke="#9ca3af" />
                <Tooltip wrapperStyle={{ backgroundColor: '#111111', border: '1px solid #333' }} />
                <Line type="monotone" dataKey="volume" stroke="#D4A017" strokeWidth={3} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </section>
      </div>
    </AppShell>
  )
}

export default Dashboard
