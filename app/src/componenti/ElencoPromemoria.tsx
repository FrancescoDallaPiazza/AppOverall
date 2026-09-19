import { Link } from 'react-router-dom'
import { supabase } from '../supabase'
import { data, Livello } from './comuni'
import type { GenerePromemoria, Promemoria } from '../tipi'

/**
 * I promemoria della 0029, divisi per genere. Non sono scadenze: sono cose da sistemare
 * nell'organigramma o nel catalogo perche le scadenze siano giuste. Ogni gruppo dice a
 * cosa si riferisce e cosa si fa.
 */
const GRUPPI: { genere: GenerePromemoria; titolo: string; spiega: string; cosaFare: string }[] = [
  {
    genere: 'ruolo_da_confermare',
    titolo: 'Ruoli da confermare',
    spiega: "La persona ha fatto un corso che nessuna nomina dell'organigramma segue. La scadenza la calcoliamo lo stesso, come faceva Sicurweb, ma l'organigramma non lo sa.",
    cosaFare: "Nell'organigramma del cliente: si conferma il ruolo (la persona lo svolge) oppure si esclude (il corso non serve piu).",
  },
  {
    genere: 'livello_emergenza',
    titolo: 'Livello di emergenza',
    spiega: "Addetti antincendio e primo soccorso: il corso va confrontato con il livello richiesto dalla sede. Se la sede non ha un livello, il confronto non si puo fare; se il corso e sotto il livello, la formazione non basta.",
    cosaFare: "Nella scheda della sede: si indica il livello antincendio e il gruppo di primo soccorso. Se il corso e insufficiente, serve quello del livello giusto.",
  },
  {
    genere: 'corso_non_definito',
    titolo: 'Ruoli senza corso nel catalogo',
    spiega: 'La persona ha un ruolo, ma il catalogo non dice quale corso lo copre: la scadenza non si puo calcolare.',
    cosaFare: "Nel catalogo: si decide se il ruolo richiede un corso, e quale. Finche non si decide, il ruolo non ha scadenze.",
  },
  {
    genere: 'da_riportare',
    titolo: 'Persone da riportare nel gestionale',
    spiega: "Aggiunte dall'app partendo da un attestato, perche non erano in anagrafe (0031). Qui ci sono, nel gestionale no.",
    cosaFare: "Nel gestionale: si inserisce la persona con il suo rapporto col cliente. Poi qui «riportata».",
  },
]

export default function ElencoPromemoria({ righe, conCliente, onCambiato }: {
  righe: Promemoria[]; conCliente: boolean; onCambiato: () => void
}) {
  const riportata = async (persona_id: string) => {
    const { error } = await supabase.from('persona').update({ da_riportare_nel_gestionale: false }).eq('id', persona_id)
    if (error) alert(error.message); else onCambiato()
  }
  return (
    <>
      {GRUPPI.map((g) => {
        const qui = righe.filter((r) => r.genere === g.genere)
        if (qui.length === 0) return null
        return (
          <div key={g.genere} className="promemoria">
            <h2>{g.titolo}<span className="quanti">{qui.length}</span></h2>
            <p className="spiega">{g.spiega}</p>
            <p className="spiega"><strong>Cosa fare.</strong> {g.cosaFare}</p>
            <table>
              <thead>
                <tr>
                  {conCliente && <th>Cliente</th>}
                  <th>Persona</th>
                  {g.genere === 'da_riportare' ? <><th>Codice fiscale</th><th></th></> : <>
                  <th>{g.genere === 'ruolo_da_confermare' ? 'Ruolo proposto' : 'Ruolo'}</th>
                  {g.genere !== 'corso_non_definito' && <><th>Corso fatto</th><th>Il</th></>}</>}
                  {g.genere === 'ruolo_da_confermare' && <th>Scadenza</th>}
                  {g.genere === 'livello_emergenza' && <th>Esito</th>}
                </tr>
              </thead>
              <tbody>
                {qui.map((r, i) => (
                  <tr key={`${r.persona_id}-${r.cliente_id}-${r.ruolo ?? ''}-${r.corso ?? ''}-${i}`}>
                    {conCliente && <td><Link to={`/cliente/${r.cliente_id}`}>{r.ragione_sociale}</Link></td>}
                    <td>{r.cognome} {r.nome}</td>
                    {g.genere === 'da_riportare'
                      ? <><td>{r.codice_fiscale}</td><td><button type="button" onClick={() => riportata(r.persona_id)}>riportata</button></td></>
                      : <>
                    <td>{r.ruolo_nome ?? <span className="tenue">da scegliere: il corso vale per piu ruoli o per nessuno</span>}</td>
                    {g.genere !== 'corso_non_definito' && <><td>{r.corso_nome}</td><td>{data(r.completato_il)}</td></>}</>}
                    {g.genere === 'ruolo_da_confermare' && <td>{data(r.scadenza)}</td>}
                    {g.genere === 'livello_emergenza' && <td><Livello esito={r.esito} richiesto={r.livello_richiesto} /></td>}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      })}
    </>
  )
}
