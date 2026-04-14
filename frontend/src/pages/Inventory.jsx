import AppShell from '../components/AppShell'

function Inventory() {
  return (
    <AppShell title="Inventory" subtitle="Performance schematic">
      <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
        <h3 className="text-xl font-bold uppercase tracking-[0.1em] text-white">Inventory</h3>
        <p className="mt-4 text-sm text-zinc-400">Track your equipment, barbell inventory, plates, and calibration data for accurate program planning.</p>
      </div>
    </AppShell>
  )
}

export default Inventory
