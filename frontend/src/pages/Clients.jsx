import { AppShell } from '../components'

function Clients() {
  return (
    <AppShell title="Clients" subtitle="Manage client relationships">
      <div className="space-y-6">
        <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
          <div className="flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-sm uppercase tracking-[0.35em] text-zinc-400">Client roster</p>
              <h3 className="mt-2 text-3xl font-black uppercase tracking-[-0.04em] text-white">Invite, assign, and review</h3>
            </div>
            <button className="rounded-3xl bg-gold px-6 py-3 text-sm font-bold uppercase tracking-[0.2em] text-black transition hover:bg-yellow-500">
              Invite Client
            </button>
          </div>
        </div>

        <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
          <div className="overflow-x-auto">
            <table className="min-w-full border-collapse text-left text-sm text-white">
              <thead>
                <tr className="border-b border-zinc-800 text-zinc-400">
                  <th className="p-4 uppercase tracking-[0.2em]">Name</th>
                  <th className="p-4 uppercase tracking-[0.2em]">Email</th>
                  <th className="p-4 uppercase tracking-[0.2em]">Assigned Program</th>
                  <th className="p-4 uppercase tracking-[0.2em]">Last Active</th>
                  <th className="p-4 uppercase tracking-[0.2em]">Status</th>
                </tr>
              </thead>
              <tbody>
                <tr className="border-b border-zinc-800">
                  <td className="p-4 font-semibold text-white">John Doe</td>
                  <td className="p-4 text-zinc-400">john.doe@example.com</td>
                  <td className="p-4 text-zinc-400">Hypertrophy Lab</td>
                  <td className="p-4 text-zinc-400">2 days ago</td>
                  <td className="p-4 text-gold">Active</td>
                </tr>
                <tr className="border-b border-zinc-800">
                  <td className="p-4 font-semibold text-white">Maya R.</td>
                  <td className="p-4 text-zinc-400">maya.r@example.com</td>
                  <td className="p-4 text-zinc-400">Strength Cycle</td>
                  <td className="p-4 text-zinc-400">Today</td>
                  <td className="p-4 text-emerald-400">Active</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AppShell>
  )
}

export default Clients
