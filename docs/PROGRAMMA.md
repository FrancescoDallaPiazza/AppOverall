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

**12 schede su 13 sono chiuse.** Stato generato dalle schede: il paragrafo `## Decisione` di ognuna e la fonte, questa tabella e la resa.

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
| [13 · Leggere gli attestati che ci arrivano, in maniera deterministica](decisioni/13-lettura-attestati.md) | niente · ma finché è aperta, le ore davvero erogate restano l'unico dato che nessuna fonte sa dire | **aperta** |

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
| Copertura del codice fiscale sulle due meta dell'organigramma | **7,8%** vs **63,5%** senza CF | Misurato il 12.09 su `ExportExcel.xlsx` (2023): **204 righe** col ruolo nelle **colonne**, 16 senza codice fiscale; **74 righe** col ruolo nella **mansione**, **47 senza**. La meta dedotta dell'organigramma e **otto volte peggio coperta** di quella dichiarata, e agganciando solo per codice fiscale se ne perderebbero **quasi due righe su tre**. Chiude la domanda lasciata aperta il giorno prima — «il 12 su 153 non si estende alle 160 della mansione» — e non si estendeva **in meglio**. **Due riserve, e la seconda conta piu del numero**: il dizionario e stato costruito sull'export del **2026** e applicato al **2023** riconosce solo le forme che gia conosce, quindi **74 e un limite inferiore**. E il 63,5% e probabilmente **ottimista**: le forme che il dizionario non conosce sono per costruzione le piu irregolari, e non c'e ragione di credere che chi scrive il ruolo in modo irregolare compili meglio il codice fiscale |
| Insiemi distinti di «fattori di rischio» | 76 | Su **162 righe** con almeno un fattore, 3.501 totali. 122 righe condividono l'insieme con un'altra: **112 nella stessa societa**, 45 con la stessa mansione. La cella ha **un solo valore distinto**, `X`, in 2.447 occorrenze su 79 colonne, e nessuna colonna porta un grado o una fascia. Misurato il 10.09 da AppSopralluoghi (`39fb586`) |
| Il numero N della migrazione anagrafica | **3.415 schede** | Misurato il 13.09 da AppSopralluoghi (`d12196a`) con `npm run conti:migrazione`, lanciato da Francesco fuori da Claude con la `service_role` passata solo per quell'esecuzione, e **prima** di qualsiasi import delle nomine: **3.419 persone su 619 clienti**, lo stesso `count(*)` del 10.09. **4 codici fiscali validi** stanno su due clienti ciascuno: 8 righe che qui diventano 4 persone con 8 rapporti, quindi 3.419 − 4 = 3.415. «Valido» vuol dire il carattere di controllo della funzione di produzione, non la forma, e nessun CF valido e ripetuto dentro lo stesso cliente (3.160 validi − 3.156 distinti = 4, esattamente). **Riserva, e va con il numero ovunque vada: sono schede, non persone.** Il ripiego sul nome di `anagraficheImport.ts:733-763` fonde due omonimi senza CF al secondo import, perche la chiave per nome si calcola e si cerca anche quando il nome e ambiguo, e una fusione avvenuta non lascia traccia nel database (`f25664e`). Il **3.420 contro 3.419** e compatibile con esattamente una scheda che ha ricevuto due righe, ma **non e verificabile**: il file del 9.09 non esiste piu. Se una fusione c'e stata, una persona vera sta gia dentro un'altra, e nessuna migrazione la tira fuori |
| Le schede senza codice fiscale, per la migrazione | **259** | **228** senza CF sul database piu i **31** con un CF scritto e non valido, che la `0008` tratta come **assenti**, con la cella conservata in `codice_fiscale_origine`. Sul database (`5727a7f`, quattro `select` in sola lettura del 13.09): **0** schede senza `import_key` su 3.419, **228 su 228** senza CF agganciate per nome, **0** omonimi senza CF nello stesso cliente con gli spazi normalizzati, **2** nomi uguali su clienti diversi, che qui tiene separati solo la `import_key` del rapporto. Fra i 31 nessuno cerca doppioni: e una perdita dichiarata, **nel verso delle schede in piu e mai in quello delle persone fuse**. Il **235** della `0013` e dei documenti del 9.09 contava righe del file, non schede, e la differenza con 228 resta non spiegata per la stessa ragione del 3.420 |

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

**E la regola si e allargata due volte il 12 settembre, e la seconda volta nel verso
scomodo.** La prima: le tre istanze erano un **dato**, la quarta era una **misura** —
«Addetti Emergenze e l'addetto antincendio?» era gia misurato da AppFormazione
dall'11, e la colonna era stata lasciata fuori dicendo «non si deduce», che e la
risposta giusta per la ragione debole.

La seconda l'ha scritta la stessa corsia poche ore dopo, dopo aver trovato in un
**proprio** file la risposta a una domanda che stava per girare a una persona:

> **La regola vale anche verso il proprio repo, non solo verso quelli degli altri.**

Due volte in una sera la risposta era gia scritta — una in un repo altrui, una nel
proprio — e nessuna delle due volte il difetto e stato **non avere il dato**: e stato
**non cercarlo dove stava**. Il verso scomodo e il secondo, perche verso gli altri la
regola si applica per abitudine di coordinamento; verso di se bisogna sospettare di
aver gia guardato.

**E la quinta istanza toglie anche l'ultima scusa, che era la piu credibile.** Le
prime quattro si potevano raccontare come «non sapevo dove fosse»: un altro repo, un
altro disco, un TODO di agosto, un file di cui non si conosceva il nome. La quinta no.
Il file era `righe.json`, in `docs/c1a/` **dal 30 luglio**, ed era stato **aperto tre
volte la sera stessa** — per contare le voci del catalogo.

> **Avevo il file in mano e gli ho fatto una domanda sola.**

E il difetto che ne esce non e di ricerca ma di **interrogazione**: un file gia
letto e classificato come «quello dei conteggi» smette di essere un posto dove
guardare. La forma operativa: quando una domanda resta senza risposta, **rifare il
giro dei file gia aperti chiedendo la domanda NUOVA**, non cercarne di nuovi.

**E il corollario, dalla stessa corsia e nella stessa ora: un avviso che vive altrove
non protegge chi apre il documento.** La contraddizione dei «30 contro 31» era stata
scritta nel loro `STATO.md` — che e il posto giusto per chi segue il lavoro — mentre
il file citato a sostegno di una decisione **si apre da solo**, e chi lo apre domani
la incontrerebbe senza avviso. Adesso l'avvertenza sta in testa a quel file.

E la forma di quell'errore e la **stessa dei diari ritirati la mattina, nel verso
opposto**: li il contenuto stava in un posto che lo faceva sembrare piu di quello che
era, qui l'avvertenza stava in un posto giusto per chi l'aveva scritta e sbagliato per
chi legge. **Dove una cosa e scritta e parte di cosa dice**, e vale nei due versi.

**E la meta che dice QUANTO, senza la quale la prima si applica male.** «Un avviso
che vive altrove non protegge chi apre il documento» dice **dove**, e da sola porta a
mettere tutto in testa — e un elenco in testa non lo legge nessuno, quindi la regola
si smette di seguire dopo il terzo avviso. La distinzione, nelle parole di chi l'ha
formulata:

> **L'avvertenza in testa e per chi deve decidere SE fidarsi del file; la correzione
> dentro la riga e per chi sta gia leggendo quella riga e si fiderebbe di QUELLA.**
> Due domande diverse, due posti diversi, e il criterio per scegliere e a quale delle
> due il lettore sta rispondendo in quel momento.

**E il posto in cui un ragionamento sbagliato si nasconde meglio ha un nome.** Il
terzo difetto trovato in quel documento non era un numero — era un argomento che non
reggeva — e **stava sotto un titolo che diceva «Cosa non decido»**. Un titolo che
dichiara di non concludere e il posto perfetto per una conclusione sbagliata: nessuno
va a controllare un ragionamento che si annuncia come non conclusivo. Un numero
sbagliato lo trova chiunque ricontrolli; un argomento sbagliato ha l'aria di un
ragionamento finito, e chi rilegge lo salta.

**E un conteggio in un'intestazione e la prima cosa che qualcuno cita senza rileggere
il corpo.** E successo due volte nella stessa sera e nello stesso documento: da questa
parte, citando «30 righe e due date» presi dalla sezione di dettaglio mentre la
tabella riassuntiva diceva 31; e dall'altra, lasciando in un titolo «sono quattro
cose» dopo che una era caduta. **Il secondo e stato rifatto entro un'ora da chi aveva
appena trovato il primo** — che e la misura di quanto poco serva sapere una regola
senza applicarla al proprio testo.

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
  **Aggiornato il 13 settembre: i due scarti restano non spiegati, e adesso per
  sempre.** Il file del 9 settembre, `ExportExcel (5).xlsx`, non esiste piu, e solo
  l'anteprima dell'import su quel file li scioglierebbe. Il 3.419 e confermato dal
  conteggio del 13, ma **conta schede e non persone**, e sul database le senza codice
  fiscale sono **228**: misure e riserve nella sezione 6.

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
| **AppOverall** | ~~la `0009`, la `0010`, la `0011`, la `0012`~~ **scritte**, e ~~l'uuid~~ **deciso con la `0013`**: i 619 clienti attraversano con **lo stesso** uuid, il cliente prende una `import_key` sua che non passa dall'uuid, e la chiave legacy atterra su `rapporto_lavoro` — perche `anag:<cliente>:<cf>` non e l'identita di una persona ma di **una persona presso un cliente**, e qui quell'oggetto ha gia un nome → **la migrazione dati**, che comincia dalle persone | la Fase 3 vera e propria | Perche sotto la domanda dell'uuid ce n'era una piu grossa e nessuno dei due documenti la diceva: **le due `persona` non sono la stessa tabella**. Da loro e per cliente e due schede sono legittime, qui `codice_fiscale` e unique globale. La migrazione non e una copia, e un **cambio di grana** — e il numero che ne esce ~~non lo sa ancora nessuno~~ **e 3.415 schede**, misurato il 13 settembre, con la riserva che siano schede e non persone (sezione 6) |
| **AppSopralluoghi** | ~~fermi~~ **ripartiti**: Francesco ha tolto la pausa la sera del 12, e il passo e **scrivere** l'import delle nomine — eseguirlo sui dati veri vuole il suo permesso **chiesto a lui direttamente**, non relaiato da qui → poi ~~i due conti che la `0013` non sa fare: quanti codici fiscali validi compaiono su piu di un cliente (le righe che qui collassano in una persona con due rapporti) e cosa succede alle 235 senza codice fiscale, che in questo schema non hanno nessuna identita propria~~ **misurati il 13 settembre** (`d12196a`): **4** codici fiscali validi su due clienti e **0** omonimi senza CF nello stesso cliente, quindi N = **3.415 schede**. Numeri e riserve nella sezione 6 | l'import delle nomine, eseguito | Perche i due conti sbagliano in **versi opposti** — il primo fonde righe che vanno fuse, il secondo righe che non vanno fuse — e un import che non li distingue fa la cosa giusta e quella sbagliata **con lo stesso codice**. E perche si fanno con dei `count`, cioe sola lettura, mentre l'import aspetta una firma |
| **AppFormazione** | **trascrivere la Parte II dell'ASR 2025 in `reference/`**, che e la lacuna che hanno dichiarato loro: chiude sei marche su sei senza decidere niente, e le sei sono le durate iniziali dei corsi piu frequenti del catalogo — datore, dirigente, preposto, lavoratore generale | il giunto `dipendenti_rls`, quando l'anagrafe attraversa | Perche e l'unica cosa che **si chiude leggendo** fra quelle rimaste aperte dalla loro consegna, e perche il secondo passo **non e avviabile e l'hanno misurato**: il loro database locale e fermo alla `0053` mentre il repo e alla `0062`, e `clienti.dipendenti` e null su tutte e 480. Il numero di dipendenti sta nell'altro archivio, su 481 delle 619 attive |

**E una domanda che hanno posto e che non tocca a loro chiudere**: se convenga
colmare `clienti.dipendenti` dai **loro** sette export invece di aspettare il
passaggio dell'anagrafe. La risposta e **no, e non per prudenza**: quel numero ha
un'etichetta — «quante persone ne gestiamo», non «quanti lavoratori ha l'impresa» —
e trasferirlo due volte da due parti diverse e il modo in cui un'etichetta si perde
per strada. Arriva con l'anagrafe, una volta sola, con la sua qualificazione.


### Prossimo passo per corsia · al 14 settembre 2026, mattina

Riscritta perche la tabella della notte del 12 non sa due cose chiuse la sera del 13.
Letta da `origin` dopo un `fetch` alle 10:02 di oggi: nessuna delle quattro corsie ha
un commit dopo il 13 alle 20:54, nessun ramo nuovo, nessuna PR recente.

- **AppFormazione ha le sei migrazioni in produzione** (`ccdf8ef`): registro da `0055`
  a `0062`, applicate il 13 alle 18:14 UTC con `db push --linked` sul si di Francesco
  dato **a quella corsia**. Il primo numero sui dati veri e **0 `ore_insufficienti`
  su 6.570 righe**, e **non assolve**: `clienti.dipendenti` e vuota su 480 clienti su
  480, quindi 8 dei 9 RLS escono `dimensione_ignota`.
- **AppSopralluoghi ha il dizionario leggibile e la guardia online** (`033994a`): la
  `064`-`068` applicata, la `069` che da `staff_full` alle due tabelle che avevano RLS
  e zero policy, e GitHub registra in produzione l'ultimo commit di `main` con stato
  `success`. Sugli omonimi Francesco ha scelto la (a): un nome ambiguo senza codice
  fiscale **non si scrive**, va fra i «da abbinare a mano».

| corsia | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **AppOverall** | ~~**la migrazione dell'anagrafe, cominciando dalle persone**~~ **scritta e provata il 14 mattina, e l'ordine di esecuzione era sbagliato: prima devono attraversare i clienti** (qui sotto). Il passo com'era assegnato: scritta e caricata su un cluster usa e getta come la `0001`-`0006`, **nessuna scrittura su produzione**. I conti che deve restituire sono gia misurati e stanno nella sezione 6: 3.419 righe → **3.415 persone** e 3.419 rapporti, 4 codici fiscali validi su due clienti, **259** schede senza codice fiscale (228 + 31 non validi) che attraversano **come schede, senza fusioni** | il resto dell'anagrafe, e con i clienti `N DIPENDENTI` insieme alla sua etichetta | Perche e il passo da cui dipendono gli altri due: il giudizio di AppFormazione aspetta `clienti.dipendenti`, e `sorveglianza.persona_id` deve puntare a persone che di qua non esistono ancora. E perche il carico si verifica contro numeri scritti **prima** di scrivere la migrazione, non ricavati dopo da quello che ha prodotto |
| **AppSopralluoghi** | **nessun passo nuovo fino all'esito dell'anteprima.** L'anteprima delle nomine dal back-office, senza Applica, **la fa Francesco oggi** — scritto nel loro `STATO.md`, e discende dalla decisione del 12 riportata qui sotto: la corsia non la fa girare. Quando l'esito arriva, a loro tocca **leggerlo e scriverlo**, e se l'anteprima si ferma sulla guardia o non riconosce le righe col ruolo nella mansione la diagnosi e loro | **D2**, il report che non conosce i componenti. L'import delle nomine **non e un passo di questa corsia**: lo esegue Francesco | Perche l'anteprima e l'unica prova che il back-office legga il dizionario: la anon a zero righe dice che la porta e chiusa a chi non e entrato, non che sia aperta a chi e entrato. **D2 viene dopo e non in parallelo** perche vuole un deploy, e un deploy prima dell'anteprima cambierebbe il codice su cui Francesco la fa. **L'abbinamento guidato non si assegna**: riguarda proprio le 259 schede senza codice fiscale che la migrazione sta per portare di qua, e costruirlo nel campo prima di sapere come attraversano vuol dire costruirlo due volte |
| **AppFormazione** | **nessun passo: ferma per costruzione**, non per lentezza. Il giunto `dipendenti_rls` e in produzione e aspetta `clienti.dipendenti` | il giudizio sui 9 RLS, quando l'anagrafe attraversa con `N DIPENDENTI` | Perche l'unica cosa che la sbloccherebbe prima e colmare `clienti.dipendenti` dai loro export, e la risposta e gia scritta qui sopra ed e no. Inventare un passo per non lasciarla ferma sarebbe la regola di questa sezione violata da chi assegna: una corsia senza passo lo chiede, e chi assegna non ne fabbrica uno per riempire la tabella |

**E due cose che l'assegnazione dice per non essere fraintesa:**

- **nessuna scrittura su un database di produzione** per nessuna delle tre righe. La
  migrazione delle persone si prova su un cluster fatto con `initdb` e poi cancellato;
- **l'import delle nomine resta di Francesco**, anteprima e scrittura. Il deploy
  verificato e la `069` applicata tolgono gli ostacoli tecnici, e nessuno dei due e un
  permesso.

**Il passo di AppOverall, fatto il 14 mattina, e la cosa che ha trovato.** Scritti e
provati su un cluster fatto con `initdb` e poi cancellato, **con dati finti**: nessun
dato vero e passato da questa macchina.

- **`0016`, `codice_fiscale_valido`**: il port in SQL di `valido()` di AppSopralluoghi,
  perche la `0008` voleva il carattere di controllo e in questo repo non c'era codice
  che lo calcolasse. Confrontata con la funzione di produzione **eseguita**, non letta:
  **6.177 vettori, 0 disaccordi**. E lo zero discrimina — un controllo di sola forma
  sugli stessi vettori ne sbaglia **1.823**.
- **`supabase/migrazione-dati/`**: `00_origine.sql` riceve l'estrazione, `01_persone.sql`
  la traduce in persone piu rapporti con quattro regole (una riga d'origine = un
  rapporto con id e `import_key` conservati; fusione **solo** per codice fiscale
  valido; mai senza; sul nome discorde vince l'ultima riga aggiornata, e le discordanze
  si contano). **Si rifiuta prima di scrivere in sei casi**, fra cui un'estrazione con
  un numero di righe diverso da quello dichiarato. La prova: **8 rifiuti nei due
  versi, 13 esiti, rieseguito senza effetto, 3 controlli finali fatti scattare**.
  E la prova ha preso un difetto suo prima di passare: con `psql` non trovato dava
  «ok, rifiutato» a tre controlli su un database mai raggiunto. Adesso un rifiuto
  vale solo se a rifiutare e PostgreSQL.

**Cosa ha trovato, e cambia l'ordine: le persone non possono attraversare per prime.**
`rapporto_lavoro.cliente_id` e `not null` con chiave esterna su `cliente` (`0001`), e
la `0013` ha deciso che i clienti attraversano **con lo stesso uuid**: ogni rapporto
punta a un cliente che deve gia esserci. «Comincia dalle persone» era giusto come
ordine di progetto — le persone erano la domanda aperta — e sbagliato come ordine di
esecuzione. Il passo 01 lo dice da se: si ferma con il rifiuto (c).

**E i clienti non sono una copia nemmeno loro.** `cliente.partita_iva` qui e `unique`
con un `check` a undici cifre (`0001:138`), e fra le 615 attive **58** hanno una P.IVA
inutilizzabile — `XXXX`, `00000000000`, due a dieci cifre (consegna dell'anagrafe
§3.4, misura di AppSopralluoghi). Senza una regola, il carico dei clienti **si ferma**:
`XXXX` e le due a dieci cifre sul `check`, e `00000000000` — che il `check` lo passa,
undici cifre sono undici cifre — sull'`unique` appena compare due volte, cosa che
nessuno ha contato. Con la regola sbagliata, invece, quelle righe spariscono. E la
stessa forma del codice fiscale, e la risposta della `0008` e gia li: la cella non
usabile vale come assente e si conserva accanto. **Da decidere prima di scriverlo**,
ed e il prossimo passo di questa corsia.

**Quello che resta fuori da qui, dichiarato:**

- **l'estrazione vera la fa Francesco**, con la select scritta in testa a
  `00_origine.sql`, e il CSV resta fuori da ogni repo;
- due rifiuti **non sono mai stati misurati sui dati veri** — `cognome` null e
  `attivo = false` senza data di cessazione. Se la prima esecuzione si ferma li, e la
  domanda che nessuno aveva fatto, non un difetto;
- `codice_fiscale_origine` riceve la cella **gia ripulita** da `cfPulisci` all'import
  del 9 settembre, non quella del gestionale: e la piu vicina all'origine che esista.

### Prossimo passo per corsia · al 14 settembre 2026, tarda mattina

**L'anteprima delle nomine e vista** (AppSopralluoghi `d8a7cc7`), e riletta da qui su
`origin` prima di assegnare: Francesco dal back-office, senza scrivere, sul codice di
`12b1768` — e fra quello e la produzione cambia solo `docs/STATO.md`, controllato con
un `diff` e non preso dal messaggio; anche il deploy di `d8a7cc7` tocca solo quel file.
La guardia non si e fermata: **364** da creare (198 dalle colonne, 166 dalla mansione),
**153** da decidere, **4** persone non trovate, **4** unita del file non abbinate. E il
conto **rifatto fuori dal database** col seme della `068` torna figura per figura, che
e la prova che mancava: il back-office legge il dizionario, per le chiavi che il file
usa.

| chi | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **Francesco** | **la scrittura delle nomine**, quando decide. **Il pulsante dira «Scrivi 364» e il risultato sara «363 nomine scritte»**: non e una nomina persa, e un doppione tolto — riga 2782, `dirigente` sia dalla colonna sia dalla mansione, e il vincolo `unique (persona_id, figura_codice)` c'e dalla `015`. Le 4 unita non abbinate possono restare fuori: l'import e idempotente e le prende a un secondo passaggio | le 4 unita e la forma «RLS - LAVORATORE», quando vuole: sono decisioni di merito, non passi tecnici | Perche sapere il numero **prima** e cio che distingue un doppione tolto da una riga persa, e dopo la scrittura le due cose si presentano uguali |
| **AppSopralluoghi** | **niente sul codice finche la scrittura non e fatta**: nessun deploy fra l'anteprima e la scrittura | **D2 e la correzione di `riepiloga`, nello stesso deploy**, dopo la scrittura. Con la correzione va ritirato il commento di `nomineImport.ts:542`, che dice «12 righe» e «coincidono» ed e falso tutte e due le volte | L'ordine del mattino diceva D2 **dopo l'anteprima**; la corsia l'ha spostato **dopo la scrittura**, e ha ragione: D2 vuole un deploy, e un deploy fra l'anteprima vista e la scrittura cambierebbe il codice che Francesco ha appena verificato. **Corretto qui, non ratificato in silenzio** |
| **AppOverall** | **la regola per le P.IVA non usabili dei clienti**, prima di scrivere il carico dei clienti: 58 su 615, e il `check` e l'`unique` di `cliente.partita_iva` | il carico dei clienti e delle sedi, poi le persone di `ebafe98`, poi le nomine — che dopo la scrittura esisteranno di la e andranno portate anche loro | Perche le persone aspettano i clienti per chiave esterna, e le nomine aspettano le persone: e l'unico ordine in cui ogni passo trova gia scritto cio a cui punta |
| **AppFormazione** | invariato: **ferma per costruzione** | il giudizio sui 9 RLS quando l'anagrafe attraversa | Niente di stamattina tocca `clienti.dipendenti` |

**Non assegnato, di nuovo e di proposito: l'abbinamento guidato.** L'anteprima gli ha
dato un caso vero — «Pradella Tazio», due righe senza codice fiscale nello stesso
cliente, non scritto per la (a), e con il codice fiscale in un altro cliente — ed e
esattamente la popolazione che la migrazione delle persone sta per portare di qua.
Un caso vero rende la domanda piu concreta, non piu urgente.

### Prossimo passo per corsia · al 14 settembre 2026, mezzogiorno

**Le nomine sono scritte** (AppSopralluoghi `4b97ca2`), da Francesco, sul codice
dell'anteprima: da `12b1768` a `origin/main` cambia solo `docs/STATO.md`, e anche il
deploy di `4b97ca2` tocca solo quello — controllato da qui. **Visto**: la rilettura
dopo la scrittura da **0 da creare** e **364 gia in organigramma**, cioe
l'idempotenza tiene sul caso vero. **Dedotto e dichiarato tale**: «363 scritte» — il
messaggio verde non e stato riportato e la corsia non legge il database, e le 364 gia
presenti sono 363 coppie perche la riga 2782 conta due volte. Nessuno dei due numeri
cambia un passo: la deduzione e aritmetica su un vincolo `unique` che c'e.

**«RLS - LAVORATORE»: la lettura e di Francesco, la migrazione non ancora.** Sono due
ruoli e dal dizionario conta la meta RLS — il lavoratore il dizionario non lo
asserisce mai. ~~Riga 3401, l'unica del file, con la colonna RLS vuota: l'RLS sta
scritto solo li.~~ **Corretto un'ora dopo da chi l'aveva scritto (`51be35d`): le righe
sono tre e il testo sta nella Qualifica, non nella mansione** — vedi il paragrafo
seguente. Qui era stato ripreso senza aprire il file, e la tabella sotto ci poggiava. La `070` che aggiunge la forma e una **proposta** di AppSopralluoghi,
e tocca un dizionario che ha una **copia gemella qui**, nella `0007` (`ruolo_testo`
29 forme e 160 righe, `ruolo_testo_parola` 34).

| chi | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **Francesco** | **se fare la `070`**: la lettura l'ha data, la migrazione e un'altra decisione, perche si applica alla produzione dall'SQL Editor come la `069` | se si fa: rilanciare l'import delle nomine con lo stesso file, perche la nomina RLS di quella riga **non nasce dalla migrazione** ma dal passaggio successivo. L'import e idempotente e l'ha appena dimostrato | Perche una forma aggiunta al dizionario non scrive niente da sola, e fra «il dizionario la conosce» e «la persona e nominata» c'e un passaggio che qualcuno deve fare apposta |
| **AppSopralluoghi** | **D2 e la correzione di `riepiloga`**, un deploy solo, ritirando il commento di `nomineImport.ts:542` — invariato da `44142f9`. **La `070` non si scrive prima del si di Francesco** | se il si arriva: la `070`, e **prima del commit** la forma esatta mandata qui — testo verbatim, figura, righe — perche la gemella sia la stessa stringa e non una trascrizione | Perche D2 e codice e la `070` e dato, e non si aspettano a vicenda. Ma una forma di dizionario copiata a mano fra due repo e esattamente il posto in cui nascono i «4.0 contro 4»: la stringa si confronta, non si riscrive |
| **AppOverall** | **la regola per le 58 P.IVA non usabili** — invariato | se la `070` si fa: **la gemella nello stesso giorno**, con i conti della `0007` aggiornati **in una migrazione nuova** e non riscritti nella vecchia (30 forme, 161 righe, 35 parole, se la forma e quella) | Perche la `0007` e merged e i suoi conti valgono per il giorno in cui sono stati presi; e perche due dizionari che divergono per una riga rompono `ruoli:check` di la e il confronto di qua, e il primo a vederlo sarebbe chi non l'ha causato |
| **AppFormazione** | invariato: **ferma per costruzione** | il giudizio sui 9 RLS quando l'anagrafe attraversa | La riga 3401 e un RLS in piu nel campo; per loro conta quando arriva con l'anagrafe, non prima |

### Prossimo passo per corsia · al 14 settembre 2026, la Qualifica

**«RLS - LAVORATORE» non e un caso unico e non sta nella mansione** (AppSopralluoghi
`51be35d`, misurato sul file dopo il si di Francesco alla `070` e prima di scriverla).
Sta nella colonna **Qualifica** su **tre** righe — 1234, 3353, 3401 — e in nessuna la
colonna RLS e compilata. L'import ne vede una sola perche `persona.mansione` di la **non
e la colonna Mansione**: e la **prima non vuota** fra cinque sinonimi — `mansione`,
`ruolo`, `qualifica`, `profilo`, `profiloprofessionale` — **messa in maiuscolo**
(`anagraficheImport.ts:174` e `:867`, **letti da qui** prima di costruirci sopra). Sulla
3401 Mansione e vuota e passa la Qualifica; sulle altre due no. E il problema e piu
largo: delle 336 Qualifiche accanto a una Mansione piena, **38** contengono una parola
di ruolo e non sono lette, quasi tutte senza colonne di ruolo; **4** forme non sono nel
dizionario della `068`.

**La domanda che ci hanno fatto: la `0007` leggeva Mansione o anche Qualifica?** La
`0007` **non legge nessuna colonna**: e un dizionario di forme, e le sue 29 forme su 160
righe vengono dalla misura `8dab00a`, che dice «dentro la MANSIONE» **senza nominare la
colonna**. ~~**Dedotto, non misurato**~~ **Misurato un'ora dopo da AppSopralluoghi (`afbb88e`), e la deduzione regge**: solo Mansione. La misura riporta **RLS zero**, e la
3401 — Mansione vuota, Qualifica «RLS - LAVORATORE» — sarebbe comparsa sia leggendo la
Qualifica sia con il ripiego dell'import. La deduzione si chiude con una domanda sola a
chi ha il file e lo script: **la 3401 e fra le 160?**

