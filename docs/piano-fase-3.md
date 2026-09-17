# Cosa manca per chiudere la Fase 3

> Scritto il 16 settembre 2026, dopo che la migrazione dati e passata sui dati veri.
> **E un piano, non un lavoro iniziato:** dice cosa manca, in che ordine, e quali tre
> domande vanno risposte prima che qualcuno scriva SQL.

## Prima: una frase che ho usato male tutto il giorno

Ho scritto piu volte «la prima migrazione del repo unico» come se fosse il prossimo
passo. **E gia scritta e applicata:** e la `0001`, del 9 settembre, e apre lei la
Fase 3 — lo dice la sua prima riga. Quello che resta non e la prima migrazione: e il
**resto dei dati**, e **una tabella che non esiste**.

La differenza non e di parole. «Preparare la prima migrazione» suona come un foglio
bianco con delle decisioni davanti; «finire la Fase 3» e un elenco di quattro cose
misurabili, di cui una sola ha un buco di forma.

## Dove siamo, misurato

- **20 migrazioni, 25 tabelle.** Anagrafe sulla sede (scheda 1), chiave P.IVA + sede
  (scheda 2), `valutazione_sede` con motivazione, fonte, data e operatore (scheda 8),
  catalogo formativo a grana obbligo con codice curato (scheda 9), sorveglianza come
  dominio proprio (scheda 10). **Le 12 schede di decisione sono chiuse tutte e 12.**
- **La migrazione dati gira da capo a fondo sui dati veri** (16 settembre, su
  `OVERALL-PC07`): 608 unita d'origine -> **605 clienti e 608 sedi**, 3.494 righe ->
  **3.494 rapporti su 3.491 persone**, **459 nomine su 338 persone**. Cluster usa e
  getta, cancellato; verificata alla fonte con la query dei quattro zeri.
- **Quindi la parte anagrafica della Fase 3 e fatta e provata.** Quello che segue e
  tutto il resto.

## Cosa manca

### 1. Gli attestati non hanno dove atterrare — ed e l'unico blocco vero

Il catalogo c'e **tutto**: `corso`, `corso_assolve`, `credito_formativo` (le 53 righe
dell'Allegato III), `corso_durata_per_dimensione`, `corso_regime_precedente`. L'anagrafe
c'e. Manca **la formazione svolta**: in AppFormazione sono circa **13.350 righe** di
attestati, e fra le 25 tabelle del repo unico **non ce n'e nessuna** che possa
riceverle.

Non e una dimenticanza da poco: **lo scadenzario non si calcola dal catalogo, si
calcola dagli attestati contro il catalogo.** Finche quella tabella non esiste, la
Fase 4 non ha su cosa girare — e la Fase 4 e la fetta che deve dimostrare che
l'impianto regge.

**Due delle tre domande hanno una risposta, data da Francesco il 16 settembre 2026:**

- **due righe che cadono sulla stessa identita si segnalano**, non si fondono in
  silenzio. Restano entrambe e la collisione e un fatto scritto, non una riga che
  sparisce: la stessa disciplina delle unita fuse per P.IVA nel passo 01, che si
  contano e si dichiarano;
- **la validita si conta dal COMPLETAMENTO del percorso**, non dall'ultima sessione ne
  dalla prima. Quindi il percorso e un oggetto: le sessioni lo compongono, e la
  scadenza sta su di lui.

**E la domanda che la seconda risposta apre — «come si sa che un percorso e completo»
— non va girata a nessuno: il gestionale lo sa gia.** Esporta due file distinti,
misurati il 16 settembre nei Download: `ExportExcelFormFrazCompletata.xlsx` (**516
righe**) e `ExportExcelFormFrazInCorso.xlsx` (**410 righe**), con le **stesse 34
colonne**. La differenza fra «completato» e «in corso» **non e un campo: e quale file
stai leggendo.**

