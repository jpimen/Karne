import { Link } from 'react-router-dom'

function Home() {
  return (
    <div className="min-h-screen bg-bg text-white">
      <div className="mx-auto max-w-7xl px-6 py-10">
        <header className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <p className="text-sm uppercase tracking-[0.4em] text-zinc-400">Iron Architect</p>
            <div className="mt-3 flex items-center gap-3">
              <span className="text-3xl font-black uppercase tracking-[0.35em] text-white">Engineered for performance.</span>
            </div>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <Link to="/features" className="rounded-full border border-zinc-700 bg-zinc-900 px-5 py-3 text-sm uppercase tracking-[0.25em] text-zinc-200 transition hover:border-gold hover:text-gold">
              Features
            </Link>
            <Link to="/pricing" className="rounded-full bg-gold px-5 py-3 text-sm font-bold uppercase tracking-[0.25em] text-black transition hover:bg-yellow-500">
              Pricing
            </Link>
            <Link to="/app" className="rounded-full border border-gold px-5 py-3 text-sm uppercase tracking-[0.25em] text-gold transition hover:bg-zinc-900">
              Launch App
            </Link>
          </div>
        </header>

        <main className="mt-16 grid gap-16 lg:grid-cols-[1.3fr_0.9fr] lg:items-center">
          <section className="space-y-8">
            <span className="text-xs uppercase tracking-[0.5em] text-gold">Version 4.0 Elite Only</span>
            <div className="space-y-6">
              <h1 className="text-5xl font-black uppercase leading-tight tracking-[-0.04em] text-white sm:text-6xl">
                Engineer your <span className="text-gold">elite</span> performance.
              </h1>
              <p className="max-w-2xl text-base leading-8 text-zinc-300 sm:text-lg">
                A brutalist training architecture designed for those who treat performance as an engineering challenge. No fluff. No emojis. Just hard data and heavy iron.
              </p>
            </div>
            <div className="flex flex-wrap gap-4">
              <Link to="/app" className="rounded-3xl bg-gold px-8 py-4 text-sm font-bold uppercase tracking-[0.2em] text-black transition hover:bg-yellow-500">
                Get Started
              </Link>
              <Link to="/features" className="rounded-3xl border border-zinc-700 px-8 py-4 text-sm uppercase tracking-[0.2em] text-white transition hover:border-gold">
                View Schematics
              </Link>
            </div>
          </section>

          <article className="overflow-hidden rounded-[2rem] border border-zinc-800 bg-[#191919] p-6 shadow-xl">
            <div className="flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p className="text-xs uppercase tracking-[0.4em] text-zinc-400">The spreadsheet advantage</p>
                <h2 className="mt-3 text-2xl font-bold uppercase tracking-[-0.02em] text-white">System architecture</h2>
              </div>
              <span className="rounded-full bg-zinc-900 px-4 py-2 text-xs uppercase tracking-[0.3em] text-gold">Built for the brutalist</span>
            </div>
            <div className="mt-8 grid gap-6 sm:grid-cols-2">
              <div className="rounded-3xl border border-zinc-800 bg-bg p-5">
                <p className="text-sm uppercase tracking-[0.3em] text-zinc-400">Cell-based programming</p>
                <p className="mt-4 text-sm text-zinc-300">Rapid entry system for complex RPE and percentage-based loading.</p>
              </div>
              <div className="rounded-3xl border border-zinc-800 bg-bg p-5">
                <p className="text-sm uppercase tracking-[0.3em] text-zinc-400">Custom logic engines</p>
                <p className="mt-4 text-sm text-zinc-300">Inject your own formulas to automate progression logic across phases.</p>
              </div>
            </div>
            <div className="mt-8 rounded-[1.75rem] bg-[#111111] p-6">
              <div className="grid gap-4 sm:grid-cols-3">
                {['Exercise', 'Sets/Reps', 'Load %'].map((item) => (
                  <div key={item} className="rounded-3xl border border-zinc-800 bg-[#121212] p-4 text-center">
                    <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">{item}</p>
                    <p className="mt-3 text-lg font-bold text-white">{item === 'Exercise' ? 'Low-bar squat' : item === 'Sets/Reps' ? '5 x 5' : '82.5%'}</p>
                  </div>
                ))}
              </div>
            </div>
          </article>
        </main>

        <section className="mt-20 grid gap-6 lg:grid-cols-[1fr_0.9fr]">
          <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
            <p className="text-sm uppercase tracking-[0.4em] text-zinc-400">Data-dense analytics</p>
            <h2 className="mt-4 text-3xl font-black uppercase tracking-[-0.04em] text-white">Visualizing human potential through math</h2>
            <div className="mt-10 grid gap-4 sm:grid-cols-2">
              <div className="rounded-3xl bg-[#151515] p-6">
                <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">Velocity loss thresholds</p>
                <p className="mt-4 text-3xl font-bold text-gold">0.84 m/s</p>
                <div className="mt-4 h-3 rounded-full bg-zinc-800">
                  <div className="h-3 rounded-full bg-gold" style={{ width: '72%' }} />
                </div>
              </div>
              <div className="rounded-3xl bg-[#151515] p-6">
                <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">Recovery index</p>
                <p className="mt-4 text-5xl font-black text-white">94%</p>
                <p className="mt-2 text-sm text-zinc-300">Optimal performance state detected</p>
              </div>
            </div>
          </div>

          <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
            <div className="grid gap-4">
              <div className="rounded-3xl bg-[#151515] p-6">
                <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">Latest personal records</p>
                <div className="mt-6 grid gap-4 sm:grid-cols-2">
                  <div>
                    <p className="text-sm uppercase tracking-[0.3em] text-zinc-400">Squat</p>
                    <p className="mt-2 text-2xl font-bold text-white">245 kg</p>
                  </div>
                  <div>
                    <p className="text-sm uppercase tracking-[0.3em] text-zinc-400">Bench press</p>
                    <p className="mt-2 text-2xl font-bold text-white">160 kg</p>
                  </div>
                </div>
              </div>
              <div className="rounded-3xl bg-[#151515] p-6">
                <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">Weekly volume intensity</p>
                <div className="mt-6 h-40 rounded-3xl bg-zinc-900" />
              </div>
            </div>
          </div>
        </section>

        <section className="mt-20 rounded-[2rem] bg-gold p-12 text-center text-black shadow-xl">
          <h2 className="text-4xl font-black uppercase tracking-[-0.04em]">Reconstruct your limits</h2>
          <p className="mx-auto mt-4 max-w-2xl text-sm uppercase tracking-[0.4em] text-zinc-950">Join the architects.</p>
          <Link to="/app" className="mt-8 inline-block rounded-3xl bg-black px-10 py-4 text-sm font-bold uppercase tracking-[0.2em] text-gold transition hover:bg-zinc-900">
            Enter the Laboratory
          </Link>
        </section>
      </div>
    </div>
  )
}

export default Home
