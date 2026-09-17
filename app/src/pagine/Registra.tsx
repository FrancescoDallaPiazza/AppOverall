import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { supabase } from '../supabase'
import { useSessione } from '../sessione'
import { useVista, data, Errore, Vuoto } from '../componenti/comuni'
import type { EventoRegistrato, PersonaInForza } from '../tipi'

type Corso = {
  codice: string; nome: string; categoria: string
  ore: number | null; ore_grandezza: string
  aggiornamento_mesi: number | null
  ore_aggiornamento: number | null; ore_aggiornamento_grandezza: string
}
type Accertamento = { codice: string; nome: string; periodicita_mesi: number }
type Tipo = 'formazione' | 'sorveglianza'

/** ASR 2025, Parte I, punto 4. */
const MODALITA = [
  { valore: 'presenza', etichetta: 'in presenza' },
  { valore: 'videoconferenza_sincrona', etichetta: 'videoconferenza sincrona' },
  { valore: 'e_learning', etichetta: 'e-learning' },
  { valore: 'mista', etichetta: 'mista' },
]

const oggi = () => new Date().toISOString().slice(0, 10)

/**
 * Decisione di Francesco del 17 settembre 2026: spento Sicurweb, gli attestati e le
 * visite nuovi si registrano qui. Una scadenza gia in elenco si chiude partendo dalla
 * sua riga, e il modulo arriva compilato (?persona=&cliente=&tipo=&obbligo=&corso=).
 * La riga la firma il database (0028), e gli elementi minimi dell'attestato li
 * pretende il database (0029), non il modulo.
 */
