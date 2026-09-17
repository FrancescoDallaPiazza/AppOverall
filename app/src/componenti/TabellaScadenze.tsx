import { Link } from 'react-router-dom'
import { data, giorni, Livello, Pastiglia } from './comuni'
import type { Scadenza } from '../tipi'

/** Le righe di v_scadenzario. `conCliente` le mostra con la colonna del cliente. */
export default function TabellaScadenze({ righe, conCliente }: { righe: Scadenza[]; conCliente: boolean }) {
  return (
    <table>
      <thead>
        <tr>
          {conCliente && <th>Cliente</th>}
          <th>Persona</th><th>Obbligo</th><th>Corso o visita</th>
          <th>Fatto il</th><th>Scadenza</th><th className="n">Giorni</th><th>Stato</th><th>Note</th>
        </tr>
      </thead>
      <tbody>
        {righe.map((r, i) => (
          <tr key={`${r.tipo}-${r.persona_id}-${r.cliente_id}-${r.obbligo ?? ''}-${r.corso ?? ''}-${i}`}>
            {conCliente && <td><Link to={`/cliente/${r.cliente_id}`}>{r.ragione_sociale}</Link></td>}
            <td>
              {r.cognome} {r.nome}
              {r.sede && <span className="tipo">{r.sede}</span>}
            </td>
            <td>
              {r.tipo === 'sorveglianza' ? <span className="tenue">visita medica</span>
                : r.obbligo_nome ?? <span className="tenue">—</span>}
            </td>
            <td>{r.corso_nome ?? <span className="tenue">nessun corso</span>}</td>
            <td>{data(r.completato_il)}</td>
            <td>
              {data(r.scadenza)}
              {r.anticipata && <span className="tipo attesa">anticipata dal medico o dall'ente</span>}
            </td>
            <td className="n">{r.stato === 'scaduto' || r.stato === 'in_scadenza' || r.stato === 'valido' ? giorni(r.giorni_residui) : ''}</td>
            <td><Pastiglia stato={r.stato} /></td>
            <td className="piccolo">
              {r.ruolo_da_confermare && (
                <span className="nota-ciclo">
                  ruolo da confermare{r.obbligo_nome ? '' : ' (nessun ruolo proposto)'}
                </span>
              )}
              <Livello esito={r.esito_livello} richiesto={r.livello_richiesto} />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
