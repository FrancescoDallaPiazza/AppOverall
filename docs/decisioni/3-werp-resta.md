# 3 · WERP resta o muore?

> **Blocca:** niente · finché era aperta, la Fase 4 non sapeva se dovesse arrivare fino alla commessa
> **In una riga:** WERP resta il gestionale ma **perde la pianificazione**: incarichi e sedute di consulenza e RSPP passano alla nuova app, e WERP **si ferma al contratto**

**Non blocca più niente.** Finché era aperta, la Fase 4 non sapeva se lo scadenzario
dovesse arrivare fino alla commessa: la risposta è no, e insieme è arrivata una cosa
che la scheda non chiedeva — la pianificazione esce da WERP.

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

## La risposta non è «dentro o fuori»: è una fetta che esce

La scheda poneva un bivio a due strade — WERP entra o resta fuori — e la risposta è una terza
cosa: **resta, e perde un pezzo.** Il pezzo è la pianificazione delle attività di
consulenza e RSPP.

Il codice attuale mostra perché quel pezzo è nel posto sbagliato. `werpImport` non
riceve un piano: lo **ricostruisce leggendo prosa**. In
`AppSopralluoghi/src/lib/admin/werpImport.ts` ci sono espressioni regolari che
cercano «N. 2 sopralluoghi…» o «SOPRALLUOGHI PERIODICI in n. di 1/anno» nella
*Descrizione* dei documenti WERP per dedurre quante sedute spettano al cliente
(`derivaContratto`, `estraiN`); se incontrano il segnaposto del template ancora
vuoto — `N./`, `N. XX` — la riga finisce in **«da chiarire»**. E per sapere quante
sedute sono state fatte, `contaFatti` filtra l'export attività cercando
`/soprall/i` nella descrizione.

Il numero di sopralluoghi di un incarico RSPP è quindi scritto in un testo libero,
e noi lo indoviniamo. Spostare la pianificazione **non aggiunge una funzione:
elimina una deduzione.**

## Decisione

**Presa da Francesco il 10 settembre 2026.** Nelle sue parole:

> «Voglio togliere da WERP la parte di pianificazione delle attività/sopralluoghi
> legate alle consulenze/RSPP, che invece farei fare alla nuova app.»

E, sul ritorno: **WERP si ferma al contratto.** Non riceve indietro le sedute
chiuse; il contratto e la fattura seguono il canone, non la singola seduta, e il
consuntivo si guarda nella nuova app.

**Il confine, adesso:**

| dominio | owner |
| --- | --- |
| contratto, preventivo, commessa, fattura | **WERP** |
| incarico (quante sedute, in che periodo, con che cadenza) | **la nuova app** |
| seduta: tecnico assegnato, data, checklist, esiti, cose da fare | **la nuova app** |
| anagrafica commerciale del cliente | WERP, che la esporta |

**Cosa comporta:**

- non nasce nessuna integrazione nuova: cambia **la proprietà del dato**. Il pezzo
  applicativo esiste già — `incarico` a cadenza o a numero fisso, `Pianificazione.tsx`,
  `EditorIncarico.tsx`, la disponibilità dei tecnici in percentuale;
- `derivaContratto` e `contaFatti` **cambiano ruolo**: da fonte della verità a
  **migrazione una volta sola**. Si leggono i contratti in essere per seminare gli
  incarichi, e dopo non si deduce più niente da una descrizione. Il lettore a sette
  stadi non si butta: diventa uno strumento di caricamento iniziale;
- le attività di consulenza e RSPP **smettono di essere pianificate in WERP** dalle
  persone. È l'unico punto in cui il perimetro si allarga rispetto al 26 agosto, e
  va scritto come allargamento consapevole invece di essere lasciato implicito;
- **non diventa un ERP**: preventivi, commesse e fatturazione restano di là, ed è
  quello che il 26 agosto voleva proteggere;
- i campi di raccordo (`incarico.werp_id`, `azione.werp_attivita_id`, l'ID Werp sul
  cliente) restano, ma come **raccordo di lettura** — non c'è nessuna direzione in
  uscita da costruire, e il canale col fornitore che `AppSopralluoghi/docs/PROGETTO.md`
  dichiara «da chiarire» **non serve più** per la Fase 4.

### Cosa resta da verificare, ma non blocca

Se in WERP le attività servano anche a qualcosa che non è il sopralluogo — per
esempio a consuntivare il tempo delle persone. La decisione toglie di là **la
pianificazione delle sedute**, non necessariamente ogni uso della parola
«attività»: si guarda quando si legge un export a mente fresca, e se emerge un
secondo uso si scrive qui.
