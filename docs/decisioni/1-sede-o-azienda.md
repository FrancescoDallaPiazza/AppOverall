# 1 · Il fatto appartiene alla sede o all'azienda?

**Blocca la Fase 3.** Determina colonne dello schema.

## Cosa e in gioco

Quattro attributi: **livello di rischio, codice ATECO, livello antincendio, gruppo
di primo soccorso**. Sono dell'azienda, o della singola sede?

## Cosa dice gia il codice

AppSopralluoghi ha **gia deciso, e ha deciso «aziendali»**, con un commento
esplicito in `formazione.ts:1301`: gli attributi che guidano l'organigramma sono
AZIENDALI. Il motore legge sempre il cliente, anche nel percorso «per sede».

Le colonne duplicate su `sede` esistono — migrazione `054`, **sei** colonne, non
quattro — ma sono **in sola scrittura**: nessuna interfaccia le rende modificabili
per sede, e nessun motore le legge. Non sono una doppia verita attiva: sono colonne
morte.

## Cosa cambia secondo la risposta

- **Restano aziendali** — si cancellano sei colonne morte e si va avanti. E la
  strada che il codice ha gia imboccato.
- **Diventano della sede** — non e completare una direzione, e **invertirla**: il
  motore va riscritto, e va deciso cosa succede quando un cliente ha sedi con
  livelli di rischio diversi.

Da sapere prima di scegliere: una divergenza e gia possibile oggi.
`Formazione.tsx:258` aggiorna `cliente.rls_territoriale` senza scriverlo anche
sulla sede, e la copia resta stantia.

## Decisione

*(da scrivere)*
