# AppOverall

Il repo unico: **anagrafe, sicurezza e formazione** di Overall Group S.r.l.
Nasce il 9 settembre 2026 per unire AppSopralluoghi, AppFormazione e
Organigramma-sicurezza, che oggi implementano la stessa norma in posti diversi.

## Qui dentro non entra SQL

**Questo repo e in Fase 2, e la Fase 2 non produce codice: produce righe scritte.**
Finche le decisioni in [`docs/decisioni/`](docs/decisioni/) non sono prese, qui non
entrano ne migrazioni, ne schema, ne applicazione, ne CI. Non e prudenza: due di
quelle decisioni **determinano colonne dello schema**, e aprire prima significa
ricostruire con le mani pulite le stesse ambiguita che stiamo smontando.

Nel momento in cui un repo esiste, la tentazione di committarci lo schema e
concreta. Questa riga sta qui per quello.

## Cosa c'e

| dove | cosa |
| --- | --- |
| [`docs/PROGRAMMA.md`](docs/PROGRAMMA.md) | Il cronoprogramma: perimetro, i sei pilastri, le sei fasi con i criteri di uscita, cosa migra e le assunzioni numerate. **Testo canonico**: gli altri due repo ne portano un puntatore. |
| [`docs/decisioni/`](docs/decisioni/) | Una scheda per decisione aperta. Vanno riempite dall'utente, non da noi: sono bivi che le verifiche hanno isolato e non possono sciogliere. |

## Dove sta il resto

Il piano dice **cosa** va fatto. Lo **stato** sta dove si lavora, perche le caselle
le riempie chi le chiude:

    ../AppSopralluoghi/docs/STATO.md     fase 0
    ../AppFormazione/docs/STATO.md       fase 1

E cosa e successo giorno per giorno sta nei due `docs/diario/`. I tre repo stanno
sullo stesso disco: per sapere cosa ha fatto l'altra corsia si guarda, non si chiede.
