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

**11 schede su 11 sono chiuse.** Stato generato dalle schede: il paragrafo `## Decisione` di ognuna e la fonte, questa tabella e la resa.

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
| Divergenze fra migrazioni e database | 0 su 21 | Su `figura_requisito`, in due letture confrontate — ricostruita dai file e letta dal database (`b50003f`). **Prova che il metodo di ricostruzione funziona**, non che ogni tabella combaci: i 40 codici curati della `0004` restano un'ipotesi finche non si confrontano allo stesso modo |
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
  mancanza di accesso o di dato va detto escluso, non lasciato in fondo alla lista.

### Prossimo passo per corsia · al 10 settembre 2026, ore 18

Tre colonne, perche una corsia deve sapere **cosa fa adesso** e **cosa la aspetta**:
senza la seconda, chi finisce alle sette di sera si ferma o si inventa un compito.

| corsia | adesso | poi | perche in questo ordine |
|---|---|---|---|
| **AppOverall** | ~~`0004` il catalogo~~ **scritta** · **`0005` la sorveglianza sanitaria: SCRITTA l'11.09** — vocabolario dei 10 accertamenti con la periodicita dichiarata, esecuzioni per persona, **scadenza calcolata nella vista e non memorizzata**. Adesso: `corso_assolve`, **bloccata** — aspetta le regole di AppFormazione, che e ferma | la migrazione **dati**: le 808 righe della sorveglianza e il corpus nel nuovo schema | La `0005` si poteva scrivere senza nessuno: la scheda 10 e decisa e le misure c'erano tutte. Porta la **forma** e non i dati, e lo dice: il conteggio 808 contro 1.148 non e sciolto, e l'avevo scritto io che una migrazione su un conteggio aperto nasce storta. `corso_assolve` invece resta vuota perche una fonte sola sarebbe coerente con se stessa e non per questo vera |
| **AppSopralluoghi** | ~~i livelli di emergenza~~ **misurato** (`505e880`): il difetto c'e anche qui ed e **latente**, che e peggio → **la scheda 11 e aperta e serve la lettura della norma**: DM 02/09/2021 e DM 388/2003 sul punto «un livello superiore assolve l'inferiore». Se la fonte non c'e nel vostro corpus, dirlo | l'import dei ruoli, quando Francesco toglie la pausa | Quattro campi di livello **vuoti su 619 righe ciascuno**, sette chiamanti enumerati, e il motore che non guarda mai il livello: `AI_LIV1` vale quanto `AI_LIV3`. Le persone scoperte oggi sono zero, e quello zero non dice niente — tre assenze indipendenti. Il difetto diventa reale al primo import di attestati di emergenza, e produce **conformita apparenti**: un errore si vede, una conformita falsa no |
| **AppFormazione** | ~~le regole obbligo -> corso~~ **consegnate** (`75d10ee`, 180 righe) · ~~il carico su PostgreSQL~~ **fatto**, con un bug trovato → **la traduzione obbligo -> `ruolo_sicurezza`**: i loro **35 obblighi** contro i **36 codici** della `0002`, uno per uno, dove non c'e corrispondenza dirlo. E la meta che mi manca per riempire `corso_assolve` | la seconda lettura del loro stato, **se** Francesco decide di installare Docker | Hanno consegnato con il limite in testa — una lettura sola, qualificata «i file dicono» (A10) — e la trappola simmetrica alla nostra: 7 titoli **parziali** che sbaglierebbero per **eccesso** dove `per_categoria` sbaglia per difetto. E hanno eseguito le mie migrazioni, che nessuno aveva mai eseguito |

**Chi e fermo, e da quando.** La sera del 10 settembre Francesco ha fermato
**AppFormazione** (passo assegnato, non iniziato) e **AppSopralluoghi** (confronto a
meta, punto di ripresa scritto nella `0004`), e l'import dei ruoli era gia in pausa. Sta scritto qui perche la prossima sessione non aspetti
un lavoro che nessuno sta facendo: una corsia ferma e diversa da una corsia lenta, e
dal foglio non si distinguono.

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
produzione, quando si decidera di farlo.

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
gestionale, e conviene farle **nella stessa conversazione**:

1. **La colonna «RSPP»** raccoglie di fatto l'art. 34, il datore che assume
   l'incarico in proprio. La prova e nei due versi — dei 28 marcati, 26 hanno un
   corso da datore e **zero** hanno i moduli professionali A/B/C; e le 12 persone
   con i moduli professionali sono marcate RSPP in **zero** casi. La domanda non e
   se noi la leggiamo bene: e se il gestionale debba continuare a chiamarla cosi.
   Nessuna nomina RSPP entra prima.
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
  piu semplice e piu grosso della deriva del `049`/`050`. Conseguenza: **la `0055`
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