**E tocca anche questa corsia, per una ragione diversa dalla gemella.** Il passo 01 di
`ebafe98` porta `mansione` d'origine in `rapporto_lavoro.mansione` com'e — ed e un campo
che mescola cinque colonne ed e gia maiuscolo. Non si reinterpreta in migrazione (una
riga d'origine non dice da quale colonna veniva, e ricostruirlo vorrebbe il file), ma
**si dichiara**: scritto in testa a `00_origine.sql`.

| chi | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **Francesco** | **se l'import legge anche la Qualifica quando la Mansione e piena.** Se no: la `070` porta una forma e produce una nomina. Se si: prima una modifica al codice, e la `070` porta piu forme. **Parere di AppOverall: si, ma come fonte distinta** — la colonna da cui viene il ruolo scritta sulla nomina, come la `068` fa gia per colonna e mansione, e non fusa nel campo `mansione` | la `070` nella forma che ne esce, e il rilancio dell'import | Il parere perche le 38 righe hanno la stessa forma delle 148 che hanno motivato la `0007`: un ruolo scritto **solo** in un campo libero, quasi sempre senza la colonna. Ma un campo in piu e piu nomine sui dati veri, e la decisione e sua |
| **AppSopralluoghi** | **D2 e la correzione di `riepiloga`**, e il deploy **aspetta la risposta sulla Qualifica**: se e si, la modifica va nello stesso deploy invece di farne due. Piu **la domanda sulla 3401 fra le 160** di `8dab00a` | la `070`, con la forma esatta mandata qui prima del commit | Perche un deploy in piu e un'altra finestra in cui il codice online non e quello verificato; e perche la deduzione sulla `0007` regge sulla loro misura, e solo loro possono chiuderla |
| **AppOverall** | **la regola per le 58 P.IVA non usabili**, in attesa del via di Francesco | la gemella della `070`, nella forma che esce dalla sua risposta; e se la Qualifica entra, **il commento della `0007` che dice «dentro il campo mansione» va corretto in una migrazione nuova** | La `0007` e merged e non si riscrive; e una descrizione della popolazione che smette di essere vera va ritirata dove qualcuno la legge, non lasciata |
| **AppFormazione** | invariato: **ferma per costruzione** | il giudizio sui 9 RLS quando l'anagrafe attraversa | Tre righe con un RLS scritto nella Qualifica sono materia per quando arrivano, non prima |

### Prossimo passo per corsia · al 14 settembre 2026, D2 su un ramo

**La domanda sulla `0007` e chiusa con una misura** (AppSopralluoghi `afbb88e`). Il seme
della `068` applicato alla sola colonna Mansione (Y) da **160 righe e 168 coppie**,
esattamente come `8dab00a`; applicato al campo come lo legge l'import ne da 167 e 175.
La 3401 non e fra le 160. Le **7 righe in piu** hanno Mansione vuota e il ruolo nella
Qualifica, e spiegano gli scarti dell'anteprima contro la `0007` — `datore_lavoro` 24
contro 22, `dirigente` dalla mansione 2 contro 1, `dl_rspp` 83 piu 1 escluso contro 81.
**I conti della `0007` restano veri per la popolazione che dichiarano**: era la grana,
non il dizionario.

**D2 e `riepiloga` sono fatti su un ramo** — `d2-report-componenti`, `6532500`, non su
`main` — e verificati da qui su `origin`: `main` e il deploy di `afbb88e` toccano ancora
solo `docs/STATO.md`. Il ramo cambia cinque file, e **quali** conta: D2 sta
nell'**Edge Function** (`genera-report/report-data.ts`, `report-html.ts`), `riepiloga`
nell'**app** (`nomineImport.ts`). `report:check` 11 su 11 sul ramo e 9 falliti su
`main`; `tsc` strict pulito; **Deno su quella macchina non c'e**, e il controllo con
Deno non e fatto.

**Ritiro l'attesa che avevo messo in `cf1d6df`, e la ragione e mia.** Avevo scritto «il
deploy aspetta la risposta sulla Qualifica», per non farne due, pensando D2 codice
dell'app. Non lo e: D2 va online **con l'Edge Function**, un canale che la Qualifica non
tocca. Dell'app resta solo `riepiloga`, che si vede al **prossimo** import — e il
prossimo import viene comunque dopo la decisione sulla Qualifica, quindi conviene che
giri su codice gia pubblicato. E una correzione verificata tenuta su un ramo ha un
costo che un deploy in piu non ha: **`main` smette di dire cosa e pronto**, e le corsie
leggono `main`.

| chi | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **Francesco** | **due decisioni, indipendenti.** (1) **Il si alla pubblicazione di D2 e `riepiloga`**, nell'ordine: merge del ramo su `main` (Vercel), poi l'Edge Function `genera-report` pubblicata **dal codice di `main`**. (2) La Qualifica, invariata | dopo la pubblicazione: **un report vero** su un sopralluogo con box e componenti, guardato, prima di dire D2 chiuso | La funzione in produzione deve essere codice che sta su `main`, mai su un ramo. E il report vero e la prova che il controllo con Deno non ha dato: il `check` prova la forma dei dati, non che la funzione giri nel suo ambiente |
| **AppSopralluoghi** | **dopo il si**: il merge, e la verifica del deploy di Vercel come per `12b1768` (stato su GitHub e bundle pubblico); nello `STATO.md` quale commit e online **per ciascuno dei due canali**, perche da oggi possono non coincidere | se la Qualifica e si: la modifica al codice e la `070`, mandata qui **prima del commit** | Due canali pubblicati in due momenti sono due verita su «cosa e online»: se lo `STATO.md` ne scrive una sola, l'altra si deduce, e si deduce male |
| **AppOverall** | **la regola per le 58 P.IVA non usabili**, in attesa del via di Francesco | la gemella della `070`. Se la `070` porta un valore nuovo per `nomina.origine`, **si guarda allora** se la `nomina` di qua ha il campo corrispondente: non si deduce adesso da un messaggio | A19: la forma arriva scritta prima del commit, e la verifica si fa su quella |
| **AppFormazione** | invariato: **ferma per costruzione** | il giudizio sui 9 RLS quando l'anagrafe attraversa | Niente di D2 tocca la formazione |

### Prossimo passo per corsia · al 14 settembre 2026, le due decisioni di Francesco

**Decise da Francesco il 14 settembre alle 11:49, in questa sessione, con le parole «1 e 2
ok»** sulle due voci numerate che gli erano state messe davanti:

1. **si alla pubblicazione di D2 e di `riepiloga`**, nell'ordine scritto in `94a5f07`:
   merge di `d2-report-componenti` su `main` (Vercel), poi l'Edge Function
   `genera-report` pubblicata dal codice di `main`;
2. **si alla Qualifica**, nella forma del parere di questa corsia: l'import legge anche
   la Qualifica quando la Mansione e piena, **come fonte distinta**, con la colonna
   d'origine scritta sulla nomina e non fusa nel campo `mansione`.

**La regola per le 58 P.IVA non era fra le due voci numerate, e resta in attesa.** Un
«ok» si legge su cio che nomina, non su tutto quello che stava nello stesso messaggio.

**Come arriva alla corsia.** Il si e riferito da qui. Per il merge e un ordine, e si
relaia. Per la pubblicazione dell'Edge Function e per la `070` la regola di questa
sezione vale per intero: **se la corsia lo legge come un permesso, lo chiede a
Francesco direttamente**, e fa bene — l'ha gia fatto AppFormazione l'11 settembre.
La `070` in produzione, comunque, la applica lui dall'SQL Editor.

**E una conseguenza della 2 che nessuno ha ancora scritto, e va guardata nella
proposta invece che dedotta qui.** Le nomine scritte stamattina includono le righe che
l'import ha preso dal campo `mansione` **quando quel campo conteneva la Qualifica** —
le 7 righe della misura di `afbb88e`, con Mansione vuota. Se la provenienza diventa una
fonte distinta, **su quelle nomine gia scritte la provenienza registrata e quella
sbagliata**. Quante sono davvero fra le 363 e cosa porta scritto il loro
`nomina.origine` lo dice il database, non questo documento: e la prima cosa che la
proposta della `070` deve contare, perche correggerle e una scrittura su dati veri.

| chi | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **Francesco** | **niente di nuovo da decidere su questi due punti**; se la corsia chiede conferma diretta sulla pubblicazione, e la regola che funziona | il report vero dopo la pubblicazione di D2, guardato; la `070` dall'SQL Editor quando arriva riletta; **il via sulla regola delle P.IVA** | La `070` resta sua da applicare, come la `069` |
| **AppSopralluoghi** | **la pubblicazione**: merge su `main`, verifica del deploy Vercel (stato GitHub e bundle), l'Edge Function dal codice di `main` — o chi la pubblica, se le credenziali sono di Francesco. Nello `STATO.md` il commit online **per ciascun canale** | **la Qualifica**: la modifica al codice e la `070` — forme nuove (4 non sono nel dizionario della `068`), il valore nuovo di `nomina.origine`, e **il conto delle nomine gia scritte con la provenienza da correggere** — mandata qui **prima del commit** | Prima si pubblica cio che e verificato, poi si scrive cio che e deciso: la modifica per la Qualifica fara un secondo deploy, ed e il costo accettato in `94a5f07` |
| **AppOverall** | **in attesa del via sulle P.IVA** — nessun carico dei clienti prima | la gemella della `070`, riletta sulla forma che arriva: dizionario **e**, se serve, la provenienza sulla `nomina` di qua | La gemella non si scrive su un messaggio: si scrive sulla stringa che la corsia manda prima del suo commit |
| **AppFormazione** | invariato: **ferma per costruzione** | il giudizio sui 9 RLS quando l'anagrafe attraversa | Le nomine RLS nuove dalla Qualifica arriveranno con l'anagrafe |

### Prossimo passo per corsia · al 14 settembre 2026, i clienti

**D2 e pubblicato** (AppSopralluoghi `72bfd70`), con il si di Francesco chiesto e dato
in quella sessione. **Verificato da qui**: il merge `e33efc2` contiene `6532500`, GitHub
registra il deploy di `e33efc2` in `success` alle 10:05:15 UTC, e dal `12b1768` il codice
cambia solo nei tre file del ramo. **Non verificabile da qui, e dichiarato come verifica
loro**: l'Edge Function `genera-report` in **v9**, riscaricata e identica a `e33efc2`, e
la v8 di prima identica a `main` — nessuna modifica dal Dashboard persa. D2 resta aperto
fino al report vero. **Le 363 nomine adesso sono viste** (198 dalla colonna, 165 dalla
mansione), e delle 7 righe con Mansione vuota **6 hanno una nomina con `origine =
mansione`** e la Qualifica in `origine_testo`: e il conto che la proposta della `070`
doveva fare, fatto prima.

**Il passo di AppOverall: i clienti, sulla regola decisa da Francesco il 14 settembre —
«ok» alla P.IVA inutilizzabile come assente, con la cella accanto.** Scritti la `0017`
e `supabase/migrazione-dati/01_clienti.sql`; il passo delle persone diventa `02`, e
passa da una tabella di corrispondenza. Provati su un cluster `initdb` poi cancellato,
con dati finti: **tutte le prove dei clienti passano** — sette rifiuti nei due versi,
tredici esiti, idempotenza, un'unita nuova che confluisce, il passo 02 sopra il passo
01, tre controlli finali fatti scattare — e **le prove delle persone passano ancora
tutte** con la corrispondenza in mezzo.

**Tre cose trovate scrivendolo, e la prima non e nostra.**

1. **La guardia sul segnaposto di `pivaUsabile` non scatta mai** (`anagraficheImport.ts:71`).
   Il commento dice «non e un segnaposto (tutte cifre uguali)», ~~il codice scrive
   `(\d){10}` — dieci cifre qualsiasi — che su undici cifre non corrisponde mai~~.
   **Corretto un'ora dopo da AppSopralluoghi (`5fb57ab`), e verificato qui con `od -c`:
   nel sorgente, dopo `(\d)`, c'era il byte di controllo 0x01 — un `\1` diventato
   invisibile — che il terminale da cui l'avevo letto mostrava come `(\d){10}`.**
   L'effetto misurato resta: la regex non corrispondeva mai.
   **Eseguita, non letta**: `00000000000` e `11111111111` sono usabili in produzione. E
   di la `partita_iva` non e unica, e l'import cerca i clienti **per P.IVA**: su un
   segnaposto aggancia «il primo candidato», che e esattamente l'avvelenamento che quel
   commento dice di evitare. Quanti clienti portano un segnaposto **non e misurato**.
   Qui la `0017` implementa la regola **come la intendono quel commento e la `0001`**, non
   come la esegue la funzione, e lo dichiara: e la prima funzione di questa migrazione
   che **non** e un port fedele.
2. **La `0013` non regge per le unita fuse.** Di la un cliente e un'unita e due
   stabilimenti con la stessa P.IVA sono due clienti (Ecodent); qui il cliente e la P.IVA
   (decisione 2, `0001`). Quindi l'unita assorbita **perde il suo uuid come cliente**, e
   le chiavi `anag:<uuid>:...` delle sue persone non agganciano piu niente. La `0017`
   aggiunge `cliente_origine`, che la `0013` aveva ritenuto superflua: aveva ragione per
   tutte le unita tranne quelle, ed e li che il conto «che fallisce in silenzio» sarebbe
   fallito. E il conto della `0013` sulle sedi `:legale` **non e piu zero per
   costruzione**: dice quante sedi non sono la sede legale del loro cliente.
3. **`N DIPENDENTI` va sulla sede, non sul cliente**: e un numero per unita, perche di
   la ogni riga di ElencoSedi e un cliente-unita. Portato in `sede.n_dipendenti_gestionale`
   **con l'etichetta nel commento** — quante persone gestiamo, non quanti lavoratori ha
   l'impresa — e mai sommato in migrazione.

E una forma di chiave che mancava: l'origine riconosce un cliente con P.IVA, **poi codice
fiscale**, poi ragione sociale, e la `0013` scriveva solo la prima e l'ultima. Aggiunta
`sedi:cf:`. **Non portati, e contati a ogni esecuzione**: ATECO (senza annata non si sa
leggere), livelli di rischio e di emergenza (qui sono una valutazione con motivazione),
contatti. **Mai misurati sui dati veri**: i rifiuti (f) — due clienti senza P.IVA con la
stessa ragione sociale o lo stesso codice fiscale — e (g) — due `werp_id` per una P.IVA.

| chi | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **Francesco** | il report vero di D2; la `070` e lo script delle 6 nomine quando arrivano riletti. **E una decisione nuova: se fare la prova generale sui dati veri** — le tre select di `00_origine.sql`, caricate su un cluster usa e getta **su questa macchina**, i passi 01 e 02 eseguiti, e tutto cancellato dopo. Scrive su un disco dati personali, anche se per un'ora e fuori dai repo: per questo e sua | se si: l'estrazione, che richiede la `service_role` e resta sua | Perche i passi sono scritti e provati su tutto cio che i dati finti sanno dire, e **i rifiuti mai misurati li puo far scattare solo l'archivio vero**. E la stessa ragione per cui il carico della `0006` ha trovato cio che due letture non avevano visto |
| **AppSopralluoghi** | **la Qualifica e la `070`**, con lo script delle 6 nomine, mandati qui prima del commit — invariato. **Piu il difetto di `pivaUsabile`**: prima la misura in sola lettura, quanti clienti portano un segnaposto e quanti lo condividono, col si di Francesco per leggere; poi la correzione, `(\d)\1{10}`, **nello stesso deploy della Qualifica** | un import delle anagrafiche **solo dopo la correzione** | Perche la correzione cambia come l'import riconosce i clienti al prossimo passaggio: un cliente oggi agganciato per segnaposto passerebbe al codice fiscale o al nome. Misurare prima e sapere chi si sposta; correggere senza misurare e spostarli al buio |
| **AppOverall** | **la gemella della `070`** quando arriva la forma; la prova generale, se Francesco la vuole | la migrazione delle nomine, sopra i passi 01 e 02 | Le nomine puntano a persone e sedi, e sono l'ultima cosa dell'anagrafe che attraversa |
| **AppFormazione** | invariato: **ferma per costruzione** | il giudizio sui 9 RLS quando l'anagrafe attraversa | Il numero che aspettano adesso ha un posto di qua, `sede.n_dipendenti_gestionale`, con la sua etichetta; non ha ancora un dato vero dentro |

### Prossimo passo per corsia · al 14 settembre 2026, la 070 riletta

**La proposta per la Qualifica e arrivata prima del commit**, come chiesto, ed e stata
riletta **sui file** e non sul messaggio: prima nel working tree del ramo, poi committata
(`d849073` su `origin/qualifica-fonte-distinta`). Tre parti:

- la `070`: `nomina.origine` accetta `qualifica`, e cinque forme nuove nel dizionario —
  non quattro: la quinta e «RSPP-SOCIO», che compare solo con la Mansione vuota;
- il codice: Mansione e Qualifica si leggono ciascuna dalla sua colonna, **solo
  nell'import delle nomine**. `anagraficheImport.ts` non cambia, quindi
  `persona.mansione` resta il campo misto dichiarato in `00_origine.sql`;
- lo script delle 6 nomine, per id e solo dove `origine` e ancora `mansione`.

**La gemella e la `0018`.** Le cinque stringhe sono **identiche byte per byte** a
`d849073`, confrontate dai due file, con le stesse posizioni e le stesse figure.
Caricata su un cluster usa e getta sopra la `0001`-`0017`: 34 testi, 182 righe, 39
parole, 10 regole; 190 asserzioni, **181 risolte e 9 no**; `datore_lavoro_rspp` resta
81. E il carico ha trovato la cosa che la lettura non vedeva: **la `0007` non conosceva
la parola `rls`**, perche nel campo mansione l'RLS non compariva mai — la prima forma
RLS avrebbe fatto fallire il vincolo. Allargato il vocabolario, aggiunta la regola col
suo motivo, e provato che il vincolo rifiuta ancora una parola inventata.

**Un rilievo sulla loro proposta, da chiudere prima che Francesco la lanci.** Lo script
delle 6 nomine finisce con `select count(*)` **dentro** `begin` … `commit`: se il conto
non dice 6, il `commit` avviene lo stesso, e il commento che dice «un numero diverso va
guardato prima di fidarsi» arriva quando la scrittura e gia fatta. Serve un controllo
che **annulli**: un blocco che solleva un errore se il conto non e 6, prima del
`commit`.

**`pivaUsabile` e riparata sul ramo** (`5fb57ab`), e verificata qui con `od -c`: su
`main` c'e `( \ d ) 001 { 1 0 }`, sul ramo `( \ d ) \ 1 { 1 0 }`. Per la corsia era
l'unico carattere di controllo nel loro repo; **in questo repo lo stesso byte e stato
cercato in 51 file con uno strumento provato prima su una sonda che lo conteneva:
nessuno**. La causa che avevo scritto era quella mostrata dal terminale, e la `0018`
corregge il commento della funzione dove si legge dal database.

**L'ordine dei passi su produzione, perche due di questi rifiutano se fatti prima:**

1. la misura dei segnaposto sui clienti, in sola lettura — **prima** del deploy, per
   sapere chi si sposta quando la guardia torna a funzionare;
2. la `070` dall'SQL Editor — **prima** del codice, che scrive `origine = 'qualifica'`
   e senza la `070` verrebbe rifiutato dal vincolo;
3. lo script delle 6 nomine, **con il controllo che annulla** — dopo la `070`, per lo
   stesso vincolo;
4. il merge del ramo su `main` e il deploy — Qualifica e `pivaUsabile` insieme;
5. l'anteprima delle nomine, con le attese scritte **prima** nello `STATO.md`: dalla
   Qualifica 36 proposte, 30 nuove per davvero, 4 da decidere;
6. la scrittura.

| chi | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **Francesco** | **tre si, nell'ordine sopra**: la lettura dei clienti per i segnaposto; la `070` e lo script, che applica lui; il merge e il deploy | l'anteprima e la scrittura delle nomine; **la domanda «Legale Rappresentante/RSPP»**; e resta aperta la prova generale sui dati veri | Due passi rifiutano se anticipati — il codice prima della `070`, lo script prima della `070` — e un rifiuto sui dati veri e un passo da rifare, non un danno. La misura prima del deploy e l'unica che, saltata, non si recupera |
| **AppSopralluoghi** | **lo script con il controllo che annulla**, poi la misura dei segnaposto col si di Francesco; nello `STATO.md` le attese dell'anteprima prima che venga fatta | il merge, la verifica del deploy come per `e33efc2`, e il commit online per canale | Un conteggio che si legge dopo il `commit` e una constatazione, non un controllo. E le attese scritte prima sono cio che permette di dire «torna» invece di «sembra giusto» |
| **AppOverall** | **fatta la `0018`** | la migrazione delle nomine sopra i passi 01 e 02; e se Francesco risponde su «Legale Rappresentante/RSPP», la gemella di quella risposta | Le nomine sono l'ultima cosa dell'anagrafe che attraversa, e adesso il dizionario di qua sa leggere tutte e due le colonne |
| **AppFormazione** | invariato: **ferma per costruzione** | il giudizio sui 9 RLS quando l'anagrafe attraversa | Sette RLS in piu dalla Qualifica sono materia per quando arrivano |

**Il rilievo sullo script e chiuso** (AppSopralluoghi `a82c6af`): dopo l'`update` un
blocco `do` conta le 6 nomine e solleva un errore prima del `commit` se non sono 6. La
corsia **non ha potuto eseguirlo** — non ha un database locale, e provarlo in
produzione vorrebbe dire scrivere — e l'ha detto. **Eseguito qui**, sul file di
`a82c6af` preso da `origin`, contro una tabella `nomina` finta con il vincolo della
`070` e senza, su un cluster usa e getta poi cancellato. Quattro casi, nei due versi:

| caso | esito |
|---|---|
| dopo la `070`, le 6 nomine ci sono | passa: 6 passano a `qualifica`, le altre righe intatte |
| rieseguito | passa, niente cambia |
| dopo la `070`, **ne manca una** | **errore**, e le 5 gia aggiornate **tornano indietro** |
| **prima** della `070` | **rifiutato dal vincolo**, niente scritto |

Provato con `psql`, e Francesco lo lancera dall'SQL Editor: la differenza non conta,
perche in PostgreSQL una transazione esplicita che va in errore scarta le istruzioni
successive, e un `commit` su una transazione abortita diventa un `rollback`.

### Prossimo passo per corsia · al 14 settembre 2026, i quattro si di Francesco

**Decisi da Francesco verso le 12:49 del 14 settembre, in questa sessione, con quattro
messaggi: «1. ok», «2. ok», «3. ok», «4. ok»**, sui quattro punti numerati del recap
che gli era stato messo davanti — che sono i passi dell'ordine su produzione scritto
sopra:

1. **la lettura dei clienti in produzione** per contare le P.IVA segnaposto — quanti
   portano come `partita_iva` undici cifre tutte uguali, e quanti condividono lo stesso
   valore. Sola lettura;
2. **la `070` dall'SQL Editor, poi lo script delle 6 nomine** (`a82c6af`, quello che
   annulla, eseguito qui nei due versi);
3. **il merge di `qualifica-fonte-distinta` su `main` e il deploy** — Qualifica e
   `pivaUsabile` insieme;
4. **l'anteprima e la scrittura delle nomine**, con le attese scritte prima: 36 proposte
   dalla Qualifica, 30 nuove, 4 da decidere.

**Quattro si non sono quattro passi da fare insieme.** L'ordine resta quello, e due
condizioni sono tecniche e non di prudenza: il codice e lo script **prima** della `070`
vengono rifiutati dal vincolo. Ogni passo parte quando il precedente e fatto **e
scritto nello `STATO.md` con cio che si e visto**.

| chi | passo | cosa si scrive dopo |
|---|---|---|
| **AppSopralluoghi**, col si di Francesco | 1. la misura | i due numeri, e quali clienti il prossimo import delle anagrafiche riconoscerebbe in un altro modo |
| **Francesco**, dall'SQL Editor | 2. la `070`, poi lo script | che la notice «Controllo superato» e comparsa, e i conti della `070` |
| **AppSopralluoghi**, col si di Francesco | 3. merge e deploy | la verifica per canale, come per `e33efc2`: stato GitHub e bundle pubblico |
| **Francesco**, dal back-office | 4. anteprima, poi scrittura | l'anteprima contro le attese — 36, 30, 4 — **prima** di premere Scrivi |

**Due precisazioni, perche un si largo e il posto dove si nasconde un passo in piu.**

- **La misura non blocca il deploy, ma blocca il prossimo import delle anagrafiche.**
  Riparare la guardia non sposta nessun cliente: cambia come l'import li riconoscera
  la prossima volta. Quindi il 3 puo seguire il 1 qualunque cosa il 1 trovi, e l'import
  delle anagrafiche — che nessuno di questi quattro si autorizza — si decide sulla misura.
- **Per le scritture su produzione la regola di questa sezione vale com'e.** La `070`,
  lo script e la scrittura delle nomine li esegue Francesco, quindi non c'e niente da
  relaiare; per la misura e il merge il si e riferito da qui, e se la corsia lo chiede a
  Francesco direttamente — come ha fatto per D2 — fa bene.

**Restano aperte, e nessuno dei quattro si le chiude:** «Legale Rappresentante/RSPP»,
il report vero che chiude D2, e la prova generale della migrazione sui dati veri.

**La `070` e applicata in produzione** (AppSopralluoghi `c4b3a42`), da Francesco
dall'SQL Editor, con il testo del ramo. Il controllo in sola lettura subito dopo, come
lo riporta lo `STATO.md` su `main`: il vincolo `nomina_origine_nota` contiene
`qualifica`, `ruolo_testo` 32 (27 + 5), `ruolo_testo_figura` 37 (32 + 5), le cinque forme
nuove presenti. **Verificato da qui** che il codice online non e cambiato: da `e33efc2` a
`main` nessun file sotto `src` o `supabase/functions`.

**L'ordine e cambiato, e non fa danno.** La `070` e arrivata prima della misura dei
segnaposto, che era il passo 1. Ma la condizione vera sulla misura era **prima del
deploy**, non prima della `070` — le due cose non si toccano: una e sui clienti, l'altra
sulle nomine — e quella condizione regge ancora. Scritto perche un ordine cambiato senza
dirlo e la forma in cui un ordine smette di contare.

**E la corsia ha trovato una finestra che l'ordine non diceva.** Fra la `070` e il deploy
**non si importano nomine**: il codice online, con la Mansione vuota, legge ancora la
Qualifica come mansione, e adesso che il dizionario conosce le forme nuove scriverebbe
«RLS - LAVORATORE» (riga 3401) e «RSPP-SOCIO» con `origine = 'mansione'` — cioe
esattamente il difetto che lo script delle 6 nomine sta per correggere, rifatto su due
righe nuove. **La finestra si chiude col deploy, e vale anche per Francesco.**

**Una riga dello `STATO.md` di la dice ancora «La `070` (non applicata)»** (riga 370 su
`c4b3a42`), mentre la 418 riporta il vincolo applicato. E la forma del 13 settembre —
il file che dice una cosa e il database un'altra — in piccolo, e va chiusa li.

**Dal file `ElencoSedi.xlsx`, non dalla produzione**: 55 partite IVA segnaposto su 849
righe (53 volte `00000000000`, 2 volte `11111111111`); fra le 619 attive, **40, tutte
`00000000000`**. E il numero che la guardia muta ha lasciato passare **nel file**; quanti
di quei 40 stanno davvero nel database, e se condividono il cliente, lo dice la misura.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **lo script delle 6 nomine** (`a82c6af`), e controllare che compaia «Controllo superato» | il si diretto alla corsia per la misura e il merge, se lo chiede; poi l'anteprima contro 36 / 30 / 4. **Nessun import di nomine fino al deploy** |
| **AppSopralluoghi** | correggere la riga 370 dello `STATO.md`; la misura dei segnaposto in produzione col si di Francesco | il merge e il deploy, con la verifica per canale — e da li la finestra e chiusa |
| **AppOverall** | nulla di nuovo | la migrazione delle nomine sopra i passi 01 e 02 |
| **AppFormazione** | invariato: **ferma per costruzione** | il giudizio sui 9 RLS quando l'anagrafe attraversa |

**Il passo 2 e chiuso: lo script delle 6 nomine e lanciato** da Francesco dopo la `070`
(AppSopralluoghi `81add8d`). Il controllo in sola lettura sui 6 id, subito dopo, da una
riga sola: `qualifica`, 6. **La notice «Controllo superato» non e stata riferita**, e la
corsia l'ha scritto cosi invece di darla per vista. Il conto basta lo stesso, ed e un
ragionamento e non una speranza: prima dello script le 6 erano `mansione` (lette il 14),
e se il blocco avesse sollevato l'errore l'`update` sarebbe tornato indietro con lui —
**sei `qualifica` dopo vogliono dire che la transazione e arrivata al `commit`**. E la riga
«non applicata» dello `STATO.md` e corretta (`f900099`). Verificato da qui che il codice
online e ancora quello di `e33efc2`.

**Adesso**: la misura dei segnaposto in produzione, poi merge e deploy — AppSopralluoghi,
con il si di Francesco dato **direttamente** in quella sessione, come la corsia ha scelto.
**La finestra resta aperta fino al deploy: nessun import delle nomine.**

**I passi 1 e 3 sono chiusi, e la finestra con loro** (AppSopralluoghi `944fa84` e
`9123f18`), con il si dato da Francesco direttamente in quella sessione.

**La misura, in sola lettura sulla produzione**: 619 clienti; **40** con `partita_iva`
di undici cifre tutte uguali, tutti `00000000000`; 22 senza P.IVA; 13 valori condivisi
da piu clienti, su 64 clienti — il segnaposto (40) e **12 P.IVA vere su 24 clienti**,
cioe aziende con piu sedi. **I 40 col segnaposto hanno zero persone collegate.** E
**con la correzione non si sposta nessuno**: le 40 righe attive di ElencoSedi col
segnaposto trovano ciascuna esattamente un cliente per ragione sociale, nessuna per
codice fiscale, nessuna nuova. La corsia ha scartato e rifatto una prima versione del
confronto che aveva preso la colonna sbagliata — prima di scriverla.

**Il deploy, verificato da qui**: il merge `6f936df` contiene tutto il ramo; GitHub
registra `944fa84` in `success` alle 11:05:03 UTC; dal codice di D2 cambiano solo i file
della Qualifica e `anagraficheImport.ts`, e **niente sotto `supabase/functions`**, quindi
l'Edge Function resta la v9. E `od -c` su `main` mostra `( \ d ) \ 1 { 1 0 }`: il byte
0x01 non c'e piu.

**E la misura dice una cosa alla migrazione dei clienti di questa corsia, dedotta e non
misurata.** Le fusioni per P.IVA del passo 01 non sono «il caso Ecodent»: sono **12**,
quante le aziende con piu sedi. Coi numeri di oggi il passo 01 darebbe circa **607
clienti** — 557 con una P.IVA usabile, meno le 12 unita assorbite, piu i 62 senza — e la
riserva e che la misura non dice se esistano altre P.IVA non usabili oltre al
segnaposto. Due cose invece rassicurano sui rifiuti mai misurati: i 40 col segnaposto
hanno **ragioni sociali uniche** — il rifiuto (f) non dovrebbe scattare su di loro — e
**nessuna persona**, quindi nessun rapporto da agganciare. Il rifiuto (g), due `werp_id`
per una P.IVA, ha adesso **12 posti precisi** dove guardare.

**Adesso**: Francesco, l'anteprima delle nomine contro le attese **36 / 30 / 4**, prima di
premere Scrivi. Poi restano aperte «Legale Rappresentante/RSPP», il report vero di D2 e
la prova generale.

**L'anteprima e vista, e ogni scarto dalle attese ha la sua riga** (AppSopralluoghi
`bed6d63`), da Francesco sul codice di `944fa84`, senza scrivere. **Ricontati da qui
sui numeri che la corsia stessa aveva dato prima**, non presi sul messaggio:

| conto | anteprima | atteso | lo scarto |
|---|---:|---:|---|
| da creare | **29**, tutte dalla qualifica | 30 | la **654** ha un codice fiscale non valido e la persona non e in archivio. Per figura 19 + 7 + 3: preposto 20 − 1; rls 4 «RLS» + 2 «RLS - LAVORATORE» + la 3401; dirigente 3 |
| gia in organigramma | **363** | 363 | le 6 corrette dallo script adesso arrivano dalla qualifica, contate una volta |
| da decidere | **154** | — | 153 + 350 + 3397 − 3401: la 3401 adesso si risolve, e la 2248 era gia fra le 153 |
| persone non trovate | **6** | 4 | piu la 654 e la 748 |

La corsia ha corretto **due suoi numeri** detti a Francesco prima dell'anteprima — 369 e
157 — ed e scritto nello `STATO.md` come errori, con la ragione. **Scrivere e sicuro**:
nessuno degli scarti produce una nomina sbagliata, tutti ne producono **una in meno**.
Attesa della scrittura: «29 nomine scritte», e alla rilettura 0 da creare e 154 da
decidere.

**E una domanda che la corsia ha scritto «senza trarne conclusioni», e che da qui
diventa una misura assegnata.** La **748** (Chiaramonte Nicola, NEW METROPOL) e una
persona **scritta nel foglio**, e il suo cliente e fra i **40 con `00000000000`**, che in
produzione hanno **zero persone tutti**. CAVOUR SRL (1931) e nello stesso gruppo. Se il
foglio porta persone per quei clienti e il database no, **l'import delle anagrafiche del
9 settembre le ha lasciate fuori** — ed e plausibile per costruzione: la guardia muta
lasciava passare il segnaposto come chiave, e 40 clienti con la stessa «P.IVA» sono
esattamente il caso in cui l'abbinamento non sa dove mettere una riga. **Non e un fatto:
e un'ipotesi che guarda nel posto giusto** (A21), e conta per tre ragioni — l'anagrafe
avrebbe un buco che nessun conto ha visto, **N = 3.415 sarebbe basso**, e le persone di
quei clienti non avrebbero ne organigramma ne formazione dovuta.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **la scrittura delle 29 nomine**, e riferire il messaggio verde | il report vero di D2; «Legale Rappresentante/RSPP»; la prova generale |
| **AppSopralluoghi** | registrare la scrittura; poi **la misura sui 40 clienti col segnaposto, prima sul file e senza database**: quante righe persona dei fogli di `ExportExcel (4)` — e di ogni export persone che ci sia su disco — appartengono a quei 40 clienti per ragione sociale, e quante hanno un codice fiscale | **se il numero non e zero**: col si di Francesco per leggere, quanti di quei codici fiscali esistono in produzione **sotto un altro cliente** — che sarebbe l'abbinamento sbagliato — e quanti **da nessuna parte**, che sarebbe il buco |
| **AppOverall** | nulla di nuovo | se il buco c'e, **N cambia** e la migrazione delle persone lo deve dire: il 3.415 e un conto su cio che il database ha, e un buco nel database non si vede da un conto sul database |
| **AppFormazione** | invariato: **ferma per costruzione** | persone mai importate sarebbero formazione dovuta che nessuno calcola: materia loro, quando e se il buco e misurato |

### Prossimo passo per corsia · al 14 settembre 2026, le 53 persone che non ci sono

**Le 29 nomine sono scritte** (AppSopralluoghi `56e5071`): Francesco riferisce «29 nomine
scritte. Rilettura: 0 da creare, 154 da decidere» — **visto**, ed e esattamente l'atteso.
La Qualifica e chiusa: resta aperta solo «Legale Rappresentante/RSPP».

**E l'ipotesi sui 40 clienti col segnaposto e confermata dalla misura.** Nello stesso
commit, verificato da qui su `origin`:

- **sui file, senza database**: le righe persona dei 40 clienti, per ragione sociale
  normalizzata, sono 55 in tutti e quattro i fogli di `ExportExcel (4)`, **54 persone
  distinte su 36 clienti**, tutte con codice fiscale — lo stesso numero in
  `ExportExcelDipendenti` e `ExportExcel (5)`; CorsiFatti 64 righe e 48 persone,
  CorsiScadenze 56 righe e 48 persone;
- **in produzione, col si di Francesco per quella lettura**: dei 54 codici fiscali,
  **0** sotto il cliente giusto, **1** sotto un altro cliente, **53 da nessuna parte**, su
  35 clienti.

**Quindi l'import delle anagrafiche del 9 settembre ha lasciato fuori 53 persone**, e
nessun conto sul database poteva vederlo: un buco nel database non si vede contando il
database. **N = 3.415 e basso di almeno 53.** Queste persone non hanno organigramma ne
formazione dovuta, e le loro nomine dei ruoli sicurezza non potevano essere scritte. **La
corsia ha misurato e si e fermata**: rimetterle dentro e un import sulla produzione, e
spetta a Francesco. Ha fatto bene due volte — anche a scrivere come **aperto** l'unico
codice fiscale trovato altrove invece di sceglierne il senso.

**Il caso aperto va deciso prima di scrivere, non dopo.** Quella persona nel foglio sta
sotto un cliente che si chiama **«XXXXXXXXXXXX»**, e in produzione sotto *Rittal RCS
Cooling Solutions S.r.l.*, che ha una P.IVA vera. Un segnaposto come **ragione sociale**,
non solo come P.IVA. Reimportando, la persona nascerebbe una seconda volta sotto quel
cliente: e una scheda doppia se e la stessa persona, un errore del gestionale se il
cliente non esiste.

