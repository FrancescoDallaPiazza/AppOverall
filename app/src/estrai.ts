/**
 * Dal testo di un attestato ai campi del modulo. Regole fisse, nessun servizio esterno:
 * quello che non si trova resta vuoto, e ogni campo trovato lo controlla chi registra.
 * La prova: `node prova/estrai.prova.ts`.
 */

export type CorsoNome = { codice: string; nome: string }

export type Estratto = {
  codiceFiscale: string | null
  data: string | null          // aaaa-mm-gg
  ore: string | null
  modalita: string | null
  aggiornamento: boolean
  corso: string | null         // codice del catalogo
}

const CF = /\b[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]\b/

// L'OCR confonde le cifre con le lettere: nelle posizioni numeriche del codice fiscale
// O vale 0, I vale 1 e cosi via. Solo li, non nel resto del testo.
function codiceFiscale(testo: string): string | null {
  const t = testo.toUpperCase().replace(/[^A-Z0-9\s]/g, ' ')
  const esatto = t.match(CF)
  if (esatto) return esatto[0]
  const cifre: Record<string, string> = { O: '0', I: '1', Z: '2', S: '5', B: '8' }
  for (const parola of t.split(/\s+/)) {
    if (parola.length !== 16) continue
    const p = parola.split('').map((c, i) => ([6, 7, 9, 10, 12, 13, 14].includes(i) ? cifre[c] ?? c : c)).join('')
    if (CF.test(p)) return p
  }
  return null
}

const MESI = ['gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', 'luglio',
  'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre']

// ponytail: la data del corso e la piu recente non nel futuro — la data di nascita e
// sempre piu vecchia. Sbaglia se sull'attestato c'e una data di rilascio posteriore.
function dataCorso(testo: string, oggi: string): string | null {
  const date: string[] = []
  const due = (n: string) => n.padStart(2, '0')
  for (const m of testo.matchAll(/\b(\d{1,2})\s*[/.-]\s*(\d{1,2})\s*[/.-]\s*(\d{4})\b/g)) {
    if (+m[2] >= 1 && +m[2] <= 12 && +m[1] >= 1 && +m[1] <= 31) date.push(`${m[3]}-${due(m[2])}-${due(m[1])}`)
  }
  for (const m of testo.toLowerCase().matchAll(new RegExp(`\\b(\\d{1,2})\\s+(${MESI.join('|')})\\s+(\\d{4})\\b`, 'g'))) {
    date.push(`${m[3]}-${due(String(MESI.indexOf(m[2]) + 1))}-${due(m[1])}`)
  }
  const buone = date.filter((d) => d <= oggi).sort()
  return buone.length ? buone[buone.length - 1] : null
}

function ore(testo: string): string | null {
  const m = testo.match(/\b(\d{1,3}(?:[.,]\d{1,2})?)\s*(?:ore|h)\b/i)
  return m ? m[1].replace(',', '.') : null
}

function modalita(testo: string): string | null {
  const t = testo.toLowerCase()
  const elearning = /e-?\s?learning|fad asincrona/.test(t)
  const video = /videoconferenza|fad sincrona/.test(t)
  const presenza = /in presenza|in aula\b/.test(t)
  if ([elearning, video, presenza].filter(Boolean).length > 1) return 'mista'
  return elearning ? 'e_learning' : video ? 'videoconferenza_sincrona' : presenza ? 'presenza' : null
}

// Parole senza accenti e senza l'ultima lettera: «carrelli elevatori» e «carrello
// elevatore» sono le stesse.
const radici = (s: string) => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
  .split(/[^a-z0-9]+/).filter((p) => p.length > 3).map((p) => p.slice(0, -1))

// Il corso con la quota piu alta di parole del nome ritrovate nel testo. I nomi sono
// quelli del catalogo e i titoli del dizionario (corso_alias). Sotto l'80%, o a pari
// merito fra due corsi diversi, non si sceglie.
function corso(testo: string, corsi: CorsoNome[]): string | null {
  const parole = new Set(radici(testo))
  let migliore: string | null = null, punteggio = 0, pari = false
  for (const c of corsi) {
    const sue = radici(c.nome)
    if (!sue.length) continue
    const q = sue.filter((p) => parole.has(p)).length / sue.length + sue.length / 1000
    if (q > punteggio) { migliore = c.codice; punteggio = q; pari = false }
    else if (q === punteggio && c.codice !== migliore) pari = true
  }
  return punteggio >= 0.8 && !pari ? migliore : null
}

export function estrai(testo: string, corsi: CorsoNome[], oggi: string): Estratto {
  return {
    codiceFiscale: codiceFiscale(testo),
    data: dataCorso(testo, oggi),
    ore: ore(testo),
    modalita: modalita(testo),
    aggiornamento: /aggiornamento/i.test(testo),
    corso: corso(testo, corsi),
  }
}
