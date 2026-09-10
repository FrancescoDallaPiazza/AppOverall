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

**Ordine, e non e una preferenza.** Se la fase di prova sugli import e chiusa,
l'azzeramento dei dati operativi viene **prima** dell'import dei ruoli: disfare
nomine e peggio che disfare anagrafiche, perche le scadenze sono **derivate** dalle
nomine e si disfano insieme. Se la prova non e chiusa, l'import va subito. Lo stato
della prova non e scritto in nessun repo — si chiede, non si deduce.

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

**9 schede su 9 sono chiuse.** Stato generato dalle schede: il paragrafo `## Decisione` di ognuna e la fonte, questa tabella e la resa.

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
- **A6** Il perimetro non si allarga durante il riavvio.
- **A7** **Una regola dedotta non entra nelle tabelle applicative.** Si applica cio
  che si legge, con parte, punto e pagina; cio che si deduce aspetta, dichiarato.
  Non e condivisa da tutte le fonti in gioco: la libreria normativa riempie le tre
  divisioni aperte senza citarle. **E l'unica assunzione che, se cade, cambia la
  natura del progetto invece che il calendario**: 32 codici si sbloccano subito, e
  il progetto smette di essere quello che dice di essere.