**L'ordine del recupero, e perche prima c'e una misura in piu.**

1. **Allargare la misura prima di importare.** I 40 clienti col segnaposto sono il buco
   **trovato**, non necessariamente l'unico: la domanda che chiude la classe e **per ogni
   cliente, quante persone nel file e quante in produzione**. Sola lettura, un conto per
   cliente. Se escono altri clienti con persone nel file e zero — o molte meno — di la,
   entrano nello **stesso** import invece di un secondo. E la forma della sezione 8: non
   dichiarare chiuso un buco prima di aver guardato dove altro poteva essere.
2. **Il caso «XXXXXXXXXXXX»**: quale cliente di produzione porta quel nome, e cosa ha
   sotto; poi la decisione di Francesco.
3. **L'import delle anagrafiche, con le attese scritte prima**: le persone nuove attese
   (53 piu cio che il punto 1 trova, meno cio che il punto 2 decide), e **nessun campo
   sovrascritto** sulle altre — l'import riempie solo i vuoti, ed e l'anteprima a dirlo.
4. **L'import delle nomine**, sulle righe di quelle persone, con le attese contate sul
   foglio prima.
5. **L'import della formazione** per quelle persone, con le attese contate su CorsiFatti
   prima.

L'ordine e quello delle chiavi: la nomina e la formazione puntano a una persona che deve
gia esserci.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **il si alla lettura del punto 1**, e la decisione sul caso «XXXXXXXXXXXX» quando la corsia la porta | anteprima e scrittura dei punti 3, 4 e 5, ciascuna contro le sue attese |
| **AppSopralluoghi** | **i punti 1 e 2**, e le attese del punto 3 scritte nello `STATO.md` prima dell'anteprima | le attese dei punti 4 e 5, una alla volta |
| **AppOverall** | nulla da scrivere: il passo 02 prende il numero di righe **all'estrazione**, non dal 3.415 | **la prova generale sui dati veri acquista valore dopo il recupero, non prima**: farla adesso misurerebbe un'anagrafe che sappiamo bucata |
| **AppFormazione** | invariato: **ferma per costruzione** | **una domanda non assegnata**: le 48 persone di CorsiFatti stanno nel loro database, che importa per ragione sociale e non passa dalla guardia? Si chiede quando il recupero e fatto, per confrontare due anagrafi e non una bucata |

### Prossimo passo per corsia · al 14 settembre 2026, 75 persone e cinque doppioni

**La misura allargata ha trovato di piu, ed e la ragione per cui si fa prima di
importare** (AppSopralluoghi `c296dfe`, `960f418`, col si di Francesco per ciascuna
lettura). Il foglio Ruoli SSL ha 479 societa, tutte con un cliente omonimo in
produzione. **I codici fiscali che non esistono sotto nessun cliente sono 75, non 53**:
53 sui 35 clienti col segnaposto, e **22 su altri 5 clienti** — IGEA 12, LA TORRE 5,
IL MAGNIFICO 2, PROGETTO EMERA 2, GIARDINAGGIO ADAMI 1 — piu 2 righe senza codice
fiscale. Un import fatto sulle 53 ne avrebbe richiesto un secondo.

**E quei cinque hanno la stessa forma: due clienti per un'azienda**, creati tutti
dall'import del 9 settembre alle 10:30, tutti con zero persone:

| cliente | i due in produzione | persone nel file, per sede |
|---|---|---|
| GIARDINAGGIO ADAMI | due righe identiche, stessa P.IVA, nessun indirizzo | 1, Via Valle 63 |
| LA TORRE | identiche salvo una virgola nell'indirizzo | 6, Via Trezzolano 4 |
| PROGETTO EMERA | una con l'indirizzo e senza P.IVA, l'altra il contrario | 2, Via del Lavoro 16 |
| IGEA | stessa P.IVA, Via Sorte 48 e Via Michelangelo 7 | **13, tutte Via Sorte 48** |
| IL MAGNIFICO | stessa P.IVA, scritti diversamente | 2, Corso Porta Nuova 131 — **nessuno dei due indirizzi** |

**Due correzioni, una per verso.**

- **Le attese scritte dalla corsia erano al rovescio**, e l'ha corretto con la versione
  sbagliata citata come tale: i 75 sono codici fiscali che non esistono **da nessuna
  parte**, e Zimmari (riga 3473) esiste sotto Rittal — quindi l'anteprima dira **75 se la
  3473 e esclusa, 76 se non lo e**, piu le 2 senza codice fiscale.
- **La mia ipotesi su IL MAGNIFICO era sbagliata**, ed era scritta come ipotesi. Avevo
  detto che la P.IVA portava fra i candidati tutti e due i clienti. **Per le persone no**:
  nessun file persone ha una colonna P.IVA, quindi i candidati vengono **solo dal nome**
  — l'ha letto la corsia nel codice. Cosi IGEA, LA TORRE, EMERA e ADAMI sono spiegati
  (stesso nome, due candidati, la sede non sceglie); IL MAGNIFICO no, perche i due nomi
  si normalizzano diversi, e **resta non spiegato**: il 9 settembre girava un codice
  precedente, e un import non si ricostruisce. L'osservazione vale per l'import dei
  **clienti**, dove la P.IVA c'e.

**Il caso della 3473 e chiuso come fatto**: Zimmari Luigino e nel file due volte con lo
stesso codice fiscale, sotto «XXXXXXXXXXXX» e sotto Rittal; la scheda in produzione viene
dalla riga di Rittal. **Non e un abbinamento sbagliato: e una riga doppia del gestionale,
sotto un cliente che si chiama segnaposto.** La proposta della corsia — escluderla — e
quella giusta.

**Le raccomandazioni di questa corsia sulle decisioni di Francesco**, scritte come
raccomandazioni e tutte dopo la misura 2a — cosa punta, in produzione, a ciascuno dei
10 clienti delle coppie e a «XXXXXXXXXXXX»: unire o togliere un cliente sposta sedi,
incarichi, sopralluoghi, e «0 persone» non vuol dire «niente collegato».

- **ADAMI e LA TORRE**: doppioni veri, **si uniscono** tenendo quello a cui punta di piu.
- **EMERA**: **si uniscono in uno che porti tutte e due le meta** — la P.IVA dell'uno e
  l'indirizzo dell'altro.
- **IGEA**: le 13 persone vanno sul cliente di **Via Sorte 48**, che e un fatto del file;
  se Via Michelangelo 7 sia una seconda sede vera lo sa Francesco, e **finche non lo dice
  non si unisce e non si toglie**.
- **IL MAGNIFICO**: stessa P.IVA, **si uniscono**; l'indirizzo delle persone e un terzo,
  e quale sia quello giusto e una domanda sua.
- **«XXXXXXXXXXXX»**: la riga 3473 **esclusa**; il cliente stesso — segnaposto come nome,
  segnaposto come P.IVA, una sede e nessuna persona — e un candidato a essere tolto,
  **dopo** la misura 2a.

**E una cosa per la migrazione di questa corsia, gia fatta.** Fra le cinque coppie, il
passo 01 fonde da se quelle con la stessa P.IVA usabile. **EMERA no**: una P.IVA e
un'assenza, stesso nome normalizzato, e sarebbero passati come due clienti senza che
niente lo dicesse. Il passo 01 adesso **li conta** — «possibili doppioni non fusi»: clienti
senza P.IVA usabile con la ragione sociale di uno che ce l'ha — **e non li fonde**, perche
fondere per nome e la mossa che questo repo non fa. Provato: il conto da 0 sull'origine
finta e 1 con un doppione aggiunto, e tutte le prove dei clienti e delle persone
passano ancora sopra la `0001`-`0018`. Il posto giusto per chiudere il doppione resta
l'origine, prima dell'estrazione.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | il si alla lettura 2a, quando la corsia la chiede | **le decisioni sulle cinque coppie e su «XXXXXXXXXXXX»**, con le raccomandazioni qui sopra davanti; poi le scritture di pulizia, e solo dopo l'anteprima dell'import delle anagrafiche contro **75 o 76, piu 2** |
| **AppSopralluoghi** | **la misura 2a**, con l'elenco delle tabelle ricavato dalle migrazioni e non dalla memoria | le attese aggiornate dopo le decisioni, perche unire un cliente cambia dove vanno le persone ma non quante sono |
| **AppOverall** | fatto il conto dei doppioni non fusi | la prova generale, dopo il recupero |
| **AppFormazione** | invariato: **ferma per costruzione** | la domanda sulle 48 persone di CorsiFatti, dopo il recupero |

**La misura 2a e fatta** (AppSopralluoghi `459517d`), col si di Francesco per quella
lettura. Le tabelle **dal catalogo e non dalla memoria**: 14 chiavi esterne in
`pg_constraint`, 9 verso `cliente` e 5 verso `sede`, piu i sopralluoghi contati
attraverso gli incarichi. **Per tutti e 11 i clienti — le cinque coppie e
«XXXXXXXXXXXX» — una sede e nient'altro**: zero incarichi, sopralluoghi, adempimenti,
azioni per responsabile, componenti, revisioni e conferme dell'organigramma, persone.
Creati tutti dall'import del 9 settembre fra le 10:30 e le 10:31.

**Regge per le chiavi esterne, e non ancora per tutto.** Il catalogo vede i riferimenti
che hanno un vincolo; **non vede quelli scritti dentro un testo**, e nel codice di la ce
n'e almeno uno, verificato da qui: la `066` e `cosedafare.ts:166` danno alle azioni la
chiave **`cliente-ateco:<cliente_id>`** — un'azione per un cliente senza ATECO, che e
proprio il caso probabile di clienti nati da un import senza quella colonna. Un'azione
cosi punta al cliente **senza chiave esterna**: unire o togliere il cliente la lascia
orfana, e nessun vincolo protesta. Il secondo candidato sono gli **abbinamenti** che gli
import delle anagrafiche e delle nomine salvano fra una chiave del file e un
`cliente_id` (`ImportAnagrafiche.tsx:80`, `ImportNomine.tsx:55`): **da qui non si vede
dove siano salvati**, e va guardato, non dedotto.

E la forma di A12 applicata a una misura invece che a un test: uno strumento che non puo
vedere una cosa risponde «zero» anche quando la cosa c'e.

| chi | adesso | poi |
|---|---|---|
| **AppSopralluoghi** | **l'ultima misura prima dello script**, in sola lettura col si di Francesco: le azioni con `chiave` uguale a `cliente-ateco:` piu uno degli 11 id, e — per non fermarsi a quello che si ricorda — ogni colonna di testo, `jsonb` o `uuid` **senza** chiave esterna che contenga uno degli 11 id; e dove stanno gli abbinamenti salvati | lo script di pulizia **con il controllo che annulla**, che copra anche cio che la misura trova; lo lancia Francesco |
| **Francesco** | le decisioni sulle cinque coppie e su «XXXXXXXXXXXX», con le raccomandazioni di `4c12034` e con questa misura davanti | lo script di pulizia; poi l'anteprima dell'import delle anagrafiche contro le attese riscritte |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | invariato: **ferma per costruzione** | la domanda sulle 48 persone di CorsiFatti, dopo il recupero |

**L'ultima misura da zero su tutti e tre i punti** (AppSopralluoghi, col si di
Francesco): 0 azioni `cliente-ateco` sugli 11 clienti — e 0 in tutto il database;
**190 colonne** di testo, JSON, `uuid` e array **senza** chiave esterna, in 36 tabelle,
prese dal catalogo, e **0 righe** con uno degli 11 id dei clienti o degli 11 delle loro
sedi; e gli abbinamenti degli import vivono **solo nello stato della pagina**, nessuna
tabella e nessun `localStorage`. **Uno zero misurato, non un'assenza di misura**: le
raccomandazioni di `4c12034` reggono senza costi nascosti.

**Le decisioni di Francesco sui doppioni, date in quella sessione**: ADAMI, LA TORRE,
EMERA e IL MAGNIFICO **si uniscono**; **IGEA resta con due clienti**, perche Via
Michelangelo 7 e una sede vera, e le 13 persone vanno su quello di Via Sorte 48; IL
MAGNIFICO tiene l'indirizzo di Largo Pescheria Vecchia 10; **la 3473 si esclude e il
cliente «XXXXXXXXXXXX» si toglie**. Una scelta e della corsia, ed e dichiarata: per IL
MAGNIFICO Francesco ha scelto l'**indirizzo**, non la riga, e si tiene la riga col nome
uguale al file persone, perche l'altra l'import delle persone non la riconoscerebbe.

**Lo script di pulizia, riletto e eseguito qui prima che lo lanci Francesco.**
`unisci_clienti_doppi.sql` la corsia l'ha mandato prima del commit, ed e stato committato
(`32a68b7`) mentre la prova girava: **la versione committata e identica, stessa impronta
sha256, al working tree da cui e stata presa la copia provata**. Ricontrolla
dal catalogo al momento del lancio ogni chiave esterna verso cliente e sede e le azioni
`cliente-ateco`, riempie **solo i campi vuoti** del cliente tenuto, toglie i 5 clienti con le
loro sedi per cascata, e annulla se il risultato non torna. Eseguito su un cluster usa e
getta, con uno schema minimo che porta i vincoli che contano — sede in cascata, `werp_id`
unico, persona, incarico, sopralluogo, azione — e gli 11 id veri, piu IGEA e un cliente
estraneo con le loro persone. Sei casi, ognuno su un database pulito:

| caso | esito |
|---|---|
| tutto pulito | **passa**: 12 clienti diventano 7, EMERA prende la P.IVA, IL MAGNIFICO l'indirizzo, IGEA e le persone intatte |
| rieseguito | errore «trovati 0», niente scritto |
| una persona su un cliente da togliere | **errore, niente scritto** — la persona non se ne va per cascata |
| un sopralluogo sulla sede di un cliente da togliere | errore, niente scritto |
| un'azione `cliente-ateco` su un cliente da togliere | errore, niente scritto |
| **`werp_id` solo sul cliente da togliere** | **violazione del vincolo `unique`**: annulla e non scrive niente, ma **lo script non puo finire** |

**L'ultimo caso non fa danno, e blocca.** Il passo che riempie i campi vuoti copia anche
`werp_id` nel cliente tenuto **mentre quello da togliere esiste ancora** con lo stesso
valore, e `cliente.werp_id` di la e unico. Se sui dati veri nessuno dei 5 da togliere ha un
`werp_id`, lo script passa; se uno ce l'ha e il suo tenuto no, Francesco vede un errore
invece della notice. **La correzione e di forma, non di merito**: copiare i clienti da
togliere in una tabella temporanea, cancellarli, e poi riempire i vuoti dalla copia — cosi
nessun vincolo di unicita puo collidere, ne `werp_id` ne uno che si aggiunga domani. E un
controllo che manca: la notice finale dice «IGEA intatta», e nessuna riga lo verifica.

| chi | adesso | poi |
|---|---|---|
| **AppSopralluoghi** | **la correzione sull'ordine** — copia, cancella, riempi — e il controllo su IGEA; poi rimandarlo qui, e lo si riesegue sugli stessi sei casi | il commit, e le attese dell'import delle anagrafiche riscritte: 75 piu 2, un solo candidato per ADAMI, LA TORRE, EMERA e IL MAGNIFICO, IGEA a mano su Via Sorte 48, la 3473 fuori |
| **Francesco** | niente fino allo script corretto e riprovato | lo script dall'SQL Editor; poi anteprima e scrittura dell'import delle anagrafiche contro le attese |
| **AppOverall** | riprovare lo script corretto | la prova generale, dopo il recupero |
| **AppFormazione** | invariato: **ferma per costruzione** | la domanda sulle 48 persone di CorsiFatti, dopo il recupero |

**Lo script corretto e riprovato, e adesso passa dove deve e annulla dove deve**
(AppSopralluoghi `10cd71f`). La correzione e quella di forma: i clienti da togliere si
copiano in una tabella temporanea, si cancellano, e i campi vuoti dei tenuti si riempiono
**dalla copia**; piu un controllo che i due clienti IGEA ci siano ancora dopo. Rieseguito
qui sulla versione di `origin/main` — identica al working tree della corsia a meno dei
fini riga — con lo stesso schema minimo e gli id veri, **IGEA compresa con i suoi uuid
completi**, e con un caso in piu, perche un controllo nuovo va visto fallire:

| caso | esito |
|---|---|
| tutto pulito | **passa**: 12 clienti diventano 7, EMERA con la P.IVA, IL MAGNIFICO con l'indirizzo, IGEA e le persone intatte |
| rieseguito | errore «trovati 0», niente scritto |
| una persona su un cliente da togliere | errore, niente scritto |
| un sopralluogo sulla sede di un cliente da togliere | errore, niente scritto |
| un'azione `cliente-ateco` su un cliente da togliere | errore, niente scritto |
| **`werp_id` solo sul cliente da togliere** | **adesso passa**: il tenuto si ritrova il `werp_id`, «Controllo superato» |
| **un cliente IGEA che manca prima del lancio** | **errore «trovati 1», annullato** — il controllo nuovo scatta |

**Il rilievo e chiuso, e lo script si puo lanciare.**

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **lo script dall'SQL Editor**, e riferire se compare «Controllo superato» | l'anteprima dell'import delle anagrafiche contro le attese — 75 persone nuove piu 2 senza codice fiscale; un solo candidato per ADAMI, LA TORRE, EMERA e IL MAGNIFICO; IGEA a mano su Via Sorte 48; il gruppo «XXXXXXXXXXXX» fuori — e poi la scrittura |
| **AppSopralluoghi** | registrare il lancio; poi le attese degli import delle nomine e della formazione per le persone recuperate, contate sui fogli **prima** | — |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | invariato: **ferma per costruzione** | la domanda sulle 48 persone di CorsiFatti, dopo il recupero |

**La pulizia dei clienti doppi e fatta** (AppSopralluoghi `a0b7a53`). Francesco ha
lanciato `10cd71f` dall'SQL Editor, e il database letto subito dopo, in sola lettura, dice
esattamente l'atteso: **614 clienti**, cioe 619 − 5; zero dei 5 tolti e delle loro sedi;
i 4 tenuti presenti; **IGEA con due clienti, intatti**, ultima modifica il 9 settembre;
EMERA con la P.IVA 09318332023 e l'indirizzo; IL MAGNIFICO con Largo Pescheria Vecchia 10,
Verona. **I 4 clienti modificati oggi portano tutti la stessa ora, 12:11:47.548 UTC** — e
siccome l'`updated_at` prende l'ora d'inizio della transazione, e **una transazione sola**,
arrivata in fondo.

**Ma a Francesco e arrivato un errore**: `42P01: relation "_coppie" does not exist`. Non
viene da quel lancio: una seconda esecuzione intera avrebbe dato «trovati 0», e un
`_coppie` che non esiste vuol dire un lancio in cui le tabelle temporanee **non erano state
create nella stessa sessione** — una parte selezionata dello script, o le istruzioni
eseguite una per una. **Quel lancio non ha scritto niente, e lo si sa dal database, non
dall'errore**: lo stato letto dopo e l'atteso fino all'ultima colonna controllata. Come sia
stato lanciato **resta non spiegato**, e la corsia l'ha scritto cosi.

**E la corsia si e corretta da sola prima di fare danni.** Leggendo l'errore aveva
ipotizzato che l'editor non tenesse la transazione e aveva riscritto lo script in un blocco
unico; **la lettura del database ha smentito l'ipotesi prima del commit**, e la riscrittura
e scartata. Nel repo resta `10cd71f`, cioe il testo provato qui sui sette casi. **Lo script
non va rilanciato.**

**La regola che ne esce, per ogni script che Francesco lancia dall'SQL Editor.** La prova
che uno script ha fatto quello che doveva **e la lettura del database dopo**, non la notice
e non l'errore: un lancio parziale produce un messaggio che non riguarda lo stato, e un
lancio intero puo non mostrare la sua notice. Quindi ogni script di questo genere arriva
con **la sua query di verifica in sola lettura scritta prima**, e in testa l'avvertenza di
incollarlo e lanciarlo **tutto insieme**. Oggi la verifica l'ha fatta la corsia dopo; da
domani sta nel file.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **l'anteprima dell'import delle anagrafiche**, senza scrivere, contro le attese: 75 persone nuove con codice fiscale piu 2 senza; un solo candidato per ADAMI, LA TORRE, EMERA e IL MAGNIFICO; IGEA da abbinare a mano su Via Sorte 48; il gruppo «XXXXXXXXXXXX» fuori | la scrittura, se l'anteprima torna; poi nomine e formazione |
| **AppSopralluoghi** | l'anteprima contro le attese, riga per riga; e negli script futuri la query di verifica e l'avvertenza in testa | le attese di nomine e formazione per le persone recuperate |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | invariato: **ferma per costruzione** | la domanda sulle 48 persone di CorsiFatti, dopo il recupero |

### Prossimo passo per corsia · al 14 settembre 2026, le emergenze sono antincendio

**Deciso da Francesco il 14 settembre, nella sessione di AppSopralluoghi, e riferito da
quella corsia prima che fosse scritto nel suo `STATO.md`: «Addetto alle emergenze ed
evacuazione = Addetto antincendio».** Cambia una regola che **tre** repo avevano scritto
come misurata: l'import delle nomine esclude la colonna «Addetti Emergenze ed
Evacuazione» (`nomineImport.ts:126-129`, verificato su `origin`), il documento 07 di
AppFormazione la chiude, e questa sezione la chiamava «deduzione smentita» — corretto
dentro le righe, piu sopra.

**La misura non era sbagliata, e resta utile.** Rifatta dalla corsia sul foglio Ruoli SSL:
71 righe con Emergenze; 47 anche con Antincendio, **32 con la stessa data e 15 con una data
diversa**; **24 solo con Emergenze**. Quello che cambia e cosa se ne legge: non «due ruoli
diversi», ma **fino a 24 addetti antincendio che oggi non risultano**, e 15 righe su cui una
data va scelta. E la decisione e quella che la norma gia suggeriva: la `0002` di questo repo
chiama la figura **«Addetto alla prevenzione incendi e gestione emergenze»** e cita il DM
2 settembre 2021 — la colonna del gestionale adesso si legge come la figura era gia
definita qui.

**Due domande che la decisione non chiude, e che la corsia ha portato a Francesco invece di
risolverle:**

- **quale data vince sulle 15 righe** con Antincendio ed Emergenze in date diverse — ECODENT
  2017 contro 2022, I.VAR con due persone e le date scambiate;
- **«Responsabile Emergenze»**, 35 righe, che la decisione non nomina. **Finche Francesco non
  lo dice, resta fuori**: e un'altra colonna, e una decisione su una non vale per l'altra.

**L'ordine, perche un solo import delle nomine copra due cose.** La modifica tocca solo
l'import delle **nomine**, che viene **dopo** quello delle anagrafiche del recupero. Quindi:
l'import delle anagrafiche prima, come previsto; la modifica per le emergenze su un ramo, con
prova, **pubblicata prima del prossimo import delle nomine**; e quell'import allora porta
insieme le nomine delle persone recuperate e gli addetti dalle emergenze. Due import delle
nomine al posto di uno vorrebbero dire due anteprime, due confronti con le attese, e una
finestra in piu.

**Nota a margine, dalla stessa corsia**: Francesco ha aperto l'anteprima delle **nomine**
invece di quella delle anagrafiche — numeri coerenti, 0 da creare e 392 gia presenti (363 +
29) — ma ADAMI, LA TORRE ed EMERA risultavano ancora non abbinate, perche la pagina legge i
clienti solo all'apertura ed era aperta da prima della pulizia. Da ricaricare.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **l'anteprima delle anagrafiche**, a pagina ricaricata, contro 75 + 2; e le due risposte: la data sulle 15 righe, e se «Responsabile Emergenze» resta fuori | la scrittura delle anagrafiche; poi il si al ramo delle emergenze e al deploy; poi l'anteprima delle nomine |
| **AppSopralluoghi** | registrare la decisione nello `STATO.md`, e la modifica per le emergenze su un ramo, con prova, **dopo le due risposte** | le attese dell'import delle nomine, che adesso comprendono gli addetti dalle emergenze |
| **AppOverall** | corrette le due righe di questa sezione | nessuna migrazione tocca la colonna: la `0007` legge testi scritti a mano, e la figura nella `0002` e gia quella giusta |
| **AppFormazione** | **un passo piccolo, e assegnato apposta**: nel documento 07, alla conclusione su «Addetti Emergenze ed Evacuazione», **l'avvertenza dentro la riga** che la decisione di Francesco del 14 settembre la supera — la misura resta, la conclusione no. Non si cancella niente | fino a 24 addetti antincendio in piu sono formazione dovuta: materia loro, quando l'anagrafe attraversa |

**Il documento 07 di AppFormazione ha l'avvertenza dentro la riga** (`1478799`, verificato
su `origin`): la conclusione resta scritta, e subito dopo la decisione del 14, i numeri che
combaciano con quelli rifatti da AppSopralluoghi, e perche non vale piu. E la corsia ha
fatto la cosa che il passo non chiedeva e che serviva: **ha cercato dove altro stava la
stessa conclusione**, l'ha trovata in `scripts/carica_ruoli_ssl.py`, e **non l'ha toccata
da sola** — ha chiesto.

**La domanda poggiava su una premessa da correggere, e la correzione cambia la risposta.**
Una delle due strade diceva: lasciarlo com'e, «perche la colonna la legge l'import di
AppSopralluoghi e non questo script». **Non e cosi, verificato su `origin`**: lo script
**legge** «Addetti Emergenze ed Evacuazione», la **esclude** in `NON_CARICATE` con la ragione
superata — «il gestionale la tiene distinta da antincendio e le date non coincidono» — e
**scrive** in `ruoli_persona`, che nella produzione di AppFormazione e stata caricata il 9
settembre. Quindi la decisione non tocca solo un commento: **in quella produzione mancano
fino a 24 addetti antincendio**, e la formazione antincendio che devono non si calcola. E il
verso in cui l'errore non si vede: un obbligo che non c'e non compare fra le scadenze.

| chi | adesso | poi |
|---|---|---|
| **AppFormazione** | **l'avvertenza nei due punti dello script** — il commento in testa e la voce di `NON_CARICATE` — **senza cambiare cosa carica**, e con in piu **che lo script non si riesegue cosi com'e**: prima va decisa la data sulle 15 righe; e **nello `STATO.md` il buco dichiarato**, fino a 24 addetti antincendio assenti da `ruoli_persona` | **dopo la risposta di Francesco sulla data**: un caricamento **aggiuntivo** degli addetti dalle emergenze, con anteprima e attese contate sul foglio prima, e la scrittura col si di Francesco chiesto **a lui direttamente**, come per il `db push` del 13 |
| **Francesco** | le due risposte gia aperte — la data sulle 15 righe, e «Responsabile Emergenze» — che adesso servono a **due** import e non a uno | il si al caricamento aggiuntivo in AppFormazione, quando la corsia lo chiede |
| **AppSopralluoghi** | invariato: la decisione nello `STATO.md`, e la modifica per le emergenze su un ramo dopo le due risposte | — |
| **AppOverall** | nulla di nuovo | la migrazione delle nomine, quando il recupero e fatto |

**Perche il caricamento in AppFormazione non aspetta l'anagrafe unica.** Aspettare
vorrebbe dire lasciare in produzione, per settimane, persone designate addette
all'antincendio senza che il motore chieda il loro corso. Il caricamento e **additivo** —
righe nuove in `ruoli_persona`, nessuna tolta — e aspetta una sola cosa, la data, che e una
decisione di Francesco e non un lavoro tecnico.

### Prossimo passo per corsia · al 14 settembre 2026, le due risposte e la domanda sulle date

**Francesco ha risposto alle due domande sulle emergenze**, nella sessione di
AppSopralluoghi, e la corsia riporta le sue parole:

- sulla data, per le righe con Antincendio ed Emergenze in date diverse: **«ma emergenze 2022
  e l'aggiornamento quinquennale di antincendio 2017»** — quindi la nomina porta la **data
  piu vecchia**, e le successive sono aggiornamenti della formazione, non incarichi;
- su «Responsabile Emergenze»: **«Si, anche lui»** — entra anche lei come addetto antincendio.
  Il «finche non la nomina resta fuori» scritto qui e soddisfatto.

**La modifica e su un ramo, verificato da qui** (`emergenze-antincendio`, `6a8c404` su
`origin`): tre file; «Addetti Emergenze ed Evacuazione» e «Responsabile Emergenze» passano a
`addetto_antincendio`, e resta fuori solo `RSPP`; a parita di fonte vince la data piu vecchia.
Provata dalla corsia: 12 controlli su 12, e 4 falliti sulla versione di `main`. **Sul file**:
29 addetti antincendio nuovi da righe senza la colonna Antincendio — 18 solo Emergenze, 5 solo
Responsabile, 6 tutte e due — e i «da decidere» scenderanno di conseguenza, contati prima
dell'anteprima. **Una sola riga fra le 48 con Antincendio ha la data piu vecchia altrove**: la
1298, FIORIO STEFANO di I.VAR, Antincendio 2004 ed Emergenze 2001. La sua nomina esiste gia con
il 2004 e l'import non la riscrive: **va corretta a parte, con uno script piccolo che porta la
sua verifica dentro e l'avvertenza di lanciarlo tutto insieme**, e lo lancia Francesco.

**E la risposta sulla data dice una cosa piu grande della domanda, che va misurata e non
dedotta.** Se la data di Emergenze e l'aggiornamento quinquennale del corso di Antincendio, allora
**le date nelle colonne di ruolo del gestionale potrebbero essere date di corsi, non di
incarichi**. Il documento 07 di AppFormazione dice il contrario — «portano la data
dell'incarico, che e proprio cio che serve a `ruoli_persona.data_nomina`» — e su quella
lettura poggiano `nomina.data` in AppSopralluoghi e `ruoli_persona.data_nomina` in AppFormazione.
ECODENT, 2017 e 2022, sono esattamente cinque anni. **E un'ipotesi che guarda nel posto giusto**
(A21), e il file la puo chiudere senza toccare nessun database: **per le persone che hanno una
data nelle colonne di ruolo antincendio, quante di quelle date coincidono con la data di un
corso antincendio della stessa persona in CorsiFatti**. Se coincidono quasi tutte, la colonna e
una data di formazione con un altro nome, e `data_nomina` va chiamata per quello che e — non si
riscrive niente, si scrive **cosa misura**. Se non coincidono, il documento 07 aveva ragione e la
risposta di Francesco vale per le righe doppie e basta.

**Il caricamento aggiuntivo di AppFormazione cambia perimetro**, perche le due risposte lo
toccano tutte e due: non piu 24 righe di sole Emergenze, ma **Emergenze e Responsabile
Emergenze**, con la **data piu vecchia** fra le tre colonne, e **la 1298** da portare al 2001 se
in `ruoli_persona` sta col 2004 — da contare sul loro database, non da dedurre dal file.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **l'anteprima delle anagrafiche**, a pagina ricaricata, contro 75 + 2 — e il passo che tiene fermi tutti gli altri | la scrittura delle anagrafiche; il si al merge del ramo delle emergenze; lo script della 1298; poi l'anteprima delle nomine; e il si al caricamento aggiuntivo in AppFormazione |
| **AppSopralluoghi** | lo `STATO.md` con le parole di Francesco; lo script della 1298 con la verifica dentro; **la misura sulle date**, solo sul file | le attese dell'import delle nomine: persone recuperate piu i 29 addetti, e i «da decidere» ricontati |
| **AppFormazione** | ~~l'avvertenza nello script~~ **fatta** (`0308d46`, verificato: la mappa non cambia, cambia solo la ragione in `NON_CARICATE`) — ma scritta **prima** della risposta di Francesco, e dice «Responsabile Emergenze resta fuori» in tre punti (documento 07 riga 166, `STATO.md` riga 122, `NON_CARICATE`): **da correggere dentro la riga**, non cancellare. Poi **la preparazione del caricamento aggiuntivo**, che adesso non aspetta piu niente — Emergenze **e** Responsabile, data piu vecchia, la 1298 — contata sul loro database, **e il conto di `ruoli_persona` in produzione** che la corsia stessa ha dichiarato non fatto | la scrittura del caricamento, con anteprima e attese, e il si di Francesco chiesto a lui |
| **AppOverall** | nulla di nuovo nel codice | se le date risultano date di corsi, **il nome di `nomina.data_nomina` di qua va chiarito prima della migrazione delle nomine**: un nome sbagliato su un dato giusto e il difetto che attraversa il confine senza farsi vedere |

### Prossimo passo per corsia · al 14 settembre 2026, un giorno di differenza

**AppFormazione ha chiuso le correzioni e contato il foglio** (`52b423f`, verificato su
`origin`, mappa dello script invariata): «Responsabile Emergenze resta fuori» corretto dentro
la riga in **quattro** punti, non tre — lo script lo diceva due volte; e sul foglio **29 righe
senza Antincendio**, tutte con codice fiscale, su 13 societa, che combaciano con il riscontro
di AppSopralluoghi, piu la sola 1298 con una data piu vecchia altrove.

**Il conto di `ruoli_persona` in produzione non e fatto, e non per una dimenticanza: la
lettura e stata negata dal controllo dei permessi di quella sessione.** La corsia non l'ha
aggirata e **non l'ha passata a un'altra corsia**: la porta a Francesco. E la regola di
questa sezione applicata nel verso giusto — un ostacolo non si aggira passandolo a chi ha il
permesso — e **da qui non si assegna a nessun altro**. Le attese del caricamento aggiuntivo
aspettano quella decisione.

