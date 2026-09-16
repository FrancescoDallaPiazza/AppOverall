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

E prima dello schema servono tre risposte, e **nessuna e tecnica**:

1. **Cosa identifica un attestato.** Persona + corso + data di fine basta? Le
   formazioni **frazionate** hanno piu sessioni e una finestra di completamento
   (`finestra_completamento_mesi` esiste gia nel catalogo): l'evento e il corso o la
   sessione? Da questo dipende se la tabella e una o due.
2. **Come si aggancia al catalogo.** La scheda 9 dice: chiave = **codice curato**, e
   l'impronta `GEST-`+md5 del gestionale e un **alias**, non un'identita. Quindi
   l'attestato punta al codice curato e porta accanto l'alias da cui e arrivato — la
   forma c'e gia in `corso_alias`, e il passo di import deve usarla e non aggirarla.
3. **Cosa si fa delle ore.** Misurato il 12 settembre: **il gestionale ha riscritto le
   ore dello storico** con quelle dell'ASR 2025, quindi la colonna `ore` dell'export
   non dice cosa e stato erogato. Le scelte sono due e vanno dichiarate: non portarla,
   oppure portarla con una colonna accanto che dice «riscritta alla fonte, non
   verificabile». **Quello che non si fa e portarla e basta.**

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

### 3. Il seed dei 268 alias, che adesso ha la sua tabella

`supabase/seed/corso_alias.sql` sta nel repo dal 10 settembre e in testa dice: *«la
tabella che questo file riempie non esiste ancora qui»*. **Non e piu vero**:
`corso_alias` c'e dalla `0004`. Il seed va caricato come **passo della migrazione
dati**, con i suoi conteggi attesi — 268 righe, 237 mappate, 31 ignorate, 98
aggiornamenti, 7 parziali, 2 pregresse — e la nota che `ATTR_GENERICO` non e
referenziato da nessun alias, che e un buco da conoscere e non un errore.

Sono **268 giudizi presi a mano**: se si perdessero, la tabella ci sarebbe lo stesso e
nessuno se ne accorgerebbe. Per questo il seed si **esporta** e non si rigioca.

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
2. **Il passo 04: gli attestati.** Sblocca la Fase 4, ed e il pezzo con piu righe.
3. **Annata ATECO e operatore, poi il passo 05: le valutazioni di sede.** Dipende da
   due decisioni tue, non da lavoro.
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

1. **L'attestato**: cosa lo identifica (corso o sessione, con le frazionate di mezzo), e
   cosa si fa delle ore riscritte dal gestionale.
2. **L'annata ATECO** da attribuire ai codici che arrivano dal gestionale.
3. **L'operatore** a cui attribuire le valutazioni di sede migrate — una persona vera,
   perche `valutazione_sede.deciso_da` punta a `operatore` e non accetta null.

Finche non arrivano, il punto 4 (il seed) si puo fare lo stesso, e il punto 5 pure.