export default function Registra() {
  const { operatore } = useSessione()
  const [parametri] = useSearchParams()
  const daScadenza = parametri.get('persona') && parametri.get('cliente')
  const [tipo, setTipo] = useState<Tipo>(parametri.get('tipo') === 'sorveglianza' ? 'sorveglianza' : 'formazione')
  const [persona, setPersona] = useState<PersonaInForza | null>(null)
  const [esito, setEsito] = useState<string | null>(null)

  const recenti = useVista<EventoRegistrato>(
    () => supabase.from('v_evento_registrato').select('*').order('inserito_il', { ascending: false }).limit(20)
  )

  // Arrivando da una scadenza, la persona e gia scelta.
  useEffect(() => {
    if (!daScadenza) return
    supabase.from('v_persona_in_forza').select('*')
      .eq('persona_id', parametri.get('persona')!).eq('cliente_id', parametri.get('cliente')!)
      .then(({ data }) => { const p = (data as PersonaInForza[] | null)?.[0]; if (p) setPersona(p) })
  }, [daScadenza, parametri])

  if (operatore && operatore.livello < 2) {
    return (
      <section>
        <h1>Nuovo attestato o visita</h1>
        <p className="sottotitolo">
          Il ruolo «{operatore.ruolo}» legge e basta: attestati e visite li registra il tecnico,
          la formazione o l'amministrazione.
        </p>
      </section>
    )
  }

  const fatto = (t: string) => { setEsito(t); recenti.ricarica() }

  return (
    <section>
      <header className="testata">
        <div>
          <h1>{daScadenza ? 'Chiudi una scadenza' : 'Nuovo attestato o visita'}</h1>
          <p className="sottotitolo">
            {daScadenza
              ? "Il modulo arriva compilato dalla scadenza: controllare i dati dell'attestato e registrare."
              : "Per chiudere una scadenza gia in elenco conviene partire dalla sua riga (pulsante «registra»): il modulo arriva compilato. Da qui si registrano gli attestati e le visite nuovi."}
            {' '}La scadenza la calcola il motore; chi ha registrato e quando lo scrive il database.
          </p>
        </div>
      </header>

      {!daScadenza && (
        <div className="filtri">
          <button className={tipo === 'formazione' ? 'attivo' : ''} onClick={() => { setTipo('formazione'); setEsito(null) }}>attestato</button>
          <button className={tipo === 'sorveglianza' ? 'attivo' : ''} onClick={() => { setTipo('sorveglianza'); setEsito(null) }}>visita medica</button>
        </div>
      )}

      <div className="modulo">
        <SceltaPersona persona={persona} bloccata={!!daScadenza}
                       onScegli={(p) => { setPersona(p); setEsito(null) }} />
        {persona && (tipo === 'formazione'
          ? <ModuloAttestato key={persona.persona_id} persona={persona} onFatto={fatto}
                             obbligo={parametri.get('obbligo')} corsoIniziale={parametri.get('corso')} />
          : <ModuloVisita key={persona.persona_id} persona={persona} onFatto={fatto}
                          accertamentoIniziale={parametri.get('corso')} />)}
        {esito && (
          <p className="esito">
            {esito}
            {daScadenza && <> <Link to={`/cliente/${parametri.get('cliente')}`}>Torna al cliente</Link></>}
          </p>
        )}
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

function SceltaPersona({ persona, bloccata, onScegli }: {
  persona: PersonaInForza | null; bloccata: boolean; onScegli: (p: PersonaInForza | null) => void
}) {
  const [testo, setTesto] = useState('')
  const [trovate, setTrovate] = useState<PersonaInForza[]>([])

  useEffect(() => {
    const t = testo.trim().replace(/[,()*]/g, ' ')
    if (t.length < 2) { setTrovate([]); return }
    let vivo = true
    supabase.from('v_persona_in_forza').select('*')
      .or(`cognome.ilike.*${t}*,nome.ilike.*${t}*,codice_fiscale.ilike.*${t}*,ragione_sociale.ilike.*${t}*`)
      .order('cognome').limit(20)
      .then(({ data }) => { if (vivo) setTrovate((data as PersonaInForza[]) ?? []) })
    return () => { vivo = false }
  }, [testo])

  if (persona) {
    return (
      <div className="scelta">
        <span className="etichetta">Persona</span>
        <strong>{persona.cognome} {persona.nome}</strong>
        <span className="tenue"> · {persona.codice_fiscale ?? 'senza codice fiscale'} · {persona.ragione_sociale}</span>
        {!bloccata && <button type="button" className="esci" onClick={() => onScegli(null)}>cambia</button>}
        {!persona.codice_fiscale && (
          <p className="avviso">
            In anagrafe manca il codice fiscale, che l'attestato deve riportare (ASR 2025,
            Parte I, punto 6 b): controllare che sia sull'attestato e aggiungerlo in anagrafe.
          </p>
        )}
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

/**
 * Il corso si sceglie scrivendo: la lista si restringe a ogni lettera. Da una scadenza,
 * in cima ci sono i corsi che chiudono quell'obbligo (v_corso_per_obbligo, 0029).
 */
function SceltaCorso({ corsi, suggeriti, scelto, onScegli }: {
  corsi: Corso[]; suggeriti: string[]; scelto: Corso | null; onScegli: (c: Corso | null) => void
}) {
  const [testo, setTesto] = useState('')

  const { primi, altri } = useMemo(() => {
    const parole = testo.trim().toLowerCase().split(/\s+/).filter(Boolean)
    const passa = (c: Corso) => parole.every((p) => `${c.nome} ${c.codice} ${c.categoria}`.toLowerCase().includes(p))
    const filtrati = corsi.filter(passa)
    return {
      primi: filtrati.filter((c) => suggeriti.includes(c.codice)),
      altri: parole.length ? filtrati.filter((c) => !suggeriti.includes(c.codice)).slice(0, 30) : [],
    }
  }, [corsi, suggeriti, testo])

  if (scelto) {
    return (
      <div className="scelta">
        <span className="etichetta">Corso</span>
        <strong>{scelto.nome}</strong>
        <span className="tenue">
          {' · '}{scelto.ore_grandezza === 'durata_corso' && scelto.ore ? `${scelto.ore} ore` : 'durata non fissata nel catalogo'}
          {' · '}{scelto.aggiornamento_mesi ? `aggiornamento ogni ${scelto.aggiornamento_mesi} mesi` : 'non scade'}
        </span>
        <button type="button" className="esci" onClick={() => onScegli(null)}>cambia</button>
      </div>
    )
  }

  const voce = (c: Corso) => (
    <li key={c.codice}>
      <button type="button" onClick={() => { onScegli(c); setTesto('') }}>
        <strong>{c.nome}</strong>
        <span className="tenue">
          {' · '}{c.categoria}{c.ore_grandezza === 'durata_corso' && c.ore ? ` · ${c.ore} ore` : ''}
          {c.aggiornamento_mesi ? ` · ogni ${c.aggiornamento_mesi} mesi` : ' · non scade'}
        </span>
      </button>
    </li>
  )

  return (
    <div className="scelta">
      <label>Corso
        <input className="cerca largo" placeholder="Scrivere parte del nome: carrello, ponteggi, preposto…"
               value={testo} onChange={(e) => setTesto(e.target.value)} />
      </label>
      {(primi.length > 0 || altri.length > 0) && (
        <ul className="elenco">
          {primi.length > 0 && <li className="intestazione">Chiudono questo obbligo</li>}
          {primi.map(voce)}
          {primi.length > 0 && altri.length > 0 && <li className="intestazione">Altri corsi</li>}
          {altri.map(voce)}
        </ul>
      )}
      {testo.trim() && primi.length === 0 && altri.length === 0 && (
        <p className="nota">Nessun corso del catalogo con queste parole.</p>
      )}
    </div>
  )
}

function ModuloAttestato({ persona, onFatto, obbligo, corsoIniziale }: {
  persona: PersonaInForza; onFatto: (t: string) => void; obbligo: string | null; corsoIniziale: string | null
}) {
  const corsi = useVista<Corso>(() => supabase.from('corso')
    .select('codice, nome, categoria, ore, ore_grandezza, aggiornamento_mesi, ore_aggiornamento, ore_aggiornamento_grandezza')
    .eq('attivo', true).order('nome'))
  const perObbligo = useVista<{ corso_codice: string }>(
    () => obbligo
      ? supabase.from('v_corso_per_obbligo').select('corso_codice').eq('ruolo', obbligo)
      : Promise.resolve({ data: [], error: null }),
    [obbligo])

  const [corso, setCorso] = useState<Corso | null>(null)
  const [giorno, setGiorno] = useState(oggi())
  const [ente, setEnte] = useState('')
  const [ore, setOre] = useState('')
  const [modalita, setModalita] = useState('')
  const [luogo, setLuogo] = useState('')
  // Da una scadenza con un corso gia fatto, quello che si registra e l'aggiornamento.
  const [aggiornamento, setAggiornamento] = useState(!!corsoIniziale)
  const [firmato, setFirmato] = useState(false)
  const [nota, setNota] = useState('')
  const [doppi, setDoppi] = useState(0)
  const [confermaDoppio, setConfermaDoppio] = useState(false)
  const [errore, setErrore] = useState<string | null>(null)
  const [inCorso, setInCorso] = useState(false)

  useEffect(() => {
    if (corsoIniziale && !corso) setCorso(corsi.righe.find((c) => c.codice === corsoIniziale) ?? null)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [corsi.righe, corsoIniziale])

  const contaDoppi = async () => {
    if (!corso || !giorno) return 0
    const { count } = await supabase.from('v_evento_formativo').select('id', { count: 'exact', head: true })
      .eq('persona_id', persona.persona_id).eq('corso_codice', corso.codice).eq('data', giorno)
    return count ?? 0
  }

  // Decisione del 16 settembre: due attestati sulla stessa persona, corso e data si
  // segnalano, non si rifiutano. Ma si registra il doppione solo dopo averlo confermato.
  useEffect(() => {
    let vivo = true
    setConfermaDoppio(false)
    contaDoppi().then((n) => { if (vivo) setDoppi(n) })
    return () => { vivo = false }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [corso?.codice, giorno, persona.persona_id])

  // Le ore previste, se il catalogo le da come durata del corso (non come parte pratica
  // o monte ore): e il confronto che si puo fare senza leggere l'attestato.
  const previste = corso
    ? aggiornamento
      ? (corso.ore_aggiornamento_grandezza === 'durata_corso' ? corso.ore_aggiornamento : null)
      : (corso.ore_grandezza === 'durata_corso' ? corso.ore : null)
    : null
  const oreNumero = Number(ore.replace(',', '.'))
  const pocheOre = previste !== null && ore !== '' && oreNumero < previste

  async function salva(e: FormEvent) {
    e.preventDefault()
    setErrore(null)
    if (!corso) return
    if (giorno > oggi()) { setErrore('La data e nel futuro: si registra un corso fatto, non uno previsto.'); return }
    if (!(oreNumero > 0)) { setErrore("La durata scritta sull'attestato deve essere un numero di ore."); return }
    // Il conteggio si rifa adesso: tra la scelta e il clic qualcun altro puo aver registrato.
    const n = await contaDoppi()
    if (n > 0 && !confermaDoppio) { setDoppi(n); setErrore('Questo attestato sembra gia registrato: confermare il doppione o cambiare i dati.'); return }
    setInCorso(true)
    const { error } = await supabase.from('evento_formativo').insert({
      persona_id: persona.persona_id,
      corso_codice: corso.codice,
      data: giorno,
      is_aggiornamento: aggiornamento,
      ente_formatore: ente.trim(),
      ore_attestato: oreNumero,
      modalita_erogazione: modalita,
      luogo: luogo.trim(),
      attestato_firmato: firmato,
      nota: nota.trim() || null,
    })
    setInCorso(false)
    if (error) { setErrore(error.message); return }
    onFatto(`Registrato: ${corso.nome} del ${data(giorno)} per ${persona.cognome} ${persona.nome}.`)
    setCorso(null); setOre(''); setNota(''); setFirmato(false); setDoppi(0); setConfermaDoppio(false)
  }

  const suggeriti = perObbligo.righe.map((r) => r.corso_codice)

  return (
    <form onSubmit={salva} className="campi">
      <SceltaCorso corsi={corsi.righe} suggeriti={suggeriti} scelto={corso} onScegli={setCorso} />
      {corso && (
        <>
          <p className="nota asr">
            I dati che l'ASR 2025 chiede su ogni attestato (Parte I, punto 6). Si copiano
            dall'attestato ricevuto.
          </p>
          <label>Soggetto formatore
            <input value={ente} onChange={(e) => setEnte(e.target.value)} required placeholder="come scritto sull'attestato" />
          </label>
          <label className="spunta">
            <input type="checkbox" checked={aggiornamento} onChange={(e) => setAggiornamento(e.target.checked)} />
            e un corso di aggiornamento
          </label>
          <div className="affiancati">
            <label>Durata (ore)
              <input inputMode="decimal" value={ore} onChange={(e) => setOre(e.target.value)} required
                     placeholder={previste ? `previste ${previste}` : ''} />
            </label>
            <label>Modalita di erogazione
              <select value={modalita} onChange={(e) => setModalita(e.target.value)} required>
                <option value="">— scegli —</option>
                {MODALITA.map((m) => <option key={m.valore} value={m.valore}>{m.etichetta}</option>)}
              </select>
            </label>
          </div>
          {pocheOre && (
            <p className="avviso">
              L'attestato riporta {ore} ore, il catalogo ne prevede {previste}{aggiornamento ? " per l'aggiornamento" : ''}.
              Controllare l'attestato: un corso piu corto non chiude l'obbligo.
            </p>
          )}
          <div className="affiancati">
            <label>Data di fine corso
              <input type="date" value={giorno} max={oggi()} onChange={(e) => setGiorno(e.target.value)} required />
            </label>
            <label>Luogo
              <input value={luogo} onChange={(e) => setLuogo(e.target.value)} required placeholder="come scritto sull'attestato" />
            </label>
          </div>
          <label className="spunta">
            <input type="checkbox" checked={firmato} onChange={(e) => setFirmato(e.target.checked)} required />
            l'attestato e firmato dal legale rappresentante del soggetto formatore o da un suo incaricato
          </label>
          <label>Nota
            <input value={nota} onChange={(e) => setNota(e.target.value)} placeholder="facoltativa" />
          </label>
          {doppi > 0 && (
            <div className="avviso doppio">
              <strong>Attenzione: sembra un doppione.</strong> Per questa persona c'e gia
              {doppi === 1 ? ' un attestato' : ` ${doppi} attestati`} di questo corso con la stessa data.
              <label className="spunta">
                <input type="checkbox" checked={confermaDoppio} onChange={(e) => setConfermaDoppio(e.target.checked)} />
                e un attestato diverso: registralo lo stesso (sara segnalato come doppio)
              </label>
            </div>
          )}
          {errore && <p className="errore">{errore}</p>}
          <button type="submit" disabled={inCorso || (doppi > 0 && !confermaDoppio)}>
            {inCorso ? 'Registro…' : "Registra l'attestato"}
          </button>
        </>
      )}
    </form>
  )
}

function ModuloVisita({ persona, onFatto, accertamentoIniziale }: {
  persona: PersonaInForza; onFatto: (t: string) => void; accertamentoIniziale: string | null
}) {
  const tipi = useVista<Accertamento>(() => supabase.from('accertamento').select('codice, nome, periodicita_mesi').order('nome'))
  const [accertamento, setAccertamento] = useState(accertamentoIniziale ?? '')
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
