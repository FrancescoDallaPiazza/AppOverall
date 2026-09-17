import { useState } from 'react'
import { supabase, LIMITE } from '../supabase'
import { useVista, Errore, Vuoto } from '../componenti/comuni'
import TabellaScadenze from '../componenti/TabellaScadenze'
import type { Scadenza, Stato } from '../tipi'

type Filtro = { chiave: string; etichetta: string; stati: Stato[] }

const FILTRI: Filtro[] = [
  { chiave: 'da_sollecitare', etichetta: 'da sollecitare', stati: ['scaduto', 'in_scadenza'] },
  { chiave: 'scaduto', etichetta: 'scadute', stati: ['scaduto'] },
  { chiave: 'in_scadenza', etichetta: 'in scadenza', stati: ['in_scadenza'] },
  { chiave: 'mancante', etichetta: 'mancanti', stati: ['mancante'] },
  { chiave: 'incompleto', etichetta: 'da completare', stati: ['incompleto', 'in_corso'] },
  { chiave: 'valido', etichetta: 'valide', stati: ['valido', 'non_scade'] },
]

/** Le scadenze di tutti i clienti, filtrate sul database: sono migliaia. */
export default function Scadenze() {
  const [filtro, setFiltro] = useState<Filtro>(FILTRI[0])
  const [tipo, setTipo] = useState<'tutti' | 'formazione' | 'sorveglianza'>('tutti')
  const [cerca, setCerca] = useState('')
  const [cercaAttiva, setCercaAttiva] = useState('')

  const { righe, errore, caricando } = useVista<Scadenza>(() => {
    let q = supabase.from('v_scadenzario').select('*').in('stato', filtro.stati)
    if (tipo !== 'tutti') q = q.eq('tipo', tipo)
    const t = cercaAttiva.trim().replace(/[,()]/g, ' ')
    if (t) q = q.or(`ragione_sociale.ilike.*${t}*,cognome.ilike.*${t}*,nome.ilike.*${t}*,corso_nome.ilike.*${t}*`)
    return q.order('scadenza', { ascending: true, nullsFirst: false }).order('ragione_sociale').limit(LIMITE)
  }, [filtro.chiave, tipo, cercaAttiva])

  if (errore) return <Errore testo={errore} />

  return (
    <section>
      <header className="testata">
        <div>
          <h1>Scadenze</h1>
          <p className="sottotitolo">
            Formazione e visite mediche di tutti i clienti. «Da sollecitare» sono le scadute
            e quelle entro il preavviso: 180 giorni per la formazione, 90 per l'RLS, 60 per le visite.
          </p>
        </div>
        <form onSubmit={(e) => { e.preventDefault(); setCercaAttiva(cerca) }}>
          <input className="cerca" placeholder="Cliente, persona o corso (Invio)"
                 value={cerca} onChange={(e) => setCerca(e.target.value)} />
        </form>
      </header>

      <div className="filtri">
        {FILTRI.map((f) => (
          <button key={f.chiave} className={filtro.chiave === f.chiave ? 'attivo' : ''} onClick={() => setFiltro(f)}>
            {f.etichetta}
          </button>
        ))}
        <span className="spinta" />
        {(['tutti', 'formazione', 'sorveglianza'] as const).map((t) => (
          <button key={t} className={tipo === t ? 'attivo' : ''} onClick={() => setTipo(t)}>
            {t === 'tutti' ? 'formazione e visite' : t === 'formazione' ? 'solo formazione' : 'solo visite'}
          </button>
        ))}
      </div>

      {caricando ? <Vuoto>Carico…</Vuoto> : righe.length === 0 ? <Vuoto>Nessuna scadenza con questi filtri.</Vuoto> : (
        <>
          {righe.length >= LIMITE && (
            <p className="nota">Mostrate le prime {LIMITE}: restringere con la ricerca o con un filtro.</p>
          )}
          <TabellaScadenze righe={righe} conCliente />
        </>
      )}
    </section>
  )
}
