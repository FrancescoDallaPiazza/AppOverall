import { BrowserRouter, Routes, Route, NavLink } from 'react-router-dom'
import { ProviderSessione, useSessione } from './sessione'
import Accesso from './pagine/Accesso'
import Clienti from './pagine/Clienti'
import Cliente from './pagine/Cliente'
import Scadenze from './pagine/Scadenze'
import Promemoria from './pagine/Promemoria'
import Registra from './pagine/Registra'

function Impalcatura() {
  const { utente, operatore, caricando, prova, esci } = useSessione()

  if (caricando) return <p className="vuoto centrato">Un momento…</p>
  if (!utente) return <Accesso />

  return (
    <BrowserRouter>
      <nav>
        <span className="marchio">AppOverall</span>
        <NavLink to="/" end>Clienti</NavLink>
        <NavLink to="/scadenze">Scadenze</NavLink>
        <NavLink to="/promemoria">Promemoria</NavLink>
        <NavLink to="/registra">Nuovo attestato o visita</NavLink>
        <span className="spinta" />
        {prova && <span className="ruolo avviso" title="app/prova/avvia.sh: dati finti">banco di prova</span>}
        <span className="chi">
          {operatore
            ? <>{operatore.nome} {operatore.cognome} <span className="ruolo">{operatore.ruolo}</span></>
            : <span className="ruolo avviso">non abilitato</span>}
        </span>
        {!prova && <button className="esci" onClick={esci}>Esci</button>}
      </nav>

      {!operatore && (
        <div className="riquadro-errore">
          <strong>Utente autenticato ma non abilitato.</strong>
          <p>
            Manca la riga in <code>operatore</code>: finche non c'e, <code>e_operatore()</code>
            risponde falso e ogni lista torna vuota. La crea l'amministrazione.
          </p>
        </div>
      )}

      <main>
        <Routes>
          <Route path="/" element={<Clienti />} />
          <Route path="/cliente/:id" element={<Cliente />} />
          <Route path="/scadenze" element={<Scadenze />} />
          <Route path="/promemoria" element={<Promemoria />} />
          <Route path="/registra" element={<Registra />} />
        </Routes>
      </main>
    </BrowserRouter>
  )
}

export default function App() {
  return (
    <ProviderSessione>
      <Impalcatura />
    </ProviderSessione>
  )
}
