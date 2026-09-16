# 13 · Leggere gli attestati che ci arrivano, in maniera deterministica

> **Blocca:** niente · ma finché è aperta, le ore davvero erogate restano l'unico dato che nessuna fonte sa dire

**Non blocca niente.** La Fase 3 si chiude senza, e la Fase 4 pure: lo scadenzario
gira sugli attestati che arrivano dal gestionale. Questa scheda riguarda gli
attestati **di carta** — i PDF che i clienti e gli enti ci mandano — e apre una
capacità che oggi non abbiamo.

## Cosa è in gioco

C'è una riga che questo repo ha scritto tre volte, e sempre come limite:

> Nessuna fonte nei tre repo può dire **se un corso da 28 ore sia stato erogato in
> 28 ore**. L'export dice sotto quale voce è stato registrato; solo **l'attestato**
> dice cosa è stato fatto. Se un giorno serve saperlo, la strada non è una query: è
> un campione di attestati.

Il 16 settembre 2026 quel limite si è fatto più stretto, non più largo: la colonna
`ore` dell'export è stata **riscritta dal gestionale** con le durate dell'ASR 2025,
quindi non dice nemmeno quello che sembrava dire. La `0021` la conserva come
provenienza e vieta al motore di leggerla.

**Questa scheda è quella strada, resa ripetibile.** La domanda di Francesco, il 16
settembre: *«è possibile implementare una funzione con cui analizzare in maniera
deterministica gli attestati di formazione che ci vengono forniti?»*

## Cosa si può fare davvero, e cosa no

La risposta non è sì o no: è **due stadi con proprietà diverse**, e tenerli separati
è la sostanza della scheda.

| | cosa fa | deterministico? |
|---|---|---|
| **1. dal file al testo** | estrae il testo dal PDF | **solo a metà.** Un PDF nato digitale ha il testo dentro: stesso file, stesso testo, sempre. Una **scansione** richiede l'OCR, che è *riproducibile* (stessa versione, stessi parametri, stesso risultato) ma **non corretto**: può leggere una data sbagliata |
| **2. dal testo ai campi** | codice fiscale, date, ore, ente, titolo del corso | **sì, interamente.** Regole pure, provabili, con il controllo negativo — e il titolo ha già il suo vocabolario: i **268 alias** confermati contro la produzione il 16 settembre |

**Riproducibile e corretto non sono la stessa cosa**, ed è su questa distinzione che
la cosa vive o muore. Un OCR che sbaglia sempre allo stesso modo è deterministico e
inutile.

## La forma che avrebbe, se si fa

Tre regole, e sono le stesse che questo sistema applica altrove:

1. **ogni campo letto porta la sua evidenza**: la stringa esatta e dove stava nel
   documento. Un valore senza evidenza non entra;
2. **tre stati e non due**: `letto`, `incerto`, `non trovato`. Mai «dedotto». È la
   stessa scelta dei tre stati dell'ATECO (`classificaAteco`) e dei tre della scheda
   11: il terzo stato è quello che rende dicibile ciò che il sistema non sa;
3. **una persona conferma.** Un attestato letto da una macchina e scritto in archivio
   senza conferma sarebbe un verdetto senza firma — esattamente ciò che la scheda 8
   ha deciso di non fare per il livello di rischio, e che il bottone RISCHIO evita
   dal 15 settembre.

E una quarta che viene dal dominio dei documenti e non da quello della formazione:
**il file si identifica con la sua impronta**, non col nome. Lo stesso PDF mandato
due volte è una lettura sola; due PDF diversi con lo stesso nome sono due documenti.

## Cosa darebbe

- **le ore davvero erogate**, che è il buco dichiarato non chiudibile;
- l'**ente formatore** e la **data** verificati sul documento e non sul gestionale;
- la possibilità di dire, per un attestato del 2019, se il programma **di allora**
  fosse quello richiesto — che è la domanda a cui `corso_regime_precedente` (`0014`)
  sa già rispondere, e che oggi non ha un termine di confronto.

## Cosa non potrà fare, e va scritto adesso

- leggere una scansione storta o un fax di terza generazione;
- capire un layout mai visto senza che qualcuno glielo insegni;
- **decidere se un attestato è valido.** Quello resta un giudizio, e deve poter
  essere mostrato a un ispettore con una firma sopra.

## Cosa resta da decidere — ed è il motivo per cui questa è una scheda e non un task

1. **Cosa si fa quando la lettura è incerta.** Una coda di documenti da leggere a
   mano? Un campo compilato col valore proposto e marcato? Non si inventa: si decide.
2. **Chi firma.** La lettura automatica propone; chi conferma è un operatore — e
   `valutazione_sede.deciso_da` ha già insegnato che una firma automatica è una firma
   che non vale.
3. **Dove vivono i file.** I documenti sono un dominio che questo repo non ha: serve
   dire dove stanno, per quanto, e chi può vederli. Sono dati di persone.
4. **Se si legge tutto o un campione.** La riga originale diceva «un campione di
   attestati», e un campione ben scelto risponde alla domanda «il gestionale mente
   sulle ore?» senza leggere 13.350 documenti.

## Decisione

*(da scrivere: aperta il 16 settembre 2026 su domanda di Francesco, e messa in coda
da lui stesso — prima si chiude la Fase 3. Le quattro cose da decidere sono qui
sopra, e la prima le regge tutte: cosa si fa quando la lettura e incerta.)*
