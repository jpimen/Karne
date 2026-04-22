import { AppShell } from '../components'

function Analytics() {
  return (
    <AppShell title="Analytics" subtitle="Performance schematic">
      <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
        <h3 className="text-xl font-bold uppercase tracking-[0.1em] text-white">Analytics</h3>
        <p className="mt-4 text-sm text-zinc-400">Weekly volume trends, PR progression, and velocity tracking will appear here once connected to your workout data.</p>
      </div>
    </AppShell>
  )
}

export default Analytics
