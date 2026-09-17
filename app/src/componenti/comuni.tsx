import { useEffect, useState, type ReactNode } from 'react'
import type { EsitoLivello, Stato } from '../tipi'

/** Una lettura dal database, con lo stato di caricamento e l'errore in chiaro. */
export function useVista<T>(
  costruisci: () => PromiseLike<{ data: unknown; error: { message: string } | null }>,
  dipendenze: unknown[] = []
) {
  const [righe, setRighe] = useState<T[]>([])
  const [errore, setErrore] = useState<string | null>(null)
  const [caricando, setCaricando] = useState(true)
  const [giro, setGiro] = useState(0)

  useEffect(() => {
    let vivo = true
    setCaricando(true)
    setErrore(null)
    costruisci().then(({ data, error }) => {
      if (!vivo) return
      if (error) setErrore(error.message)
      setRighe((data as T[]) ?? [])
      setCaricando(false)
    })
    return () => { vivo = false }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...dipendenze, giro])

  return { righe, errore, caricando, ricarica: () => setGiro((g) => g + 1) }
}

const ETICHETTE: Record<Stato, string> = {
  valido: 'valido',
  in_scadenza: 'in scadenza',
  scaduto: 'scaduto',
  mancante: 'mancante',
  incompleto: 'incompleto',
  in_corso: 'in corso',
  non_scade: 'non scade',
  senza_regola: 'senza regola',
}

export function Pastiglia({ stato }: { stato: Stato }) {
  return <span className={`pastiglia ${stato}`}>{ETICHETTE[stato] ?? stato}</span>
}

const LIVELLO: Record<EsitoLivello, string> = {
  livello_non_definito: 'livello non definito',
  conforme: 'livello ok',
  non_conforme: 'livello insufficiente',
}

/** Il confronto della decisione 11, accanto allo stato: non lo sostituisce. */
export function Livello({ esito, richiesto }: { esito: EsitoLivello | null; richiesto?: string | null }) {
  if (!esito) return null
  return (
    <span className={`livello ${esito}`} title={richiesto ? `richiesto dalla sede: ${richiesto}` : 'la sede non ha un livello'}>
      {LIVELLO[esito]}
    </span>
  )
}

export function data(v: string | null | undefined) {
  if (!v) return '—'
  const [a, m, g] = v.slice(0, 10).split('-')
  return `${g}/${m}/${a}`
}

/** Zero non si scrive: una colonna piena di zeri nasconde i numeri che contano. */
export function conteggio(v: number | null | undefined) {
  return v ? String(v) : ''
}

export function Vuoto({ children }: { children: ReactNode }) {
  return <p className="vuoto">{children}</p>
}

export function Errore({ testo }: { testo: string }) {
  return (
    <div className="riquadro-errore">
      <strong>Il database ha risposto con un errore.</strong>
      <p>{testo}</p>
      <p className="nota">
        Se la lista e vuota e non c'e errore, sono le policy a dirlo: l'utente non ha una
        riga attiva in <code>operatore</code>.
      </p>
    </div>
  )
}

export function giorni(v: number | null | undefined) {
  if (v === null || v === undefined) return '—'
  if (v < 0) return `${-v} fa`
  return `fra ${v}`
}
