import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import { supabase, tokenProva, utenteProva } from './supabase'
import type { Operatore } from './tipi'

type Stato = {
  /** L'id dell'utente autenticato, o null se non c'e nessuno. */
  utente: string | null
  operatore: Operatore | null
  caricando: boolean
  prova: boolean
  esci: () => Promise<void>
}

const Contesto = createContext<Stato | null>(null)

export function ProviderSessione({ children }: { children: ReactNode }) {
  const prova = Boolean(tokenProva)
  const [utente, setUtente] = useState<string | null>(prova ? utenteProva ?? null : null)
  const [operatore, setOperatore] = useState<Operatore | null>(null)
  const [caricando, setCaricando] = useState(true)

  useEffect(() => {
    if (prova) { setCaricando(false); return }
    supabase.auth.getSession().then(({ data }) => {
      setUtente(data.session?.user.id ?? null)
      setCaricando(false)
    })
    const { data: sub } = supabase.auth.onAuthStateChange((_e, s) => setUtente(s?.user.id ?? null))
    return () => sub.subscription.unsubscribe()
  }, [prova])

  // La riga di `operatore` e cio che `e_operatore()` interroga. Senza, l'utente e
  // autenticato e non vede niente: lo si dice, invece di mostrare tabelle vuote.
  useEffect(() => {
    if (!utente) { setOperatore(null); return }
    supabase
      .from('operatore')
      .select('id, cognome, nome, email, ruolo, attivo, ruolo_applicativo(livello)')
      .eq('utente_id', utente)
      .maybeSingle()
      .then(({ data }) => {
        if (!data) { setOperatore(null); return }
        const d = data as unknown as Operatore & { ruolo_applicativo: { livello: number } | null }
        setOperatore({ ...d, livello: d.ruolo_applicativo?.livello ?? 0 })
      })
  }, [utente])

  const esci = async () => {
    if (prova) return
    await supabase.auth.signOut()
  }

  return (
    <Contesto.Provider value={{ utente, operatore, caricando, prova, esci }}>
      {children}
    </Contesto.Provider>
  )
}

export function useSessione() {
  const v = useContext(Contesto)
  if (!v) throw new Error('useSessione fuori dal provider')
  return v
}
