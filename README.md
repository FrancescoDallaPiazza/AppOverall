# AppOverall

Il repo unico: **anagrafe, sicurezza e formazione** di Overall Group S.r.l.
Nasce il 9 settembre 2026 per unire AppSopralluoghi, AppFormazione e
Organigramma-sicurezza, che oggi implementano la stessa norma in posti diversi.

## La guardia e sciolta, il 9 settembre 2026

Questo repo e nato in **Fase 2**, e la Fase 2 non produce codice: produce righe
scritte. Il README portava una guardia — *finche le decisioni non sono prese, qui
non entra SQL* — perche due di quelle decisioni determinano colonne, e aggiungerle
dopo significa riscrivere le righe gia scritte.

**Le decisioni sono state prese lo stesso giorno**, e la guardia ha fatto il suo
lavoro per il tempo che serviva:

| scheda | decisa |
| --- | --- |
| 1 · sede o azienda | rischio, ATECO, antincendio e primo soccorso stanno sulla **sede** |
| 2 · chiave cliente | **P.IVA + sede**: un cliente, N sedi, un organigramma per sede |
| 4 · kitformasubito | resta dov'e, non entra: e un servizio che si lega al cliente |
| 7 · base normativa | la libreria resta il **generatore unico**, `reference/` la alimenta |
| 8 · scostamento ATECO | si annota accanto al default, con **motivazione, data e autore** |

Restano aperte tre schede — la 3 da confermare, la 5 e la 6 di norma — e **nessuna
delle tre blocca**: non determinano colonne.

La riga resta scritta qui invece di essere cancellata, perche una guardia tolta
senza dire quando e perche e indistinguibile da una guardia dimenticata.

## Cosa c'e

| dove | cosa |
| --- | --- |
| [`docs/PROGRAMMA.md`](docs/PROGRAMMA.md) | Il cronoprogramma: perimetro, i sei pilastri, le sei fasi con i criteri di uscita, cosa migra e le assunzioni numerate. **Testo canonico**: gli altri due repo ne portano un puntatore. |
| [`supabase/migrations/`](supabase/migrations/) | Lo schema. La `0001` porta le fondamenta e l'anagrafe con la grana decisa, e i pilastri che dopo non si aggiungono. |
| [`docs/decisioni/`](docs/decisioni/) | Una scheda per decisione. Vanno riempite dall'utente, non da noi: sono bivi che le verifiche hanno isolato e non possono sciogliere. |

## Dove sta il resto

Il piano dice **cosa** va fatto. Lo **stato** sta dove si lavora, perche le caselle
le riempie chi le chiude:

    ../AppSopralluoghi/docs/STATO.md     fase 0
    ../AppFormazione/docs/STATO.md       fase 1

E cosa e successo giorno per giorno sta nei due `docs/diario/`. I tre repo stanno
sullo stesso disco: per sapere cosa ha fatto l'altra corsia si guarda, non si chiede.
