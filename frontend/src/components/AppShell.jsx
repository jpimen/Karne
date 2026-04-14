import { NavLink } from 'react-router-dom'

const navItems = [
  { label: 'Dashboard', to: '/app', icon: '▹' },
  { label: 'Program Builder', to: '/app/program-builder', icon: '▹' },
  { label: 'Training Log', to: '/app/training-log', icon: '▹' },
  { label: 'Analytics', to: '/app/analytics', icon: '▹' },
  { label: 'Inventory', to: '/app/inventory', icon: '▹' },
]

function AppShell({ title, subtitle, children }) {
  return (
    <div className="min-h-screen bg-[#0d0d0d] text-white">
      <div className="grid min-h-screen lg:grid-cols-[240px_1fr]">
        <aside className="border-r border-zinc-900 bg-[#0f0f0f] p-6">
          <div className="space-y-6">
            <div>
              <p className="text-sm uppercase tracking-[0.35em] text-gold">THE LABORATORY</p>
              <p className="mt-2 text-xs uppercase tracking-[0.5em] text-zinc-500">ELITE STATUS</p>
            </div>
            <div className="rounded-3xl border border-zinc-800 bg-[#111111] p-4">
              <p className="text-[11px] uppercase tracking-[0.45em] text-zinc-400">Command center</p>
              <p className="mt-3 text-base font-bold uppercase tracking-[0.2em] text-gold">Live mission</p>
            </div>
          </div>

          <nav className="mt-10 space-y-2">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  `group flex items-center gap-3 rounded-3xl border-l-4 px-4 py-3 text-sm font-semibold uppercase tracking-[0.2em] transition ${
                    isActive ? 'border-gold bg-[#1f1f1f] text-gold' : 'border-transparent text-zinc-300 hover:border-zinc-700 hover:text-zinc-100'
                  }`
                }
              >
                <span className="text-gold">{item.icon}</span>
                {item.label}
              </NavLink>
            ))}
          </nav>

          <div className="mt-auto pt-10">
            <div className="rounded-3xl border border-zinc-800 bg-[#111111] p-4 text-sm text-zinc-300">
              <div className="mb-4 flex items-center justify-between gap-3">
                <span>⚙️</span>
                <span>Settings</span>
              </div>
              <div className="flex items-center gap-3 rounded-3xl bg-[#0d0d0d] p-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-gold text-black">AT</div>
                <div>
                  <p className="text-xs uppercase tracking-[0.35em] text-zinc-500">Athlete Profile</p>
                  <p className="text-sm font-semibold uppercase tracking-[0.2em] text-white">VIEW ACCOUNT</p>
                </div>
              </div>
            </div>
          </div>
        </aside>

        <main className="p-6">
          <header className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="text-xs uppercase tracking-[0.35em] text-gold">{subtitle}</p>
              <h2 className="mt-2 text-3xl font-black uppercase tracking-[-0.04em] text-white">{title}</h2>
            </div>
          </header>

          {children}
        </main>
      </div>
    </div>
  )
}

export default AppShell
