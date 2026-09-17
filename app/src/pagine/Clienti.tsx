import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { supabase, LIMITE } from '../supabase'
import { useVista, conteggio, data, Errore, Vuoto } from '../componenti/comuni'
import type { SintesiCliente } from '../tipi'

const urgenza = (r: SintesiCliente) => [
  r.formazione_scadute + r.visite_scadute,
  r.formazione_mancanti,
  r.formazione_in_scadenza + r.visite_in_scadenza,
]

/** Da chi comincio: i clienti con qualcosa da fare, i piu urgenti in cima. */
export default function Clienti() {
  const [cerca, setCerca] = useState('')
  const [tutti, setTutti] = useState(false)

  const { righe, errore, caricando } = useVista<SintesiCliente>(
    () => supabase.from('v_scadenzario_cliente').select('*').order('ragione_sociale').limit(LIMITE)
  )

  const viste = useMemo(() => {
    const q = cerca.trim().toLowerCase()
    return righe
      .filter((r) => {
        if (!tutti && r.persone === 0) return false
        if (!q) return true
        return r.ragione_sociale.toLowerCase().includes(q) || (r.partita_iva ?? '').includes(q)
      })
      .sort((a, b) => {
        const [ua, ub] = [urgenza(a), urgenza(b)]
        for (let i = 0; i < ua.length; i++) if (ua[i] !== ub[i]) return ub[i] - ua[i]
        return a.ragione_sociale.localeCompare(b.ragione_sociale)
      })
  }, [righe, cerca, tutti])

  const somma = (k: keyof SintesiCliente) => viste.reduce((t, r) => t + (Number(r[k]) || 0), 0)

  if (errore) return <Errore testo={errore} />

  return (
    <section>
      <header className="testata">
        <div>
          <h1>Clienti</h1>
          <p className="sottotitolo">
            Un cliente per riga, i piu urgenti in cima: prima chi ha scadenze scadute, poi
            chi ha corsi mancanti, poi chi ha scadenze vicine. I numeri contano le scadenze
            delle persone in forza.
          </p>
        </div>
        <input className="cerca" placeholder="Ragione sociale o P.IVA"
               value={cerca} onChange={(e) => setCerca(e.target.value)} />
      </header>

      <div className="cifre">
        <div className="gruppo-cifre">
          <span className="titolo-gruppo">Formazione</span>
          <div className="cifra grave"><span>{somma('formazione_mancanti')}</span>corsi mancanti</div>
          <div className="cifra scaduta"><span>{somma('formazione_scadute')}</span>scaduti</div>
          <div className="cifra attesa"><span>{somma('formazione_in_scadenza')}</span>in scadenza</div>
          <div className="cifra"><span>{somma('formazione_da_completare')}</span>da completare</div>
        </div>
        <div className="gruppo-cifre">
          <span className="titolo-gruppo">Visite mediche</span>
          <div className="cifra scaduta"><span>{somma('visite_scadute')}</span>scadute</div>
          <div className="cifra attesa"><span>{somma('visite_in_scadenza')}</span>in scadenza</div>
        </div>
        <div className="gruppo-cifre">
          <span className="titolo-gruppo">Da sistemare</span>
          <Link to="/promemoria" className="cifra"><span>{somma('promemoria')}</span>promemoria</Link>
        </div>
      </div>

      <div className="filtri">
        <button className={!tutti ? 'attivo' : ''} onClick={() => setTutti(false)}>con persone in forza</button>
        <button className={tutti ? 'attivo' : ''} onClick={() => setTutti(true)}>tutti</button>
      </div>

      {caricando ? <Vuoto>Carico…</Vuoto> : viste.length === 0 ? <Vuoto>Nessun cliente.</Vuoto> : (
        <>
          <table className="doppia">
            <thead>
              <tr>
                <th rowSpan={2}>Cliente</th>
                <th rowSpan={2} className="n" title="Persone con un rapporto di lavoro non cessato">Persone<br />in forza</th>
                <th colSpan={4} className="gruppo">Formazione</th>
                <th colSpan={2} className="gruppo">Visite mediche</th>
                <th rowSpan={2} className="n" title="Cose da sistemare nell'organigramma o nel catalogo">Promemoria</th>
                <th rowSpan={2} title="La scadenza piu vecchia tra le scadute, o la piu vicina tra quelle in scadenza">Prima<br />scadenza</th>
              </tr>
              <tr>
                <th className="n" title="Ruoli con un obbligo di formazione e nessun corso fatto">mancanti</th>
                <th className="n" title="Corsi con la scadenza passata">scaduti</th>
                <th className="n" title="Corsi che scadono entro il preavviso (180 giorni, 90 per l'RLS)">in scadenza</th>
                <th className="n" title="Corsi iniziati o con l'attestato incompleto">da completare</th>
                <th className="n" title="Visite con la scadenza passata">scadute</th>
                <th className="n" title="Visite che scadono entro 60 giorni">in scadenza</th>
              </tr>
            </thead>
            <tbody>
              {viste.map((r) => (
                <tr key={r.cliente_id}>
                  <td>
                    <Link to={`/cliente/${r.cliente_id}`}>{r.ragione_sociale}</Link>
                    {!r.attivo && <span className="tipo">non attivo</span>}
                  </td>
                  <td className="n">{conteggio(r.persone)}</td>
                  <td className="n grave inizio-gruppo">{conteggio(r.formazione_mancanti)}</td>
                  <td className="n scaduta">{conteggio(r.formazione_scadute)}</td>
                  <td className="n attesa">{conteggio(r.formazione_in_scadenza)}</td>
                  <td className="n">{conteggio(r.formazione_da_completare)}</td>
                  <td className="n scaduta inizio-gruppo">{conteggio(r.visite_scadute)}</td>
                  <td className="n attesa">{conteggio(r.visite_in_scadenza)}</td>
                  <td className="n inizio-gruppo">{conteggio(r.promemoria)}</td>
                  <td>{data(r.prima_scadenza)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <p className="nota">
            Le visite non hanno «mancanti»: il motore non sa quali visite servono a ogni
            mansione, perche il protocollo sanitario non e ancora nel database.
          </p>
        </>
      )}
    </section>
  )
}
