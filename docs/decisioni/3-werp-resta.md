# 3 · WERP resta o muore?

> **Blocca:** la **Fase 4**, e solo se lo scadenzario deve generare commesse

**Blocca la Fase 4**, e solo se lo scadenzario deve generare commesse.

## Raccomandazione: resta

Il perimetro del repo unico e anagrafe + sicurezza + formazione; con preventivi,
incarichi e fatturazione ci si parla via Excel come gia oggi.

Il motivo e lo stesso del 26 agosto e oggi vale il doppio: riavviare il codice **e**
allargare il perimetro sono due rischi che si moltiplicano, non che si sommano. Se
WERP entra, non stiamo scrivendo un sistema di adempimenti: stiamo scrivendo un ERP,
e quello si affronta a fasi dichiarate.

## Cosa comporta confermarlo

- L'anagrafe si modella **sapendo che un giorno WERP potrebbe arrivare** — i campi
  `incarico.werp_id` e `azione.werp_attivita_id` sono gia predisposti, anche se
  nessuna sincronizzazione e attiva — ma senza inseguirlo.
- Nessuna API da nessuna parte: lo scambio resta **import periodico con
  riconciliazione**. Non e una fase, e il mestiere. Il modello giusto esiste gia:
  `werpImport` a sette stadi con dry-run.

## Decisione

*(da scrivere. Serve una conferma formale, perche riapre il perimetro deciso il
26 agosto.)*
