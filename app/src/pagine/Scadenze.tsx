import { useState } from 'react'
import { supabase, LIMITE } from '../supabase'
import { useSessione } from '../sessione'
import { useVista, Errore, Vuoto } from '../componenti/comuni'
import TabellaScadenze from '../componenti/TabellaScadenze'
import { FILTRI_STATO } from './Cliente'
import type { Scadenza } from '../tipi'

/** Le scadenze di tutti i clienti, filtrate e ordinate sul database: sono migliaia. */
export default function Scadenze() {
  const { operatore } = useSessione()
  const [filtro, setFiltro] = useState(FILTRI_STATO[0])
  const [tipo, setTipo] = useState<'tutti' | 'formazione' | 'sorveglianza'>('tutti')
  const [cerca, setCerca] = useState('')
  const [cercaAttiva, setCercaAttiva] = useState('')

  const { righe, errore, caricando } = useVista<Scadenza>(() => {
    let q = supabase.from('v_scadenzario').select('*').in('stato', filtro.stati)
    if (tipo !== 'tutti') q = q.eq('tipo', tipo)
    const t = cercaAttiva.trim().replace(/[,()]/g, ' ')
    if (t) q = q.or(`ragione_sociale.ilike.*${t}*,cognome.ilike.*${t}*,nome.ilike.*${t}*,corso_nome.ilike.*${t}*,obbligo_nome.ilike.*${t}*`)
    return q.order('priorita')
      .order('scadenza', { ascending: true, nullsFirst: false })
      .order('ragione_sociale').order('cognome')
      .limit(LIMITE)
  }, [filtro.chiave, tipo, cercaAttiva])

  if (errore) return <Errore testo={errore} />

  return (
    <section>
      <header className="testata">
        <div>
          <h1>Scadenze</h1>
          <p className="sottotitolo">
            Formazione e visite mediche di tutti i clienti, in ordine di priorita: prima i
            corsi mancanti, poi le scadenze passate dalla piu vecchia, poi quelle entro il
            preavviso (180 giorni per la formazione, 90 per l'RLS, 60 per le visite).
          </p>
        </div>
        <form onSubmit={(e) => { e.preventDefault(); setCercaAttiva(cerca) }}>
          <input className="cerca" placeholder="Cliente, persona, corso o ruolo (Invio)"
                 value={cerca} onChange={(e) => setCerca(e.target.value)} />
        </form>
      </header>

      <div className="filtri">
        {FILTRI_STATO.map((f) => (
          <button key={f.chiave} className={filtro.chiave === f.chiave ? 'attivo' : ''} onClick={() => setFiltro(f)}
                  title={f.chiave === 'da_fare' ? 'Mancanti, scadute, in scadenza e da completare' : undefined}>
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
      <p className="nota filtri-nota">
        «Da fare» raccoglie tutto quello che chiede un'azione: mancanti, scadute, in scadenza e
        da completare. Gli altri filtri mostrano un solo stato.
      </p>

      {caricando ? <Vuoto>Carico…</Vuoto> : righe.length === 0 ? <Vuoto>Nessuna scadenza con questi filtri.</Vuoto> : (
        <>
          {righe.length >= LIMITE && (
            <p className="nota">Mostrate le prime {LIMITE}: restringere con la ricerca o con un filtro.</p>
          )}
          <TabellaScadenze righe={righe} conCliente puoChiudere={(operatore?.livello ?? 0) >= 2} />
        </>
      )}
    </section>
  )
}
