# 10 · La sorveglianza sanitaria entra nel perimetro?

> **Blocca:** niente subito · ma decide se 808 accertamenti già raccolti hanno un posto, e allarga il perimetro del 26 agosto per la seconda volta
> **In una riga:** **entra, come dominio proprio** — accanto alla formazione e non dentro, perché l'art. 41 non è l'art. 37

**Nata da una misura, non da un'idea.** Il 10 settembre 2026 la corsia
AppSopralluoghi ha enumerato i quattro fogli di `ExportExcel (4).xlsx` — un
workbook che **nessun import apre** — e nel foglio «Visite» ha trovato la
sorveglianza sanitaria già raccolta.

## Cosa c'è dentro, contato — e la prima volta era sbagliato

| accertamento | righe |
| --- | ---: |
| visita medica annuale | 670 |
| visita medica biennale | 106 |
| visita medica quinquennale | 23 |
| visita medica trimestrale | 2 |
| visita medica quadriennale | 2 |
| esame audiometrico | 2 |
| elettrocardiogramma | 1 |
| esame spirometrico | 1 |
| oculistica biennale | 1 |
| oculistica quinquennale | **0** — la colonna c'è, i dati no |
| **totale** | **808** |

**Questa scheda ha scritto 818 per due ore, ed era gonfiato di dieci.** Il foglio ha
**due righe di intestazione**, non una: la riga 1 porta «Ultima Esecuzione» e
«Prossima Scadenza (1 anno)». Leggendo i dati dalla riga 1, ogni colonna contava
un'intestazione come un dato — dieci colonne, dieci di troppo, uno per colonna.
Corretto il 10 settembre 2026 dalla corsia AppSopralluoghi (`9331e61`).

**Come l'ha trovato conta più del numero:** l'indizio era «esattamente una cella non
numerica per colonna», che sembrava rumore. Un'anomalia **uniforme** non è
sporcizia: è struttura non capita. È la stessa forma del difetto delle mille righe di
agosto.

Ogni accertamento è una **coppia di colonne**: quella intestata porta la data,
quella senza nome accanto porta la **scadenza**.

**E la riga scartata era la fonte migliore.** La seconda intestazione **dichiara la
periodicità** — `(1 anno)`, `(2 anni)`, `(3 mesi)`, `(4 anni)`, `(5 anni)` — ed è
indipendente dal titolo. I tre esami (audiometrico, elettrocardiografico,
spirometrico) **non hanno periodicità nel titolo**: senza quella riga sarebbero
entrati nello schema senza regola, o con una inventata.

## Perché non è formazione, e perché conta

È l'**art. 41 del D.Lgs. 81/2008**, non l'art. 37. Due articoli, due obblighi, due
soggetti che li assolvono: la formazione la erogano i formatori, la sorveglianza il
**medico competente** — che nella `0002` esiste già come figura (`medico_competente`,
art. 38) proprio con la nota «si registra la nomina, non un percorso».

La differenza non è formale. Una scadenza formativa si assolve con un corso, che sta
a catalogo; una visita si assolve con un accertamento, che non ha ore, non ha
prerequisiti e non ha aggiornamento — ha una periodicità decisa dal protocollo
sanitario, che varia per mansione e per rischio. Ficcarla nel catalogo dei corsi
avrebbe prodotto **808 adempimenti finti**, ed è per questo che gli undici titoli
di sorveglianza fra i 268 alias sono marcati `ignorato` invece di essere mappati.

## Cosa dice già il codice

**Il posto era previsto e non è mai stato riempito.** `formazioneImport.ts:13` di
AppSopralluoghi scarta le visite dicendo dove andrebbero: «il loro posto è
adempimento categoria sorveglianza». La tabella `adempimento` esiste in quel repo,
ed è stata **misurata vuota** il 10 settembre — zero righe.

Quindi non è una funzione che manca: è una funzione **dichiarata, mai costruita**, e
il dato per costruirla è in un foglio che nessuno apre da mesi.

## Cosa comporta, e va detto prima di cominciare

- **Allarga il perimetro**, ed è la seconda volta dopo la decisione 3. L'assunzione
  **A6** del programma — «il perimetro non si allarga durante il riavvio» — va
  annotata di nuovo. Due allargamenti dichiarati non sono una deriva; due
  allargamenti taciuti lo sarebbero.
- **Non è un ERP sanitario.** Entra la scadenza, non la cartella: il repo deve
  sapere *che* una visita è dovuta e *quando*, non l'esito clinico. Il giudizio di
  idoneità e i dati sanitari restano del medico competente — e su quelli si applica
  l'art. 25 c. 1 lett. c) e il GDPR, quindi il default è **non tenerli**.
- **Il modello somiglia allo scadenzario, non al catalogo.** Un accertamento, un
  protocollo che dice ogni quanto, una data fatta e una scadenza calcolata: è la
  forma di `adempimento`, non quella di `corso`.
- **Le 808 righe sono già lì.** Non è una raccolta da avviare: è un import da
  scrivere, sullo stesso workbook che porta anche i ruoli e i fattori di rischio.

## Decisione

**Presa da Francesco il 10 settembre 2026: entra, come dominio proprio.**

Accanto alla formazione e non dentro: la scadenza sanitaria è un'entità sua, con la
sua periodicità e il suo soggetto: il medico competente. Il catalogo dei corsi —
`corso`, `corso_alias`, `corso_assolve` della `0004` — non si tocca e non la ospita.

