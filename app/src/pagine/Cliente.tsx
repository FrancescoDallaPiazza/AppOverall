import { useMemo, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { supabase, LIMITE } from '../supabase'
import { useSessione } from '../sessione'
import { useVista, data, Errore, Vuoto } from '../componenti/comuni'
import TabellaScadenze from '../componenti/TabellaScadenze'
import ElencoPromemoria from '../componenti/ElencoPromemoria'
import type { Promemoria, Scadenza, SintesiCliente, Stato } from '../tipi'

type FiltroStato = { chiave: string; etichetta: string; stati: Stato[] }

/** «Senza regola» non e una scadenza: sta nei promemoria (0029). */
export const FILTRI_STATO: FiltroStato[] = [
  { chiave: 'da_fare', etichetta: 'da fare', stati: ['mancante', 'scaduto', 'in_scadenza', 'incompleto', 'in_corso'] },
  { chiave: 'mancante', etichetta: 'mancanti', stati: ['mancante'] },
  { chiave: 'scaduto', etichetta: 'scadute', stati: ['scaduto'] },
  { chiave: 'in_scadenza', etichetta: 'in scadenza', stati: ['in_scadenza'] },
  { chiave: 'incompleto', etichetta: 'da completare', stati: ['incompleto', 'in_corso'] },
  { chiave: 'valido', etichetta: 'valide', stati: ['valido', 'non_scade'] },
  { chiave: 'tutte', etichetta: 'tutte', stati: ['mancante', 'scaduto', 'in_scadenza', 'incompleto', 'in_corso', 'valido', 'non_scade'] },
]

type Tipo = 'tutti' | 'formazione' | 'sorveglianza'

/** Prima le mancanti, poi le scadute dalla piu vecchia, poi quelle in scadenza (0029). */
export function perPriorita(a: Scadenza, b: Scadenza) {
  return a.priorita - b.priorita
    || (a.scadenza ?? '').localeCompare(b.scadenza ?? '')
    || `${a.cognome} ${a.nome}`.localeCompare(`${b.cognome} ${b.nome}`)
}

/** Come sta questo cliente: le sue scadenze, persona per persona, e i promemoria. */
export default function Cliente() {
  const { id } = useParams()
  const { operatore } = useSessione()
  const [scheda, setScheda] = useState<'scadenze' | 'promemoria'>('scadenze')
  const [filtro, setFiltro] = useState<FiltroStato>(FILTRI_STATO[0])
  const [tipo, setTipo] = useState<Tipo>('tutti')
  const [cerca, setCerca] = useState('')

  const testa = useVista<SintesiCliente>(
    () => supabase.from('v_scadenzario_cliente').select('*').eq('cliente_id', id!), [id])
  const scadenze = useVista<Scadenza>(
    () => supabase.from('v_scadenzario').select('*').eq('cliente_id', id!)
      .neq('stato', 'senza_regola').limit(LIMITE), [id])
  const promemoria = useVista<Promemoria>(
    () => supabase.from('v_promemoria').select('*').eq('cliente_id', id!)
      .order('cognome').limit(LIMITE), [id])

  const righe = useMemo(() => {
    const q = cerca.trim().toLowerCase()
    return scadenze.righe
      .filter((r) => filtro.stati.includes(r.stato))
      .filter((r) => tipo === 'tutti' || r.tipo === tipo)
      .filter((r) => !q
        || `${r.cognome} ${r.nome}`.toLowerCase().includes(q)
        || (r.corso_nome ?? '').toLowerCase().includes(q)
        || (r.obbligo_nome ?? '').toLowerCase().includes(q))
      .sort(perPriorita)
  }, [scadenze.righe, filtro, tipo, cerca])

  const quante = (f: FiltroStato) => scadenze.righe.filter((r) => f.stati.includes(r.stato)).length

  const errore = testa.errore ?? scadenze.errore ?? promemoria.errore
  if (errore) return <Errore testo={errore} />
  const c = testa.righe[0]

  return (
    <section>
      <p className="briciole"><Link to="/">Clienti</Link> /</p>
      <header className="testata">
        <div>
          <h1>{c?.ragione_sociale ?? '…'}</h1>
          <p className="sottotitolo">
            {c?.partita_iva ? `P.IVA ${c.partita_iva} · ` : ''}{c?.persone ?? 0} persone in forza
            {c?.prima_scadenza ? ` · prima scadenza ${data(c.prima_scadenza)}` : ''}
          </p>
        </div>
      </header>

      {c && (
        <div className="cifre">
          <div className="gruppo-cifre">
            <span className="titolo-gruppo">Formazione</span>
            <div className="cifra grave"><span>{c.formazione_mancanti}</span>corsi mancanti</div>
            <div className="cifra scaduta"><span>{c.formazione_scadute}</span>scaduti</div>
            <div className="cifra attesa"><span>{c.formazione_in_scadenza}</span>in scadenza</div>
            <div className="cifra"><span>{c.formazione_da_completare}</span>da completare</div>
          </div>
          <div className="gruppo-cifre">
            <span className="titolo-gruppo">Visite mediche</span>
            <div className="cifra scaduta"><span>{c.visite_scadute}</span>scadute</div>
            <div className="cifra attesa"><span>{c.visite_in_scadenza}</span>in scadenza</div>
          </div>
        </div>
      )}

      <div className="schede">
        <button className={scheda === 'scadenze' ? 'attiva' : ''} onClick={() => setScheda('scadenze')}>
          Scadenze<span className="quanti">{quante(FILTRI_STATO[0])} da fare</span>
        </button>
        <button className={scheda === 'promemoria' ? 'attiva' : ''} onClick={() => setScheda('promemoria')}>
          Promemoria<span className="quanti">{promemoria.righe.length}</span>
        </button>
      </div>

      {scheda === 'scadenze' ? (
        <>
          <div className="filtri">
            {FILTRI_STATO.map((f) => (
              <button key={f.chiave} className={filtro.chiave === f.chiave ? 'attivo' : ''} onClick={() => setFiltro(f)}>
                {f.etichetta}<span className="quanti">{quante(f)}</span>
              </button>
            ))}
          </div>
          <div className="filtri">
            {(['tutti', 'formazione', 'sorveglianza'] as const).map((t) => (
              <button key={t} className={tipo === t ? 'attivo' : ''} onClick={() => setTipo(t)}>
                {t === 'tutti' ? 'formazione e visite' : t === 'formazione' ? 'solo formazione' : 'solo visite'}
              </button>
            ))}
            <span className="spinta" />
            <input className="cerca" placeholder="Persona, corso o ruolo"
                   value={cerca} onChange={(e) => setCerca(e.target.value)} />
          </div>
          {scadenze.caricando ? <Vuoto>Carico…</Vuoto>
            : righe.length === 0 ? <Vuoto>Nessuna scadenza con questi filtri.</Vuoto>
            : <TabellaScadenze righe={righe} conCliente={false} puoChiudere={(operatore?.livello ?? 0) >= 2} />}
        </>
      ) : (
        promemoria.caricando ? <Vuoto>Carico…</Vuoto>
          : promemoria.righe.length === 0 ? <Vuoto>Niente da sistemare per questo cliente.</Vuoto>
          : <ElencoPromemoria righe={promemoria.righe} conCliente={false} onCambiato={promemoria.ricarica} />
      )}
    </section>
  )
}
