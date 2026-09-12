# 12 · Un corso con due durate: tre cause diverse, e un meccanismo non basta

> **Blocca:** il **motore**, e la `0006` limitatamente ai codici coinvolti · finché è aperta, il catalogo giudica col metro di oggi attestati validi sotto il metro di ieri
>
> **In una riga:** **decisa il 12 settembre 2026** — i meccanismi sono **tre** e sono entrati tutti e tre (validità temporale, condizione sulla dimensione con **tre** casi, un codice per variante combinata); il **quarto** — separare `PREPOSTO` — **non si fa finché non risponde l'Area Formazione**, perché tocca i dati già scritti e la domanda sotto non è di schema

**Nata da un riscontro a tre fonti**, l'11 settembre 2026: le durate che il sito di
Overall dichiara, quelle che il catalogo della `0004` si aspetta, e quelle che
l'export mostra su 13.348 righe erogate.

## Il fatto

Undici codici su quaranta hanno **più di una durata reale**, e il catalogo ne tiene
**una sola**. Ma le durate multiple non hanno tutte la stessa causa — ne hanno
almeno **tre**, e questo è il punto della scheda:

| causa | esempio | cosa serve per esprimerla |
| --- | --- | --- |
| **il tempo** | `DIRIGENTE`: 16 ore fino all'ASR 2025, 12 dopo | una **validità temporale** sulla riga |
| **la dimensione dell'azienda** | `RLS`: **tre** casi, e in uno la durata non è un numero | una **condizione sul cliente** — e un caso in cui la regola rinvia altrove |
| **il contenuto del corso** | carrello 12 ore per tipo, **16 per entrambi**; escavatori 16 contro 10; gru torre 14 contro 12 | **un codice in più**, uno per variante |
| **un codice che raccoglie corsi diversi** | `PREPOSTO`: **sette titoli**, di cui **tre corsi iniziali distinti** erogati negli stessi anni | **separare i codici**, e il titolo non basta per farlo |

**Un solo meccanismo non le copre**, e applicarne uno dove non c'entra introduce un
difetto invece di chiuderlo. La quarta causa è arrivata per ultima, dopo che una
frase di questa scheda è stata smentita dai dati che pretendeva di spiegare.

## Le misure, e il controllo che le rende affidabili

