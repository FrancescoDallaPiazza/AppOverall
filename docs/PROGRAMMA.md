# Cronoprogramma del repo unico

**Testo canonico.** Questo file e l'originale. La pagina condivisibile
(https://claude.ai/code/artifact/8116d53d-6944-4ce0-a9c0-29a1e072d763) ne e la resa;
AppFormazione e AppSopralluoghi ne portano un puntatore, non una copia. Un piano
scritto in due posti diverge come diverge una norma scritta in tre — che e il
problema da cui e nato tutto questo. Le correzioni si fanno qui, e da qui si
ripubblica.

Redatto il 9 settembre 2026, fondendo due programmi scritti in parallelo in due
sessioni. Poggia sul dossier di verifica dello stesso giorno, sul censimento dei
quindici repo dell'account e sul confronto delle letture dell'Allegato IV.

---

## 1. Il perimetro

Riavviare il codice **e** allargare il campo d'azione sono due rischi che si
moltiplicano, non che si sommano.

| Repo | Esito | Destino |
|---|---|---|
| AppSopralluoghi | dentro | Unica con `sede` come entita, unico punto dove WERP e Sicurweb convergono. Porta l'anagrafe. Il campo migra per ultimo. |
| AppFormazione | dentro | Corpus con le citazioni, schema provato su dati veri, raccordo ATECO. |
| Organigramma-sicurezza | assorbito | Terza copia del corpus e quarta app dell'organigramma. Entra per essere assorbito, non mantenuto. Da li vengono le trascrizioni `.txt` degli accordi. |
| formazione-81-utils-src | **base normativa** | Non e un'applicazione: **genera** `ateco.ts` e, in prospettiva, le tabelle del repo unico. Decisione 7: resta il generatore unico e `reference/` la alimenta. Non viene dismessa con la Fase 5. |
| kitformasubito ×2 | fuori | Erogazione. E vivo e resta vivo: va detto **dove vive e chi lo tiene**, o fra sei mesi rientra. |
| WERP | fuori, **meno la pianificazione** | Decisione 3: resta il gestionale — contratto, preventivo, commessa, fattura — e **perde la pianificazione delle attivita di consulenza e RSPP**, che passa alla nuova app. Scambio via Excel in entrata, e **nessuna direzione in uscita**: WERP si ferma al contratto. |
| AppCorsiOverall, AppHr, sito, IPE | fuori | Escluse per decisione o linea di business diversa. Non vanno aperte. |

Togliendo l'erogazione, il sistema nuovo **non e in concorrenza con ASSIDAL**: non
deve rispondere a «chi emette», ma solo a «chi certifica e chi archivia».

## 2. Le sei cose che non si aggiungono dopo

Sono il motivo per cui il repo e nuovo invece che riparato. Ognuna e un difetto
gia misurato. Ed e anche il motivo per cui riscrivere lo strato applicativo costa
meno di quanto sembri: quel codice e gia condannato a prescindere.

1. **Viste come strato di indirezione** — zero `create view` in AppSopralluoghi.
   **Non nell'altro repo**: AppFormazione ne ha 29, e non e un dettaglio (vedi 2).
2. **RLS che isolano davvero.** Questa riga diceva «oggi **tutte** `using (true)
   with check (true)`», e faceva di due repo un mucchio solo. **Corretta il 10
   settembre 2026**, contando: AppSopralluoghi ne ha **17**; AppFormazione ne ha
   **zero**, e dichiara `security_invoker` su **28 viste su 29** al momento del
   censimento — **29 su 29** dalla sua migrazione `0056`, poche ore dopo, che ha
   chiuso l'unica scoperta.

   La correzione non e cosmetica, perche da quella riga la `0001` aveva tratto
   una conseguenza operativa — «non c'e isolamento da replicare, va scritto da
   zero» — e ha percio riprodotto un difetto che **l'altro repo aveva gia
   risolto**: viste che, senza `security_invoker`, eseguono coi diritti del
   proprietario e scavalcano le policy. Scoperto due giorni dopo scrivendo la
   `0002`, chiuso con la `0003`. Non era un difetto ignoto al progetto: era ignoto
   a noi, perche il censimento aveva unito due repo che su questo punto sono
   **opposti**.

   E la stessa forma di errore della decisione 7 — un censimento fatto sulla cosa
   sbagliata perde cio che sta a monte.
3. **Un solo vocabolario di ruoli** — oggi due insiemi senza un valore in comune,
   e con **una distinzione che nessuno dei due fa**: il datore di lavoro che svolge
   in proprio i compiti di RSPP (**art. 34**) non e un RSPP (**art. 32**). Sono due
   figure, due percorsi formativi e due scadenze. Misurato il 9 settembre: 28 nomine
   RSPP e 14 persone col corso professionale, sovrapposizione **zero** — una
   disgiunzione perfetta non e un caso, era una colonna mappata male, e 26 delle 28
   erano datori dell’art. 34. Se il vocabolario nuovo non separa i due valori, lo
   stesso errore si riscrive alla prima migrazione e stavolta con la provenienza
   che lo fa sembrare verificato. **La distinzione non e da inventare**: il catalogo
   di AppFormazione tiene gia i due gruppi d'obbligo separati — `datore_lavoro_rspp`
   e `rspp_aspp`, migrazione `0022` — e nell'export i due percorsi si distinguono da
   soli, 31 righe di corso per datore contro 7 di moduli A/B/C professionali. Il
   vocabolario nuovo eredita quella separazione invece di rifarla.
4. **Provenienza su ogni riga formativa** — a tre valori: Sicurweb, ASSIDAL, kit.
5. **Navigazione con URL** — oggi cinque livelli di stato annidato, zero URL.
6. **Concorrenza ottimistica** — `updated_at` c'e ma nessuno lo legge.

## 3. Le fasi

Le fasi 0 e 1 corrono in parallelo in due repo. Dalla 3 in poi e una fila.

> **Questo foglio dice cosa va fatto, non a che punto e.** Lo stato sta dove si
> lavora, perche le caselle le riempie chi le chiude e nessuna delle due corsie
> scrive nel repo dell'altra:
>
> - fase 0 -> `AppSopralluoghi/docs/STATO.md`
> - fase 1 -> `AppFormazione/docs/STATO.md`
>
> Un piano che tiene anche lo stato nasce scaduto: la prima versione di questo
> file segnava aperti i sette buchi dell'import sessanta minuti dopo che erano
> stati chiusi.

### Fase 0 — Tenere a galla la barca · AppSopralluoghi

- **D1** cache voci sui template composti — una riga, col caveat RLS nel commento
- **D4** `tecnico.cognome` — la migrazione mai scritta, idempotente
- **D3** quarantena della coda offline — classificazione dell'errore e quarantena
- **D2** il report non conosce i componenti — richiede un deploy di Edge Function
- La schermata della quarantena: il dato c'e, l'interfaccia no
- I sette buchi dell'import: 847 indirizzi persi, `ATTIVA` ignorata con 229 ex
      clienti vivi, P.IVA fittizie, cessati come attivi, 233 persone senza CF
- L'ATECO mancante sul 57% delle attive — **non aspetta piu**: il raccordo e a monte
- **L'import dei ruoli sicurezza** — voce nuova, emersa il 9 settembre: il foglio
      «Ruoli SSL» dell'export contiene i ruoli **con la data dell'incarico**, e
      `formazioneImport.ts` legge solo il primo foglio e crea solo nomine
      `lavoratore`. Finche quel foglio non entra, gli attestati importati sono muti:
      il motore ricava i requisiti dalle **nomine**, non dagli attestati

**Criterio di uscita.** Un tecnico lavora offline senza restare bloccato, e le 619
aziende attive sono rientrate nel database, vuoto dal 5 agosto.

**L'ordine non ha piu oggetto, e la riga che c'era qui era una trappola.** Questo
paragrafo diceva che l'azzeramento dei dati operativi andasse prima dell'import dei
ruoli. **Misurato il 10 settembre 2026 sul database di produzione di AppSopralluoghi**
(`pvbwcfrgatkqashstxjc`, `main`): non c'e niente da azzerare. `nomina`, `formazione`,
`esonero`, `adempimento`, `azione`, `incarico`, `sopralluogo`, `esito_voce`, `foto`
sono **tutte a zero**; ci sono 619 clienti, 619 sedi, 3.419 persone (3.419 marcate
`anag:%`, zero senza), i 268 alias e la config intatta.

Tutte le tabelle che `azzera_anagrafiche.sql` prende di mira erano gia vuote: **il
database e gia nello stato che l'azzeramento doveva produrre.** Lanciarlo oggi non
pulirebbe una prova, cancellerebbe le anagrafiche — cioe il lavoro che la Fase 0
registra come fatto e da non rifare.

**Chiuso da Francesco il 10 settembre 2026: «non c'e nessun azzeramento da fare, era
una mia idea a voce.»** Non e un impegno rinviato, e un'ipotesi ritirata: non va
riproposta, e nessun import aspetta piu una pulizia.

E infatti **nessun repo registrava un azzeramento in sospeso**: cercato in tutti e tre. In
AppSopralluoghi `TODO.md` racconta l'azzeramento del **5 agosto**, che e un fatto
passato, non un impegno; in AppFormazione il carico del 9 settembre (216 ruoli su 121
persone) e dichiarato come **misura su dati veri**, non come dati di prova da
buttare. Quindi la fase di prova non ha un azzeramento pendente da nessuna parte, e
l'import dei ruoli non aspetta niente.

> **Un vincolo che vale per tutte e tre le corsie:** il piano Supabase e **free**,
> quindi **non ci sono backup automatici**. Ogni cancellazione e definitiva davvero, e
> uno script distruttivo non si lancia perche il suo nome descrive l'intenzione: si
> lancia dopo aver contato le righe che colpisce.

Il lettore Excel e TypeScript puro sui file: le riparazioni all'import **viaggiano
con il codice** nel repo nuovo. Si scrivono una volta sola.

### Fase 1 — Chiudere le fonti · AppFormazione

- **Asse A**, la lettura della norma: mettere a confronto le letture dell'Allegato
  IV e stabilire se il repo unico eredita una regola sola o una divergenza
- **Asse B**, l'annata del codice: il nostro raccordo contro quello della libreria
- L'**Interpello MLPS n.1/2025** in `reference/fonti/` con la trascrizione
- Le tre divisioni 30, 86, 87: o una fonte, o restano `null`
- «Si prende il piu alto»: scritto in due posti, citato in nessuno
- **Consegnare il raccordo ISTAT alla libreria**, che dichiara di non averlo

**Criterio di uscita.** Ogni regola destinata alle tabelle applicative porta parte,
punto e pagina — oppure e dichiarata dedotta e non ci entra.

**A monte.** Riparare qui non ripara il campo: `ateco.ts` e *generato* dalla
libreria.

**Unico aggancio con la fase 0.** L'ATECO manca sul 57% delle attive e si riempie
dalla visura, che oggi porta un codice ATECO 2025. Il percorso a mano risolve il
codice e scrive `codice_ateco` **e** `livello_rischio` nella stessa patch
(`Anagrafiche.tsx:866` -> `:873`), senza conferma: e li che i 62 codici diventano
una classe sbagliata in anagrafica. La dipendenza non e l'import dei due Excel —
quelli portano codici gia in formato 2007 — ma **la campagna di riempimento**.

### Fase 2 — Le decisioni che aprono il repo · nessun codice

Le schede stanno in [`decisioni/`](decisioni/), e **lo stato si legge nella
[sezione 5](#5-stato-delle-decisioni)**, che lo prende dalle schede. Non e
riportato qui: lo stesso fatto stava in quattro posti — la scheda, questo elenco,
la tabella della sezione 5, lo STATO dell'altra corsia — e chi decideva ne toccava
uno. Il piano e invecchiato due volte in un'ora il 9 settembre, ed e per questo che
questo paragrafo non elenca piu niente.

Quello che resta qui e pianificazione, non stato: **con l'ultima delle bloccanti e
caduta la guardia che teneva l'SQL fuori dal repo**, e le decisioni 1 e 8 vanno
applicate insieme, perche determinano colonne della stessa tabella.

**Criterio di uscita.** Una riga scritta per scheda, non un'opinione. Ognuna delle
bloccanti determina una colonna dello schema — ed e per questo che sono state decise
**insieme**: aggiungere dopo le colonne della 8 avrebbe significato riscrivere le
righe scritte sotto la 1.

### Fase 3 — Il repo nasce, e nasce piccolo

Il primo commit **non e applicazione**: e lo schema piu la migrazione dati che
porta dentro cataloghi, alias, corpus e anagrafe. I sei pilastri entrano dal primo
giorno. Le quattro pagine di `app/` sono l'innesto naturale — hanno gia
l'indirezione — e vanno completate sul lato scrittura.

**Criterio di uscita.** Nessuna query tocca una tabella fisica; un utente senza
abilitazione non vede niente perche lo dice la policy, non l'applicazione; ogni
riga formativa sa da dove viene.

Da risolvere qui, non dopo: le **chiavi esterne che attraversano il confine**.

### Fase 4 — Prima verticale: lo scadenzario che Sicurweb lascia

Il calendario lo detta Sicurweb. E la fetta che dimostra se l'impianto regge.
**Criterio di uscita.** Sicurweb si puo spegnere sullo scadenzario senza che
nessuno tenga due finestre aperte.

Sotto la **decisione 3** lo scadenzario **si ferma alla scadenza**: dice chi e
scaduto e cosa serve, e non genera commesse. La commessa la apre una persona in
WERP, come oggi — quindi questa fase non ha dipendenze esterne, e in particolare
non aspetta il canale col fornitore.

### Fase 5 — Il campo migra per ultimo

**Criterio di uscita.** Il tecnico apre il nuovo in un capannone, offline, e non se
ne accorge. Le due app vecchie si archiviano, non si congelano.

## 4. Cosa migra, cosa si riscrive, cosa torna indietro

Schema nuovo si, contenuto no. Il codice che si butta e grande in righe e piccolo
in conoscenza; quello che si rifarebbe a mano e piccolo in righe e caro in anni.

| Che cosa | Destino |
|---|---|
| Corpus normativo (misurato al commit `7acfd69`: 4.568 righe, 1.505 in `reference/`, 17 PDF) | migra come dato |
| Schema del dominio (62 migrazioni di qua, 53 e 7.423 righe SQL di la) | migra, rivisto |
| Cataloghi e configurazione (268 alias, 40 corsi, 13 figure, 16 box) | migra come dato — **ma gli alias non stanno nelle migrazioni**: vedi sotto |
| Lettori degli export (WERP a 7 stadi, Sicurweb) | migra come codice — ma sotto la decisione 3 il lettore WERP **cambia ruolo**: da fonte della verita sul numero di sedute a strumento di caricamento iniziale |
| Motori di dominio (requisiti, valutazione, scadenze) | migra come codice |
| Schermate e navigazione | si riscrive |
| Sincronizzazione offline | si riscrive |
| **Il raccordo ISTAT** (3.257 codici, 6.742 righe) | **torna a monte, alla libreria** — e ci resta: sotto la decisione 7 la libreria e la sorgente, non una copia |
| **Il corpus `reference/`** (17 PDF, 11 trascrizioni citate) | **va a monte anch'esso**, ad alimentare il generatore |

**Dove stanno davvero i 268 alias.** Non in `supabase/migrations/`: li la tabella
`corso_alias` nasce **vuota** (`055`). Le righe vivono in
`AppSopralluoghi/supabase/scripts/`, seminate da `ripristina_alias_gestionale.sql`
e poi mappate da **76 `update` scritti a mano** — 237 mappati, 31 ignorati. Con
loro vanno le colonne di comportamento (`ignorato`, `pregressa`,
`is_aggiornamento`, `parziale`, `evidenza_incompleta`), che sono decisioni prese
una per una. Una migrazione dati che guardasse solo `migrations/` creerebbe la
tabella e perderebbe **268 giudizi**, senza accorgersene: la tabella ci sarebbe.

E lo stato vero non e nei file ma nel database, perche gli script ricostruiscono il
30 luglio e il TODO del campo riporta l'esito come gia eseguito. Il seed si
**esporta**, non si rigioca.

## 5. Stato delle decisioni

**Tre decisioni di perimetro non hanno una scheda**, perche non hanno uno stato
che evolve: sono state prese e basta — il perimetro senza erogazione,
`AppCorsiOverall` escluso, il repo nuovo invece del foglio bianco.

Le altre ce l'hanno, e da li si legge lo stato — la 9 e stata aperta il 10
settembre, quando e emerso che il codice dei corsi di AppFormazione e
un'impronta del titolo e non un codice:

<!-- decisioni:inizio (generato da docs/decisioni/genera.py) -->

**12 schede su 12 sono chiuse.** Stato generato dalle schede: il paragrafo `## Decisione` di ognuna e la fonte, questa tabella e la resa.

| scheda | blocca | stato |
| --- | --- | --- |
| [1 · Il fatto appartiene alla sede o all'azienda?](decisioni/1-sede-o-azienda.md) | la **Fase 3** · determina colonne dello schema | **decisa il 9 settembre 2026** — appartengono alla **sede**, per tre ragioni diverse; e il motore, che legge sempre il cliente, va riscritto |
| [2 · Qual e la chiave di un cliente?](decisioni/2-chiave-cliente.md) | la **Fase 3** · determina colonne dello schema | **decisa il 9 settembre 2026** — la chiave è **P.IVA + sede**: un cliente, N sedi, un organigramma per sede |
| [3 · WERP resta o muore?](decisioni/3-werp-resta.md) | niente · finché era aperta, la Fase 4 non sapeva se dovesse arrivare fino alla commessa | **decisa il 10 settembre 2026** — WERP resta il gestionale ma **perde la pianificazione**: incarichi e sedute di consulenza e RSPP passano alla nuova app, e WERP **si ferma al contratto** |
| [4 · Dove vive kitformasubito, e chi lo tiene?](decisioni/4-kitformasubito.md) | niente subito · ma non deciderlo la fa rientrare dalla finestra fra sei mesi | **decisa il 9 settembre 2026** — resta dov’è, fuori dall’ecosistema, e si lega al cliente che lo chiede |
| [5 · Le divisioni 30, 86 e 87: alto rischio, o silenzio?](decisioni/5-divisioni-non-classificate.md) | niente · ma finché era aperta, 32 codici ATECO non avevano classe | **decisa il 9 settembre 2026** — valgono **`ALTO`**, con la citazione della Gazzetta e la deduzione marcata separatamente dal valore |
| [6 · Il cliente con piu codici ATECO: si prende il piu alto?](decisioni/6-piu-alto.md) | niente · finché le sedi non sono entità di prima classe | **decisa il 9 settembre 2026** — **dipende dalla mansione** — il «più alto» resta solo come default prudenziale per la sede multi-ATECO |
| [7 · Chi possiede la base normativa, e chi puo modificarla](decisioni/7-base-normativa.md) | niente · è una decisione di governo, non di costruzione | **decisa il 9 settembre 2026** — la libreria `formazione-81-utils-src` resta il **generatore unico**, e `reference/` la alimenta |
| [8 · Dove si annota che il livello di rischio non viene dall'ATECO](decisioni/8-scostamento-dal-rischio-ateco.md) | la **Fase 3** · determina colonne, insieme a quelle della decisione 1 | **decisa il 9 settembre 2026** — si annota in un **box accanto al default ATECO**, con motivazione, data e autore |
| [9 · Il catalogo formativo: si tiene il corso o l'obbligo, e con che chiave](decisioni/9-grana-e-chiave-del-catalogo.md) | la **Fase 3** · determina la forma delle tabelle formative e la chiave a cui si aggancia tutto ciò che è già stato importato | **decisa il 10 settembre 2026** — la grana è l'**obbligo**, la chiave è il **codice curato**, e l'impronta `GEST-`+md5 del gestionale diventa un **alias** invece di un'identità |
| [10 · La sorveglianza sanitaria entra nel perimetro?](decisioni/10-sorveglianza-sanitaria.md) | niente subito · ma decide se 808 accertamenti già raccolti hanno un posto, e allarga il perimetro del 26 agosto per la seconda volta | **decisa il 10 settembre 2026** — **entra, come dominio proprio** — accanto alla formazione e non dentro, perché l'art. 41 non è l'art. 37 |
| [11 · Il livello antincendio e il gruppo di primo soccorso: chi li confronta?](decisioni/11-livelli-emergenza.md) | il **motore**, non lo schema · finché era aperta, un livello 1 valeva quanto un livello 3 | **decisa** — **tre stati** — livello definito e attestato pari o superiore: conforme; definito e inferiore: non conforme; **non definito: si segnala e non si blocca l'import** |
| [12 · Un corso con due durate: tre cause diverse, e un meccanismo non basta](decisioni/12-le-durate-multiple.md) | il **motore**, e la `0006` limitatamente ai codici coinvolti · finché è aperta, il catalogo giudica col metro di oggi attestati validi sotto il metro di ieri | **decisa il 12 settembre 2026** — **decisa il 12 settembre 2026** — i meccanismi sono **tre** e sono entrati tutti e tre (validità temporale, condizione sulla dimensione con **tre** casi, un codice per variante combinata); il **quarto** — separare `PREPOSTO` — **non si fa finché non risponde l'Area Formazione**, perché tocca i dati già scritti e la domanda sotto non è di schema. **Corretta la sera stessa**: lo spartiacque non è il 17/04/2025 ma **due estremi che si sovrappongono**, 19/05/2025 e 19/05/2026, e il meccanismo lo paga `DL_RSPP_BASE` e non il dirigente |

<!-- decisioni:fine -->

## 6. Le misure

Ogni numero porta il criterio, perche e gia successo che una cifra circolasse
gonfiata di cinque volte e orientasse una raccomandazione.

| Misura | Valore | Criterio |
|---|---:|---|
| Letture indipendenti dell'Allegato IV | 2 | Le altre due: un derivato fedele e un promemoria |
| Divisioni condivise -> classi diverse | 85 -> 0 | Nessun disaccordo sulla norma |
| Codici che cambiano classe fra le annate | 62 | Su 2.166 validi in entrambe |
| Codici ATECO 2025 a una classe sola | 1.229 | Su 1.290 foglia; 32 fermati dalle divisioni non classificate |
| Clienti — formazione / sopralluoghi | 480 / 607 | Sottoinsieme stretto, zero orfani, una collisione |
| Anagrafiche da far rientrare | 619 | Database del campo vuoto dal 5 agosto |
| Scadenze sul modello | 7.084 | Base allargata; il 100% era chiuso su 4.778 |
| Migrazioni AppFormazione | 53 | `supabase/migrations/*.sql`, al 9 settembre; il 10 sono 54 |
| Righe SQL AppFormazione | 7.423 | **solo `migrations/`**, al 9 settembre; con `scripts/*.sql` erano 8.125 |
| Corpus in markdown | 4.568 | tutti i `.md` tracciati al commit `7acfd69`, di cui 1.505 in `reference/`. **Il 10 settembre sono 5.574 e 1.949**: la misura vale per il giorno in cui e stata presa, e per questo porta il commit invece di essere aggiornata a ogni file scritto |
| Formazione dentro l'app da campo | 8.876 | 36,1% di 24.576 righe di `src/` |
| Viste nelle 62 migrazioni del campo | 0 | — |
| Difetti del campo confermati · riparati | 4 · 3 | Resta D2, che vuole un deploy |
| Righe a 6 ore nell'export · di cui del datore | 1.651 · 76 | **La regola «6 ore = art. 37» era rovesciata.** A 6 ore ci sono 14 tipi distinti (il piu frequente e l'aggiornamento lavoratori, 1.031 righe), e l'unico del datore e «AGGIORNAMENTO R.S.P.P. DATORE DI LAVORO RISCHIO BASSO», che e **art. 34**. Nel gestionale gli aggiornamenti dell'art. 34 seguono il rischio: 6, 10, 14. Il discriminante resta il **titolo**, che `corso_alias` mappa gia; le ore sono un **controllo**, non una chiave |
| Famiglie di corso del sito che combaciano col catalogo | 9 su 11 | Confronto dell'11.09 fra le pagine di `overallgroup.info/corsi-sicurezza/` e i 40 codici della `0004` — **prima fonte esterna al sistema**. Esatte al numero anche le due che si sbagliano piu facilmente: preposto a **2** anni, primo soccorso a **3**. I quattro buchi in `docs/riscontro-catalogo-sito.md`: `RLS` con aggiornamento che dipende dalla dimensione, i corsi combinati senza codice, la periodicita dei lavori in quota che e **prassi** e non norma, e l'accesso con funi che manca |
| ATECO sui clienti del campo | 262 su 619 | **E sono divisioni a due cifre**, non codici pieni: 25, 43, 86 — non 25.62.00. 46 divisioni distinte, **262 su 262 risolvono** contro il raccordo. Il livello e **derivato e non scritto a mano**, e lo dimostrano i **due zeri spaiati**: zero clienti con codice e senza livello, zero con livello e senza codice. Misurato l'11.09 (`5595601`) |
| Celle ATECO in cui il livello dipende dall'ordine di incollaggio | 2 su 267 · **30 lavoratori** | Otto celle contengono **piu di un codice** e vince il primo che compare nel testo. Su due, le divisioni hanno livelli diversi: ANTICHI SAPORI `10 alto` / `47 basso`, MIGLIORINI `46 basso` / `33 alto`. Il danno non si conta in clienti: **MIGLIORINI ha 3 lavoratori** con `LAV_SPEC` da 4 ore che col `33` sarebbero 12 — otto ore in meno a testa, nel verso che non si vede — e **ANTICHI SAPORI ne ha 27** con 12 ore dove ne basterebbero 4, cioe eccesso che non espone nessuno. **Il caso pericoloso e il piu piccolo e quello innocuo e quello che si nota**, ed e il rapporto fra i due numeri a dirlo. Confermato l'11.09 (`56ae424`) leggendo il livello di **88 divisioni due volte** da due repository — `atecoDati.ts` e `allegato_iv_asr2025.js` — con zero divergenze su livello e sezione |
| Celle ATECO di forma non canonica | 14 su 267 · **87 lavoratori** | Correzione di un numero che questo programma tracciava: `f1184f6` diceva 11 e lasciava fuori le quattro celle multi-codice coi codici nella stessa divisione — non ambigue per il livello, ma anomale di forma come le altre. L'unione corretta e **14, il 5,2%** (`56ae424`): 15 lavoratori sulle cinque celle senza cifre, 1 su SHAMS, 20 sul multi-codice stessa divisione, 21 su divisioni diverse stesso livello, 30 sulle due divergenti. Le conclusioni del documento precedente non cambiano |
| Il `continue` sul modulo di settore, quanto morde | 0 oggi · 4 al primo import | `nomina` e a **zero righe**: il motore non ha organigramma su cui girare. Al primo import delle nomine si accende su 65 societa, 31 con un RSPP: **6** hanno il modulo dovuto, **21** hanno il `null` corretto, **4** hanno il `null` «non lo so» perche non hanno ATECO in archivio — il 13%. SHAMS, il caso travestito da dato buono, **non e fra quelle**. Due dei quattro sono gia noti come anagrafiche incomplete su un altro asse. Misurato l'11.09 (`f1184f6`) |
| Celle ATECO che prendono la divisione sbagliata | 1 su 262 | Misurato l'11.09 (`154cbcf`). La cella del gestionale e **testo libero**: la forma normale e `(C.25.62) Lavori di meccanica generale;` e `risolviAteco` pesca il primo gruppo di 1-2 cifre. In SHAMS SERVICE il primo gruppo e `37054`, il **CAP di Nogara**, e un'impresa edile finisce in divisione 37. Il livello non cambia (37 e 41 sono entrambe `alto`) **per caso e non per costruzione**; cambia il modulo di settore, 16 ore che non verranno chieste. Due celle su 262 non cominciano col codice, e una delle due e innocua |
| I cinque ATECO che «mancavano» | 5 clienti su 5 presenti | Non erano clienti persi: sono cinque celle in cui chi compilava ha scritto **cosa fa l'azienda** invece di scegliere la voce, e non contengono **una sola cifra**. Non c'e niente da riparare nell'import — il dato d'origine non porta l'informazione — e l'import lo dichiarava gia a schermo. Mancava il conto, non l'avviso. La ricostruzione dal file riproduce **cinque misure indipendenti** del database (262, 46 divisioni, 6 sulla 86, 0 sulla 30 e sulla 87), quindi i cinque nomi sono nomi e non candidati |
| Il dizionario dei 268 alias, in tre posti | 3 su 3 identici | Script di AppSopralluoghi, seed di AppOverall e produzione, chiusi in due confronti indipendenti: seed vs produzione **undici valori su undici** (`f94ff83`), script vs seed **zero righe diverse** e somme delle impronte identiche (`7d0b322`). Per transitivita i 268 giudizi presi a mano sono gli stessi nei tre posti, e **cade la riserva A10** sotto cui stava l'analisi delle durate |
| Il seed dei 268 alias contro la produzione | 11 valori su 11 | Confronto dell'11.09: `n`, la somma delle impronte per riga, i cinque flag, le note, i codici distinti e le due somme di lunghezze. **Combacia tutto**, quindi i 268 giudizi presi a mano sono quelli in produzione e la qualificazione «i file dicono» cade sul seed. Il primo tentativo, un `md5(string_agg(... order by))`, dava hash diversi: ordinamento e collation, non deriva — vedi **A11** |
| Divergenze fra migrazioni e database | 0 su 21 | Su `figura_requisito`, in due letture confrontate — ricostruita dai file e letta dal database (`b50003f`). **Prova che il metodo di ricostruzione funziona**, non che ogni tabella combaci: i 40 codici curati della `0004` restano un'ipotesi finche non si confrontano allo stesso modo |
| La `0001` → `0006` caricata su PostgreSQL | 12 conteggi su 12 · 8 prove su 8 | Carico dell'11.09 da AppFormazione su un cluster **nuovo**, fatto con `initdb` nello scratchpad di sessione (porta 5455, auth `trust`, poi cancellato): **nessuna credenziale di nessuno**. I sette della `0006` e i cinque della `0004` tornano tutti, e i tre vincoli sono provati **nei due versi** — un vincolo che rifiuta tutto non e un vincolo. **Nessun bug trovato**, a differenza del carico precedente. Le due cose temute prima e misurate dopo: 0 apostrofi rimasti doppi su 31 note, il punto e virgola dentro una nota e arrivato intero, nota piu lunga 411 caratteri |
| L'organigramma che le colonne dichiarano | 51% · **153 righe su 301** | Misurato l'11.09 (`8dab00a`) su tutte le 3.501 righe persona e tutte le 480 societa, non sulle 65 del perimetro assegnato — l'allargamento e loro e senza di quello la domanda 3 non aveva risposta. **160 righe portano il ruolo dentro la MANSIONE**, 12 in entrambi i posti, e per il **datore di lavoro nell'export non esiste nemmeno una colonna**: quelle 22 righe sono l'unica traccia che il gestionale ne porti. **94 societa — il 15% del portafoglio attivo, 703 persone** — dopo un import che legge solo le colonne avrebbero l'organigramma **vuoto avendone uno scritto**, e «senza organigramma» e uno stato legittimo: il difetto sarebbe **indistinguibile dal dato mancante**, come il `null` di `oreModuloSettore` su un'altra tabella |
| «RSPP» nella mansione che vuol dire art. 34 | 85 su 91 | Delle 91 righe con RSPP scritto nella mansione, **85 dicono che quella persona e anche titolare, socio o datore** e **3 dicono esplicitamente che non lo e**: il testo libero distingue i due casi in **88 casi su 91**, la colonna in nessuno. Mandare quelle 85 su `rspp` darebbe il percorso del professionista — moduli A, B, C — a chi deve quello del datore, e toglierebbe quello che deve davvero. **Il testo libero dice piu della colonna, non meno** |
| Aziende sopra i 50 lavoratori | **8 su 619** | `N DIPENDENTI` e valorizzata su **tutte** le 619 attive (138 a zero, 481 con un numero). **Sotto i 15 sono 432 su 481, il 90%**, e la scheda 12 e confermata con margine largo. Le otto si contano a mano: Rittal RCS 408, VELOX HOTELLERIE 227, VELOX SERVIZI 190, FRESENIUS KABI 113, CROCE VERDE 76, ZUCCHELLI FORNI 66, CAFFINI 53, SERVIZI SICUREZZA ITALIA 52. **Riserva dichiarata da chi l'ha misurata, e va con il dato ovunque vada**: quel numero **non e una dichiarazione della forza lavoro**, e il conteggio delle persone che abbiamo in anagrafica — coincide col conteggio righe in **601 casi su 619** — quindi risponde a «quante ne gestiamo», non a «quanti lavoratori ha l'impresa». Per un artigiano le due domande coincidono; per una societa di cui seguiamo un reparto no, ed e **proprio sulla soglia dei 50** che la differenza morde |
| Le 31 righe a 8 ore, contate | 25 su 31 · **4 aziende** | L'81% viene da aziende sopra i 50, e la controprova regge nell'altro verso: le **128 righe a 4 ore** vengono da 42 aziende, di cui **due sole** sopra i 50, per 4 righe su 128 — il **3%**. La separazione fra le due durate segue la dimensione. E la meta della frase che nessuno aveva notato non aveva bisogno di conteggi: il gestionale ha **due voci di catalogo distinte**, «Aggiornamento R.L.S. 4 ore» e «8 ore», quindi chi registrava **sceglieva**. Resta aperta **KOSME SPA**, 6 righe da 8 ore e 11 persone in anagrafica (`40ca5bc`) |
| Eventi erogati sui due titoli contesi del datore | **0** | Nessuno dei due compare in `ExportExcelCorsiFatti`: esistono **solo come scadenze future**, 12 righe fra gennaio 2030 e luglio 2031, ognuna generata da un **iniziale davvero erogato** («Datore di Lavoro» 16h x10 e «... con Modulo Cantieri» 22h x2), e i conti tornano persona per persona. Quindi la correzione della classificazione **e gratis sullo storico** — non c'e niente da rimappare — e tocca 12 obblighi **da calcolare bene la prima volta**. I 12 iniziali sono tutti 2025-2026, gia sotto l'ASR 17/04/2025 (`40ca5bc`) |
| Alias di `ATTR_AMB_CONFINATI`, per durata dell'aggiornamento | **2 durate · 4h e 12h** | Quattro ore ai **lavoratori**, dodici a **preposto, DL-RSPP e RSPP modulo B**: non quattro durate per quattro platee, **due**, ma la linea che le separa e la platea — che e proprio cio che il codice non porta. Periodicita 60 mesi su tutti e dieci gli alias, quindi `aggiornamento_mesi` e giusto. **Le durate erogate non c'erano** — zero righe su tutti e cinque gli aggiornamenti — e la fonte e la **colonna Durata del catalogo del gestionale**, autorizzata da un riscontro: sui cinque alias iniziali, che righe erogate ne hanno, la durata dichiarata coincide con quella effettiva **cinque volte su cinque, su 32 righe** (`b0f630c`) |
| Alias che NON sono il testo dell'origine | **211 su 268** | ~~Nove titoli con uno spazio doppio~~ **era la punta visibile.** Contati carattere per carattere (`a997859`): **identici all'origine sono 57**. Centonovantasei differiscono per **maiuscole e minuscole** — il catalogo del gestionale non e tutto maiuscolo, ha titoli in Frase, titoli maiuscoli e titoli misti dentro la stessa riga — e **quindici** anche per gli spazi: 8 con uno spazio doppio interno, **1 con un ritorno a capo dentro il titolo**, 6 con uno spazio in coda. `corso_alias.testo` non tiene il testo: **tiene la chiave**, e il commento che lo dichiara «come lo emette l'origine, verbatim» e falso su 211 righe su 268 |
| I 180 titoli di AppFormazione contro i 268 alias | 180 su 180 | Giunto della `0006`. Il confronto ingenuo ne perde **dieci**, e sono **tutti e dieci antincendio**: la loro pipeline **cancella** i caratteri non ASCII (`ATTIVITA'` -> `ATTIVIT`) dove chi usa `unaccent` li traslittera (`ATTIVITA`). Con una chiave che toglie da entrambi i lati ogni carattere non ASCII e non alfanumerico: 180 su 180. Quella chiave collassa 268 alias in **262**, e le cinque collisioni sono innocue **perche verificate**, non perche improbabili: tutte e cinque puntano allo stesso codice di corso |
| Coppie ruolo -> corso su cui le due fonti concordano | 14 su 14 | Sulle **figure**, dove sia il modello di AppFormazione sia `figura_requisito` possono parlare. Fuori dalle figure non c'e incrocio e non e un difetto: il campo dichiara nelle sue `045` e `058` che le abilitazioni non sono figure dell'organigramma, quindi le 14 righe di attrezzature e attivita della `0006` hanno **una fonte sola** e portano la sua qualificazione, «i file dicono» |
| Righe scritte in `corso_assolve` | 31 | Su 39 coppie derivabili: **-7** antincendio e primo soccorso (scheda 11), **-3** divergenze non scritte, **+2** con una fonte sola e dichiarata. Coprono **20 dei 36 ruoli**; i 16 vuoti sono di quattro nature diverse e la `0006` le separa, perche un motore che non le distingue dichiara non conforme chi non ha un corso da fare |
| Obblighi i cui unici titoli sono fra i 31 `ignorato` | 5 su 5 | `diisocianati`, `fitosanitari`, `alimenti`, `segnaletica_stradale`, `conduce_transpallet`: **nove titoli, nove `ignorato`, zero eccezioni**. Due curatele che non si sono parlate — chi ha giudicato i 268 alias e chi ha classificato i 180 titoli — hanno separato lo stesso insieme. E il riscontro piu pulito dell'incrocio, e dice una cosa commerciale e non tecnica: quei corsi Overall non li eroga |
| Insiemi distinti di «fattori di rischio» | 76 | Su **162 righe** con almeno un fattore, 3.501 totali. 122 righe condividono l'insieme con un'altra: **112 nella stessa societa**, 45 con la stessa mansione. La cella ha **un solo valore distinto**, `X`, in 2.447 occorrenze su 79 colonne, e nessuna colonna porta un grado o una fascia. Misurato il 10.09 da AppSopralluoghi (`39fb586`) |

## 7. Le assunzioni

Numerate perche si possa dire «su A4 non sono d'accordo» invece di riscrivere il
piano.

- **A1** Il valore non e nel codice applicativo, ma nel corpus, nello schema e nei
  lettori degli export. Se e falsa, riscrivere da zero costa molto meno.
- **A2** Sicurweb detta il calendario. Se la data slitta, la 4 puo scambiarsi con la 5.
- **A3** Non esistono API: solo Excel. L'import con riconciliazione e il mestiere,
  non una fase.
- **A4** L'anagrafe unica sta dove ci sono le sedi. La riconciliazione ha una
  direzione obbligata, non e simmetrica.
- **A5** ~~Il database operativo e vuoto dal 5 agosto.~~ **Ritirata il 9 settembre**:
  era un'affermazione del TODO, non una misura, e nessuno l'aveva verificata contro il
  database. All'import i clienti c'erano gia — 0 nuovi, 618 a posto — e le persone
  scritte sono 3.420. Resta vero che ogni fase che presuppone dati veri dipende dalla
  fase 0, ma non perche il database fosse vuoto.
- **A6** Il perimetro non si allarga durante il riavvio. **Piegata una volta, il 10
  settembre, con la decisione 3**: la pianificazione delle attivita di consulenza e
  RSPP esce da WERP ed entra nel perimetro. E un allargamento dichiarato e circoscritto
  — preventivi, commesse e fatturazione restano fuori — ma e un allargamento, e sta
  scritto qui perche la prossima volta si sappia che questa e la seconda e non la
  prima. **Piegata una seconda volta lo stesso giorno, con la scheda 10**: la
  sorveglianza sanitaria entra come dominio proprio, perche 808 accertamenti
  dell'art. 41 erano gia raccolti in un foglio che nessun import apre. Due allargamenti
  dichiarati non sono una deriva; due allargamenti taciuti lo sarebbero. Il terzo
  si guarda con sospetto.
- **A7** **Una regola dedotta non entra nelle tabelle applicative.** Si applica cio
  che si legge, con parte, punto e pagina; cio che si deduce aspetta, dichiarato.
  Non e condivisa da tutte le fonti in gioco: la libreria normativa riempie le tre
  divisioni aperte senza citarle. **E l'unica assunzione che, se cade, cambia la
  natura del progetto invece che il calendario**: 32 codici si sbloccano subito, e
  il progetto smette di essere quello che dice di essere.

- **A8** **Un impegno scritto e un impegno eseguito hanno la stessa forma sulla
  pagina.** Una nota che dice «verra fatto» non prova che sia da fare: si confronta
  con la data in cui la cosa e stata fatta. Aggiunta il 10 settembre 2026 dalla corsia
  AppSopralluoghi, che ha letto come pendente un azzeramento **deciso il 3 agosto** ed
  **eseguito il 5** — e che, per la conferma di Francesco, non era mai stato un
  impegno ma un'idea a voce. E la sorella di A5: la stessa nota letta come misura.
  Il difetto non e stato misurare male, e stato **non misurare affatto**.

## 8. Chi decide il prossimo passo

**Deciso da Francesco il 10 settembre 2026.** AppOverall e il repo in cui tutte le
corsie confluiranno, quindi e **qui che si decide cosa si fa dopo e chi lo fa**. Non e
un privilegio, e una conseguenza: chi tiene il piano canonico e l'unico che vede le
tre corsie insieme, e una corsia che sceglie da se sceglie sul suo pezzo.

Come funziona, per non trasformarlo in un collo di bottiglia:

- **a chiusura di ogni task** — non a fine giornata — la corsia riporta lo stato nel
  suo `STATO.md` e lo dice; AppOverall decide il passo successivo e **a chi tocca**,
  e lo scrive **qui**, non in un messaggio;
- una corsia che non ha un passo assegnato **non lo inventa**: lo chiede;
- **una pausa messa da Francesco non la toglie nessun altro.** Il fatto che gli
  ostacoli tecnici siano spariti non e un permesso di ripartire;
- l'assegnazione dice anche **cosa non fare**, quando serve: un task escluso per
  mancanza di accesso o di dato va detto escluso, non lasciato in fondo alla lista;
- **un'autorizzazione a scrivere su dati veri non si accetta di seconda mano.** Un
  ordine si relaia; un permesso su un database senza backup no. L'11 settembre 2026 la
  corsia AppFormazione ha ricevuto da qui l'autorizzazione di Francesco ad applicare
  due migrazioni in produzione, **e l'ha richiesta a lui direttamente** prima di
  procedere. Ha fatto bene, e vale anche quando il relay e corretto: chi esegue
  risponde di cio che scrive, e una parola riportata non e una firma. Questa regola
  protegge Francesco da noi, non noi da lui;
- **e la sua simmetrica, aggiunta l'11 settembre 2026: un ostacolo non si aggira
  passandolo a un'altra corsia.** Questa sessione non ha la password del PostgreSQL
  locale, e il tentativo di indovinarla e stato bloccato — giustamente. La corsia
  AppFormazione quella macchina la sa usare. Girarle il lavoro **di mia iniziativa**
  sarebbe stato lo stesso ostacolo scavalcato da un'altra porta: non piu sicuro,
  solo meno visibile. Quindi la domanda e andata a Francesco, che ha scelto la
  terza opzione fra le tre che gli ho messo davanti, e **da li in poi e
  un'assegnazione e non una scorciatoia**. La differenza non e formale: assegnare
  e una cosa che si scrive qui e che qualcuno puo rileggere, aggirare e una cosa
  che non lascia traccia.

**La terza volta non e una coincidenza: e una regola.** Tre volte in due giorni il
dato che manca a una corsia **esiste nell'altra**, e tutte e tre le volte viene
**dallo stesso export**:

| dato | dove risultava mancante | dove c'era |
|---|---|---|
| ATECO | `clienti.ateco` vuota su 480 | 262 delle 619 attive |
| ruoli | nessun organigramma importato | 153 colonne **e** 160 mansioni |
| lavoratori | `clienti.dipendenti` scritta solo a mano | **619 su 619** |

**Non e che i dati manchino: e che ogni import ha letto le colonne che gli servivano
quel giorno.** La regola, formulata da AppSopralluoghi e adottata qui: **prima di
dichiarare mancante un dato anagrafico, guardare se un'altra corsia lo sta gia
leggendo dallo stesso file.** Costa un `grep` e ha gia evitato tre campagne di
raccolta inutili.

E il corollario che la terza istanza aggiunge: **un dato che trasloca porta con se la
sua etichetta.** `N DIPENDENTI` non e «quanti lavoratori ha l'impresa», e «quante
persone ne gestiamo» — e l'uso previsto e proprio la soglia dei 50 dell'RLS, cioe il
punto esatto in cui le due domande divergono. Trasferirlo senza l'etichetta
produrrebbe la stessa classe di difetto dell'ATECO derivato senza la cella.

**~~Serviva la password~~ — no, e l'errore e mio, dello stesso tipo di A9.** Ho messo
davanti a Francesco tre opzioni — dimmela, la lanci tu, la assegni a loro — e
**nessuna delle tre era quella giusta**. AppFormazione non ha usato il PostgreSQL
sulla 5433 e non ne ha cercato la password: ha fatto `initdb` di un **cluster nuovo**
nello scratchpad di sessione, porta 5455, auth `trust`, vuoto, cancellato a fine
lavoro. Nessuna credenziale di nessuno, niente che tocchi la 5433 ne la produzione.
`initdb` sta nella stessa cartella di `psql`, dove avevo gia guardato.

Avevo trasformato «non ho la password di **quel** database» in «non posso caricare
**un** database», che e la stessa scorciatoia logica di A9 e della nota qui sotto
sull'assenza di `psql`: **la terza volta oggi che generalizzo un ostacolo specifico
in un impedimento generale.** La regola sopra resta giusta e ha funzionato — la
domanda e andata a Francesco invece che a una corsia — ma una domanda ben posta su
una premessa sbagliata resta una domanda sbagliata, e gli ho fatto scegliere fra tre
opzioni quando la risposta era una quarta. **Prima di chiedere un permesso, chiedersi
se serva il permesso o lo strumento.**

### Prossimo passo per corsia · al 12 settembre 2026, sera

Riscritta perche i due passi assegnati l'11 si sono chiusi — AppSopralluoghi ha
risposto sui due export delle visite (`348b6da`) e AppFormazione ha consegnato le
quattro grandezze (`b2b4e0c`) — e perche **e cambiata la macchina, non solo la
data**.

**Il fatto che viene prima di tutti, e che va letto prima di leggere la tabella:**
il lavoro dell'11 settembre e stato fatto **altrove**, e su questa macchina e
arrivato **oggi alle 16:55** con un `pull` su tutti e tre i repo. Il reflog lo dice
senza ambiguita: qui AppOverall era fermo al 10 alle 12:04, AppSopralluoghi al 9
alle 19:41, AppFormazione al 10 alle 12:05. **Oggi, 12 settembre, nessuno dei tre
repo ha un commit.** Le due corsie che lavorano qui hanno davanti uno stato che
conoscono da un'ora, non da un giorno: la prima cosa che devono fare non e
ripartire, e **leggere cosa e successo mentre questa macchina era indietro**.

E una cosa l'ho tolta di mezzo invece di distribuirla: `formazione-81-utils-src`
era indietro di **quattro** commit e **`reference/` qui non esisteva** — 33 MB di
fonti, fra cui il DPR 177/2011 e gli articoli citati del D.Lgs 81/08. Portata a
`a1827fd`. Chiunque avesse controllato una citazione su questa macchina prima di
adesso avrebbe letto «la fonte non c'e» da un repo che la fonte ce l'ha.

| corsia | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **AppOverall** | ~~la `0008`~~ **scritta e caricata** (`b395ee6`, `c9938a7`) → **la `0009`, e non e una colonna: e una tabella.** I crediti formativi — `datore_lavoro_rspp -> datore_lavoro_art37 = 'totale'`, ASR Allegato III pag. 130 — piu la seconda meta del rilievo 3, `posizione = 'esterno'` che oggi si ferma in `ruolo_testo` e non viaggia con la nomina | la migrazione dati, che comincia dalle persone | Perche la `0007` **attiva** un difetto che finche le nomine non entravano non costava niente: sette persone risulterebbero dovere l'art. 34 **piu** l'art. 37, e `corso_assolve` funzionerebbe perfettamente producendo il risultato sbagliato. Un credito che manca non si vede: si vede un obbligo in piu, che sembra prudenza |
| **AppSopralluoghi** | ~~`STATO.md` prima del lavoro~~ **fatto, e il numero era mio e sbagliato: i commit dopo l'ultimo tocco erano DICIANNOVE, non dodici** (`b392190`): la `067`, la `068`, il progetto dell'import delle nomine, i due export delle visite. Chi apre quel file oggi legge il 10 settembre. Mancano anche i diari del 10 e dell'11 → poi **la consegna dell'anagrafe alla migrazione dati**, **sola lettura**: cosa attraversa il confine (619 clienti, 619 sedi, 3.419 persone) e con **quale identita** quando il codice fiscale non c'e — 235 righe in anagrafica, 12 su 153 nei ruoli, e fra quelle dodici l'unico ASPP dell'export | l'import delle nomine, **che resta fermo** | Perche e l'unica cosa che blocca il passo di questa corsia: `sorveglianza.persona_id` deve puntare a 787 persone che nel repo unico non esistono ancora, e una migrazione dati **non puo inventarsi una chiave** dove la fonte non ce l'ha. E perche lo `STATO.md` viene prima per una ragione misurabile e non formale: oggi, per sapere a che punto fosse questa corsia, ho dovuto ricostruirla da diciannove messaggi di commit e da sei file in `c1a/`. Il file che esiste apposta diceva altro |
| **AppFormazione** | **le quattro grandezze applicate ai 40 codici della `0004`**, sola lettura, consegna qui. La `0008` marca **in positivo** solo i sedici aggiornamenti dell'art. 73 (`parte_pratica`), e poi assegna `durata_corso` a **tutto il resto che porta un numero**. Il sospetto e il loro: il documento 16 dice che `monte_ore_quinquennio` **sfugge al guardrail** e darebbe `insufficienti` falso — e l'aggiornamento dell'art. 34 e quello del modulo B sono monti ore quinquennali, non durate di corso. La domanda e **quante delle 40 righe portano un `durata_corso` che nessuna regola ha riconosciuto, e quante di quelle sono un'altra grandezza** | il giunto `dipendenti_rls` sui dati veri, quando l'anagrafe attraversa | Perche il difetto che cercano l'hanno gia descritto **sulla loro tabella** e questa e la stessa forma **sulla mia**: la `0008` ha invertito il `default` su loro rilievo — e ha ragione — ma sotto il `default` corretto c'e un `update` che marca per **presenza di un numero** e non per riconoscimento, che e esattamente cio che la migrazione dichiara di non fare due righe sopra. Un guardrail che protegge le righe future e lascia passare quelle presenti protegge meta del problema |

**E tre cose che l'assegnazione dice per non essere fraintesa:**

- **l'import dei ruoli e delle nomine resta fermo.** La `0007` e la `0008` sono
  caricate e l'ostacolo tecnico non c'e piu: **non e un permesso.** La pausa e di
  Francesco e non la toglie nessun altro, ed e la terza volta che questo programma
  scrive questa riga perche e la terza volta che l'ostacolo sparisce e la pausa no;
- **nessuna scrittura su database di produzione**, da nessuna delle due corsie e
  per nessuna delle due assegnazioni. Tutte e due sono sola lettura. Il piano
  Supabase e free e non c'e backup: vale oggi come il 10 settembre;
- **ad AppFormazione non si chiede di cambiare la sua regola sul `push`.** Nove
  commit sono stati spinti l'11 sera **da qui**, su istruzione di prima mano di
  Francesco, e quella regola e rimasta intatta. Il prossimo blocco restera locale
  allo stesso modo: **e stata risolta la volta, non il meccanismo**, e la scelta fra
  «spinge Francesco» e «per questa corsia lo stato si chiede e non si legge» e sua e
  resta aperta.


### Le due consegne della sera del 12, e la cosa che hanno trovato in mezzo

Tutte e due le corsie hanno chiuso il passo assegnato **la sera stessa**, e nessuna
delle due ha consegnato solo cio che era stato chiesto. Da qui sono uscite tre
migrazioni — la `0009`, la `0010` e la `0011` — e **la terza e interamente loro**.

**AppFormazione, le quattro grandezze sui 40 codici** (`2632cbf`, locale). Tre
risposte, e due non erano fra quelle che avevo previsto:

- **il numero era mio ed era sbagliato**: 53 marche su 37 righe, non 36. La `0008`
  fa **due** update per presenza di un numero e nella domanda li avevo **citati
  tutti e due e contati come uno**;
- e le due colonne non hanno la stessa forma: su `ore_aggiornamento` il blanket e il
  **residuo** di una regola che ha riconosciuto sedici righe, su `ore` **non c'e
  nessuna regola**. Quindi **zero righe su 40** avevano una grandezza che qualcuno
  avesse riconosciuto, e «si marca solo in positivo» era vero per **16 marche su 69**;
- **una sola grandezza era sbagliata**, `RSPP_MOD_B.ore_aggiornamento = 40`, ed e un
  monte ore quinquennale — Parte III punto 3, e la trascrizione aggiunge la frase che
  rende la lettura decidibile: «e **qui, e solo qui**, che l'accordo dice»;
- **e il secondo candidato l'avevo indicato io, e non regge.** L'aggiornamento
  dell'art. 34 «**ha durata**, modulata in relazione ai tre livelli di rischio»
  (223/CSR del 21/12/2011). «Quinquennale, quindi monte ore» e dedurre invece di
  leggere: **A7 usata contro chi l'ha invocata**, e va scritto qui perche il sospetto
  stava in un'assegnazione — un sospetto assegnato si ritira dove era stato dato;
- **la categoria piu numerosa non era fra le due previste**: per **13 marche** la
  grandezza e plausibilmente `durata_corso` e **nessuna fonte leggibile lo dice** —
  una scansione senza livello di testo, una norma tecnica a pagamento, un protocollo
  non normativo, una prassi, una scelta di erogazione. Sono tornate ad `assente`
  con la `0011`. Altre sei restano, e la linea passa fra **fonte non leggibile** e
  **fonte non trascritta**: la seconda si chiude trascrivendo, non decidendo.

Di passaggio hanno corretto **due note del catalogo che citavano una norma che non
dice quello** — il DM 388/2003 non fissa le ore dell'aggiornamento, sono prassi
Overall — e leggendo le righe accanto ne e uscita una terza: la nota dell'`RLS`
portava la regola di **prima del 31/12/2025**, due casi invece di tre e una durata
al posto di un pavimento.

**AppSopralluoghi, la consegna dell'anagrafe** (`b392190`, `4692b52`, locali). La
regola richiesta c'e — l'identita e la coppia **(cliente, codice fiscale)**, col
ripiego su cognome+nome finche quel nome e univoco **sia nell'archivio sia nel
file** — ma sotto c'e il fatto che la rende urgente, ed e per la Fase 3:

> **Il primo campo di `import_key` e `cliente.id`, un uuid generato dal loro
> database.** Non deriva dalla fonte. Se nel repo unico i 619 clienti rinascono con
> uuid nuovi, **tutte e 3.419 le chiavi puntano a un id che qui non esiste — e non
> danno errore**: restano stringhe sintatticamente valide che non agganciano niente,
> e il secondo import ricrea 3.419 persone **in silenzio**.

E la forma esatta del rischio che la provenienza doveva chiudere, un livello piu in
basso di dove la si era guardata: `import_key` prova che una riga **e gia arrivata
da qualche parte**, e non prova che quel «da qualche parte» esista ancora. Le vie
sono due — i clienti attraversano **con gli stessi uuid**, oppure attraversa una
tabella di corrispondenza e le chiavi **si riscrivono in migrazione** — e la scelta
e di questa corsia, non della loro. Quel che **non** si puo fare e ricalcolare le
chiavi dall'export: la regola dipende da un controllo di ambiguita fatto su
**quell'archivio**, e rifarlo altrove puo dare esito diverso sulle stesse persone.

Con la consegna arrivano tre avvertenze e due numeri lasciati **non tornanti invece
che aggiustati**, che e la forma giusta:

- il codice fiscale **dentro la chiave non e validato** — `cfPulisci` ripulisce, la
  validazione esiste e serve solo all'avviso a schermo. E le visite sono indicizzate
  **per codice fiscale**: una chiave che porta dentro una stringa che CF non e
  aggancia la persona e **non agganciera mai la sua visita**;
- **i clienti attraversano senza chiave**: `import_key` sta su persona, formazione e
  adempimento, **non** su `cliente`. Dei 619 non resta scritto da dove vengono, e va
  deciso **prima** che attraversino, perche dopo l'id da scriverci e gia cambiato;
- le **619 sedi non sono un secondo insieme**: la loro `054` ne crea una per cliente
  copiando la sede legale, e `persona.sede_id` oggi vuol dire «il cliente» detto in
  un altro modo. Il sito produttivo non e mai stato importato;
- **235 contro 233** righe senza codice fiscale, e **3.420 contro 3.419** persone: i
  quattro export non sono su quella macchina, quindi i due scarti restano scritti
  come scarti. Per la migrazione fa fede il **3.419**, che e una misura sul database.

**E il 787 non e loro, e hanno fatto bene a dirlo.** «Le 808 esecuzioni appartengono
a 787 persone» sta in questo repo — `docs/misure/sorveglianza-foglio-visite.py`, la
misura di questa corsia sul foglio — e nel loro non compare da nessuna parte. Il
numero e mio: l'avevo messo in un'assegnazione come se fosse un dato condiviso, e
loro hanno risposto con cio che sanno misurare — 800 coppie nel foglio, 804 nello
scadenzario, 769 comuni — invece di confermare un numero che non avevano.

**Un terzo caso della stessa regola, dal verso opposto.** Le 160 righe col ruolo
scritto nella mansione **non hanno mai avuto una misura di copertura del codice
fiscale**: il «12 su 153» vale per le righe che dichiarano il ruolo in colonna e
**non si estende alle altre**. Estenderlo sarebbe la mossa ritirata sulle 31
aziende, fatta nel verso opposto — e l'ha segnalata la corsia a cui quella mossa
era stata rimproverata.

### Prossimo passo per corsia · al 12 settembre 2026, notte

| corsia | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **AppOverall** | ~~la `0009`, la `0010`, la `0011`, la `0012`~~ **scritte**, e ~~l'uuid~~ **deciso con la `0013`**: i 619 clienti attraversano con **lo stesso** uuid, il cliente prende una `import_key` sua che non passa dall'uuid, e la chiave legacy atterra su `rapporto_lavoro` — perche `anag:<cliente>:<cf>` non e l'identita di una persona ma di **una persona presso un cliente**, e qui quell'oggetto ha gia un nome → **la migrazione dati**, che comincia dalle persone | la Fase 3 vera e propria | Perche sotto la domanda dell'uuid ce n'era una piu grossa e nessuno dei due documenti la diceva: **le due `persona` non sono la stessa tabella**. Da loro e per cliente e due schede sono legittime, qui `codice_fiscale` e unique globale. La migrazione non e una copia, e un **cambio di grana** — e il numero che ne esce non lo sa ancora nessuno |
| **AppSopralluoghi** | ~~fermi~~ **ripartiti**: Francesco ha tolto la pausa la sera del 12, e il passo e **scrivere** l'import delle nomine — eseguirlo sui dati veri vuole il suo permesso **chiesto a lui direttamente**, non relaiato da qui → poi **i due conti che la `0013` non sa fare**: quanti codici fiscali validi compaiono su **piu di un cliente** (le righe che qui collassano in una persona con due rapporti) e cosa succede alle **235 senza codice fiscale**, che in questo schema non hanno nessuna identita propria | l'import delle nomine, eseguito | Perche i due conti sbagliano in **versi opposti** — il primo fonde righe che vanno fuse, il secondo righe che non vanno fuse — e un import che non li distingue fa la cosa giusta e quella sbagliata **con lo stesso codice**. E perche si fanno con dei `count`, cioe sola lettura, mentre l'import aspetta una firma |
| **AppFormazione** | **trascrivere la Parte II dell'ASR 2025 in `reference/`**, che e la lacuna che hanno dichiarato loro: chiude sei marche su sei senza decidere niente, e le sei sono le durate iniziali dei corsi piu frequenti del catalogo — datore, dirigente, preposto, lavoratore generale | il giunto `dipendenti_rls`, quando l'anagrafe attraversa | Perche e l'unica cosa che **si chiude leggendo** fra quelle rimaste aperte dalla loro consegna, e perche il secondo passo **non e avviabile e l'hanno misurato**: il loro database locale e fermo alla `0053` mentre il repo e alla `0062`, e `clienti.dipendenti` e null su tutte e 480. Il numero di dipendenti sta nell'altro archivio, su 481 delle 619 attive |

**E una domanda che hanno posto e che non tocca a loro chiudere**: se convenga
colmare `clienti.dipendenti` dai **loro** sette export invece di aspettare il
passaggio dell'anagrafe. La risposta e **no, e non per prudenza**: quel numero ha
un'etichetta — «quante persone ne gestiamo», non «quanti lavoratori ha l'impresa» —
e trasferirlo due volte da due parti diverse e il modo in cui un'etichetta si perde
per strada. Arriva con l'anagrafe, una volta sola, con la sua qualificazione.

**Chi e fermo, e da quando.** La sera del 10 settembre Francesco aveva fermato
**AppFormazione** (passo assegnato, non iniziato) e **AppSopralluoghi** (confronto a
meta, punto di ripresa scritto nella `0004`), e l'import dei ruoli era gia in pausa.
**Le prime due sono ripartite**, e si vede da `origin` e non da un permesso riferito:
`41b4192` e `5595601` sono dell'11 settembre. L'import dei ruoli **resta fermo**, e
resta fermo finche non lo toglie Francesco. Sta scritto qui perche la prossima
sessione non aspetti un lavoro che nessuno sta facendo: una corsia ferma e diversa da
una corsia lenta, e dal foglio non si distinguono.

**`ponteggi_art136` si puo estendere, `spazi_confinati` no — e il no viene dai miei
alias.** AppFormazione ha chiesto (`cf9cba6`) se `PONTEGGI` e `ATTR_AMB_CONFINATI`
siano fra i codici con piu di una durata reale, e ha chiesto di **guardare la lista
invece di rifare la misura**. Guardata, in `durate-come-controllo.md` (`eddbb44`):

- **`PONTEGGI` e nominato**, nella riga «100% conforme». Verde, e l'estensione costa
  la riga che dicono loro.
- **`ATTR_AMB_CONFINATI` non e nominato da nessuna parte.** Non fra i conformi, non
  fra le anomalie. La tabella chiude con «e 9 codici attrezzature», e quel codice non
  e un'attrezzatura — e `lavori_speciali`.

**E «non nominato» non e «conforme».** Trasformare un silenzio in una conferma e
esattamente la mossa che ho appena ritirato sulle 31 aziende, e non la rifaccio
ventiquattro ore dopo nel verso opposto.

**C'e anche una ragione positiva per dubitarne, e sta nel mio seed.** A
`ATTR_AMB_CONFINATI` puntano **dieci alias** — contro i tre di `PONTEGGI` — e quattro
di quei dieci sono:

    LAVORI IN AMBIENTI CONFINATI (AGGIORNAMENTO LAVORATORI)
    LAVORI IN AMBIENTI CONFINATI (AGGIORNAMENTO PREPOSTO)
    LAVORI IN AMBIENTI CONFINATI (AGGIORNAMENTO R.S.P.P. DATORE DI LAVORO)
    LAVORI IN AMBIENTI CONFINATI (AGGIORNAMENTO R.S.P.P. MODULO B)

**Quattro aggiornamenti per quattro platee diverse sotto un codice solo, con una
attesa sola.** E la forma della loro categoria 5 — «manca la separazione dei corsi» —
e non quella di un obbligo pronto. Il loro conto dice «1 titolo di aggiornamento»
perche conta i **loro** sei titoli; il dizionario ne porta dieci. I due numeri non
misurano lo stesso oggetto, ed e la stessa trappola dei «1.148 eventi di visita».

Serve una misura sola prima di estendere: **le durate reali dei dieci alias, divise
per alias**. Chiesta ad AppSopralluoghi, che ha l'export.

**E la loro convergenza sulle attese resta vera e vale.** Il loro modello dice
`ponteggi 28/4/48` e `spazi confinati 12/4/60`, il mio catalogo — curato a parte, da
fonti diverse — dice `PONTEGGI 28/4/48` e `ATTR_AMB_CONFINATI 12/4/60`: **tre numeri
su tre, su entrambi**. Ma e un accordo su cosa ci si **aspetta**, e la domanda era
cosa e stato **erogato**. Due curatele che concordano sull'attesa sono la terza gamba
del riscontro, non un sostituto della prima.

**E su `LAV_SPEC` avevano ragione e io l'avevo classificato male.** Avevo scritto che
lo blocca «il livello della sede, lo stesso buco della scheda 11». Falso per
l'aggiornamento: il discriminante governa le ore **iniziali** (4/8/12) e
l'aggiornamento e **6 per tutte e tre le classi** — lo dice la nota del mio stesso
`LAV_SPEC`, che avevo scritto io. Quindi non e la categoria che si sblocca con una
domanda al cliente: e quella che chiede una **migrazione e tocca lo storico**, perche
sono cinque titoli di aggiornamento di cui tre portano una classe di rischio nel nome
pur avendo tutti la stessa attesa. La differenza non e accademica — la prima categoria
costa una telefonata, la seconda un progetto.

**E una cosa che ho imparato sul mio dizionario da una misura che non riguardava me.**
Passando i 268 alias attraverso la loro normalizzazione, **una sola collisione perde
una distinzione vera**: `PREPOSTI - BIENNALE` (12 ore) contro `PREPOSTI_BIENNALE` (8
ore). Ma il rilievo che conta e il loro secondo: **anche il mio catalogo le unisce**,
un livello piu in la — sono due righe di `corso_alias` con lo **stesso**
`corso_codice = 'PREPOSTO'`. Quindi oggi **nessuno dei due repo sa dire per codice
quale sia il corso da 12 e quale quello da 8**, e la mia frase «il dizionario le tiene
gia come due voci» era vera e non bastava: la distinzione sopravvive nell'alias e
muore nel codice, che e il livello a cui il motore lavora.

**«Riscarica tutto lo stesso giorno» era un consiglio sbagliato, e lo zip lo dimostra.**

AppSopralluoghi ha guardato **quando i file sono stati salvati** prima di girare quel
consiglio a Francesco, e ha trovato che due su cinque hanno la data interna uguale al
momento dello scaricamento e **tre ce l'hanno di un mese prima**. Due letture possibili,
e non potevano sceglierne una: **(a)** quei tre portano la data dell'ultimo
**aggiornamento dei dati a monte** e riscaricarli non allineerebbe niente; **(b)** sono
stati prodotti il 6 agosto e solo **salvati** il 3 settembre.

**Il discriminante c'era, ed e uno zip in `Downloads`.** `ExportExcelCorsiScadenze.zip`
e stato salvato il **03/09 alle 13:12** e contiene quattro `.xlsx` i cui timestamp
interni allo zip sono del **03/09 alle 13:11** — cioe i file **sono nati il 3 settembre**
e dichiarano in fondo «Dati aggiornati al **06/08**/2026». Un file non puo essere stato
prodotto prima di esistere: **quella data in fondo non e la data dell'estrazione, e la
data dei dati.** Lettura (a).

**E la conferma sta in una differenza di parole che avevo letto e non visto.**

    ExportExcel (4)                        «Report aggiornato al 09/09/2026»
    gli altri cinque                       «Dati aggiornati al 06/08/2026 07:44»

**«Report aggiornato» e «Dati aggiornati» non dicono la stessa cosa**: il primo data la
**produzione del foglio**, il secondo la **freschezza del contenuto**. Le due formule
stavano sotto i miei occhi da quando ho aperto i file, e le ho trattate come sinonimi
perche portavano entrambe una data.

**La regola sull'unanimita come l'avevo scritta e troppo forte, e la condizione che le
manca e quella che la rende usabile.**

Avevo scritto: **l'unanimita e una prova di assenza di intenzione**, perche le persone
sono irregolari e le operazioni no. Vale **solo se la popolazione e fatta di scelte umane
indipendenti** — nove medici, o un medico su nove occasioni distanti. Se le nove righe
venissero da **una sola decisione applicata a un gruppo** — una campagna, un protocollo,
una direttiva — **l'unanimita tornerebbe compatibile con l'intenzione**, e anzi sarebbe
cio che ci si aspetta.

**Qui il limite non morde, e si vede perche**: le nove stanno su **tre societa diverse**,
quindi **non possono venire da una decisione sola**. Ma la regola senza quella condizione
porterebbe a **scartare i casi in cui l'uniformita e esattamente il segno giusto**, ed e
il difetto peggiore che una regola euristica possa avere: funzionare nel caso da cui e
nata e sbagliare in quelli per cui verra riusata.

Quindi, scritta per intero: **fra popolazioni di scelte indipendenti, l'unanimita e una
prova di assenza di intenzione; fra popolazioni che possono condividere una causa unica,
non prova niente — e la prima domanda diventa se le righe siano indipendenti.**

**E una nota che vale per la `0008` e per qualunque commento aperto.** Un commento che
dichiara un'ambiguita deve dire **che cosa la scioglierebbe**, non solo che esiste: senza,
chi legge fra un anno **non distingue «e ancora ambigua» da «nessuno ha rifatto il
conto»**. Sono due stati diversi e una nota che non li separa **invecchia in silenzio** —
la stessa cosa dei tre stati dell'ATECO, applicata a una frase invece che a un calcolo.
**«Non lo so» e «nessuno ha guardato» non sono la stessa frase.**

**E le due ambigue non vanno a Francesco come domanda: si sciolgono con un download, e
lo stesso download e il controllo negativo delle altre sette.**

Avevo detto di lasciarle ambigue e di non portargliele, perche due righe non giustificano
una domanda. Hanno **dissentito sulla conclusione e non sul principio**, con l'argomento
giusto: **non e una domanda a una persona, e un file.** Riscaricando
`ExportExcelVisiteScadenze` **oggi** — e adesso sappiamo che per questo report la data
dichiarata **e** l'istante dello scaricamento — le scadenze si ricalcolano sulle
esecuzioni piu recenti, e:

    MANARA   diventa 26.06.2027  ->  era ritardo di REGISTRAZIONE
             resta   25.07.2026  ->  e un richiamo ANTICIPATO vero
    PORRINI  diventa 27.07.2027  ->  ritardo
             resta   14.10.2026  ->  richiamo

**E lo stesso file scioglie le altre sette in un colpo**: se sono fantasma **spariscono
tutte e sette**, e quello e il **controllo che conferma la diagnosi** invece di lasciarla
come la piu plausibile delle spiegazioni. Che e la disciplina applicata a se stessi per
l'ennesima volta oggi — e stavolta **su una conclusione appena consegnata e gia
accettata**.

**Cosa cambia per la `0008`**, ed e piccolo sul numero e grande sulla natura: se le due
sono ritardo di registrazione, `scadenza_dichiarata` **non registra mai un dissenso** e
serve **solo per l'assenza del fatto** — le coppie senza esecuzione e le dieci
`PIANIFICATA`. Se sono richiami veri, ne registra **due**. La colonna esiste in entrambi i
casi; cambia **cosa dice di se stessa**, e un commento di colonna si scrive una volta e si
legge per anni.

**E la regola sull'unanimita esce piu affilata di come l'avevo scritta.** Avevo detto che
la regolarita che convince andrebbe spiegata per prima; loro aggiungono il perche:
**nove su nove senza una eccezione e raro nei dati umani**, e proprio per questo doveva
insospettire invece di convincere. *«Un medico che anticipa nove richiami su nove ne
lascerebbe almeno uno alla scadenza ordinaria; una sottrazione no.»* L'unanimita non e
una prova debole di intenzione: **e una prova di assenza di intenzione**, perche le
persone sono irregolari e le operazioni no.

**E una diagnosi sulla ripetizione che spiega meglio della mia.** Avevo scritto «un dato
che sembra spiegato non si riapre»; loro precisano che non era distrazione — **la
correzione precedente aveva riaperto il METODO e non il DATO**. Un dato chiuso smette di
essere un dato da guardare anche per chi ha appena imparato a guardare meglio, e le due
cose si riaprono separatamente.

**Spinti l'11 settembre sera, e li ho spinti io.** `41b4192..d6c6d4c`, fast-forward,
nove commit. Francesco ha detto «pusha» **a questa sessione**, e l'ho eseguito **da qui**
invece di riferirlo: la regola di quella corsia dice che **loro** eseguono `push` solo su
richiesta del proprio utente, e quella regola **resta intatta** — non e stata infranta e
nessuno ha chiesto di infrangerla. **Un'istruzione di prima mano a chi compie l'azione non
e una parola riportata**, ed e la stessa distinzione che l'11 settembre mattina aveva
fatto fermare quella corsia davanti a un'autorizzazione relaiata.

**~~Il commit della libreria non e stato spinto~~ — era gia su `origin` dalle 13:32, e
l'ho chiesto a Francesco come se fosse pendente.** Verificato: `4548621` sta in
`origin/main` di `formazione-81-utils-src` da sei ore, **zero commit non spinti**, e
`a1827fd` — la lettura dell'art. 16 — ci e **costruito sopra**. Il fascicolo GU da 6,5 MB
e in storia **ed e gia per sempre**.

**La cautela era giusta come cautela e tardiva come decisione**: il momento per guardare
quel PDF era **prima** del push, e quel momento e passato senza che nessuno dei due se ne
accorgesse. E anche se i 6,5 MB fossero stati un problema, **la risposta sarebbe stata
comunque «restano»**: riscrivere la storia di un repo che due corsie leggono costa piu del
PDF. Quindi la cosa onesta e **registrare che c'e e perche** — fascicolo integrale della
GU 260/2011, dieci pagine, **l'unica prova della fonte sotto la trascrizione del DPR**, che
e esattamente la ragione per cui i 26 MB di quella libreria stanno nel repo e non in una
chat.

**E ho messo sulla lista di Francesco una decisione che non esisteva.** Avevo letto quel
repo **due volte oggi** con `git show origin/main:` — per la pratica dei PDF in
`reference/fonti/` e per vedere se l'art. 16 fosse trascritto — quindi **guardavo `origin`
e avrei visto il commit**: non ho mai controllato se fosse spinto, perche avevo accettato
«un commit nella libreria in attesa» come dato. **Stessa forma dei nove commit, la stessa
sera, sullo stesso argomento**: ho ratificato un'affermazione sullo stato senza
verificarla, e l'ho ripetuta.

**E la loro e simmetrica alla mia**: avevano riferito quel fatto un'ora prima, **come nota
a margine invece che come «la decisione che stiamo tenendo aperta e gia presa»**. Stamattina
avevano dato un vincolo senza la sua ragione; stasera un fatto senza il suo peso. **In
tutti e due i casi l'informazione c'era e il suo peso no** — ed e la forma che, fra tre
corsie che si scrivono, costa piu di un dato sbagliato: un dato sbagliato qualcuno lo
contesta, un dato senza peso passa.

**Cosa cambia: da adesso lo stato di quella corsia si legge da `origin` come per le
altre.** Cosa non cambia: la sua regola, e quindi il **prossimo** blocco di commit
restera locale allo stesso modo. **Oggi e stata risolta la volta, non il meccanismo** — e
la scelta fra «spinge Francesco periodicamente» e «per questa corsia lo stato si chiede e
non si legge» resta aperta e resta sua.

**Nove commit non spinti per sei ore, e il difetto non e loro: e che non ho mai chiesto
perche.**

Segnalato da Francesco l'11 settembre sera, e prima ancora da AppSopralluoghi. I fatti:
`origin/main` di AppFormazione fermo a **41b4192 delle 08:28**, il loro HEAD a **d6c6d4c
delle 14:28**, e in mezzo **nove commit** — dalle 12:43 alle 14:28. Niente di non
committato.

Al primo commit di stamattina quella corsia ha scritto «il push lo chiedo a Francesco,
non lo do per assegnato». **Ho preso quella frase per buona e l'ho ripetuta una decina di
volte** — a Francesco e all'altra corsia — **senza mai verificare se fosse una regola o
un'assunzione**. Il coordinamento e di questo repo, e questa e la cosa che il
coordinamento doveva prendere.

**Perche e un'asimmetria e non una regola.** Le altre due corsie spingono ogni commit da
sole; oggi da qui saranno trenta push. La regola del progetto sull'autorizzazione
riguarda **lo scrivere su dati veri** — «un permesso su un database senza backup non si
relaia» — e un push su un repo git non e quello. E soprattutto: **lo stato delle tre
corsie si legge da `origin` dopo un fetch**, ed e il meccanismo con cui questo progetto
sa cosa succede. Nove commit non spinti non sono lavoro in attesa: sono **lavoro
invisibile**.

**E il costo l'ho pagato io senza accorgermene.** Per otto ore ho coordinato leggendo il
**loro disco** invece di `origin`: le migrazioni `0057`-`0062`, i documenti 14 e 16, e
`domini_orfani.py`, che su `origin` **non c'e**. Il programma dice che lo stato si legge
da `origin` e non dal disco, e **ho fatto l'opposto per mezza giornata senza dirlo**. Ha
funzionato perche erano **avanti** e non indietro — ma e la stessa regola violata, e nel
verso che non produce un errore visibile. La regola esiste contro il disco **vecchio**;
qui il disco era **nuovo**, e il risultato e stato lo stesso: `origin` non descriveva la
realta e nessuno se n'e accorto.

E non e astratto: la `0006` cita il loro modello, la loro `0060` ha cambiato le
grandezze, la decisione sui confinati poggia sul loro documento 14. **Niente di tutto
questo e verificabile da `origin`.**

**La ragione c'era, e non e nessuna delle tre che avevo ipotizzato: e una regola del
loro ambiente.** Quella corsia **esegue `commit` e `push` solo quando glielo chiede il
proprio utente** — non una policy di AppFormazione, non un'istruzione di Francesco che
non avevo visto, non un vincolo tecnico: **hanno verificato e non c'e niente che lo
impedisca**, nessun hook, nessun ramo protetto, e un `push --dry-run` passa pulito in
fast-forward.

E che abbiano committato nove volte e spinto zero **non e incoerenza**: un commit e
locale e reversibile, e senza commit quel repo non lavora. **Il push esce**, e li si
fermano.

**L'assegnazione l'ho ritirata, e la ragione che danno e migliore della mia.** Se
spingessero perche l'ha chiesto **una corsia pari** invece del proprio utente,
aggirerebbero una decisione che **non e mia da prendere** — e la loro frase e quella
giusta: *«la sede della decisione conta piu del suo contenuto. Se un giorno vi dicessi
«l'ha detto l'altra corsia» per fare una cosa che il mio utente non ha autorizzato,
dovreste non credermi.»* E la stessa regola che questo programma applica alle
autorizzazioni sui dati veri, vista dal lato di chi esegue.

**Quindi il rilievo resta, ed e un altro: hanno presentato un vincolo del proprio
ambiente come se fosse una regola del progetto, senza dire perche.** Una frase come «il
push lo chiedo a Francesco» va accompagnata dalla sua ragione **la prima volta che si
dice**, altrimenti **diventa una regola del progetto per adozione** — ed e esattamente
quello che e successo, in dieci ripetizioni mie.

**E la conseguenza strutturale e piu grande dei nove commit.** La regola di coordinamento
di questo progetto — *lo stato delle tre corsie si legge da `origin` dopo un fetch* —
**presuppone che tutte e tre possano pubblicare. Una non puo, per costruzione.** Quindi
la regola ha un buco che e stato invisibile finche non e costato una giornata: per
AppFormazione `origin` **non descrive lo stato e non puo descriverlo**, e chi legge
«AppFormazione e ferma alle 08:28» sta leggendo una cosa falsa in un posto che il
programma indica come autorevole.

**Va scritto nella tabella delle corsie e non in una nota**, perche chiunque legga deve
poter distinguere **«e ferma»** da **«aspetta una firma per costruzione»**: sono due
stati diversi e dal foglio si somigliano — che e la stessa frase che questo programma usa
per «una corsia ferma e diversa da una lenta», applicata un livello piu in basso.

Le strade sono due e la scelta e di Francesco: **spingere lui** i commit di quella corsia,
periodicamente o a richiesta; oppure **dichiarare che per AppFormazione lo stato si chiede
e non si legge**, e allora il fetch smette di essere il canale per un terzo del progetto.
La seconda costa zero ed e onesta; la prima e migliore e costa un comando. **E una distinzione va tenuta**: il commit nella
**libreria** e un'altra cosa e li si fermavano a ragione — porta un PDF da **6,2 MB**, e
un binario in git e per sempre. Quello resta un push che Francesco guarda prima, e
l'avevano segnalato loro per primi.

**La regola che ne esce, e vale per chi coordina piu che per chi esegue: una corsia che
si autolimita va chiesta, non ratificata.** Un «non lo do per assegnato» e prudenza da
parte di chi lo dice e diventa una regola inventata nel momento in cui chi coordina la
ripete senza verificarla. Oggi e successo dieci volte di fila, e ogni ripetizione l'ha
resa piu solida.

**La `0007` e la `0008` lette prima del carico: sei rilievi, e il primo non potevo
vederlo da qui.**

**1. Sette righe prendono due obblighi, e qui non c'e niente che li collassi.** Quattro
frasi nominano `rspp` **e** `datore_lavoro` con `posizione = 'datore'` — «RSPP - Datori
di Lavoro», «DATORE DI LAVORO- RSPP», «AMMINISTRATORE/DATORE DI LAVORO/RSPP» — e le mie
regole le risolvono **due volte**, giustamente **come ruoli**: quella persona **e** il
datore **ed e** il datore che fa l'RSPP.

Ma diventano **due obblighi formativi**, e non lo sono: il modello di AppFormazione ha
`crediti_formativi` con la riga `datore_lavoro_rspp -> datore_lavoro_art37 = 'totale'`,
**ASR Allegato III pag. 130** — «chi ha fatto l'art. 34 non deve rifare l'art. 37». **In
questo schema una tabella dei crediti non c'e**, cercata e assente. Quindi quelle sette
persone risulterebbero dovere il percorso dell'art. 34 **piu** le 16 ore dell'art. 37, e
`corso_assolve` funzionerebbe **perfettamente producendo il risultato sbagliato**.

E la loro formulazione e quella che conta: **non e un difetto della `0007`, e un difetto
che la `0007` ATTIVA.** Finche le nomine non entravano, il credito mancante non costava
niente. **Va nella `0009`**, e non e una colonna: e una tabella.

**2. L'indice unico della `0007` non impedisce la sovrapposizione.** Impedisce due righe
identiche, non che per la stessa parola coesistano `(rspp, null)` e `(rspp, titolare)`: il
predicato che risolve **le matcherebbe entrambe**, il totale crescerebbe restando
plausibile, e l'import creerebbe **due nomine per la stessa persona**. Un `check` non
puo vederlo — e una condizione **fra righe** — quindi entra come **conto** nella `0008`,
dichiarato come conto e non come vincolo.

**3. `esterno` risolve dove `socio` si astiene, e l'asimmetria non ha un motivo scritto.**
Le due ignoranze sono diverse e l'astensione regge — su quello non hanno obiezioni. Ma
`posizione = 'esterno'` e **il fatto piu azionabile che il testo libero abbia prodotto**,
quello che la colonna non poteva dire: un RSPP esterno **non e un dipendente**, e la sua
formazione **non e a carico di quell'azienda**. E si ferma in `ruolo_testo`: **non viaggia
con la nomina**. Avevo scritto che il campo libero dice piu della colonna — **questa e
l'unica riga in cui quel «di piu» viene raccolto e poi lasciato indietro.**

**4. Il 28% delle asserzioni atterra sull'obbligo che una nomina non basta a
dimensionare.** `ADD. ANTINCENDIO` sono **47 righe su 168**, e `antincendio` ha un
discriminante — il livello — che viene dalla **scheda di ingresso**, cioe da una risposta
del cliente. Dopo l'import quelle 47 daranno «obbligo dovuto, **ore ignote**» finche
quella societa non risponde. Non e un difetto: e che **il blocco piu grande di nomine
nuove atterra sull'unico obbligo che una nomina non quantifica**, e l'organigramma
sembrera completo mentre il fabbisogno resta vuoto.

**5. La regola sul nome non e un elenco travestito, ma il `default` la disfaceva.** E il
rilievo che ha cambiato la migrazione. La regola e un **proxy** — la grandezza viene dalla
fonte, la regola legge il **titolo commerciale** — e il difetto non era il proxy, era
**cosa succede quando manca**:

    default 'durata_corso'   il corso non marcato e CONFRONTABILE   -> fallisce APERTO
    default 'assente'        il corso non marcato NON si giudica    -> fallisce CHIUSO

**Quando la loro regola sbaglia il motore si rifiuta di giudicare; quando sbagliava la mia,
giudicava.** Invertito: `default 'assente'`, e si marca **solo in positivo**. Cosi il
conteggio degli `assente` smette di essere una constatazione e **diventa un filo teso**.

**6. Il guardrail assente e una scelta, e la difendono** — non c'e un motore da proteggere
e una vista che nessuno interroga sarebbe impalcatura — **ma reggeva solo se lo stato non
marcato fosse quello prudente, e non lo era.** Quindi: niente vista adesso, **default
invertito adesso**. E quando il guardrail si scrivera, va scritto come **whitelist** — «e
`durata_corso`?» e non «non e `parte_pratica`?» — che e l'errore che la loro `0060` ha
fatto e la `0062` ha dovuto disfare.

**E una cosa che non avevo chiesto**: `ATTR_CARRELLO.ore = 12` e marcato `durata_corso`, e
**la grandezza e giusta** — ma e la durata di **una variante**, e il percorso combinato ne
vuole 16. La colonna nuova puo dare l'impressione che quel numero sia **completamente
qualificato**, e non lo e: l'altro asse e «quale corso», non «quale grandezza». E
l'indeterminazione morde **nel verso indulgente** — chi ha fatto le 12 di una tipologia
quando gliene servivano 16 passa il confronto. Scritto nel commento della colonna.

**La `0008` e stata corretta prima del carico, e la regola del «merged non si tocca» non
vale qui**: quella regola esiste per non invalidare **misure gia prese**, e di misure su
questa migrazione non ce n'era nessuna. **E il motivo per cui gliel'ho fatta leggere.**

**I segnaposto cercati di proposito sono quarantasette, con settantaquattro persone
vere dentro — e la terza forma non e ne ripetuta ne incrementale.**

`XXXXXXXXXXXX` era stato trovato **per caso**, seguendo un codice fiscale duplicato.
Cercati di proposito su ElencoSedi, con un rilevatore **dichiarato prima dei numeri**
(un solo carattere distinto, lunghezza almeno 4 — la soglia serve: a 3 prenderebbe
`VR`, `bg`, `SONA`):

    righe attive                      619
    con zero campi segnaposto         572
    con un campo                       11
    con due campi                      34      sempre la stessa coppia: sede + P.IVA
    con tre campi                       2      'Prova' e 'XXXXXXXXXXXX'
    ---
    sede 36 · P.IVA 47 · ragione sociale 2 · codice fiscale del cliente 0

**E la mia ipotesi e stata esclusa, che e un risultato.** Avevo chiesto se ci fosse una
famiglia sulla **ragione sociale**, il campo su cui non avevamo mai guardato: **e il piu
pulito dei quattro** — due righe in tutto, ed entrambe sono segnaposto anche altrove.
Nessuna riga ha il segnaposto **solo** sul nome. Cercare di proposito ha **tolto**
un'ipotesi invece di confermarne una.

**La forma e una terza, e si comporta in due modi nello stesso campo.** Sulla sede i
sette valori distinti sono **tutti la stessa X ripetuta a lunghezze diverse** — 5, 6, 10,
11, 12, 15 caratteri. Non e ripetizione pura come il `00000000000` delle P.IVA, e non e
incrementale come gli `XXXYYY` dei codici fiscali: e **ripetuta dentro la variante e
multi-variante fra una e l'altra**. Un `unique` ne prende **l'80%** — 40 righe sullo
stesso valore, 22 sullo stesso — e **lascia passare la coda**, le cinque varianti da una
riga sola.

**E le varianti di lunghezza fanno da discriminante accidentale**: `XXXXXXXXXX` e
`XXXXXXXXXXX` sono stringhe diverse, quindi chiavi diverse. Due aziende omonime con la
sede segnaposto **si separerebbero o no a seconda di quante volte qualcuno ha premuto X**.
E la stessa forma dei dieci segnaposto distinti di stamattina: **la proprieta che salva e
la stessa che rende il difetto invisibile**.

**Contro il `check` della `0001` — `partita_iva ~ '^[0-9]{11}$'` — diciassette dei
diciotto valori distinti sono rifiutati**, `O2759230242` compreso, che comincia con la
**lettera O** e sembra una P.IVA a chiunque guardi la lunghezza. **Ne passa uno solo**:
`00000000000`, che di cifre ne ha undici. E poiche e `unique`, **la seconda riga fallisce
e la prima no**: quaranta righe portano lo stesso valore e **una entrerebbe come P.IVA
buona**. Terza volta oggi che **la prima istanza di un segnaposto e invisibile** e la
seconda no.

**Quello che il mio schema NON ha, ed e il punto.** `cliente.ragione_sociale` **non ha
nessun vincolo di unicita**, quindi le **36 righe** in cui ne la P.IVA ne la sede
identificano **non rompono niente**: rompono la capacita dell'**import** di riconoscerle.
Il vincolo non codifica l'identita, la codifica l'import — **identico a `persona`**. Quindi
`cliente` chiede lo stesso trattamento della `0008`: `partita_iva` **null quando non e una
P.IVA**, e `partita_iva_origine` accanto. **Quinta tabella, stessa forma**, e questa volta
il caso e arrivato **dopo** che il modello era gia stato scritto per un'altra tabella.

**E settantaquattro persone vere stanno dentro quelle 47 righe** — 69 con un codice
fiscale valido — fra cui **tre dentro un cliente che si chiama `Prova`**. Non sono righe
da scartare: vanno importate **sapendo che il loro cliente non identifica**, che e una cosa
diversa dallo scartarle e diversa dall'importarle e basta.

**Sette delle nove «scadenze anticipate» della `0005` erano aritmetica su una fotografia
vecchia. Non una scelta clinica: una sottrazione.**

La `0005` scrive che `scadenza_dichiarata` va valorizzata «solo dove una fonte esterna
dissente dal calcolo — **9 righe su 769**, tutte e nove **anticipate**». Rifatto il conto
contro lo **storico** del nuovo file: le nove sono le stesse, ma in **sette casi su nove**
la dichiarata e esattamente **penultima esecuzione + periodicita**, e l'esecuzione piu
recente e **posteriore al 06/08** — cioe alla fotografia dello scadenzario, che **non
poteva conoscerla**. Rifatto con «ultima esecuzione **nota al 06/08**»: **sette spiegate,
due no**.

**E la direzione che sembrava la prova si spiega da se.** «Tutte e nove piu **vicine**,
nessuna piu lontana» sembrava il richiamo prudente di un medico; e invece **una scadenza
calcolata su un'esecuzione piu vecchia cade prima, sempre**. Un pattern unanime non era
un indizio di intenzione: era la firma di un'operazione. **La regolarita che convince e
spesso quella che andrebbe spiegata per prima.**

**Le due che restano** — MANARA DAVIDE e PORRINI SERENA — hanno la dichiarata = penultima
+ periodicita **anche al netto del taglio**, e restano ambigue fra due letture che i dati
non separano: **ritardo di registrazione** (il file porta la data dell'esecuzione, non
quella dell'inserimento) oppure **richiamo anticipato vero**.

**E la loro diagnosi e la parte che tengo**: *«avevo un'altra rilevazione a un metro di
distanza — lo storico — e ho concluso senza aprirla. Due volte sullo stesso dato.»* La
prima era il «796 su 796».

**Cosa cambia per lo schema.** La scadenza e **derivabile** molto piu di quanto la `0005`
suppone: **784 su 793** con l'ultima esecuzione, **791 su 793** con l'ultima nota alla
data della fotografia — il **99,7%**. Quindi `scadenza_dichiarata` **serve ancora ma per
altro**: per **due** righe ambigue, e soprattutto per i casi in cui derivare non e
impreciso ma **impossibile** — le coppie dello scadenzario **senza nessuna esecuzione**.

**E quel caso ha un nome, che e la risposta al secondo quesito.** `PIANIFICATA` non marca
un appuntamento fissato: **dieci righe, tutte della stessa societa, e nessuna delle dieci
ha una sola esecuzione nello storico**. Marca le righe che **non derivano da un fatto** —
le scadenze di persone **mai visitate**, con una data messa a mano (nove su dieci al
**31 dicembre**, una data tonda che nessun calcolo produce). E **l'unico posto dello
scadenzario dove una scadenza esiste senza un fatto dietro**, cioe esattamente dove una
scadenza calcolata non e diversa: **e impossibile**.

**E il `(7)` non e un terzo oggetto**, ed e loro la correzione: ha **le stesse 35 colonne**
del vecchio, `Stato` compresa. E **il vecchio filtrato sullo scaduto** — 315 righe con data
**passata 315 su 315**, e delle 489 escluse **477 sono future**. Non alternativi:
**complementari nel tempo**. Quindi `scadenza_dichiarata` si riempie dal **vecchio**, che
e l'unico a coprire il futuro fino al 2031. Con dodici righe di residuo di cui **otto
dichiarate non spiegate** invece di coperte da una quarta ipotesi.

**E `scadenza_fonte` ha adesso una dimostrazione e non un argomento.** Le sette divergenze
fantasma di oggi **sono** la prova che senza la data del file **non si distingue una
scadenza anticipata da una scadenza vecchia** — e per un anno nessuno se ne sarebbe
accorto, perche entrambe si presentano come «dichiarata diversa dal calcolo». **Settima
volta oggi**, e la prima con una dimostrazione al posto di un ragionamento.

**Lo scarto di tre era fra la loro misura e il loro codice, e i tre casi cadono dentro
una difesa scritta stamattina.**

I tre sono **codici fiscali di diciassette caratteri**, verificati anche qui sulle stesse
righe del nuovo file: `LNRZDRA75D11C342V` (LIANZI DARIO), `GRSLNE67A60L781MH` (GRISI
ELENA), `PRZBBR84S51Z5050W` (PREZZI BARBARA). Sono **gli unici tre** che non fanno sedici
dopo la pulizia, in tutto il file.

**E `GRSLNE67A60L781MH` era gia fra le otto celle anomale del foglio «Visite» di
stamattina: la stessa persona.** Quindi quel difetto **attraversa due export diversi** —
sta nel dato **a monte**, non nell'estrazione. Un difetto che compare in due estrazioni
indipendenti ha smesso di poter essere un artefatto di lettura.

**E non si correggono, benche a occhio si veda quale carattere e di troppo** — la `H` di
GRISI, la `R` di LIANZI, lo `0` di PREZZI. Proprio perche si vede in tre casi su tre
qualcuno scriverebbe la regola, **e la regola sbaglierebbe sul quarto**.

**La loro correzione vale piu del numero.** Il 1.016 era la soglia del loro **script di
misura**, non il comportamento del loro **import**, che non filtra per lunghezza e
**marca soltanto**. Quindi lo scarto non era fra due misure: **era fra la loro misura e il
loro codice**, e me l'avevano mandata come se descrivesse l'import. E la stessa
imprecisione di stamattina — «da noi sporca il campo e non l'identita» — **sulla stessa
funzione**, e averla riconosciuta due volte sullo stesso punto e cio che la rende una
lezione invece di un inciampo.

**E i tre cadono dentro la difesa decisa stamattina invece di chiederne una nuova**:
calcolare il controllo, trattare il fallimento come **assente**, tenere il verbatim in
`codice_fiscale_origine`, far scattare il ripiego. **E la prima volta oggi che succede in
quest'ordine**: tutte le altre volte la difesa e arrivata dopo il caso.

**E resta un'ultima cosa ignota prima dell'import della sorveglianza**, ed e loro l'avere
segnalato senza inseguirla: il secondo file nuovo, `ExportExcel (7)`, **non e il sostituto
di `VisiteScadenze`**. Ha 315 coppie **tutte gia dentro** le 804 del vecchio — meno della
meta — e una colonna **`Stato`** che il vecchio non ha, con 8 righe `PIANIFICATA` e 311
vuote. Finche non si sa **perche** ne abbia meno, `scadenza_fonte` non ha un valore da
scrivere: e la colonna che esiste apposta perche **una scadenza che nessuno sa da dove
venga non e opponibile**. Assegnato.

**«Visite Fatte» esiste, e lo storico c'e. L'import cambia forma prima di essere
scritto, che era il punto della domanda.** Francesco l'ha trovato e scaricato l'11
settembre alle 15:23; misurato qui e da AppSopralluoghi **separatamente**.

    righe dati                                  1.383   tutte Genere = 'Visita'
    societa                                        66
    dal                                    14/06/2016   al 09/09/2026
    coppie (C.F., tipo)                         1.053
    con PIU DI UNA data                           167

E la distribuzione, **identica nelle due misure**: 91 coppie con due date, 47 con tre, 13
con quattro, 4 con cinque, 7 con sei, 4 con sette, e **una con otto** — otto visite
mediche annuali consecutive dal 2018 al 2026 sulla stessa persona.

**Il confronto chiude la domanda**: il nuovo file e un **superinsieme stretto** del foglio
— 800 coppie in comune, **zero** solo nel foglio, **250** solo nel nuovo. Quindi
importando cio che avevamo, **per 167 persone avremmo tenuto l'ultima visita e buttato le
precedenti — e i conti sarebbero tornati lo stesso.** E esattamente il caso che la domanda
cercava, e la ragione per cui valeva dieci secondi di menu.

**E `sorveglianza_una_per_data` smette di essere una porta su un muro**: il vincolo
`(persona, accertamento, data)` era stato scritto per reggere entrambe le risposte, e
adesso e la risposta giusta ad essere quella che lo esercita.

**Una cosa in piu che ho trovato contando: i tipi sono DIECI, non nove.** Nel foglio del
09/09 `Visita oculistica quinquennale` aveva **zero** righe, e nella storia ne ha **due**.
Il decimo accertamento del vocabolario della `0005` non era una voce inutilizzata: era una
voce **senza esecuzioni correnti**. Un vocabolario giudicato su una fotografia sembra
sempre piu grande del necessario.

**E un piccolo scarto da tenere**: io conto **1.019** codici fiscali distinti e **1.053**
coppie, loro **1.016** e **1.050**. Lo scarto e **tre** in tutti e due i numeri, quindi e
**una regola di normalizzazione** e non un errore — la stessa differenza di soglia che
stamattina valeva due righe sugli spazi interni. Va sciolto prima dell'import, non perche
tre righe contino, ma perche due conti che differiscono sempre della stessa quantita
**hanno una causa sola** e conviene saperla.

**E il controesempio che ribalta una mia conclusione di un'ora fa.** I due file nuovi
dichiarano «Dati aggiornati al **11/09/2026 15:23**» — **l'istante dello scaricamento**.
Quindi **«riscaricare non allinea» era troppo forte**: lo zip resta la prova per quei tre
file, prodotti il 03/09 e dichiarati 06/08, ma **non e una legge del gestionale**, dipende
dal report. **Cade la frase, non la colonna** — anzi la colonna serve **di piu**: se la
freschezza dipende dal report e non dal momento, **non c'e nessuna regola che permetta di
dedurla**, e l'unico modo di saperla e leggerla da ogni file e conservarla.

E la scelta delle **due colonne** regge anche qui, ed e la prova che serviva: «Dati
aggiornati al 11/09/2026 **15:23**» ha l'ora, «Report aggiornato al 09/09/2026» no.
**Stesso gestionale, stesso giorno, due formati** — un `timestamp` unico avrebbe dovuto
inventare mezzanotte su uno dei due **gia oggi**.

**Il 31 non e stato dichiarato: e stato misurato. Dodici sono tempo, diciannove no.**
(`bfdbb6b`.)

Avevo proposto la strada economica — dichiarare che quel numero era misurato su
fotografie a cinque settimane di distanza — e loro hanno fatto la cosa migliore: hanno
**contato quali**. Le coppie «solo nel foglio» con esecuzione **posteriore al 06/08**,
cioe che lo scadenzario **non poteva conoscere**, sono **dodici**, su **tre date** e
**due sole societa** — Rittal RCS sei e FOOD & SWEET sei: due **campagne di visite di
fine agosto**. Le stesse due societa che compaiono nelle nove date che non tornano, e non
e una coincidenza utile: quelle due aziende hanno avuto movimento in agosto, e il
movimento si vede **in tutti e due i modi**.

**Le altre diciannove sono divergenza vera, e lo dimostra la distribuzione**: nove del
2019, una del 2020, una del 2021, una del 2025, sette del 2026 anteriori ad agosto.
**Un'esecuzione del 2019 assente dallo scadenzario di agosto 2026 non e un problema di
fotografie.** La dichiarazione e quindi piu stretta di come l'avevamo pensata: non «una
parte ignota potrebbe essere tempo», ma **«dodici lo sono, diciannove no, e questi sono i
nomi»**.

**E ricontando hanno trovato quattro numeri sbagliati nel proprio documento**, e le due
cause sono **roba di oggi**: le righe dello scadenzario erano 814 e sono **812** — le
altre due erano **il pie di pagina contato come dato** — e i codici fiscali inutilizzabili
erano «7 e 9» e sono **otto per parte**, cioe l'otto-contro-sei gia corretto stamattina
**sulla stessa colonna**. Quindi 800, 804 e **769 in entrambi**, e il 760 diventa 759 —
e adesso i conti **chiudono**: 759 + 9 + 1 = 769.

La loro diagnosi vale piu della correzione: **«quel numero l'avevo sbagliato una volta e
citato due, che e esattamente il modo in cui un errore piccolo diventa strutturale».** E
hanno verificato che i numeri che contano **non cambino**, invece di supporlo — e
controllato che nessuna coppia comparisse due volte da nessuna delle due parti, **zero**,
che era affermato e non misurato.

**E una nota che arriva in tempo per la `0008`: la data dichiarata non ha un formato
solo.**

    Report aggiornato al 09/09/2026            senza ora
    Dati aggiornati al 06/08/2026 07:44        con l'ora

Se la colonna fosse un `timestamp`, sui file del primo tipo bisognerebbe mettere
**mezzanotte** — e **mezzanotte e un valore dedotto che non si distingue da uno vero**,
cioe il difetto da cui e nata tutta questa famiglia, all'ultimo passo utile per
evitarlo. Quindi **due colonne**: la **data** che si confronta, e il **testo verbatim**
della riga di pie di pagina, dove l'ora resta per chi la vuole. **Sesta volta oggi** che
la risposta ha questa forma, e la prima in cui e stata vista **prima** di scrivere la
colonna invece che dopo averla scritta.

**E la mia regola sulle due diciture andava corretta prima di entrare nella `0008`.**
Avevo scritto «*Dati aggiornati* = freschezza, *Report aggiornato* = produzione», e
implicitamente «quindi se dice *Dati* e vecchio». **Il secondo pezzo e falso**, e il
controesempio e in casa: `elencoAnagraficaFormazioni` dice «**Dati** aggiornati al
30/07/2026 17:04» ed e stato salvato **il 30/07 alle 17:01** — coincide con l'estrazione
a tre minuti.

**La dicitura dice QUALE DELLE DUE COSE la data misura; non dice se le due coincidano.**
Lo dice solo il confronto con un **timestamp esterno**, e per i tre del 3 settembre
quel timestamp e stato lo zip. Anzi, `elencoAnagrafica` lo rafforza: una data interna
**tre minuti dopo** l'mtime del file e impossibile come momento di produzione, quindi
«Dati aggiornati al» non descrive **mai** il file — descrive **sempre** il dato, e puo
cadere prima o dopo l'istante in cui il file esiste.

Da cui la conseguenza sulla colonna: **si riempie con la data dichiarata e non con un
giudizio su quanto sia vecchia.** E un **valore**, non una valutazione. Il giudizio lo fa
chi legge, confrontando due colonne di file diversi — che e esattamente il motivo per cui
la colonna serve.

**E il corollario che nessuno dei due aveva detto, ed e il verso che mancava.** Se «Dati
aggiornati» e la freschezza del dataset **a monte**, allora due export della stessa
famiglia scaricati in **momenti diversi** possono portare la **stessa data interna** — e
sarebbero **la stessa fotografia, non due**. Quindi la colonna non serve solo a dire
«questi due file non sono confrontabili»: serve anche a dire «**questi due sono lo stesso
istante**, anche se li ho scaricati a un mese di distanza». **La seconda informazione oggi
si perde del tutto**, e non e la meno utile delle due: e quella che permette di
**combinare** invece di limitarsi a diffidare.

**Quindi il consiglio cambia, e cambia in peggio.** Riscaricare allinea il **momento
dell'estrazione** e non il **momento dei dati**: se il gestionale aggiorna quei tre
insiemi con la propria cadenza, tre file scaricati insieme continueranno a portare tre
freschezze diverse, e **non c'e volonta di nessuno che li allinei**. «Tre file letti
insieme producono uno stato che non e mai esistito» smette di essere un avvertimento e
diventa **una condizione permanente dell'import**.

Da cui la conseguenza, che e loro e che accetto: non «li riscarichiamo insieme» ma
**l'import registra la data interna di ogni file da cui ha letto** — la fotografia
accanto al dato che ne viene, che e la stessa forma di `ateco_origine`, `testo_origine`,
`codice_fiscale_origine` e della coppia `testo`/`chiave`. **Quinta volta oggi.**

E il **31** delle coppie «solo nel foglio» perde l'opzione economica: se le date non si
possono allineare, **riverificarlo su file della stessa data non sara possibile**, e
dichiararlo «misurato su fotografie a cinque settimane di distanza» diventa **l'unica**
strada invece della piu conveniente.

**E nemmeno «3 di testa e 2 di piede» e un guard universale**: `ExportExcel (4)` ha le
intestazioni alla riga 2, i dati dalla 3 e **una sola** riga di piede. Tre file su sei
seguono una regola, uno ne segue un'altra, uno non ne segue nessuna. Il riconoscimento
va fatto **per forma**, o dichiarato **per file**.

**I due conti delle due corsie differiscono di esattamente due righe per file, e non
sbagliava nessuno dei due: «righe» non era stato definito.**

Avevo rilanciato a Francesco «13.350 righe di corsi fatti e 4.899 di scadenze» prendendoli
da AppFormazione **senza contarli**. AppSopralluoghi li ha contati prima di girare la
frase e ha corretto: 13.348 e 4.897. **Contati anche qui**, e la struttura spiega tutto:

    riga 1   'Elenco Visite/Formazioni'      titolo
    riga 2   vuota
    riga 3   intestazioni di colonna
    ...      dati
    penultima 'https://overall.sgslweb.com/'  pie di pagina
    ultima    'Dati aggiornati al ...'        pie di pagina

    ExportExcelCorsiFatti      13.353 lette  - 3 testa - 2 piede = 13.348
    ExportExcelCorsiScadenze    4.902        - 3       - 2       =  4.897
    ExportExcelVisiteScadenze     817        - 3       - 2       =    812

**AppFormazione toglieva le tre righe di testa e non le due di piede; AppSopralluoghi
toglieva entrambe.** La differenza e **esattamente due per file**, in tutti e tre.
Nessuno dei due era distratto: la parola «righe» non aveva una definizione, e due
convenzioni non dichiarate producono **due numeri veri che non concordano**. E la forma
di «un vocabolario osservato e un campione» applicata a un conteggio invece che a un
dominio.

**E il quadro del pie di pagina e completo su sei file, e nessun guard unico funziona:**

    elencoAnagraficaFormazioni    2 righe   URL + data
    ExportExcelCorsiFatti         2
    ExportExcelCorsiScadenze      2
    ExportExcelVisiteScadenze     2
    ExportExcel (4), ogni foglio  1         solo la data, niente URL
    ElencoSedi                    0         l'ultima riga e un cliente vero

Cinque su sei ce l'hanno, **in due forme diverse**, e il sesto no. Un guard che togliesse
«le ultime due righe» **sbaglierebbe su due file su sei in due modi opposti**: ne
lascerebbe una in `ExportExcel (4)` e ne **mangerebbe una vera** in `ElencoSedi`.

**E la cosa che nessuno aveva guardato: i file hanno tre date diverse.**

    ExportExcelCorsiFatti / CorsiScadenze / VisiteScadenze    06/08/2026
    ExportExcel (4), tutti e quattro i fogli                  09/09/2026
    elencoAnagraficaFormazioni                                30/07/2026

Per le 808 visite non cambia niente — vengono tutte dal foglio del 09/09. Ma il confronto
fra quel foglio e `ExportExcelVisiteScadenze` mette a paragone **due fotografie a cinque
settimane di distanza**, e la riconciliazione gia fatta — 770 coppie in entrambi, **31
solo nel foglio** — potrebbe contenerne qualcuna che e semplicemente **piu recente**.
Trentuno righe di cui una parte ignota non e una divergenza ma il tempo passato: va
riverificato su file della stessa data, o dichiarato.

**L'impronta dei 268 e dell'ESTRAZIONE e non dei testi, e la `0008` deve portarsi
dietro il numero di riga — altrimenti diventa incontrollabile.**

Avvertimento di AppSopralluoghi arrivato **prima** che caricassi, e **ricalcolato qui**:
lo sha256 sta sui 268 `testo_origine` concatenati con `\n` **nell'ordine di riga del
foglio**, in UTF-8, verbatim.

    dichiarato   9742ecef...5f30
    ricalcolato  9742ecef...5f30     COMBACIA
    alfabetico   fd81d6a7...        DIVERSO
    per chiave   0ac9431a...        DIVERSO

**E qui la conseguenza che non era nel loro avvertimento.** `corso_alias` ha per chiave
`testo` e **nessuna colonna d'ordine**. Se caricassi i 268 e poi provassi a ricalcolare
l'impronta **dal database**, dovrei ordinare per `testo` — e sarebbe **la trappola A11
da capo**: l'`order by` di PostgreSQL segue la **collation**, quindi otterrei un **terzo**
hash e concluderei che il carico e rotto. La stessa trappola che l'11 settembre aveva gia
prodotto un falso allarme sul dizionario, e che questa volta si presenterebbe **a valle**
invece che a monte.

Quindi la `0008` **porta `riga_foglio`**, e la query di verifica ordina per quello. Non e
una colonna di comodo: **e cio che rende l'impronta ricontrollabile dopo il carico**, ed e
la stessa forma di tutto il resto di oggi — un derivato che non porta con se cio che
serve a rivederlo.

E due cose che vanno sapute con quei testi: i 268 sono i titoli dell'export **del
30/07/2026** — se il catalogo nel frattempo e cambiato, l'impronta **non torna per la
ragione giusta**, cioe perche i testi sono davvero altri; e le **due righe di pie di
pagina** (l'URL e la data) sono gia fuori dai 268 ed elencate a parte, quindi saltarle di
nuovo altrove le conterebbe due volte.

**Il senso dell'avvertimento vale piu del dettaglio**: un'impronta che non torna per una
ragione **procedurale** segnalerebbe un problema che non c'e, e **la prossima volta
nessuno ci crederebbe piu**. Un controllo perde valore la prima volta che grida a vuoto,
non la prima volta che sbaglia.

**E i dieci segnaposto sono innocui da loro per la stessa proprieta per cui erano
pericolosi da me. In nessuno dei due casi e una difesa.**

AppSopralluoghi ha verificato se la conclusione mordesse anche il proprio import invece
di darlo per scontato — e ha cominciato **correggendo cio che mi aveva appena scritto**:
«da noi sporca il campo e non l'identita» era impreciso, perche `import_key` e
`anag:<cliente_id>:<cf ripulito>` e quel cf passa da `pulisci()` **ma non da `valido()`**.
Il valore sporco **e nella chiave**, solo col cliente davanti.

Misurato: **zero fusioni sbagliate oggi**. Trentuno righe col controllo fallito, zero
gruppi `(cliente, cf-non-valido)` con piu di una riga, zero valori su piu clienti. Nemmeno
dove sarebbe piu facile — EMME.TI ha **due** segnaposto e MOBILTABA **tre**, dentro lo
stesso cliente, e **non si fondono solo perche i suffissi sono diversi**.

**Ed e li che la ragione non regge.** Da loro quei dieci non fanno danno **perche sono
distinti**, cioe per la stessa identica proprieta per cui da me **passavano l'`unique`**.
La caratteristica che li rendeva pericolosi nel mio schema li rende innocui nel loro, e in
nessuno dei due casi e una difesa: **e una coincidenza sul valore, non una regola.**

Il controfattuale lo mostra e lo scrivono loro: se il gestionale emettesse
`XXXYYY123456X000` **per tutti**, da me collidirebbe al secondo e si vedrebbe subito; da
loro **fonderebbe in silenzio le tre persone di MOBILTABA in una**. *Il loro import e
protetto dall'unica forma di segnaposto che il mio rifiuterebbe* — e viceversa. I due
schemi hanno modi di rompersi **complementari**, e ciascuno e coperto esattamente dove
l'altro non lo e.

Da cui la regola, che vale oltre i codici fiscali: **una difesa che dipende dalla forma
del valore cattivo non e una difesa.** Regge finche il valore cattivo ha quella forma, e
non c'e niente che glielo imponga.

E una seconda esposizione che **non si puo misurare da un export solo**, dichiarata come
ipotesi: se a un prossimo export il gestionale assegnasse **un suffisso diverso alla stessa
persona**, la loro `import_key` cambierebbe e la persona **rientrerebbe come nuova**.

**E un rilievo sul metodo che merita di stare fra le regole.** Che io abbia **riscritto**
l'algoritmo del carattere di controllo invece di importare una libreria e la ragione per
cui il riscontro vale — e la loro frase lo dice meglio: **«due librerie che concordano
possono essere la stessa tabella copiata due volte»**, e oggi e gia successo col dizionario
ATECO identico in tre posti, dove la coincidenza era **transitiva** e non indipendente.
Due implementazioni dell'**algoritmo** che concordano su 3.269 celle sono un'altra cosa.

**Le soglie sul codice fiscale sono TRE, e la terza decide il vincolo che stavo per
scrivere. Dieci valori hanno la forma giusta e non sono identita.**

Segnalato da AppSopralluoghi **prima** che il vincolo fosse scritto, e **ricalcolato qui
da zero** — l'algoritmo del carattere di controllo implementato invece che importato,
cosi se sbaglia sbaglia in modo ispezionabile. **I tre numeri coincidono al pezzo:**

    A  16 alfanumerici sul GREZZO ................  3.261   (ne scarta   8)
    B  16 alfanumerici DOPO la pulizia ...........  3.266   (ne scarta   3)
    C  pulizia + forma + CARATTERE DI CONTROLLO ..  3.238   (ne scarta  31)

`A` e il `check` della `0001` come sta oggi. `B` e la normalizzazione che avevo proposto,
e rende quel che dicevo: **5 righe su 8 rientrano**. **Fra `B` e `C` ci sono 28 righe che
sono sedici alfanumerici e non sono codici fiscali**, e si dividono in due gruppi con
conseguenze diverse.

**Dieci sono un segnaposto fabbricato dal gestionale**, e sono il caso peggiore possibile
per un `unique`:

    XXXYYY123456X126  X187  X190  X199  X203  X204  X205  X208  X236  X237

**Dieci righe, dieci valori distinti**: il suffisso e un **contatore**. Hanno esattamente
la forma che il mio `check` pretende, **non collidono mai fra loro per costruzione**, e
quindi `codice_fiscale unique` **non puo rifiutarli**: entrerebbero come **dieci identita
buone**. E l'osservazione che lo rende una regola e loro: **un segnaposto che si ripete si
vede, uno incrementale no** — la P.IVA `00000000000` si scopre al primo conflitto, questo
non produce mai un conflitto.

**Le altre diciotto sono persone vere con un refuso**: diciassette hanno il **carattere di
controllo sbagliato** — `CRNNRC79D18L781V` per CORNALE ENRICO, dove l'ultima lettera
dovrebbe essere `Y`; `CNNGPP59C23F464N` per CANOVA GIUSEPPE, `N` invece di `X` — e una,
`CHWSKD92E01Z2490`, finisce con una cifra dove il codice fiscale vuole una lettera.

**Da cui la decisione, e non e irrigidire il `check`.** Mettere il carattere di controllo
nel vincolo rifiuterebbe **diciassette persone vere** per una lettera sbagliata, e perdere
una riga e peggio che tenerla imprecisa. La soglia del **formato** resta dov'e; quella
dell'**identita** si sposta nell'import, che calcola il controllo e tratta ogni fallimento
come **assente** — i dieci segnaposto finiscono nel ripiego cognome+nome invece che in
dieci identita inventate.

**E per non perdere cio che c'era scritto, la risposta e quella che oggi e gia stata
trovata tre volte**: `persona` prende un `codice_fiscale_origine` accanto al campo
normalizzato, e `codice_fiscale` **e null quando il valore non e un codice fiscale**. Cosi
«non ce n'era» e «ce n'era uno e non era un C.F.» restano **distinguibili** — la stessa
cosa di `ateco_origine` sul cliente, di `testo_origine` su `corso_alias`, e della coppia
`testo`/`chiave` della `0007`. **Quarta tabella, stessa forma, e questa volta la
soluzione era gia in casa prima che il problema arrivasse.**

**E loro hanno corretto se stessi in un verso che vale la pena registrare.** Avevano
scritto «sei righe malformate»; sono otto, e la frase e loro: *«contate, non stimate: e la
seconda volta oggi che sbaglio nel verso di far sembrare un problema piu piccolo»*. Un
errore ha un verso, e questo e il verso che non si corregge da solo — perche un problema
che sembra piccolo non viene riguardato.

**E sul disacordo di prima hanno dato ragione a me con un'aggiunta che vale piu della
concessione**: che da loro la stessa persona su due organigrammi resti due schede **non e
una proprieta del loro modello, e un limite** — e l'avevano descritta come una proprieta.
E la distinzione fra le due cose e tutto il valore di averla guardata in due.

**L'identita delle persone: i numeri di AppSopralluoghi tornano, io ne trovo due in
piu, e la conclusione sullo schema NON e la stessa per i due modelli.**

**Prima una correzione al mio 3.501, ed e loro.** Una di quelle righe **non e una
persona**: e il **pie di pagina** dell'export — «Report aggiornato al 09/09/2026» —
con la Societa piena e tutto il resto vuoto. Le righe persona vere sono **3.500**.
E l'avvertimento che vale piu della correzione: un import di **clienti** che
controllasse solo «ragione sociale non vuota» creerebbe un cliente **chiamato «Report
aggiornato al 09/09/2026»**. E non c'e un guard unico da scrivere: `elencoAnagrafica
Formazioni` ha **due** righe di pie di pagina — ed e la ragione per cui «il catalogo ha
270 righe» invece di 268 — mentre `ElencoSedi` **non ne ha nessuna**, e l'ultima riga e
un cliente vero. **Non e una regola degli export Sicurweb: va controllato file per file.**

**I C.F. malformati sono otto e non sei, e i due in piu li trova il mio `check`.** La
`0001` impone `^[A-Z0-9]{16}$`, che **rifiuta gli spazi interni**:

    CNVRNT6 3S12B546 X    18   Canova Renato        REDIL COSTRUZIONI SRL
    SNVLRS68 D10G693L     17   Sanavia Loris        REDIL COSTRUZIONI SRL
    FNSDNL85P09F965J,     17   virgola in coda
    PNTGNN88S14G039T,     17   virgola in coda
    PPEMHL90E28L781Y?     17   punto interrogativo in coda
    GRSLNE67A60L781MH     17   una lettera in piu, e non c'e niente da togliere
    54175989000           11   e una P.IVA nella colonna del C.F.
    PASTUSHYNA TETYANA    18   e un nome nella colonna del C.F.

**Cinque degli otto tornano validi togliendo i caratteri non alfanumerici** — i due con
gli spazi, i due con la virgola, quello col punto interrogativo — e **tre no**: la
P.IVA, il nome, e quello con una lettera in piu. Non e un dettaglio di conteggio: dice
che la ripulitura **si puo fare e quanto rende**, cinque righe su otto, e che le altre
tre vanno trattate come **assenti** e non come identita.

**I sette C.F. ripetuti: confermati uno per uno.** Sei sono la **stessa persona su due
clienti** — MOUSTAHSSEN HAJAR fra le due societa del gruppo Velox, AMARI e NEGRETTI fra
due aziende agricole — e **uno** e una **riga doppia dentro lo stesso cliente**, DE VITA
LUIGI in CTF INTEGRATED LOGISTIC.

**E qui la loro conclusione e giusta per il loro schema e sbagliata per il mio.** Loro
scrivono che `codice_fiscale` unique **globale rifiuterebbe l'import**, e che l'unicita
va su `(cliente, codice_fiscale)`. Vero **da loro**, dove una persona su due
organigrammi e **due schede** per costruzione. **Qui no**: la `0001` ha `persona` e
`rapporto_lavoro` **separate**, e una persona con due datori e **una riga di `persona` e
due di `rapporto_lavoro`** — che e precisamente cio per cui quella tabella esiste. I sei
casi non sono un ostacolo al mio vincolo: **sono la prova che il modello e giusto**, e
con `(cliente, codice_fiscale)` MOUSTAHSSEN HAJAR diventerebbe **due persone**.

Quindi **il vincolo non cambia; cambia l'import**, e in tre punti che adesso hanno un
numero: ripulire il C.F. prima di scriverlo (5 su 8 rientrano); **fondere** i sei
cross-cliente in una persona con due rapporti invece di rifiutarli; e la terza, che e la
mia e non la loro.

**Il rischio che il mio modello ha e il loro no, misurato: due righe.** Un ripiego su
cognome+nome, nel mio modello, **fonderebbe fra clienti diversi** — e ci sono **due**
persone senza C.F. valido che compaiono con lo stesso cognome e nome presso **due
clienti**: `MORANDINI ACHILLE` e `TECCHIO STEFANO`. Da loro il problema non esiste
perche il cliente e gia nella chiave. **Da me, un ripiego sul nome senza il cliente
fonderebbe due persone che potrebbero non essere la stessa** — e non c'e modo di sapere
se lo siano. Piu i due `PRADELLA TAZIO` **dentro lo stesso cliente**, che sono il caso
opposto e vale per entrambi i modelli.

Il loro commento lo dice meglio di come lo direi io, e vale per la mia terza regola:
**«meglio un doppione che si vede, di due persone fuse per sbaglio, che non si vede
piu».**

**La migrazione dati non puo cominciare dalle 808 righe, e il prerequisito non era
scritto da nessuna parte.** Misurato l'11 settembre sul foglio «Visite» di
`ExportExcel (4).xlsx`, che e su questo disco insieme all'altro file che serve.

    righe persona                    3.501   su 480 societa
    ESECUZIONI                         808   esatte, il numero del programma confermato
    persone che ne hanno almeno una     787
    accertamenti che compaiono            9   su dieci a vocabolario

Le dieci periodicita lette dalla sottointestazione — 12/24/12/24/12/24/3/48/60/60 —
**combaciano con le dieci della `0005`**, che le aveva prese dallo stesso posto: e una
rilettura indipendente della stessa fonte, non una conferma esterna, e vale per quello.

**E la colonna «Prossima Scadenza» del foglio e derivata, misurato: 796 su 796 identiche
a esecuzione + periodicita, zero diverse, 12 mancanti.** Quindi la `0005` aveva ragione
a non prenderla da li e a cercare le scadenze **dichiarate** nell'altro file, dove sono
9 su 769 e tutte anticipate. I due numeri — 808 e 769 — **non erano in contraddizione**:
contano due cose diverse su due file diversi, e messi in fila lo si vede.

**Il prerequisito.** `sorveglianza.persona_id` e una chiave esterna su `persona(id)`, e
in questo repo `persona` **e vuota**. Le 808 righe appartengono a **787 persone**:
prima delle 808 vanno le 787, e prima ancora i loro clienti. «La migrazione dati: le 808
righe di sorveglianza» stava scritta in questa tabella **come se fosse il primo passo**,
e non lo e. Non e un errore di stima: e una dipendenza che nessuno aveva nominato perche
il numero piu grande nascondeva quello piu piccolo.

**E la distribuzione dice che costa meno di quanto sembri.** Sulle 3.501 righe mancano
**232 codici fiscali**; sulle **787 che hanno una esecuzione** ne mancano **sette**. Il
problema dell'identita e molto piu piccolo sulla popolazione che conta — la forma
dell'import non cambia, il suo costo si.

**Due cose sono andate a chi le puo misurare.** Ad AppSopralluoghi le regole d'identita
del loro import — hanno scritto 3.420 persone da questi stessi file e chiuso i sette
buchi, quindi il conto delle righe non agganciate ce l'hanno — e i **sette codici
fiscali che compaiono su piu di una riga** (3.269 con C.F., 3.262 distinti), che decidono
se `persona.codice_fiscale unique` regga l'import o lo rifiuti. Ad AppFormazione la
domanda aperta della **scheda 10**, che da oggi e operativa: **l'ultima esecuzione o
tutte?** Il foglio ha **una coppia di colonne sola** per accertamento e la chiama
«Ultima Esecuzione»; se il gestionale tenesse la storia, importare 808 righe la
**perderebbe in silenzio** e il conto tornerebbe lo stesso. Loro hanno l'estrazione
completa dal 2018, che e l'unica finestra piu larga dei cinque export dell'attivo.

Il vincolo `sorveglianza_una_per_data` ammette la storia ed e stato scritto per reggere
entrambe le risposte. **Nessuna delle due e un difetto; sapere quale delle due e la
differenza fra un import che sa cosa lascia fuori e uno che crede di aver preso tutto.**

**L'art. 16 e letto, e la prima risposta e un'assenza: non nomina mai la formazione.**
(`a1827fd` nella libreria.)

Avevo posto la domanda in due modi — se «gli obblighi» del delegato includano quelli
formativi, **oppure** se la formazione sia un requisito **presupposto** alla delega — e
il testo ha una **terza** risposta che non era fra le due: **ne l'uno ne l'altro**.
L'art. 16 di formazione **non parla**, ne come obbligo che ne discende ne come requisito
che la precede; cio che il delegato deve gia possedere e «professionalita ed esperienza»
(lett. b), che il decreto non definisce e **che non e il corso**. Quindi l'obbligo del
delegato, se c'e, **non nasce li**: nasce dall'art. 37 c. 7, e solo attraverso la
**qualifica** che gli si riconosce. «Datore o dirigente?» non era una sfumatura della
domanda: **era tutta la domanda**.

E l'art. 37 c. 7 **nomina tre soggetti** — datore, dirigenti, preposti — e il delegato
non e fra loro. **Non per esclusione: per silenzio.**

**La risposta, col suo limite messo per primo: il testo non dice mai «il delegato e un
datore di lavoro».** Espressamente, **la norma non decide**. Ma **quattro articoli
convergono da una parte sola**: l'art. 2 c. 1 lett. b) definisce datore anche chi ha la
responsabilita dell'organizzazione **«in quanto esercita i poteri decisionali e di
spesa»**; l'art. 16 lett. c) e d) attribuisce al delegato **«tutti i poteri di
organizzazione, gestione e controllo»** e **«l'autonomia di spesa»** — esattamente i due
attributi di quella definizione; l'art. 2 c. 1 lett. d) dice che il dirigente invece
**«attua le direttive del datore di lavoro»**, e un delegato non ha direttive da attuare
perche la delega **trasferisce** le funzioni invece di eseguirle; e l'art. 299 fa gravare
le posizioni di garanzia **«su colui il quale, pur sprovvisto di regolare investitura,
eserciti in concreto i poteri giuridici»** — **la qualifica segue i poteri, non il nome
dell'atto**.

Quindi la `053` di AppSopralluoghi **regge**, e ha una citazione dove aveva una nota —
ma la citazione dice **«converge»**, non «lo prevede». E la distinzione e quella che
questo repo impone dappertutto.

**E le due cose che il testo lascia aperte valgono piu della risposta, perche nessuno le
aveva nominate.**

**1. La delega puo essere PARZIALE, e la riga che la modella assume il caso totale senza
dirlo.** L'art. 16 parla sempre di «funzioni delegate» e di poteri «richiesti dalla
**specifica natura** delle funzioni delegate»: la delega puo coprire **una parte**. Un
delegato che riceve una fetta **non diventa datore per tutto il resto**, e il decreto non
dice a che punto la fetta sia abbastanza grande. La loro `053` ha **una figura sola** che
assume il caso totale — **e non e sbagliata, e non dichiarata**, che e una diagnosi piu
sottile di quella che cercavo.

**2. Due orologi sullo stesso soggetto.** L'art. 16 lett. b) chiede professionalita ed
esperienza **al momento della delega**; l'art. 37 c. 7 fa scattare **un termine** — e per
il datore l'ASR 2025 lo fissa al **19/05/2027**. Il decreto ne fa scattare **uno solo**.
Un delegato formato **dopo** soddisfa il c. 7 mentre la validita della delega resta una
questione a parte, **che non e piu formazione, e diritto**.

**Cosa cambia per la `0006`: l'esclusione resta, e adesso ha una ragione migliore.** Non
piu «non sappiamo se datore o dirigente» — su quello la convergenza sta da una parte
sola — ma **«non sappiamo quanta parte delle funzioni»**, e una riga
`datore_lavoro_art16 -> DATORE_LAVORO` **asserirebbe "tutte"**. E lo stesso difetto della
`053`, con la differenza che qui non e stato scritto. La domanda vera non e quella che
avevo messo nella lista di Francesco, ed e **una che nessuna delle tre corsie si era
posta**.

**E una divergenza tipografica tenuta invece che appianata**: in art. 16 c. 1 la lett. d)
finisce con un **punto** nel testo coordinato e con un **punto e virgola** su tussl. E il
residuo dell'aggiunta della lett. e) nel dicembre 2025 — prima la d) chiudeva l'elenco, e
l'edizione coordinata ha inserito la nuova **senza ritoccare la punteggiatura della
precedente**. Non cambia il senso; non annotata, **la prossima volta fa dubitare della
fonte sbagliata**.

**Zero viste orfane, e lo zero discrimina — che e la sola cosa che lo rende un
risultato.** (`f124b8e`.)

    letterali nominati in viste, script e app   128
    risolti su un vocabolario controllato        62
    coerenti                                     62
    ORFANI                                        0
    non risolvibili, esclusi dal conto           66

**Il controllo negativo e costruito e non trovato.** Il difetto vero e esistito **pochi
minuti** e non e mai stato committato, quindi hanno **ricostruito quell'istante** — le
62 migrazioni piu la vista com'era prima della rinomina — e l'hanno dato allo stesso
strumento con gli stessi parametri, **un solo oggetto diverso**. Lo trova, e lo trova
anche su una ricostruzione **senza dati finti**: stessi 128, stessi 62, stessi 0. Un
analizzatore che risponde sempre «tutto a posto» e indistinguibile da uno rotto.

**E i vocabolari li raccoglie dai domini, non da un elenco scritto a mano**: enum,
`check`, chiavi esterne, e **i domini che le viste producono, seguiti transitivamente**.
Quest'ultimo era il caso da cui e nato tutto — il vocabolario di `formazione_dovuta
.stato` non e fatto dai letterali del suo `case`, e quello **piu tutto cio che arriva
dall'`else`**, che e un `coalesce` fra altre quattro cose. **Tredici valori che nessuno
ha scritto nello stesso posto.**

**I due errori che lo strumento ha fatto prima di funzionare valgono quanto il
risultato**, e sono due volte la stessa forma — *un conteggio si crede finche non si
guarda cosa conta*:

- la prima versione trovava **27 orfani**, quasi tutti falsi: risolveva le colonne per
  **nome nudo**, quindi `requisiti_persona.ruolo` finiva sul vocabolario di
  `operatori.ruolo`, che e un enum di permessi con tre valori;
- la seconda ne trovava **1**, anche quello falso: uno script cerca `ruolo = 'rspp'` e
  in quella tabella oggi **non c'e nessuna riga con quel valore** — le ha cancellate lo
  script stesso, **e il suo mestiere**. Lo strumento leggeva il vocabolario **osservato**
  e concludeva che il valore non esiste.

Da cui la frase che tengo, e che e la stessa distinzione che questo repo applica alle
norme: **un vocabolario osservato e un campione, e un campione non puo smentire
un'appartenenza.** Uno **dichiarato** — chiave esterna, `enum`, `check` — e la verita.
Cio che si legge vale, cio che si osserva aspetta.

**E lo strumento sbaglia tacendo, non gridando**, perche i vocabolari sono **per
eccesso**: seguendo `else` e `coalesce` ci finiscono dentro valori che non
appartengono, e un vocabolario troppo grande **fa passare per vivo un valore morto**.
Direzione giusta per non inventare difetti, **sbagliata per fidarsi di uno zero** — ed e
esattamente il motivo per cui il controllo negativo non e un ornamento.

**E la riga che mi riguarda: una chiave esterna non e solo una protezione, e anche un
vocabolario dichiarato.** E la ragione per cui il loro strumento risolve certe colonne e
non altre — e il motivo per cui la `0007`, che risolve con una **join** e non con un
`case`, e protetta **due volte: a scrivere e a verificare**. Non e piu solo fortuna: e
una proprieta che si puo usare. Al carico della `0007` il controllo sul contenuto ha gia
il suo candidato piu economico — **`scripts/domini_orfani.py` girato sul mio schema**,
che legge `pg_views` e `pg_constraint` e **non sa niente di AppFormazione**. Esce con 1
se trova un orfano, quindi sta accanto al carico invece che dopo.

**E un limite che diventa una richiesta.** I 66 esclusi non sono contati come sani, e 36
di quelli sono colonne di tabelle **vuote su una ricostruzione**, i cui valori esistono
**solo in produzione**. Quindi quel controllo, per valere davvero, **va girato sul
database applicato** — in sola lettura, `set transaction read only`. E qui torna il
blocco che il programma porta da giorni: **la corsia AppFormazione non ha l'accesso in
lettura al proprio progetto Supabase.** Finora era una richiesta generica; adesso ha un
uso preciso e una durata di un minuto.

**Sull'art. 16 una corsia ha gia deciso e l'altra no, e l'ho scoperto perche loro
hanno corretto se stessi.** (`2b51eef`.)

AppSopralluoghi aveva scritto che `datore_lavoro_art16` «dalla loro parte esiste come
`datore_lavoro`». **E falso, e l'hanno corretto loro**: e una **figura a se**, aggiunta
dalla loro `053` come tredicesima — «Datore di lavoro delegato (ex art. 16)» — con i
propri `estremi_procura` e la propria evidenza, visura camerale piu atto notarile.

**E il verso dell'errore era quello cattivo.** Chi avesse scritto l'import leggendo
quella riga **avrebbe tradotto il delegato nel datore**, che e precisamente la
confusione contro cui la riga stessa metteva in guardia. Parole loro: «avevo scritto che
un nome che combacia a meta e piu pericoloso di uno che non c'e, e poi ho fatto
combaciare a meta due nomi che nel nostro schema sono separati da tre anni. **La mappa
era piu affidabile della mia memoria.**» E il secondo argomento per leggere
`ruolo_sicurezza_alias` invece di riscriverla, ed e piu concreto del primo.

**E il fatto che ne esce cambia lo stato della domanda, non la sua risposta.** Sull'art.
16 — se al delegato spettino gli obblighi del **datore** o quelli del **dirigente** — le
due corsie **non sono nello stesso stato**:

    da qui                 APERTA, e aspetta una lettura della norma
    da AppSopralluoghi     DECISA dalla `053` e IN PRODUZIONE: `datore_lavoro_art16`
                           richiede `DATORE_LAVORO`, con la nota «il delegato assume gli
                           obblighi del datore, formazione inclusa»
    da AppFormazione       il ruolo non esiste, quindi non puo dissentire

Nella `0006` avevo scritto che «il campo ha quella riga e potrebbe bastare». Era vero e
**sottostimato**: non e una fonte silenziosa che afferma qualcosa, e **una decisione
presa con una motivazione scritta e applicata su dati veri**. Il che non la rende una
citazione — resta un'affermazione, e oggi ho imparato due volte che un'affermazione in
uno schema non e una misura — ma cambia **chi fa cosa se la lettura va nell'altro
verso**: sarebbe **una loro riga da rivedere**, non una mia da allineare. Lo dicono loro
per primi, ed e il modo giusto di segnalare una divergenza che non si e ancora
manifestata.

**E la norma che la chiuderebbe non e nella libreria.** `reference/dlgs-81-2008-articoli
-citati.md` porta l'art. 37 ai commi 7-ter, 10, 11 e 14-bis, l'allegato XXI e il D.L.
159/2025 — **l'art. 16 non c'e, e nemmeno l'art. 37 c. 7**, che e quello che fissa
l'obbligo del datore e del dirigente. E esattamente la situazione del DPR 177/2011 due
ore fa: **si cita una norma che nessuno ha aperto**, e la strada e quella che ha appena
funzionato.

**E una cosa che questo repo aveva gia scritto senza saperlo.** Il commento di
`ruolo_sicurezza_alias.ruolo` dice che `null` **non significa «non ancora tradotto» ma
«conosciuto e non traducibile da solo»** — cioe la distinzione fra «non lo so» e «non
c'e», scritta nella `0002` **mesi prima** che la trovassimo sull'ATECO, sui ruoli e sugli
alias. La lezione dei tre giorni non e nuova: e nuova la sua applicazione sistematica.

**Il progetto dell'import delle nomine e scritto, e la traduzione che chiedeva esiste
gia dalla `0002`.** (`7820c90`.)

**Gli esiti sono tre e non due**, ed e la stessa forma dell'ATECO e degli alias — **terza
tabella in tre giorni**: `risolta`; **`riconosciuta, non mappabile`** — la parola di
ruolo c'e, la combinazione non ha una regola, quindi **nessuna nomina** e una riga che
lo dice; `non riconosciuta`, e li tacere e giusto. «Risolta / non risolta» sarebbe stato
il `null` a due significati da capo: «non ho una regola» e «qui non c'e nessun ruolo»
sono fatti diversi, e **solo il primo e un lavoro per qualcuno**.

**E il rifiuto della scorciatoia e la parte migliore.** Era disponibile: creare la nomina
su `rspp` con `da_confermare` alzato, «poi qualcuno guarda». Non l'hanno presa perche
**`da_confermare` e uno stato e gli stati si azzerano** — appena qualcuno conferma, quella
nomina diventa indistinguibile da una letta dalla colonna **e il ruolo resta quello
indovinato dall'import**. Parole loro: *si sarebbe scritto un dato falso con un post-it
sopra, e il post-it si stacca.*

**Da cui la distinzione che a me era sfuggita: `da_confermare` e un COMPITO, non una
provenienza.** Dice «qualcuno guardi questa riga» e si azzera quando qualcuno la guarda,
**portandosi via l'unica traccia che quel ruolo era stato interpretato**. E la differenza
fra «questa cella e da rivedere» e «questa cella diceva `37054`». Oggi `nomina` non ha
provenienza, e **160 righe su 301 verrebbero dal testo libero**: meta del totale
indistinguibile dall'altra meta il giorno dopo l'import. La loro proposta —
`nomina.origine` e `nomina.origine_testo`, stessa forma di `cliente.ateco_origine` — ha
un guadagno che non si vede finche non serve: **il giorno in cui il dizionario cambia idea
su una forma, le righe da rivedere si trovano con una query invece che riaprendo un
Excel.**

**La meta onesta: cosa il progetto NON copre, e non potrebbe.** Una forma nuova con una
parola nota — `RSPP/amministratore delegato` — **cade nel secondo esito ed e coperta**.
Un ruolo scritto **senza nessuna parola nota** — `resp. serv. prev. e prot.`, `capo
squadra emergenze` — **non e rilevabile**: per il parser e una mansione come «operaio»,
e non produce niente **ne rumore**. Nessuna regola potrebbe coprirla, e dirlo e parte
della decisione. Il contrappeso sta **a monte del parser** e costa poco: stampare le
stringhe di mansione **distinte comparse dall'ultima volta**. Misurato: 2.890 mansioni
non vuote, **603 distinte**, di cui **23** contengono una parola di ruolo. Un export
successivo ne aggiunge qualche decina, e **un occhio umano su venti stringhe nuove prende
cio che nessun `if` avrebbe preso**.

**E il dettaglio che vale 81 righe, con la risposta che sta gia in questo repo.** La
`0007` risolve a `datore_lavoro_rspp`; il codice figura del campo e `dl_rspp`. Sono
**esattamente le 81 righe** che quella migrazione esiste per non sbagliare, e chiedevano
«una traduzione al confine, scritta una volta sola e in un posto solo».

**C'e gia, ed e `ruolo_sicurezza_alias` della `0002`** — riga
`('sopralluoghi', 'dl_rspp', 'datore_lavoro_rspp')`. Quella tabella e nata **per questo
difetto e lo cita**: «se la mappa e in un `switch`, qualcuno ci mette il caso mancante a
mano — ed e cosi che `dl_rspp` e diventato `rspp` su 26 righe». Due precisazioni che
servono a usarla: la mappa e scritta nel verso `codice esterno -> nostro`, e per le
nomine serve **il verso opposto**; si puo leggere all'indietro **perche e iniettiva**,
verificato — dodici codici, dodici destinazioni distinte — **tranne una**,
`operatore_attrezzatura -> null`, che all'indietro non ha entrata. Irrilevante per le
mansioni (fra le 29 forme non c'e nessuna attrezzatura) e da sapere prima che qualcuno
ci provi.

**E hanno ragione su `datore_lavoro_art16`, che resta aperto.** Un nome che combacia a
meta e piu pericoloso di uno che non c'e: finche la domanda di diritto non ha risposta
l'import **non deve tradurlo**, e la `0002` tiene le due righe separate proprio per
questo — `datore_lavoro` e `datore_lavoro_art16` mappano ciascuna su se stessa.

**Il guardrail rifiuta una grandezza mai vista, e il carico ha trovato una vista che
aveva smesso di spiegare.** (`1b1ce9f`.)

La prova che avevo chiesto — un `G5` finto, per vedere se il guardrail **dichiara la
regola** invece di allungare l'elenco — e passata nei due versi: rifiutata dal vincolo,
e **`misura_non_confrontabile`** quando si allarga il dominio e la si scrive lo stesso,
che e cio che accadrebbe a una scoperta vera. Ma la riga che convince e un'altra, e non
l'aveva chiesta nessuno: **nella stessa simulazione l'attesa INIZIALE dello stesso
obbligo continua a essere giudicata `sufficienti`**. Il guardrail e per **attesa** e non
per riga — cioe l'insegnamento di `coordinatore_sicurezza` **visto funzionare** invece
che rispettato in fase di scrittura. Un disegno si prova cosi, non con il caso per cui
e stato fatto.

E sono **popolate per regola e non per elenco** — «il metodo dell'obbligo e monte ore?
la fonte e la parte III punto 5 o 6? il numero non c'e? per esclusione, durata del
corso» — **senza nominare nessun codice**. Un obbligo nuovo con una fonte di quella
famiglia **si marca da solo**, che era esattamente il difetto da chiudere.

**Il difetto che il carico ha trovato e che la lettura non vedeva, e vale oltre il
caso.** Una vista a valle — `rls_ore_aggiornamento` — **aveva smesso di spiegare una
riga**: il suo `case` nominava `rinvio_al_ccnl`, un valore che non esiste piu. La vista
**girava senza errori**, tornava **lo stesso numero di righe**, e il motivo era **vuoto**.

    Un `count(*)` non se ne accorge.

Rinominare un valore rompe in silenzio ogni `case` che lo nomina, e **il posto dove si
vede non e il carico ma il contenuto**. La riparazione e quella giusta: il motivo lo
**prende dalla colonna** invece di riscriverlo, cosi la prossima causa nuova ci arriva
da sola — di nuovo la regola al posto dell'elenco, un livello piu in la.

**E mi riguarda subito.** I sette conteggi della `0006` e gli otto della `0007` sono
**conteggi**: proverebbero che le righe ci sono, non che dicano ancora qualcosa. Su
questo sono fortunato e non bravo — nella `0007` la risoluzione e una **join** fra
`ruolo_testo_parola` e `ruolo_da_parola`, non un `case`, quindi un valore rinominato
**rompe la chiave esterna** invece di svuotare una stringa. E la stessa forma della
`0041` che lascio `ore_iniziali` a null: **una struttura giusta protegge da un errore
che non e ancora stato nominato**, e questa volta la struttura giusta l'ho scelta per
un'altra ragione. Al carico della `0007` va aggiunto **un controllo sul contenuto** e
non solo sui numeri.

**E la frase sul CCNL non e persa: e passata da etichetta a spiegazione**, che e
l'unico posto a cui apparteneva. Un raccoglitore battezzato col nome del suo inquilino
si ripara cosi — non cancellando il nome, ma spostandolo dove descriveva davvero
qualcosa.

**Sulla scheda 12, un dato che restringe la domanda di Francesco invece di aggiungerne
una.** I tre titoli da preposto hanno periodi di erogazione **che si sovrappongono**, e
uno dei tre va dal marzo 2011 al maggio 2026 **ininterrotto**. Chi risponde non deve
ricostruire niente: deve dire **se in aula si insegnavano cose diverse**. E una domanda
da due minuti per la persona giusta, e non lo e nessuna delle tre corsie.

**L'azione di livello cliente e chiusa, e il vincolo che avevo dettato e rispettato per
costruzione invece che per disciplina.** (`81f6903`, migrazione `066`.)

Avevo scritto: **non deve diventare la campagna di riempimento**. La soluzione non e una
query prudente, e una scelta di origine — **la riga non nasce dal campo vuoto, nasce da
un calcolo che si e fermato**:

    clienti senza ATECO                                357
    clienti con la riga OGGI                             0   (`nomina` e a zero righe)
    clienti con la riga al primo import delle nomine      4

I quattro hanno gia un nome dalla misura del giorno prima. **Un cliente senza ATECO e
senza nessuno nominato in quei ruoli non produce niente**, e va bene cosi: per lui quel
buco non sta bloccando nulla. La differenza fra «ecco i 357, comincia» e «questo cliente
ha un buco e serve a questo» ha smesso di dipendere dal buon senso di chi scrive la
query.

**E sparisce da sola perche non c'e proprio una spunta da fare.** La riga e attesa solo
finche un requisito porta la marcatura; quando la cella arriva la marcatura sparisce e
la cancellazione degli orfani — **che esisteva gia** — la rimuove. Il rischio che avevo
nominato, «358 azioni chiuse a mano che si riaprono al prossimo import», **non puo
verificarsi**, perche non esiste una chiusura a mano da rifare. E la ragione tecnica e
migliore della scelta: hanno messo la chiave nella **stessa colonna** delle altre azioni
non per risparmiare una colonna ma **perche quella colonna e gia riconciliata** — una
nuova avrebbe richiesto di riscrivere la riconciliazione, e la chiusura automatica era
il requisito, non il contorno.

**Il prefisso della chiave, che e la lezione dei due giorni applicata a un caso nuovo.**
Le due forme sono `persona_id:corso_codice` e `cliente-ateco:<cliente_id>`, e davanti ai
due punti c'e un uuid di **persona** nella prima e un id di **cliente** nella seconda.
Cercare il secondo fra le persone **non da errore**: non trova niente, e la riga
comparirebbe **senza discente e senza corso**. Un danno silenzioso invece che rumoroso —
la forma esatta del difetto inseguito per due giorni. Il prefisso rende il caso
riconoscibile **prima** di sbagliare, che e l'unico momento utile.

**E una decisione che nessuno aveva chiesto: non e «SUBITO».** Una riga di formazione
senza data viene mostrata come subito e messa **davanti a ogni scadenza datata**, perche
per costruzione e un corso dovuto e mai erogato. Questa non ha data per la ragione
**opposta** — non e un lavoro in ritardo, e un dato che manca, e nessun termine di legge
dice entro quando compilarlo. Metterla in cima la farebbe passare davanti a formazione
davvero dovuta. E **nessuna data inventata**, ne oggi ne oggi+30: sarebbe un dato dedotto
indistinguibile da uno vero, cioe il difetto da cui e nata tutta questa famiglia.

**Un limite dichiarato invece che implicito**: il banco di prova gira **offline sul
codice puro**, quindi verifica che la **ragione** compaia e sparisca quando deve, e non
che il backfill materializzi e rimuova la riga. Quello si vedra al primo cliente con una
nomina vera, e **oggi non ce n'e nessuno**. Detto invece di lasciato intendere, che e la
differenza fra un limite e una lacuna.

**E adesso il collo di bottiglia sono io.** L'import delle nomine aspetta che la `0007`
sia **caricata**, e le altre due corsie hanno tutte e due un passo che a valle dipende da
questo repo. Va scritto perche e la prima volta oggi che succede, e perche la regola
della sezione dice che una corsia ferma e diversa da una lenta: **non sono ferme, sono in
attesa di me.**

**Le grandezze sono quattro, il tetto e 11 su 34, e A13 va corretta: la grandezza e un
attributo dell'ATTESA e non dell'obbligo.** Misura dell'11 settembre (`b2b4e0c`).

    G1  durata complessiva del corso      confrontabile con un attestato, ed e l'unica
    G2  durata della sola parte pratica   un pezzo del corso
    G3  durata del solo modulo teorico    l'altro pezzo
    G4  monte ore nel quinquennio         una somma su cinque anni e su piu attestati
    G0  nessuna attesa

G4 l'avevo indicata io; **G3 e la quarta e non l'aveva vista nessuno**: viene dalle otto
attrezzature dove `ore_iniziali` e null e il solo numero disponibile sta in
`ore_teoriche` — un'attesa che misura **la meta opposta** di G2.

**E il risultato strutturale, che corregge l'assunzione che avevo appena scritto**: le
due attese di un obbligo — iniziale e aggiornamento — **vanno classificate
separatamente**, e cinque obblighi stanno in classi diverse sui due lati.
`coordinatore_sicurezza` ha l'iniziale in ore **totali** e l'aggiornamento in monte ore
**quinquennale**: G1 di qua e G4 di la, **dentro la stessa riga**. Quindi A13 non e un
attributo dell'obbligo: e un attributo dell'**attesa**, e ce ne sono due per obbligo.

    aggiornamento   11 G1   12 G2    2 G4    9 G0
    iniziale        16 G1    8 G3   10 G0

**E mi corregge la `0008` prima che la scrivessi.** Avevo previsto **una** colonna di
marcatura sui sedici codici col `4` di parte pratica. Ma `corso` ha **due** attese per
riga — `ore` e `ore_aggiornamento` — e su `ATTR_CARRELLO` sono grandezze diverse: `12`
e un totale, `4` e la sola parte pratica. **Una colonna sola avrebbe marcato la riga e
descritto male meta dei suoi numeri**, che e la forma esatta del difetto che la colonna
doveva chiudere.

**Il numero che la scheda 12 aspettava, ed e piu duro di come lo immaginavo.** Dei 34
obblighi, **11 hanno un'attesa di aggiornamento confrontabile**, 2 sono nel perimetro, e
**uno dei due c'e entrato solo perche il giunto della `0057` risolve il suo
discriminante**. Il confronto delle ore, in questo modello, e uno strumento per **un
terzo dei casi**: il tetto e **11, non 34**. La scheda 12 chiedeva gia, prima di
saperlo, che si scrivesse **quali casi la decisione non risolve** — «una regola che
copre un terzo dei casi e non dichiara gli altri due e il modo in cui si crede di aver
chiuso un difetto». Quel «un terzo» era una figura retorica e adesso e una misura.

**Due difetti latenti, nessuno attivo, trovati simulando l'errore futuro:**

- **il guardrail della `0060` non prende G4**: un RSPP con una giornata da 8 ore contro
  un'attesa di 40 nel quinquennio esce `insufficienti`. La diagnosi e la parte che vale
  — **il flag marca le eccezioni note invece di dichiarare la regola**, quindi ogni
  grandezza nuova gli sfugge **per costruzione**. Un elenco di eccezioni e sempre
  vecchio di una scoperta;
- **`rinvio_al_ccnl` e un raccoglitore battezzato col nome del suo unico inquilino**: un
  transpallet con attesa nulla perche la fonte non c'e ne esce con quell'etichetta. Non
  e un giudizio falso, **e una spiegazione falsa** — e in un sistema il cui valore e
  spiegarsi, e la stessa famiglia di difetto. La colonna che distingue le tre cause
  esiste **dalla loro `0041`** e il ramo non la legge.

**E una cosa che funziona, ed e il rovescio esatto di R5.** Gli otto iniziali G3 non
producono nessun giudizio falso, e non per fortuna: la `0041` ha messo le ore di teoria
in `ore_teoriche` **lasciando `ore_iniziali` a null** invece di riempirla col numero che
aveva sottomano. **Una buona decisione di modello protegge da un errore che non era
ancora stato nominato** — A13 non esisteva, ma chi scriveva sapeva che quel numero non
era il totale e non l'ha messo dove si mettono i totali. R5 dice che un record vero
invecchia; questa dice che una **struttura** giusta no.

**E il DPR in `reference/fonti/` e al suo posto, contro il mio sospetto.** Avevano
segnalato che il PDF pesa 6,2 MB e che quel push conviene guardarlo prima. Guardato:
`reference/fonti/` **contiene gia una dozzina di PDF** — gli ASR, i DM, gli accordi
2011 e 2012, le tavole di raccordo — quindi il DPR non introduce una pratica nuova, la
segue. La segnalazione era giusta e la conclusione e che non c'e niente da decidere: la
libreria e **fatta per contenere le fonti**, ed e la ragione per cui i suoi 26 MB stanno
nel repo e non in una chat.

**La famiglia dei tre difetti e chiusa, e la riparazione ha messo il terzo stato dove
non me l'aspettavo: nel confronto, non in un valore.** AppSopralluoghi ha chiuso la
riparazione dell'ATECO l'11 settembre (`3c8b84e`, migrazione `065`).

Avevo chiesto «tre stati separati». La soluzione e migliore della richiesta: **lo stato
«questa divisione potrebbe essere sbagliata» non e un membro di un enum, e il confronto
fra `codice_ateco` e la cella conservata**. Un enum con un valore `incerto` avrebbe
richiesto che **qualcuno decidesse quali righe marcare**, e quella e esattamente la
decisione che nessuno puo prendere a tavolino; cosi invece si ricalcola dalla cella ogni
volta, e **se domani la cella cambia cambia la risposta**. Un giudizio conservato invecchia,
un confronto no.

**E ne discende una terza parola che non avevo previsto.** Le 262 righe anteriori alla
`065` la cella non ce l'hanno, quindi il loro stato e `noto` con riscontro
**`NON_VERIFICABILE`**: niente le smentisce e niente le conferma. Scrivere «confermato»
su righe che non si possono verificare sarebbe **la stessa bugia del commento della
`055`** — una descrizione che afferma piu di quanto il sistema sappia.

**Cosa fa il motore, e perche il silenzio resta giusto in un caso su tre.**

    non_dovuto        213 clienti   si salta, IN SILENZIO — un requisito qui sarebbe un
                                    falso «mancante» su un obbligo che non esiste
    non_calcolabile   358 clienti   una riga `da_verificare` che porta la ragione E cosa
                                    la risolve: «si risolve compilando l'ATECO del
                                    cliente, non registrando un attestato»
    dovuto             48 clienti   come sempre, con le sue ore

Il pezzo che vale e l'ultimo rigo del secondo: non e `critico` — dire «mai svolto»
affermerebbe che il corso serve, e non lo sappiamo — e non e l'assenza della riga, che
direbbe che non serve, e **non lo sappiamo nemmeno**. Fra «manca» e «non serve» c'era
un terzo posto e non aveva un nome.

**E il numero che dice a cosa e servita la riparazione e uno solo: 214 -> 213.** Prima i
«non dovuti» erano 214 perche **SHAMS ci stava dentro**, con il suo `37` preso da un CAP.
Adesso e passato dal silenzio alla riga che dice di non sapere. Una riga su 619, ed e il
caso per cui esiste tutto il resto.

**Un giudizio che hanno preso e che condivido**: se la cella e ambigua ma **tutte** le
divisioni plausibili danno lo stesso esito, la risposta **e determinata** e dire «non lo
so» sarebbe un falso allarme. Vale per BP CHIMICA (due codici, stessa divisione) e per
MIGLIORINI **sul modulo** (ne 46 ne 33 sono settore speciale). **Non** vale per SHAMS,
dove `37` non da modulo e `41` ne da 16. E di MIGLIORINI **resta aperto il livello** — 46
basso, 33 alto — e quella incertezza il motore non la chiude: la mostra, e la risolve
qualcuno con una visura. Un motore che sa dire quali domande non sono sue e meglio di uno
che le risolve male.

**Misurato sul codice vero e non su una reimplementazione**: `ateco.ts` compilato con
esbuild ed esercitato sulle celle **verbatim** dell'export. E l'ultimo dei nove controlli
e **la regola stessa** — «non lo so» e «non dovuto» devono restare esiti **diversi**, e se
un giorno qualcuno li riunisce quel test fallisce. E un guardrail sull'invariante e non
sul comportamento, che e la forma piu duratura.

**Non riempie niente e non c'e backfill possibile**: la cella non era conservata da
nessuna parte, quindi le 262 righe esistenti restano senza e si popolano da sole al
prossimo import. **E la misura di cosa costa non aver conservato il testo la prima
volta**, e vale la pena tenerla come cifra e non come morale.

**La famiglia, e la regola che ne esce e una sola per tutti e tre:**

    ATECO   `codice_ateco` / la cella dell'export     «questa divisione potrebbe essere sbagliata»
    ruoli   la colonna di ruolo / la mansione         «RSPP- NO TITOLARE», il refuso `TITOLRE`
    alias   `testo_gestionale` / il titolo verbatim   «il gestionale scrive due spazi», e un a capo

**Quando si deriva un dato da un testo altrui, il testo altrui e parte del dato**: il
derivato da solo non sa dire se sia affidabile, e **chi arriva dopo non ha modo di
chiederglielo**. Tre difetti trovati in due giorni su tre tabelle diverse, e nessuno dei
tre era visibile guardando l'archivio.

**Il DPR 177/2011 e stato letto, e non distingue le figure: la questione e chiusa e
non arriva a Francesco.** Letto l'11 settembre 2026 (`4548621` nella libreria,
`8ba2edd` in AppFormazione), e la risposta non e un silenzio ma un testo:

- **art. 2 c. 1 lett. d) e f)** — formazione e addestramento sono «di tutto il
  personale, **ivi compreso il datore di lavoro**»: una platea sola, nominata per
  **estensione** e non per figure;
- **art. 2 c. 1 lett. c)** — il preposto **e nominato**, una volta sola, e per
  l'**esperienza triennale**: non per le ore di corso.

**Il decreto sa distinguere il preposto quando gli serve, e quando parla di formazione
non lo distingue.** E un argomento **dal testo** e non dal silenzio — non «non ne
parla», ma «ne parla altrove e qui no» — ed e la differenza fra una conclusione e una
mancanza di prove.

E il DPR **non fissa nessuna durata**: rimanda contenuti e modalita a un accordo
Stato-Regioni, e quell'accordo per gli ambienti confinati e **l'ASR 2025**, che lo
dichiara in proprio nella Parte VII. La catena e chiusa ai due estremi: il DPR rimanda
all'accordo, l'accordo conosce **una figura**, e nessuno dei due da durate per platea.

**Quindi cade anche la strada 2, ed e la parte che cambia la lista di Francesco.**
Avevo scritto che, se la fonte non avesse distinto, le 12 ore al preposto sarebbero
state una **decisione commerciale da dichiarare**, e che dichiararla impegna Overall
quindi tocca a lui. **Non tocca a nessuno**: una decisione aziendale si scrive dove la
norma **tace**, e qui la norma **parla** — dice una figura sola. Non c'e una lacuna da
colmare, c'e una risposta. Che il gestionale eroghi 4 ore ai lavoratori e 12 alle altre
tre platee **resta vero e resta sensato** — un preposto che entra in uno spazio confinato
ha piu cose da imparare — ma e un fatto sul **catalogo**, e li resta.

**E il problema di catalogo resta intero e resta mio**: un codice che ne nasconde due va
spezzato, e **si giustifica col catalogo senza bisogno di nessuna citazione**. E la
`0008`.

**Art. 3 c. 4, e alza la gravita senza alzare la probabilita.** «Il mancato rispetto
delle previsioni di cui al presente regolamento determina il **venir meno della
qualificazione** necessaria per operare, direttamente o indirettamente, nel settore.»
La sanzione e sull'**impresa** e non sul singolo: una formazione mancante toglie
all'azienda il titolo per lavorarci. Il motore non lo modella e non deve — ma la mia
riga unica `spazi_confinati -> ATTR_AMB_CONFINATI`, che lascia un aggiornamento da
lavoratore chiudere l'obbligo di un preposto, **e peggio di quanto sembrasse quando
l'ho trovata**. Da dire con precisione: **non e piu probabile** — zero aggiornamenti
erogati e `nomina` a zero righe — **e piu grave se accade**, ed e la distinzione che di
solito si perde dicendo «e piu urgente».

**E una figura che la `0002` non ha.** L'art. 3 c. 2 crea il **rappresentante del datore
di lavoro committente**, che vigila sul cantiere per conto di chi appalta; il decreto
gli chiede competenze e attivita svolte, **non una durata**. Non entra in
`ruolo_sicurezza`: e una figura del **committente** e non del datore formato, e prima va
saputo se Overall la segua. Sta scritta nella trascrizione della libreria, che e il
posto dove una domanda aspetta — e va detto che le **15 figure** della `0002` sono la
tassonomia di **cio che formiamo**, non di tutto cio che le norme nominano.

**E un refuso del legislatore, lasciato dov'e.** Il rimando dell'art. 3 alle «lettere c)
ed f)» non torna: la c) non e un'attivita di formazione, e il requisito dei **tre anni
di esperienza**, quindi il periodo chiede letteralmente di aver «svolto» un requisito di
anzianita. Verificato in **entrambe** le fonti, quindi e del testo e non della
trascrizione, e **non e stato corretto**: la lettura sensata — «d) ed f)» — e
un'interpretazione, e va marcata come tale invece che scritta come se fosse la fonte.

**Come e stato verificato, che su una fonte nuova conta quanto il testo.** Due
estrazioni indipendenti — Normattiva articolo per articolo e il PDF del fascicolo GU
260/2011 — e **sul periodo che decide sono identiche parola per parola**: 758 caratteri
contro 754, e le quattro differenze sono «a» accentate che l'estrazione dal PDF non ha
reso. Con un limite dichiarato: **la lettura a video pagina per pagina non e stata
fatta**, perche su quella macchina manca il renderer, e il doppio riscontro
programmatico ne ha preso il posto. Detto perche quella regola esiste per una ragione
pagata — `pdftotext -layout` aveva gia prodotto una matrice sbagliata — e qui non c'e
nessuna tabella, e prosa.

**Le quattro platee non sono entrate, e il passo l'avevo assegnato male io.**
AppFormazione ha rifiutato l'assegnazione con l'argomento giusto: sugli ambienti
confinati **l'ASR 2025 conosce una figura sola** — la parte II punto 7 e la parte VII
nominano «lavoratori, datori di lavoro e lavoratori autonomi» come **un gruppo**,
l'Allegato III ha **una colonna** («LAVORATORE sospetto di inquinamento»), la parte III
punto 5 **una riga**. La distinzione, se esiste, sta nel **DPR 177/2011**, che il loro
`obblighi.spazi_confinati` cita gia e che **nessuno ha letto**: non e in `reference/`.

**L'errore e mio ed e preciso: ho preso una misura di cio che si VENDE e l'ho proposta
come modello di cio che si DEVE.** Che Overall eroghi 12 ore al preposto e un fatto sul
**catalogo**; che la legge gliene chieda 12 e un'affermazione sulla **norma**, e non ce
l'ha nessuno. Scritta nei loro `requisiti` — che portano `fonte`, e quella colonna e una
promessa — direbbe la seconda cosa avendo misurato la prima. Il giorno dell'estensione
il motore direbbe `insufficienti` a un preposto con un corso da 4 ore **conforme al
punto 5**: falso nel verso severo, prodotto codificando un formato commerciale come
requisito di legge.

**E la distinzione che lo spiega e quella della scheda 9, che ho scritto io.** «Il corso
resta come catalogo di **erogazione** agganciato all'obbligo che assolve, **non come
soggetto della regola**.» Un codice in piu nel mio `corso` si giustifica col catalogo —
due corsi diversi esistono davvero — e **quello resta da fare**. Una riga in piu nei
loro `requisiti` si giustifica solo con la norma. Avevo chiesto la seconda cosa
mostrando la prova della prima.

**Cercando la citazione hanno trovato il difetto vero, ed e piu grosso: la parte III usa
DUE formule diverse.**

    punto 1.1  lavoratori           durata minima di 6 ore
    punto 1.2  preposti             biennale, durata minima 6 ore
    punto 2    DL-RSPP              quinquennale, 8 ore
    punto 5    ambienti confinati   durata minima 4 ore DI PARTE PRATICA
    punto 6    attrezzature art. 73 durata minima 4 ore DI PARTE PRATICA

Sulle prime tre il numero e un pavimento sulla **durata del corso**; sulle ultime due e
un pavimento sulla **sola parte pratica**, e il totale la fonte **non lo dice**. Che sia
una distinzione vera e non una sfumatura di trascrizione lo prova l'allegato XXI, che
per i ponteggi scrive l'altra formula: «durata minima di 4 ore **di cui 3** di contenuti
tecnico pratici». **Stesso numero, grandezza diversa.**

**E il mio catalogo ha lo stesso difetto, su sedici codici.** `ore_aggiornamento = 4`
sta su diciotto righe della `0004`, e sono tre cose diverse:

    15 art. 73    ATTR_CARRELLO, ATTR_PLE, i tre ATTR_GRU_*, i tre ATTR_TRATT_*,
                  ATTR_ESCAVATORI, ATTR_CARROPONTE, ATTR_CMM, ATTR_CRF,
                  ATTR_POMPE_CLS, ATTR_AUTORIBALTABILI, ATTR_GENERICO
                                                    -> 4 ore di PARTE PRATICA
     1 punto 5    ATTR_AMB_CONFINATI                -> 4 ore di PARTE PRATICA
     1 all. XXI   PONTEGGI                          -> 4 ore TOTALI, di cui 3 pratiche
     2 altre      ATTR_LAV_ELETTRICI (CEI 11-27), ATTR_LAV_QUOTA (dove i 60 mesi
                  sono gia dichiarati prassi e non norma)

**Sedici di quei diciotto numeri non sono confrontabili con le ore di un attestato**, che
riporta il totale — e `PONTEGGI`, che porta lo stesso `4`, lo e. Oggi nessuno li
confronta e non e un difetto attivo: e **una mina su ogni estensione futura**, ed e la
stessa mina in due cataloghi diversi, perche il numero e stato copiato dalla stessa
fonte **senza la sua grandezza**.

**Da cui l'assunzione che mancava, e viene prima delle altre due: vedi A13.**

**~~Al primo import quei nove titoli non si troverebbero~~ — falso, e mi hanno fermato
prima che lo riparassi nel posto sbagliato.** L'import di AppSopralluoghi
**normalizza tutti e due i lati** del confronto con la stessa funzione — maiuscolo,
spazi collassati, `trim`, dichiarato nel commento del codice — quindi i nove titoli si
trovano, oggi come al primo import, e il `\s+` prende anche il ritorno a capo. **Non
c'e nessun import da riparare.**

L'errore e mio e ha una forma che vale la pena nominare: **ho letto un commento di
schema e ho concluso da quello**, senza guardare il codice che fa il confronto. E il
commento era **a sua volta falso** — la loro `055` dice `testo_gestionale text not null
unique, -- la stringa esatta esportata`, e non lo e. Ho fatto la cosa ragionevole
partendo da una premessa scritta, che e esattamente la forma delle «31 aziende» vista
dall'altro capo: li avevo citato come misura una lettura non marcata, qui ho citato
come descrizione un commento non verificato. **Un commento di schema e un'affermazione,
non una misura**, e si controlla contro il codice che gli sta sotto.

**Ma il difetto non sparisce: si sposta, e diventa piu grande.** Due cose restano
vere e una e nuova:

- **il mio commento e falso quanto il loro.** `corso_alias.testo` si dichiara «come lo
  emette l'origine, verbatim» e **non lo e per 211 righe su 268** — solo 57 sono
  identiche all'origine, 196 differiscono per maiuscole e minuscole, 15 anche per gli
  spazi. Non teniamo il testo: **teniamo la chiave**;
- **da questo lato l'import non esiste ancora**, quindi non c'e nessuna funzione che
  normalizzi due lati. Chi lo scrivera leggera quel commento e concludera cio che ho
  concluso io stamattina. Un commento falso in una tabella senza codice e piu
  pericoloso che in una tabella con il codice accanto, perche non c'e niente che lo
  smentisca;
- **e cio che si e perso non e l'import: e la forma originale**, e non la conserva
  nessuno. Per sapere se il gestionale scrive `Costruzioni  per Datore` con due spazi
  l'unica fonte e **riaprire l'export**. Terza volta con la stessa forma, dopo la cella
  ATECO di SHAMS e le mansioni: **il dato derivato non porta con se l'unica cosa che
  permetterebbe di rivederlo.**

E quei numeri **confermano la `0007` dal basso**, che e il motivo per cui questa nota
sta qui e non fra gli errori. La separazione `testo` / `chiave` non era una previsione
di cosa succede tenendone una sola: **e il referto di cosa e successo**. In
`corso_alias` la colonna era una, ha dovuto fare il lavoro della chiave, e il testo e
andato — compreso **un titolo di corso che contiene un ritorno a capo**, che nessuno
saprebbe piu che esiste.

**Cosa si ripara e dove.** Il commento della `0004` non si tocca — caricata e
misurata — quindi la correzione e un `comment on column` in una migrazione nuova,
insieme alla `0008` dei confinati. E con esso la domanda che il conteggio apre e che
prima non aveva un caso sotto: **se `corso_alias` debba conservare `testo_origine`
accanto alla chiave.** Oggi ha un caso vero — una corsia ha speso un giro senza poter
rispondere a «il gestionale scrive due spazi?» se non riaprendo il file.

**E `spazi_confinati` ha lo stesso difetto dell'antincendio, un piano piu in basso —
nel mio catalogo, non nella `0006`.** La misura di `b0f630c` dice che sotto
`ATTR_AMB_CONFINATI` vivono **due corsi di aggiornamento diversi**: 4 ore ai
lavoratori, **12 a preposto, DL-RSPP e RSPP modulo B**. La riga
`spazi_confinati -> ATTR_AMB_CONFINATI` della `0006` e **una sola** e dice che un
qualunque corso di ambienti confinati chiude l'obbligo — quindi un aggiornamento da 4
ore chiude l'obbligo di un preposto che ne deve 12. E la stessa cosa che ho tenuto
fuori per l'antincendio, e qui e entrata perche il livello non era nel nome del
**codice** ma solo in quello degli **alias**: dal codice non si vedeva.

E cosa **non** e: non e il caso del carrello. Li la seconda durata esiste perche
esiste un corso **combinato** — manca un codice per una cosa diversa. Qui la stessa
cosa dura diversamente secondo **chi la fa**, che e la forma dell'`RLS`. La
distinzione e di AppSopralluoghi e regge l'intera decisione: portare
`ore_aggiornamento` da 4 a 12 sarebbe **sbagliato quanto lasciarlo a 4**, perche
renderebbe giusti tre alias su cinque invece di due.

La riparazione sta in due posti e nessuno dei due e la `0006`: **un codice in piu nel
catalogo** — una `0008` di qua — e, nel modello di AppFormazione, **quattro requisiti
invece di un obbligo con quattro alias**, che e la forma che hanno proposto loro
notando che «platee diverse sono ruoli diversi». **Non morde oggi**: zero aggiornamenti
erogati e `nomina` a zero righe, quindi nessuno e nominato in nessuna delle tre figure
da 12 ore. Decisione di progetto, non riparazione urgente — la stessa qualifica che
aveva il modulo di settore, e per la stessa ragione.

**E il paragrafo non immunizza.** La svista che ha promosso `spazi_confinati` a
obbligo pronto — contare i propri 180 titoli e concludere sul catalogo altrui — e la
**terza volta in due giorni** che quella forma si presenta, dopo i «1.148 eventi di
visita» e le «31 righe a 8 ore». Ed e capitata alla corsia che aveva appena finito di
scriverne il paragrafo, e l'ha lasciata scritta nel proprio documento invece di
correggerla via. Vale la pena tenerla accanto alle altre due: **aver descritto un
difetto non protegge dal commetterlo**, e l'unica difesa che ha funzionato tutte e tre
le volte e stata qualcun altro che contava.

**E una cosa che nessuno dei due ha fatto, e che costava meno di tutto il resto.** La
questione delle 31 righe a 8 ore si chiudeva guardando il **catalogo del gestionale**,
che ha due voci distinte — «Aggiornamento R.L.S. 4 ore» e «8 ore». Quelle due voci
stanno nelle migrazioni `0022` e `0007` di AppFormazione **da giorni**, e sono le
stesse che il giunto della `0057` distingue. Nessuno dei due ha pensato di aprire il
dizionario per rispondere a una domanda che sembrava riguardare le aziende. **Una
domanda sulla realta puo avere la risposta nel vocabolario**, e si guarda prima perche
costa meno.

**La `0007` ha un caso di bordo, trovato prima che la scrivessi.** Due delle 29 forme
— `TITOLARE ASPP e RSPP` e `AMMINISTRATORE/DATORE DI LAVORO/RSPP` — mostrano che il
secondo campo **non e sempre la posizione della persona: a volte e un secondo ruolo**.
Con una colonna «posizione» che ammette solo titolare/socio/non-titolare/esterno/non
dichiarato, quelle stringhe costringono o a perdere l'ASPP o a fare due righe per la
stessa persona. Sono **6 righe su 160**, e si vedono adesso.

La risposta e che **due righe sono la cosa giusta, non il ripiego**: la grana e
`(testo, ruolo asserito)`, e una frase che asserisce due ruoli produce due righe perche
**asserisce davvero due cose**. La `posizione` resta proprieta del **testo** — descrive
la persona, non il singolo ruolo — e vale su tutte le righe che quel testo genera.
`datore di lavoro` compare allora in **due panni**, come ruolo asserito e come cio che
fissa la posizione, e non e una contraddizione: e esattamente il meccanismo che rende
`RSPP/titolare` risolvibile in `datore_lavoro_rspp` invece che in `rspp`.

**La `0007` non e una tabella di alias, e il motivo e nei dati che l'hanno chiesta.**
La tentazione, dopo `8dab00a`, e ovvia: `corso_alias` esiste perche «il titolo stampato
su un attestato di terzi e per natura un alias e non un'identita», e 29 forme scritte a
mano chiedono lo stesso trattamento. **Ma le 22 forme dell'RSPP non sono 22 modi di
scrivere «RSPP».** Sono frasi che asseriscono **due fatti**:

    RSPP/titolare                          RSPP + e il titolare      -> datore_lavoro_rspp
    RSPP ESTERNO                           RSPP + non e dell'azienda -> rspp, e forse fuori
    RSPP- NO TITOLARE                      RSPP + NON e il titolare  -> rspp
    AMMINISTRATORE/DATORE DI LAVORO/RSPP   RSPP + e il datore        -> datore_lavoro_rspp

Il ruolo non e il testo: e la **combinazione**. Una tabella `testo -> ruolo` funziona
sulle 29 di oggi e si rompe sulla trentesima, e soprattutto **seppellisce la ragione**:
chi legge `RSPP/titolare -> datore_lavoro_rspp` non sa se sia una regola o un giudizio
preso a mano su quella stringa. La `0002` descrive gia questo fallimento e lo attribuisce
alla forma sbagliata — «se la mappa e in un `switch`, qualcuno ci mette il caso mancante
a mano, **ed e cosi che `dl_rspp` e diventato `rspp` su 26 righe**». Una tabella di alias
e un `switch` in tabella: stessa opacita, indice migliore.

Quindi la `0007` porta **due colonne di fatto e non una di destinazione**: quale parola
di ruolo compare, e cosa il testo dice della **posizione della persona** — titolare o
socio, non titolare, esterno, non dichiarato. Il ruolo lo decide una regola scritta una
volta, che si legge e si discute; il testo verbatim resta accanto, come per l'ATECO e
come per `corso_alias`. E la forma «non dichiarato» e obbligatoria: 29 forme su 160
righe vuol dire **una riga su cinque scritta in modo nuovo**, e la lettura deve poter
dire di non aver capito invece di ignorare in silenzio.

**Manca un dato per scriverla**, ed e piccolo: di 29 forme ne conosco **22 verbatim**,
quelle dell'RSPP. Le 5 del datore e le 4 del preposto sono contate e non trascritte.
Chieste ad AppSopralluoghi in coda ai tre conteggi — **non le invento**, perche il
refuso `TITOLRE` e la negazione `NO TITOLARE` dicono che in quelle stringhe la forma
**e** il dato.

**«Le 31 sono le aziende oltre i cinquanta» non e una misura, e l'ho propagata io.**
Contestata da AppFormazione l'11 settembre con l'argomento giusto: `clienti.dipendenti`
da loro **non ha nessuno che la riempia in blocco** — la scrive solo `carica_scheda.py`,
un cliente alla volta — quindi quel confronto da li non puo essere stato fatto.

Risalita alla fonte, e hanno ragione. Sta in `durate-come-controllo.md` di
AppSopralluoghi (`eddbb44`), e la tabella li misura **una cosa sola**: le durate degli
attestati, `4h x128` e `8h x31`. La frase che segue — «le 31 righe a 8 ore non sono un
errore del gestionale, **sono le aziende oltre i 50 lavoratori**» — e **l'unica lettura
che dia un senso al dato**, e non e un conteggio: nessuno ha unito quelle 31 righe a
un numero di dipendenti. E la forma dell'assunzione **A7** applicata a me stesso, la
stessa che avevo scritto nella `0004` per `ATTR_LAV_QUOTA`: **una prassi presentata
come dato**. Da li e passata nel commento della `0004`, in questa tabella, e in un
messaggio a una corsia che l'ha ricevuta come fatto.

**E c'e di peggio del non averla verificata: e poco probabile.** ~~La scheda 12 dice
che la maggior parte delle 480 aziende sta sotto i 15 lavoratori, quindi 31
aggiornamenti su 159 — il 19% — sono troppi per venire da quelle.~~ **Contata l'11
settembre (`40ca5bc`), ed e vera all'81%.** Le 31 righe sono **quattro aziende**:
Rittal RCS 17 righe (408 lavoratori), ZUCCHELLI FORNI 6 (66), CAFFINI 2 (53), KOSME 6
(11). **Venticinque righe su 31 vengono da aziende sopra i 50**, e la controprova
nell'altro verso e quella che rende il conto credibile: **le 128 righe a 4 ore vengono
da 42 aziende, di cui due sole sopra i 50, per 4 righe su 128 — il 3%.** Ottantuno
contro tre non e una coincidenza.

**Quindi la ritrattazione era giusta e il dubbio era sbagliato, e le due cose sono
diverse.** Giusto: quella frase **non era un conteggio** e l'ho citata come tale;
qualificarla era dovuto a prescindere da come sarebbe finita. Sbagliato: il ragionamento
di probabilita con cui l'ho attaccata. E l'errore ha un nome preciso — **avevo scritto
io stesso il controesempio e poi ho ragionato come se non l'avessi scritto**: «31 righe
non sono 31 aziende, e un'azienda grande fa piu aggiornamenti negli anni». Erano quattro
aziende, e una ne ha fatti diciassette. Sollevare una riserva e poi non pesarla e peggio
che non sollevarla, perche fa sembrare controllato un conto che non lo e.

**E la meta della frase che nessuno aveva notato regge da sola, senza contare niente.**
Il gestionale ha **due voci di catalogo distinte** — «Aggiornamento R.L.S. 4 ore» e
«Aggiornamento R.L.S. 8 ore». Non e una durata digitata storta: chi registrava ha
**scelto** fra due voci. Bastava guardare il dizionario invece di ragionare sulle
proporzioni.

**Resta aperta KOSME SPA**: 6 righe da 8 ore con 11 lavoratori in anagrafica. O sei
righe sul titolo sbagliato, o — piu probabile — l'anagrafica parziale di una societa
grande, che e il punto della riserva qui sotto. Va nella lista di cio che aspetta una
persona, dopo MIGLIORINI e ANTICHI SAPORI.

Che cosa resta vero: che le durate reali sono **due** e il catalogo ne porta **una**.
Quello e misurato e il giunto della `0057` risponde comunque. E adesso e misurato anche
il **perche** siano due.

La `0004` non si corregge, per la stessa ragione della nota dell'RLS qui sotto. Ma va
detto che **la `0006` da quella frase e salva**: la nota di `rls -> RLS` porta
`(4h x128, 8h x31)` e si ferma li, senza dire di chi siano le 31. Non per merito —
non me ne ero accorto — ma perche scrivere in una colonna costringe a scrivere meno.

**Una nota della `0006` cita una norma abrogata, e la `0006` non si tocca lo stesso.**
La riga `rls -> RLS` porta scritto «4 fino a 50 lavoratori, 8 oltre»: e la regola di
**prima del 31 dicembre 2025**, superata dall'art. 5 del D.L. 159/2025 convertito con
L. 198/2025. I casi sono **tre e non due** — sotto i 15 la legge non fissa nessuna
durata e rinvia al CCNL — e le 4 e le 8 sono **un pavimento** e non la durata.
Segnalato da AppFormazione l'11 settembre mentre caricava la migrazione, e hanno
ragione: **la scheda 12 di questo repo lo scrive gia**, nella sezione «L'RLS ha tre
casi, non due». E una riga di catalogo che **sopravvive alla scheda che l'ha
corretta**, che e la forma domestica di R5.

Aggravante rispetto a un commento sbagliato: quella frase non e un commento, **e il
valore della colonna `note`**, quindi e un dato caricato in tabella e non una riga
di file. Una norma abrogata dentro una colonna e peggio di una norma abrogata dentro
un commento.

E nonostante questo **il file non si corregge**, per due ragioni che vanno insieme:
la `0006` e appena stata **caricata e misurata**, e riscriverla farebbe riferire quei
sette conteggi a un file che non esiste piu — si distruggerebbe una misura fresca per
sistemare una frase. E perche la correzione vera non e riscrivere la nota: e
**modellare le tre varianti**, che e il giunto assegnato ad AppFormazione. La nota
sparira quando ci sara la regola, e fino ad allora il posto dove sta scritta e questo.
`rspp -> RSPP_MOD_B_SETTORE` e `datore_lavoro_rspp -> DL_RSPP_SETTORE` dicono che il
modulo di settore e dovuto; **quante ore** lo decide l'ATECO del cliente, e l'ATECO
del cliente e una cella di testo libero. La misura dell'11 settembre
(`154cbcf` in AppSopralluoghi) dice quanto: su 262 celle risolte **una** prende la
divisione sbagliata, ed e quella che il modulo di settore lo perde — edile
archiviata come reti fognarie, 16 ore che nessuno chiedera mai. Lo 0,4% non e un
motivo per non spostare il dato: **e un motivo per non spostarlo come se fosse stato
validato**, ed e la riga di cautela che va con quei 262 ovunque vadano.

La correzione **non si fa nella `0006`** — una migrazione gia merged non si tocca, e
la regola e della `0004` — e non si fa nemmeno nello schema: quelle due righe sono
giuste. Si fa dove il `null` vuol dire piu cose, cioe nel motore di AppSopralluoghi.

**E la misura dell'11 settembre (`f1184f6`) ha ridimensionato l'urgenza e allargato
il problema, nello stesso colpo.** Ridimensionato: `nomina` e a **zero righe**,
quindi oggi non morde su nessuno, e al primo import morde su **quattro** societa che
non sono SHAMS. Allargato: gli stati da separare sono **tre e non due** — «nessun
modulo dovuto» (214 clienti), «non conosco la divisione perche l'ATECO non c'e»
(357), e **«ho una divisione e potrebbe essere quella sbagliata»**. Il terzo e il
solo che **nessun tipo di ritorno sa esprimere**: non lo distingue un `null`, non lo
distingue un valore, lo distingue **soltanto** il confronto con la cella d'origine —
che in archivio non c'e piu, perche si e conservata la divisione e non il testo da
cui e stata ricavata.

Da cui una conseguenza che vale oltre l'ATECO, e che questo repo ha gia imparato una
volta con `import_key`: **quando si deriva un dato da un testo altrui, il testo
altrui e parte del dato.** Buttarlo rende la derivazione irripetibile e il dubbio
inesprimibile. E la stessa ragione per cui `corso_alias` tiene il testo verbatim
invece dell'impronta, ed e il motivo per cui la riparazione qui non e solo un
`enum` al posto di un `null`.

I numeri del 11 settembre lo confermano **dal basso**, ed e la cosa piu utile uscita
da quella misura: tutte e tre le anomalie sono **invisibili guardando l'archivio e
visibili in un secondo guardando la cella**. SHAMS ha `37` e sembra una riga come le
altre; MIGLIORINI ha `46` e sembra una riga come le altre; i 357 senza ATECO almeno
si vedono, ed e il caso **meno** grave dei tre. E la distinzione su **dove** va
conservata la cella e di AppSopralluoghi e vale la pena ripeterla: sul **cliente**,
accanto a `codice_ateco`, e non in un log dell'import — «un log dell'import risponde
a *cosa e successo quel giorno*, non a *questo valore e affidabile*».

**La divergenza che AppFormazione deve guardare in casa propria.** Incrociando le due
consegne per riempire la `0006` e uscita una riga che **non e stata scritta** e che
spiega perche: in `staging.classificazione_corsi` i due titoli

    AGGIORNAMENTO DATORE DI LAVORO
    AGGIORNAMENTO DATORE DI LAVORO CON MODULO AGGIUNTIVO "CANTIERI"

stanno sotto l'obbligo **`datore_lavoro_rspp`** (art. 34), mentre le loro due varianti
**iniziali** — «DATORE DI LAVORO», «DATORE DI LAVORO CON MODULO AGGIUNTIVO CANTIERI» —
stanno sotto **`datore_lavoro_art37`**. Gli stessi due corsi, l'iniziale di qua e
l'aggiornamento di la. Se fosse vero, **l'aggiornamento da datore semplice chiuderebbe
l'obbligo dell'art. 34**: un percorso abilitante con decadenza a dieci anni assolto da
sei ore. Qui la riga non e entrata, perche `figura_requisito` non ha niente di simile e
la sua `049` ha cancellato proprio la riga del DL-RSPP verso il corso base. **Non va
compensata da questo lato**: va guardata dove nasce, ed e un difetto che tocca il loro
motore delle scadenze prima del nostro schema.

**Confermata l'11 settembre (`f73eb1b`), ed e peggio: non e una scelta discutibile, e
meta di una correzione.** La loro `0022` aveva messo tutti e 17 i titoli sotto l'art.
34 **annotando** che «DATORE DI LAVORO» andava riguardato; la `0035` e andata a
riguardarlo — ha creato `datore_lavoro_art37`, **ha spostato i due iniziali**, ha
rifatto la matrice dei crediti — e nella propria testata scrive «aggiornamento
diverso: 6 ore per il datore di lavoro, 8 per il datore di lavoro RSPP». **Sapeva, e
ha spostato meta.** Lo confermano anche le note: i due titoli spostati ne portano una
ciascuno, i due rimasti indietro non portano niente. E il gestionale sta con la norma
e non con loro — in `staging.mappa_aggiornamenti` i due aggiornamenti contesi ricevono
**solo** da corsi dell'art. 37 e **mai** dalla famiglia RSPP: tredici righe, zero
eccezioni sul verso che conta.

**E il costo non sono le ore, e la decadenza.** `datore_lavoro_rspp` ha
`decadenza_mesi = 120`, `datore_lavoro_art37` non ha decadenza. Due percorsi identici
dell'art. 34 del marzo 2018, una sola differenza — sei ore di AGGIORNAMENTO DATORE DI
LAVORO nel marzo 2026 — e la decadenza si sposta **dal 2028 al 2036**: `scaduto`
diventa `valido`. Quella riga non chiude solo un obbligo che non ha titolo di
chiudere: **rinvia di otto anni l'unico stato che dice «rifare da capo»**. Tenerla
fuori dalla `0006` era giusto per una ragione piu grossa di quella che avevo.

**La correzione non e stata fatta, e il motivo e migliore di «era sola lettura».** Sta
in due righe di `staging.classificazione_corsi`, e `promuovi.sql` le applicherebbe **da
solo al prossimo import**: rimapperebbe lo **storico** senza che nessuno esegua altro.
Prima serve un numero — quanti eventi hanno oggi quei due titoli. Se e zero la
correzione e gratis; se non e zero, **cosa fare dello storico viene prima della
correzione**. Il numero e chiesto ad AppSopralluoghi, che ha l'export. **Contato l'11 settembre: e zero** (`40ca5bc`). Quei due
titoli non compaiono fra i corsi erogati — esistono **solo come 12 scadenze future**,
2030-2031, ognuna generata da un iniziale davvero fatto. Quindi la correzione **non
rimappa niente**: tocca dodici obblighi da calcolare bene la prima volta, il che sulla
decadenza a 120 mesi e la posizione migliore possibile.

**E il conteggio ha portato un quarto testimone.** Lo scadenzario del gestionale mette
quegli aggiornamenti a **cinque anni** dall'iniziale (2026 -> 2031), mentre la
decadenza dell'art. 34 e a **dieci**. AppSopralluoghi l'ha segnalato come «due orologi
diversi sullo stesso attestato», e letto insieme al resto dice di piu: **cinque anni e
il ciclo dell'art. 37**, cioe il gestionale tratta quei titoli da datore semplice
anche quando decide **quando scadono**. Tre segnali indipendenti — la norma, la
`staging.mappa_aggiornamenti` con tredici righe e zero eccezioni, e adesso il
calendario — contro **una sola** riga di classificazione.

**~~Un task che nessuna corsia puo prendere~~ — era falso, e l'ho scoperto per caso.**
Avevo scritto che far girare le migrazioni su PostgreSQL potesse farlo solo
Francesco, perche «nessuna delle tre sessioni ha `psql`, Docker o le credenziali».
**Su questa macchina un PostgreSQL locale c'e**: la corsia AppFormazione ci ha
riprodotto 56 migrazioni su 56 per ricostruire il proprio stato. Non l'avevo
verificato — avevo generalizzato l'assenza di `psql` in **questa** sessione a tutte e
tre, che e la forma domestica di A9.

**Fatto l'11 settembre 2026, e la `0004` e la `0005` non sono piu solo scritte.**
Caricate su un PostgreSQL 16 locale e vuoto dalla corsia AppFormazione: **le cinque
migrazioni passano tutte e cinque in ordine**, e i cinque conteggi attesi combaciano
— 40 in `corso`, 268 in `corso_alias`, 31 `ignorato`, 237 mappate su 39 codici, 10 in
`accertamento`. `v_sorveglianza` calcola le scadenze giuste, e il vincolo
`alias_senza_corso_ha_un_motivo` e stato provato **nei due versi**: rifiuta la riga
senza motivo e accetta la stessa riga con una nota. Un vincolo che rifiuta tutto non
e un vincolo.

Il carico ha trovato **un bug vero**: il seed dei 268 alias chiudeva con `on conflict
(testo_gestionale)`, il nome che la colonna aveva prima che la rinominassi `testo`.
L'elenco delle colonne dell'`insert` era gia giusto — la deriva era fra il generatore
del seed e la migrazione, e sarebbe stata invisibile fino al primo carico.

Nota per la Fase 3: quelle migrazioni hanno bisogno di **quattro righe** di
impalcatura Supabase (due `auth.uid()` e i `to authenticated`), quindi girano su un
Postgres nudo. Non e una dipendenza da Supabase.

Resta di Francesco **solo** cio che vuole le credenziali vere: applicare in
produzione. **Autorizzato l'11 settembre 2026** — «applica le due migrazioni in
produzione» — per la `0055` e la `0056` di AppFormazione, cioe la decisione 5 che il
database non aveva e il `security_invoker` sull'unica vista scoperta.

Ordinata con la disciplina che il piano free impone: misura del **prima**, i due file
letti per sapere se sono **idempotenti**, applicazione in ordine, misura del **dopo**
— incluso **quanti clienti cambiano classe di rischio**, che e il numero che dice cosa
e cambiato per l'azienda e non per lo schema. E una trappola dichiarata in anticipo:
applicare incollando SQL nell'editor **non registra** le versioni in
`supabase_migrations.schema_migrations`, quindi ripara il dato e crea una nuova deriva
fra file e registro — la classe di difetto per cui esiste A10. Se la CLI non c'e, va
scritto che sono state applicate a mano e non registrate; **non** si inventano righe
nel registro di sistema.

**~~Serve Docker~~ — no, e la confusione era mia.** Avevo scritto che senza Docker il
database *applicato* di AppFormazione non fosse leggibile. E falso in un modo che
conta: Docker alzerebbe un Supabase **locale**, cioe un database **vuoto** su cui
riapplicare le migrazioni — che e una **terza ricostruzione**, non il database
applicato. Sotto A10 non proverebbe niente: A10 chiede di confrontare i file con
**cio che e stato applicato in produzione**, e quello vive nel progetto Supabase
remoto.

Quindi lo strumento giusto non e Docker, e l'**SQL Editor del progetto**, in sola
lettura e dal browser — che e esattamente come la corsia AppSopralluoghi ha letto il
proprio (`pvbwcfrgatkqashstxjc`, `main`) e ha prodotto lo «zero divergenze su 21» e
la divergenza sul `049`/`050`. Non serve installare niente e non serve spostare
macchina: **serve l'accesso in lettura al progetto di AppFormazione**, che quella
corsia non ha.

E per le **mie** migrazioni Docker non serviva mai: la `0001` -> `0005` piu il seed e
stata caricata su un **PostgreSQL 16 nudo**, e quelle migrazioni chiedono quattro
righe di impalcatura (`auth.uid()` e i `to authenticated`) e nient'altro di Supabase.

**E due che aspettano una persona, non un turno.** Entrambe vanno a chi compila il
gestionale, e conviene farle **nella stessa conversazione**. Dall'11 settembre sono
**quattro**, e le ultime due non vanno a chi compila.

**La piu urgente e anche la piu piccola, ed e l'unica che ha una data di scadenza
implicita: qual e l'ATECO primario di MIGLIORINI MATTEO?** In archivio c'e il `46`,
ingrosso, `basso`; nella stessa cella c'e anche il `33`, riparazione di macchine,
`alto`. Vince il primo incollato, che non e un criterio. Sono **tre lavoratori** che
oggi hanno una formazione specifica da 4 ore dove ne servirebbero 12. Nei dati la
risposta **non c'e** — le tre mansioni sono OPERAIO, TITOLARE-RSPP, APPRENDISTA, e i
due mestieri sono compatibili con la stessa ditta individuale — quindi serve la
**visura** o una domanda al cliente. Qualunque regola automatica (il primo codice, il
piu specifico, il piu alto per prudenza) sarebbe **una nostra decisione travestita da
dato**, e non e stata presa. Subito dopo viene ANTICHI SAPORI, 27 lavoratori e il
verso opposto: li i dati **corroborano** il `10` archiviato — la maggioranza delle 27
mansioni e produzione alimentare — ma corroborare non e decidere, perche l'attivita
prevalente e quella della **visura** e non quella che sembra dall'organigramma.

**E la terza, che va letta su una norma:** `corso_assolve` non
ha una riga per **`datore_lavoro_art16`**, il datore delegato, perche se al delegato
spettino gli obblighi del **datore** o quelli del **dirigente** e una domanda di
diritto e non di mappatura. Le fonti si dividono: il campo ha gia scritto
`datore_lavoro_art16 -> DATORE_LAVORO` e ce l'ha in produzione, il modello di
AppFormazione quel ruolo **non ce l'ha proprio** e dice per iscritto di non tradurlo
finche la norma non e letta. Sotto A7 aspetta parte, punto e pagina:

1. **La colonna «RSPP»** raccoglie di fatto l'art. 34, il datore che assume
   l'incarico in proprio. La prova e nei due versi — dei 28 marcati, 26 hanno un
   corso da datore e **zero** hanno i moduli professionali A/B/C; e le 12 persone
   con i moduli professionali sono marcate RSPP in **zero** casi. La domanda non e
   se noi la leggiamo bene: e se il gestionale debba continuare a chiamarla cosi.
   Nessuna nomina RSPP entra prima.
   **L'11 settembre e arrivata una seconda prova, e da un'altra popolazione**
   (`8dab00a`): delle **91 righe** che scrivono «RSPP» dentro la *mansione* —
   non nella colonna — **85 aggiungono di proprio pugno che quella persona e
   titolare, socio o datore**, e 3 dicono espressamente che **non** lo e. Le due
   misure guardano insiemi diversi, 28 marcati nella colonna e 91 scritti a mano,
   e **concordano**. Non rispondono alla domanda — cosa il gestionale *intendesse*
   resta tuo — ma la pesano: se quella colonna volesse dire «professionista
   esterno», ci sono **85 righe che la smentiscono per iscritto**.
2. **Le 79 colonne dei «fattori di rischio»**: cosa ci si mette, e chi. Non e la
   valutazione della mansione — due righe della stessa societa portano gli stessi
   quindici fattori con mansioni «installatore di cantiere» e «programmatore» — e
   nessuna riga ha uno o due fattori: il minimo e **tre**, come se si incollasse un
   blocco invece di aggiungere un rischio alla volta. Le tre letture compatibili
   (rischi dell'azienda dal DVR attribuiti a tutti; griglia iniziata e non finita,
   39 societa su 480; rischio di reparto) **i dati non le distinguono**, e per questo
   foglio non esiste riscontro esterno: nessun altro foglio incrocia quelle colonne
   e non c'e un campo che dica chi ha compilato o quando. Il documento della corsia
   descrive la **forma** del dato, non il significato — ed e scritto cosi.

Quando uno di questi si chiude, questa tabella si riscrive. Se resta ferma per un
giorno di lavoro, e scaduta — e vale la nota della sezione 3: un piano che tiene
anche lo stato nasce scaduto, ma **l'assegnazione non e stato, e una decisione**.

- **A9** **Un dato coerente con se stesso non e per questo vero.** Enumerare le
  colonne di un export e **necessario e non sufficiente**: la verifica che scopre il
  difetto e **esterna al file**. Aggiunta il 10 settembre 2026 dalla corsia
  AppSopralluoghi, e pagata sul caso peggiore — il foglio «Ruoli SSL» ha una colonna
  testuale (la 32) che ripete i ruoli in prosa, e il riscontro fra quella e le nove
  colonne di data da **zero incoerenze su tutte e nove** (79/79, 85/85, 31/31 e via).
  Il file non si contraddice mai: chiama RSPP la colonna 45 e la ripete RSPP
  nell'elenco. Il difetto sta **a monte del file** — il gestionale chiama RSPP il
  datore che assume l'incarico in proprio, art. 34 — e la prova sta **negli
  attestati**, dove la sovrapposizione con chi ha i moduli professionali e zero.
  A8 riguarda **quando** una nota e stata scritta; questa riguarda **dove** puo stare
  la prova: mai solo dentro il dato che si sta verificando.

- **A10** **Le migrazioni descrivono il database, tranne dove un file e stato
  modificato dopo essere stato applicato — o non e stato applicato affatto.** La
  seconda meta e arrivata l'11 settembre 2026, misurata in SQL sul progetto di
  AppFormazione: **54 migrazioni applicate su 56 file**, e le due che mancano sono la
  `0055` e la `0056`. Nessuna rinumerata, nessuna applicata senza file: il difetto e
  piu semplice e piu grosso della deriva del `049`/`050`.
  **E il test operativo che avevo scritto era sbagliato**, corretto l'11 settembre da
  AppFormazione: confrontare i **nomi** dei file col registro trova un file
  **rinominato**, non un file **modificato** — un file modificato conserva il suo
  nome, quindi quel confronto passerebbe senza vedere niente. Per accorgersi di un
  contenuto cambiato serve un'**impronta**, e va prima verificato se il registro di
  Supabase ne conservi una. **Lo conserva, e meglio di un checksum** — misurato l'11
  settembre 2026: `schema_migrations` ha una colonna **`statements`**, valorizzata su
  tutte e 56 le righe, che non e un'impronta ma **il contenuto applicato**, spezzato
  in enunciati e **verbatim**: il primo enunciato della `0055` comincia col suo
  commento di intestazione, quindi **anche una modifica ai soli commenti sarebbe
  visibile**. Quindi A10 **ha un test**, e «i file sono quelli applicati» e
  dimostrabile.
  **Ma il test non e `md5(file)` contro `md5(statements)`**, e scriverlo cosi lo
  farebbe nascere rotto: la CLI applica un suo parsing che quattro tentativi di
  riprodurre non hanno riprodotto, e darebbe **un falso positivo su tutte e 56**. Il
  test operativo e prendere **oggi** l'md5 degli `statements` come riferimento e
  riconfrontarlo in futuro: una deriva si vede come cambio d'impronta, senza
  ricostruire le regole della CLI. Riferimenti gia presi: `0055` venti enunciati,
  `b847bbb2597510e439945f43c729d6b0`; `0056` un enunciato,
  `f9f9728d76c2dc4281e4d53d37920d7d`.
  *E una nota che merita di stare qui: per rispondere a questa domanda **Docker
  sarebbe servito davvero** — `supabase db dump --schema supabase_migrations` lo
  richiede. Lo strumento chiesto per il problema sbagliato serviva per un altro
  problema.* Conseguenza: **la `0055`
  recepiva la decisione 5**, e in produzione le divisioni **30, 86 e 87 sono ancora
  `null`** — un cliente con quell'ATECO oggi non ha classe di rischio, e le colonne
  `fonte` e `dedotto` non esistono. La voce era dichiarata **chiusa** nel loro
  `STATO.md`: il commit c'era, il file c'era, e il database non lo sapeva.** Aggiunta il 10 settembre 2026 e pagata
  sul caso benigno: `DL_RSPP_BASE` porta «DEPRECATO dalla **050**» nel database e
  «dalla **049**» nel file, perche quella migrazione e nata 050, e stata applicata,
  poi rinumerata a 049 con la nota aggiornata — e il database non e stato
  rieseguito. Qui la differenza e un carattere in una nota. **Il meccanismo non e
  benigno**: se la modifica avesse riguardato le **ore** di un corso, la
  ricostruzione dai file avrebbe prodotto un valore che nel database non e mai
  esistito, e sarebbe stata coerente con se stessa — cioe A9 applicata alle
  migrazioni invece che a un export. Da cui: una ricostruzione dai file **si
  qualifica** («i file dicono»), non si dichiara vera, finche non e confrontata con
  cio che e stato applicato.
- **A11** **Quando due fonti divergono al cento per cento, il sospetto giusto e il
  confronto, non i dati.** Aggiunta il 10 settembre 2026 dalla corsia
  AppSopralluoghi, che al primo giro ha visto **zero hash coincidenti su 40** e
  stava per riportare «divergono tutte». Non divergeva niente: `ore` e `numeric` e
  Postgres la stampa `4.0` dove la migrazione scrive `4`, e un booleano concatenato
  diventa `t` e non `true`. Due differenze di **rappresentazione**, zero di dato. Il
  controllo che l'ha smascherata e guardare **la stringa grezza sotto l'hash**: un
  digest dice *se* due cose differiscono e non *in cosa*, e per questo non va usato
  da solo per dare una notizia.
  **Seconda applicazione il giorno dopo, e da li viene una regola operativa:** il
  confronto del dizionario dei 268 alias col database usava
  `md5(string_agg(... order by testo))` e dava hash diversi. Un digest su
  un'aggregazione **ordinata non e confrontabile fra sistemi** — l'`order by` di
  PostgreSQL segue la **collation** del database, un ordinamento in Python segue i
  codepoint — e sulle stesse 268 righe i due ordini differiscono in **71 posizioni**.
  Si confronta con una **somma di impronte per riga**, che non dipende dall'ordine, e
  si accompagna a **conteggi per campo**, che dicono *dove* sta la differenza invece
  di dire solo *che c'e*. Fatto cosi ha dato **undici valori su undici identici**: la
  tabella era la stessa dall'inizio, e «qualcuno ha ritoccato a mano» era a un passo
  dall'essere scritto.
  **Due cose da tenere, e la seconda vale piu della prima.** La query non era
  sbagliata: era **giusta per un altro uso**. Confrontare un database **con se stesso
  nel tempo** con quell'hash funziona, perche l'ordinamento e lo stesso da entrambe le
  parti; confrontarlo con un'**altra implementazione** no. Uno strumento corretto
  applicato a un uso diverso da quello per cui e corretto.
  E la regola che dice **quando** sospettare, perche e l'opposto dell'istinto: nei due
  casi **la notizia falsa era piu interessante di quella vera**. «Quaranta codici su
  quaranta divergono» e «qualcuno ha ritoccato 268 giudizi a mano» sono titoli;
  «combacia tutto» non lo e. **Un confronto che produce una notizia grossa merita piu
  sospetto di uno che non ne produce nessuna**, e la fretta di riportarla e il momento
  in cui il controllo non si fa.

- **A12** **Un test che non sbaglia mai non prova niente: serve un controllo
  negativo.** Aggiunta l'11 settembre 2026 dalla corsia AppSopralluoghi, e ha
  trasformato tre risultati plausibili in tre affidabili. Cercando quali durate di
  corso fossero cambiate **nel tempo**, ha aggiunto al test un codice in cui la causa
  e **nota e diversa** — l'`RLS`, dove le due durate dipendono dalla dimensione
  dell'azienda — e ha verificato che il test rispondesse «nessuna separazione». Lo ha
  fatto: 82% e 81% di attestati prima dello spartiacque, proporzioni quasi identiche.
  Da cui il taglio netto del `DIRIGENTE` (12 righe prima, zero dopo) non e un
  artefatto del metodo. **Un controllo che conferma qualunque ipotesi gli si dia non
  e un controllo**, e la differenza fra «plausibile» e «misurato» sta in questo passo
  in piu.

- **A13** **Un confronto fra due numeri presuppone che misurino la stessa grandezza, e
  questa condizione viene prima di tutte le altre.** Aggiunta l'11 settembre 2026 dalla
  corsia AppFormazione, che l'ha pagata **cercando una citazione**: il loro documento
  sulle durate multiple chiedeva due prove per ammettere un obbligo al confronto —
  attesa unica e durate reali uniche — e **ne mancava una terza a monte**. La parte III
  dell'ASR scrive «durata minima 6 ore» per il preposto e «durata minima 4 ore **di
  parte pratica**» per le attrezzature: stesso formato, due grandezze. Un attestato
  riporta il **totale**. Confrontare il secondo numero con le ore di un attestato non
  da un risultato sbagliato per poco: **da un risultato che non significa niente**, e lo
  da **in silenzio**, perche due numeri si confrontano sempre. La difesa non e la
  prudenza, e **marcare la grandezza accanto al numero** — `requisiti
  .aggiornamento_solo_parte_pratica` da loro, e da qui una colonna che la `0004` non ha:
  sedici codici di questo catalogo portano un `4` che non dice di che cosa.