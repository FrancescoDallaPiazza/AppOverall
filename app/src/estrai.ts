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
  ente: string | null
  luogo: string | null
  cognome: string | null       // per aggiungere chi non e in anagrafe
  nome: string | null
  nascita: string | null
}

const CF = /\b[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]\b/

// L'OCR confonde le cifre con le lettere: nelle posizioni numeriche del codice fiscale
// O vale 0, I vale 1 e cosi via. Solo li, non nel resto del testo.
function codiceFiscale(testo: string): string | null {
  const t = testo.toUpperCase().replace(/[^A-Z0-9\s]/g, ' ')
  const esatto = t.match(CF)
  if (esatto) return esatto[0]
  // Scritto a gruppi: «BRN DVD 94E04 B296W».
  const unito = t.replace(/\s+/g, '').match(new RegExp(CF.source.replaceAll('\\b', '')))
  if (unito) return unito[0]
  const cifre: Record<string, string> = { O: '0', I: '1', Z: '2', S: '5', B: '8' }
  for (const parola of t.split(/\s+/)) {
    if (parola.length !== 16) continue
    const p = parola.split('').map((c, i) => ([6, 7, 9, 10, 12, 13, 14].includes(i) ? cifre[c] ?? c : c)).join('')
    if (CF.test(p)) return p
  }
  return null
}

// Le tre lettere del codice fiscale per un cognome o un nome (DM 23/12/1976).
function tripla(parole: string, nome: boolean): string {
  const l = parole.toUpperCase().normalize('NFD').replace(/[^A-Z]/g, '')
  let cons = l.replace(/[AEIOU]/g, '')
  if (nome && cons.length >= 4) cons = cons[0] + cons[2] + cons[3]
  return (cons + l.replace(/[^AEIOU]/g, '') + 'XXX').slice(0, 3)
}

// Cognome e nome: le due-cinque parole consecutive del testo le cui lettere danno le
// prime sei del codice fiscale, in un ordine o nell'altro. Senza etichette da cercare.
function nominativo(testo: string, cf: string): { cognome: string; nome: string } | null {
  const parole = testo.match(/[A-Za-zÀ-ÿ']+/g) ?? []
  for (let i = 0; i < parole.length; i++) {
    for (let n = 2; n <= 5 && i + n <= parole.length; n++) {
      const w = parole.slice(i, i + n)
      for (let k = 1; k < n; k++) {
        const a = w.slice(0, k).join(' '), b = w.slice(k).join(' ')
        if (tripla(a, false) + tripla(b, true) === cf.slice(0, 6)) return { cognome: a, nome: b }
        if (tripla(b, false) + tripla(a, true) === cf.slice(0, 6)) return { cognome: b, nome: a }
      }
    }
  }
  return null
}

// La data di nascita scritta nel codice fiscale. Le lettere di omocodia tornano cifre;
// il secolo e il piu recente che non la mette nel futuro.
function nascita(cf: string, oggi: string): string | null {
  const cifra = (c: string) => ('LMNPQRSTUV'.includes(c) ? String('LMNPQRSTUV'.indexOf(c)) : c)
  const n = (s: string) => Number(s.split('').map(cifra).join(''))
  const aa = n(cf.slice(6, 8)), mese = 'ABCDEHLMPRST'.indexOf(cf[8]) + 1, giorno = n(cf.slice(9, 11)) % 40
  if (!mese || !giorno) return null
  let anno = 2000 + aa
  const d = () => `${anno}-${String(mese).padStart(2, '0')}-${String(giorno).padStart(2, '0')}`
  if (d() > oggi) anno -= 100
  return d()
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

// Il valore dopo un'etichetta, fino a fine riga o a un salto di piu spazi.
function dopo(testo: string, etichetta: RegExp): string | null {
  const m = testo.match(new RegExp(`${etichetta.source}\\s*:?\\s*(.+?)(?:\\s{2,}|\\n|$)`, 'i'))
  return m ? m[1].trim() : null
}

export function estrai(testo: string, corsi: CorsoNome[], oggi: string): Estratto {
  const cf = codiceFiscale(testo)
  const chi = cf ? nominativo(testo, cf) : null
  return {
    codiceFiscale: cf,
    data: dataCorso(testo, oggi),
    ore: ore(testo),
    modalita: modalita(testo),
    aggiornamento: /aggiornamento/i.test(testo),
    corso: corso(testo, corsi),
    ente: dopo(testo, /(?:soggetto (?:che ha organizzato il corso|formatore|organizzatore)|ente formatore|organizzato da)/),
    cognome: chi?.cognome ?? null,
    nome: chi?.nome ?? null,
    nascita: cf ? nascita(cf, oggi) : null,
    luogo: dopo(testo, /\bluogo(?! di nascita)/),
  }
}