Il confine è già scritto nella `0004`, in fondo, come rinuncia dichiarata: quella
migrazione dice che non porta la sorveglianza e perché. Con questa decisione quella
riga cambia di significato — non è più «fuori perimetro», è «prossima migrazione».

### La scadenza si deriva, l'intervallo si memorizza

Misurato prima di scrivere lo schema, ed è la riga che lo decide:

| | |
| --- | ---: |
| accertamenti | 808 |
| con la data e **senza** la scadenza | 12 |
| con la scadenza e **senza** la data | **0** |
| scadenza uguale a data + intervallo dichiarato | **796 su 796** |

Zero deviazioni, nemmeno di un giorno. Le differenze 365/366, 730/731, 1826/1827 non
sono deviazioni: sono gli anni bisestili, e calcolando sul calendario invece che in
giorni tornano tutte.

**Quindi la scadenza si deriva, non si memorizza.** Nessuna riga la corregge a mano,
e lo «zero scadenze senza data» esclude anche il caso che sembrava plausibile — una
scadenza imposta dal medico su una visita non registrata. Le 12 senza scadenza non
sono un controesempio: non contengono un'informazione **diversa**, contengono
un'informazione **in meno**. Derivandola si ottiene esattamente ciò che il gestionale
avrebbe scritto, e quelle 12 smettono di essere un buco.

**Quel che invece va memorizzato è l'intervallo per tipo di accertamento**, perché è
un dato di **regola** e non di fatto — e nel file sta in un posto fragile: fra
parentesi, dentro una sotto-intestazione. Se il gestionale un giorno cambia quel
testo, la regola sparisce senza che nessuno se ne accorga.

Sotto **A9** questa è la situazione opposta ai «fattori di rischio»: qui il riscontro
esterno esiste, e sono **tre fonti concordi** su tutti e nove gli accertamenti con
dati — il titolo dove c'è, la sotto-intestazione per tutti e dieci, e 796 coppie di
date vere. Dove il titolo tace, parlano le altre due.

### Il numero che non torna con AppFormazione

Sullo stesso dominio le due corsie contano cose diverse: **808** qui, **1.148** nel
`staging.catalogo_gestionale` di AppFormazione (167 righe di catalogo, 10 marcate
`tipo = 'VISITA'`).

| accertamento | AppFormazione | campo |
| --- | ---: | ---: |
| annuale | 961 | 670 |
| biennale | 151 | 106 |
| quinquennale | 24 | 23 |
| trimestrale | 2 | **2** |
| quadriennale | 2 | **2** |
| audiometrico | 2 | **2** |
| spirometrico | 1 | **1** |
| elettrocardiogramma | 1 | **1** |
| oculistica biennale | 1 | **1** |
| oculistica quinquennale | 3 | **0** |
| **totale** | **1.148** | **808** |

**La prima versione di questa sezione poggiava su una coincidenza che non esisteva.**
Diceva: «le quinquennali coincidono esatte, 24 e 24», e ci costruiva sopra la lettura
«818 sono le aperte, 1.148 le storiche». Con i numeri corretti sono **24 e 23**: la
coincidenza era un artefatto del conteggio gonfiato di uno.

Il pattern vero è un altro, e dice più di quella coincidenza: **gli accertamenti rari
coincidono esatti** — trimestrale, quadriennale, audiometrico, spirometrico, ECG,
oculistica biennale, tutti uno a uno — **e i frequenti no**, con l'annuale a 961
contro 670. È esattamente la forma che avrebbe «storico contro aperto»: chi fa una
visita annuale accumula molti eventi e ha una sola scadenza aperta, chi ha fatto una
volta un audiometrico ha 1 e 1.

**Una riga però va contro quella lettura**, e non la nascondo: oculistica
quinquennale **3 di là e 0 qui**. Se il campo raccogliesse le scadenze aperte dello
stesso insieme, tre accertamenti storici dovrebbero lasciare almeno una scadenza
aperta. Le spiegazioni possibili — perimetri di clienti diversi, o quelle tre su
clienti che il campo non ha — sono le stesse che il pattern rende improbabili. Non si
scioglie leggendo: si misura contando i **clienti distinti** dei due insiemi e
guardando se le righe del campo abbiano date passate.

Si scioglie **prima della `0005`**: una migrazione che nasce su un conteggio non
sciolto nasce storta.

**Il modello di AppFormazione tiene già le visite fuori dalla formazione, per
costruzione**, e questo è un riscontro al «accanto e non dentro» di questa scheda:
`scripts/promuovi.sql` le esclude nel punto esatto in cui diventerebbero corsi —
`where coalesce(c.e_visita, false) = false` — quindi non entrano mai in `corsi`.

### Cosa resta da decidere, ma non blocca

Quanto del protocollo sanitario deve stare nel sistema. Le periodicità che si vedono
nel foglio (annuale, biennale, quinquennale, trimestrale, quadriennale) sono un
**esito**, non una regola: chi le decide è il medico nel protocollo, per mansione e
per rischio. Tenere solo le scadenze rende il sistema un registro; tenere anche il
protocollo lo rende capace di dire che una visita **manca**, che è la domanda utile.
Si decide quando si disegna la scheda della persona, e va decisa con il medico
competente — non fra noi.
