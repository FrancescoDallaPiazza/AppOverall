# 9 · Il catalogo formativo: si tiene il corso o l'obbligo, e con che chiave

> **Blocca:** la **Fase 3** · determina la forma delle tabelle formative e la chiave a cui si aggancia tutto ciò che è già stato importato

**Blocca la Fase 3.** È della stessa specie delle schede 1 e 8: determina colonne, e
aggiungerle dopo significa riscrivere le righe già scritte — con l'aggravante che
qui le righe da riscrivere sarebbero **13.215 eventi formativi**, non uno schema
vuoto.

## Cosa è in gioco

Sono due domande, e vanno risposte insieme perché la seconda dipende dalla prima.

**La grana.** I due repo contano cose diverse. AppSopralluoghi tiene il **corso**:
l'antincendio sono tre righe (`AI_LIV1/2/3`), il primo soccorso due (`PS_GRA`,
`PS_GRBC`), l'RSPP tre moduli (`RSPP_MOD_A/B/C`). AppFormazione tiene l'**obbligo**:
un solo `antincendio`, un solo `primo_soccorso`, un solo `rspp_aspp`, e il livello o
il gruppo stanno nei `requisiti`, non nel catalogo. Non è una differenza di nome: è
un'unità di conto diversa, e la stessa cosa si chiama `PONTEGGI` (corso),
`ponteggi_art136` (obbligo) e `ponteggi` (ruolo) in tre tabelle di due repo.

**La chiave.** `corso_catalogo` ha chiave primaria testuale; `corsi` ha un uuid, con
il codice solo `unique`. Nove chiavi esterne vive dipendono da questa differenza —
due sul codice, sette sull'uuid.

## Cosa dice già il codice

**I codici di AppSopralluoghi sono nostri, e sono stabili.** Quaranta codici
parlanti, curati a mano, dichiarati «chiave stabile» nel commento che li istituisce
(`015_formazione_organigramma.sql:52`). In 63 migrazioni non c'è **un solo**
`update corso_catalogo set codice`, e persino la deprecazione conserva il codice
invece di cancellarlo, perché gli attestati storici lo referenziano
(`049:49-59`). L'import Excel del catalogo si rifiuta di scrivere lì, e dice
perché: «la mappatura nome→codice è una **curatela**, non un import meccanico»
(`src/lib/admin/catalogoImport.ts:11-15`).

**I codici di AppFormazione non sono codici: sono impronte.** Per i corsi reali il
codice è `'GEST-' || left(md5(chiave), 8)`, dove `chiave` è il titolo del gestionale
passato per la nostra funzione di normalizzazione (`scripts/promuovi.sql:158`). Gli
autori lo dichiarano provvisorio: «il gestionale non ha una codifica, e va
sostituito quando il catalogo verrà rivisto» (`docs/05-import-storico.md:125-127`).

**E infatti è già cambiato.** La migrazione `0020` ha corretto un `btrim` mancante
dentro `staging.norm`, e cambiata la normalizzazione è cambiata l'impronta: **41
corsi su 163 hanno cambiato codice** in un colpo solo (`0020:53`). La riga di
commento che spiega perché era necessario dice tutto: «senza questa riscrittura la
prossima promozione creerebbe 41 corsi doppi».

**Sulla grana, AppFormazione si è già mossa una volta, e in una direzione sola.** La
`0036` ha fatto `drop table requisiti` e ha rifatto le regole sugli obblighi, con la
motivazione scritta: «la sua forma legava una regola a un titolo di catalogo»
(`0036:91-94`). Le due chiavi esterne verso `corsi(id)` che c'erano lì dentro non
esistono più.

**La libreria normativa non decide per noi.** Verificato: `formazione-81-utils-src`
genera l'Allegato IV per divisione ATECO e le durate per classe di rischio. Non
genera un catalogo corsi né un elenco di obblighi con codice. Ma tutte le chiavi che
genera sono **testuali e parlanti** (`'56.10.20'`, `'BASSO'`), perché — dice la
scheda 7 — la libreria è «il posto dove finisce ciò che ha una chiave».

## Raccomandazione: l'obbligo per la grana, il codice curato per la chiave — e l'impronta diventa un alias

Le due risposte, prese insieme, **sciolgono la collisione invece di sceglierne un
lato**.

**Grana: l'obbligo.** È dove il motore ragiona già dalla `0024`, ed è già scritto
nel cronoprogramma il perché: i titoli cambiano e gli obblighi no. Il corso resta,
ma come **catalogo di erogazione** agganciato all'obbligo che assolve, non come
soggetto della regola.

**Chiave: il codice testuale curato.** È il precedente che questo repo ha già
adottato due volte — `ruolo_applicativo` nella `0001`, `ruolo_sicurezza` nella
`0002` — con la motivazione che un uuid costringe a una join per capire cosa c'è
scritto, in tabelle che si leggono nelle migrazioni dati e negli scarti dell'import.

**E l'uuid di AppFormazione proteggeva la cosa sbagliata.** L'argomento più forte a
suo favore è vero: senza uuid, la riscrittura dei 41 codici sarebbe stata una
cascata su 13.215 righe invece di una riga sola. Ma quella riscrittura è successa
**perché il codice era derivato dal titolo**. Se l'impronta `GEST-…` smette di
essere un'identità e diventa quello che è davvero — la chiave di un **alias**,
calcolata sul titolo normalizzato del gestionale, esattamente come i 268 alias del
campo — allora cambiare la normalizzazione non tocca più nessuna identità: si
ricalcola l'alias e si rimappa. Il problema non si risolve meglio, **smette di
esistere**.

Stesso discorso per la collisione BLS-D, dove due righe di catalogo finiscono sulla
stessa impronta: come alias sono due testi del gestionale che puntano allo stesso
corso, che è già ciò che `corso_alias` fa per l'iniziale e l'aggiornamento.

## Cosa comporta

- I **40 codici curati** del campo migrano invariati, e con loro le due chiavi
  esterne testuali e i punti in cui il motore li ha scritti in TypeScript.
- I **~163 corsi del gestionale** non portano dentro la loro impronta come
  identità: si agganciano per alias. Ognuno vuole un codice curato — è **lavoro
  nuovo**, ed è il costo vero di questa strada. Ma non parte da zero: i 268 alias
  del campo sono già una curatela su quei testi, 237 dei quali mappati sui 40
  codici.
- L'`equivalenze_corsi` è vuota, quindi le sue due chiavi esterne uuid costano zero.
- Le due tabelle che pesano — `edizioni` e `eventi_formativi`, 13.215 righe —
  vanno risolte una volta sola in migrazione, per alias, e la risoluzione va
  **verificata prima di scrivere**, non dopo.
- Va scritto **da subito** che l'impronta del gestionale è un alias e non una
  chiave, altrimenti la prima persona che vede `GEST-a1b2c3d4` la tratta da codice.

## Cosa la rende diversa dalle altre schede

Le otto precedenti erano bivi che il codice non poteva sciogliere. Questa lo è a
metà: sulla **grana** il progetto ha già scelto due volte e l'ha motivato per
iscritto, quindi la scheda serve a **ratificare**, non a decidere da zero. Sulla
**chiave** la scelta è aperta davvero, e il fatto nuovo che la orienta — che il
codice di AppFormazione sia un'impronta già cambiata su 41 righe — è emerso il 10
settembre 2026 e non era scritto in nessuno dei due piani.

## Decisione

*(da scrivere. Serve prima della prima migrazione formativa: è quella che crea le
tabelle di cui questa scheda decide la forma.)*