Per ogni codice con due durate è stata guardata la **data** degli attestati, con lo
spartiacque del 17 aprile 2025 (l'ASR):

| codice | durata | prima | dopo | esito |
| --- | --- | ---: | ---: | --- |
| `DIRIGENTE` | 16 h | **12** | **0** | **taglio netto**: regime chiuso |
| `PREPOSTO` | 8 h | 248 | **28** | **nessun taglio** |
| `PREPOSTO` | 12 h | **30** | 8 | si sovrappongono nei due versi |
| `DL_RSPP_BASE` | 6 / 10 / 14 h | 73 / 23 / 34 | 3 / 0 / 2 | separazione **quasi** pulita |
| `DL_RSPP_BASE` | 8 h | 6 | **20** | l'unificato è quasi tutto dopo |
| `RLS` | 4 h | 82 % | 18 % | **nessuna separazione** |
| `RLS` | 8 h | 81 % | 19 % | idem — e **doveva** dirlo |

**L'ultima riga è un controllo negativo, ed è la ragione per cui le altre valgono.**
Sull'`RLS` sappiamo già che la seconda durata dipende dalla **dimensione** e non dal
tempo: un test onesto lì deve rispondere «nessuna separazione». Risponde esattamente
quello, con le due popolazioni che attraversano lo spartiacque in proporzioni quasi
identiche. Il test **discrimina**, quindi il taglio netto del dirigente non è un
artefatto del metodo. Un test che non sbaglia mai non prova niente — è l'assunzione
**A12** del programma, e nasce qui.

## Cosa ciascun meccanismo risolve, e cosa no

- **una validità temporale sulla riga** risolve `DIRIGENTE` **per intero** (16 ore
  valide fino al 17/04/2025, 12 dopo: il più recente attestato a 16 ore è del
  **5 febbraio 2025**, sei settimane prima dell'Accordo);
- risolve **quasi tutto** `DL_RSPP_BASE`, e lascia fuori **sei righe** a 8 ore
  datate 2016-2024;
- **non risolve niente** su `PREPOSTO`: le due popolazioni si sovrappongono nei due
  versi, con 28 attestati da 8 ore **dopo** l'Accordo (l'ultimo il 19 maggio 2026,
  tredici mesi dopo) e 30 da 12 ore **prima** (il più vecchio il 20 maggio 2024);
- e su `RLS` sarebbe **la modellazione sbagliata**: lì la seconda durata non è un
  regime passato, è una dimensione d'azienda che **convive** con la prima oggi.

## Cosa è in gioco

Oggi ogni riga del catalogo porta **un** numero, quindi racconta il regime corrente e
**giudica col metro di oggi attestati validi sotto il metro di ieri**. Un dirigente
formato nel 2018 con 16 ore risulterebbe sotto-durata rispetto alle 12 attuali — e la
sua formazione era completa quando l'ha fatta.

La domanda non è «serve una data di validità»: la risposta è sì per un caso su tre.
La domanda è **quanti meccanismi il catalogo deve avere**, sapendo che ne servono tre
per coprire tre cause — e che il terzo (un codice per variante) è l'unico già
esprimibile senza toccare la forma delle tabelle.

## Il `PREPOSTO` non è un regime cambiato: è un codice che raccoglie tre corsi

Questa scheda aveva scritto che il preposto era il caso «due regimi nel tempo che si
sovrappongono», e che «12 ore erano state erogate prima che l'Accordo le
richiedesse». **Era una deduzione presentata come un fatto** — nessuna fonte nei repo
dice che il regime precedente fosse di 8 ore, e l'asimmetria col dirigente lo
segnalava: lì la nota del catalogo dichiara «erano 16h con accordo 2011», qui no.

Chiesti gli esempi, i **titoli** hanno sciolto tutto (`c15feab`). Le 30 righe a 12 ore
prima dell'Accordo hanno **un titolo solo** e **due sole date** — 5 il 20.05.2024 e 25
il 05.09.2024: non una popolazione diffusa nel tempo, **due aule**.

    FORMAZIONE PARTICOLARE AGGIUNTIVA PREPOSTI - BIENNALE    12 h   mag 2024 - dic 2025
    FORMAZIONE PARTICOLARE AGGIUNTIVA PREPOSTI                8 h   mar 2011 - mag 2026
    CORSO DI FORMAZIONE PER PREPOSTI                         12 h   dal 19.02.2026

**Il dato che uccide la lettura per regimi** è uno solo: il corso da 8 ore va dal
**marzo 2011 al maggio 2026, ininterrotto**. Non si è fermato all'Accordo e tredici
mesi dopo era ancora erogato — nessuna finestra transitoria copre tredici mesi di
erogazione continua. E il «- BIENNALE» da 12 ore **scavalca l'Accordo in entrambi i
versi**. Non c'è un prima e un dopo: ci sono **corsi diversi erogati negli stessi
anni**.

Il terzo titolo è l'unico che somiglia al regime nuovo: sette righe, tutte dal
**19 febbraio 2026**. **Confidenza media**, e va detto: la forma è giusta, sette righe
sono poche, e nessuna fonte nei repo lo dichiara.

Sotto `PREPOSTO` ci sono quindi **sette titoli**: tre corsi iniziali distinti, due di
aggiornamento, una integrazione.

### E il titolo non è una chiave perfetta

    ... PREPOSTI - BIENNALE   (trattino)     12 ore
    ... PREPOSTI_BIENNALE     (underscore)    8 ore

**Stesse parole, punteggiatura diversa, durata diversa.** Il dizionario dei 268 alias
le tiene già come due voci — la curatela del campo aveva visto la differenza — ma
chiunque «normalizzi» quei titoli collassa due corsi di durata diversa in uno. È la
forma della normalizzazione aggressiva che ha già colpito una volta: sostituire
`[^a-zA-Z0-9]` con uno spazio fa sparire trattino e underscore **insieme alla loro
differenza**.

### La colonna della data non dichiara cosa contiene

Chiesto per terzo, e vale oltre questa scheda: la colonna si chiama **`Data`** e
basta. Le altre tre che contengono «data» sono nascita, assunzione, licenziamento.
**L'export non dichiara** se sia la data del corso, dell'attestato o della
registrazione, e non esiste una seconda data con cui incrociarla. Il
`formazioneImport.ts:230` del campo la mappa su `data_completamento`, cioè **assume**
sia la data del corso: assunzione nostra, non fatto della fonte. Per questa scheda non
serve — la separazione è nei titoli — ma resta un'assunzione non dichiarata **sotto
ogni scadenza che calcoliamo**.

## L'`RLS` ha tre casi, non due, e la regola che avevo scritto è vecchia

Questa scheda diceva «4 ore da 15 a 50 lavoratori, 8 oltre 50», dalla pagina di corso
di Overall. **È la regola di prima del 31 dicembre 2025.** L'ultimo periodo dell'art.
37 c. 11 è stato modificato dall'art. 5 del **D.L. 31 ottobre 2025 n. 159**,
convertito con **L. 29 dicembre 2025 n. 198**, in vigore dal **31/12/2025** —
trascritto verbatim a monte in
`formazione-81-utils-src/reference/dlgs-81-2008-articoli-citati.md`.

| lavoratori | durata dell'aggiornamento annuale |
| --- | --- |
| **meno di 15** | **la legge non la fissa**: la fissa il CCNL, «nel rispetto del principio di proporzionalità» |
| da 15 a 50 | **4 ore** annue |
| oltre 50 | **8 ore** annue |

**E le 4 e le 8 non sono la durata: sono un pavimento.** Il testo dice che il CCNL
«disciplina le modalità dell'obbligo di aggiornamento periodico, la cui durata **non
può essere inferiore a** 4 ore annue… e a 8 ore annue». Quindi si citano come norma —
sono minimi vincolanti — ma **la durata effettiva la fissa il contratto e può essere
maggiore**. Sotto i 15 lavoratori non c'è nessun numero da citare.

Due conseguenze pratiche: l'aggiornamento dell'RLS è **annuale** e non quinquennale;
e **la maggior parte delle 480 aziende in archivio sta sotto i 15 lavoratori**, cioè
nel caso in cui la risposta non è un numero. Sapere quanti dipendenti ha un cliente
**non chiude** questa variante: la manda in un caso che rinvia al contratto.

**La forma esiste già in AppFormazione, come vocabolario e non come regola:**
`clienti.dipendenti` (integer, loro `0039`, col commento che cita la norma) e un
discriminante dedicato nella `0052`, `dipendenti_rls`, con **tre varianti** —
`meno_15`, `15_50`, `oltre_50`. C'è l'ingresso, c'è la citazione, **manca il giunto
fra i due**: identico nella forma al buco dei livelli antincendio della scheda 11.

## Decisione

**Decisa il 12 settembre 2026.** Le quattro righe sono indipendenti e sono state
prese come quattro, non come una: tre dicono cosa il catalogo deve saper esprimere,
la quarta dice **chi** deve rispondere prima che si tocchino i dati già scritti.

**1 · La validità temporale entra.** Una riga di catalogo può valere *fino a* una
data e un'altra *da* quella data. Risolve `DIRIGENTE` per intero — 16 ore fino
all'ASR 2025, 12 dopo — e il fatto che la regge è un **taglio netto misurato**: 12
attestati a 16 ore prima dello spartiacque, **zero** dopo, e il più recente è del 5
febbraio 2025, sei settimane prima dell'Accordo. Risolve anche quasi tutto
`DL_RSPP_BASE`. Senza, il motore giudica col metro di oggi una formazione che era
completa quando è stata fatta.

**2 · La condizione sulla dimensione entra, e i casi sono TRE.** Non «4 ore fino a
50, 8 oltre»: l'art. 37 c. 11, come modificato dall'art. 5 del D.L. 31/10/2025
n. 159 (conv. L. 29/12/2025 n. 198, in vigore dal 31/12/2025), separa **sotto i 15
lavoratori**, dove la durata la fissa il **CCNL** e non c'è nessun numero da citare,
da **15-50** (non meno di 4 ore annue) e **oltre 50** (non meno di 8). E le 4 e le 8
sono un **pavimento**, non la durata: il confronto è `>=`, e il contratto può
chiedere di più.

Il caso che pesa è il primo: **432 delle 481 aziende con un numero stanno sotto i
15**, cioè il 90%. Quindi il ramo in cui la risposta *non è un numero* non è
l'eccezione da sbrigare — è la regola. Il catalogo deve poter dire «qui la durata la
fissa il contratto» come **stato proprio**, distinto da «non lo so».

**3 · Le varianti combinate prendono un codice proprio.** Carrello 12 ore per tipo e
**16 per entrambi**, escavatori 16 contro 10, gru a torre 14 contro 12. È l'unico
dei tre meccanismi già esprimibile **senza toccare la forma delle tabelle** — si
aggiungono righe, non colonne — e non tocca lo storico, perché gli attestati si
riagganciano per titolo attraverso alias che le due voci le distinguono già.

**4 · `PREPOSTO` NON si separa oggi, e la domanda ha un destinatario.** È l'unica
delle quattro che tocca i **dati già scritti**, e sotto ha una domanda che i dati non
possono sciogliere: i tre corsi iniziali sono **tre cose diverse**, o **lo stesso
corso che l'erogazione ha chiamato in tre modi**? Lo sa chi li ha erogati, cioè
l'**Area Formazione** — la stessa che la scheda del percorso attestati indica come
titolare del giudizio di conformità dei contenuti.

Fino a quella risposta il catalogo tiene **un codice solo**, e la distinzione resta
dove già vive: negli alias, che `PREPOSTI - BIENNALE` (12 ore) e `PREPOSTI_BIENNALE`
(8 ore) li tengono come due voci. Non è una proroga tacita: è una riga che dice che
il buco c'è, di chi è la risposta, e cosa succede nel frattempo.

### Cosa questa decisione NON risolve, che la scheda chiedeva di scrivere

- **Le sei righe a 8 ore di `DL_RSPP_BASE` datate 2016-2024** restano fuori dalla
  validità temporale: la data non le separa, e nessuno dei tre meccanismi le prende.
  Sono poche e vanno guardate una per una, non modellate.
- **Il `PREPOSTO` resta indistinto per codice** — e con lui l'8 ore erogato senza
  interruzione dal marzo 2011 al maggio 2026, che nessuna finestra transitoria
  spiega. Finché è così, **nessuno dei due repo sa dire per codice quale sia il
  corso da 12 e quale quello da 8**.
- **La durata effettiva sotto i 15 lavoratori non la sappiamo comunque**: sapere
  quanti dipendenti ha un cliente manda quel cliente nel ramo del CCNL, non a un
  numero. Il ramo va costruito sapendo che finisce in una domanda al cliente.
- **Il meccanismo non dice quale numero sia giusto**: dice che il catalogo può
  esprimerne più di uno. Le tre righe qui sopra decidono la **forma**; quali valori
  entrino in quella forma resta lavoro di lettura, sotto A7 come tutto il resto.

---

*Misure dell'11 settembre 2026, corsia AppSopralluoghi: `eddbb44` (le distribuzioni
delle durate) e `f4f2802` (le date, con il controllo negativo sull'RLS).*

*Quelle misure portavano una riserva — il dizionario era **simulato dai file** e non
letto dal database — ed è **caduta l'11 settembre 2026**. I 268 giudizi sono ora
identici in **tre posti**: gli script di AppSopralluoghi, il seed di AppOverall e la
produzione. Il triangolo è chiuso in due passi indipendenti: seed ↔ produzione con
undici valori su undici (`f94ff83`), e script ↔ seed con zero righe diverse e le somme
delle impronte identiche (`7d0b322`). Quindi l'analisi delle durate — l'`RLS`
sotto-specificato, i combinati, i quattro regimi di `DL_RSPP_BASE`, il dirigente —
**non è più qualificata**: si cita senza riserva.*
