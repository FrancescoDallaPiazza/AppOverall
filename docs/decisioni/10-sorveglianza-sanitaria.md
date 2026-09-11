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

**~~Quindi la scadenza si deriva, non si memorizza.~~ Si deriva *per default*, e si
può dichiarare — e la prima versione di questa sezione era un difetto grave.**

Il «796 su 796» è giusto come numero e non era una verifica. La colonna «Prossima
Scadenza» del foglio **è calcolata dal gestionale** da esecuzione + intervallo:
confrontarla con esecuzione + intervallo verifica **una formula contro sé stessa**, e
un risultato che non poteva non tornare non prova niente. Non era una terza fonte:
era la stessa fonte guardata due volte.

**La prima fonte davvero esterna dissente in 9 casi su 769**, e non è rumore:
`ExportExcelVisiteScadenze.xlsx` dà nove scadenze **tutte più vicine** di quella
calcolata, zero più lontane, e nessuna corrisponde a un ciclo precedente (verificato
fino a otto cicli indietro). Una differenza casuale andrebbe nei due sensi; una con
una direzione sola ha una causa — e la causa ha un nome: il **richiamo anticipato**
deciso dal medico competente su una persona da rivedere prima della periodicità
ordinaria. Un caso misurato: esecuzione 31.08.2026, calcolata 31.08.2027,
**dichiarata 21.11.2026**.

È il caso clinicamente più importante che esista in questo dominio, ed è esattamente
quello che una scadenza solo derivata **cancella in silenzio**: la riga resta e
sembra giusta. Nove persone da rivedere prima sarebbero diventate nove persone in
regola, e nessun conteggio lo avrebbe segnalato.

Quindi nella `0005`: la scadenza è **derivata** dove nessuno dice altro — e le 12
righe senza scadenza restano un'informazione **in meno**, non diversa — e
**dichiarata** dove una fonte dissente, con la fonte scritta accanto. La vista mostra
calcolata, dichiarata e un `anticipata` booleano, perché un anticipo non si deve
poter nascondere dentro un `coalesce`.

**E i due export sono complementari, non ridondanti**: l'import leggerà due file. Il
foglio è primario — porta l'esecuzione, cioè il fatto, e ha una società e 31 coppie
in più — lo scadenzario porta le 35 coppie che il foglio non ha e l'informazione che
dal foglio non si può derivare. I nomi dei nove tipi coincidono **carattere per
carattere**, quindi nessuna tabella di corrispondenza.

**Quel che invece va memorizzato è l'intervallo per tipo di accertamento**, perché è
un dato di **regola** e non di fatto — e nel file sta in un posto fragile: fra
parentesi, dentro una sotto-intestazione. Se il gestionale un giorno cambia quel
testo, la regola sparisce senza che nessuno se ne accorga.

Sotto **A9** questa è la situazione opposta ai «fattori di rischio»: qui il riscontro
esterno esiste, e sono **tre fonti concordi** su tutti e nove gli accertamenti con
dati — il titolo dove c'è, la sotto-intestazione per tutti e dieci, e 796 coppie di
date vere. Dove il titolo tace, parlano le altre due.

### Il numero che non tornava: non c'era niente da riconciliare

Per un giorno questa scheda ha tenuto due numeri accanto — **808** nel foglio del
campo e **1.148** in AppFormazione — e ha proposto due letture per spiegare la
differenza: «aperte contro storiche» e «perimetri diversi». **Erano entrambe
sbagliate, e la domanda stessa era mal posta.** Sciolto l'11 settembre 2026.

**I 1.148 non sono accertamenti.** Sono la **somma della colonna `occorrenze`** su
**dieci righe** di `staging.catalogo_gestionale` — una tabella con una riga per
**descrizione distinta** di catalogo, non per persona — e vengono da
`0007_seed_catalogo_gestionale.sql`. Le righe con `tipo = 'VISITA'` in quel file sono
**dieci**.

**E nemmeno lo stesso perimetro.** Quella tabella deriva dal report di qualità dati
sull'**estrazione completa di agosto 2026** — non uno dei cinque export — che copre
**dal 2018**: circa 522 aziende, 4.135 persone, 12.500 erogazioni, e include
esplicitamente **cessati ed ex clienti**, con 1.016 persone che hanno eventi e non
hanno riga anagrafica e l'ultimo evento mediano a febbraio 2022. Gli export delle
visite coprono l'attivo, una riga per persona e per tipo.

Quindi il confronto giusto è **10 descrizioni di catalogo contro 808/814 righe di
scadenza**: non misurano la stessa cosa, e non c'era niente da riconciliare.

**Cos'è davvero il conteggio del campo: l'ultima esecuzione per persona e per tipo.**
Non le scadenze aperte, non lo storico. Tutte le 808 esecuzioni sono nel passato, e
delle scadenze **311 sono già scadute**, 485 valide, 12 assenti: se fossero «solo le
aperte» non ce ne sarebbero 311 scadute; se fosse uno storico ci sarebbero più righe
per la stessa coppia persona/tipo, e non ci sono — 801 coppie su 808 righe. È ciò che
dichiara l'intestazione che stavamo per scartare come rumore: **«Ultima
Esecuzione»**.

**Un secondo export, che non sapevamo di avere, conferma il perimetro.**
`ExportExcelVisiteScadenze.xlsx`, dedicato alle visite: 814 righe, 62 società contro
63, 805 coppie (CF, tipo), e la sua colonna data arriva al 2031 — è la scadenza, non
l'esecuzione. Due forme diverse dello stesso gestionale, lo stesso insieme, entrambe
una riga per persona e per tipo. E negli export **degli eventi** le visite non ci
sono affatto: `Genere` vale «Formazione» su 13.348 righe di 13.348. Enumerato, non
supposto.

**Le tre oculistiche quinquennali restano non verificate**, e va detto così: sono tre
occorrenze di quell'estrazione del 2018-in-poi, compatibili con clienti cessati che
gli export dell'attivo non contengono — ma nessuno ha aperto quel file. Sono dati
personali, non stanno nei repo, e il numero letto è quello **cablato nella
migrazione**. Per chiuderla serve qualcuno che apra l'estrazione di agosto.

**Cosa insegna, al di là del numero.** Due corsie hanno costruito due strati di
spiegazione — «storico contro aperto», appoggiato a una coincidenza «24 e 24» che a
sua volta non esisteva — sopra un confronto **mai verificato**. Il difetto non era
nei dati: era non aver guardato **che cosa conta** una colonna prima di metterla
accanto a un'altra. È **A11** nella sua forma più pura, e nessuno dei due numeri era
sbagliato.

### Cosa resta da decidere, ma non blocca

Quanto del protocollo sanitario deve stare nel sistema. Le periodicità che si vedono
nel foglio (annuale, biennale, quinquennale, trimestrale, quadriennale) sono un
**esito**, non una regola: chi le decide è il medico nel protocollo, per mansione e
per rischio. Tenere solo le scadenze rende il sistema un registro; tenere anche il
protocollo lo rende capace di dire che una visita **manca**, che è la domanda utile.
Si decide quando si disegna la scheda della persona, e va decisa con il medico
competente — non fra noi.
