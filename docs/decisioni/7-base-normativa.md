# 7 · Chi possiede la base normativa, e chi puo modificarla

**Decisa il 9 settembre 2026.** E l'unica decisione di governo fra le sette: non
dice cosa costruire, dice chi ha l'ultima parola su cosa e vero.

## Il problema

La base normativa sta in quattro posti con quattro regole diverse:

| dove | cosa | regola |
| --- | --- | --- |
| `AppFormazione/reference/` | 16 PDF e 2 tavole ISTAT, 11 trascrizioni **con parte, punto, pagina** | dichiarata nel CLAUDE.md, rigorosa |
| `AppFormazione/supabase/migrations/` | le tabelle applicative | A7: entra solo cio che e citato |
| `Organigramma-sicurezza/.../references/` | 7 `.txt` trascritti, 4 accordi RAW, `ateco-rischio.md` | nessuna, e contiene un errore |
| `formazione-81-utils-src` | `allegato_iv_asr2025.js`, `raccordo_ateco.js`, `raccordo_istat_2025.js` | ricostruita da fonti incrociate |

Il difetto di governo in una riga: **c'e una sorgente autorevole e tre valli che non
ne dipendono.** Una correzione a monte non arriva mai a valle.

E l'asimmetria peggiore: **la libreria e a monte dell'app da campo ma a valle di
niente.** Genera senza derivare. E per questo che le e mancato il raccordo ISTAT per
quattro mesi senza che nessuno se ne accorgesse — e che `ateco.ts`, in campo,
classifica ancora un codice ATECO 2025 sbagliando su 62 codici.

## Decisione

**La libreria `formazione-81-utils-src` resta il generatore unico, e `reference/` la
alimenta.**

Non viene dismessa con la Fase 5: diventa **la base normativa** di tutto il gruppo —
a monte di AppOverall, di AppSopralluoghi finche vive, e delle skill. Le tabelle
applicative del repo unico si generano da li, non si trascrivono a mano una seconda
volta.

Il motivo per cui questa strada e stata scelta contro l'alternativa (il repo unico
come sorgente, e la libreria dismessa): la conoscenza normativa deve restare
**riusabile fuori da questo progetto**, e una libreria e il posto giusto per quello;
un modello SQL dentro un'applicazione non lo e.

## Due materie, non una

La prima stesura di questa scheda diceva «la libreria genera la base normativa» come
se la base normativa fosse una cosa sola. Non lo e, e la distinzione non e teorica:
**meta di quello che sta in `reference/` non puo entrare in una libreria**, e finche
non si dice dove va, resta nella testa di chi l'ha letto.

**(a) Le tabelle.** Divisione ATECO -> classe di rischio, ore e periodicita di
aggiornamento per figura, la matrice dei crediti, il raccordo ATECO 2025 -> 2007.
Hanno una chiave e un valore, si derivano dalla fonte in modo deterministico, e due
persone che le trascrivono ottengono lo stesso risultato. **Queste stanno nella
libreria**, generate, citate riga per riga, versionate. Chi le consuma le rigenera,
non le modifica.

**(b) Le interpretazioni.** FAQ, interpelli, e il silenzio della fonte. Non hanno
chiave e non diventano righe di tabella. Vanno in tre posti diversi, e vale la pena
scriverli perche oggi non sono scritti:

| tipo | esempio vero | dove vive |
| --- | --- | --- |
| **sposta un dato caso per caso** | Interpello 1/2025: la classe ATECO e un default che la valutazione dei rischi puo alzare *o abbassare* | un **campo** dell'applicazione — l'override con motivazione e fonte — piu la regola di schermata. Mai nella libreria |
| **precisa come si legge una regola** | il buco del 23 maggio 2023 fra «prima del 23» e «a partire dal 24» | una **nota nella trascrizione**, accanto alla regola che precisa |
| **riempie un silenzio della fonte** | le 6 e 4 ore di aggiornamento del primo soccorso, decise da Overall perche il DM 388 non le fissa | **prassi aziendale dichiarata**, marcata come tale e con la data in cui smettera di esserlo |

