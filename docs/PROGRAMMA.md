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
| WERP | fuori | Scambio via Excel. L'anagrafe si modella sapendo che un giorno potrebbe arrivare, senza inseguirlo. |
| AppCorsiOverall, AppHr, sito, IPE | fuori | Escluse per decisione o linea di business diversa. Non vanno aperte. |

Togliendo l'erogazione, il sistema nuovo **non e in concorrenza con ASSIDAL**: non
deve rispondere a «chi emette», ma solo a «chi certifica e chi archivia».

## 2. Le sei cose che non si aggiungono dopo

Sono il motivo per cui il repo e nuovo invece che riparato. Ognuna e un difetto
gia misurato. Ed e anche il motivo per cui riscrivere lo strato applicativo costa
meno di quanto sembri: quel codice e gia condannato a prescindere.

1. **Viste come strato di indirezione** — oggi zero `create view` in 62 migrazioni.
2. **RLS che isolano davvero** — oggi tutte `using (true) with check (true)`.
3. **Un solo vocabolario di ruoli** — oggi due insiemi senza un valore in comune.
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
- L'ATECO mancante sul 57% delle attive — **aspetta il raccordo della fase 1**

**Criterio di uscita.** Un tecnico lavora offline senza restare bloccato, e le 619
aziende attive sono rientrate nel database, vuoto dal 5 agosto.

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

- **Sede o azienda**: il codice ha gia deciso «aziendali», con un commento esplicito
- **Chiave cliente**: la direzione e obbligata, ma va scritta
- **WERP resta**: da confermare formalmente
- **Dove vive `kitformasubito`** e chi lo tiene
- Le due decisioni di norma della fase 1, se non hanno trovato una fonte

**Criterio di uscita.** Cinque righe scritte, non cinque opinioni. Ognuna determina
una colonna dello schema.

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

### Fase 5 — Il campo migra per ultimo

**Criterio di uscita.** Il tecnico apre il nuovo in un capannone, offline, e non se
ne accorge. Le due app vecchie si archiviano, non si congelano.

## 4. Cosa migra, cosa si riscrive, cosa torna indietro

Schema nuovo si, contenuto no. Il codice che si butta e grande in righe e piccolo
in conoscenza; quello che si rifarebbe a mano e piccolo in righe e caro in anni.

| Che cosa | Destino |
|---|---|
| Corpus normativo (4.568 righe, 1.505 in `reference/`, 17 PDF) | migra come dato |
| Schema del dominio (62 migrazioni di qua, 53 e 7.423 righe SQL di la) | migra, rivisto |
| Cataloghi e configurazione (268 alias, 40 corsi, 13 figure, 16 box) | migra come dato |
| Lettori degli export (WERP a 7 stadi, Sicurweb) | migra come codice |
| Motori di dominio (requisiti, valutazione, scadenze) | migra come codice |
| Schermate e navigazione | si riscrive |
| Sincronizzazione offline | si riscrive |
| **Il raccordo ISTAT** (3.257 codici, 6.742 righe) | **torna a monte, alla libreria** — e ci resta: sotto la decisione 7 la libreria e la sorgente, non una copia |
| **Il corpus `reference/`** (17 PDF, 11 trascrizioni citate) | **va a monte anch'esso**, ad alimentare il generatore |

## 5. Stato delle decisioni

| Decisione | Stato | Cosa blocca |
|---|---|---|
| Perimetro senza erogazione | deciso | niente |
| `AppCorsiOverall` escluso | deciso | niente |
| Repo nuovo, non foglio bianco | deciso | niente |
| WERP resta | raccomandato | solo la fase 4, e solo se lo scadenzario genera commesse |
| Sede o azienda | **aperto** | **la fase 3** |
| Chiave cliente unica | **aperto** | **la fase 3** |
| Dove vive `kitformasubito` | aperto | niente subito, ma rientra fra sei mesi |
| Chi possiede la base normativa | **deciso** | niente: la libreria resta il generatore unico |
| Le divisioni 30, 86, 87 | aperto | 32 codici senza classe |
| «Si prende il piu alto» | aperto | niente finche le sedi non sono di prima classe |

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
| Migrazioni AppFormazione | 53 | `supabase/migrations/*.sql` |
| Righe SQL AppFormazione | 7.423 | **solo `migrations/`**; con `scripts/*.sql` sono 8.125 |
| Corpus in markdown | 4.568 | tutti i `.md` tracciati, di cui 1.505 in `reference/` |
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