**E ha trovato una cosa che puo toccare ogni data importata da AppSopralluoghi.** Nell'XML del
foglio le celle della 1298 sono seriali interi, **37993 e 37025**; convertiti da qui, **2004-01-07
e 2001-05-14**. AppSopralluoghi aveva riferito **2004-01-06 e 2001-05-13: un giorno prima, su
tutte e due**. Un seriale non ha ora ne fuso, quindi lo scarto nasce leggendolo.

**Dove guardare, letto da qui nel loro codice — un indizio, non una diagnosi.** L'import delle
anagrafiche legge il file con `cellDates: true` e passa le celle a `isoData`
(`anagraficheImport.ts:103-106`), che dalla `Date` prende anno, mese e giorno **in ora
locale**. Se la libreria costruisce quella `Date` con uno scarto di fuso — anche di minuti,
come succede sulle date storiche — la mezzanotte cade nel giorno prima e la data esce indietro
di uno. `isoData` e la stessa funzione che l'import delle **nomine** usa per `nomina.data`
(`nomineImport.ts:442`) e che l'import delle anagrafiche usa per **assunzione e cessazione**;
`formazioneImport` invece legge con `cellDates: false` e converte il seriale in UTC, e
potrebbe non esserne toccato.

**Perche questo cambia l'ordine dei prossimi passi.** Se lo scarto c'e, le 392 nomine gia
scritte e le date delle persone portano il giorno prima; la prossima scrittura delle
anagrafiche ne aggiungerebbe altre 77; e **lo script della 1298 porterebbe la nomina al 13
maggio, quando il file dice 14**. **La prova si fa sul file e senza database, in pochi minuti**:
leggere un campione di celle data con lo stesso codice di produzione, e confrontarle con i
seriali dell'XML. Va fatta **prima** della scrittura delle anagrafiche e dello script della 1298.
**L'anteprima invece si puo guardare anche adesso**: non scrive.

| chi | adesso | poi |
|---|---|---|
| **AppSopralluoghi** | **la prova sul file**: un campione di celle data — la 1298, e righe con giorni diversi e anni diversi — lette con `leggiFoglio` e `isoData` di produzione, contro i seriali dell'XML | **se lo scarto c'e**: correzione del codice prima di qualunque altro import; poi, col si di Francesco per leggere, **quante righe in produzione** portano una data importata cosi — nomine, assunzioni, cessazioni — e lo script che le corregge, con la verifica dentro. **Se non c'e**: da dove veniva il giorno prima riferito, scritto |
| **Francesco** | **l'anteprima delle anagrafiche**, che non scrive; **e la decisione sulla lettura di `ruoli_persona` negata ad AppFormazione** — lanciarla lui o consentirla | la scrittura delle anagrafiche **dopo la prova sulle date** |
| **AppFormazione** | niente finche Francesco non decide sulla lettura | le attese del caricamento aggiuntivo |
| **AppOverall** | nulla di nuovo | se lo scarto c'e, **la migrazione dati prende le date dall'estrazione**: vanno corrette all'origine prima, o il passo 02 porta di qua un giorno sbagliato con la faccia di un dato |

### Prossimo passo per corsia · al 14 settembre 2026, nessuno scarto e un altro doppione

**Nel codice di produzione lo scarto di un giorno non c'e** (AppSopralluoghi `ab7dedd`,
verificato su `origin`). La prova, solo sul file: **3.990 celle** data di Ruoli SSL e **3.651**
di Fattori di Rischio lette con `leggiFoglio` e `isoData` di produzione, contro il seriale
grezzo, col fuso di Roma e con UTC, **zero differenze**, anche decennio per decennio dal 1940.
**Il giorno prima veniva dagli script di analisi della corsia**, che convertivano con
`toISOString()` sul fuso della macchina: sono sbagliate di un giorno solo le date **citate** —
FIORIO e gli esempi della misura sulle emergenze — e i conteggi reggono, perche ogni confronto
usava la stessa conversione dai due lati. **L'indizio letto da qui in `isoData` era sbagliato**,
ed era scritto come indizio: la funzione fa la cosa giusta.

**E la domanda sulle date dei ruoli si chiude con una misura, nel verso opposto a quello
suggerito.** Su 79 righe con Addetti Antincendio, confrontate col corso antincendio piu vicino
della stessa persona in CorsiFatti: **stesso giorno 19**, entro una settimana 2, entro un mese 4,
entro un anno 24, oltre un anno 21; senza corso 4, senza codice fiscale 5. **La data della colonna
coincide con un corso in circa un caso su quattro: in generale non e la data di un corso.** Cosa
misuri esattamente il file non lo dice, e il documento 07 di AppFormazione non va toccato. La
risposta di Francesco sulla data vale per le righe doppie, dove l'ha data.

**Lo script della 1298 e provato qui, e si puo lanciare quando l'ordine lo chiama**
(`correggi_data_antincendio_fiorio.sql` in `ab7dedd`, date corrette sui seriali: dal 2004-01-07 al
2001-05-14). Un blocco solo, l'avvertenza in testa, il conteggio prima, `row_count` dopo, la
verifica in fondo. Eseguito su un cluster usa e getta con lo schema di `nomina` della loro `015`:

| caso | esito |
|---|---|
| normale | **passa**: una riga a 2001-05-14 nella verifica |
| rilancio | «ne ha toccate 0», niente scritto |
| nomina assente | «trovate 0», niente scritto |
| due FIORIO STEFANO nello stesso cliente, uno scritto con spazi e minuscole | «trovate 2», niente scritto |
| data diversa da 2004-01-07 | «ne ha toccate 0», niente scritto |
| gia a 2001-05-14 prima del lancio | «ne ha toccate 0», niente scritto |

In tutti i casi **la nomina da preposto dello stesso FIORIO e il FIORIO STEFANO di un altro cliente
restano intatti**.

**L'anteprima delle anagrafiche rifatta fuori dallo schermo, col si di Francesco a leggere le
persone, trova quello che la schermata non diceva.** Coincidono gruppi, voci, i 2 da abbinare, i 2
gruppi senza cliente — IGEA e «XXXXXXXXXXXX» — e la riga scartata. **Ma le nuove vengono 88, e la
schermata ne mostrava 93: cinque di scarto non spiegate**, e un conto che non torna non si scrive.
Delle 88:

- **63** hanno un codice fiscale mai visto in produzione: il recupero — le 75 meno le 12 di IGEA,
  che stanno nel gruppo da abbinare a mano;
- **1** senza codice fiscale, LESO IRENE di LA TORRE;
- **24** hanno il codice fiscale **gia presente sotto un altro cliente**, e sono il fatto nuovo.

**21 delle 24 sono MAISON 22 S.R.L., un altro cliente doppio**: due clienti con la stessa P.IVA,
04285130235, localita Verona; uno ha 21 persone, l'altro nessuna, e il gruppo del file sceglie
**quello vuoto**. Scrivendo nascerebbero **21 doppioni**. **Le altre 3 sono di AZIENDA AGRICOLA
GIACOMELLI FRANCESCO**, con i codici fiscali sotto AZ. AGR. AMARI UMBERTO e sotto Impresa
Agromeccanica Aprili Graziano; e GIACOMELLI (zero persone) e Aprili (sei) hanno **la stessa P.IVA**,
00912140233, con nomi diversi.

**MAISON 22 non l'aveva visto nessuna misura precedente, e la ragione dice che la classe non e
chiusa.** Le cinque coppie di prima erano venute fuori dalle **persone mancanti**; MAISON 22 ha le
persone **sotto uno dei due**, quindi da quel lato non mancava niente — l'ha fatto vedere solo
l'anteprima. E la misura del pomeriggio contava **12 P.IVA vere condivise da 24 clienti**: tolte le
coppie gia unite, **quelle rimaste non sono state guardate una per una**. Decidere doppione per
doppione, a ogni anteprima, e il modo in cui la terza sorpresa arriva dopo la scrittura.

**Le 24 schede che cambierebbero, e la lettura va corretta prima di decidere.** Cambiano solo per
spazi doppi presi dal file. **Non contraddice il principio dell'import**, come si poteva pensare:
«si riempiono solo i campi vuoti» vale per i **clienti**; per le **persone** `fondiPersona` ha la
regola opposta, scritta nel suo commento — «ciò che il file non dice resta com'era», cioe **quello
che dice vince** (`anagraficheImport.ts:876`). Quindi e il file che riscrive con due spazi un nome
che in produzione ne ha uno. Le chiavi di confronto collassano gli spazi, e l'abbinamento non ne
risente.

**Le raccomandazioni, scritte come raccomandazioni:**

- **prima di tutto, la tabella intera**: tutti i clienti che dopo la pulizia condividono ancora una
  P.IVA usabile, con persone, indirizzo, data di creazione e da quale import vengono. Le decisioni
  si prendono **una volta**, su tutti;
- **MAISON 22**: doppione, stessa P.IVA e stessa localita — **si uniscono tenendo quello con le 21
  persone**, con uno script della stessa forma di `10cd71f` e la stessa misura di cosa punta al
  cliente da togliere. **Prima dell'unione le anagrafiche non si scrivono**;
- **GIACOMELLI e Aprili**: la stessa P.IVA con due nomi diversi **non e un doppione, e un dato
  sbagliato** su uno dei due. Si verifica quale P.IVA sia vera — una visura la dice — e **non si
  unisce niente**. Le tre persone con il codice fiscale sotto AMARI e Aprili possono lavorare davvero
  in piu aziende agricole: all'origine sono tre schede legittime;
- **gli spazi doppi**: accettarli adesso — non cambiano nessun abbinamento — e **far collassare gli
  spazi nella lettura dei nomi nello stesso ramo delle emergenze**, cosi gli import successivi smettono
  di riscriverli; una pulizia dei nomi a doppio spazio, se serve, dopo. Metterci un deploy **prima**
  della scrittura delle anagrafiche sposterebbe tutto il recupero per una questione di forma;
- **le cinque nuove in piu**: ricaricare la pagina e rileggere il numero. Se resta 93, **si spiegano
  prima di scrivere**.

| chi | adesso | poi |
|---|---|---|
| **AppSopralluoghi** | **la tabella dei clienti con P.IVA usabile ancora condivisa**, in sola lettura col si di Francesco; e la spiegazione delle 5 nuove in piu | lo script di unione per i doppioni che Francesco decide, **mandato qui prima del lancio**; nel ramo delle emergenze, se Francesco lo vuole, gli spazi collassati |
| **Francesco** | le decisioni su MAISON 22, GIACOMELLI e Aprili, gli spazi doppi — **meglio con la tabella intera davanti** | lo script di unione; poi l'anteprima ricaricata e la scrittura delle anagrafiche; poi il merge delle emergenze, lo script della 1298, l'import delle nomine |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |
| **AppOverall** | provati lo script della 1298 e, quando arriva, quello di unione | il passo 01 della migrazione fonde gia i clienti con la stessa P.IVA usabile: un doppione non unito all'origine diventerebbe **una sede vuota** di qua, non un secondo cliente — un difetto piu piccolo, ma sempre un difetto |

**Una decisione di Francesco e due casi letti, riferiti da AppSopralluoghi** — le letture in
sola lettura, su richiesta di Francesco.

- **Gli spazi doppi: «Si, ripulisci».** Si collassano nella lettura dei nomi delle persone, sul
  ramo delle emergenze, come raccomandato: nessun deploy prima della scrittura delle anagrafiche.
- **MAISON 22 e un doppione pieno**, ed e gia doppio nell'export del gestionale: i due clienti
  hanno la stessa P.IVA e lo stesso codice fiscale, 04285130235, lo stesso indirizzo, Via Quattro
  Novembre 1/D, 37126 Verona, sono nati nello stesso minuto del 9 settembre e non hanno incarichi;
  uno ha 21 persone, l'altro nessuna. ~~**La raccomandazione di unirli regge.**~~ **Sbagliata, e
  corretta da Francesco un'ora dopo: MAISON 22 ha due sedi vere**, e il gestionale le esporta con
  lo stesso nome e lo stesso indirizzo — vedi il paragrafo seguente.
- **GIACOMELLI non e un doppione, ed e piu di una P.IVA sbagliata.** Nel gestionale
  «AZIENDA AGRICOLA GIACOMELLI FRANCESCO», senza indirizzo, porta **la P.IVA e il codice fiscale di
  Impresa Agromeccanica Aprili Graziano** — e il codice fiscale e quello di una persona, non di una
  societa. Esiste anche **«AZ. AGR. GIACOMELLI FRANCESCO»**, Pradelle di Nogarole Rocca, con una
  P.IVA sua, 02884860235, e una persona. In produzione la prima ha zero persone e Aprili ne ha sei;
  ma **due di quelle sei — AMARI UMBERTO e GIACOMELLI FRANCESCO — nel file non stanno mai sotto
  Aprili**, stanno sotto Giacomelli. La corsia ne deduce che l'import del 9 settembre abbia agganciato
  ad Aprili le righe dell'anagrafica con i suoi stessi dati fiscali, e **lo scrive come dedotto e
  non misurato**: il file di quel giorno non c'e piu. Da qui resta un'ipotesi, e la risposta non sta
  in nessun database — sta in chi conosce quelle aziende agricole.

**La domanda per Francesco su Giacomelli, allargata:** per quale azienda lavorano davvero AMARI
UMBERTO, GIACOMELLI FRANCESCO e NEGRETTI LUCA — che nel file compare sotto tutte e due; se
«AZIENDA AGRICOLA GIACOMELLI FRANCESCO» sia la stessa azienda di «AZ. AGR. GIACOMELLI FRANCESCO»
registrata coi dati di un'altra; e quindi se quel cliente vada tolto, e quelle due persone
spostate. **Niente di questo si scrive prima della sua risposta**, e la scrittura delle anagrafiche
resta ferma: MAISON 22 da unire, Giacomelli da chiarire, e prima la tabella intera delle P.IVA
condivise, che la corsia gli chiede adesso.

**Per la migrazione di questa corsia**, se l'ipotesi e vera: il passo 02 porterebbe di qua due
rapporti di lavoro sotto Aprili che non sono di Aprili. E il genere di errore che una migrazione
trasporta intatto, perche la chiave e coerente con se stessa — va chiuso all'origine.

### Prossimo passo per corsia · al 14 settembre 2026, due sedi e un'azienda con i dati di un'altra

**Le decisioni di Francesco su MAISON 22 e Giacomelli**, date nella sessione di AppSopralluoghi e
riferite da quella corsia prima di essere scritte nel suo `STATO.md`.

**MAISON 22 non e un doppione, e la raccomandazione di questa corsia era sbagliata.** Francesco:
«MAISON 22 ha 2 sedi: Corso Porta Borsari, 26, 37121 Verona VR in cui ci sono 4 risorse e Via IV
Novembre, 1d, 37126 Verona VR con 17», e ha indicato le quattro persone di Porta Borsari. **I dati
dicevano doppione — stessa P.IVA, stesso indirizzo, righe identiche nell'export — e i dati erano
sbagliati**: il gestionale esporta le due unita con lo stesso nome e la stessa sede, e nel file le 21
righe hanno tutte sede «Verona». E la stessa forma di A9 — un dato coerente con se stesso non e per
questo vero — su un caso in cui la coerenza era totale. Lo script che la corsia prepara: il cliente
vuoto prende l'indirizzo di Porta Borsari, e le quattro persone ci passano con sede e `import_key`
riscritte.

**E un rischio che va detto adesso, non agli import futuri.** Dopo lo script, nel prossimo import
delle anagrafiche il gruppo MAISON 22 del file — 21 righe, sede «Verona» — avra **due candidati**
e non ne scegliera nessuno. **Se nell'anteprima lo si abbinasse a mano al cliente di Via IV
Novembre, le quattro persone spostate verrebbero ricreate li**, perche la loro chiave vecchia non
esiste piu. **Il gruppo va escluso, non abbinato**, e cosi a ogni import finche la sede non e
corretta **nel gestionale**, che e l'unico posto dove questo si chiude. Per la migrazione di questa
corsia non cambia niente di male: i due clienti hanno la stessa P.IVA usabile e il passo 01 li porta
come **un cliente con due sedi**, che adesso e esattamente il vero.

**Giacomelli, le risposte:**

- «AZIENDA AGRICOLA GIACOMELLI FRANCESCO» **e la stessa azienda** di «AZ. AGR. GIACOMELLI
  FRANCESCO»: il cliente con i dati fiscali di Aprili **si toglie**, dopo la misura di cosa gli punta;
- la P.IVA vera della Giacomelli, data da Francesco, e **02984860235**, non 02884860235 come in
  produzione. **Verificato da qui con la cifra di controllo, che nessuna funzione dell'import
  controlla: 02884860235 la sbaglia, 02984860235 la passa** — era un refuso nel gestionale. Il codice
  fiscale di persona che va con lei non entra in nessuno script e in nessun repo: lo corregge
  Francesco dalla scheda cliente;
- AMARI UMBERTO e GIACOMELLI FRANCESCO **non lavorano per Aprili**: le loro schede sotto Aprili, nate
  dall'import del 9 settembre, si tolgono — la corsia ha letto che non hanno niente collegato. Nelle
  loro aziende vere ci sono gia;
- NEGRETTI LUCA **lavora per Aprili**: la sua scheda resta, e la riga del file sotto Giacomelli e
  sbagliata nel gestionale.

**E la cifra di controllo apre una misura che chiude la classe.** Ne `pivaUsabile` ne la
`partita_iva_usabile` della `0017` guardano la cifra di controllo: **un refuso su una P.IVA vera passa
per una chiave buona**, aggancia il cliente sbagliato o nessuno, e non fa rumore. Quante P.IVA usabili
in produzione sbagliano la cifra di controllo e un conto in sola lettura. **Se non sono zero, se
«usabile» debba voler dire anche «cifra giusta» e una decisione di Francesco**, perche cambia chi si
fonde e chi no nella migrazione, e oggi la regola approvata e un'altra.

| chi | adesso | poi |
|---|---|---|
| **AppSopralluoghi** | **lo script unico** — MAISON 22, il cliente Giacomelli da togliere, le due schede sotto Aprili — con la misura su cosa punta a cio che si toglie, il controllo che annulla e la verifica dentro, **mandato qui prima del lancio**; nell'anteprima delle anagrafiche, **il gruppo MAISON 22 escluso** e scritto fra le attese | la tabella delle P.IVA condivise, **quando Francesco dice si** — «cosa devo fare?» non e un si, e la corsia ha fatto bene a non prenderlo come tale; **e il conto delle P.IVA con la cifra di controllo sbagliata**, nella stessa lettura |
| **Francesco** | la P.IVA e il codice fiscale della Giacomelli dalla scheda cliente; il si alla lettura della tabella | lo script, provato qui; la sede di MAISON 22 corretta **nel gestionale**; poi l'anteprima e la scrittura delle anagrafiche |
| **AppOverall** | provare lo script unico quando arriva | — |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

### Prossimo passo per corsia · al 14 settembre 2026, lo script unico e la tabella intera

**Lo script unico e provato qui, e manca una cosa** (AppSopralluoghi `f2132a2`,
`correggi_maison22_giacomelli.sql`, verificato su `origin`). Un blocco solo, l'avvertenza in testa,
ogni scrittura con il conto delle righe, i controlli dopo relativi a prima, i collegamenti letti dal
catalogo. Eseguito su un cluster usa e getta con uno schema minimo — cliente, sede in cascata,
persona con la chiave unica, nomina, formazione, **adempimento con cliente, sede e persona**, azione —
e gli id veri:

| caso | esito |
|---|---|
| normale | **passa**: 4 persone a Porta Borsari con sede e chiave nuove, Via IV Novembre con le altre, Aprili con NEGRETTI e APRILI, la falsa Giacomelli tolta |
| rilancio | «doveva essere vuoto», niente scritto |
| una delle quattro gia spostata | «doveva essere vuoto», niente scritto |
| una nomina su una scheda da togliere sotto Aprili | notice e errore, niente scritto |
| un adempimento sulla sede della falsa Giacomelli | notice e errore, niente scritto |
| la chiave nuova esiste gia | errore, niente scritto |
| **una visita medica su una delle quattro persone da spostare** | **passa — e la visita resta sul cliente e sulla sede di Via IV Novembre** |

**L'ultimo caso e il vuoto.** Lo script cerca i collegamenti di cio che **toglie**, non di cio che
**sposta**; e `adempimento` porta **cliente, sede e persona** insieme — le visite mediche sono
adempimenti della persona. Dopo lo script la persona sta a Porta Borsari e la sua visita a Via IV
Novembre: nessun vincolo protesta, e lo scadenzario la mostra sotto l'unita sbagliata. **La
correzione e piccola**: contare gli adempimenti delle quattro persone e, se ci sono, spostarne cliente
e sede con il conto delle righe — o annullare, se Francesco preferisce guardarli prima. Riletto nel
loro codice il resto di cio che si sposta: **la chiave dei corsi non contiene il cliente**
(`gest:<cf>:<corso>:<data>`), quindi i corsi gia scritti restano riconosciuti; **ma l'import della
formazione cerca le persone fra quelle di un cliente solo** — un corso nuovo di una delle quattro, in
un'unita MAISON 22 abbinata a Via IV Novembre, non troverebbe la persona. **Il gruppo MAISON 22 va
escluso anche dall'import della formazione**, non solo da quello delle anagrafiche.

**La tabella intera delle P.IVA condivise**, letta col si di Francesco: **9 P.IVA usabili su 18
clienti**, tutti nati il 9 settembre fra le 10:29 e le 10:30, nessuno con incarichi; IGEA c'e, ed e il
controllo che la query vede il caso noto.

| P.IVA | clienti | indirizzi | persone | stato |
|---|---|---|---|---|
| 00199400128 | LINDE MATERIAL HANDLING ITALIA ×2 | Via del Luguzzone 3, Buguggiate / nessuno | 0 / 0 | **da decidere** |
| 00912140233 | AZIENDA AGRICOLA GIACOMELLI / Aprili | — | 0 / 6 | nello script |
| 00967010232 | CENTRO ATTIVITA' ×2 | Via Fratelli Corra 7 / 9, Valeggio | 21 / 0 | **da decidere** |
| 01249140235 | CENTRO SOCIALIZZAZIONE ×2 | Via Cantore 6, Villafranca, tutti e due | 26 / 0 | **da decidere** |
| 02325330237 | ECODENT ×2 | Via del Lavoro 6/8 Trevenzuolo / Via Belgio 6 Villafranca | 8 / 8 | due sedi, noto dal 31 luglio |
| 02449980230 | MARANI G. SPA ×2 | identici, Via dell'Artigianato 51 Bovolone | 0 / 0 | **da decidere** |
| 04285130235 | MAISON 22 ×2 | — | 17 / 4 dopo lo script | due sedi, deciso |
| 04312380233 | AZ. AGR. PARAVANTO / DELIPERI ALBERTO | Via Saraina / Via T. Saraina 13 | 0 / 0 | **da decidere** |
| 04366240234 | IGEA ×2 | — | — | due sedi, deciso |

**E dopo MAISON 22 la domanda si fa sede per sede, non «unire?»** — la corsia l'ha gia deciso da sola,
ed e la lezione giusta: i dati dicevano doppione pieno, ed erano due sedi.

**La cifra di controllo, su 554 P.IVA usabili: 4 la sbagliano** — AZ. AGR. GIACOMELLI FRANCESCO
02884860235, il refuso gia corretto da Francesco; CAPRINI FRANCO 20619000235; L'ERBA DEL VICINO
04570450234; **e Progetto EMERA Onlus 09318332023, cioe la P.IVA arrivata col cliente tenuto
nell'unione delle 12:11**. Nella pulizia EMERA ha preso la P.IVA dell'altra meta come quella vera, e la
decisione era giusta sui dati di allora; **ma quella P.IVA non passa la cifra di controllo**, e va
guardata da chi puo leggere una visura. E l'unica delle quattro che una scrittura di oggi ha
promosso da una riga a un'altra.

| chi | adesso | poi |
|---|---|---|
| **AppSopralluoghi** | **gli adempimenti delle quattro persone nello script** — contati, e spostati col conto delle righe o annullati — e **rimandarlo qui**; nello `STATO.md` il gruppo MAISON 22 escluso **anche** dall'import della formazione | le domande a Francesco sede per sede per LINDE, CENTRO ATTIVITA', CENTRO SOCIALIZZAZIONE, MARANI, PARAVANTO e DELIPERI |
| **Francesco** | **la P.IVA di EMERA**, 09318332023, da verificare; e le altre tre con la cifra sbagliata; la P.IVA e il codice fiscale della Giacomelli dalla scheda | lo script corretto e riprovato; le risposte sede per sede; poi l'anteprima e la scrittura delle anagrafiche |
| **AppOverall** | riprovare lo script corretto | per la migrazione: con la regola approvata le quattro P.IVA sono **usabili**, e quella di EMERA oggi e sul cliente giusto per nome ma forse sbagliata per cifra — se «usabile» debba voler dire «cifra giusta» resta una decisione di Francesco |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

**Lo script unico corretto regge su tutti i casi, e si puo lanciare** (AppSopralluoghi `ec2f15b`,
verificato su `origin`). La correzione: dopo lo spostamento delle quattro persone, **dal catalogo al
momento del lancio**, ogni tabella che ha una chiave esterna verso la persona **e** una verso cliente o
sede segue le persone — cliente e sede portati su Porta Borsari, ogni `update` con il conto delle righe
e una notice — e lo stesso per le azioni che portano la persona nella chiave e il vecchio cliente come
responsabile; dopo, il controllo che nessuna riga delle quattro sia rimasta sul vecchio cliente o su una
vecchia sede. Rieseguito qui sullo stesso schema, con **un caso in piu** per la parte nuova sulle azioni,
e **una visita di un'altra persona di Via IV Novembre** presente in tutti i casi come controllo:

| caso | esito |
|---|---|
| normale | **passa** |
| rilancio · una delle quattro gia spostata · una nomina su una scheda da togliere · un adempimento sulla falsa Giacomelli · la chiave nuova gia esistente | errore, niente scritto — come nella prima prova |
| **una visita medica su una delle quattro** | **passa, e adesso la visita segue la persona**: cliente e sede di Porta Borsari, con le due notice |
| **un'azione di una delle quattro col vecchio cliente responsabile** | **passa, e l'azione segue la persona** |
| la visita dell'altra persona di Via IV Novembre, in tutti i casi | **non si muove mai** |

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **lo script dall'SQL Editor**, tutto insieme, e la query di verifica in fondo | la P.IVA di EMERA e le altre tre con la cifra sbagliata; le risposte sede per sede sui cinque casi della tabella; poi l'anteprima delle anagrafiche con MAISON 22 **escluso** |
| **AppSopralluoghi** | registrare il lancio con la verifica; nello `STATO.md` MAISON 22 escluso dall'import delle anagrafiche **e** da quello della formazione | le domande sede per sede; le attese dell'anteprima aggiornate dopo lo script |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

### Prossimo passo per corsia · al 14 settembre 2026, le cinque P.IVA condivise

**Francesco ha deciso le cinque coppie ancora aperte**, nella sessione di AppSopralluoghi e riferito
da quella corsia: **«tieni solo la sede con persone e dove non ci sono persone la prima sede che
incontri in ordine»**, nell'ordine della tabella. Quindi resta LINDE di Via del Luguzzone 3; CENTRO
ATTIVITA' di Via Fratelli Corra 7, con 21 persone; CENTRO SOCIALIZZAZIONE con 26; il primo MARANI; e
AZ. AGR. PARAVANTO DI ALBERTO DELIPERI — e l'altro di ciascuna coppia si toglie.

**La nota di merito della corsia, che va tenuta a vista:** Corra 9 e il secondo CENTRO SOCIALIZZAZIONE
**potevano essere sedi vere**, come MAISON 22. La regola li toglie perche sono vuoti, e **se un giorno
arrivano persone di quelle sedi, il cliente va ricreato** — non abbinato a quello rimasto.

**Lo script e provato qui, e si puo lanciare** (`unisci_cinque_piva_condivise.sql`, `ac8cd75`,
verificato su `origin`). Ripete la forma gia provata — la misura dal catalogo, poi copia, cancella,
riempi i vuoti dalla copia, poi i controlli relativi a prima. Eseguito su un cluster usa e getta, con
gli id veri, persone sui clienti tenuti, e **i due clienti IGEA presenti in tutti i casi come
controllo**:

| caso | esito |
|---|---|
| normale | **passa**: 12 clienti diventano 7, persone intatte, IGEA intatta |
| rilancio | «trovati 0», niente scritto |
| una persona su un cliente da togliere | notice e errore, niente scritto |
| una visita sulla sede di un cliente da togliere | notice e errore, niente scritto |
| una coppia con P.IVA diversa | errore sulla coppia, niente scritto |
| un'azione `cliente-ateco` su un cliente da togliere | notice e errore, niente scritto |
| `werp_id` solo sul cliente da togliere | **passa, e il tenuto lo prende** |
| codice fiscale pieno sul tenuto e diverso sul tolto | **passa, e resta quello del tenuto**; dove il tenuto non l'aveva, lo prende |

**Due cose da sapere prima del lancio, nessuna delle due lo blocca.**

- **Il riempimento prende i vuoti campo per campo, e puo comporre un indirizzo da due righe.** Nella
  prova PARAVANTO tiene «Via Saraina» e prende **CAP 37060 e localita Nogarole Rocca** dall'altro,
  che era «Via T. Saraina 13». E quasi certamente lo stesso posto; ma e un indirizzo che nessuna delle
  due righe diceva intero, e se lo si vuole diverso lo si corregge dalla scheda dopo.