Da cui una conseguenza da scrivere adesso, perche dopo non si recupera: **l'import
deve registrare da quale file arriva ogni riga.** Nel momento in cui i due file si
uniscono senza quella colonna l'informazione sparisce, e nessun vincolo se ne
accorgerebbe: le righe sono valide tutte e due le volte. La forma c'e gia,
`origine_estrazione` (`0008`), ed e nata per dire esattamente questo. **Dove una cosa e
scritta e parte di cosa dice**, e qui la cosa e scritta nel nome del file.

**E con quelle due risposte l'identita diventa decidibile senza un'altra decisione.**
L'import di oggi in AppSopralluoghi usa `gest:<codice fiscale>:<titolo
normalizzato>:<data>` (`formazioneImport.ts:480`): e una chiave di **import**, non
un'identita. Per il repo unico la forma coerente con la scheda 9 e questa:

- **l'identita e persona + corso curato + data**, perche e quella su cui il motore
  decide se una persona e in regola;
- **il titolo del gestionale resta sulla riga come provenienza**, come gia fanno
  `ateco_origine`, `testo_origine` e `codice_fiscale_origine`;
- **la chiave di import resta quella di oggi**, come `import_key` e basta: l'impronta
  del gestionale e un alias, non un'identita — la scheda 9 applicata agli attestati
  invece che ai titoli.

E poiche le collisioni **si segnalano**, l'unicita su quella terna non e un vincolo del
database: e un conteggio che il passo stampa, come le unita fuse del passo 01.

**E la terza domanda — le ore — ha una risposta, e l'ha chiusa un'obiezione di
Francesco.** Il gestionale ha riscritto la colonna `ore` dello storico con le durate
dell'ASR 2025 (misurato il 12 settembre), quindi quel numero non dice quante ore siano
state erogate. La domanda era se portarlo o no. L'obiezione, del 16 settembre:

> «Se io importo un corso passato, lo si deve verificare rispetto alle regole vigenti
> alla data del corso.»

**E infatti e gia cosi**, ed e la decisione 12 nella migrazione `0014`:
`corso_regime_precedente` tiene **fino a quando** valeva il programma vecchio e
`corso_regime_precedente_ore` **quante ore** chiedeva, varianti comprese. Il motore
confronta la data dell'attestato con quell'estremo.

**Da cui la risposta, che e piu netta di quella che avevo proposto.** Le ore che
servono alla verifica **non vengono dall'export**: vengono dal catalogo, che le tiene
datate. Usare la colonna dell'export per giudicare un attestato del 2019 vorrebbe dire
confrontare **il numero di oggi con la regola di ieri** — la peggiore delle due
combinazioni, e nemmeno segnalata. Quindi:

- la colonna `ore` dell'export **si porta**, accanto al titolo d'origine, come
  provenienza: e cio che il gestionale dice oggi, e cancellarla perderebbe un dato che
  esiste;
- **il motore non la legge mai.** Chi giudica un attestato guarda il catalogo datato.

La differenza fra «portarla dichiarandola inaffidabile» e questo non e di parole: la
prima lascia la porta aperta a chi un domani la usera lo stesso, la seconda dice **chi
puo leggerla e chi no**.

### 2. I livelli e l'ATECO, che oggi il passo 01 conta e lascia fuori

Il passo 01 stampa: `NON portati: ATECO su 261 clienti, almeno un livello su 261`. Non
e un difetto, e una scelta scritta nel passo, e le ragioni sono due:

- **l'ATECO all'origine e senza annata**, e la `0001` dice che un codice senza annata
  non si sa leggere: fra ATECO 2007 e 2025 ci sono 2.166 stringhe e **62 codici che
  cambiano classe**;
- **i livelli qui sono `valutazione_sede`**, con **motivazione e operatore
  obbligatori**, e all'origine sono un valore senza ne l'una ne l'altro.

Servono quindi due decisioni piccole e una riga di codice ciascuna: **quale annata**
attribuire ai codici migrati, e **quale operatore** firma le valutazioni che arrivano
dal gestionale, con una motivazione onesta del tipo «migrato dal gestionale il
16/09/2026, come e stato deciso non risulta».

**E c'e un raccordo nato oggi.** In AppSopralluoghi e entrata la colonna provvisoria
`livello_rischio_definito_mediante`, dove ogni gesto scrive una riga —
`tabella_ateco, applicato il …`, `livello ALTO scelto a mano il …`, `livello tolto il
…`. **Ogni riga di quel testo e una riga di `valutazione_sede`**: quando si migra, il
testo si smonta in `attributo`, `valore`, `motivazione`, `deciso_il`, `deciso_da`, e le
righe vecchie diventano quelle con `revocato_il` valorizzato. Era il motivo per cui la
colonna e stata scritta con un prefisso riconoscibile.

### 3. ~~Il seed dei 268 alias~~ — fatto il 16 settembre, e confermato

**Non e piu un punto aperto.** Il seed lo carica la prova generale, subito dopo le
migrazioni, e ne **conta i giudizi** invece di limitarsi a caricarlo: 268 righe, 237
mappate su 39 codici, 31 ignorate, 98 aggiornamenti, 7 parziali, 2 pregresse. La prova
negativa non toglie righe, ne **cambia una**: le righe restano 268, i controlli interni
del file passano lisci, e a protestare e il conteggio — che e la forma vera del
rischio, perche un seed alterato non lascia nessun segno.

**Ed e confermato contro il database vivo**, con l'impronta di
`migrazione-dati/impronta_alias.sql`: `corso_alias` in produzione su AppSopralluoghi e
il seed danno la stessa stringa su 268 righe, e i nove conti coincidono uno per uno.
Nessuno ha cambiato un giudizio dall'interfaccia dopo gli script. La riga «resta da
confermare contro il database vivo», aperta il 10 settembre, e chiusa.

**Una cosa emersa per caso e da non ritrovare per caso:** anche in **AppFormazione**
esiste una `corso_alias`, con la colonna `testo` — cioe lo schema di questo repo,
applicato la. Quei 268 giudizi possono vivere in **due** posti, e il repo unico dovra
sapere da quale legge.

### 4. I ruoli: due fonti, e da oggi sappiamo quale vale

La stessa colonna «RSPP» del gestionale e stata letta in due modi, e oggi lo abbiamo
misurato: il **passo 03** distingue `datore_lavoro_rspp` (116) da `rspp` (3); il
caricatore di AppFormazione la mappava dritta su `rspp` — 28 righe, **tolte oggi**
perche sbagliate.

Quindi, per il repo unico: **la fonte dei ruoli e l'export letto dal passo 03**, e
`ruoli_persona` di AppFormazione **non migra**: si ricostruisce. Resta una cosa da
verificare, non da decidere: se il passo 03 copra anche gli addetti antincendio che
stavano nelle colonne delle emergenze — le 29 righe caricate oggi di la — o se quel
pezzo di lettura vada portato dentro.

### 5. La sorveglianza: le tabelle ci sono, il passo no

`accertamento` e `sorveglianza` esistono dalla `0005` (scheda 10). Gli **808
accertamenti** gia raccolti non hanno ancora un passo di import. Non blocca niente e
puo andare in coda.

### 6. Cosa non entra, e va detto adesso

- **Il corpus normativo e il raccordo ISTAT** (3.257 codici, 6.742 righe) tornano a
  monte, alla libreria, e ci restano: sotto la scheda 7 la libreria e la sorgente, non
  una copia.
- **Contatti, referenti, coordinate**: fuori dal perimetro dell'anagrafe. Restano
  nell'origine.
- **kitformasubito**: fuori dall'ecosistema (scheda 4).

## L'ordine, e perche questo

1. **La forma dell'evento formativo** — le tre risposte, poi la migrazione `0021`.
   **Fatto** il 16 settembre.
2. **Il passo 04: gli attestati.** Sblocca la Fase 4, ed e il pezzo con piu righe.
   **Fatto**, e arrivato in fondo sui dati veri la sera del 16. **Il passo 05**, le
   sessioni dei due export `FormFraz`, e scritto e provato sui dati finti il 17: le
   chiusure dei percorsi erano gia fra gli attestati del 04, e il 05 le riconosce.
3. ~~**Annata ATECO e operatore, poi il passo 05: le valutazioni di sede.** Dipende da
   due decisioni tue, non da lavoro.~~ **Il numero 05 e andato alle sessioni dei
   percorsi frazionati** (17 settembre: `05_frazionata.sql` e la `0022`), quindi le
   valutazioni di sede sono il **passo 06**. Le due decisioni sono prese (qui sotto):
   resta la misura su 2007 e 2022 a livello di divisione, e poi il lavoro.
   **Scritto e provato sui dati finti il 17** (`06_valutazioni.sql`, `0023`): la misura
   c'era gia in AppFormazione, e il rischio uguale al default non si scrive (decisione 8).
   Manca il giro sui dati veri, con una nuova estrazione.
4. **Il seed degli alias.** Non dipende da niente: puo andare in qualunque momento, e
   conviene presto perche e quello che si perde piu facilmente.
5. **La sorveglianza.**
6. **La prova generale si estende a ogni passo nuovo**, con i suoi conteggi attesi.

I primi due sbloccano la Fase 4; il terzo aspetta te; gli altri non bloccano nessuno.

## Come si prova, e non e da inventare

La prova generale esiste, e il 16 settembre e arrivata in fondo **sui dati veri**:
cluster usa e getta, tutte le migrazioni in ordine, il passo 00, i quattro CSV, i passi
01-02-03 con i conteggi attesi, i conteggi finali, e il cluster cancellato anche quando
si ferma. **Ogni passo nuovo entra li dentro con i propri conteggi attesi**, altrimenti
non e finito.

Due cose imparate oggi che valgono per i passi nuovi:

- l'SQL Editor scrive i valori nulli come la **parola** `null`: si carica con
  `null_scritto=null`, e si verifica alla fonte che nessun valore vero sia quella
  parola (la query sta in `estrazione.md`);
- **l'SQL Editor non tiene una sessione fra un comando e l'altro**: niente tabelle
  temporanee e niente transazioni che attraversino due comandi. Chi genera SQL per
  quell'editor se lo deve portare dentro comando per comando.

## Cosa serve da Francesco: tre domande

**Risposte tutte e tre da Francesco il 16 settembre 2026.**

1. **L'attestato.** Due righe sulla stessa identita **si segnalano**, non si fondono; la
   validita si conta dal **completamento del percorso**; le **ore dell'export si
   portano come provenienza e il motore non le legge mai**, perche un attestato si
   giudica col catalogo datato (`corso_regime_precedente`).
2. **L'annata ATECO: `2007` sui codici migrati** — non 2025. Per i nuovi inserimenti la
   scheda chiedera a quale classificazione appartiene il codice (`ateco_versione`
   accetta gia 2007, 2022, 2025). **Annotato come da verificare:** se a livello di
   **divisione** (due cifre, che e la grana che avete) 2007 e 2022 diano classi diverse.
   Non e misurato, e finche non lo e la scelta `2007` non va citata come se lo fosse.
3. **L'operatore: Francesco.** Le valutazioni migrate portano la sua firma, e la
   motivazione dice cosa quella firma significa: «migrato dal gestionale il 16/09/2026:
   come e stato deciso non risulta». La firma e sulla **migrazione**, non su 261
   giudizi presi uno per uno.

**Con queste, la migrazione dell'evento formativo e il passo 04 si possono scrivere.**
