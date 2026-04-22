import { useEffect, useMemo, useState } from 'react'
import { AppShell } from '../components'

const intensityOrder = ['PEAK', 'HIGH', 'MED', 'MAX', 'LOW']

const sampleAthletes = [
  {
    id: 'athlete-1',
    name: 'ALEX THOMPSON',
    level: 'ELITE',
    focus: 'POWERLIFTING',
    avatar: 'AT',
  },
  {
    id: 'athlete-2',
    name: 'SARAH KIM',
    level: 'ADVANCED',
    focus: 'OLYMPIC WEIGHTLIFTING',
    avatar: 'SK',
  },
  {
    id: 'athlete-3',
    name: 'MIKE RODRIGUEZ',
    level: 'INTERMEDIATE',
    focus: 'BODYBUILDING',
    avatar: 'MR',
  },
  {
    id: 'athlete-4',
    name: 'JENNA LEE',
    level: 'BEGINNER',
    focus: 'GENERAL FITNESS',
    avatar: 'JL',
  },
]

const sampleRows = [
  {
    id: 'row-1',
    exercise: 'BARBELL BACK SQUAT (HIGH BAR)',
    sets: 4,
    reps: 8,
    load: '75% 1RM',
    rpe: 8,
    intensity: 'PEAK',
    rest: 180,
    notes: 'TEMPO 3-1-1...',
  },
  {
    id: 'row-2',
    exercise: 'ROMANIAN DEADLIFT',
    sets: 3,
    reps: 12,
    load: '140 KG',
    rpe: 7,
    intensity: 'MED',
    rest: 90,
    notes: 'NO STRAPS I...',
  },
  {
    id: 'row-3',
    exercise: 'LEG PRESS (NEUTRAL STANCE)',
    sets: 3,
    reps: 15,
    load: 'MAX LOAD',
    rpe: 9,
    intensity: 'HIGH',
    rest: 120,
    notes: 'CONSTANT TE...',
  },
  {
    id: 'row-4',
    exercise: 'SEATED CALF RAISES',
    sets: 5,
    reps: 20,
    load: '60 KG',
    rpe: 10,
    intensity: 'MAX',
    rest: 60,
    notes: 'STRETCH AT...',
  },
  {
    id: 'row-5',
    exercise: 'LEG CURLS (LYING)',
    sets: 4,
    reps: 12,
    load: '65 KG',
    rpe: 8,
    intensity: 'MED',
    rest: 90,
    notes: 'DROP SET ON...',
  },
]

const noteOptions = [
  'TEMPO 3-1-1...',
  'NO STRAPS I...',
  'CONSTANT TE...',
  'STRETCH AT...',
  'DROP SET ON...',
  'FOCUS ON POSITION',
  'ACCELERATE THROUGH LOCKOUT',
  'PAUSE AT BOTTOM',
]

const columnOptions = [
  { value: 'exercise', label: 'EXERCISE', width: 'min-w-[250px]' },
  { value: 'sets', label: 'SETS', width: 'w-[90px]' },
  { value: 'reps', label: 'REPS', width: 'w-[90px]' },
  { value: 'load', label: 'LOAD (%/KG)', width: 'min-w-[150px]' },
  { value: 'rpe', label: 'RPE', width: 'w-[90px]' },
  { value: 'intensity', label: 'INTENSITY', width: 'w-[130px]' },
  { value: 'rest', label: 'REST (S)', width: 'w-[110px]' },
  { value: 'notes', label: 'NOTES', width: 'min-w-[320px]' },
]

const emptyRow = (index) => ({
  id: `empty-${Date.now()}-${index}`,
  exercise: '',
  sets: '',
  reps: '',
  load: '',
  rpe: '',
  intensity: 'LOW',
  rest: '',
  notes: '',
})

