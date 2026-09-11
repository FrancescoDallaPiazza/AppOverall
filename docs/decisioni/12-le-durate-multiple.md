# 12 · Un corso con due durate: tre cause diverse, e un meccanismo non basta

> **Blocca:** il **motore**, e la `0006` limitatamente ai codici coinvolti · finché è aperta, il catalogo giudica col metro di oggi attestati validi sotto il metro di ieri

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

*(da scrivere. **Quattro** righe, e sono indipendenti: se il catalogo porti una
validità temporale; se porti una condizione sulla dimensione dell'azienda — sapendo
che in un caso su tre la risposta **non è un numero** ma un rinvio al CCNL; se le
varianti combinate prendano un codice proprio; e se `PREPOSTO` vada **separato in tre
codici**, uno per corso iniziale.*

*Sulla quarta: separare i codici è la sola che tocca i **dati già scritti**, perché
gli attestati esistenti andrebbero ri-mappati. E ha sotto una domanda che non è di
schema: i tre corsi sono tre cose diverse, o lo stesso corso che l'erogazione ha
chiamato in tre modi? Lo sa chi li ha erogati.*

*Va scritto anche **quali casi la decisione non risolve**: una regola che copre un
terzo dei casi e non dichiara gli altri due è il modo in cui si crede di aver chiuso
un difetto.)*

---

*Misure dell'11 settembre 2026, corsia AppSopralluoghi: `eddbb44` (le distribuzioni
delle durate) e `f4f2802` (le date, con il controllo negativo sull'RLS). Il limite
dichiarato: in quelle misure il dizionario è **simulato dai file** e non letto dal
database, perché l'SQL Editor di Supabase ha smesso di accettare input. Sotto A10
vale «i file dicono».*