La conseguenza operativa: la libreria **non** e il posto dove finisce tutto. E il
posto dove finisce cio che ha una chiave. Il resto ha bisogno di un posto suo, e la
scheda 5 e il controesempio piu chiaro — «le divisioni 30, 86 e 87 sono alto rischio»
non e una riga di tabella finche non ha una fonte, ed e esattamente per questo che la
libreria oggi la scrive e non la puo dire.

## La gerarchia delle fonti

E il pezzo che mancava del tutto. Il motore poggia su sei tipi di fonte che dicono
cose diverse con autorita diversa, e quando due discordano oggi si decide a mano, una
volta per uno, senza lasciare traccia riutilizzabile. `reference/README.md` sa gia
dichiarare **che** due fonti non concordano: non ha una regola per **quale vince**.

Dal piu forte al piu debole:

| # | fonte | esempi in `fonti/` |
| --- | --- | --- |
| 1 | **Norma primaria e decreti attuativi** | D.Lgs. 81/2008; DM 388/2003; DM 02/09/2021; DI 22/01/2019 |
| 2 | **Accordo Stato-Regioni**, nel perimetro che l'art. 37 c. 2 gli rimanda | ASR 17/04/2025 (Rep. 59/CSR) e i cinque abrogati |
| 3 | **Interpello** ex art. 12 D.Lgs. 81/2008: risposta ufficiale, valore nazionale | Interpello MLPS 1/2025 |
| 4 | **FAQ interregionali** — orientamento condiviso fra le regioni, non fonte di diritto | Commissione Salute 31/07/2025; interregionali 27/03/2026 |
| 5 | **FAQ regionali** — stessa natura, perimetro piu stretto | FAQ Regione del Veneto |
| 6 | **Prassi aziendale dichiarata** — quando tutte tacciono | le ore di aggiornamento del primo soccorso |

Tre regole, e sono quello che rende la gerarchia utilizzabile:

**G1 · Una fonte piu debole non puo contraddire una piu forte. Puo solo riempire un
silenzio.** Se una FAQ dice il contrario dell'accordo, la FAQ si annota e non si
applica. Se dice qualcosa dove l'accordo tace, si applica e si cita.

**G2 · A parita di rango, vince la lettura che produce l'obbligo prima o la classe
piu alta**, e la scelta si dichiara come precauzione, non come lettura.

**G3 · Ogni conflitto sciolto lascia una riga scritta** nella trascrizione della fonte
perdente: cosa diceva, perche non si applica, in che data si e deciso. Un conflitto
sciolto senza traccia si ripresenta identico fra sei mesi.

**G1-bis · Il rango di chi porta la notizia non e il rango della notizia.** Una FAQ
che **cita una norma primaria** porta il rango di quella norma, non il proprio: non
sta contraddicendo l'accordo per conto suo, lo sta leggendo alla luce di qualcosa che
gli sta sopra. Una FAQ che afferma in proprio vale rango 4. Senza questa distinzione
G1 sbaglia il primo caso su cui viene applicata, ed e il caso qui sotto.

### La gerarchia, appena scritta, viene confermata da una decisione che non la conosceva

**La prima stesura di questo paragrafo era falsa, e la verifica costava un comando.**
Diceva che G1 rovescia una scelta gia fatta e che il progetto usa il 24 maggio. Non e
vero **dal 6 settembre 2026**: `AppFormazione/supabase/migrations/0043_entrata_in_vigore_19_maggio.sql`
(commit `eba5a4e`) porta gia tutti i termini transitori al **19 maggio**, e la ragione
scritta nel suo commento e — parola per parola — *«dove si sbaglia, si sbaglia in
anticipo»*, sugli stessi **167 preposti**.

Cioe **G2, detta da chi G2 non l'aveva mai vista.**

Quindi la gerarchia non rovescia niente: **conferma**, arrivando allo stesso numero
per un'altra strada e tre giorni dopo. E la validazione piu forte che quelle regole
potessero avere — meglio di un caso costruito apposta, perche nessuno dei due lati
sapeva dell'altro.