const initialWeeks = [
  {
    title: 'WEEK 1',
    days: [
      { title: 'DAY 1', rows: [...sampleRows, ...Array.from({ length: 10 }, (_, index) => emptyRow(index + 1))] },
      { title: 'DAY 2', rows: Array.from({ length: 15 }, (_, index) => emptyRow(index + 1)) },
      { title: 'DAY 3', rows: Array.from({ length: 15 }, (_, index) => emptyRow(index + 1)) },
      { title: 'DAY 4', rows: Array.from({ length: 15 }, (_, index) => emptyRow(index + 1)) },
    ],
  },
  {
    title: 'WEEK 2',
    days: Array.from({ length: 4 }, (_, i) => ({
      title: `DAY ${i + 1}`,
      rows: Array.from({ length: 15 }, (_, index) => emptyRow(index + 1)),
    })),
  },
  {
    title: 'WEEK 3',
    days: Array.from({ length: 4 }, (_, i) => ({
      title: `DAY ${i + 1}`,
      rows: Array.from({ length: 15 }, (_, index) => emptyRow(index + 1)),
    })),
  },
]

function parseLoadToKg(load) {
  if (!load) return 0
  const kgMatch = load.match(/([0-9]+(?:\.[0-9]+)?)\s*kg/i)
  if (kgMatch) return parseFloat(kgMatch[1])
  const percentMatch = load.match(/([0-9]+(?:\.[0-9]+)?)\s*%/)
  if (percentMatch) return parseFloat(percentMatch[1])
  const numberMatch = load.match(/([0-9]+(?:\.[0-9]+)?)/)
  return numberMatch ? parseFloat(numberMatch[1]) : 0
}

