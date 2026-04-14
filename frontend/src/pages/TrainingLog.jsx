import AppShell from '../components/AppShell'

function TrainingLog() {
  return (
    <AppShell title="Training Log" subtitle="Performance schematic">
      <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
        <h3 className="text-xl font-bold uppercase tracking-[0.1em] text-white">Training log</h3>
        <p className="mt-4 text-sm text-zinc-400">Track sessions, load, RPE, and volume over time. This page will show session history and workout details.</p>
      </div>
    </AppShell>
  )
}

export default TrainingLog
