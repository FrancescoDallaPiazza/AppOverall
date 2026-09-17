import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const anon = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!url || !anon) {
  throw new Error(
    'Mancano VITE_SUPABASE_URL o VITE_SUPABASE_ANON_KEY. Copia app/.env.example in app/.env.local e riempile, ' +
    'oppure avvia il banco di prova (app/prova/avvia.sh) e usa npm run prova.'
  )
}

/**
 * Nel banco di prova non c'e il servizio di autenticazione di Supabase: c'e un token
 * gia firmato, che PostgREST verifica e le policy leggono con auth.uid(). L'app lo
 * manda come farebbe con una sessione vera.
 */
export const tokenProva: string | undefined = import.meta.env.VITE_PROVA_TOKEN
export const utenteProva: string | undefined = import.meta.env.VITE_PROVA_UTENTE

export const supabase = createClient(url, anon, {
  global: tokenProva ? { headers: { Authorization: `Bearer ${tokenProva}` } } : undefined,
  auth: tokenProva ? { persistSession: false, autoRefreshToken: false } : undefined,
})

/** Il tetto di PostgREST su Supabase e 1000 righe per richiesta. */
export const LIMITE = 1000
