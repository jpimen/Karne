import { Link } from 'react-router-dom'

function Features() {
  return (
    <div className="min-h-screen bg-bg text-white">
      <div className="mx-auto max-w-7xl px-6 py-12">
        <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-gold">Engineering peak performance</p>
            <h1 className="mt-4 text-4xl font-black uppercase tracking-[-0.04em] sm:text-5xl">The gilded laboratory</h1>
          </div>
          <Link to="/" className="rounded-full border border-gold px-5 py-3 uppercase tracking-[0.25em] text-sm text-gold transition hover:bg-zinc-900">
            Back home
          </Link>
        </header>

        <p className="mt-6 max-w-2xl text-sm leading-7 text-zinc-300">A brutalist suite of digital tools designed for the elite athlete. Every gram, every rep, every variable architected for absolute dominance.</p>

        <section className="mt-16 grid gap-10 xl:grid-cols-[0.85fr_1fr]">
          <article className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
            <div className="grid gap-8 lg:grid-cols-[1fr_0.9fr] lg:items-center">
              <div>
                <span className="text-sm uppercase tracking-[0.35em] text-zinc-400">01</span>
                <h2 className="mt-4 text-3xl font-black uppercase tracking-[-0.04em] text-white">Precision program builder</h2>
                <p className="mt-4 text-sm leading-7 text-zinc-300">Discard fragile interfaces. Our spreadsheet-inspired builder allows for hyper-granular programming of RPE, percentage-based loading, and dynamic volume adjustments.</p>
                <ul className="mt-6 space-y-3 text-sm text-zinc-300">
                  <li className="flex items-start gap-3"><span className="mt-1 rounded-full bg-gold px-2 py-1 text-[11px] font-bold uppercase tracking-[0.25em] text-black">✔</span> Dynamic macro-cycle mapping</li>
                  <li className="flex items-start gap-3"><span className="mt-1 rounded-full bg-gold px-2 py-1 text-[11px] font-bold uppercase tracking-[0.25em] text-black">✔</span> RPE-based auto-regulation</li>
                </ul>
              </div>
              <div className="rounded-[2rem] bg-[#151515] p-6">
                <div className="space-y-3 text-sm text-zinc-400">
                  <p className="uppercase tracking-[0.3em]">Exercise</p>
                  <div className="grid gap-3 rounded-3xl bg-[#1f1f1f] p-4">
                    <div className="flex items-center justify-between"><span>Low-bar squat</span><span>5 x 5</span></div>
                    <div className="flex items-center justify-between"><span>Paused bench</span><span>3 x 8</span></div>
                    <div className="flex items-center justify-between"><span>Conventional DL</span><span>1 x 5</span></div>
                  </div>
                </div>
              </div>
            </div>
          </article>

          <article className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
            <div className="grid gap-8">
              <div>
                <span className="text-sm uppercase tracking-[0.35em] text-zinc-400">02</span>
                <h2 className="mt-4 text-3xl font-black uppercase tracking-[-0.04em] text-white">Advanced training log</h2>
                <p className="mt-4 text-sm leading-7 text-zinc-300">Archive every metric. Track CNS readiness, volume intensity, and personal record growth in one polished interface.</p>
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="rounded-3xl bg-[#151515] p-6">
                  <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">Latest personal records</p>
                  <p className="mt-4 text-3xl font-black text-white">245 kg</p>
                  <p className="mt-2 text-sm text-zinc-300">Squat</p>
                </div>
                <div className="rounded-3xl bg-[#151515] p-6">
                  <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">CNS readiness</p>
                  <p className="mt-4 text-5xl font-black text-gold">94%</p>
                  <p className="mt-2 text-sm text-zinc-300">Optimal performance state</p>
                </div>
              </div>
              <div className="rounded-3xl bg-[#151515] p-6">
                <p className="text-xs uppercase tracking-[0.3em] text-zinc-400">Weekly volume intensity</p>
                <div className="mt-6 h-40 rounded-3xl bg-zinc-900" />
              </div>
            </div>
          </article>

          <article className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-8 shadow-xl">
            <div className="lg:flex lg:items-center lg:justify-between lg:gap-8">
              <div>
                <span className="text-sm uppercase tracking-[0.35em] text-zinc-400">03</span>
                <h2 className="mt-4 text-3xl font-black uppercase tracking-[-0.04em] text-white">The armory</h2>
                <p className="mt-4 text-sm leading-7 text-zinc-300">Manage your hardware. Log every barbell, plate, and resistance band in your facility. Your inventory is as accurate as your execution.</p>
              </div>
              <div className="rounded-[2rem] bg-[#151515] p-6">
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="rounded-3xl bg-[#1f1f1f] p-4">
                    <p className="text-xs uppercase tracking-[0.25em] text-zinc-400">Steel plates</p>
                    <p className="mt-2 text-2xl font-bold text-white">1,450 kg</p>
                  </div>
                  <div className="rounded-3xl bg-[#1f1f1f] p-4">
                    <p className="text-xs uppercase tracking-[0.25em] text-zinc-400">Precision bars</p>
                    <p className="mt-2 text-2xl font-bold text-white">8 units</p>
                  </div>
                </div>
              </div>
            </div>
          </article>
        </section>

        <section className="mt-16 rounded-[2rem] bg-gold p-12 text-center text-black shadow-xl">
          <h2 className="text-4xl font-black uppercase tracking-[-0.04em]">Architect your legacy</h2>
          <Link to="/app" className="mt-8 inline-block rounded-3xl bg-black px-10 py-4 text-sm font-bold uppercase tracking-[0.2em] text-gold transition hover:bg-zinc-900">
            Enter the Laboratory
          </Link>
        </section>
      </div>
    </div>
  )
}

export default Features