- **Una notice innocua che nell'SQL Editor puo sembrare un errore**: `drop table if exists
  pg_temp.copia_cinque_piva` stampa «schema "pg_temp" does not exist, skipping» in una sessione che non
  ha ancora tabelle temporanee. **Non e un errore e non cambia niente**; la corsia puo toglierla
  scrivendo il nome senza `pg_temp.`, oppure dirlo a Francesco prima del lancio.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **lo script MAISON 22 e Giacomelli**, gia provato; poi **questo**, tutto insieme, e la query di verifica in fondo | la P.IVA di EMERA; l'anteprima delle anagrafiche con MAISON 22 escluso, contro le attese riscritte dopo i due script |
| **AppSopralluoghi** | registrare i due lanci con le verifiche; la notice di `pg_temp` tolta o annunciata | **le attese dell'anteprima riscritte dopo i due script**: sono cambiati clienti, candidati e persone |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

### Prossimo passo per corsia · al 14 settembre 2026, i due script lanciati e l'ordine rivisto

**I due script sono lanciati da Francesco, e le verifiche danno l'atteso.**

- **MAISON 22 e Giacomelli** (`ec2f15b`, registrato da AppSopralluoghi in `6d4ce07`, verificato su
  `origin`): MAISON 22 con due clienti, Corso Porta Borsari 26 con 4 persone e Via Quattro Novembre
  1/D con 17; Aprili con 4; AZ. AGR. GIACOMELLI FRANCESCO con 1; la falsa «AZIENDA AGRICOLA
  GIACOMELLI FRANCESCO» non c'e piu; zero adempimenti fuori posto. La P.IVA della Giacomelli e ancora
  quella col refuso, come previsto: la corregge Francesco dalla scheda.
- **Le cinque P.IVA condivise** (`ac8cd75`, riferito dalla corsia, **non ancora su `origin`** mentre
  questo si scrive): cinque righe, una per P.IVA, nessun cliente tolto rimasto; CENTRO ATTIVITA' con
  21 persone e CENTRO SOCIALIZZAZIONE con 26; PARAVANTO con Via Saraina, 37131 Verona.

**L'ordine cambia, e cambia una raccomandazione di questa corsia.** Il 14 pomeriggio era scritto:
accettare adesso gli spazi doppi e collassarli nel ramo delle emergenze, **dopo** la scrittura delle
anagrafiche, per non mettere un deploy davanti al recupero. **Con il «Si, ripulisci» di Francesco il
conto e un altro**, e l'ha fatto AppSopralluoghi: se il ramo va online dopo, le 24 schede prendono gli
spazi doppi e serve una seconda pulizia; se va online prima, no. **E anticiparlo non costa quello che
temevo**: il ramo cambia come l'import delle **nomine** leggera le colonne, e nessun import delle
nomine avviene fra il deploy e il punto 5. L'ordine nuovo:

1. il collasso degli spazi nella lettura dei nomi delle persone, sul ramo `emergenze-antincendio`, con
   prova;
2. merge e deploy del ramo, con la verifica per canale, col si di Francesco;
3. anteprima e scrittura delle anagrafiche, con **MAISON 22 escluso**, contro attese calcolate **sul
   codice pubblicato**;
4. lo script della 1298;
5. **un solo** import delle nomine.

**Tre condizioni, perche il punto 1 tocca la chiave con cui una persona senza codice fiscale e
riconosciuta.**

- **La chiave `anag:<cliente>:n:COGNOME|NOME` non deve cambiare.** Oggi passa gia da `normNome`, che
  collassa gli spazi (`anagraficheImport.ts:86-87`, letto da qui), quindi non dovrebbe; **ma la prova
  lo deve mostrare**, perche una chiave che cambia di uno spazio fa ricreare la persona al primo import
  — un doppione per ogni nome toccato, senza un errore;
- **il collasso tocca solo i campi in cui stanno le 24 differenze**, e in nessun altro: ~~la mansione,
  per dirne uno, e un testo che il dizionario dei ruoli legge alla lettera~~ **premessa sbagliata,
  corretta sotto: il dizionario non legge `persona.mansione`**;
- **le attese dell'anteprima si calcolano col codice che sara online al punto 3**, non con quello di
  oggi: le 24 schede **non** devono piu risultare aggiornate, e questo e il riscontro che il collasso
  funziona.

| chi | adesso | poi |
|---|---|---|
| **AppSopralluoghi** | **il collasso sul ramo, con la prova delle tre condizioni** — chiavi invariate per le persone senza codice fiscale, solo i campi delle 24, e le prove delle emergenze ancora verdi | merge e deploy col si di Francesco e la verifica per canale; poi le attese dell'anteprima sul codice pubblicato |

**Le attese dell'anteprima delle anagrafiche, riscritte dopo i due script** (AppSopralluoghi, sul
codice di `main`, con le funzioni vere e i dati letti in sola lettura). **Ricontate da qui**: clienti
**608** = 614 − la falsa Giacomelli − le cinque coppie; persone **3.417** = 3.419 − le due schede sotto
Aprili. Con MAISON 22 escluso e IGEA su Via Sorte 48: 480 gruppi; **77 nuove** — 75 codici fiscali mai
visti piu 2 senza; **0** con il codice fiscale gia sotto un altro cliente, che erano 24; 3.395
aggiornate, di cui **24 solo per spazi doppi**, che col codice del ramo devono andare a zero; 2 da
abbinare, i due Pradella Tazio; 3 gruppi senza cliente — la falsa Giacomelli, MAISON 22, «XXXXXXXXXXXX»;
1 riga scartata.

**Una correzione a quello che era scritto qui, e cambia cosa deve fare Francesco.** Si era scritto
che il gruppo MAISON 22, con due candidati, **non ne sceglie nessuno**. **Non e cosi: senza scelte a
mano si abbina da solo a uno dei due.** Quindi nell'anteprima **non comparira fra i da abbinare**, avra
l'aspetto di un gruppo a posto, e **va escluso attivamente** — non basta non toccarlo. Altrimenti le
quattro persone di Porta Borsari rinascono sotto l'altro cliente.

**E un conto vecchio che le attese nuove devono chiudere.** Nell'anteprima vista prima dei due script la
schermata diceva 93 nuove e il ricalcolo fuori schermo 88, e **le 5 di scarto non sono mai state
spiegate**. L'anteprima del punto 3 va confrontata con le attese ricalcolate sul codice del ramo: **se
non tornano, ci si ferma e si spiega prima di scrivere**, anche se lo scarto e piccolo.

**Il punto 1 e fatto, e una delle tre condizioni scritte qui era sbagliata** (AppSopralluoghi
`a567e20` sul ramo, `fddd5a6` su `main`, verificati su `origin`; su `main` c'e anche il lancio delle
cinque P.IVA, `9fd764b`). `leggiCampiPersona` riduce a uno gli spazi ripetuti in nome, cognome,
mansione e reparto, e in nient'altro. **I campi delle 24, contati**: mansione 14, cognome 5, nome 3,
reparto 3 — gli spazi stavano tutti nel file, e il database li aveva gia puliti.

**La seconda condizione chiedeva di lasciare fuori la mansione, e la corsia non l'ha seguita, e l'ha
detto.** Aveva ragione. La premessa era che il dizionario dei ruoli legga la mansione della persona alla
lettera: **non la legge**. L'import delle nomine prende la mansione **dalla colonna del file**
(`testoLibero`, `nomineImport.ts:435` sul ramo, letto da qui) e la confronta con `chiaveTesto`, che gli
spazi li collassava gia. Senza la mansione le 24 non andavano a zero, cioe falliva la terza condizione.
**E la prova che conta e sua**: il piano delle nomine rifatto sui dati di produzione con il codice di
prima e con quello nuovo e **identico campo per campo** — 506 proposte, 50 da decidere, 3 non trovate.
Da qui, cercando nel loro codice un confronto alla lettera su `.mansione` fuori dai due import, **non ne
e uscito nessuno**: e una ricerca per forme — uguaglianze, `includes`, `startsWith`, mappe — e non una
lettura di tutto il codice, e va detto con quel limite.

**Le altre due condizioni sono mostrate.** La chiave delle persone senza codice fiscale e la stessa prima
e dopo — un caso di prova con doppio spazio nel cognome e nel nome, e sull'anteprima vera **tutte le
3.472 voci** con chiave, stato e id identici riga per riga, comprese le 229 senza codice fiscale. E col
codice del ramo le 24 **vanno a zero**, e ogni altra voce resta com'era: 480 gruppi, 77 nuove, 2 da
abbinare, 3 gruppi senza cliente, 1 scartata. **Controllo negativo**: sul codice di prima le prove che
devono cambiare falliscono e quelle che non devono cambiare passano; sul ramo tutte le prove sono verdi.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **il si al merge e al deploy del ramo delle emergenze**, dato ad AppSopralluoghi | l'anteprima delle anagrafiche con **MAISON 22 escluso attivamente**, contro le attese — e se la schermata non torna, ci si ferma |
| **AppSopralluoghi** | merge e deploy col si di Francesco, e la verifica per canale | registrare l'anteprima contro le attese, e la scrittura |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

### Prossimo passo per corsia · al 14 settembre 2026, il primo passaggio delle anagrafiche

**Il punto 2 e fatto**: merge `2f8d21a` e deploy in `success` alle 15:21:53 UTC, col si di Francesco
dato ad AppSopralluoghi. **Verificato da qui** che il deploy contiene la pulizia degli spazi
(`a567e20`); la corsia l'ha verificato anche sul bundle pubblico. Il file dell'anteprima e quello delle
attese, `ExportExcel (4).xlsx` del 9 settembre, «Report aggiornato al 09/09/2026»: **nessun export
nuovo**, perche le attese valgono per quel file e per le persone vince il file quando parla.

**Francesco ha aperto l'anteprima prima delle scelte a mano, e ha incollato la schermata qui.**
Ricontata: 3.480 da scrivere, 68 nuove, 3.412 aggiornate, 2 da abbinare, 3 gruppi senza cliente, 1
scartata. **Torna con le attese a meno delle due scelte non ancora fatte**: MAISON 22 agganciato da
solo a Via Quattro Novembre (+21 da scrivere, +4 nuove, +17 aggiornate) e IGEA senza abbinamento (−13).
3.472 + 21 − 13 = 3.480; 77 + 4 − 13 = 68; 3.395 + 17 = 3.412. **Lo scarto di 5 della schermata di
prima qui non c'e.** La corsia ha poi ricalcolato lo stesso stato col codice di `2f8d21a` e coincide
cifra per cifra.

**IGEA esce dal primo passaggio, e non per prudenza generica.** Nella tendina i due candidati hanno
**la stessa etichetta** — nome, P.IVA, San Bonifacio, 37047 — e differiscono solo nell'indirizzo, che
l'etichetta non mostra. Scegliere per posizione sarebbe un'ipotesi scritta nei dati di tredici persone.

**Le attese del primo passaggio**, ricalcolate da AppSopralluoghi sul codice pubblicato (`5a22720`),
con MAISON 22 escluso a mano e IGEA lasciata fuori: **3.459 da scrivere, 64 nuove** — 63 codici fiscali
mai visti piu uno senza —, **3.395 aggiornate di cui 0 che cambiano**, 2 da abbinare, 1 scartata, e **4
gruppi senza cliente**, perche l'esclusione a mano conta come cliente vuoto (`ImportAnagrafiche.tsx:120`).
Dopo la scrittura la stessa anteprima deve dare **0 nuove e 3.459 aggiornate**.

**Il secondo passaggio, per IGEA, con un metodo che non tocca i dati e ha tre controlli:** scelta
l'opzione, «Ispeziona» sulla tendina mostra il `value` — l'id del cliente, che si **legge**
(`ImportAnagrafiche.tsx:327`); a nome identico la tendina e ordinata per id, e 3f485f16 viene prima di
def8645c; dopo la scrittura, col si di Francesco, **13 persone su 3f485f16 e 0 su def8645c**, lette.
Mettere l'indirizzo nell'etichetta quando due clienti la condividono e la correzione giusta a lungo
termine, e **va nel prossimo giro di codice**: farne un deploy adesso, per tredici persone che il metodo
sa gia mettere al posto giusto, sposterebbe il recupero per una comodita.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | ricaricare la pagina e il file; **escludere MAISON 22** e lasciare IGEA com'e; controllare **3.459 / 64 / 3.395 / 2 / 4 / 1**; se torna, Applica — se no, fermarsi | il secondo passaggio per IGEA col metodo sopra; poi lo script della 1298 e l'import delle nomine |
| **AppSopralluoghi** | registrare la scrittura e la rilettura: 0 nuove, 3.459 aggiornate | il secondo passaggio di IGEA e la sua lettura; nel prossimo giro di codice, l'indirizzo nell'etichetta dei clienti omonimi |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

**Il primo passaggio e scritto, e la lettura del database dice che e giusto in tutto tranne una cosa —
e quella cosa e la piu istruttiva della giornata.** Riferito da AppSopralluoghi: Francesco ha escluso
MAISON 22 e premuto Applica, e la pagina ha risposto «3459 persone scritte». Poi, col suo si, una lettura
in sola lettura:

- **3.481 persone**, cioe 3.417 + 64;
- **MAISON 22 intatto**: 17 e 4, stesse schede per id, nessuna delle quattro di Porta Borsari anche
  sotto l'altro cliente — l'esclusione a mano ha tenuto;
- **i 63 codici fiscali che non esistevano da nessuna parte ora esistono ciascuno una volta**, 63 su 63
  sotto il cliente del loro gruppo e con la chiave giusta; la nuova senza codice fiscale una volta;
- 64 schede nate, tutte fra le attese; 0 codici fiscali doppi dentro un cliente; le 3.395 aggiornate
  esattamente quelle del piano, e nessuna sparita;
- il controllo negativo: la stessa lettura sulla fotografia di prima fallisce nei sei punti attesi.

**E non torna: le 24 schede degli spazi sono state riscritte con gli spazi doppi**, valori identici al
file. E esattamente l'esito del codice **di prima**; col codice di `2f8d21a` il ricalcolo da zero. **Nel
browser di Francesco girava il pacchetto vecchio**, nonostante il deploy verificato e l'indicazione di
ricaricare: l'app e una PWA con aggiornamento automatico, e una scheda aperta prima del deploy — o una
ricarica che non scavalca il service worker — serve ancora il codice precedente. Il perche esatto non e
accertato. **Il danno e piccolo**: i due codici sono identici su tutto il resto, provato su tutte le 3.472
voci e confermato dalla lettura.

**La lezione e grande, e va scritta come regola.** Da stamattina questa sezione verifica i deploy «per
canale»: stato su GitHub, bundle pubblico, versione dell'Edge Function. **Mancava un canale: il browser di
chi scrive.** Un deploy verificato dice cosa il server offre, non cosa gira nella pagina aperta. Sulla
prossima scrittura il costo non sarebbe piccolo: l'import delle **nomine** col codice vecchio non leggerebbe
le colonne delle emergenze come addetti antincendio.

**Quindi, prima di ogni scrittura da una pagina dell'app:**

- **la versione si verifica a vista, e in positivo.** Il pacchetto e uno solo, quindi basta la pagina
  Import nomine: deve dire **«Le nove colonne di ruolo, e quella che non entra»**, che esiste solo da
  `2f8d21a`. **Non basta che manchi il titolo vecchio**: si cerca la presenza del nuovo;
- per forzare l'aggiornamento, una **ricarica forzata** (Ctrl+Shift+R, che scavalca il service worker per
  quel caricamento), o chiudere tutte le schede dell'app e riaprirla, **prima** di guardare il titolo;
- **se il titolo non e quello nuovo, non si scrive.**

**Il passaggio di IGEA ripara anche le 24, senza script**: col codice nuovo il file le riscrive con uno
spazio. Attese ricalcolate da AppSopralluoghi sul codice di `2f8d21a` e sull'archivio di adesso: **Applica
3.472, 13 nuove** (12 con codice fiscale, 1 senza), 3.459 aggiornate, 2 da abbinare, 3 gruppi senza
cliente, 1 scartata. La pagina non mostra i campi cambiati, quindi il riscontro e la lettura dopo: **3.494
persone; 13 su 3f485f16 e 0 su def8645c; e le 24 schede, per id, con uno spazio solo**. Il controllo si fa
**su quelle 24**, non come «nessuno spazio doppio in tutto l'archivio»: altre schede nate a mano possono
averne, e renderebbero il riscontro ambiguo. **Se le 24 hanno ancora gli spazi, anche quel passaggio ha
girato col codice vecchio**, e si vede li.

**La rilettura dell'anteprima dopo il primo passaggio non serve piu**: la lettura del database prova di piu.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **ricarica forzata, e il titolo di Import nomine: «e quella che non entra»**; poi il passaggio di IGEA col metodo dell'id, contro 3.472 / 13 / 3.459 / 2 / 3 / 1 | il si alla lettura dopo; poi lo script della 1298; poi l'import delle nomine, **col titolo controllato di nuovo** |
| **AppSopralluoghi** | il passaggio di IGEA passo per passo a Francesco, **con il controllo del titolo come primo passo**; la lettura dopo sulle 24 per id | nello `STATO.md` la regola della versione nel browser, accanto a quella della verifica per canale |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

**IGEA aspetta domani, e FIORIO e fatto oggi.** Francesco e fuori ufficio, e `ExportExcel (4).xlsx`
(7.228.718 byte, 09/09 12:48) e rimasto sul PC dell'ufficio: non e su questo portatile, non e su Drive, e
nessuna sessione di la e raggiungibile. **Nessun export nuovo al suo posto**: le attese valgono per quel
file. Fermi finche il file non c'e: il passaggio di IGEA, la lettura delle 24 e l'import delle nomine, che
usa lo stesso file.

Lo script di FIORIO non passa dal file ne dal bundle, e AppSopralluoghi ha confermato sul codice che si puo
anticipare senza cambiare nessuna attesa: il passaggio di IGEA scrive solo `persona` e non legge `nomina`;
lo script non guarda mansione, reparto ne i totali; e l'import delle nomine riconosce la coppia persona e
figura senza la data, e non la riscrive. Le due posizioni nel loro `STATO.md` (ultimo passo in `f3d224b`,
terzo nella nota della pausa) erano equivalenti, e ora il fatto e scritto una volta sola. Letto qui prima
dei passi, uguale a origin. **Lanciato da Francesco: una riga, FIORIO STEFANO, I.VAR INDUSTRY SRL,
`addetto_antincendio`, 2001-05-14, nessun errore.**

| chi | adesso | poi |
|---|---|---|
| **Francesco** | recuperare `ExportExcel (4).xlsx` dal PC dell'ufficio, e controllarlo al byte | ricarica forzata e titolo; il passaggio di IGEA contro 3.472 / 13 / 3.459 / 2 / 3 / 1; il si alla lettura dopo; l'anteprima e poi l'import delle nomine, **col titolo controllato di nuovo** |
| **AppSopralluoghi** | registrare FIORIO nello `STATO.md` | il passaggio di IGEA passo per passo; la lettura dopo sulle 24 per id |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il recupero |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

**Il file c'e, al byte, e IGEA riparte.** 15 settembre 2026, sessione su `OVERALL-PC07`: in `Downloads`
c'e `ExportExcel (4).xlsx`, **7.228.718 byte, modificato il 09/09/2026 alle 12:48:21** — i due valori
scritti ieri sera. Nessuna impronta era stata registrata in nessuno dei tre repo, quindi il controllo al
byte e quello possibile, e l'impronta si scrive adesso perche il prossimo confronto non dipenda dalla
dimensione: SHA-256 `EA4E58E6F3EF9F2CDF08F675EF94CC3ED049BF24C4E64F17C9295FE078A34907`. Le altre
`ExportExcel` della cartella hanno dimensioni diverse, e la `(5)` delle 13:01 **non** e il file delle
attese. Nessun export nuovo: vale ancora la regola di ieri.

Il passo «recuperare il file» e chiuso; la sequenza di ieri resta com'era, nello stesso ordine.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | aprire l'app, **ricarica forzata** (Ctrl+Shift+R) e cercare in Import nomine il titolo **«Le nove colonne di ruolo, e quella che non entra»** — se non c'e, non si scrive; poi il passaggio di IGEA con `ExportExcel (4).xlsx`, col metodo dell'id, contro **3.472 / 13 / 3.459 / 2 / 3 / 1** | il si alla lettura dopo; l'anteprima e poi l'import delle nomine, **col titolo controllato di nuovo**; la decisione sulla lettura negata ad AppFormazione |
| **AppSopralluoghi** | guidare il passaggio di IGEA passo per passo, **titolo per primo** | la lettura dopo: 3.494 persone, 13 su 3f485f16 e 0 su def8645c, le 24 per id con uno spazio solo |
| **AppOverall** | nulla di nuovo | la prova generale, dopo il passaggio di IGEA e le nomine |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo |

### Il recupero e chiuso: 3.494 persone e 454 nomine · 15 settembre 2026, pomeriggio

Riferito da AppSopralluoghi con un messaggio fra sessioni, e **riletto qui sul loro `origin/main`**
(`f679127`, 19 commit dal `2140192`) prima di costruirci sopra (A19). Tutti i passi sono stati lanciati da
Francesco, ognuno con le attese scritte prima e una lettura dopo:

- **IGEA** (`e45cc2d`, `1f0a4ad`): 3.472 scritte; lettura 10 ok su 10 — 3.494 persone, 13 su `3f485f16` e 0
  su `def8645c`, MAISON 22 17/4, e **le 24 riscontrate per id**, 0 spazi doppi. Riparate senza script.
- **Un solo import delle nomine** (`578873a`, `64a4783`): attese calcolate sulla produzione con le funzioni
  della pagina, **35 / 51 / 1 / 392**, riconciliate riga per riga — 29 dalle emergenze, la 654 dalla
  qualifica, la 1931 dalla mansione, la 2268 e la 3049. Anteprima identica, 35 scritte, **427 nomine**.
  Sono gli stessi numeri che stamattina, da qui, avevo fermato perche le attese non c'erano ancora: adesso
  ci sono, e tornano.
- **La colonna RSPP, decisa con gli attestati** invece che chiedendo a chi compila il gestionale
  (`73154af`): delle 31 righe, 27 con attestato da datore-RSPP e **0 con i moduli A/B/C**; 20 `dl_rspp`
  nuove da colonna, con data e nota. **447.**
- **I testi** (`a04d39d`): 7 `dl_rspp` dove «RSPP» e scritto e c'e l'attestato da datore, senza data. **454.**
- **La `071`** (`45c7193`): «INSTALLATORE/MANUTENTORE IMPIANTI ANTINCENDIO E ANTIFURTO», 9 righe di DER
  ERSTE, e un **mestiere e non un ruolo** — nel dizionario senza figure, decisione di Francesco. Applicata
  dall'SQL Editor, quindi **non registrata in `schema_migrations`**, come le altre date da li.
- **La pagina nomine** (`bea1692`, verificata nel browser): chi ha gia la nomina scritta va fra le «gia
  risolte». **Restano 7 da decidere**: 1097, 1503, 2146, 2326, 3451 (RSPP senza un attestato che basti), 2248
  (TOP CAR S.N.C., che non e TOP CAR SRL), 2461 (ECODENT, solo Modulo A).

**La gemella della `071` e scritta qui: `0019`.** La struttura della `0007` e diversa dalla loro — `testo`
come chiave e `ruolo_testo_parola` al posto di `ruolo_testo_figura` — quindi la forma e una riga in
`ruolo_testo` e **nessuna parola**. Le query della `0007` partono dal `join` con le parole, e la riga non
entra ne fra le asserzioni ne fra le non risolte. Stringa confrontata **byte per byte** col loro file.
Provata su un cluster `initdb` usa e getta, 0001-0019 in ordine: 35 testi, 191 righe, 39 parole, 190
asserzioni e **9 non risolte, invariate**, 1 testo senza incarico. Controllo negativo, stesso cluster e
0001-0018 soltanto: 34 testi e 0 senza incarico. Il cluster e stato cancellato.

**Tre cose da tenere, che vengono dal loro messaggio e riguardano questo repo:**

1. **I conti della migrazione dati sono vecchi.** 619 clienti, 3.419 righe, N = 3.415 erano del 13
   settembre; oggi le persone sono **3.494** e le nomine **454**. `00_origine.sql` e gia scritto per contare
   nello stesso momento e non fidarsi di quei numeri, ma le **nomine** nella migrazione non hanno ancora un
   passo: esistono `00`, `01` clienti e `02` persone, e **nessun `03`**.
2. **Una migrazione applicata dall'editor non lascia traccia in `schema_migrations`.** Il livello della
   produzione di AppSopralluoghi non si legge da quella tabella: si legge dagli oggetti (la `068` del 13
   settembre l'aveva gia insegnato). Vale per qualunque controllo che faremo prima della migrazione.
3. **In quale progetto Supabase vivra il database di AppOverall non e deciso da nessuna parte.** La
   migrazione dati presuppone un database distinto. Sul piano gratuito i progetti attivi per organizzazione
   sono pochi — il numero va verificato, non ricordato.

E un'osservazione sul loro file, che e la regola dell'avviso letto da chi apre il documento: la testa del
loro `STATO.md` dice ancora **«Ultimo aggiornamento: 14 settembre 2026, pomeriggio»**, sopra diciannove
commit del 15.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | le **7 da decidere**, riga per riga; **la lettura negata ad AppFormazione**, ferma dal 14; **il progetto Supabase** di AppOverall | valutare se rigenerare la chiave `service_role`, che oggi e passata in una sessione per un'esecuzione sola |
| **AppSopralluoghi** | la **testa dello `STATO.md`** portata al 15 settembre; nessuna scrittura nuova finche Francesco non risponde sulle 7 | registrare le risposte sulle 7, e le nomine che ne escono con attese e lettura |
| **AppOverall** | **il passo `03` delle nomine nella migrazione dati**, provato su `initdb`, con le origini che le 454 portano oggi (colonna, mansione, qualifica, attestati) | la prova generale, quando il progetto Supabase e deciso |
| **AppFormazione** | fermi finche Francesco decide sulla lettura negata | le attese del caricamento aggiuntivo, sapendo che i 29 addetti dalle emergenze adesso sono nomine in produzione |

**Perche il `03` e non la prova generale.** La prova generale vuole una destinazione, e la destinazione non
e decisa; il passo delle nomine invece si scrive e si prova su un database usa e getta, e senza di lui la
prova generale porterebbe 3.494 persone e **zero** incarichi. **Cosa non si fa**: nessun export nuovo, e
nessuna lettura della produzione da questa corsia — le 454 si contano quando la prova generale le legge.

### Le tre risposte di Francesco · 15 settembre 2026, sera

Date nella sessione di AppSopralluoghi e riferite da loro con le sue parole; registrate nel loro `STATO.md`,
sezione «Le altre due decisioni di Francesco sulla sezione 8».

**1. Le 7: «1097 A, 1503 C, 2146 A, 2326 A, 3451 A, 2248 A, 2461 C».** A e il datore che fa da RSPP in
proprio (`dl_rspp`), C e «non e l'RSPP, o non si sa». Ne escono **5 `dl_rspp`**: 1097, 2146, 2326 e 3451
dalla colonna con la sua data, 2248 dalla qualifica («RSPP-SOCIO») senza data. **1503 e 2461 restano da
decidere**, e restano li: C non e un no, e un «non si sa», e una nomina non si scrive su un «non si sa».
AppSopralluoghi scrive come oggi — lettura prima, script che si annulla, lettura dopo — con attese **459
nomine**, e nella pagina 2 da decidere e 40 gia risolte. La 1097 e la 3451 non hanno codice fiscale e si
cercano per nome: e il caso in cui la lettura prima deve dire **una persona sola** per ciascuna, o ci si ferma.

**2. La lettura negata ad AppFormazione: «ok».** Le letture le lancia **Francesco dall'SQL Editor** sul loro
progetto, come ha fatto per AppSopralluoghi. Quindi non e un permesso passato a una sessione, e non vale la
regola della seconda mano: la sessione prepara la query in sola lettura, **chi la esegue e Francesco**.
AppFormazione non ha una sessione aperta: l'ordine le arriva da qui.

**3. Il progetto Supabase di AppOverall: «riusare piu avanti uno dei due progetti esistenti, svuotandolo
quando le app vecchie vengono archiviate».** Restano due domande che non gli sono state fatte — quale dei
due, e dove si fa la prova generale finche quel progetto e in uso — e **nessuna delle due serve adesso**:
- **quale dei due** dipende da quale app viene archiviata per prima, e quel giorno non e vicino;
- **dove si fa la prova generale**: su un cluster `initdb` usa e getta, come si provano gia la `01` e la
  `02`. Non occupa nessun progetto, e il progetto destinazione serve solo alla migrazione vera. **Non si
  chiede a Francesco una cosa che si risolve con uno strumento** (la lezione della password dell'11).

| chi | adesso | poi |
|---|---|---|
| **Francesco** | le letture che AppFormazione gli prepara, dall'SQL Editor; la conferma degli script delle 5 `dl_rspp` quando AppSopralluoghi li porta | il via al passo `03` di AppOverall |
| **AppSopralluoghi** | le **5 `dl_rspp`**: lettura prima, script, lettura dopo, contro **459** e 2 / 40 | 1503 e 2461 restano aperte e non si toccano |
| **AppOverall** | il passo `03` delle nomine nella migrazione dati, provato su `initdb` — **assegnato alla sessione `appoverall-ac`**, aperta da Francesco per ricevere l'ordine; questa sessione non tocca `supabase/migrazione-dati` ne nuove migrazioni finche lavora | la prova generale su `initdb`, con i conteggi letti nello stesso momento |

**Le 5 sono scritte: 459 nomine** (AppSopralluoghi `948b201`, riletto su `origin`). Lettura prima: una
persona per ciascuna, anche la 1097 e la 3451 cercate per nome, nessuna con `dl_rspp`. Script che si annulla
(`7567c04`), provato su `initdb` in quattro casi; lanciato da Francesco, 5 ok su 5. **1503 e 2461 restano
aperte e non si toccano.** Nella pagina nomine l'attesa e 2 da decidere e 40 gia risolte — **un'attesa, non
ancora vista a schermo**.

**Per la migrazione dati, e con una correzione arrivata un minuto dopo.** Il primo messaggio diceva che in
tutte le `dl_rspp` `note` spiega da quale decisione vengono; **non e cosi**: `note` e compilato solo sulle 32
scritte dagli script del 15, mentre tutte quelle scritte dalla pagina hanno `note = null` (`applicaNomine`
lo scrive sempre null). **La provenienza affidabile e `origine` piu `origine_testo`**; `note` si porta se c'e
e non classifica niente. Girato ad `appoverall-ac` nei due tempi, con la correzione esplicita — e la frase
sbagliata l'avevo gia rilanciata come «`note` e un dato di provenienza»: A19 nel verso di chi relaia.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | niente di urgente: le letture di AppFormazione quando arrivano; alla prossima apertura di Import nomine, guardare 2 / 40 **senza scrivere** | il si al merge e al deploy del giro di codice di AppSopralluoghi |
| **AppSopralluoghi** | **l'indirizzo nell'etichetta dei clienti omonimi**, nelle tendine di Import anagrafiche e Import nomine, su un ramo con una prova che fallisce su `main`; il segno della versione scelto fra cio che il bundle di prima **non** ha | `riepiloga` che non toglie i doppioni (364 proposte per 363 coppie), con la stessa forma; nessuna scrittura in produzione; le 4 P.IVA con la cifra sbagliata restano a Francesco |
| **AppOverall** | `appoverall-ac` sul passo `03`, con `origine` e `origine_testo` fra i dati di provenienza da portare | la prova generale su `initdb` |
| **AppFormazione** | il conto di `ruoli_persona` preparato per l'SQL Editor | le attese del caricamento aggiuntivo |

**Perche l'etichetta e non altro.** E il difetto che oggi ha fatto leggere un id con *Ispeziona* a Francesco
per scegliere fra due IGEA, e la prossima coppia di omonimi lo richiedera di nuovo: costa poco, e toglie un
passo manuale da ogni import futuro. Il doppione di `riepiloga` viene dopo perche e un difetto di conteggio,
non di dati.

**L'etichetta e pronta sul ramo, e `riepiloga` era chiuso dal 14: l'ordine era sbagliato, ed e mio.**
AppSopralluoghi, riletto su `origin`: ramo `etichetta-clienti-omonimi` a `b1765b0`, non pubblicato.
`distinguiOmonimi` aggiunge l'indirizzo solo a chi ha un'etichetta uguale a un altro — della sede operativa,
altrimenti dell'anagrafica — e, se manca o coincide, l'inizio dell'id. Vale nelle **tre** tendine che usano
`etichettaCliente`, compresa Import formazione. Prova: 5 casi su 5, e 4 falliscono sul codice di `main`. Il
segno della versione e scelto come si deve: 0 occorrenze nel bundle online, 1 nella build del ramo.

**`riepiloga` usa `senzaDoppioni` su `main` dal `6532500`** (verificato qui: `nomineImport.ts:605-607`). L'ho
assegnato leggendo la riga in testa al loro `STATO.md` che lo dava aperto, **senza aprire il codice**: e la
regola scritta sopra — «un avviso che vive altrove non protegge chi apre il documento» — nel verso di chi
assegna. La riga era vecchia e l'hanno corretta (`9e2430d`); il difetto di metodo e di qui. **Da qui in poi
un'assegnazione presa da una lista di cose aperte si verifica sul codice prima di mandarla**, e la corsia
che la riceve non prende voci da quella lista senza passare dalla sezione 8.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | il si o il no a merge e deploy delle etichette, **chiesto a lui direttamente** da AppSopralluoghi | alla prossima apertura di Import nomine, 2 / 40 senza scrivere |
| **AppSopralluoghi** | col si: merge, deploy, verifica per canale; poi nel browser le due IGEA con voci diverse, e da dove arriva l'indirizzo | **nessun passo nuovo**: l'esito con l'hash, e il passo successivo si chiede qui |
| **AppOverall** | `appoverall-ac` sul passo `03` | la prova generale su `initdb` |
| **AppFormazione** | il conto di `ruoli_persona` preparato per l'SQL Editor | le attese del caricamento aggiuntivo |

**Le etichette sono online, e il passo dopo e verificato sul codice prima di mandarlo.** Si di Francesco
chiesto da AppSopralluoghi con le tre tendine nominate: «si». Merge `03b1633`, 10 controlli verdi sul `main`
unito. **Riletto da qui per canale**: GitHub deployments da `03b1633` *Production* `success` alle 15:35:02
UTC, e `app-sopralluoghi.vercel.app` risponde 200 con `index-G0ow0SI3.js`; il segno sale da 0 a 1. **Manca
la verifica a vista**, e il deploy non e chiuso finche non c'e.

**Il passo dopo, e perche questo.** Nella Fase 0 le voci aperte sono due: D2, che si chiude quando Francesco
guarda un report vero e non si puo forzare, e **l'ATECO mancante**, che «non aspetta piu» il raccordo ma ha
una condizione scritta il 9 settembre e mai chiusa: il percorso a mano. **Verificato su `origin/main` prima
di assegnarlo**, applicando la regola di stamattina: `src/admin/Anagrafiche.tsx:881-884`, `scegli` scrive
`codice_ateco` **e** `livello_rischio` nella stessa patch al clic su un suggerimento. Un livello messo a mano
viene sovrascritto senza conferma, e il bottone RISCHIO (`:960`) sa gia applicarlo come gesto separato. **E
il punto in cui una campagna di riempimento cambierebbe classi di rischio in silenzio**, quindi va prima.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | la verifica a vista delle etichette e di 2 / 40, **senza scrivere**, guidata da AppSopralluoghi | il si al merge e al deploy del percorso ATECO; un report vero su un sopralluogo con box e componenti, quando capita, per chiudere D2 |
| **AppSopralluoghi** | riportare la verifica a vista | **il percorso a mano dell'ATECO**: il suggerimento scrive solo il codice, il livello cambia solo col bottone; prova che fallisce su `main` col caso «alto messo a mano, suggerimento che propone basso»; ramo, si di Francesco, segno della versione. **La campagna ATECO non parte**, e nessun codice ATECO si scrive in produzione |
| **AppOverall** | `appoverall-ac` sul passo `03` | la prova generale su `initdb` |
| **AppFormazione** | il conto di `ruoli_persona` preparato per l'SQL Editor | le attese del caricamento aggiuntivo |

**Il passo `03` delle nomine c'e, e riprovato da qui prima di costruirci sopra.** `appoverall-ac`, `fe9fade`: la
`0020` porta in `nomina` `origine` (quattro valori o null), `origine_testo` e `note`, con il vincolo che un testo
c'e se e solo se l'origine e dedotta; `03_nomine.sql` con dieci rifiuti prima di scrivere; la quarta select nel
`00`. **Riprovato qui su un cluster `initdb` separato**, 0001-0020: `prova_01` 38 ok, `prova_02` 29 ok,
`prova_03` 55 ok, **0 NO** — gli stessi numeri riferiti. Cluster cancellato.

Le decisioni prese la, accettate:
- **la figura viene solo da `ruolo_sicurezza_alias`** con `sistema = 'sopralluoghi'`, 13 codici su 13; un codice
  senza riga si rifiuta, e `dl_rspp` diventa `datore_lavoro_rspp` per via della sua riga, non per somiglianza;
- **`origine` null resta null**: la salvano null anche `salvaNomina` e l'import della formazione, quindi null e
  «non registrata», non «manuale»;
- **`note` si porta alla lettera e non classifica**; pesa solo nel rifiuto (h), dove una nomina dedotta che il
  nostro dizionario non ricava passa solo con una nota — le 8 degli script;
- **la sede e quella dell'unita d'origine**, e la stessa figura su due unita fuse resta due nomine, contate in un
  avviso. **Sui dati veri quel numero non e misurato.**

**Deciso qui: nessun vincolo unique su `nomina` adesso.** Il `03` e idempotente per id e controlla le collisioni
prima di scrivere; un vincolo scritto prima di sapere quante collisioni e unita fuse ci sono davvero e il vincolo
prima della misura. Si decide sui numeri della prova generale.

**E il passo dopo e la prova generale, preparata senza dati veri.** Uno script che fa tutta la migrazione su un
`initdb` usa e getta da quattro CSV fuori da qualunque repo, provato sui dati finti; e una pagina per Francesco
con cosa lanciare **nello stesso momento** nell'SQL Editor — le quattro select, i quattro conteggi, il controllo
di livello sul vincolo, e **due conteggi mai misurati**: nomine non attive e `da_confermare`, che sono i rifiuti
(d) ed (e). Meglio saperli prima che scoprirli da un rifiuto.

**L'estrazione vera porta dati personali su questo disco, ed e una decisione di Francesco**: si chiede quando lo
script e pronto, non prima e non per implicito.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | la verifica a vista delle etichette, quando AppSopralluoghi la porta | **il si o il no all'estrazione** per la prova generale, quando lo script e pronto |
| **AppSopralluoghi** | la verifica a vista | il percorso a mano dell'ATECO |
| **AppOverall** | `appoverall-ac`: lo script della prova generale e la pagina dell'estrazione, provati sui dati finti | la prova generale sui dati veri, col si di Francesco |
| **AppFormazione** | il conto di `ruoli_persona` preparato per l'SQL Editor | le attese del caricamento aggiuntivo |

### Francesco fuori · 15 settembre 2026, tardo pomeriggio

**Il percorso a mano dell'ATECO e pronto sul ramo, e aspetta il si.** AppSopralluoghi, riletto su `origin`:
ramo `ateco-scelta-senza-livello` a `3ee2cc6`, non unito; su `main` il punto di ripresa (`0f519d1`). La regola sta
in due funzioni pure di `formazione/ateco.ts` — `patchSceltaAteco` scrive solo il codice, `statoRischio` dice cosa
propone il bottone — e il componente le usa (`Anagrafiche.tsx:890`). Prova 6 su 6; sulla patch di `main`
trascritta alla lettera ne falliscono 4, **compreso il caso assegnato**: «alto» messo a mano resta «alto». Segno
della versione «premi per applicarlo»: 0 nel bundle online, 1 nella build del ramo.

**Accettata la decisione su `ateco_origine`: non si tocca**, ne dalla scelta ne dall'input libero, perche e la
cella del gestionale e l'unico riscontro. Il prezzo e scritto: dopo una correzione a mano l'avviso di divisione
incerta puo restare. **Si decide con la campagna ATECO**, che non e partita.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | fuori | al ritorno: la verifica a vista delle etichette e di 2 / 40; il si o il no a merge e deploy del ramo ATECO; il si o il no all'estrazione per la prova generale, quando lo script e pronto |
| **AppSopralluoghi** | **fermi**: nessun merge, nessun deploy, nessuna scrittura in produzione | al si: merge, deploy, verifica per canale e a vista |
| **AppOverall** | `appoverall-ac` sullo script della prova generale, **solo dati finti**, commit a ogni punto coerente | la prova generale sui dati veri, col si di Francesco |
| **AppFormazione** | il conto di `ruoli_persona` preparato per l'SQL Editor | le attese del caricamento aggiuntivo |
| **AppFormazione** | **la lettura negata e sbloccata**: preparare in sola lettura il conto di `ruoli_persona` in produzione, e passarlo a Francesco per l'SQL Editor | le attese del caricamento aggiuntivo, sui numeri che quel conto restituisce; i 29 addetti dalle emergenze sono gia nomine in AppSopralluoghi |

### Francesco rientrato · 15 settembre 2026, sera

**Il percorso a mano dell'ATECO e online.** Col si di Francesco, `appoverall-55` ha unito il ramo su `main` di
AppSopralluoghi: `29f3968`, `--no-ff` su `0f519d1`. Prima del push `ateco-scelta:check` 6 su 6, `ateco:check` e
`omonimi-etichetta:check` verdi, build verde. Push di Francesco; stato GitHub Vercel `success` alle 16:31:42Z
(deployment `6463589757`); sul dominio pubblico il bundle e `index-Da57U_gT.js`, lo stesso nome della build locale,
e «premi per applicarlo» passa da 0 a 1. AppSopralluoghi l'ha riletto per conto suo: bundle identico byte per byte a
`dist/`, la patch vecchia (codice e livello insieme) 0 nel bundle.

**Le tre verifiche a vista sono chiuse**, fatte da Francesco nel browser senza scrivere, annotate nello `STATO.md`
di AppSopralluoghi (`733d62c`, `20f82f9`):
- ATECO: su un cliente con un livello salvato, scegliere un suggerimento lascia il livello e mostra la proposta;
- import nomine: «ok» sull'atteso 0 da creare, 2 da decidere, 40 gia risolte — riferito, **non** i numeri uno per uno;
- tendina clienti: le due IGEA SRL UNIPERSONALE sono 2 voci distinte; se le distingua l'indirizzo o l'id **non e
  riferito**.

**Lungo la strada un falso allarme, e l'errore era nelle mie istruzioni.** Il primo esito fu «il livello e cambiato
da solo». Il cliente non aveva un livello salvato: il bottone mostra `livello ?? proposto` col colore pieno, e
cambiando codice cambia la proposta. Avevo scritto «un cliente il cui bottone mostra un livello», che non distingue
un livello salvato da una proposta; il criterio che distingue e **il bottone col campo ATECO vuoto**: «—» vuol dire
nessun livello salvato. Non l'ha introdotto il ramo: la stessa riga c'era su `0f519d1`.

**Da li il ritocco, si di Francesco:** ramo `rischio-proposta-distinta` a `0eaa1a2`, pushato, non unito. Senza
livello salvato il bottone ha il contorno tratteggiato e sotto «proposto, non salvato»; col livello salvato non
cambia. `ateco-scelta:check` 7 su 7, e il caso nuovo fallisce sul codice online; build verde; anteprima Vercel
`success` (deployment `6464457624`). **Merge e deploy dopo che Francesco l'ha visto.**

**Le 2 da decidere restano 2.** Francesco ha risposto qui «1503 b; 2461 C», poi nella sessione di AppSopralluoghi
ha corretto la 1503: QUALIFT fa parte di un gruppo il cui RSPP e di un'altra entita, quindi **C anche lei**. Nessuno
script, 459 nomine (`392c916`). Visto preparando: una nomina `rspp` avrebbe risolto la riga
(`nomineImport.ts:377`); e `ExportExcel (4).xlsx` non e piu nei Download, quindi `attese-nomine.mjs` senza
argomenti oggi si ferma.

**Si all'estrazione, e la prova generale non puo ancora partire: su questo PC PostgreSQL non c'e** (la correzione
sta piu sotto, dove questo file diceva il contrario). Consiglio dato a Francesco, non una sua decisione: i quattro
CSV non si estraggono finche PostgreSQL non c'e, altrimenti restano sul disco senza uso. La cartella
`C:\Users\Francesco\Documents\migrazione-privata\2026-09-15` e creata, vuota. Si puo intanto lanciare la
fotografia del punto 1 di `estrazione.md`, che non porta dati personali.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | scegliere fra installare PostgreSQL 16 e adattare lo script a Docker Desktop; guardare l'anteprima di `rischio-proposta-distinta` | la fotografia, poi l'estrazione; il si o il no al merge del ritocco |
| **AppSopralluoghi** | ramo `rischio-proposta-distinta` pronto; **main fermo** | al si: merge, deploy, verifica per canale e a vista |
| **AppOverall** | `appoverall-55`, nessun lavoro in corso | la prova generale sui dati veri, quando c'e PostgreSQL |
| **AppFormazione** | invariata: il conto di `ruoli_persona` per l'SQL Editor | le attese del caricamento aggiuntivo |


### Non e lo stesso PC, e qui PostgreSQL c'e · 16 settembre 2026, mattina

**La prova generale gira su questa macchina, e l'ho fatta girare.** `OVERALL-PC07`,
misurato adesso: `C:\Program Files\PostgreSQL\16\bin` con `initdb` e `psql` **16.10**,
servizio `postgresql-x64-16` avviato e in ascolto sul 5433; `pg_nel_path` di
`prova_generale_comune.sh` lo trova senza che gli si dica dove.
`verifica_prova_generale.sh` e **arrivata in fondo con tutte le prove passate**: il giro
intero sui dati finti, lo stesso giro con BOM, virgolette e CRLF, e le **nove** fermate
volute — i tre conteggi sbagliati, la nomina non attiva, il conteggio mancante, la
cartella dentro un repo, le colonne in un altro ordine, il file senza intestazione (con
la sua prima riga, che e un dato, **non** stampata) e il file non UTF-8. Cluster
fermato e cancellato ogni volta.

**E la password non e piu un ostacolo, perche la prova non usa il server installato.**
`cluster_avvia` fa un `initdb` in una cartella temporanea, `-A trust`, su una porta
libera fra 5487 e 5520: il PostgreSQL del servizio resta dov'e e non viene toccato.
L'ostacolo scritto qui sopra — «questa sessione non ha la password del PostgreSQL
locale» — su questa strada non si ripresenta.

**Ma «questo PC» non e lo stesso oggetto nelle due misure, e la differenza e il punto.**
Ieri sera la misura diceva l'opposto: nessun `initdb` su tutto il disco C:, Docker
Desktop 29.4.2 e la distribuzione WSL `docker-desktop`.

| | ieri sera | qui, adesso |
|---|---|---|
| `initdb` | assente su tutto C: | `16.10`, installato il **4 maggio 2026** |
| Docker | Desktop 29.4.2 | nessun `C:\Program Files\Docker`, `docker` non risponde |
| WSL | distribuzione `docker-desktop` | **non installato affatto** |

**Nessuna delle due misure e sbagliata, e la data di installazione esclude che lo sia:**
un PC che ieri non aveva `initdb` non puo averlo da maggio. Sono **due macchine**. A9
vale una terza volta, nel verso che mancava: l'assenza in una sessione non vale per
tutte, la presenza in una sessione non vale per il PC, **e la presenza su un PC non
vale per l'altro**.

**Dove questo sposta il lavoro: non e piu la scelta fra installare PostgreSQL e
adattare lo script a Docker, e la scelta di DOVE si estrae.** I quattro CSV non sono
mai stati estratti, e la cartella `migrazione-privata\2026-09-15` creata ieri **non e
su questo disco**. La prova sui dati veri vuole i CSV e PostgreSQL **sulla stessa
macchina**, perche i dati veri non si spostano da dove escono. Quindi due opzioni, e
sono per Francesco:

- **estrarre qui**, su `OVERALL-PC07`: PostgreSQL c'e gia, la prova e appena passata,
  non si installa niente;
- **estrarre sull'altro PC**, e li resta intera la scelta di ieri.

Non la decido io, perche dipende da quale delle due macchine arriva al gestionale, e
quello lo sa solo lui. **Cosa non fare intanto:** estrarre i CSV su una macchina e
fare la prova sull'altra.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | dire su quale PC si estrae; guardare l'anteprima di `rischio-proposta-distinta` | la fotografia del punto 1, poi l'estrazione; il si o il no al merge del ritocco |
| **AppSopralluoghi** | invariata: ramo `rischio-proposta-distinta` pronto, **main fermo** | al si: merge, deploy, verifica per canale e a vista |
| **AppOverall** | prova generale verde su questa macchina, nessun lavoro in corso | la prova sui dati veri, sul PC che Francesco indica |
| **AppFormazione** | invariata: il conto di `ruoli_persona` per l'SQL Editor | le attese del caricamento aggiuntivo |


### Si estrae qui, e la palla passa all'SQL Editor · 16 settembre 2026, mattina

**Francesco ha scelto: l'estrazione si fa su `OVERALL-PC07`.** Quindi non si installa
niente, e la scelta di ieri — PostgreSQL 16 o script adattato a Docker — **decade**.
Resta scritta qui sopra perche vale ancora per l'altro PC: se un giorno i CSV escono
di la, quel punto si riapre intero.

**Fatto da qui, e nessuna delle due cose tocca un dato:**
- cartella `C:\Users\Francesco\Documents\migrazione-privata\2026-09-16` creata, vuota,
  fuori da ogni repository (lo script rifiuta una cartella dentro un repo);
- `estrazione.md` aggiornata in due punti — «Prima di cominciare» e il punto 5 — perche
  diceva «sul PC di Francesco PostgreSQL non c'e, va installato prima di estrarre», che
  su questa macchina e falso. **Chi apre quella pagina oggi non deve incontrare
  l'avviso di ieri**: e la stessa regola dei «30 contro 31», applicata prima che serva.

**Il resto lo fa Francesco, e non e una divisione di comodo: la produzione da questa
corsia non si legge.** L'ordine, e perche e quello:

1. **fotografia** (punto 1), da cui escono i quattro conteggi attesi;
2. **quattro esportazioni** una per volta, colonne nell'ordine scritto (lo script
   confronta l'intestazione e si ferma se non coincide);
3. **fotografia di nuovo** (punto 4): se cambia un numero o una data, qualcuno ha
   scritto in mezzo e si ricomincia;
4. **la prova generale la lancio io** con i quattro numeri, e alla fine la cartella si
   cancella.

**Due cose si guardano nella prima fotografia, prima di esportare**, perche fermano la
prova dopo e si vedono prima:

- **`livello_origine` deve contenere `qualifica`.** Se esce vuota manca la `068`, e la
  select delle nomine del punto 2 fallisce: si scoprirebbe alla seconda query invece
  che alla prima riga.
- **`nomine_non_attive` e `nomine_da_confermare` devono essere `0`.** Non li ha mai
  misurati nessuno. Se non sono zero **ci si ferma li**: il passo 03 li rifiuta (d ed
  e), e cosa farne e una decisione che si prende qui, non un errore della prova.

**E serve un momento senza utenti**, per una ragione che sta scritta in fondo a
`estrazione.md` e che la fotografia non copre: vede le righe nuove e cancellate di
tutte e quattro le tabelle, ma le **modifiche** solo su persone e nomine — nella select
del passo 00 clienti e sedi non hanno un `updated_at`. Un cliente gia esistente
modificato fra due esportazioni non lo vede nessuno.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | la fotografia, poi le quattro esportazioni, poi la fotografia di nuovo; guardare l'anteprima di `rischio-proposta-distinta` | portare qui i quattro numeri; il si o il no al merge del ritocco |
| **AppSopralluoghi** | invariata: ramo `rischio-proposta-distinta` pronto, **main fermo** | al si: merge, deploy, verifica per canale e a vista |
| **AppOverall** | cartella pronta, `estrazione.md` aggiornata, niente altro in corso | la prova generale sui dati veri, appena arrivano CSV e numeri |
| **AppFormazione** | invariata: il conto di `ruoli_persona` per l'SQL Editor | le attese del caricamento aggiuntivo |


### La prova generale e arrivata in fondo sui dati veri · 16 settembre 2026, mattina

**Fatto.** Quattro CSV estratti da Francesco dall'SQL Editor, cluster usa e getta su
`OVERALL-PC07`, 20 migrazioni, passo 00, caricamento, 01, 02, 03, conteggi finali,
cluster cancellato. Ultima riga: **ARRIVATA IN FONDO**.

    clienti d'origine 608  ->  clienti 605, sedi 608      3 unita fuse per P.IVA
    righe d'origine 3494   ->  rapporti 3494, persone 3491
    nomine d'origine 459   ->  nomine 459, su 338 persone

Le due fotografie — prima e dopo le quattro esportazioni — sono **identiche tranne
`letto_il`**: i quattro file sono uno scatto solo. `livello_origine` conteneva
`qualifica` (la `070` e applicata), `nomine_non_attive` e `nomine_da_confermare` erano
`0`, quindi i rifiuti d ed e del passo 03 non avevano niente da rifiutare.

**Il primo giro si era fermato, e il motivo vale piu del rimedio: l'SQL Editor scrive i
valori nulli come la parola `null`.** Non campo vuoto — la parola. Nei quattro file
veri sono **11.912 campi**: 2.798 in `cliente.csv`, 760 in `sede.csv`, 7.009 in
`persona.csv`, 1.345 in `nomina.csv`.

**E la parte pericolosa e quella che non si e fermata.** Su `numero_lavoratori`, che e
un intero, il caricamento ha rifiutato alla riga 5 e l'errore si e visto. Su una
colonna di **testo** — `codice_ateco`, `mansione`, `note` — la parola «null» sarebbe
entrata **come testo**, e nessun vincolo avrebbe protestato: 605 clienti con un ATECO
che dice `null`, e nessuno che se ne accorge prima di leggerlo. **La colonna tipizzata
ha fatto da guardia per tutte le altre**, e per caso: se `numero_lavoratori` fosse
stata `text` come le sue vicine, la prova sarebbe arrivata in fondo con i conteggi
giusti e i dati sbagliati.

**Rimedio: si legge diversamente, non si riscrivono i file.** `prova_generale.sh`
accetta `null_scritto=null` e lo passa a `\copy`. I CSV restano come li ha prodotti il
database — nessuna trasformazione fra la fonte e la prova, che e il posto dove un
errore non lo vedrebbe piu nessuno.

**Provato, non solo scritto.** `verifica_prova_generale.sh` ha quattro prove nuove e le
passa tutte, insieme alle diciotto di prima: che senza l'opzione la prova **si ferma al
caricamento e dice cosa fare**; che con l'opzione **arriva in fondo con gli stessi
conteggi** dei file normali; che una parola malformata viene rifiutata ai controlli
iniziali; e che **un testo che vale «null» resta testo** quando il file lo produce
psql, perche PostgreSQL in quel caso lo scrive fra virgolette e in CSV non applica la
parola nulla a cio che e quotato.

**Cio che l'opzione non puo sapere, e chi lo sa.** Un valore vero uguale a «null»
diventerebbe NULL anche lui: l'editor mette le virgolette solo quando servono, quindi
nel CSV il caso vero e quello finto si scrivono uguali. Alla fonte si distinguono, e la
query che lo dice e in `estrazione.md` (una `jsonb_each_text` su tutte le colonne delle
quattro tabelle). **Deve dare quattro zeri, e finche non li da la prova resta una prova
con un'assunzione dentro.** E un'assunzione piccola e verificabile in dieci secondi:
quello che non si fa e lasciarla implicita.

**Un numero l'ho sbagliato mentre lo raccontavo**: ho scritto «2.229 campi» in un
messaggio prima di sommare le colonne. Sono **11.912**. Nessuna decisione ci stava
sopra, ma e la forma gia scritta in questa sezione — «un conteggio in un'intestazione e
la prima cosa che qualcuno cita senza rileggere il corpo» — con il posto cambiato: li
era un titolo, qui un messaggio, e un messaggio si cita allo stesso modo. Sta qui
perche il numero giusto sopravviva a quello sbagliato.

**E i quattro zeri sono arrivati: l'assunzione e chiusa.** Francesco ha lanciato la
query, e `cliente`, `sede`, `persona` e `nomina` danno **0** righe con un campo che
valga la parola «null». Quindi gli 11.912 campi erano nulli tutti e undicimila e
novecentododici, e `null_scritto=null` non ha mangiato niente di vero. **La prova
generale sui dati veri e passata senza assunzioni dentro** — e il controllo vale **per
questa estrazione**: un'estrazione nuova lo rifa, perche misura i dati, non lo script.

**Tre cose da guardare, dai numeri dei passi, e nessuna e per adesso:**
- **3 unita fuse** per P.IVA (608 -> 605) e **1 possibile doppione non fuso**: un
  cliente senza P.IVA usabile con la ragione sociale di uno che ce l'ha;
- **261 righe senza codice fiscale valido** su 3.494, e 3.230 codici validi distinti;
- **ATECO e almeno un livello non portati su 261 clienti**, che e il passo 01 che fa
  quello che deve: quei campi si contano, non si migrano.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | ~~la query dei quattro zeri~~ fatta, quattro zeri; dire se si cancella la cartella dei CSV; guardare l'anteprima di `rischio-proposta-distinta` | il si o il no al merge del ritocco |
| **AppSopralluoghi** | invariata: ramo `rischio-proposta-distinta` pronto, **main fermo** | al si: merge, deploy, verifica per canale e a vista |
| **AppOverall** | niente in corso: la prova e passata e verificata alla fonte | la migrazione vera si puo programmare |
| **AppFormazione** | invariata: il conto di `ruoli_persona` per l'SQL Editor | le attese del caricamento aggiuntivo |


### Il tratteggio e online, e il livello che non si toglie · 16 settembre 2026, mezzogiorno

**Col si di Francesco il ramo e unito.** `b52913e`, merge `--no-ff` di
`rischio-proposta-distinta` (`0eaa1a2`) su `main` di AppSopralluoghi, fatto da questa
sessione come il 15.09. Prima del push: `ateco-scelta:check` **7 su 7** — A7 e il caso
nuovo — `ateco:check` e `omonimi-etichetta:check` verdi, build verde. Deployment Vercel
`6478545843`, stato **success**.

**E l'alias pubblico l'ho provato, non dedotto.** Su `app-sopralluoghi.vercel.app` il
bundle e `index-BASYOjxn.js` e **contiene «proposto, non salvato»**: la versione online
e quella. Il nome **non** coincide con la mia build locale (`index-DSleJdSD.js`), e la
ragione e misurata e non supposta: qui non c'e `.env.local`, quindi il bundle locale
inlinea `https://placeholder.supabase.co` mentre quello di Vercel porta l'URL vero —
331 byte di differenza. **Il confronto per nome vale solo quando le due build hanno lo
stesso ambiente**, e il 15.09 ce l'avevano. Quando non ce l'hanno si confronta il
contenuto.

