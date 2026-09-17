# AppOverall · l'app dello scadenzario

La Fase 4 vista da chi la usa (`docs/piano-fase-4.md`): lo scadenzario che sostituisce
Sicurweb, la lista dei ruoli da confermare nell'organigramma, e il modulo con cui si
registrano gli attestati e le visite nuovi (decisione del 17 settembre 2026: spento
Sicurweb, si registrano qui).

React 18 + Vite + TypeScript + supabase-js, come `AppFormazione/app`.

## Le pagine

| Indirizzo | Cosa mostra | Da dove legge |
|---|---|---|
| `/` | un cliente per riga, i piu urgenti in cima | `v_scadenzario_cliente` |
| `/cliente/:id` | le scadenze del cliente e i suoi ruoli da confermare | `v_scadenzario`, `v_ruolo_da_confermare` |
| `/scadenze` | le scadenze di tutti, filtrate sul database | `v_scadenzario` |
| `/organigramma` | i corsi fatti che nessuna nomina segue | `v_ruolo_da_confermare` |
| `/registra` | un attestato o una visita fatti | scrive in `evento_formativo` e `sorveglianza` |

Le viste e i permessi sono nella `0028`. L'app non calcola scadenze: le legge dal motore
(`0026`, `0027`). Chi ha registrato una riga e quando lo scrive un trigger, non il client;
lo stesso trigger rifiuta le date nel futuro. Registrare serve il livello 2 (tecnico,
formazione, amministrazione): il lettore e chi non e in `operatore` sono fermati dalle RLS,
non solo dalla pagina.

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
