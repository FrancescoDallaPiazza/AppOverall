import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { supabase, LIMITE } from '../supabase'
import { useVista, conteggio, data, Errore, Vuoto } from '../componenti/comuni'
import type { SintesiCliente } from '../tipi'

/** Da chi comincio: i clienti con qualcosa da fare, i piu urgenti in cima. */
export default function Clienti() {
  const [cerca, setCerca] = useState('')
  const [tutti, setTutti] = useState(false)

  const { righe, errore, caricando } = useVista<SintesiCliente>(
    () => supabase.from('v_scadenzario_cliente').select('*')
      .order('scadute', { ascending: false })
      .order('in_scadenza', { ascending: false })
      .order('ragione_sociale')
      .limit(LIMITE)
  )

  const viste = useMemo(() => {
    const q = cerca.trim().toLowerCase()
    return righe.filter((r) => {
      if (!tutti && r.persone === 0) return false
      if (!q) return true
      return r.ragione_sociale.toLowerCase().includes(q) || (r.partita_iva ?? '').includes(q)
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
            Una riga per cliente, i piu urgenti in cima. Le scadenze vengono dal motore:
            formazione e visite mediche, per le persone in forza.
          </p>
        </div>
        <input className="cerca" placeholder="Ragione sociale o P.IVA"
               value={cerca} onChange={(e) => setCerca(e.target.value)} />
      </header>

      <div className="cifre">
        <div className="cifra scaduta"><span>{somma('scadute')}</span>scadute</div>
        <div className="cifra attesa"><span>{somma('in_scadenza')}</span>in scadenza</div>
        <div className="cifra grave"><span>{somma('mancanti')}</span>mancanti</div>
        <div className="cifra"><span>{somma('ruoli_da_confermare')}</span>ruoli da confermare</div>
        <div className="cifra"><span>{somma('livello_non_definito')}</span>livello di emergenza non definito</div>
      </div>

      <div className="filtri">
        <button className={!tutti ? 'attivo' : ''} onClick={() => setTutti(false)}>con persone in forza</button>
        <button className={tutti ? 'attivo' : ''} onClick={() => setTutti(true)}>tutti</button>
      </div>

      {caricando ? <Vuoto>Carico…</Vuoto> : viste.length === 0 ? <Vuoto>Nessun cliente.</Vuoto> : (
        <table>
          <thead>
            <tr>
              <th>Cliente</th><th className="n">Persone</th><th className="n">Scadute</th>
              <th className="n">In scadenza</th><th className="n">Mancanti</th>
              <th className="n">Da completare</th><th className="n">Ruoli da confermare</th>
              <th className="n">Livello da definire</th><th>Prima scadenza</th>
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
                <td className="n scaduta">{conteggio(r.scadute)}</td>
                <td className="n attesa">{conteggio(r.in_scadenza)}</td>
                <td className="n grave">{conteggio(r.mancanti)}</td>
                <td className="n">{conteggio(r.incomplete)}</td>
                <td className="n">{conteggio(r.ruoli_da_confermare)}</td>
                <td className="n">{conteggio(r.livello_non_definito)}</td>
                <td>{data(r.prima_scadenza)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  )
}