**Ma il caso e anche il controesempio che ha prodotto G1-bis**, e questa parte non
era stata vista da nessuna delle due corsie. Il conflitto vero non era FAQ contro FAQ:
era la **Parte VII punto 1 dell'accordo** — rango 2, *«entra in vigore il giorno della
pubblicazione nella Gazzetta Ufficiale»*, e la Gazzetta e la n. 119 **del 24 maggio**
— contro le FAQ interregionali, rango 4. **G1 letta alla lettera darebbe il 24.**

Da il 19 per una ragione sola: la FAQ non parla in proprio, invoca l'**art. 32 della
legge 69/2009**, che e rango 1. La FAQ e il messaggero, non la fonte. Senza G1-bis la
gerarchia avrebbe sbagliato il suo primo caso reale — e lo avrebbe sbagliato
*sembrando* di funzionare.

**Cosa resta aperto, e non e piu la data.** La nota in
`AppFormazione/reference/faq-asr-2025.md` dice ancora che «il progetto usa il 24
maggio» e che «va sciolto»: e ferma a prima del 6 settembre e contraddice la
migrazione 0043. Non e un file di questo repo — va segnalata alla corsia che lo
tiene, non corretta da qui.

## Cosa la decisione adesso richiede

La libreria non ha oggi la disciplina che questo ruolo comporta. Tre regole, e sono
il prezzo della scelta. Valgono sulla materia (a): le tabelle.

**R1 · Le fonti stanno accanto al generatore.** I PDF e le trascrizioni citate
alimentano la libreria: vanno dove lei le puo leggere. I `.txt` di
Organigramma-sicurezza si assorbono nella stessa raccolta — sono in formato
*migliore* dei nostri PDF, perche gia trascritti.

**R2 · Ogni riga generata deve poter dire da dove viene.** Oggi la libreria dichiara
le fonti in un commento d'intestazione, per l'intera tabella. Non basta: serve la
citazione **per riga**, parte-punto-pagina, come nelle nostre migrazioni. Le
divisioni 30, 86 e 87 sono il controesempio — le riempie con `ALTO` senza poterlo
dire, e sotto R2 quella modifica non entrerebbe. E A7 applicata a un repo che oggi
non la segue.

**R3 · Chi consuma dichiara la versione.** `ateco.ts` gia dice in intestazione da
dove e generato. Va aggiunto **quando** e **da quale commit**, cosi un difetto a
monte si rintraccia a valle invece di restare invisibile per quattro mesi.

Sotto queste regole, consegnare il raccordo ISTAT non e copiare un file: e portarlo
**con la provenienza dentro** — la tavola ISTAT, la data, il commit che lo genera.

## R4 · Il ciclo di aggiornamento

Le prime tre regole dicono **come una riga entra**. Questa dice **cosa succede
quando la fonte da cui e entrata cambia**, ed e la meta che mancava: una base
normativa ferma non e una base normativa, e una fotografia.

