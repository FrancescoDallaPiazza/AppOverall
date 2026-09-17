import { useMemo, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { supabase, LIMITE } from '../supabase'
import { useVista, data, Errore, Vuoto } from '../componenti/comuni'
import TabellaScadenze from '../componenti/TabellaScadenze'
import type { RuoloDaConfermare, Scadenza, SintesiCliente, Stato } from '../tipi'

const ORDINE: Record<Stato, number> = {
  scaduto: 0, mancante: 1, in_scadenza: 2, incompleto: 3, in_corso: 4, senza_regola: 5, valido: 6, non_scade: 7,
}

/** Come sta questo cliente: le sue scadenze, persona per persona, e l'organigramma da aggiornare. */
export default function Cliente() {
  const { id } = useParams()
  const [scheda, setScheda] = useState<'scadenze' | 'organigramma'>('scadenze')
  const [soloAperte, setSoloAperte] = useState(true)

  const testa = useVista<SintesiCliente>(
    () => supabase.from('v_scadenzario_cliente').select('*').eq('cliente_id', id!), [id])
  const scadenze = useVista<Scadenza>(
    () => supabase.from('v_scadenzario').select('*').eq('cliente_id', id!).limit(LIMITE), [id])
  const ruoli = useVista<RuoloDaConfermare>(
    () => supabase.from('v_ruolo_da_confermare').select('*').eq('cliente_id', id!)
      .order('cognome').limit(LIMITE), [id])

  const righe = useMemo(() => scadenze.righe
    .filter((r) => !soloAperte || !['valido', 'non_scade'].includes(r.stato))
    .sort((a, b) => ORDINE[a.stato] - ORDINE[b.stato]
      || `${a.cognome} ${a.nome}`.localeCompare(`${b.cognome} ${b.nome}`)
      || (a.scadenza ?? '').localeCompare(b.scadenza ?? '')),
  [scadenze.righe, soloAperte])

  const errore = testa.errore ?? scadenze.errore ?? ruoli.errore
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
          <div className="cifra scaduta"><span>{c.scadute}</span>scadute</div>
          <div className="cifra attesa"><span>{c.in_scadenza}</span>in scadenza</div>
          <div className="cifra grave"><span>{c.mancanti}</span>mancanti</div>
          <div className="cifra"><span>{c.incomplete}</span>da completare</div>
          <div className="cifra"><span>{c.ruoli_da_confermare}</span>ruoli da confermare</div>
          <div className="cifra"><span>{c.livello_non_definito}</span>livello di emergenza non definito</div>
        </div>
      )}

      <div className="filtri">
        <button className={scheda === 'scadenze' ? 'attivo' : ''} onClick={() => setScheda('scadenze')}>
          Scadenze<span className="quanti">{scadenze.righe.length}</span>
        </button>
        <button className={scheda === 'organigramma' ? 'attivo' : ''} onClick={() => setScheda('organigramma')}>
          Organigramma da aggiornare<span className="quanti">{ruoli.righe.length}</span>
        </button>
        {scheda === 'scadenze' && (
          <>
            <span className="spinta" />
            <button className={soloAperte ? 'attivo' : ''} onClick={() => setSoloAperte(true)}>da fare</button>
            <button className={!soloAperte ? 'attivo' : ''} onClick={() => setSoloAperte(false)}>tutte</button>
          </>
        )}
      </div>

      {scheda === 'scadenze' ? (
        scadenze.caricando ? <Vuoto>Carico…</Vuoto>
          : righe.length === 0 ? <Vuoto>{soloAperte ? 'Niente da fare: tutte le scadenze sono valide.' : 'Nessuna scadenza.'}</Vuoto>
          : <TabellaScadenze righe={righe} conCliente={false} />
      ) : (
        ruoli.caricando ? <Vuoto>Carico…</Vuoto>
          : ruoli.righe.length === 0 ? <Vuoto>L'organigramma segue tutti i corsi fatti.</Vuoto>
          : <TabellaRuoli righe={ruoli.righe} conCliente={false} />
      )}
    </section>
  )
}

export function TabellaRuoli({ righe, conCliente }: { righe: RuoloDaConfermare[]; conCliente: boolean }) {
  return (
    <>
      <p className="nota">
        Queste persone hanno fatto un corso che l'organigramma non segue: la scadenza c'e
        comunque (come in Sicurweb), ma il ruolo va confermato o escluso nell'organigramma.
      </p>
      <table>
        <thead>
          <tr>
            {conCliente && <th>Cliente</th>}
            <th>Persona</th><th>Corso fatto</th><th>Il</th><th>Ruolo da confermare</th><th>Scadenza</th>
          </tr>
        </thead>
        <tbody>
          {righe.map((r) => (
            <tr key={`${r.persona_id}-${r.cliente_id}-${r.corso}`}>
              {conCliente && <td><Link to={`/cliente/${r.cliente_id}`}>{r.ragione_sociale}</Link></td>}
              <td>{r.cognome} {r.nome}</td>
              <td>{r.corso_nome}</td>
              <td>{data(r.completato_il)}</td>
              <td>{r.ruolo_proposto_nome ?? <span className="tenue">da scegliere: il corso vale per piu figure o per nessuna</span>}</td>
              <td>{data(r.scadenza)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  )
}
