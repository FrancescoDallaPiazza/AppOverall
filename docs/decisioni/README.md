# Le decisioni

Una scheda per decisione. Non sono scelte tecniche: sono bivi che le verifiche
hanno isolato e non possono sciogliere, perche dipendono da come si vuole che
funzioni l'azienda, non da come funziona il codice.

Ogni scheda dice cosa e in gioco, cosa dicono gia il codice e le fonti, e cosa
blocca. La sezione **Decisione** e vuota: la riempie chi decide, con la data.

Una decisione scritta a meta non e presa. Il criterio di uscita della Fase 2 e che
in fondo a ogni scheda ci sia una riga, non un'opinione.

<!-- decisioni:inizio (generato da docs/decisioni/genera.py) -->

**12 schede su 12 sono chiuse.** Stato generato dalle schede: il paragrafo `## Decisione` di ognuna e la fonte, questa tabella e la resa.

| scheda | blocca | stato |
| --- | --- | --- |
| [1 · Il fatto appartiene alla sede o all'azienda?](1-sede-o-azienda.md) | la **Fase 3** · determina colonne dello schema | **decisa il 9 settembre 2026** — appartengono alla **sede**, per tre ragioni diverse; e il motore, che legge sempre il cliente, va riscritto |
| [2 · Qual e la chiave di un cliente?](2-chiave-cliente.md) | la **Fase 3** · determina colonne dello schema | **decisa il 9 settembre 2026** — la chiave è **P.IVA + sede**: un cliente, N sedi, un organigramma per sede |
| [3 · WERP resta o muore?](3-werp-resta.md) | niente · finché era aperta, la Fase 4 non sapeva se dovesse arrivare fino alla commessa | **decisa il 10 settembre 2026** — WERP resta il gestionale ma **perde la pianificazione**: incarichi e sedute di consulenza e RSPP passano alla nuova app, e WERP **si ferma al contratto** |
| [4 · Dove vive kitformasubito, e chi lo tiene?](4-kitformasubito.md) | niente subito · ma non deciderlo la fa rientrare dalla finestra fra sei mesi | **decisa il 9 settembre 2026** — resta dov’è, fuori dall’ecosistema, e si lega al cliente che lo chiede |
| [5 · Le divisioni 30, 86 e 87: alto rischio, o silenzio?](5-divisioni-non-classificate.md) | niente · ma finché era aperta, 32 codici ATECO non avevano classe | **decisa il 9 settembre 2026** — valgono **`ALTO`**, con la citazione della Gazzetta e la deduzione marcata separatamente dal valore |
| [6 · Il cliente con piu codici ATECO: si prende il piu alto?](6-piu-alto.md) | niente · finché le sedi non sono entità di prima classe | **decisa il 9 settembre 2026** — **dipende dalla mansione** — il «più alto» resta solo come default prudenziale per la sede multi-ATECO |
| [7 · Chi possiede la base normativa, e chi puo modificarla](7-base-normativa.md) | niente · è una decisione di governo, non di costruzione | **decisa il 9 settembre 2026** — la libreria `formazione-81-utils-src` resta il **generatore unico**, e `reference/` la alimenta |
| [8 · Dove si annota che il livello di rischio non viene dall'ATECO](8-scostamento-dal-rischio-ateco.md) | la **Fase 3** · determina colonne, insieme a quelle della decisione 1 | **decisa il 9 settembre 2026** — si annota in un **box accanto al default ATECO**, con motivazione, data e autore |
| [9 · Il catalogo formativo: si tiene il corso o l'obbligo, e con che chiave](9-grana-e-chiave-del-catalogo.md) | la **Fase 3** · determina la forma delle tabelle formative e la chiave a cui si aggancia tutto ciò che è già stato importato | **decisa il 10 settembre 2026** — la grana è l'**obbligo**, la chiave è il **codice curato**, e l'impronta `GEST-`+md5 del gestionale diventa un **alias** invece di un'identità |
| [10 · La sorveglianza sanitaria entra nel perimetro?](10-sorveglianza-sanitaria.md) | niente subito · ma decide se 808 accertamenti già raccolti hanno un posto, e allarga il perimetro del 26 agosto per la seconda volta | **decisa il 10 settembre 2026** — **entra, come dominio proprio** — accanto alla formazione e non dentro, perché l'art. 41 non è l'art. 37 |
| [11 · Il livello antincendio e il gruppo di primo soccorso: chi li confronta?](11-livelli-emergenza.md) | il **motore**, non lo schema · finché era aperta, un livello 1 valeva quanto un livello 3 | **decisa** — **tre stati** — livello definito e attestato pari o superiore: conforme; definito e inferiore: non conforme; **non definito: si segnala e non si blocca l'import** |
| [12 · Un corso con due durate: tre cause diverse, e un meccanismo non basta](12-le-durate-multiple.md) | il **motore**, e la `0006` limitatamente ai codici coinvolti · finché è aperta, il catalogo giudica col metro di oggi attestati validi sotto il metro di ieri | **decisa il 12 settembre 2026** — **decisa il 12 settembre 2026** — i meccanismi sono **tre** e sono entrati tutti e tre (validità temporale, condizione sulla dimensione con **tre** casi, un codice per variante combinata); il **quarto** — separare `PREPOSTO` — **non si fa finché non risponde l'Area Formazione**, perché tocca i dati già scritti e la domanda sotto non è di schema |

<!-- decisioni:fine -->