Una parte esiste gia, ed e scritta bene:
[`aggiornamento-fonti.md`](../../../AppFormazione/reference/aggiornamento-fonti.md)
tiene il controllo mensile sul D.Lgs. 81/2008 — la fonte identificata (il testo
coordinato Amato/Di Fiore, che dichiara l'edizione in home), la tabella «edizione in
mano / letta il», i sei passi con il comando di scarico, e la lista dei **16 articoli**
su cui il motore poggia davvero, cosi si leggono quelli e non 1.466 pagine. Ha gia
prodotto un ritrovamento: l'art. 37 c. 11 era cambiato il **31 dicembre 2025**.

**Il difetto e che quella procedura si ferma a monte.** Finisce a «trascrivi, e se la
regola si legge entra in una migrazione». E lo stesso difetto del raccordo ISTAT in
una forma nuova: un aggiornamento che arriva in `reference/` e non arriva a `ateco.ts`
non e un aggiornamento, e una nota. La catena va scritta fino in fondo, ed e di
cinque anelli:

    1. rilevo che la fonte e cambiata
    2. trascrivo cosa e cambiato, con la citazione
    3. trovo le righe che ne dipendono
    4. rigenero la libreria
    5. rigenero i consumatori e aggiorno la versione dichiarata

**Il passo 3 e la ragione per cui R2 vale il suo prezzo**, e non era detto: se ogni
riga generata cita parte-punto-pagina, allora quando un articolo cambia si puo
*chiedere* quali righe lo citano e ottenere la lista. Senza citazione per riga il
passo 3 si fa a memoria, cioe non si fa. Il passo 5 e R3 usata al contrario: la
versione dichiarata dal consumatore serve a sapere quando **non** e stata rigenerata.

### Due meccanismi, non tre cadenze

La prima stesura elencava tre cadenze — mensile, trimestrale, a evento — e la terza
era una finzione: «a evento» non e una cadenza, perche nessuno pubblica un feed del
giorno in cui esce un decreto attuativo. La domanda giusta per ogni fonte non e *ogni
quanto la guardo*, ma **cosa mi accorgerebbe che e cambiata**. Posta cosi, quasi tutte
hanno gia una risposta, e le tre cadenze si riducono a due meccanismi.

| sentinella | cosa mi accorgerebbe | chi lo fa |
| --- | --- | --- |
| modifiche al D.Lgs. 81/2008, i 16 articoli che reggono il motore | il testo coordinato **annota ogni comma modificato** con il provvedimento e la data | il controllo mensile, gratis |
| tavole ATECO ISTAT | la pagina ISTAT della classificazione dichiara data e versione | il controllo mensile, se la pagina e stabile |
| il decreto attuativo dell'**art. 45 c. 2** | *da verificare* — vedi la riserva qui sotto | il mensile se lo annota, altrimenti il promemoria |
| statistiche INAIL sull'inabilita permanente | sono **triennali**, in Gazzetta, aggiornate al 31 dicembre: la finestra e prevedibile | promemoria a data, non un watcher |
| nuove FAQ interregionali o regionali | nessun feed: le pubblicano il Coordinamento e le regioni sui propri siti | il promemoria trimestrale |
| un nuovo ASR, o una modifica dell'ASR 2025 | nessun segnale automatico affidabile — ma e notizia di settore, e arriva prima da li | il promemoria trimestrale |

**Meccanismo 1 · il controllo mensile**, che legge una stringa e la confronta con
l'ultima osservata. **Meccanismo 2 · il promemoria trimestrale**, che non controlla
niente e non finge di farlo: porta davanti la lista delle cose che vanno guardate a
mano. Piu un promemoria a data per l'INAIL.

**La riserva, dichiarata invece di essere scoperta dopo.** Un decreto attuativo
dell'art. 45 c. 2 e un atto separato: non e detto che modifichi il testo
dell'articolo, quindi **non e garantito che il testo coordinato lo annoti**.
`aggiornamento-fonti.md` dice che ogni comma modificato porta la nota; non dice cosa
fa con i decreti attuativi. Va guardato al primo controllo utile: se lo segnala, la
sentinella e coperta dal mensile; se non lo segnala, scende nel trimestrale. Non si da
per buono adesso.

Nota di merito, emersa proprio da questo esercizio: le statistiche INAIL **non sono
ancora in `fonti/`**, e servono alla condizione II del gruppo A di primo soccorso. Il
buco c'era gia — lo dichiara `reference/README.md` — ma nessuna cadenza lo faceva
riemergere.

### Il registro, e i suoi tre esiti

Ogni controllo lascia una riga **anche quando non cambia niente**: data, cosa si e
guardato, esito. Serve per la ragione opposta a quella che sembra — non a provare che
il lavoro e stato fatto, ma a sapere **da quando** non lo e. «Ultimo controllo: marzo»
e un'informazione; il silenzio no.

Il registro sta in [`../registro-normativa.md`](../registro-normativa.md), qui, e non
nel repo di una corsia: il ciclo appartiene alla base normativa del gruppo, e cosi
sopravvive al trasloco previsto da R1.

Gli esiti sono **tre, non due**, ed e la parte da non sbagliare:

| esito | cosa significa |
| --- | --- |
| **invariato** | ho guardato, la fonte dichiara quello che dichiarava prima |
| **cambiato** | ho guardato, dichiara altro: parte la catena dei cinque anelli |
| **non verificabile** | **non ho potuto guardare**: sito irraggiungibile, pagina cambiata, stringa non trovata |

Il terzo esiste perche senza di lui un controllo scritto male **tace**, e nel registro
il silenzio e indistinguibile da «invariato». Sarebbe la stessa forma di difetto gia
presa due volte su questo progetto: la lettura non paginata che tronca a 1000 e
presenta l'assenza come un insieme completo, e il «141 su 141» che contava solo le
righe che il codice fiscale ce l'avevano. **Un'assenza che si presenta come una
conferma.**

### Cosa l'agente puo scrivere da solo

Il controllo mensile e automatico e **committa la sua riga senza chiedere**. Una PR
al mese che dice «invariato» verrebbe approvata senza leggerla, e un'approvazione
automatica e peggio di nessuna: da l'impressione del controllo senza il controllo.

Il confine e questo, e vale come regola: **l'agente scrive cio che ha osservato, mai
cio che ne ha concluso.** Data, fonte, stringa dichiarata, esito. Non trascrizioni,
non migrazioni, non righe di tabella — quelli sono gli anelli 2-5 e richiedono una
citazione, che un controllo automatico non sa produrre. E R2 applicata a chi scrive
invece che a cio che e scritto.

Nota di separazione, per non creare la doppia verita che questo repo esiste per
chiudere: il registro dice **cosa la fonte dichiara oggi**; la tabella «Stato» di
`aggiornamento-fonti.md` dice **quale edizione e stata letta e trascritta**. Sono due
fatti diversi, e non si duplicano. **Il divario fra i due e il segnale**: quando il
registro osserva un'edizione che la tabella non ha ancora letto, c'e lavoro da fare.

### Cosa R4 richiede e oggi non c'e

- **Un innesco.** «Ogni mese» e un'intenzione: l'unica traccia e la data «letta il» in
  una tabella, e un mese e abbastanza per dimenticarsene. Va agganciato a qualcosa che
  parte da solo e avvisa **solo se l'edizione dichiarata e cambiata**.
- **Un controllo sul derivato.** Sotto R3 ogni consumatore dichiara da quale commit e
  generato: confrontarlo con l'ultimo dice «`ateco.ts` e fermo a N commit fa». E il
  controllo che avrebbe trovato il buco di quattro mesi in un minuto.
- **Una cadenza per le FAQ.** Oggi e «vale un giro quando una regola discussa torna a
  galla», che non e una regola. Vanno trattate come l'81/08: una «edizione in mano»
  dichiarata anche per loro.
- **La reazione al conflitto.** L'aggiornamento non porta solo cose nuove: porta cose
  che **contraddicono** una regola gia in produzione. Li scattano G1 e G3, e la
  procedura di oggi non ci arriva.

Nota di collocazione: sotto R1 le fonti traslocano accanto al generatore, e
`aggiornamento-fonti.md` **trasloca con loro**. Finche non succede, il ciclo di
aggiornamento della base normativa del gruppo vive nel repo di una sola corsia.

## Cosa resta da sciogliere

- **Le fonti traslocano dentro la libreria, o restano in un repo e lei le vendora?**
  Sono repo separati: un generatore JS non legge i file di un altro repo a tempo di
  build senza copiarli. La strada pulita e che `reference/` diventi parte della
  libreria; ma va detto, perche sposta 16 PDF, 2 tavole ISTAT e 11 trascrizioni.
- **Dove vive la materia (b).** Le tabelle hanno una casa dichiarata; le
  interpretazioni no. Il campo di override dell'Interpello 1/2025 e uno schema, non
  una libreria: e la prima cosa che la Fase 3 deve sapere.
- **La nota ferma in `faq-asr-2025.md`.** Dice ancora che il progetto usa il 24 maggio
  e che «va sciolto»: la migrazione 0043 l'ha sciolto il 6 settembre, sul 19. E una
  riga falsa nel repo di un'altra corsia, e va segnalata la, non corretta da qui.
- **Il nome.** `formazione-81-utils-src` si annuncia come una raccolta di utilita.
  Se diventa la base normativa del gruppo, il nome dice la cosa sbagliata a chiunque
  ci arrivi senza contesto.
- **Chi puo modificarla.** Sotto R2 la risposta e implicita — chi puo citare — ma non
  e scritta da nessuna parte, e la libreria oggi non ha ne CLAUDE.md ne una regola.
