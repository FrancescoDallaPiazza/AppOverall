import { Link } from 'react-router-dom'
import { data, giorni, Livello, Pastiglia } from './comuni'
import type { Scadenza, Stato } from '../tipi'

/** Gli stati che si chiudono registrando un attestato o una visita. */
const DA_CHIUDERE: Stato[] = ['mancante', 'scaduto', 'in_scadenza', 'incompleto', 'in_corso']

/** L'indirizzo del modulo gia compilato con persona, cliente e cosa manca. */
export function indirizzoChiusura(r: Scadenza) {
  const q = new URLSearchParams({ persona: r.persona_id, cliente: r.cliente_id, tipo: r.tipo })
  if (r.obbligo) q.set('obbligo', r.obbligo)
  if (r.corso) q.set('corso', r.corso)
  return `/registra?${q}`
}

/**
 * Le righe di v_scadenzario. `conCliente` le mostra con la colonna del cliente;
 * `puoChiudere` aggiunge il pulsante che apre il modulo gia compilato.
 */
export default function TabellaScadenze({ righe, conCliente, puoChiudere }: {
  righe: Scadenza[]; conCliente: boolean; puoChiudere: boolean
}) {
  return (
    <table>
      <thead>
        <tr>
          {conCliente && <th>Cliente</th>}
          <th>Persona</th><th>Obbligo</th><th>Corso o visita</th>
          <th>Fatto il</th><th>Scadenza</th><th className="n">Giorni</th><th>Stato</th><th>Note</th>
          {puoChiudere && <th />}
        </tr>
      </thead>
      <tbody>
        {righe.map((r, i) => (
          <tr key={`${r.tipo}-${r.persona_id}-${r.cliente_id}-${r.obbligo ?? ''}-${r.corso ?? ''}-${i}`}>
            {conCliente && <td><Link to={`/cliente/${r.cliente_id}`}>{r.ragione_sociale}</Link></td>}
            <td className="persona">
              {r.cognome} {r.nome}
              {r.sede && <span className="tipo">{r.sede}</span>}
            </td>
            <td>
              {r.tipo === 'sorveglianza' ? <span className="tenue">visita medica</span>
                : r.obbligo_nome ?? <span className="tenue">—</span>}
            </td>
            <td>{r.corso_nome ?? <span className="tenue">nessun corso fatto</span>}</td>
            <td>{data(r.completato_il)}</td>
            <td>
              {data(r.scadenza)}
              {r.anticipata && <span className="tipo attesa">anticipata dal medico o dall'ente</span>}
            </td>
            <td className="n">{r.stato === 'scaduto' || r.stato === 'in_scadenza' || r.stato === 'valido' ? giorni(r.giorni_residui) : ''}</td>
            <td><Pastiglia stato={r.stato} /></td>
            <td className="piccolo">
              {r.ruolo_da_confermare && (
                <Link to="/promemoria" className="nota-ciclo" title="Il corso e fatto, ma nessuna nomina lo segue: vedi i promemoria">
                  ruolo da confermare
                </Link>
              )}
              <Livello esito={r.esito_livello} richiesto={r.livello_richiesto} />
            </td>
            {puoChiudere && (
              <td>
                {DA_CHIUDERE.includes(r.stato) && (
                  <Link className="chiudi" to={indirizzoChiusura(r)}
                        title={r.tipo === 'sorveglianza' ? 'Registra la visita che chiude questa scadenza' : "Registra l'attestato che chiude questa scadenza"}>
                    {r.tipo === 'sorveglianza' ? 'registra visita' : 'registra attestato'}
                  </Link>
                )}
              </td>
            )}
          </tr>
        ))}
      </tbody>
    </table>
  )
}
