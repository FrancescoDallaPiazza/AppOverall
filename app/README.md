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
(`0029`), non solo il modulo. Il modulo avvisa se le ore sono meno di quelle del catalogo
e se l'attestato sembra un doppione: il doppione si registra solo dopo averlo confermato.

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
