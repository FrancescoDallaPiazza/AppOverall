import { useMemo, useState } from 'react'
import { supabase, LIMITE } from '../supabase'
import { useVista, Errore, Vuoto } from '../componenti/comuni'
import ElencoPromemoria from '../componenti/ElencoPromemoria'
import type { Promemoria as RigaPromemoria } from '../tipi'

/**
 * I promemoria di tutti i clienti (0029): quello che va sistemato nell'organigramma o
 * nel catalogo perche le scadenze siano giuste. Separati dallo scadenzario su
 * richiesta di Francesco del 17 settembre 2026.
 */
export default function Promemoria() {
  const [cerca, setCerca] = useState('')
  const { righe, errore, caricando, ricarica } = useVista<RigaPromemoria>(
    () => supabase.from('v_promemoria').select('*')
      .order('ragione_sociale').order('cognome').limit(LIMITE)
  )

  const viste = useMemo(() => {
    const q = cerca.trim().toLowerCase()
    if (!q) return righe
    return righe.filter((r) =>
      r.ragione_sociale.toLowerCase().includes(q)
      || `${r.cognome} ${r.nome}`.toLowerCase().includes(q)
      || (r.corso_nome ?? '').toLowerCase().includes(q)
      || (r.ruolo_nome ?? '').toLowerCase().includes(q))
  }, [righe, cerca])

  if (errore) return <Errore testo={errore} />

  return (
    <section>
      <header className="testata">
        <div>
          <h1>Promemoria</h1>
          <p className="sottotitolo">
            Non sono scadenze: sono cose da sistemare nell'organigramma, nel catalogo o nel gestionale
            perche le scadenze siano giuste. Ogni gruppo spiega a cosa si riferisce.
          </p>
        </div>
        <input className="cerca" placeholder="Cliente, persona, corso o ruolo"
               value={cerca} onChange={(e) => setCerca(e.target.value)} />
      </header>
      {righe.length >= LIMITE && (
        <p className="nota">Mostrati i primi {LIMITE}: restringere con la ricerca.</p>
      )}
      {caricando ? <Vuoto>Carico…</Vuoto>
        : viste.length === 0 ? <Vuoto>Nessun promemoria.</Vuoto>
        : <ElencoPromemoria righe={viste} conCliente onCambiato={ricarica} />}
    </section>
  )
}