function ProgramBuilder() {
  const [mode, setMode] = useState('select') // 'select' or 'build'
  const [selectedAthlete, setSelectedAthlete] = useState(null)
  const [programName, setProgramName] = useState('HYPERTROPHY LAB PHASE 01')
  const [programDetails, setProgramDetails] = useState({
    level: 'ELITE',
    focus: 'POWERLIFTING',
    duration: '12 WEEKS',
    frequency: '5 DAYS / WEEK',
  })
  const [weeks, setWeeks] = useState(initialWeeks)
  const [activeWeek, setActiveWeek] = useState(0)
  const [activeDay, setActiveDay] = useState(0)
  const [selectedRowId, setSelectedRowId] = useState('row-1')
  const [customColumns, setCustomColumns] = useState([])
  const [columnHeaders, setColumnHeaders] = useState(columnOptions)
  const [fontSize, setFontSize] = useState(12)
  const [toast, setToast] = useState('')

  useEffect(() => {
    if (!toast) return undefined
    const timer = window.setTimeout(() => setToast(''), 2400)
    return () => window.clearTimeout(timer)
  }, [toast])

  const activeWeekData = weeks[activeWeek]
  const activeDayData = activeWeekData.days[activeDay]

  const getGlobalDayNumber = (weekIdx, dayIdx) => {
    let dayCount = 0
    for (let i = 0; i < weekIdx; i++) {
      dayCount += weeks[i].days.length
    }
    return dayCount + dayIdx + 1
  }

  const updateCell = (rowId, field, value) => {
    setWeeks((prev) =>
      prev.map((week, weekIndex) => {
        if (weekIndex !== activeWeek) return week
        return {
          ...week,
          days: week.days.map((day, dayIndex) => {
            if (dayIndex !== activeDay) return day
            return {
              ...day,
              rows: day.rows.map((row) => (row.id === rowId ? { ...row, [field]: value } : row)),
            }
          }),
        }
      }),
    )
  }

  const selectedRowIndex = activeDayData.rows.findIndex((row) => row.id === selectedRowId)

  const addRow = (position = 'bottom') => {
    setWeeks((prev) =>
      prev.map((week, weekIndex) => {
        if (weekIndex !== activeWeek) return week
        return {
          ...week,
          days: week.days.map((day, dayIndex) => {
            if (dayIndex !== activeDay) return day
            const rows = [...day.rows]
            const newRow = emptyRow(rows.length + 1)
            if (position === 'above' && selectedRowIndex !== -1) {
              rows.splice(selectedRowIndex, 0, newRow)
            } else if (position === 'below' && selectedRowIndex !== -1) {
              rows.splice(selectedRowIndex + 1, 0, newRow)
            } else {
              rows.push(newRow)
            }
            return { ...day, rows }
          }),
        }
      }),
    )
    setSelectedRowId(`empty-${Date.now()}-added`)
  }

  const deleteSelectedRow = () => {
    if (selectedRowIndex === -1) return
    setWeeks((prev) =>
      prev.map((week, weekIndex) => {
        if (weekIndex !== activeWeek) return week
        return {
          ...week,
          days: week.days.map((day, dayIndex) => {
            if (dayIndex !== activeDay) return day
            return { ...day, rows: day.rows.filter((row) => row.id !== selectedRowId) }
          }),
        }
      }),
    )
    setSelectedRowId(activeDayData.rows[0]?.id || '')
  }

  const addNewCycle = () => {
    setWeeks((prev) => {
      const nextWeeks = [
        ...prev,
        {
          title: `WEEK ${prev.length + 1}`,
          days: Array.from({ length: 4 }, (_, i) => {
            const globalDayIdx = prev.reduce((sum, w) => sum + w.days.length, 0) + i + 1
            return {
              title: `DAY ${globalDayIdx}`,
              rows: Array.from({ length: 15 }, (_, index) => emptyRow(index + 1)),
            }
          }),
        },
      ]
      setActiveWeek(nextWeeks.length - 1)
      setActiveDay(0)
      return nextWeeks
    })
    setToast('Week added')
  }

  const addNewDay = () => {
    setWeeks((prev) =>
      prev.map((week, index) => {
        if (index !== activeWeek) return week
        const globalDayIdx = prev.slice(0, index + 1).reduce((sum, w) => sum + w.days.length, 0) + 1
        const nextDays = [
          ...week.days,
          {
            title: `DAY ${globalDayIdx}`,
            rows: Array.from({ length: 15 }, (_, index) => emptyRow(index + 1)),
          },
        ]
        return { ...week, days: nextDays }
      }),
    )
    setActiveDay(weeks[activeWeek].days.length)
    setToast('Day added')
  }

  const deleteWeek = () => {
    if (weeks.length <= 1) {
      setToast('At least one week is required')
      return
    }

    setWeeks((prev) => {
      const nextWeeks = prev.filter((_, index) => index !== activeWeek)
      const nextActive = Math.max(0, Math.min(activeWeek, nextWeeks.length - 1))
      setActiveWeek(nextActive)
      setActiveDay(0)
      return nextWeeks
    })
    setToast('Week deleted')
  }

  const deleteDay = () => {
    if (weeks[activeWeek].days.length <= 1) {
      setToast('At least one day is required')
      return
    }

    setWeeks((prev) => {
      const weekToUpdate = prev[activeWeek]
      const nextDays = weekToUpdate.days.filter((_, idx) => idx !== activeDay)
      const nextWeeks = prev.map((week, index) =>
        index === activeWeek ? { ...week, days: nextDays } : week,
      )

      const nextActiveDay = Math.max(0, Math.min(activeDay, nextDays.length - 1))
      setActiveDay(nextActiveDay)
      return nextWeeks
    })
    setToast('Day deleted')
  }

  const addColumn = () => {
    const nextIndex = customColumns.length + 1
    const defaultOption = columnOptions[0] // Use first option as default
    const newColumn = { ...defaultOption, id: `custom-${nextIndex}` }
    setCustomColumns((prev) => [...prev, newColumn])
    setWeeks((prev) =>
      prev.map((week) => ({
        ...week,
        days: week.days.map((day) => ({
          ...day,
          rows: day.rows.map((row) => ({ ...row, [newColumn.id]: '' })),
        })),
      })),
    )
    setToast(`${newColumn.label} added`)
  }

  const updateCustomHeaderField = (index, value) => {
    const selectedOption = columnOptions.find((option) => option.value === value)
    if (!selectedOption) return
    setCustomColumns((prev) =>
      prev.map((column, idx) => (idx === index ? { ...selectedOption, id: column.id } : column)),
    )
  }

  const updateHeaderField = (index, value) => {
    const selectedOption = columnOptions.find((option) => option.value === value)
    if (!selectedOption) return
    setColumnHeaders((prev) =>
      prev.map((column, idx) => (idx === index ? { ...selectedOption } : column)),
    )
  }

  const renderHeaderTitle = (field, idx) => {
    const option = columnOptions.find((option) => option.value === field)
    const prefix = String.fromCharCode(65 + idx)
    return option ? `${prefix}: ${option.label}` : `${prefix}: ${field.toUpperCase()}`
  }

  const renderCellByField = (column, row, rowId) => {
    const field = column.id || column.value // Use id for custom columns, value for main columns
    const fieldType = column.value

    if (fieldType === 'intensity') {
      return (
        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation()
            cycleIntensity(rowId)
          }}
          className={`rounded-3xl px-4 py-3 text-sm font-bold uppercase tracking-[0.2em] ${
            row.intensity === 'PEAK'
              ? 'bg-gold text-black'
              : row.intensity === 'HIGH'
              ? 'bg-amber-500 text-black'
              : row.intensity === 'MED'
              ? 'bg-zinc-700 text-white'
              : row.intensity === 'MAX'
              ? 'bg-orange-600 text-black'
              : 'bg-[#222222] text-zinc-200'
          }`}
        >
          {row.intensity}
        </button>
      )
    }

    const inputProps = {
      value: row[field] ?? '',
      onChange: (e) => updateCell(rowId, field, e.target.value),
      className: 'w-full rounded-3xl border border-zinc-800 bg-[#111111] px-3 py-3 text-sm text-white',
    }

    if (fieldType === 'notes') {
      return (
        <>
          <input
            list="note-suggestions"
            {...inputProps}
            placeholder="Type note..."
            className="w-full rounded-3xl border border-zinc-800 bg-[#111111] px-4 py-3 text-sm text-white placeholder:text-zinc-500"
          />
          <datalist id="note-suggestions">
            {noteOptions.map((option) => (
              <option key={option} value={option} />
            ))}
          </datalist>
        </>
      )
    }

    if (['sets', 'reps', 'rpe', 'rest'].includes(fieldType)) {
      return <input type="number" min="0" {...inputProps} />
    }

    return <input {...inputProps} />
  }

  const cycleIntensity = (rowId) => {
    const row = activeDayData.rows.find((item) => item.id === rowId)
    if (!row) return
    const nextIndex = (intensityOrder.indexOf(row.intensity) + 1) % intensityOrder.length
    updateCell(rowId, 'intensity', intensityOrder[nextIndex])
  }

  const totalVolume = useMemo(
    () =>
      activeDayData.rows.reduce((sum, row) => {
        const sets = Number(row.sets)
        const reps = Number(row.reps)
        const kg = parseLoadToKg(row.load)
        if (!sets || !reps || !kg) return sum
        return sum + sets * reps * kg
      }, 0),
    [activeDayData.rows],
)

  const estimatedDuration = useMemo(
    () =>
      activeDayData.rows.reduce((sum, row) => {
        const sets = Number(row.sets)
        const rest = Number(row.rest)
        if (!sets) return sum
        return sum + sets * 45 + (rest || 0)
      }, 0),
    [activeDayData.rows],
)

  const saveProgram = () => setToast('Program saved successfully')

  const exportCsv = () => {
    const header = ['Row', 'EXERCISE', 'SETS', 'REPS', 'LOAD (%/KG)', 'RPE', 'INTENSITY', 'REST (S)', 'NOTES']
    const dayTitle = `DAY ${getGlobalDayNumber(activeWeek, activeDay)}`
    const rows = activeDayData.rows.map((row, index) => [
      index + 1,
      row.exercise,
      row.sets,
      row.reps,
      row.load,
      row.rpe,
      row.intensity,
      row.rest,
      row.notes,
    ])
    const csv = [header, ...rows]
      .map((line) => line.map((cell) => `"${String(cell || '').replace(/"/g, '""')}"`).join(','))
      .join('\n')
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = `${activeWeekData.title}_${dayTitle}.csv`
    link.click()
    setToast('Export complete')
  }

  const selectAthlete = (athlete) => {
    setSelectedAthlete(athlete)
    setMode('build')
  }

  const backToSelect = () => {
    setMode('select')
    setSelectedAthlete(null)
  }

  if (mode === 'select') {
    return (
      <AppShell title="Program Builder" subtitle="Select athlete">
        <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-6 shadow-xl">
          <div className="mb-6">
            <h2 className="text-lg font-black uppercase tracking-[0.15em] text-white">SELECT ATHLETE</h2>
            <p className="mt-2 text-sm text-zinc-400">Choose an athlete to build a program for. Each program is tailored to individual performance metrics.</p>
          </div>

          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            {sampleAthletes.map((athlete) => (
              <button
                key={athlete.id}
                onClick={() => selectAthlete(athlete)}
                className="rounded-[1.5rem] border border-zinc-800 bg-[#141414] p-6 text-left transition hover:border-gold hover:bg-[#161616]"
              >
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-gold text-sm font-bold text-black">
                    {athlete.avatar}
                  </div>
                  <div>
                    <p className="text-sm font-bold uppercase tracking-[0.2em] text-white">{athlete.name}</p>
                    <p className="text-xs uppercase tracking-[0.35em] text-zinc-500">{athlete.level}</p>
                  </div>
                </div>
                <p className="mt-4 text-xs uppercase tracking-[0.35em] text-zinc-400">{athlete.focus}</p>
              </button>
            ))}
          </div>

          <div className="mt-8 rounded-3xl bg-[#141414] p-5">
            <p className="text-xs uppercase tracking-[0.35em] text-zinc-400">Create new athlete</p>
            <p className="mt-2 text-sm text-zinc-300">Add a new athlete profile to the system for program creation.</p>
            <button className="mt-4 rounded-3xl bg-gold px-5 py-3 text-sm font-bold uppercase tracking-[0.2em] text-black transition hover:bg-yellow-500">
              + ADD ATHLETE
            </button>
          </div>
        </div>
      </AppShell>
    )
  }

  return (
    <AppShell title="Program Builder" subtitle="Performance schematic">
      <div className="rounded-[2rem] border border-zinc-800 bg-[#111111] p-6 shadow-xl">
        <div className="mb-6 grid gap-6 xl:grid-cols-[1fr_auto]">
          <div className="space-y-4">
            <div className="flex flex-wrap items-center gap-4">
              <button onClick={backToSelect} className="rounded-3xl border border-zinc-700 bg-[#121212] px-4 py-2 text-sm uppercase tracking-[0.2em] text-zinc-200 hover:border-gold hover:text-gold">
                ← BACK TO ATHLETES
              </button>
              <div>
                <span className="text-xs uppercase tracking-[0.35em] text-gold">ATHLETE</span>
                <span className="ml-2 text-lg font-black uppercase tracking-[0.15em] text-white">{selectedAthlete?.name}</span>
              </div>
            </div>
            <div className="flex flex-wrap items-center gap-4">
              <span className="text-xs uppercase tracking-[0.35em] text-gold">PROGRAM NAME</span>
              <input
                value={programName}
                onChange={(e) => setProgramName(e.target.value)}
                className="min-w-[220px] rounded-3xl border border-zinc-800 bg-[#111111] px-4 py-3 text-lg font-black uppercase tracking-[0.15em] text-white outline-none placeholder:text-zinc-500"
                placeholder="ENTER PROGRAM NAME"
              />
            </div>
            <div className="grid gap-4 sm:grid-cols-3 xl:grid-cols-4">
              {[
                { label: 'LEVEL', name: 'level' },
                { label: 'FOCUS', name: 'focus' },
                { label: 'DURATION', name: 'duration' },
                { label: 'FREQUENCY', name: 'frequency' },
              ].map((item) => (
                <div key={item.label} className="rounded-3xl bg-[#121212] p-4">
                  <p className="text-[10px] uppercase tracking-[0.35em] text-zinc-500">{item.label}</p>
                  <input
                    value={programDetails[item.name]}
                    onChange={(e) => setProgramDetails((prev) => ({ ...prev, [item.name]: e.target.value }))}
                    className="mt-2 w-full rounded-3xl border border-zinc-800 bg-[#111111] px-4 py-3 text-sm font-semibold uppercase tracking-[0.15em] text-white outline-none placeholder:text-zinc-500"
                    placeholder={item.label}
                  />
                </div>
              ))}
            </div>
          </div>

          <div className="flex flex-col items-start gap-3 sm:items-end">
            <button onClick={saveProgram} className="rounded-3xl bg-gold px-6 py-3 text-sm font-bold uppercase tracking-[0.2em] text-black transition hover:bg-yellow-500">
              SAVE PROGRAM
            </button>
            <button onClick={exportCsv} className="rounded-3xl border border-zinc-700 bg-[#121212] px-6 py-3 text-sm uppercase tracking-[0.2em] text-zinc-200 transition hover:border-gold hover:text-gold">
              EXPORT TO CSV
            </button>
          </div>
        </div>

        <div className="mb-6 overflow-hidden rounded-[2rem] border border-zinc-800 bg-[#121212] p-5">
          <div className="flex w-full items-center gap-3 overflow-hidden">
            <div className="min-w-0 overflow-x-auto">
              <div className="flex min-w-max items-center gap-3 text-sm uppercase tracking-[0.25em] text-zinc-300">
                <span className="rounded-3xl border border-zinc-700 bg-[#111111] px-4 py-3">ROW ACTIONS</span>
                <button onClick={() => addRow('above')} className="rounded-3xl border border-zinc-700 bg-[#111111] px-4 py-3 text-sm uppercase tracking-[0.2em] text-zinc-200 hover:border-gold hover:text-gold">ABOVE</button>
                <button onClick={() => addRow('below')} className="rounded-3xl border border-zinc-700 bg-[#111111] px-4 py-3 text-sm uppercase tracking-[0.2em] text-zinc-200 hover:border-gold hover:text-gold">BELOW</button>
                <button onClick={deleteSelectedRow} className="rounded-3xl border border-zinc-700 bg-[#111111] px-4 py-3 text-sm uppercase tracking-[0.2em] text-zinc-200 hover:border-red-500 hover:text-red-400">DELETE</button>
                <button onClick={addColumn} className="rounded-3xl border border-zinc-700 bg-[#111111] px-4 py-3 text-sm uppercase tracking-[0.2em] text-zinc-200 hover:border-gold hover:text-gold">ADD COLUMN</button>
              </div>
            </div>
          </div>
          <div className="mt-4 overflow-x-auto border-b border-zinc-800 pb-4 pt-4">
            <div className="flex min-w-max items-center justify-between gap-3">
              <div className="flex gap-3 text-sm uppercase tracking-[0.25em]">
                {weeks.map((week, index) => (
                  <button
                    key={week.title}
                    onClick={() => {
                      setActiveWeek(index)
                      setActiveDay(0)
                    }}
                    className={`rounded-full px-5 py-3 transition ${
                      index === activeWeek ? 'bg-[#161616] text-gold ring-1 ring-gold' : 'bg-[#111111] text-zinc-400 hover:bg-[#1c1c1c]'
                    }`}
                  >
                    {week.title}
                  </button>
                ))}
              </div>
              <div className="flex items-center gap-3">
                <button onClick={addNewCycle} className="rounded-3xl bg-gold px-5 py-3 text-sm font-bold uppercase tracking-[0.2em] text-black transition hover:bg-yellow-500">ADD</button>
                <button onClick={deleteWeek} className="rounded-3xl border border-zinc-700 bg-[#111111] px-5 py-3 text-sm uppercase tracking-[0.2em] text-zinc-200 transition hover:border-red-500 hover:text-red-400">DELETE</button>
              </div>
            </div>
          </div>

          <div className="mt-4 overflow-x-auto pt-4">
            <div className="flex min-w-max items-center justify-between gap-3">
              <div className="flex items-center gap-3 text-sm uppercase tracking-[0.25em]">
                {activeWeekData.days.map((day, index) => (
                  <button
                    key={`${activeWeek}-${index}`}
                    onClick={() => setActiveDay(index)}
                    className={`rounded-full px-5 py-3 transition ${
                      index === activeDay ? 'bg-[#161616] text-gold ring-1 ring-gold' : 'bg-[#111111] text-zinc-400 hover:bg-[#1c1c1c]'
                    }`}
                  >
                    DAY {getGlobalDayNumber(activeWeek, index)}
                  </button>
                ))}
              </div>
              <div className="flex items-center gap-3">
                <button onClick={addNewDay} className="rounded-3xl bg-gold px-5 py-3 text-sm font-bold uppercase tracking-[0.2em] text-black transition hover:bg-yellow-500">ADD</button>
                <button onClick={deleteDay} className="rounded-3xl border border-zinc-700 bg-[#111111] px-5 py-3 text-sm uppercase tracking-[0.2em] text-zinc-200 transition hover:border-red-500 hover:text-red-400">DELETE</button>
              </div>
            </div>
          </div>

          <div className="overflow-x-auto max-w-full">
            <table className="min-w-full w-full border-separate border-spacing-0 text-sm" style={{ fontSize: `${fontSize}px` }}>
              <thead>
                <tr className="text-left text-[11px] uppercase tracking-[0.38em] text-zinc-500">
                  <th className="w-[48px] border-b border-zinc-800 px-3 py-3">#</th>
                  {columnHeaders.map((header, index) => (
                    <th key={`${header.value}-${index}`} className={`${header.width} border-b border-zinc-800 px-3 py-3`}>
                      <select
                        value={header.value}
                        onChange={(e) => updateHeaderField(index, e.target.value)}
                        className="w-full appearance-none bg-[#111111] px-3 py-3 text-left text-sm text-white outline-none"
                      >
                        {columnOptions.map((option) => (
                          <option key={option.value} value={option.value} className="bg-[#111111] text-white">
                            {option.label}
                          </option>
                        ))}
                      </select>
                    </th>
                  ))}
                  {customColumns.map((column, index) => (
                    <th key={column.id} className={`${column.width} border-b border-zinc-800 px-3 py-3`}>
                      <select
                        value={column.value}
                        onChange={(e) => updateCustomHeaderField(index, e.target.value)}
                        className="w-full appearance-none bg-[#111111] px-3 py-3 text-left text-sm text-white outline-none"
                      >
                        {columnOptions.map((option) => (
                          <option key={option.value} value={option.value} className="bg-[#111111] text-white">
                            {option.label}
                          </option>
                        ))}
                      </select>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {activeDayData.rows.map((row, rowIndex) => {
                  const isSelected = row.id === selectedRowId
                  return (
                    <tr
                      key={row.id}
                      onClick={() => setSelectedRowId(row.id)}
                      className={`${isSelected ? 'border border-gold bg-[#161616]' : 'border-b border-zinc-800 bg-[#111111]'} cursor-pointer transition hover:bg-[#1a1a1a]`}
                    >
                      <td className="px-3 py-4 text-zinc-500">{rowIndex + 1}</td>
                      {columnHeaders.map((header) => (
                        <td key={`${row.id}-${header.value}`} className={`${header.width} px-3 py-3`}>
                          <div className="min-w-full">
                            {renderCellByField(header, row, row.id)}
                          </div>
                        </td>
                      ))}
                      {customColumns.map((column) => (
                        <td key={column.id} className={`${column.width} px-3 py-3`}>
                          <div className="min-w-full">
                            {renderCellByField(column, row, row.id)}
                          </div>
                        </td>
                      ))}
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </div>

        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex flex-wrap gap-3">
            <button onClick={() => addRow('bottom')} className="rounded-3xl bg-gold px-6 py-3 text-sm font-bold uppercase tracking-[0.2em] text-black transition hover:bg-yellow-500">
              + ADD ROW
            </button>
            <button onClick={() => setToast('Day duplicated')} className="rounded-3xl border border-zinc-700 bg-[#121212] px-6 py-3 text-sm uppercase tracking-[0.2em] text-zinc-200 transition hover:border-gold hover:text-gold">
              DUPLICATE DAY
            </button>
          </div>

          <div className="grid gap-3 text-right text-sm uppercase tracking-[0.2em] text-zinc-400 sm:text-left">
            <div className="text-zinc-300">TOTAL VOLUME</div>
            <div className="text-2xl font-black uppercase tracking-[0.05em] text-gold">{totalVolume.toLocaleString()} KG</div>
            <div className="text-zinc-300">ESTIMATED DURATION</div>
            <div className="text-2xl font-black uppercase tracking-[0.05em] text-gold">{estimatedDuration} MIN</div>
          </div>
        </div>
      </div>

      {toast ? (
        <div className="pointer-events-none fixed bottom-6 right-6 rounded-3xl bg-[#111111] px-5 py-4 text-sm font-semibold uppercase tracking-[0.2em] text-gold shadow-2xl border border-zinc-800">
          {toast}
        </div>
      ) : null}
    </AppShell>
  )
}

export default ProgramBuilder