**La verifica a vista di Francesco ha trovato altro, e la parte utile non e quella che
sembrava.** Il suo primo caso — `A.S.D. FARESE 1921`, senza ATECO, bottone grigio
`RISCHIO —` — e il **terzo stato** e il ramo non lo tocca: senza codice non c'e nessuna
proposta da distinguere. Poi ha provato a togliere un ATECO appena messo, e ha scritto
che **il livello precedente resta**.

**Resta per costruzione, e fin qui e voluto.** Dal 15.09 il codice e il livello si
scrivono con gesti diversi: la scelta scrive il codice, il livello lo scrive **solo** il
bottone. Ma il rovescio non era stato guardato: **nel codice l'unico punto che scrive
`cliente.livello_rischio` e quel bottone** (piu l'import, e solo quando e nullo).
**Nessuna schermata riporta il livello a «non impostato».** Prima non si vedeva perche
il livello seguiva l'ATECO; adesso che e un gesto, gli manca il gesto opposto.

**E la domanda di Francesco — «ma il livello non deriva dall'ATECO secondo l'ASR?» — ha
corretto una mia frase sbagliata.** Avevo scritto che ATECO e livello sono
«indipendenti»: falso. **Il livello deriva dall'ATECO**; cio che e indipendente e la
**scrittura** del valore. E il motivo per cui si scrive con un gesto non e una scelta
di interfaccia: e la **decisione 8**, presa da Francesco il 9 settembre — *la classe
che l'Allegato IV assegna a una divisione non e un verdetto, e un default*, e
l'Interpello 1/2025 la sposta nei due versi. Piu due ragioni di questo archivio: il
codice memorizzato e **derivato** da una cella che puo essere ambigua (lo stato
«incerto»), e la scrittura automatica il 15.09 ha prodotto il falso allarme che il ramo
ha appena chiuso.

**Quindi il buco non e nuovo: e la meta non costruita della decisione 8.** Quella
scheda chiede che il livello porti con se **come** e stato deciso — `definito_mediante`,
motivazione, fonte, data, autore — e lo colloca nella prima migrazione del repo unico.
Oggi il livello si scrive e basta: non dice da dove viene e non si puo disfare. La cosa
nuova che il 16 settembre aggiunge alla scheda e **operativa**: manca anche il gesto
per **toglierlo**, e quello non aspetta il repo unico.

**Un secondo punto resta aperto e non l'ho capito dal codice.** Francesco dice che
l'ATECO, una volta messo, **non si lascia cancellare**. Dal codice dovrebbe: svuotare il
campo manda `codice_ateco: null`, `salvaCliente` scrive `vuotoNull(...)` cioe NULL, e
nelle migrazioni non c'e nessun trigger che lo ricalcoli. Quindi o il sintomo e un
altro, o c'e qualcosa che non ho visto: **si riproduce prima di ipotizzare**. Le
domande sono in fondo al messaggio di quella sessione, e servono le risposte di chi
l'ha visto.

**E una cosa che non sta in piedi e trovata per strada:** sotto il campo si legge
«modificabile anche dall'organigramma del cliente», ma la schermata Formazione dice
l'opposto — «impostalo nella sezione Dati anagrafici» — e nel codice non ho trovato
nessun punto che scriva `cliente.livello_rischio` fuori da quel bottone. Una delle due
frasi e vecchia, e finche non si sa quale **nessuna delle due si cita**.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | la verifica a vista online sul dominio pubblico; dire cosa succede esattamente quando cancella l'ATECO | il gesto per togliere il livello, quando c'e |
| **AppSopralluoghi** | riprendere: riportare il merge nel proprio `STATO.md`; **riprodurre** il caso dell'ATECO che non si cancella | secondo cosa esce: la correzione, oppure il gesto «togli il livello» disegnato accanto al bottone |
| **AppOverall** | niente in corso | la decisione 8 nella prima migrazione del repo unico: `definito_mediante`, motivazione, fonte, data, autore |
| **AppFormazione** | invariata: il conto di `ruoli_persona` per l'SQL Editor | le attese del caricamento aggiuntivo |


### Il livello di rischio ha tre gesti, e ognuno lascia scritto perche · 16 settembre 2026, primo pomeriggio

**Online:** `92b3596` su `main` di AppSopralluoghi (poi `bc8be78` con lo `STATO.md`),
deployment `6479348909` success, bundle `index-BpTh7V03.js` sul dominio pubblico —
verificato per contenuto: «proposto, non salvato», «togli il livello» e «scegli a
mano» ci sono, la frase vecchia «modificabile anche dall'organigramma del cliente» no
(0 occorrenze). `ateco-scelta:check` **13 su 13**, altri controlli e build verdi.
**La migrazione `072` l'ha applicata Francesco in produzione**: chi legge domani non
la deve rifare.

**Quattro giri di anteprima in due ore, e nessuno e uscito leggendo il codice.** Sono
usciti tutti da Francesco che provava su un cliente vero, uno dopo l'altro, e ogni
correzione ne scopriva un'altra che prima stava coperta:

| giro | cosa ha trovato | cosa ne e uscito |
|---|---|---|
| 1 | il livello applicato non si toglie | il gesto opposto |
| 2 | — | la **motivazione obbligatoria**, e la colonna che la tiene (mig. `072`) |
| 3 | la data non dice chi | la firma del tecnico collegato |
| 4 | riapplicando sparisce il motivo di prima | il testo si **accumula**, il passato dietro una «ⓘ N prima» |
| 5 | senza ATECO il livello non si puo proprio assegnare | **«scegli a mano»**, solo verso l'alto |

**Il quinto e il piu grosso, ed e una contraddizione con una decisione di questa
casa.** La decisione 8 dice che la classe dell'Allegato IV e un **default** che la
valutazione dei rischi sposta; l'app pero sapeva fare **una cosa sola**: applicare il
default. La classe diversa — quella che l'Interpello 1/2025 prevede quando emergono
rischi particolari — non si poteva nemmeno scrivere. La decisione era del 9 settembre,
il codice non l'aveva mai potuta eseguire, e **nessuno se n'era accorto in una
settimana**: se ne e accorto chi ha provato a usare la schermata per un caso vero.

**E il vincolo nuovo, deciso da Francesco: a mano si va SOLO verso l'alto.** Sembra
contraddire il «nei due versi» della decisione 8 e non lo fa, per una ragione che vale
la pena tenere: **la discesa che l'ASR 2025 prevede e per mansione, non per azienda**
(Parte II 2.1.1, chi non frequenta i reparti produttivi) — e per la persona il campo
esiste gia, «Rischio (override)», e accetta anche un livello piu basso. Quindi:
**azienda solo in su, persona nei due versi**, che e piu vicino alla fonte di quanto
fosse prima.

**Cosa e entrato in anticipo sul repo unico, e quanto poco.** La decisione 8 colloca
`definito_mediante`, motivazione, fonte, data e autore nella prima migrazione del repo
unico, e dice esplicitamente di **non** metterli nello schema attuale di
AppSopralluoghi. Qui e entrata **una colonna di testo**, e solo perche l'alternativa
era cancellare un livello senza lasciare traccia. Resta fuori tutto il resto: il
vocabolario, la fonte in un campo suo, e il «chi» come riferimento a `tecnico.id`
invece che come nome scritto nel testo. **Quando il repo unico costruira la forma
piena, quella colonna si legge e si smonta in quattro**: e per questo che le tre righe
hanno un prefisso riconoscibile (`tabella_ateco,` / `livello tolto` / `livello ALTO
scelto a mano`).

**La cosa che questa sessione ha sbagliato, e costa un giro.** Il primo rilievo di
Francesco — «metto un ATECO e poi non riesco a cancellarlo» — l'ho preso alla lettera e
ho passato mezz'ora a cercare nel campo ATECO un difetto che non c'era, arrivando a
scrivere in questo file che «si riproduce prima di ipotizzare». Il difetto era il
**livello**, non il codice. La domanda che l'avrebbe chiuso in un minuto era «cosa
succede esattamente quando premi?», e l'ho fatta al secondo giro invece che al primo.
**Chiedere il sintomo costa una domanda; dedurlo costa un ramo.**

| chi | adesso | poi |
|---|---|---|
| **Francesco** | niente in attesa da noi | provare i tre gesti sul dominio pubblico quando capita; dire se «solo in su» vale anche per la sede quando le sedi diventeranno di prima classe |
| **AppSopralluoghi** | `main` allineato e online, `STATO.md` aggiornato | quando riprende: nient'altro di aperto su questo |
| **AppOverall** | niente in corso | la decisione 8 nella prima migrazione del repo unico, e li la colonna `072` si smonta in quattro campi |
| **AppFormazione** | invariata: il conto di `ruoli_persona` per l'SQL Editor | le attese del caricamento aggiuntivo |


### Uno script che risultava eseguito, e non lo era · 16 settembre 2026, pomeriggio

**`ruoli_persona` in produzione, misurata oggi:** 216 righe, 121 persone distinte, 57
clienti — **gli stessi numeri del caricamento del 9 settembre**, quindi quella tabella
non l'aveva toccata nessuno. Per ruolo: `addetto_primo_soccorso 80`,
`addetto_antincendio 74`, **`rspp 28`**, `preposto 23`, `rls 9`, `dirigente 2`, nessuna
riga cessata.

**Il 28 e il numero che non doveva esserci.** Il 9 settembre AppFormazione aveva
dimostrato che la colonna «RSPP» del gestionale non contiene RSPP professionali ma
**datori di lavoro che fanno da RSPP in proprio** (art. 34): dei 28 nominati, **zero**
avevano un corso RSPP in archivio e 26 avevano gli attestati da datore — una
disgiunzione perfetta non e un caso. Aveva scritto `togli_ruoli_rspp.sql`, e nel
proprio `STATO.md` la frase era **al passato**: «*ha tolto le 31 righe*».

**Non era stato eseguito in produzione.** E A8 — *un impegno scritto e un impegno
eseguito hanno la stessa forma sulla pagina* — alla sua terza istanza e nella forma
peggiore: non «verra fatto», ma «**ha fatto**». Un futuro chiede di essere verificato,
un passato no. E le righe erano **28**, non 31: anche il numero nella frase era di
un'altra misura.

**Cosa stava facendo, nei due versi opposti, nella stessa tabella:**
- **28 persone** nominate `rspp` senza corso: il motore chiede loro il modulo
  professionale A/B/C, **che non devono fare**. Falso allarme, e si vede;
- **fino a 29 addetti antincendio** senza riga: il motore **non** chiede il loro corso.
  Non si vede.

**Il verso invisibile e quello che dura.** Il falso allarme lo segnala la prima
persona che lo legge; l'obbligo che non viene chiesto non lo segnala nessuno, e i due
convivevano in 216 righe.

**Eseguito da Francesco il 16 settembre**, nell'SQL Editor: 28 righe tolte, restano
**188**, e i cinque ruoli superstiti sono **identici** a prima (80, 74, 23, 9, 2) — che
e la prova che il `delete` ha preso solo cio che doveva. Le persone distinte scendono
sotto 121 perche chi aveva solo quel ruolo non ne ha piu nessuno: la formazione resta,
la riga si riporta dal foglio quando la colonna sara chiarita con chi compila il
gestionale. Corretto nello `STATO.md` di AppFormazione (`d0f47f8`), dentro la riga.

**E il riscontro incrociato che rende la cosa piu interessante di un difetto.** La
migrazione delle nomine di AppOverall, girata stamattina sugli stessi dati veri, legge
la stessa fonte e **distingue**: `datore_lavoro_rspp 116`, `rspp 3`. Il caricatore di
AppFormazione mappa la colonna RSPP dritta su `rspp`. Non e che il dato manchi o sia
ambiguo: **due corsie leggono la stessa colonna in due modi, e uno dei due e gia stato
dimostrato sbagliato da chi lo usava**. Quando il repo unico prendera i ruoli, la
lettura da tenere e gia scritta, ed e quella del passo 03.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | niente in attesa da noi | il si al caricamento aggiuntivo, quando l'anteprima e pronta |
| **AppFormazione** | **riprendere da qui**: i numeri di partenza ci sono (188 righe, `addetto_antincendio` a 74). Preparare il caricamento **aggiuntivo** dei 29 dal foglio, con anteprima e attese contate prima, e la riga 1298 da portare al 2001 | la vista che calcola l'esito `mancante`, che il ROADMAP tiene aperta |
| **AppSopralluoghi** | niente di aperto | — |
| **AppOverall** | niente in corso | la prima migrazione del repo unico: li i ruoli si leggono col passo 03, non con la mappatura del caricatore |


### Il buco degli addetti antincendio e chiuso, ed erano 29 · 16 settembre 2026, sera

**Fatto, e in quest'ordine:** anteprima in sola lettura, numeri guardati, poi la
scrittura — eseguita da Francesco nell'SQL Editor di AppFormazione, come il `db push`
del 13 e la rimozione degli `rspp` di oggi.

    ruoli_persona            188  ->  217
    addetto_antincendio       74  ->  103
    persone con un ruolo             136
    rimaste_fuori / arretri_rimasti    0

Piu la riga 1298, arretrata dal `2004-01-07` al `2001-05-14`: la decisione del 14
sulla data piu vecchia applicata anche a una nomina gia caricata.

**L'anteprima diceva zero su tutti e tre i contatori del residuo** — nessun cliente
non trovato, nessuna persona non trovata per codice fiscale, nessuna che avesse gia il
ruolo — e 29 righe che entravano, 29 distinte. **E il caso in cui non c'e niente da
guardare prima, e si riconosce solo guardando.**

**Erano 29 e non «fino a 24».** Il numero prudente del 14 settembre contava le righe
con Emergenze; con «Responsabile Emergenze» dentro — la risposta «Si, anche lui» — sono
29, e nessuna di loro aveva gia il ruolo. La prudenza aveva sottostimato, che e il
verso giusto in cui sbagliare.

**Cosa cambia in produzione da stasera:** il motore chiede il corso antincendio a 29
persone a cui non lo chiedeva. **Le scadenze che compariranno non sono nuove**: erano
dovute e non risultavano. Chi le guarda domani non deve leggerle come un peggioramento.

**E una cosa imparata sull'SQL Editor, che vale per chiunque generi SQL per questo
archivio.** Il primo tentativo usava `create temporary table ... on commit drop`, come
fa il caricatore del 9 settembre — che pero parla al database da `psql`, una sessione
sola. L'editor ha risposto `relation "_nuove" does not exist` al secondo comando: fra
un comando e l'altro **la sessione non e la stessa**. Per la stessa ragione **non
sopravvive nemmeno una transazione**, quindi l'anteprima non poteva essere un
`begin ... rollback`: e diventata una **SELECT che non scrive**, e la scrittura un file
a parte con tre comandi ognuno indipendente e ripetibile. Sta scritto in testa al
generatore, perche la prossima volta non ci si ricaschi.

**E la prova prima della produzione, che qui era gratis.** Su questo PC c'e
PostgreSQL: il generatore scrive anche un `prova_locale.sql` che semina un archivio
finto con le stesse societa e gli stessi codici fiscali — comprese le righe da
arretrare, con la loro data attuale, altrimenti quel pezzo non sarebbe stato provato —
ci lancia sopra la scrittura vera e verifica le attese. 29 nuove piu 1 arretrata fanno
30, la data si sposta, e rilanciando restano 30. **Poi sulla produzione e andata come
sulla prova.** Non e una coincidenza: e il motivo per cui la prova esisteva.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | cancellare la cartella `2026-09-16-antincendio` (29 codici fiscali) | niente in attesa da noi |
| **AppFormazione** | **riprendere da qui**: misurare cosa hanno acceso le 29 nomine — quante coppie requisito nuove, e quante senza corso in archivio | la vista che calcola l'esito `mancante`, che il ROADMAP tiene aperta da settembre |
| **AppSopralluoghi** | niente di aperto | — |
| **AppOverall** | niente in corso | la prima migrazione del repo unico |


### Il piano per chiudere la Fase 3, e una frase che avevo usato male · 16 settembre 2026, sera

**Scritto in `docs/piano-fase-3.md`.** E un piano e non un lavoro iniziato: dice cosa
manca, in che ordine, e quali tre domande vanno risposte prima che qualcuno scriva SQL.

**La correzione prima di tutto: «la prima migrazione del repo unico» e gia scritta e
applicata.** E la `0001`, del 9 settembre, e apre lei la Fase 3 — sta nella sua prima
riga. Io l'ho usata tutto il giorno, in tre tabelle di assegnazione, come se fosse il
prossimo passo. Non e un dettaglio di parole: «preparare la prima migrazione» suona
come un foglio bianco con delle decisioni davanti, «finire la Fase 3» e un elenco di
quattro cose misurabili di cui **una sola** ha un buco di forma.

**E il buco e questo: gli attestati non hanno una tabella.** Il catalogo c'e tutto —
`corso`, `corso_assolve`, le 53 righe di `credito_formativo`, le durate per dimensione,
i regimi precedenti — e l'anagrafe c'e ed e provata sui dati veri. Ma delle **13.350
righe di attestati** di AppFormazione non ce n'e una che possa atterrare: fra le 25
tabelle del repo unico non esiste un evento formativo. **Lo scadenzario non si calcola
dal catalogo, si calcola dagli attestati contro il catalogo** — quindi la Fase 4, che e
la fetta che deve dimostrare se l'impianto regge, oggi non avrebbe su cosa girare.

**Come ho fatto a non vederlo prima.** Guardando le migrazioni si vede un catalogo
formativo ricco e curato, con l'Allegato III per intero: la parola «formativo» era la',
e ho letto «la formazione c'e». C'era il **metro**, non le **misure**. E la forma di
A15 — un'etichetta che suggerisce una struttura diversa da quella che ha.

**Le altre tre cose non hanno buchi, hanno decisioni piccole davanti:**
- **i livelli e l'ATECO** che il passo 01 conta e lascia fuori (261 e 261): servono
  l'annata da attribuire ai codici e un **operatore** che firmi le valutazioni migrate,
  perche `valutazione_sede` vuole motivazione e autore e l'origine non li ha;
- **il seed dei 268 alias**, che ora ha la sua tabella (`corso_alias`, dalla `0004`) e
  va caricato come passo con i suoi conteggi: sono 268 giudizi presi a mano, e se si
  perdessero la tabella ci sarebbe lo stesso;
- **la sorveglianza**: le tabelle ci sono dalla `0005`, gli 808 accertamenti non hanno
  ancora un passo.

**E una cosa che oggi si e decisa da se.** I ruoli nel repo unico vengono **dal passo
03**, e `ruoli_persona` di AppFormazione non migra: si ricostruisce. Non e una
preferenza — stamattina la stessa colonna del gestionale letta dai due caricatori ha
dato `datore_lavoro_rspp 116 / rspp 3` di qua e 28 `rspp` sbagliati di la, e quei 28
sono stati tolti. **Quando due letture della stessa fonte divergono e una e stata
dimostrata sbagliata da chi la usava, la migrazione non ha piu una scelta da fare.**

| chi | adesso | poi |
|---|---|---|
| **Francesco** | leggere `docs/piano-fase-3.md` e rispondere alle tre domande in fondo (attestato, annata ATECO, operatore) | il si ai passi nuovi, uno per uno, come oggi |
| **AppOverall** | **il seed dei 268 alias**, che non aspetta nessuna risposta | alle risposte: la forma dell'evento formativo, poi il passo 04 |
| **AppSopralluoghi** | niente di aperto | quando si migra: `livello_rischio_definito_mediante` si smonta in righe di `valutazione_sede` |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove | la vista dell'esito `mancante` |


### Il seed dei 268 alias e l'export, e l'impronta me l'ha detto al terzo tentativo · 16 settembre 2026, sera

**Il seed e confermato contro il database vivo.** `corso_alias` in produzione su
AppSopralluoghi e il seed di questo repo danno **la stessa impronta** —
`77e35ffc…`, 268 righe — e i nove conti coincidono uno per uno: 268 totali, 237
mappati, 31 ignorati, 98 aggiornamenti, 7 parziali, 2 pregresse, 1 evidenza
incompleta, 39 codici distinti, 1 nota. **Nessuno ha cambiato un giudizio
dall'interfaccia dopo gli script.** La riga «resta da confermare contro il database
vivo», aperta il 10 settembre in testa al seed, e chiusa.

E il seed adesso non e piu un file che aspetta: **lo carica la prova generale**,
subito dopo le migrazioni, e ne **conta i giudizi** invece di limitarsi a caricarlo.
La prova negativa non toglie righe — ne cambia **una**: le righe restano 268, i
controlli interni del file passano lisci, e a protestare e il conteggio. E la forma
vera del rischio, perche un seed dimenticato o alterato non lascia nessun segno: la
tabella ci sarebbe lo stesso.

**Ma la conferma e arrivata al terzo tentativo, e i primi due erano miei.**

1. **Ho scritto la query con i nomi di colonna sbagliati.** Il testo del gestionale
   la si chiama `testo_gestionale`, qui `testo`: due schemi diversi per una ragione
   buona (scheda 9: l'identita e cio che si riceve), e io ho lanciato la versione di
   qua sulla loro produzione. Si e fermata con «column "testo" does not exist», che e
   il modo gentile di sbagliare.
2. **Poi ho creduto a una differenza che non c'era.** Le due impronte non
   coincidevano, e ho concluso che i 268 testi divergessero. Non divergevano:
   **`string_agg(... order by testo)` segue la collation del database**, il mio
   cluster e creato con `--no-locale` e ordina per byte, la produzione ordina con la
   sua. Le stesse identiche righe, concatenate in ordine diverso, danno impronte
   diverse. **Non stavo misurando i dati: stavo misurando la collation.**

**E la parte che brucia: l'avvertimento era scritto nel file accanto.** In fondo a
`seed/corso_alias_origine.sql`, dal 10 settembre:

> «L'impronta va ricontrollata ordinando per `riga_foglio` e **mai per `testo`**.
> Un'impronta che non torna per una ragione procedurale segnala un problema che non
> c'e, e la prossima volta nessuno ci crede piu.»

Quel file la sua impronta la ordina per `riga_foglio`, che e un intero e non ha
collation: chi l'ha scritto **il problema l'aveva gia avuto e l'aveva gia risolto**.
Io ho aperto la cartella `seed/`, ho letto l'altro file per intero, e la riga in
fondo a questo non l'ho letta. **E la quinta istanza della regola del 12 settembre**
— «quando una domanda resta senza risposta, rifare il giro dei file gia aperti
chiedendo la domanda NUOVA» — con l'aggravante che qui non serviva nemmeno rifare il
giro: bastava leggere fino in fondo un file che stavo usando.

**Cosa ne esce, oltre alla conferma.** `impronta_alias.sql` porta adesso le due
versioni della query, l'ordinamento `collate "C"` da tutte e due le parti, e scritto
perche: **un confronto fra due database non e un confronto finche non si fissa
l'ordine.** Costa sei caratteri e vale il terzo tentativo di oggi.

**E una cosa che non abbiamo ancora guardato**, emersa per caso mentre si cercava il
progetto giusto: in **AppFormazione** esiste una `corso_alias` con la colonna `testo`
— cioe lo schema di questo repo, applicato la. Quei 268 giudizi possono quindi vivere
in **due** posti, e il repo unico dovra sapere da quale legge. Non e un problema
oggi; e una domanda da non trovare per caso una seconda volta.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | niente; si puo cancellare `migrazione-privata\testi.csv`, che ha fatto il suo lavoro | le tre domande del piano (attestato, annata ATECO, operatore) |
| **AppOverall** | niente in corso: il seed e caricato, contato e confermato | alle risposte: la forma dell'evento formativo, poi il passo 04 |
| **AppSopralluoghi** | niente di aperto | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove | e dire quale `corso_alias` vive nella loro produzione, e perche |


### Gli attestati hanno una tabella e un passo · 16 settembre 2026, sera

**Il buco del piano e chiuso, ed era uno solo.** La `0021` porta `evento_formativo` e
due viste; il **passo 04** traduce `origine.formazione` in eventi. Da adesso la Fase 4
ha su cosa girare — non ancora il motore, ma il dato.

**Le tre risposte di Francesco sono diventate forma, non commenti:**
- «le collisioni si segnalano» -> **nessun `unique` su (persona, corso, data)**, e il
  passo le conta. Un vincolo li avrebbe fatto sparire cio che doveva mostrare;
- «la validita si conta dal completamento» -> `completa_il_percorso`, e accanto
  `estrazione`, perche a dire se un percorso e finito e **quale file** lo porta;
- «le ore si portano e il motore non le legge» -> `ore_origine` sta **nella tabella e
  non nella vista**. Una nota in un commento la leggono quelli che non la userebbero
  comunque.

**E una colonna che stavo per perdere, salvata da una sorella.** L'origine ha
`formazione.scadenza` — una scadenza **dichiarata**, non calcolata. La `0021` non
aveva dove metterla, e il passo 04 avrebbe dovuto buttarla. L'ha salvata la `0005`:
li nove righe su 769 dichiaravano una scadenza **anticipata**, e una scadenza solo
calcolata le avrebbe cancellate in silenzio — la riga resta, e sembra giusta. Adesso
`scadenza_dichiarata` e `scadenza_fonte` ci sono anche qui, con lo stesso vincolo che
lega il valore alla sua fonte.

**Il completamento non si calcola dalle ore, e il perche e una conferma della
decisione 3.** Sommare le ore degli spezzoni per vedere se arrivano alla durata
richiesta userebbe **la colonna che il gestionale ha riscritto**: il numero di oggi
contro la regola di ieri. Quindi i percorsi frazionati entrano **aperti** e il passo
lo stampa; quali siano completi lo dicono i due export `FormFraz`, e quelli entrano
con un passo loro.

**Provato, e la prova e cresciuta con lui.** La prova generale ha un quinto file e un
quinto conteggio atteso; `verifica_prova_generale.sh` ha sette prove nuove — 7
attestati scritti su 8, uno risolto per alias, uno ignorato a mano, due spezzoni
aperti, una collisione segnalata, una scadenza dichiarata portata fino in fondo, un
«da confermare» contato e non portato — piu la fermata sul conteggio sbagliato.
**Tutte le prove passate.**

**E la fonte era di nuovo una scelta fra due, decisa dallo stesso criterio di
stamattina.** Gli attestati stanno in tutti e due i repo: si prendono da
AppSopralluoghi perche li il codice del corso e **gia quello curato** dai 268 alias,
mentre in AppFormazione l'identita del corso e l'impronta `GEST-` che la scheda 9
declassa ad alias. Terza volta oggi che due letture della stessa fonte divergono e
una e gia stata dimostrata piu povera da chi la usava.

**Scheda 13 aperta, e in coda per decisione di Francesco.** «E possibile analizzare
in maniera deterministica gli attestati che ci vengono forniti?» — si, in due stadi
con proprieta diverse: dal file al testo e' deterministico solo sui PDF nati
digitali, dal testo ai campi lo e' del tutto. La scheda dice cosa darebbe (le **ore
davvero erogate**, il buco dichiarato non chiudibile) e cosa no, e lascia scritte le
quattro cose da decidere. La prima le regge tutte: **cosa si fa quando la lettura e
incerta, e chi firma.**

| chi | adesso | poi |
|---|---|---|
| **Francesco** | quando vuole: una **nuova estrazione**, che adesso ha **cinque** query e cinque conteggi (`estrazione.md` aggiornata) | la prova generale sui dati veri col passo 04 dentro |
| **AppOverall** | niente in corso | il passo 05: i due export `FormFraz`, che chiudono i percorsi aperti |
| **AppSopralluoghi** | niente di aperto | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove | — |


### Il passo 05 non chiude niente, perche le chiusure c'erano gia · 17 settembre 2026

**Prima una cosa che questa sezione non diceva: la sera del 16 la prova generale e
arrivata in fondo sui dati veri con il passo 04 dentro.** Ci e arrivata dopo quattro
fermate, e ognuna e un commit: due date nel futuro e 96 anteriori al 2008, che entrano
e si contano (`d64c667`); `numero_attestato`, letto da una loro migrazione e non dal
database (`09c1125`, `57a9b04`); il `\r` che il checkout di Windows metteva nel seed
degli alias (`0ef3dce`); `upper()` che in un cluster `--no-locale` non alza le lettere
accentate, e lasciava fuori 10 titoli e 1.324 attestati (`0c16d69`). La tabella qui
sopra diceva ancora «poi: la prova generale col passo 04 dentro». **E fatta.**

**E il passo che la stessa tabella assegnava a questa corsia era descritto male due
volte.** Diceva «il passo 05: i due export `FormFraz`, che chiudono i percorsi
aperti». Misurato oggi sui due file del 6 agosto (513 e 403 sessioni con data e codice
fiscale), contro i 13.350 `corsi_fatti` dello stesso istante:

- **i percorsi aperti del passo 04 non sono in quei file.** Sono i sette attestati con
  un titolo `... PARZIALE ...`, e nessuno dei due export nomina quei titoli. Restano
  aperti, e **nessun passo li chiude**: lo dice adesso il passo 04, dove prima
  prometteva il contrario;
- **e i percorsi completati non vanno chiusi, perche lo sono gia.** Tutti i 154
  (persona e corso) hanno un attestato dello stesso corso, e 163 sessioni su 513
  cadono esattamente su un attestato della stessa persona, dello stesso corso e dello
  stesso giorno. **Il gestionale registra la chiusura come un attestato**, e il passo
  04 l'aveva gia portata. Non c'e una sola chiusura da calcolare, e la decisione 2 —
  «non dalle ore» — non ha nemmeno un caso da tenere a bada.

Quello che mancava davvero erano **le sessioni**: AppFormazione le ha lasciate nel suo
`staging` apposta, per non contare due volte lo stesso corso, quindi fra i 13.215
`eventi_formativi` **non ce n'e nessuna**. Il passo 05 porta quelle, e le chiusure le
**riconosce**.

**Cosa e scritto, e provato:**

- **`0022`**: `evento_formativo.percorso_dichiarato`, `completato` o `in_corso`. La
  `0021` aveva affidato quella differenza a `estrazione`, che e un codice di file con
  una data: leggerci «chiuso» avrebbe voluto dire riconoscere un prefisso. E
  `v_percorso_formativo` contava come aperta **ogni** riga che non chiude — con le
  sessioni vere, **350** righe di percorsi finiti sarebbero risultate in sospeso;
- **`05_frazionata.sql`**: le sessioni entrano con `completa_il_percorso = false`; una
  sessione «Completata» che cade su un attestato **e** quell'attestato, non si
  riscrive, e l'attestato prende `parziale` e `percorso_dichiarato`. Si ferma su nove
  cose, fra cui **due caricamenti dello stesso file nello staging**: lo staging scarta
  solo le righe identiche, e una sessione passata da «in corso» a «completata»
  starebbe nei due file;
- **`estrazione.md`**: la sesta query, **nell'SQL Editor di AppFormazione**, sulle
  righe di `staging.righe_import`, con la sua fotografia. Provata su uno staging finto:
  la data dichiarata viene dal piede del foglio, che lo staging tiene come una riga;
- **la prova generale** carica sei file, esegue il 05 e legge il percorso **dalla
  vista**; la verifica ha nove controlli nuovi e tre fermate nuove. **Tutte le prove
  passate.** Rilanciato due volte di fila su un cluster a parte: il secondo giro
  scrive zero righe.

**Due cose che restano da guardare, e si contano invece di essere risolte:** **8**
sessioni in corso cadono sul giorno di un attestato dello stesso corso — in 7 quel
giorno c'e anche una sessione «Completata», la giornata che chiude un percorso e apre
il successivo; l'ottava non ha quella spiegazione. E **10** percorsi completati (contati per titolo) hanno
l'ultima sessione dopo l'attestato che li chiude, di 50-115 giorni.

**E un numero che avevo scritto senza misurarlo.** Nella prima stesura della `0022`
c'era «360 righe». Ricontato prima del commit: 350. Lo scrivo perche e la forma
esatta di cio che questa sezione chiede alle corsie — il numero giusto e arrivato
solo perche l'ho cercato **dopo** averlo scritto.

**Il piano della Fase 3 chiamava «passo 05» le valutazioni di sede.** Diventano il
**06**, e il piano e corretto. Le due decisioni che le bloccavano (annata ATECO e
operatore) Francesco le ha date il 16 settembre, quindi **non aspettano piu nessuno**
— tranne una misura che il piano stesso dichiara aperta: se a livello di divisione
2007 e 2022 diano classi diverse.

**Di passaggio:** `formazione-81-utils-src` su questo disco era indietro di due
commit, e adesso e allineato (`b6b7af1`): sono le durate iniziali dell'ASR 2025 e le
varianti delle attrezzature, trascritte dalla fonte.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | quando vuole: **una nuova estrazione**, che adesso ha **sei** query — le due nuove nell'SQL Editor di **AppFormazione** — e sei conteggi | la prova generale sui dati veri con il passo 05 dentro |
| **AppOverall** | **il passo 06: le valutazioni di sede.** Prima la misura su 2007 e 2022 a livello di divisione, poi i 261 livelli e i 261 ATECO che il passo 01 conta e lascia fuori, con la firma di Francesco sulla migrazione | il passo della sorveglianza, 808 accertamenti |
| **AppSopralluoghi** | niente di aperto | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove | — |

**E una cosa che AppFormazione non deve fare senza dirlo:** ricaricare o ripulire le
righe `fraz_completata` e `fraz_in_corso` di `staging.righe_import`. Da oggi il passo
05 le legge da li. Un secondo caricamento lo ferma — ed e giusto che lo fermi — ma e
meglio saperlo prima dell'estrazione che scoprirlo durante.


### La prova generale arriva in fondo con sei file · 17 settembre 2026, mattina

**Fatto.** Nuova estrazione di Francesco, sei CSV: quattro dall'SQL Editor di
AppSopralluoghi, due da quello di AppFormazione. Cluster usa e getta su `OVERALL-PC07`,
22 migrazioni, seed, passi da 01 a 05, cluster cancellato. Ultima riga: **ARRIVATA IN
FONDO**, al primo giro.

**La fotografia di AppSopralluoghi e identica prima e dopo** (10:11 e 10:18), con i
file salvati fra le 10:15 e le 10:16: 608 / 608 / 3.494 / 459, come ieri, ultime
modifiche del 15 settembre. Quattro zeri sui «null». Da AppFormazione: **13.215**
attestati, zero senza data; **un solo caricamento** per ciascuno dei due `FormFraz`,
513 e 407 sessioni — gli stessi numeri misurati sui file in Download.

    clienti d'origine 608      ->  clienti 605, sedi 608
    righe d'origine 3494       ->  rapporti 3494, persone 3491
    nomine d'origine 459       ->  nomine 459, su 338 persone
    attestati d'origine 13215  ->  eventi scritti 9917, su 2732 persone
    sessioni d'origine 920     ->  sessioni scritte 712, su 302 persone
    percorsi 6743: 6737 completi, 286 con sessioni aperte, 0 non completi e senza sessioni aperte

**Il passo 05 sui dati veri dice cio che la misura di stamattina prevedeva:** 146
sessioni riconosciute come chiusure (163 sui file, meno quelle di persone che
l'anagrafe non ha), 150 attestati segnati come chiusura, **zero** percorsi completati
senza attestato, **8** sessioni in corso sul giorno di un attestato. Fuori: 5 senza
codice fiscale valido, 57 con un codice che l'anagrafe non ha.

**Il numero che va guardato non e del passo 05: e del 04.** Degli attestati, **2.810
restano fuori perche l'anagrafe di AppSopralluoghi non ha quella persona** — piu di uno
su cinque. Contati a grandi linee sui file (senza stamparne una riga): sono circa
**1.000 persone**, e la domanda che AppFormazione ha gia scritto nel suo `docs/05` —
«storico dei cessati: se non si migrano, sono righe di eventi perse per scelta, e va
scritto» — qui diventa concreta. **Ma non sono tutti cessati da anni:** per circa
**120** di quelle persone l'ultimo attestato e del 2025 o del 2026. Chi sono quelle
120 — lavoratori che l'anagrafe dovrebbe avere, o gente uscita da poco — non si
deduce dal conteggio, e **la scelta se e come migrare lo storico e di Francesco**.

Gli altri fuori sono noti: 460 attestati con un titolo ignorato a mano, 119 senza
codice fiscale valido. E 40 terne persona-corso-data con piu attestati, segnalate e
non fuse.

**Ieri il passo 04 era arrivato in fondo e i suoi numeri non erano stati scritti da
nessuna parte.** Stamattina, per sapere se 2.810 fosse nuovo, non avevo con cosa
confrontarlo. Da qui in avanti i conteggi di ogni giro sui dati veri stanno in questa
sezione.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **cancellare la cartella `migrazione-privata/2026-09-17`** (`estrazione.md`, punto 6); e quando vuole, **decidere lo storico dei ~1.000 fuori anagrafe** — si migra, con quale persona, o si scrive che resta fuori | il si ad applicare `0021` e `0022` dove andranno applicate |
| **AppOverall** | il passo 06, le valutazioni di sede — invariato | la sorveglianza |
| **AppSopralluoghi** | niente di aperto | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove — invariato; e, se Francesco lo chiede, dire quante delle ~1.000 persone fuori anagrafe loro hanno fra le attive | — |


### Il passo 06: l'ATECO sulle sedi, e il rischio che viene dalla tabella non si scrive · 17 settembre 2026

**La misura che il piano lasciava aperta e chiusa, e non l'ho fatta io.** «Se a
livello di divisione 2007 e 2022 diano classi diverse»: AppFormazione l'aveva gia
misurata nella sua `0048` — le 88 divisioni dell'Allegato IV e le 88 di ATECO 2022
sono **lo stesso insieme**, senza resti — e l'allegato dice di se «ancorata ad ATECO
2007 agg. 2022». A due cifre le due annate non si distinguono, e `'2007'` e il nome
che la norma usa. Sesta istanza della regola di questa sezione: la risposta c'era,
in un altro repo, da giorni.

**Il piano diceva una cosa imprecisa, e la decisione 8 la correggeva gia.** «I
livelli qui sono `valutazione_sede`» — tutti. Ma la decisione 8 dice che **il default
calcolato dall'ATECO non si sovrascrive**, e la `0001` scrive `valutazione_sede` come
il posto dello **scostamento**. Quindi:

- **rischio uguale al default: non si scrive.** Si ricalcola, e se la tabella cambia
  la sede la segue;
- **rischio diverso, o senza divisione: si scrive**, con il default che la tabella
  darebbe e il testo che AppSopralluoghi ha scritto accanto (loro `072`);
- **antincendio e primo soccorso: si scrivono sempre.** Non hanno una tabella da cui
  ricalcolarli, quindi un livello definito e una decisione.

**E per distinguere i primi due casi mancavano due cose, tutte e due scritte oggi:**

- **la tabella divisione -> classe**, che nel database non c'e e non ci deve stare.
  La migrazione ne carica una **copia generata** dalla libreria
  (`genera_allegato_iv.js` -> `allegato_iv.sql`, commit `736699e`), con le tre
  divisioni dedotte marcate;
- **quattro colonne che l'estrazione non portava**: `ateco_origine` e i tre
  `*_definito_mediante`. Aggiunte **in coda** a `cliente.csv`, e la cella va sulla
  sede con la `0023` — la forma di `titolo_origine`, perche la divisione derivata
  male si riconosce solo li.

**Cosa e scritto:** `0023`, `06_valutazioni.sql`, i dati finti del 06, la prova
generale che lo esegue e conta sedi, annate, valutazioni e firma. **Tutte le prove
passate**, piu due fermate nuove (un livello fuori vocabolario, un ATECO che non e
una divisione). A parte: rilanciato due volte, il secondo giro non scrive niente; e
**una valutazione gia presa da un'altra mano non si scavalca** — resta la sua, e si
conta.

**Cosa il passo non porta, e conta:** il testo di un rischio **tolto** (non c'e un
valore da annotare) e il testo accanto a un rischio **uguale** al default che non
dice `tabella_ateco` — l'unico punto in cui la regola perde una frase, e sui dati
veri va visto quanti sono.

**Non e ancora passato sui dati veri**, e non puo: la cartella di stamattina e
cancellata, e `cliente.csv` adesso ha **quattro colonne in piu**. Serve una nuova
estrazione **intera** — sei file, perche la prova e un giro solo e le fotografie
devono essere dello stesso momento.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | quando vuole: **una nuova estrazione**, con la select di `cliente.csv` aggiornata in `estrazione.md` | la prova generale con il passo 06 dentro; lo storico dei ~1.000 fuori anagrafe resta sua |
| **AppOverall** | alla prova sui dati veri: guardare i due «NON portati» del 06 e le valutazioni scritte | il passo della sorveglianza, 808 accertamenti |
| **AppSopralluoghi** | niente di aperto | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove — invariato | — |


### Il passo 06 sui dati veri: 262 divisioni, zero valutazioni · 17 settembre 2026, tarda mattina

**Arrivata in fondo**, seconda estrazione del giorno (cartella `2026-09-17-b`, sei
file, `cliente.csv` con le quattro colonne nuove). Tutti i passi da 01 a 05 danno
**gli stessi numeri** del giro delle 10, e i file hanno le stesse dimensioni.

    unita d'origine 608  ->  divisioni ATECO 262, scritte su 262 sedi (annata 2007)
    livelli di rischio 262: uguali al default 262 (6 su una divisione dedotta), diversi 0
    come e stato deciso: tabella_ateco 1, non risulta 261
    antincendio 0, primo soccorso 0  ->  valutazioni vive: nessuna

**Il risultato e piu povero di quanto il piano facesse pensare, ed e la cosa da
sapere.** «Almeno un livello su 262» erano **262 livelli di rischio e nient'altro**, e
**tutti e 262 coincidono con l'Allegato IV**: in AppSopralluoghi il livello e stato
derivato dall'ATECO, come dice il loro `STATO.md`. Quindi, applicata la decisione 8,
**non c'e una sola valutazione da migrare**. Antincendio e primo soccorso sono vuoti
su tutte le 608 unita — lo zero della decisione 11 dell'11 settembre e ancora zero.
E la cella d'origine dell'ATECO non c'e su nessuna: la loro `065` lo prevedeva, si
riempie al prossimo import delle anagrafiche, che non c'e stato.

**Da questo giro la Fase 3 non ha piu un dato anagrafico che resta fuori per forma.**
Restano fuori per scelta, contati: i ~1.000 fuori anagrafe del passo 04, e cio che non
e mai stato raccolto (357 ATECO, i livelli di emergenza).

~~**Resta da ricevere:** la fotografia «dopo» di AppSopralluoghi e quella degli
attestati.~~ **Arrivate tutte e due.** La fotografia di AppSopralluoghi e identica
alle 11:02 e alle 11:11, con i quattro file esportati fra le 11:03 e le 11:05; quella
degli attestati dice 13.215 e zero senza data. Il giro e uno scatto solo.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **cancellare `migrazione-privata/2026-09-17-b`** | lo storico dei ~1.000 fuori anagrafe |
| **AppOverall** | il passo della sorveglianza, 808 accertamenti | — |
| **AppSopralluoghi** | niente di aperto | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove — invariato | — |

### Il passo 07: la sorveglianza dalla storia, e le nove anticipate erano due · 17 settembre 2026

**La fonte non e quella che il piano nominava.** «Gli 808 accertamenti» sono il foglio
«Visite» del 09/09, che porta **l'ultima visita** per persona e tipo. L'11 settembre
questa sezione aveva gia scritto che `ExportExcelVisiteFatte` e la storia e contiene
il foglio tutto (800 coppie su 800, piu 250): il piano del 16 non l'aveva raccolto, e
stamattina lo portavo in tabella con il numero vecchio. Il passo 07 legge la storia —
**1.383 visite** — e lo scadenzario del 06/08.

**E la misura fatta prima di scrivere ha corretto la scheda 10.** Le «9 scadenze su
769, tutte anticipate» — la ragione per cui `sorveglianza` ha una scadenza
dichiarabile — **sono 2**. Per sette di quelle persone l'ultima visita e di **fine
agosto**, lo scadenzario e del **6 agosto**, e la scadenza che dichiara e **esattamente**
quella della visita precedente piu la periodicita. Confrontando ogni scadenza con
l'ultima visita **nota a quella data**: 792 uguali, 2 anticipate (di 286 e 336
giorni), 0 posticipate. Anche l'esempio della scheda era uno dei sette.

**La forma regge, il numero no.** Due richiami anticipati veri bastano a giustificare
la colonna, e una scadenza solo derivata li cancellerebbe. Ma «nove richiami» era
**due fotografie di date diverse confrontate come se fossero una** — il difetto per cui
esiste `origine_estrazione.data_dichiarata`, commesso sulla tabella che l'aveva
motivata. La correzione sta **dentro il paragrafo** della scheda 10, non solo qui.

**Cosa e scritto:**

- **`estrai_visite.py`**: dai due xlsx ai due CSV, nella cartella dell'estrazione.
  Cerca le colonne **per nome** (i due tracciati sono diversi: 34 e 35 colonne),
  rifiuta una cartella in un repository, stampa solo i due conteggi e le due date.
  Provato su due xlsx finti con il tracciato vero;
- **`0024`**: `sorveglianza.estrazione`, e il commento della scadenza dichiarata con il
  numero giusto;
- **`07_sorveglianza.sql`**: una visita e persona + accertamento + data (9 righe della
  storia sono la stessa visita due volte, e entrano una); lo scadenzario si confronta
  con la visita **nota alla sua data**, e dove dissente la scadenza va **su quella
  visita** — se la persona e stata rivista dopo, la dichiarazione resta dove dice il
  vero, e si conta. Una riga «PIANIFICATA» non e un fatto;
- la prova generale carica **otto** file. **Tutte le prove passate**, con due fermate
  nuove; e nei dati finti c'e la forma esatta delle sette: una persona rivista il
  28/08 con la scadenza del 2025, che **non** risulta anticipata.

**Sui dati veri serve un giro nuovo**, il terzo di oggi: sei query come prima, e lo
script per le visite. Gli xlsx sono gia in `Download`.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | quando vuole: **l'estrazione con le visite** — le sei query di prima e `estrai_visite.py`, che posso lanciare io sui file in `Download` | lo storico dei ~1.000 fuori anagrafe |
| **AppOverall** | alla prova: guardare le due anticipate vere e le visite fuori anagrafe | con la sorveglianza, la Fase 3 ha un passo per ogni tabella che ha un'origine |
| **AppSopralluoghi** | niente di aperto | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove — invariato | — |


### La prova generale con la sorveglianza: otto file, e arriva in fondo · 17 settembre 2026, mezzogiorno

**Terzo giro del giorno, cartella `2026-09-17-c`.** Fotografie di AppSopralluoghi
identiche alle 11:32 e alle 11:35, quattro zeri, 13.215 attestati, un caricamento per
ciascun `FormFraz`. I due CSV delle visite li ha scritti `estrai_visite.py` dai file in
`Download`. I passi da 01 a 06 danno gli stessi numeri dei due giri di prima.

    visite d'origine 1383     ->  visite scritte 1046, su 778 persone
    scadenzario 812           ->  uguali al calcolo 764, anticipate 2 (scritte), posticipate 0
    coppie persona-accertamento 799, con l'ultima visita scaduta oggi 320

**Fuori, e contati:** 38 visite senza codice fiscale valido e **298 con un codice che
l'anagrafe non ha** — la stessa forma dei 2.810 attestati del passo 04, sulle stesse
persone o su altre; dello scadenzario 11 senza codice, 26 fuori anagrafe, 9 senza
nessuna visita fino al 6 agosto, 10 «PIANIFICATA». Una sola visita registrata due
volte fra quelle entrate (le altre otto misurate stamattina cadono fra le escluse).

**Le due anticipate vere sono entrate, e la vista le mostra.** Nessuna delle due e
su una persona rivista dopo il 6 agosto.

**E un conteggio che avevo scritto male e il giro ha mostrato subito.** La prima
versione della riga finale diceva «scadute oggi 555»: contava **ogni visita della
storia**, e una visita del 2019 e scaduta per forza. Il numero che serve e sull'ultima
visita per persona e tipo — 320 su 799 — e la riga adesso conta quello. Con la storia
dentro, **«per riga» e «per coppia» non sono piu la stessa domanda**: la vista e per
riga, e il motore della Fase 4 dovra chiedere per coppia.

**Con questo giro ogni tabella che ha un'origine ha il suo passo, provato sui dati
veri.** Restano fuori per scelta e contati: le persone che l'anagrafe non ha — adesso
con due numeri, 2.810 attestati e 298 visite — e cio che non e mai stato raccolto.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | **cancellare `migrazione-privata/2026-09-17-c`**; e, quando vuole, decidere lo storico dei fuori anagrafe, che adesso tocca anche le visite | — |
| **AppOverall** | ~~misurare quante persone fra i fuori anagrafe dei passi 04 e 07 sono le stesse~~ **fatto sui file del giro, prima di cancellarli**: 1.005 dagli attestati, 233 dalle visite, **202 in entrambi** — **1.036 persone** in tutto (codice fiscale di forma valida, conteggio fatto fuori dal database) | la Fase 4 |
| **AppSopralluoghi** | niente di aperto | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove — invariato | — |

### Le 1.036 persone fuori anagrafe entrano con il loro rapporto · 17 settembre 2026, pomeriggio

**Decisione di Francesco: strada C.** Delle tre messe davanti — lasciarle fuori (A),
portarle senza datore (B), portarle con il cliente per cui lavoravano (C) — ha scelto
la terza. Io avevo consigliato B, preceduta da una verifica sulle ~120 con una storia
recente; la verifica resta dentro C come conteggio, e la decisione e sua.

**C chiedeva una cosa che lo schema non sapeva dire: un rapporto finito senza una
data.** Il gestionale toglie dall'anagrafica chi esce e la data non la scrive (4 righe
in tutto). In `rapporto_lavoro` l'unico segno di fine era `data_cessazione`, e un
rapporto con la data vuota **sembra aperto**: mille ex lavoratori sarebbero entrati
nello scadenzario. **`0025`**: `rapporto_lavoro.cessato`, con il vincolo che una data
implica cessato e non il contrario. Il passo 02 adesso lo scrive anche lui (data, o
riga d'origine non attiva).

**Il passo 02b** (`02b_persone_fuori_anagrafe.sql`), fra il 02 e il 03, perche
attestati, sessioni e visite devono trovare queste persone quando le cercano:

- entra chi ha **una storia** (attestato, sessione, visita) e **non ha una scheda**;
- il nome da **AppFormazione**, che quelle persone le ha gia promosse; per chi ha
  **solo visite**, dal file delle visite — `estrai_visite.py` adesso porta anche nome e
  azienda. Senza nome non si entra, e si conta;
- il cliente si riconosce **per P.IVA**, poi **per ragione sociale** con la regola del
  passo 01 ma solo se porta a un cliente solo; altrimenti si crea **non attivo**;
- il rapporto entra **cessato**, anche per chi AppFormazione dà per attivo: la sua
  anagrafica e del 6 agosto, quella di AppSopralluoghi del 9 settembre, e vince la
  piu recente. **Quelle persone si contano a parte**, con quante hanno una storia dal
  2025: sono le «~120» che potrebbero essere lavoratori persi dall'anagrafe.

**Una query in piu nell'SQL Editor di AppFormazione**, `persona_storica.csv`, con la
sua fotografia. **Provato:** la verifica carica nove file e **tutte le prove passano**,
con cinque controlli nuovi; e nei dati finti le persone che finora restavano fuori
adesso entrano, e portano con se attestati, sessioni e visite — i conti dei passi 04,
05 e 07 sono cambiati di conseguenza, e lo dicono. Rilanciate anche le prove dei
passi 01, 02 e 03 su database usa e getta: passano.

**Sui dati veri serve un quarto giro**: le sei query, la settima di AppFormazione, e lo
script delle visite (che ora porta i nomi).

| chi | adesso | poi |
|---|---|---|
| **Francesco** | quando vuole: l'estrazione con `persona_storica.csv` | guardare quante persone AppFormazione da per attive e l'anagrafe non ha |
| **AppOverall** | al giro vero: i due numeri da guardare sono le **attive per AppFormazione** e le **ragioni sociali ambigue** | la Fase 4 |
| **AppSopralluoghi** | niente di aperto | se il giro conferma persone attive fuori anagrafe: sapere perche mancano |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove — invariato | — |

### La strada C sui dati veri: 1.025 persone, e 112 aziende che sono clienti di oggi · 17 settembre 2026, pomeriggio

**Arrivata in fondo al secondo tentativo**, cartella `2026-09-17-d`, nove file.
Fotografie di AppSopralluoghi identiche alle 12:18 e alle 12:20, quattro zeri;
AppFormazione 13.215 attestati, un caricamento per `FormFraz`, **4.164 persone (987
non attive) su 4.176 righe**.

**Il primo tentativo si e fermato sul caricamento di `visita.csv`, e il difetto era
mio.** I CSV delle visite li scrive `estrai_visite.py`, dove un valore mancante e un
**campo vuoto**; la prova li caricava con `null_scritto=null` come quelli dell'SQL
Editor, e una data di nascita vuota e diventata una stringa. **La verifica non
l'aveva visto perche esportava anche quei file con la parola «null»**: provava il
formato che mi aspettavo, non quello che lo script produce. Adesso i file dello
script si caricano sempre con la regola standard, e la verifica li scrive come li
scrive lo script.

    persone con una storia e senza scheda 1.025  ->  schede 1.025 (995 da AppFormazione, 30 dalle visite)
    rapporti cessati scritti 1.032, persone senza rapporto 0
    aziende: per P.IVA 112, per ragione sociale 1, ex clienti creati 1
    attestati 13.215   ->  12.637 scritti (erano 9.917), fuori anagrafe 0
    visite 1.383       ->  1.344 scritte (erano 1.046), fuori anagrafe 0
    persone 4.516, rapporti 4.526 di cui cessati 1.036, percorsi 9.001

**Due cose che il numero dice e la stima non diceva.**

- **1.025, non 1.036.** La mia stima di stamattina contava i codici fiscali con la
  **forma** giusta; il passo usa `codice_fiscale_valido`, che controlla anche il
  carattere di controllo. Undici avevano la forma e non il controllo;
- **le aziende sono quasi tutte clienti di oggi: 112 riconosciute per P.IVA, un solo
  ex cliente creato.** Quindi quelle persone non sono lo storico di clienti persi, sono
  **ex dipendenti dei clienti attuali** — e questo rende la strada C piu naturale di
  quanto sembrasse: il rapporto si attacca a un cliente che c'e.

**Le persone da guardare sono 34** — e **23 stanno in una sola azienda**, che e un segnale di causa unica (un'anagrafica non importata, o un'uscita collettiva) prima che di 23 casi separati: attive per AppFormazione (anagrafica del 6
agosto) e assenti da quella di AppSopralluoghi (9 settembre). **28 hanno una storia
dal 2025.** Sono entrate cessate perche vince l'anagrafe piu recente; se qualcuna
lavora ancora, e l'anagrafe che va completata, e fino ad allora le sue scadenze non
vengono seguite. In tutto le persone entrate con una storia dal 2025 sono 135.

| chi | adesso | poi |
|---|---|---|
| **Francesco** | ~~cancellare `migrazione-privata/2026-09-17-d`; decidere se vuole l'elenco delle 34~~ **fatto**: `elenco_da_guardare.py` ha scritto `da_guardare.xlsx` nella cartella `2026-09-17-e` — **34 persone, 28 con attivita dal 2025, su 7 aziende, e 23 su una sola**. Da compilare con le aziende: lavora ancora, o data di uscita | chi lavora ancora torna nell'anagrafica del gestionale, e il giro successivo lo porta attivo |
| **AppOverall** | la Fase 4 | — |
| **AppSopralluoghi** | se Francesco lo chiede: sapere perche 34 persone attive per AppFormazione non sono nella loro anagrafe | — |
| **AppFormazione** | misurare cosa hanno acceso le 29 nomine nuove — invariato | — |

### Tre cose decise a tarda sera, e una regola che si allarga

**L'import delle nomine lo esegue Francesco dal back-office.** Deciso da lui il 12
settembre nella sessione di AppSopralluoghi, e riferito qui. Quella corsia non lo fa
girare — né l'anteprima né la scrittura — e **le tre colonne restano fuori**. Chiude
il punto sul permesso nel modo migliore dei tre possibili: non un'autorizzazione
relaiata, non una firma chiesta e riportata, ma **chi decide che esegue**. La regola
«un ordine si relaia, un permesso di scrivere no» non è stata messa alla prova perché
non ce n'è stato bisogno.

**E la regola della sezione 8 si allarga, perché la quarta istanza ha una forma
nuova.** Stava scritto: *prima di dichiarare mancante un dato anagrafico, guardare se
un'altra corsia lo sta già leggendo dallo stesso file.* Le prime tre volte era un
**dato** — ATECO, ruoli, lavoratori. La quarta è una **misura**: «Addetti Emergenze è
l'addetto antincendio?» era già stata misurata da AppFormazione **l'11 settembre**, e
AppSopralluoghi ha lasciato la colonna fuori dicendo «non si deduce» — dando la
risposta giusta per la ragione debole.

> **Prima di dichiarare che una cosa non si sa, guardare se qualcun altro l'ha già
> misurata.** Vale per i dati e vale per le misure, e la differenza fra le due
> formulazioni non è accademica: «non si deduce» è una **posizione**, che fra un mese
> chi ha fretta riapre; «la deduzione è falsa su 24 righe e su altre 15 imporrebbe di
> scegliere quale data tenere» è un **fatto**, ~~e non si riapre~~.
>
> **Corretto il 14 settembre: la misura resta un fatto, e la domanda si e riaperta lo
> stesso** — perche la misura diceva come il gestionale **usa** due colonne, non se i due
> ruoli **siano** lo stesso. Quella e una decisione di significato, e l'ha presa Francesco:
> vedi «Addetto alle emergenze ed evacuazione = Addetto antincendio», piu sotto.

Lo ha scritto la corsia che aveva applicato la prudenza: *«due volte oggi ho lasciato
una cosa fuori dicendo non si deduce, e in un caso su due la misura esisteva già —
in un altro repo, sullo stesso disco, da un giorno.»*

**E le tre colonne escluse sono escluse per tre ragioni diverse**, che appiattite in
«tre colonne fuori» perdono quello che serve a riaprirle: `RSPP` per un **fatto
dimostrato** (contiene il datore dell'art. 34), ~~«Addetti Emergenze» per una
**deduzione smentita**~~, «Responsabile Emergenze» per un **argomento** che regge da sé.
~~Le prime due non sono più domande per l'Area Formazione: **sono chiuse**.~~ **La
seconda e riaperta e decisa da Francesco il 14 settembre: «Addetti Emergenze» entra come
addetto antincendio** — vedi il paragrafo di quel giorno. La prima resta chiusa. Resta semmai
se serva una figura nuova per le emergenze, che è un'altra domanda e non è urgente,
perché in tutti e due i casi quelle righe oggi restano fuori.

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

- **~~`PONTEGGI` e nominato, nella riga «100% conforme». Verde, e l'estensione costa
  la riga che dicono loro.~~ Ritirato, e poi RISOLTO la sera stessa: la `0059` sta in
  piedi su una gamba nuova.** Quel verde non era diventato falso — **non lo era mai
  stato**, perche l'export riproduce il catalogo e la riga confrontava il catalogo con
  se stesso. Ma le voci del gestionale che nominano i ponteggi sono **tre e senza
  varianti** — 28 ore (r5 e r228), 4 di aggiornamento (r41), tutte a 4 anni — quindi
  **tre curatele indipendenti danno 28 e 4**: l'Allegato XXI letto da AppFormazione,
  il catalogo di questo repo, il catalogo del gestionale. **Nessuna delle tre passa
  dall'export.** E il preposto ai ponteggi **non e una variante**: sta dentro le
  stesse voci, con la stessa durata, come l'Allegato XXI prevede — la differenza con
  le PLE, dove la fonte ha **due** percorsi e il catalogo ne tiene uno.
  **Piu una ragione che esclude l'alterazione**: la riscrittura e stata fatta «con le
  nuove ore dell'ASR25», e i **ponteggi non sono nell'ASR** — stanno nell'Allegato
  XXI, che l'accordo non tocca. Non c'era nessuna ora nuova con cui riscriverli.
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

**~~Su questa macchina un PostgreSQL locale c'e~~ — non sul PC di Francesco, misurato il 15 settembre 2026, sera.**
`appoverall-55` ha cercato `initdb.exe` su tutto il disco C: e non ce n'e, ne in `PATH` ne in
`C:\Program Files\PostgreSQL`; `prova_generale_comune.sh` risponde che non lo trova. Ci sono Docker Desktop (29.4.2)
e la sola distribuzione WSL `docker-desktop`. Dove siano girate le prove su `initdb` citate qui e quelle della prova
generale (`0058641`) **non l'ho misurato**: non su un PostgreSQL che oggi stia su questo disco. Ed e il disco che
conta, perche i dati veri non escono da li: la prova generale vuole PostgreSQL installato su questo PC, o lo script
adattato a Docker. Di nuovo A9, nell'altro verso: l'assenza in una sessione non vale per tutte, e la presenza in una
sessione non vale per il PC.

**E il 16 settembre la misura si sdoppia, e nessuna delle due va ritirata: sono due PC.**
Su `OVERALL-PC07` PostgreSQL **16.10** c'e — installato il 4 maggio 2026, servizio avviato — e la
prova generale ci e passata intera. Li WSL non e nemmeno installato, quindi non e la stessa macchina
misurata ieri sera, e la frase «la prova generale vuole PostgreSQL installato su questo PC» resta vera
**su quel PC**: quale dei due sia «questo» dipende da dove si estraggono i CSV. Vedi «Non e lo stesso
PC, e qui PostgreSQL c'e».

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

- **A14** **Un totale che esiste per far vedere una divergenza puo' produrne una che
  non c'e'.** Aggiunta il 12 settembre 2026. I due repo tengono lo stesso dizionario
  dei ruoli scritti a mano con due grane diverse — qui la chiave e il **testo
  verbatim** (34 asserzioni su 29 grafie), nel campo e la **chiave normalizzata** (32
  su 27) — e i due totali **non sono confrontabili**, benche' contino la stessa cosa.
  Un confronto fra 34 e 32 avrebbe dato «i dizionari hanno divergiuto» su due tabelle
  identiche, e stava per essere riportato da questa corsia.
  **La forma e' nuova, ed e' l'opposto di quella di A11.** Fino a ieri il difetto era
  sempre nello stesso verso — un totale che **tace** una differenza vera — e da qui
  venivano il `default` che falliva aperto, i 141 codici fiscali che nascondevano i
  12 senza, il blanket delle grandezze. Questo e' un totale che **grida** una
  differenza falsa. Il rimedio e' lo stesso di A11 e va detto una volta di piu':
  **si confrontano gli esiti e le chiavi, mai i conteggi di riga** — e prima di
  confrontare due numeri si guarda se contano la stessa grana, che e' A13 applicata
  ai conteggi invece che alle ore.

- **A15** **Un'etichetta che suggerisce una struttura diversa da quella che ha si
  legge come un fatto, e chi la legge non ha modo di sospettarla.** Aggiunta il 12
  settembre 2026 dalla corsia AppSopralluoghi, che l'ha proposta **dopo aver smentito
  una deduzione di questa corsia**. Il valore `titolare_socio` della loro `068` si
  legge come «titolare **o** socio» e vuol dire invece «la frase stabilisce che e' al
  vertice dell'azienda, per titolo o perche' lo dice con quelle parole». Da li avevo
  dedotto che fondesse un valore che risolve con uno che si astiene — cioe' che fosse
  ambiguo **esattamente sul confine art. 34 / art. 32**, quello che e' gia' costato 26
  nomine sbagliate — e l'avevo scritto come un fatto.
  **Era falso, e l'ha stabilito una misura sul seme**: `socio` da loro e' un valore suo
  e si astiene 2 su 2, come qui; `titolare_socio` risolve 14 su 14; e nessuna coppia
  (posizione, ruolo) fa tutte e due le cose. Cio' che quel nome fonde sono i **due
  valori che qui risolvono allo stesso modo**, `datore` e `titolare`: la traduzione
  perde la **provenienza** dell'asserzione, non l'esito. Il confine dell'astensione e'
  intatto in tutte e due le tabelle.
  **E la forma e' diversa da A14, che non la copre.** La' era un **totale** che grida
  una differenza falsa, e si rimedia confrontando esiti e chiavi invece di conteggi.
  Qui e' un **nome**, e un nome non si confronta meglio: **o si cambia, o si spiega
  dove qualcuno lo incontrera'**. E' la stessa forma del commento «la stringa esatta
  esportata» di `corso_alias.testo`, falso su 211 righe su 268, che aveva gia' fatto
  sbagliare qualcuno prima di essere corretto dalla `0008`.
  **Non e' stato rinominato, ed e' la scelta giusta**: quella tabella e' caricata, un
  rename e' una migrazione, e non e' una cosa che due sessioni decidono di sera fra
  loro. La spiegazione e' andata nei due posti dove qualcuno incontrera' il valore,
  con i numeri accanto perche' chi rilegge non debba fidarsi. Se un giorno si
  rinomina, il nome che descrive cio' che fa e' qualcosa come `al_vertice`.
  **E la lezione su di me, che e' la ragione per cui questa assunzione sta qui e non
  in una nota:** avevo dedotto una struttura **da un nome** mentre il seme era sul
  disco, a due comandi di distanza, in un repo che questo programma dice di guardare
  invece di chiedere. La regola contro cui ho sbagliato e' la prima riga della sezione
  8.

- **A16** **Due prove che coprono meta ciascuna sembrano una prova intera finche
  sono una sola.** Aggiunta il 12 settembre 2026 dalla corsia AppSopralluoghi, che
  ha diviso in due comandi cio che era uno: `ruoli:check` prova la **regola** contro
  un corpus dichiarato, `nomine:dryrun` prova il **foglio** aprendo un file vero.
  Nessuna delle due copre l'altra — «una regola giusta su un foglio che non si apre
  non importa niente; un foglio che si apre con una regola sbagliata importa il dato
  sbagliato» — e finche esisteva solo la prima sembrava di avere una verifica intera.
  **E la stessa forma vale sui vincoli, dove si e presentata lo stesso giorno**: un
  controllo negativo prova che un vincolo **morde**, non che sia il vincolo
  **giusto**, ed e per questo che l'insieme vuoto e passato sotto quattro controlli
  negativi tutti superati. La domanda che le scopre e sempre la stessa: **di questa
  cosa, quale meta sto provando?**

- **A17** **Il difetto peggiore puo arrivare RIPARANDO, e un errore inerte diventa
  pericoloso il giorno in cui qualcuno ci costruisce sopra.** Aggiunta il 12
  settembre 2026, e viene da due episodi della stessa migrazione.
  **Il primo: riparando.** Un rilievo giusto di AppFormazione ha fatto sciogliere un
  vincolo **troppo stretto** — rifiutava un caso legittimo della fonte — e nessuna
  delle due corsie ha guardato cosa quel vincolo facesse **anche di giusto**. Il buco
  che ne e uscito era **peggiore di quello che si stava chiudendo**: l'insieme vuoto
  faceva sparire una riga (un buco prima o poi si nota), l'insieme incompleto
  produceva un «sufficienti CERTO» **confidente e falso**. La forma operativa: **un
  vincolo troppo stretto non si toglie, si stringe meglio — e se si toglie, cio che
  teneva va rimesso da un'altra parte prima.**
  **Il secondo: l'errore inerte.** La nota di `PREPOSTO` nella `0004` attribuiva
  all'ASR 2025 una cadenza che era **legge dal 2021**, e per giorni non e costata
  niente: nessuna data poggiava su quella riga. La `0014` e la **prima migrazione che
  ce ne mette una**, e da li in poi quell'errore diventa utilizzabile — chi datasse la
  biennalita dal 19/05/2025 sbaglierebbe di quattro anni il termine di ogni preposto
  formato fra il 2021 e il 2025.
  **Da cui una lente per cercare, e non solo una nota da ricordare:** un commento
  falso non costa niente finche nessuno ci costruisce sopra, e **il momento in cui
  qualcuno ci costruisce non e il momento in cui lo si rilegge**. Vale la pena passare
  le note delle tabelle gia caricate con questa domanda — *cosa succede a questa
  frase il giorno in cui una colonna nuova la usa?* — invece di aspettare che sia una
  migrazione a scoprirlo.

- **A18** **Una conclusione giusta appoggiata a una ragione troppo piccola sopravvive
  finche nessuno la discute, e cade al primo che la discute.** Aggiunta il 12
  settembre 2026 dalla corsia AppSopralluoghi. Il ripiego cognome+nome sul lettore dei
  ruoli era stato acceso citando **19 incarichi persi e l'unico ASPP** — numeri veri, e
  **piccoli**: facevano sembrare il ripiego un rammendo per pochi casi. Misurato dopo:
  quel ripiego **regge meta del lavoro che l'import esiste per fare**, perche sulla
  meta dedotta dell'organigramma manca il codice fiscale su **quasi due righe su tre**.
  La decisione era giusta e la motivazione era **sottodimensionata di un ordine di
  grandezza**.
  **Non e una conclusione sbagliata, ed e per questo che nessuna rilettura la trova**:
  chi rilegge controlla se la conclusione regge, e regge. Cade il giorno in cui
  qualcuno con fretta dice «per diciannove righe non vale la pena» — cioe quando la
  ragione, non la conclusione, viene messa alla prova. **La difesa e scrivere il numero
  grande dove la decisione si rilegge**, non nel documento che l'ha motivata: loro
  l'hanno messo al punto del codice dove il ripiego si accende, che e dove qualcuno un
  giorno si chiedera se valga la pena tenerlo.
  E la sua parente prossima si e presentata **la stessa sera da questa parte**: la
  scheda 12 motivava la validita temporale con un caso che ne guadagnava **zero**
  mentre quello che ne guadagnava 76 non era nominato. Conclusione giusta, ragione
  sbagliata; li conclusione giusta, ragione troppo piccola. **In tutti e due i casi a
  reggere era il numero che nessuno aveva contato.**

- **A19** **Un fatto ricevuto su cui si sta per COSTRUIRE va verificato alla fonte;
  uno su cui si deve solo essere d'accordo, no. La differenza non e la fiducia, e
  quanto ci pesa sopra.** Aggiunta il 12 settembre 2026, e le due meta vengono dalle
  due corsie che se la sono fatta a vicenda nella stessa ora.
  **Cosa e successo.** Questa corsia ha scritto nella `0015` che
  `rapporto_lavoro.import_key` «non e un vincolo, e una stringa» — falso: l'aveva
  resa `unique` **due ore prima**, nella `0013`. AppSopralluoghi l'ha ricevuto come
  fatto e ci ha costruito sopra la riga che ha chiamato «la cosa piu importante che
  questa consegna possa dire», **senza aprire la `0013`**, che stava sullo stesso
  disco e che aveva gia aperto quattro volte quel giorno. La verifica costava due
  comandi.
  **Perche la forma «un fatto» e potente e per questo pericolosa.** Poche ore prima la
  stessa corsia aveva osservato che **dare un fatto invece di una proposta fa muovere
  le cose** — «se avessi scritto *dovreste correggere la 0001* avreste valutato una
  proposta invece di un fatto, e sarebbe finita in una lista». E vero, **e vale anche
  quando il fatto e falso**: *un fatto sbagliato consegnato come fatto viaggia piu
  veloce di una proposta sbagliata*. **La forma non ha un dispositivo di sicurezza, e
  quello deve metterlo chi riceve.**
  **E la soglia e quella che rende la regola applicabile invece che virtuosa:** non si
  verifica tutto — si verifica cio su cui si sta per costruire. E la settima istanza
  della regola della sezione 8 in due giorni, con un'aggravante che le altre sei non
  avevano: le prime erano «non ho cercato», questa e **«mi e stato detto, e non ho
  controllato»** — peggio, perche la fonte era a portata di mano **e aveva appena
  dimostrato di poter sbagliare**.
  **E la frase falsa va ritirata dove qualcuno l'ha letta, non cancellata**: chi apre
  quel documento domani deve vedere che quella riga era sbagliata e **su cosa era
  stata costruita**, non trovarne una giusta al suo posto come se niente fosse.

- **A20** ~~Una conferma che la fonte puo fabbricare non e una conferma; una
  divergenza si.~~ **CORRETTA la sera stessa, e la diagnosi era sbagliata anche se la
  conclusione operativa e giusta.** La formulazione originale diceva che la
  riscrittura dello storico aveva **distrutto** la prova di
  `durate-come-controllo.md`. **Non l'ha distrutta: ha fatto vedere che non c'era.**
  **La misura che lo stabilisce non passa dall'export** (AppFormazione, doc. 23, e
  verificata da qui sulle 268 voci di `righe.json`): la colonna `ore` dell'export
  **riproduce la durata della VOCE DI CATALOGO** sotto cui la riga e registrata —
  sette titoli su sette del preposto (8 · 12 · 8 · 12 · 6 · 6 · 3), **zero varianza
  dentro un titolo**. Quindi le 13.348 righe **non danno 13.348 osservazioni: ne
  danno al massimo 268 replicate.**
  **Da cui il fatto che rovescia la lettura**: quel documento non confronta
  *erogato* contro *atteso*. Confronta **catalogo contro catalogo** — le 268 voci
  del gestionale contro i 40 codici di questo repo. La «terza gamba» che dichiara —
  «l'export dice cosa e stato EROGATO» — **non e mai esistita**, e la riscrittura
  d'imperio e il **fatto che ce l'ha fatto notare**, non la causa.
  **La conclusione operativa resta, e le divergenze restano utili per un'altra
  ragione di quella che credevamo:** non dicono «qualcuno ha erogato una durata
  diversa», dicono **«i due cataloghi non concordano su quel corso»** — che e
  esattamente l'uso che ne era stato fatto bene (il carrello combinato a 16 ore e una
  voce che il gestionale ha e questo repo no), e **non** l'uso di «una seconda durata
  realmente erogata».
  **E la regola generale sopravvive in una forma piu stretta e piu utile**: prima di
  usare una conferma, chiedersi **se i due lati del confronto siano davvero due** —
  se la fonte puo fabbricarla (il caso che A20 diceva) **o se sia la stessa cosa
  confrontata con se stessa** (il caso che era). Nel secondo la conferma non e
  fragile: **e vuota**.
  **E la replica e stata fatta su un codice scelto DOPO, apposta per poter
  fallire.** Il preposto l'aveva gia guardato chi ha formulato la tesi, e una
  verifica sulla stessa evidenza non e una verifica: AppSopralluoghi ha rifatto il
  conto su `DL_RSPP_BASE`, la distribuzione piu ricca che avesse — 6/10/14/8
  sull'aggiornamento, 16/32/48/8/24 sull'iniziale — e ha trovato **nove titoli su
  nove, zero non spiegati**. Non era una distribuzione di ore: era una distribuzione
  di **titoli**. E A12 applicata a una **tesi** invece che a un vincolo.
  **E il confine dell'evidenza, che vale per ogni codice e va scritto una volta
  sola:** nessuna fonte nei tre repo puo dire **se un corso da 28 ore sia stato
  erogato in 28 ore**. L'export dice **sotto quale voce** e stato registrato; solo
  **l'attestato** dice cosa e stato fatto. Se un giorno serve saperlo, la strada non
  e una query: **e un campione di attestati.**

