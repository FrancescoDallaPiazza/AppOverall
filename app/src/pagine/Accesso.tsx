import { useState, type FormEvent } from 'react'
import { supabase } from '../supabase'

export default function Accesso() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errore, setErrore] = useState<string | null>(null)
  const [inCorso, setInCorso] = useState(false)

  async function entra(e: FormEvent) {
    e.preventDefault()
    setInCorso(true)
    setErrore(null)
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) setErrore(error.message)
    setInCorso(false)
  }

  return (
    <div className="accesso">
      <form onSubmit={entra}>
        <h1>AppOverall</h1>
        <p className="sottotitolo">Scadenzario della sicurezza — Overall Group S.r.l.</p>
        <label>
          Indirizzo mail
          <input type="email" value={email} autoComplete="username"
                 onChange={(e) => setEmail(e.target.value)} required />
        </label>
        <label>
          Password
          <input type="password" value={password} autoComplete="current-password"
                 onChange={(e) => setPassword(e.target.value)} required />
        </label>
        {errore && <p className="errore">{errore}</p>}
        <button type="submit" disabled={inCorso}>
          {inCorso ? 'Un momento…' : 'Entra'}
        </button>
        <p className="nota">
          L'utenza nasce in Authentication e l'abilita l'amministrazione con una riga in
          <code> operatore</code>: senza, si entra e non si vede niente.
        </p>
      </form>
    </div>
  )
}
