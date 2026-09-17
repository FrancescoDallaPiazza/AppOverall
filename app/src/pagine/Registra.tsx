import { useEffect, useState, type FormEvent } from 'react'
import { supabase } from '../supabase'
import { useSessione } from '../sessione'
import { useVista, data, Errore, Vuoto } from '../componenti/comuni'
import type { EventoRegistrato, PersonaInForza } from '../tipi'

type Corso = { codice: string; nome: string; categoria: string; aggiornamento_mesi: number | null; attivo: boolean }
type Accertamento = { codice: string; nome: string; periodicita_mesi: number }

const oggi = () => new Date().toISOString().slice(0, 10)

/**
 * Decisione di Francesco del 17 settembre 2026: spento Sicurweb, gli attestati e le
 * visite nuovi si registrano qui. La riga la firma il database (0028), non il modulo.
 */
export default function Registra() {
  const { operatore } = useSessione()
  const [tipo, setTipo] = useState<'formazione' | 'sorveglianza'>('formazione')
  const [persona, setPersona] = useState<PersonaInForza | null>(null)
  const [esito, setEsito] = useState<string | null>(null)

  const recenti = useVista<EventoRegistrato>(
    () => supabase.from('v_evento_registrato').select('*').order('inserito_il', { ascending: false }).limit(20)
  )

  if (operatore && operatore.livello < 2) {
    return (
      <section>
        <h1>Registra</h1>
        <p className="sottotitolo">
          Il ruolo «{operatore.ruolo}» legge e basta: attestati e visite li registra il tecnico,
          la formazione o l'amministrazione.
        </p>
      </section>
    )
  }

  return (
    <section>
      <header className="testata">
        <div>
          <h1>Registra</h1>
          <p className="sottotitolo">
            Un attestato o una visita fatti. La scadenza la calcola il motore; chi ha
            registrato e quando lo scrive il database.
          </p>
        </div>
      </header>

      <div className="filtri">
        <button className={tipo === 'formazione' ? 'attivo' : ''} onClick={() => { setTipo('formazione'); setEsito(null) }}>attestato</button>
        <button className={tipo === 'sorveglianza' ? 'attivo' : ''} onClick={() => { setTipo('sorveglianza'); setEsito(null) }}>visita medica</button>
      </div>

      <div className="modulo">
        <SceltaPersona persona={persona} onScegli={(p) => { setPersona(p); setEsito(null) }} />
        {persona && (tipo === 'formazione'
          ? <ModuloAttestato persona={persona} onFatto={(t) => { setEsito(t); recenti.ricarica() }} />
          : <ModuloVisita persona={persona} onFatto={(t) => { setEsito(t); recenti.ricarica() }} />)}
        {esito && <p className="esito">{esito}</p>}
      </div>

      <h2>Ultime registrazioni</h2>
      {recenti.errore ? <Errore testo={recenti.errore} />
        : recenti.caricando ? <Vuoto>Carico…</Vuoto>
        : recenti.righe.length === 0 ? <Vuoto>Ancora niente registrato dall'app.</Vuoto>
        : (
          <table>
            <thead><tr><th>Registrato</th><th>Da</th><th>Persona</th><th>Cosa</th><th>Fatto il</th><th>Ente</th></tr></thead>
            <tbody>
              {recenti.righe.map((r) => (
                <tr key={`${r.tipo}-${r.id}`}>
                  <td>{new Date(r.inserito_il).toLocaleString('it-IT')}</td>
                  <td>{r.inserito_da}</td>
                  <td>{r.cognome} {r.nome}</td>
                  <td>{r.descrizione}{r.tipo === 'sorveglianza' && <span className="tipo">visita medica</span>}</td>
                  <td>{data(r.data)}</td>
                  <td>{r.ente_formatore ?? ''}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
    </section>
  )
}

function SceltaPersona({ persona, onScegli }: { persona: PersonaInForza | null; onScegli: (p: PersonaInForza | null) => void }) {
  const [testo, setTesto] = useState('')
  const [trovate, setTrovate] = useState<PersonaInForza[]>([])

  useEffect(() => {
    const t = testo.trim().replace(/[,()*]/g, ' ')
    if (t.length < 2) { setTrovate([]); return }
    let vivo = true
    const q = supabase.from('v_persona_in_forza').select('*')
      .or(`cognome.ilike.*${t}*,nome.ilike.*${t}*,codice_fiscale.ilike.*${t}*,ragione_sociale.ilike.*${t}*`)
      .order('cognome').limit(20)
    q.then(({ data }) => { if (vivo) setTrovate((data as PersonaInForza[]) ?? []) })
    return () => { vivo = false }
  }, [testo])

  if (persona) {
    return (
      <div className="scelta">
        <strong>{persona.cognome} {persona.nome}</strong>
        <span className="tenue"> · {persona.codice_fiscale ?? 'senza codice fiscale'} · {persona.ragione_sociale}</span>
        <button type="button" className="esci" onClick={() => onScegli(null)}>cambia</button>
      </div>
    )
  }
  return (
    <div className="scelta">
      <label>Persona
        <input className="cerca largo" autoFocus placeholder="Cognome, nome, codice fiscale o cliente"
               value={testo} onChange={(e) => setTesto(e.target.value)} />
      </label>
      {trovate.length > 0 && (
        <ul className="elenco">
          {trovate.map((p) => (
            <li key={`${p.persona_id}-${p.cliente_id}`}>
              <button type="button" onClick={() => onScegli(p)}>
                <strong>{p.cognome} {p.nome}</strong>
                <span className="tenue"> · {p.codice_fiscale ?? 'senza CF'} · {p.ragione_sociale}{p.mansione ? ` · ${p.mansione}` : ''}</span>
              </button>
            </li>
          ))}
        </ul>
      )}
      {testo.trim().length >= 2 && trovate.length === 0 && (
        <p className="nota">Nessuna persona in forza con questo testo. Chi non e in anagrafe va aggiunto prima all'organigramma del cliente.</p>
      )}
    </div>
  )
}

function ModuloAttestato({ persona, onFatto }: { persona: PersonaInForza; onFatto: (t: string) => void }) {
  const corsi = useVista<Corso>(() => supabase.from('v_corso').select('codice, nome, categoria, aggiornamento_mesi, attivo')
    .eq('attivo', true).order('categoria').order('nome'))
  const [corso, setCorso] = useState('')
  const [giorno, setGiorno] = useState(oggi())
  const [ente, setEnte] = useState('')
  const [aggiornamento, setAggiornamento] = useState(false)
  const [nota, setNota] = useState('')
  const [errore, setErrore] = useState<string | null>(null)
  const [avviso, setAvviso] = useState<string | null>(null)
  const [inCorso, setInCorso] = useState(false)

  // Decisione del 16 settembre: due attestati sulla stessa persona, corso e data si
  // segnalano, non si rifiutano. Lo si dice prima di scrivere.
  useEffect(() => {
    setAvviso(null)
    if (!corso || !giorno) return
    supabase.from('v_evento_formativo').select('id', { count: 'exact', head: true })
      .eq('persona_id', persona.persona_id).eq('corso_codice', corso).eq('data', giorno)
      .then(({ count }) => { if (count) setAvviso(`Esiste gia un attestato di questo corso per questa persona in questa data (${count}). Se lo registri, sara segnalato come doppio.`) })
  }, [corso, giorno, persona.persona_id])

  async function salva(e: FormEvent) {
    e.preventDefault()
    setErrore(null)
    if (giorno > oggi()) { setErrore('La data e nel futuro: si registra un corso fatto, non uno previsto.'); return }
    setInCorso(true)
    const { error } = await supabase.from('evento_formativo').insert({
      persona_id: persona.persona_id,
      corso_codice: corso,
      data: giorno,
      is_aggiornamento: aggiornamento,
      ente_formatore: ente.trim() || null,
      nota: nota.trim() || null,
    })
    setInCorso(false)
    if (error) { setErrore(error.message); return }
    const nome = corsi.righe.find((c) => c.codice === corso)?.nome ?? corso
    onFatto(`Registrato: ${nome} del ${data(giorno)} per ${persona.cognome} ${persona.nome}.`)
    setCorso(''); setEnte(''); setNota(''); setAggiornamento(false)
  }

  return (
    <form onSubmit={salva} className="campi">
      <label>Corso
        <select value={corso} onChange={(e) => setCorso(e.target.value)} required>
          <option value="">— scegli —</option>
          {corsi.righe.map((c) => (
            <option key={c.codice} value={c.codice}>
              {c.nome}{c.aggiornamento_mesi ? ` · ogni ${c.aggiornamento_mesi} mesi` : ' · non scade'}
            </option>
          ))}
        </select>
      </label>
      <label>Data di fine corso
        <input type="date" value={giorno} max={oggi()} onChange={(e) => setGiorno(e.target.value)} required />
      </label>
      <label className="spunta">
        <input type="checkbox" checked={aggiornamento} onChange={(e) => setAggiornamento(e.target.checked)} />
        e un aggiornamento
      </label>
      <label>Ente formatore
        <input value={ente} onChange={(e) => setEnte(e.target.value)} placeholder="facoltativo" />
      </label>
      <label>Nota
        <input value={nota} onChange={(e) => setNota(e.target.value)} placeholder="facoltativa" />
      </label>
      {avviso && <p className="avviso">{avviso}</p>}
      {errore && <p className="errore">{errore}</p>}
      <button type="submit" disabled={inCorso || !corso}>{inCorso ? 'Registro…' : 'Registra l\'attestato'}</button>
    </form>
  )
}

function ModuloVisita({ persona, onFatto }: { persona: PersonaInForza; onFatto: (t: string) => void }) {
  const tipi = useVista<Accertamento>(() => supabase.from('accertamento').select('codice, nome, periodicita_mesi').order('nome'))
  const [accertamento, setAccertamento] = useState('')
  const [giorno, setGiorno] = useState(oggi())
  const [nota, setNota] = useState('')
  const [errore, setErrore] = useState<string | null>(null)
  const [inCorso, setInCorso] = useState(false)

  async function salva(e: FormEvent) {
    e.preventDefault()
    setErrore(null)
    if (giorno > oggi()) { setErrore('La data e nel futuro: si registra una visita fatta.'); return }
    setInCorso(true)
    const { error } = await supabase.from('sorveglianza').insert({
      persona_id: persona.persona_id,
      accertamento,
      data_esecuzione: giorno,
      note: nota.trim() || null,
    })
    setInCorso(false)
    if (error) {
      setErrore(error.message.includes('sorveglianza_una_per_data')
        ? 'Questa visita e gia registrata per questa persona in questa data.'
        : error.message)
      return
    }
    const nome = tipi.righe.find((t) => t.codice === accertamento)?.nome ?? accertamento
    onFatto(`Registrata: ${nome} del ${data(giorno)} per ${persona.cognome} ${persona.nome}.`)
    setAccertamento(''); setNota('')
  }

  return (
    <form onSubmit={salva} className="campi">
      <label>Accertamento
        <select value={accertamento} onChange={(e) => setAccertamento(e.target.value)} required>
          <option value="">— scegli —</option>
          {tipi.righe.map((t) => (
            <option key={t.codice} value={t.codice}>{t.nome} · ogni {t.periodicita_mesi} mesi</option>
          ))}
        </select>
      </label>
      <label>Data della visita
        <input type="date" value={giorno} max={oggi()} onChange={(e) => setGiorno(e.target.value)} required />
      </label>
      <label>Nota
        <input value={nota} onChange={(e) => setNota(e.target.value)} placeholder="facoltativa (niente dati sanitari)" />
      </label>
      <p className="nota">
        Si registra che la visita e stata fatta, non il giudizio: l'esito resta del medico competente.
      </p>
      {errore && <p className="errore">{errore}</p>}
      <button type="submit" disabled={inCorso || !accertamento}>{inCorso ? 'Registro…' : 'Registra la visita'}</button>
    </form>
  )
}