- **A21** **Un'ipotesi sbagliata che fa guardare nel posto giusto vale piu di una
  prudenza che non fa guardare da nessuna parte.** Aggiunta il 12 settembre 2026
  dalla corsia AppSopralluoghi, come contropeso a tutto il resto di questa lista.
  In tre ore la colonna `ore` dell'export e passata per **tre stati**: dato
  affidabile, dato **falsato da una riscrittura**, dato che **non ha mai misurato
  quello che credevamo**. Il secondo stato e durato un'ora ed era **sbagliato** — ma
  **non inutile**: senza la riscrittura nessuno avrebbe guardato quella colonna, e la
  cosa vera stava sotto.
  **E l'ordine dei fatti dice come e stata trovata, e nessuno dei tre passaggi poteva
  arrivarci da solo:** le ore le ha smentite **Francesco**, guardando due aule che
  conosceva — non un documento, non una rilettura. La cosa vera l'ha vista
  **AppFormazione**, contando. La replica su un terzo codice l'ha fatta
  **AppSopralluoghi**. Tre passaggi, tre fonti diverse, tre metodi diversi.
  **Il contropeso che questa lista aveva bisogno di avere scritto:** le altre
  assunzioni insegnano a diffidare — di un totale, di un nome, di una conferma, di un
  fatto ricevuto. Prese da sole portano a **non dire niente finche non si e sicuri**,
  e una sera come questa sarebbe finita al primo passaggio. **Un'ipotesi si consegna
  come ipotesi e si dice che lo e**: quello che non si fa e consegnarla come fatto —
  che e A19, ed e l'unica riga di questa lista che limita questa.
