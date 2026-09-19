// node prova/estrai.prova.ts (da app/)
import assert from 'node:assert/strict'
import { estrai } from '../src/estrai.ts'

const corsi = [
  { codice: 'CARRELLO', nome: 'Carrelli elevatori semoventi con conducente a bordo' },
  { codice: 'PREPOSTO', nome: 'Formazione del preposto' },
  { codice: 'LAV_GEN', nome: 'Formazione generale dei lavoratori' },
]

const pdf = `ATTESTATO DI FREQUENZA
Si attesta che ROSSI MARIO nato il 03/04/1980 codice fiscale RSSMRA80D03H501U
ha frequentato il corso Carrelli elevatori semoventi con conducente a bordo
della durata di 12 ore, erogato in presenza, concluso il 15 marzo 2025. Verona, 15/03/2025`

assert.deepEqual(estrai(pdf, corsi, '2026-09-19'), {
  codiceFiscale: 'RSSMRA80D03H501U', data: '2025-03-15', ore: '12',
  modalita: 'presenza', aggiornamento: false, corso: 'CARRELLO',
})

// Scansione: l'OCR legge O per 0 nel codice fiscale; e-learning; aggiornamento; ore con virgola.
const ocr = `Corso di aggiornamento Formazione del preposto - modalita e-learning
C.F. RSSMRA8OD03H5O1U   durata 6,5 ore   data 02-09-2024`
const e = estrai(ocr, corsi, '2026-09-19')
assert.equal(e.codiceFiscale, 'RSSMRA80D03H501U')
assert.equal(e.data, '2024-09-02')
assert.equal(e.ore, '6.5')
assert.equal(e.modalita, 'e_learning')
assert.equal(e.aggiornamento, true)
assert.equal(e.corso, 'PREPOSTO')

// Una data nel futuro non e la data del corso; niente di riconoscibile resta vuoto.
assert.equal(estrai('rilasciato il 01/01/2030', corsi, '2026-09-19').data, null)
assert.equal(estrai('testo qualunque', corsi, '2026-09-19').corso, null)

console.log('estrai: tutte le prove passano')
