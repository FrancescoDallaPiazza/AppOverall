// AppOverall — migrazione dati: genera allegato_iv.sql dalla libreria normativa.
//
//   node genera_allegato_iv.js <cartella di formazione-81-utils-src> > allegato_iv.sql
//
// Il passo 06 deve sapere se il livello di rischio di un cliente d'origine e' quello
// che l'Allegato IV da' alla sua divisione — perche' se lo e', la decisione 8 dice di
// NON scriverlo: il default si ricalcola, e si annota solo lo scostamento. Quella
// tabella non sta nel database di AppOverall, e non ci deve stare (decisione 8: «non
// nella libreria» vale anche al contrario — le tabelle deterministiche stanno li').
// Quindi la migrazione dati ne carica una COPIA in `origine`, che vive quanto la
// migrazione e poi si cancella con lo schema.
//
// La copia non si scrive a mano: si genera da qui, e il file generato porta il
// commit della libreria da cui viene. Se la libreria cambia, si rigenera.

'use strict';

const path = require('path');
const { execFileSync } = require('child_process');

const radice = process.argv[2];
if (!radice) {
  console.error('uso: node genera_allegato_iv.js <cartella di formazione-81-utils-src>');
  process.exit(1);
}

const { ALLEGATO_IV } = require(path.resolve(radice, 'allegato_iv_asr2025.js'));
const commit = execFileSync('git', ['-C', radice, 'log', '-1', '--format=%h', '--', 'allegato_iv_asr2025.js'])
  .toString().trim();

const q = (s) => (s == null ? 'null' : "'" + String(s).replace(/'/g, "''") + "'");
const righe = Object.keys(ALLEGATO_IV).sort().map((div) => {
  const r = ALLEGATO_IV[div];
  if (!/^\d{2}$/.test(div)) throw new Error('divisione non a due cifre: ' + div);
  if (!['BASSO', 'MEDIO', 'ALTO'].includes(r.livello)) throw new Error('livello sconosciuto su ' + div);
  return `  (${q(div)}, ${q(r.sezione)}, ${q(r.livello.toLowerCase())}, ${r.dedotto === true}, ${q(r.fonte || null)})`;
});

process.stdout.write(`-- AppOverall — migrazione dati: l'Allegato IV, copia per la sola migrazione.
--
-- GENERATO da genera_allegato_iv.js, non si modifica a mano.
-- Fonte: formazione-81-utils-src, allegato_iv_asr2025.js, commit ${commit}.
-- ${righe.length} divisioni ATECO 2007 agg. 2022. \`dedotto\` = il valore non si legge nel
-- testo vigente e viene dal 2011 (decisione 5): si porta, perche' chi confronta deve
-- poter dire quanta deduzione c'e' nel default.
--
-- A grana di divisione ATECO 2007 e ATECO 2022 sono lo stesso insieme di 88 codici
-- (AppFormazione, migrazione 0048), e l'allegato dice di se' «ancorata ad ATECO 2007
-- agg. 2022»: il valore '2007' di \`sede.ateco_versione\` e' questo.

create table if not exists origine.allegato_iv (
  divisione text primary key,
  sezione text not null,
  livello text not null check (livello in ('basso', 'medio', 'alto')),
  dedotto boolean not null,
  fonte text
);

insert into origine.allegato_iv (divisione, sezione, livello, dedotto, fonte) values
${righe.join(',\n')}
on conflict (divisione) do nothing;
`);
