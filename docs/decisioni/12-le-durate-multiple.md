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
| **la dimensione dell'azienda** | `RLS`: aggiornamento 4 ore da 15 a 50 lavoratori, **8 oltre 50** | una **condizione sul cliente**, non sul tempo |
| **il contenuto del corso** | carrello 12 ore per tipo, **16 per entrambi**; escavatori 16 contro 10; gru torre 14 contro 12 | **un codice in più**, uno per variante |

**Un solo meccanismo non le copre**, e applicarne uno dove non c'entra introduce un
difetto invece di chiuderlo.

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

**E resta un caso che nessun meccanismo spiega**, perché non è un problema di
modellazione: il `PREPOSTO`. Perché sono stati erogati corsi da 12 ore **prima** che
l'Accordo li richiedesse, e da 8 ore **dopo**? Le due letture — una finestra
transitoria che lascia concludere i percorsi avviati, oppure 12 ore erogate
volontariamente in anticipo — non si distinguono dai dati. **È una domanda per chi
conosce l'erogazione, non per il codice.**

## Decisione

*(da scrivere. Tre righe, e sono indipendenti: se il catalogo porti una validità
temporale; se porti una condizione sulla dimensione dell'azienda — il dato in
anagrafe c'è, `N° DIPENDENTI` su 481 delle 619 attive; e se le varianti combinate
prendano un codice proprio. Più la domanda sul preposto, che non è di schema.*

*Va scritto anche **quali casi la decisione non risolve**: una regola che copre un
terzo dei casi e non dichiara gli altri due è il modo in cui si crede di aver chiuso
un difetto.)*

---

*Misure dell'11 settembre 2026, corsia AppSopralluoghi: `eddbb44` (le distribuzioni
delle durate) e `f4f2802` (le date, con il controllo negativo sull'RLS). Il limite
dichiarato: in quelle misure il dizionario è **simulato dai file** e non letto dal
database, perché l'SQL Editor di Supabase ha smesso di accettare input. Sotto A10
vale «i file dicono».*
