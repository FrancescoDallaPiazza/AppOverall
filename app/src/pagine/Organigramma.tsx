import { useMemo, useState } from 'react'
import { supabase, LIMITE } from '../supabase'
import { useVista, Errore, Vuoto } from '../componenti/comuni'
import { TabellaRuoli } from './Cliente'
import type { RuoloDaConfermare } from '../tipi'

/**
 * Decisione di Francesco del 17 settembre 2026: le scadenze seguono anche i corsi fatti
 * senza nomina, e l'app lo segnala perche l'organigramma si aggiorni. Questa e la lista.
 */
export default function Organigramma() {
  const [cerca, setCerca] = useState('')
  const { righe, errore, caricando } = useVista<RuoloDaConfermare>(
    () => supabase.from('v_ruolo_da_confermare').select('*')
      .order('ragione_sociale').order('cognome').limit(LIMITE)
  )

  const viste = useMemo(() => {
    const q = cerca.trim().toLowerCase()
    if (!q) return righe
    return righe.filter((r) =>
      r.ragione_sociale.toLowerCase().includes(q)
      || `${r.cognome} ${r.nome}`.toLowerCase().includes(q)
      || r.corso_nome.toLowerCase().includes(q))
  }, [righe, cerca])

  const clienti = new Set(viste.map((r) => r.cliente_id)).size

  if (errore) return <Errore testo={errore} />

  return (
    <section>
      <header className="testata">
        <div>
          <h1>Organigramma da aggiornare</h1>
          <p className="sottotitolo">
            {viste.length} corsi fatti che nessuna nomina segue, su {clienti} clienti. Per
            ognuno: il ruolo si conferma nell'organigramma, oppure si dichiara che la persona
            non lo svolge.
          </p>
        </div>
        <input className="cerca" placeholder="Cliente, persona o corso"
               value={cerca} onChange={(e) => setCerca(e.target.value)} />
      </header>
      {caricando ? <Vuoto>Carico…</Vuoto>
        : viste.length === 0 ? <Vuoto>Nessun ruolo da confermare.</Vuoto>
        : <TabellaRuoli righe={viste} conCliente />}
    </section>
  )
}
