# AppOverall · l'app dello scadenzario

La Fase 4 vista da chi la usa (`docs/piano-fase-4.md`): lo scadenzario che sostituisce
Sicurweb, la lista dei ruoli da confermare nell'organigramma, e il modulo con cui si
registrano gli attestati e le visite nuovi (decisione del 17 settembre 2026: spento
Sicurweb, si registrano qui).

React 18 + Vite + TypeScript + supabase-js, come `AppFormazione/app`.

## Le pagine

| Indirizzo | Cosa mostra | Da dove legge |
|---|---|---|
| `/` | un cliente per riga, formazione e visite separate, i piu urgenti in cima | `v_scadenzario_cliente` |
| `/cliente/:id` | le scadenze del cliente con i filtri, e i suoi promemoria | `v_scadenzario`, `v_promemoria` |
| `/scadenze` | le scadenze di tutti, filtrate e ordinate per priorita sul database | `v_scadenzario` |
| `/promemoria` | cosa sistemare nell'organigramma o nel catalogo: ruoli da confermare, livelli di emergenza, ruoli senza corso | `v_promemoria` |
| `/registra` | un attestato o una visita fatti; da una scadenza arriva compilato | scrive in `evento_formativo` e `sorveglianza` |

L'app non calcola le scadenze: le legge dal motore (`0026`, `0027`). L'ordine e la
**priorita** della `0029`: prima i corsi mancanti, poi le scadenze passate dalla piu
vecchia, poi quelle entro il preavviso.

Una scadenza si chiude **dalla sua riga** (pulsante «registra»): il modulo arriva con la
persona e il corso, e propone per primi i corsi che chiudono quell'obbligo
(`v_corso_per_obbligo`). Il corso si sceglie scrivendo parte del nome.

L'attestato porta gli **elementi minimi dell'ASR 2025** (Parte I, punto 6): soggetto
formatore, durata, modalita di erogazione, data e luogo, firma. Li pretende il database
(`0029`), non solo il modulo. Il modulo avvisa se l'attestato sembra un doppione: il
doppione si registra solo dopo averlo confermato.

## Il controllo dell'ASR 2025

Mentre si compila, il modulo chiede al database `controlla_attestato()` (`0030`): un
controllo **a regole fisse**, senza servizi esterni e senza leggere il PDF, che sullo
stesso attestato da sempre lo stesso esito. Una riga per regola, con la fonte:

| regola | cosa guarda |
|---|---|
| elementi minimi | i sei elementi della Parte I punto 6, codice fiscale compreso |
| data | attestato non nel futuro; prima del 24/05/2025 vale l'accordo del 2011 |
| modalita di erogazione | la tabella della Parte IV punto 3.5, corso per corso (`corso_modalita`) |
| durata | il minimo del catalogo, la classe di rischio per la formazione specifica, il regime precedente per gli attestati vecchi |
| formazione richiesta prima | il prerequisito del corso, e il corso base sotto un aggiornamento |
| soggetto formatore | i tipi della Parte I punto 1, con le condizioni da guardare |

Quattro esiti: **conforme**, **non conforme** (la regola e violata e si vede dai dati),
**da guardare** (dipende da un fatto che il database non ha) e **non si applica** (il
corso non e disciplinato dall'ASR: antincendio, primo soccorso, RLS, ponteggi…). Un
attestato non conforme si registra solo dopo averlo confermato, e l'esito del momento
resta scritto sulla riga (`controllo_esito`, `controllo_asr`).

## Leggere l'attestato

Nel modulo si puo scegliere il PDF dell'attestato, anche scansionato, o una foto. Il
file si legge **nel browser** e non esce dal PC: il testo del PDF com'e, le pagine
senza testo con l'OCR in italiano (Tesseract, che al primo uso scarica il modello da
jsdelivr). `src/estrai.ts` ne ricava a regole fisse codice fiscale (che cerca la
persona), corso (catalogo e titoli di `corso_alias`), data, ore, modalita e
aggiornamento; il resto si scrive a mano. La prova: `node prova/estrai.prova.ts`.
Il file **non si salva**: va nella cartella del cliente sul server, a mano.

Se il codice fiscale letto non e di nessuna persona in forza, la persona si aggiunge
da li (`0031`, `aggiungi_persona_da_attestato()`): cognome e nome sono le parole del
testo che danno le prime sei lettere del codice fiscale, la data di nascita viene dal
codice fiscale, il cliente lo sceglie chi registra. Resta nei Promemoria, «da riportare
nel gestionale», finche qualcuno non preme «riportata».

Le viste e i permessi sono nella `0028` e nella `0029`. Chi ha registrato una riga e
quando lo scrive un trigger, non il client; lo stesso trigger rifiuta le date nel futuro.
Registrare serve il livello 2 (tecnico, formazione, amministrazione): il lettore e chi
non e in `operatore` sono fermati dalle RLS, non solo dalla pagina.

## Avviarla

```sh
cp .env.example .env.local    # URL e anon key del progetto Supabase
npm install
npm run dev
```

La service_role key non entra mai qui.

## Il banco di prova

Finche AppOverall non ha il suo database, l'app si prova su dati **finti**: PostgreSQL con
tutte le migrazioni e i passi 01–07 della migrazione dati, e PostgREST davanti come in
Supabase.

```sh
POSTGREST=<percorso di postgrest.exe> UTENTE=tecnico bash prova/avvia.sh   # da app/
npm run prova                                                              # in un altro terminale
```

`UTENTE` e `amministrazione` (default), `tecnico`, `lettore` o `nessuno`. Il banco scrive
`.env.prova.local` con un token gia firmato (ignorato da git, cancellato alla chiusura) e
l'app entra senza password; in alto compare «banco di prova». Il `dist` di un build fatto
con quel file dentro contiene il token del banco: non si pubblica.
