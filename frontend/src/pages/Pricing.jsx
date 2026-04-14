import { Link } from 'react-router-dom'

function Pricing() {
  return (
    <div className="min-h-screen bg-bg text-white">
      <div className="mx-auto max-w-7xl px-6 py-12">
        <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-gold">Select your specifications</p>
            <h1 className="mt-4 text-4xl font-black uppercase tracking-[-0.04em] sm:text-5xl">System upgrades engineered for peak intensity.</h1>
          </div>
          <Link to="/" className="rounded-full border border-gold px-5 py-3 uppercase tracking-[0.25em] text-sm text-gold transition hover:bg-zinc-900">
            Back home
          </Link>
        </header>

        <p className="mt-6 max-w-2xl text-sm leading-7 text-zinc-300">Choose the architecture that matches your volume. Upgrade to access unlimited programs, cloud sync, and elite analytics.</p>

        <section className="mt-16 grid gap-6 xl:grid-cols-3">
          <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
            <p className="text-sm uppercase tracking-[0.3em] text-zinc-400">System 01</p>
            <h2 className="mt-4 text-4xl font-black uppercase tracking-[-0.04em] text-white">Novice</h2>
            <p className="mt-4 text-5xl font-black text-white">Free</p>
            <p className="mt-2 text-sm uppercase tracking-[0.3em] text-zinc-400">Entry level access</p>
            <ul className="mt-8 space-y-3 text-sm text-zinc-300">
              <li>3 active programs</li>
              <li>Basic lift tracking</li>
            </ul>
            <div className="mt-8">
              <button className="w-full rounded-3xl bg-zinc-800 px-5 py-4 uppercase tracking-[0.2em] text-sm text-zinc-200 transition hover:bg-zinc-700">Initiate Free</button>
            </div>
          </div>

          <div className="rounded-[2rem] border border-gold bg-[#111111] p-8 shadow-xl">
            <div className="flex items-center gap-3 text-xs uppercase tracking-[0.35em] text-zinc-400">
              <span className="rounded-full bg-gold px-3 py-1 font-bold text-black">Most popular</span>
            </div>
            <h2 className="mt-5 text-4xl font-black uppercase tracking-[-0.04em] text-white">Architect</h2>
            <p className="mt-4 text-5xl font-black text-white">$199<span className="text-base font-medium text-zinc-400">/year</span></p>
            <p className="mt-2 text-xs uppercase tracking-[0.3em] text-zinc-400">Annual pro optimization</p>
            <ul className="mt-8 space-y-3 text-sm text-zinc-300">
              <li>Unlimited programs</li>
              <li>Enterprise cloud sync</li>
              <li>Advanced analytics</li>
              <li>Custom intensity logic</li>
              <li>Priority laboratory access</li>
            </ul>
            <div className="mt-8">
              <button className="w-full rounded-3xl bg-gold px-5 py-4 uppercase tracking-[0.2em] text-sm font-bold text-black transition hover:bg-yellow-500">Deploy Architect</button>
            </div>
          </div>

          <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
            <p className="text-sm uppercase tracking-[0.3em] text-zinc-400">System 02</p>
            <h2 className="mt-4 text-4xl font-black uppercase tracking-[-0.04em] text-white">Elite</h2>
            <p className="mt-4 text-5xl font-black text-white">$24<span className="text-base font-medium text-zinc-400">/mo</span></p>
            <p className="mt-2 text-xs uppercase tracking-[0.3em] text-zinc-400">Monthly high performance</p>
            <ul className="mt-8 space-y-3 text-sm text-zinc-300">
              <li>10 active programs</li>
              <li>Cloud sync</li>
              <li>Advanced analytics</li>
            </ul>
            <div className="mt-8">
              <button className="w-full rounded-3xl bg-zinc-800 px-5 py-4 uppercase tracking-[0.2em] text-sm text-zinc-200 transition hover:bg-zinc-700">Upgrade to Elite</button>
            </div>
          </div>
        </section>

        <section className="mt-16 overflow-hidden rounded-[2rem] bg-[#111111] p-8 shadow-xl">
          <div className="flex flex-col gap-8 xl:flex-row xl:items-center xl:justify-between">
            <div>
              <h2 className="text-3xl font-black uppercase tracking-[-0.04em] text-white">Technical comparison</h2>
              <p className="mt-3 text-sm leading-7 text-zinc-300">Compare each tier by functional capability and choose the best fit for elite training volume.</p>
            </div>
            <div className="rounded-3xl bg-[#151515] px-4 py-3 text-sm uppercase tracking-[0.25em] text-gold">No limits. No weakness.</div>
          </div>

          <div className="mt-10 overflow-hidden rounded-[1.5rem] bg-[#141414] border border-zinc-800">
            <div className="grid grid-cols-[1.8fr_1fr_1fr_1fr] gap-px bg-zinc-900 text-center text-xs uppercase tracking-[0.3em] text-zinc-400">
              <div className="bg-[#111111] px-4 py-4 text-left font-bold text-white">Functional capability</div>
              <div className="bg-[#111111] px-4 py-4">Novice</div>
              <div className="bg-[#111111] px-4 py-4">Elite</div>
              <div className="bg-[#111111] px-4 py-4">Architect</div>
            </div>
            {[
              ['Unlimited programs', '—', '10 Max', '✔'],
              ['Cloud sync', '—', '✔', '✔'],
              ['Advanced analytics', '—', '✔', '✔'],
              ['Custom intensity logic', '—', '—', '✔'],
              ['Data export (CSV/JSON)', '—', '✔', '✔'],
            ].map(([label, novice, elite, architect]) => (
              <div key={label} className="grid grid-cols-[1.8fr_1fr_1fr_1fr] gap-px bg-[#111111] text-sm text-zinc-300">
                <div className="bg-[#141414] px-4 py-4 text-left text-white">{label}</div>
                <div className="bg-[#111111] px-4 py-4">{novice}</div>
                <div className="bg-[#111111] px-4 py-4">{elite}</div>
                <div className="bg-[#111111] px-4 py-4">{architect}</div>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  )
}

export default Pricing
