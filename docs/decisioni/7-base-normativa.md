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

### La gerarchia, appena scritta, produce subito un esito

E onesto dirlo qui invece di scoprirlo dopo: **G1 rovescia una scelta gia fatta.**

Sull'entrata in vigore dell'ASR 2025, le FAQ del Veneto (rango 5) dicono **24 maggio
2025**; le FAQ interregionali del 27/03/2026, quesito 11, dicono **19 maggio 2025**,
citando l'art. 32 della legge 69/2009. Il progetto usa il 24 maggio, e la ragione
scritta in `faq-asr-2025.md` e che il Veneto e la regione in cui l'azienda opera e che
quelle date sono dichiarate e non calcolate. **Sotto G1 vince il rango 4**, e sotto G2
vince comunque il 19 maggio, che e la data che fa scadere prima.

Cosa cambia davvero, misurato: riguarda **167 persone**, e le due scadenze transitorie
dei preposti diventano 19/05/2026 e 19/05/2027 invece del 24. La prima **e gia
passata in entrambe le letture** — oggi e il 9 settembre 2026 — quindi li la domanda
non e di pianificazione ma di conformita all'indietro, su una finestra di cinque
giorni. La seconda e ancora davanti.

Non la cambio io: e una conseguenza della gerarchia, e va decisa sapendo che il
motivo per tenere il 24 maggio sarebbe operativo, non gerarchico.

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

### Tre cadenze

| cadenza | cosa si guarda | perche quella |
| --- | --- | --- |
| **mensile** | D.Lgs. 81/2008, edizione dichiarata | e l'unica fonte che cambia da sola, ogni pochi mesi |
| **trimestrale** | FAQ interregionali, FAQ regionali, nuovi interpelli MLPS | escono a ondate — tre raccolte in otto mesi — e sono la materia (b): spostano interpretazioni, non tabelle |
| **a evento** | ASR e decreti attuativi, tavole ISTAT, statistiche INAIL triennali | non cambiano da soli. Il sorvegliato speciale e l'**art. 45 c. 2**: il giorno in cui esce il decreto che sostituisce il DM 388/2003, le 6 e 4 ore di aggiornamento del primo soccorso smettono di essere prassi aziendale — materia (b), rango 6 — e tornano a essere una lettura |

### Il registro

Ogni controllo lascia una riga **anche quando non cambia niente**: data, cosa si e
guardato, esito. Serve per la ragione opposta a quella che sembra — non a provare che
il lavoro e stato fatto, ma a sapere **da quando** non lo e. «Ultimo controllo: marzo»
e un'informazione; il silenzio no.

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
- **Il 19 o il 24 maggio 2025.** La gerarchia lo decide, 167 persone lo subiscono, e
  la scelta di oggi e quella meno prudente delle due.
- **Il nome.** `formazione-81-utils-src` si annuncia come una raccolta di utilita.
  Se diventa la base normativa del gruppo, il nome dice la cosa sbagliata a chiunque
  ci arrivi senza contesto.
- **Chi puo modificarla.** Sotto R2 la risposta e implicita — chi puo citare — ma non
  e scritta da nessuna parte, e la libreria oggi non ha ne CLAUDE.md ne una regola.
