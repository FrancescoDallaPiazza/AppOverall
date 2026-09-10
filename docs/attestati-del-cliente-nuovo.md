# Gli attestati del cliente nuovo: dal foglio di carta alla scadenza calcolata

**Che cos'è questo documento.** Il progetto di un percorso che oggi non esiste come
percorso: un cliente nuovo consegna un mazzo di attestati di corsi fatti anni fa con
altri enti, e quelle carte vanno controllate, registrate, agganciate all'obbligo che
assolvono e trasformate in scadenze. I pezzi ci sono, in tre repo; la fila no. Questo
foglio dice quali sono i pezzi, dove si spezza la fila, e cosa deve avere lo schema
del repo unico perché la fila si possa fare — **prima** che le tabelle formative
nascano, non dopo, perché tre degli attributi che servono non si aggiungono a righe
già scritte.

**Metodo.** Ogni affermazione porta `file:riga`. Dove non ho trovato, scrivo che non
c'è invece di riempire il buco: è la regola A7 del cronoprogramma — «una regola
dedotta non entra nelle tabelle applicative» (`AppOverall/docs/PROGRAMMA.md:253-258`).
Le letture sono del 10 settembre 2026, sui tre repo in
`C:\Users\Francesco\Documents\GitHub\`.

**Cosa questo documento non è.** Non è una migrazione e non contiene SQL. La scheda 9
(`AppOverall/docs/decisioni/9-grana-e-chiave-del-catalogo.md`) è ancora aperta e
decide la forma delle tabelle formative: fin quando non è chiusa, qui si dice la
**forma** e il **perché**, non le colonne.

---

## 0. Le tre operazioni, e dove stanno oggi

Il caso reale contiene tre domande che il progetto tratta come una sola e che non lo
sono.

**«Questo attestato vale qualcosa?»** è una domanda sulla **carta**: chi l'ha emessa,
cosa ci sta scritto sopra, se il corso era conforme a quello che la norma chiedeva
quando è stato fatto. Il progetto ha le fonti per rispondere solo in parte, e sa
dichiarare quali parti mancano — è tutto in `AppFormazione/reference/`. Non ha nessuna
tabella dove scrivere la risposta.

**«A quale obbligo assolve?»** è una domanda sul **titolo**, ed è quella meglio
attrezzata: c'è una catena di quattro anelli — alias del titolo, classificazione,
crediti, equivalenze — costruita e provata su 13.215 eventi formativi. La catena però
è tarata su un universo chiuso: i 268 titoli che il gestionale di Overall sa emettere.
Un ente sconosciuto sta fuori da quell'universo per definizione.

**«Quando scade?»** è la domanda risolta. Il motore delle scadenze
(`AppFormazione/supabase/migrations/0024_motore_scadenze.sql:81-172`) calcola otto
esiti, distingue la periodicità della norma da quella battuta nel gestionale, gestisce
decadenza, regimi transitori, esoneri e cicli frazionati, e riproduce lo scadenzario
del gestionale su 4.860 righe su 4.860 (`AppFormazione/docs/04-motore-scadenze.md:319`).
Riceve però un solo dato dalla carta — una data — e non chiede da dove venga.

La rottura sta nel mezzo, ed è di forma prima che di funzione: **il progetto ha un
modello per gli attestati che emette e nessuno per gli attestati che riceve.** La
tabella `attestati` di AppFormazione nasce per «emissione, numerazione progressiva per
anno, archiviazione del file e tracciamento dell'invio al cliente»
(`AppFormazione/supabase/migrations/0003_attestati.sql:2-3`), il suo stato è
`('emesso','inviato','annullato')` (`0003:7`), e `ente_emittente` porta il commento
`-- null = Overall` (`0003:16`). Un attestato di terzi entra in quella tabella come un
attestato di Overall a cui manca qualcosa, non come un oggetto di specie diversa.

---

## 1. I controlli, in ordine, e quale fonte li impone

L'ordine non è arbitrario: si va dal controllo che può invalidare tutto a quello che
sposta un numero. Un controllo che fallisce a monte rende inutile fare quelli a valle,
e questa è anche la ragione per cui la coda umana va posta dove va posta (§4).

Prima di entrare nel merito serve la regola che dice **quale fonte vince** quando due
discordano, perché su quasi ogni controllo qui sotto ce ne sono almeno due. È la
gerarchia della decisione 7 (`AppOverall/docs/decisioni/7-base-normativa.md:80-108`):
norma primaria e decreti attuativi, poi Accordo Stato-Regioni, poi interpello ex art.
12, poi FAQ interregionali, poi FAQ regionali, e in fondo la prassi aziendale
dichiarata. Con tre regole: **G1**, una fonte più debole non contraddice una più forte
ma può riempire un silenzio; **G2**, a parità di rango vince la lettura che produce
l'obbligo prima o la classe più alta, e la scelta si dichiara come precauzione;
**G3**, ogni conflitto sciolto lascia una riga scritta. E **G1-bis**, che è la regola
che questo percorso userà più spesso senza accorgersene: una FAQ che *cita* una norma
primaria porta il rango di quella norma, non il proprio (`7-base-normativa.md:104-108`).

### 1.1 Quale regime si applica — e questo controllo viene per primo

Un attestato non si giudica contro la norma di oggi ma contro quella del giorno in cui
il corso è finito. È il senso per cui esiste
`AppFormazione/reference/quadro-storico-ore-pregresse.md`, che lo dice nella prima
riga: «per sapere se un corso già fatto sia conforme bisogna sapere a che cosa doveva
essere conforme quando è stato fatto» (`:5-7`).

Lo spartiacque è l'entrata in vigore dell'ASR 17/04/2025 (Rep. Atti n. 59/CSR). Il
progetto usa il **19 maggio 2025** e non il 24, e non è un errore: è una decisione del
6 settembre 2026, applicata dalla migrazione `0043_entrata_in_vigore_19_maggio.sql`,
perché le FAQ interregionali del 27/03/2026 invocano l'art. 32 della legge 69/2009,
che è norma primaria (`AppFormazione/reference/asr-2025-parte-vii.md:11-26`). È il
primo caso reale su cui la gerarchia è stata provata, ed è quello che ha prodotto
G1-bis (`7-base-normativa.md:126-135`).

**Automatico**, e a costo zero: è un confronto fra la data di fine corso e una
costante. Ma dipende dal dato che il caso peggiore non ha, cioè la data. E porta con
sé un difetto che ho trovato guardando: **il file che si userebbe come lista di
controllo dice ancora 24 maggio.**
`AppFormazione/reference/assorbite-organigramma/ASR_59_2025_punto6_ATTESTAZIONI.txt:27`
recita «Applicabile agli attestati emessi dal 24/05/2025», e la sua nota di testa non
lo corregge — corregge il punto 7 e i tre elementi inventati, non la data. Il
`README.md` della stessa cartella dichiara il conflitto del 19 contro il 24 ma lo
attribuisce all'altro file, quello del 2011 (`assorbite-organigramma/README.md:70-78`).
Chi prendesse quel `.txt` come checklist applicherebbe il regime vecchio agli
attestati del 19, 20, 21, 22 e 23 maggio 2025. Sotto G3 quella riga va scritta lì.

### 1.2 Chi poteva emetterlo — **la fonte non c'è**

Questo è il controllo che il senso comune mette per primo e che il progetto **non può
fare**, e la ragione è documentale, non tecnica.

L'ASR 2025 dice che l'attestato è «rilasciato dal soggetto formatore» (punto 6, in
`ASR_59_2025_punto6_ATTESTAZIONI.txt:31-32`), e l'accordo del 2011 dice «ente o datore
di lavoro abilitato» (`ASR_221_2011_punto7_ATTESTATI.txt:37`). **Chi sia un soggetto
formatore non è trascritto da nessuna parte in `reference/`**: verificato con una
ricerca su tutti gli `.md` e i `.txt` della cartella, le sole sei occorrenze di
«soggetto formatore», «ente formatore» e «accreditato» sono quelle appena citate più
tre nella trascrizione del punto 6 e una nelle FAQ (`faq-asr-2025.md:108`). La Parte I
dell'ASR 2025 che definisce i soggetti formatori sta dentro
`reference/fonti/ASR-170425.pdf` ma non è stata letta e trascritta. Sotto A7, finché
non lo è, **non può entrare in nessuna tabella e non può essere citata su una
contestazione**.

Peggio va con i **requisiti dei formatori**. Il Decreto Interministeriale 6 marzo 2013
è ricostruito a memoria in
`assorbite-organigramma/DI_06_03_2013_REQUISITI_FORMATORI.txt`, e il file lo dichiara
da sé nella testata: «**DEDOTTO**… non è una trascrizione: è un riassunto di memoria, e
non è stato possibile confrontarlo» (`:9-11`), «**CITAZIONE: nessuna**… i 21 file di
`fonti/` non lo comprendono» (`:12-16`), «sotto A7 questo file **non può entrare in una
tabella applicativa** e non può essere citato su un attestato o su una contestazione»
(`:17-21`). Il contenuto — prerequisito del diploma, sei criteri per ciascuna delle tre
aree, le 64 ore del corso abilitante, le 24 ore triennali di cui 8 di docenza
(`:32-48`) — vale come promemoria di cosa cercare, non come regola.

**Né automatico né umano: oggi non si fa.** Un occhio umano che guardasse il nome del
docente sull'attestato non avrebbe contro cosa confrontarlo. È la voce più vicina a
diventare una fonte vera — il decreto è pubblicato e si scarica (`:22-25`) — e finché
non entra in `fonti/`, il percorso deve **dichiarare che questo controllo non è stato
fatto**, non ometterlo in silenzio. Un controllo scritto male tace, e nel registro il
silenzio è indistinguibile da una conferma: è la ragione per cui il registro delle
fonti ha tre esiti e non due, e il terzo è `non verificabile`
(`AppOverall/docs/registro-normativa.md:24-36`).

### 1.3 Cosa deve riportare l'attestato

Qui la fonte c'è, ed è la migliore che il progetto abbia su questa materia.

**Regime vigente, dal 19/05/2025** — ASR 2025, Parte I, punto 6, verificato riga per
riga il 10/09/2026 contro `fonti/ASR-170425.pdf`, pagina «Pag. 9 a 136»
(`ASR_59_2025_punto6_ATTESTAZIONI.txt:8-12`). Sei elementi minimi (`:33-39`):
denominazione del soggetto formatore; dati anagrafici del partecipante — **nome,
cognome e codice fiscale**; tipologia di corso con riferimento normativo e durata;
modalità di erogazione; firma del legale rappresentante o di suoi incaricati; data e
luogo. E l'attestato è **unico per ciascun corso** (`:32`), che è la stessa frase che
le FAQ interregionali 2025 n. 53 usano per dire che un percorso scaglionato produce un
attestato solo, alla fine (`reference/faq-asr-2025.md:106-114`).

**Regime abrogato, fino al 18/05/2025** — Accordo 21/12/2011 (Rep. Atti n. 221/CSR),
Allegato A, punto 7. Il file in `reference/` è una **sintesi operativa e non una
trascrizione**, e dichiara tre scarti verificati contro il testo il 10/09/2026
(`ASR_221_2011_punto7_ATTESTATI.txt:16-29`): l'accordo chiede anche il **profilo
professionale** del corsista, condiziona il rilascio alla **frequenza del 90% delle
ore** — e per preposti e dirigenti al superamento della prova — e le date che il file
riporta sono quelle sbagliate. Per citare si va al punto 7 dell'accordo in `fonti/`;
questo file serve a sapere cosa cercare (`:28-29`).

Sui sei elementi il controllo è **automatico solo in apparenza**. Sei caselle di spunta
sono banali da modellare e impossibili da compilare senza qualcuno che legga la carta:
non esiste, in nessuno dei tre repo, un'acquisizione strutturata del contenuto di un
attestato. `AppSopralluoghi` archivia il PDF o la foto in un bucket privato
(`supabase/migrations/021_attestati_storage.sql:17-25`, costante in
`src/lib/supabase.ts:56`) senza estrarne niente; `AppFormazione` tiene una stringa di
path in `attestati.file_path` (`0003_attestati.sql:19`) — nessun bucket dichiarato,
nessun mime, nessun hash, nessuna dimensione. **La lista dei sei elementi è quindi una
lista per un umano**, e il suo esito è un dato da salvare, non un calcolo da rifare.

E qui va detta la cosa che rende questo paragrafo diverso da una checklist: il
contenuto del **fascicolo del corso** — punto 7 dell'ASR 2025 — nella nostra
trascrizione è **sbagliato in tre voci su sette**. Elenca «copia degli attestati;
materiale didattico; questionario di gradimento», che nell'accordo non ci sono, e omette
«progetto formativo e programma del corso», che c'è; l'elenco vero è di cinque voci
(`ASR_59_2025_punto6_ATTESTAZIONI.txt:13-22`). Il conflitto è già sciolto a favore del
testo, con la motivazione scritta: «se quelle tre voci fossero passate in una lista di
controllo, avremmo chiesto a un ente formatore documenti che nessuno gli chiede»
(`assorbite-organigramma/README.md:61-68`). Vale come avvertimento su tutto ciò che
segue: **la lista di controllo di questo percorso non si copia da un file di
`reference/` senza rileggere la fonte.**

### 1.4 Ore e contenuti minimi

Le ore sono l'unico controllo davvero calcolabile, e sono anche quello che il progetto
ha più solido, purché il regime sia stato stabilito al punto 1.1.

Per il regime vecchio le ore stanno in `quadro-storico-ore-pregresse.md`, sette righe
lette con punto e pagina e tre marcate come non leggibili. Lavoratori invariati — 4
generali più 4, 8 o 12 specifiche secondo la classe di rischio, aggiornamento
quinquennale di 6 ore (`:30-44`). Preposto **8 ore nel 2011, 12 oggi**, con
l'aggiornamento passato da quinquennale a biennale — «è la differenza che pesa di più
su tutto l'archivio» (`:49-58`). Dirigente **16 ore nel 2011, 12 oggi**, e già allora
credito formativo permanente (`:60-70`). Datore di lavoro-RSPP a 16, 32 o 48 ore
secondo il rischio, con l'aggiornamento a 6, 10 o 14 — che la tabella di partenza non
diceva (`:71-92`). Attrezzature invariate, con la tabella per allegato (`:100-119`).
Primo soccorso e RLS invariati e già scritti altrove (`:128-144`).

Le tre righe che **non** si leggono sono marcate e non entrano in nessuna tabella
(`:146-204`): **RSPP e ASPP** è `non verificabile`, perché il PDF dell'accordo 128/CSR
del 2016 è una scansione da cui `pdftotext` cava 37 byte e la copia di
Organigramma-sicurezza ne cava altrettanti (`:159-169`); **antincendio ante 4 ottobre
2022** è dedotto, perché il DM 10/03/1998 non è in `fonti/` (`:171-179`); **datore di
lavoro senza compiti di RSPP** è dedotto per assenza, ed è un'affermazione negativa che
per essere provata richiederebbe di leggere per intero cinque accordi di cui due sono
scansioni illeggibili (`:189-204`).

Per il regime nuovo le ore stanno in `AppFormazione/supabase/migrations/0036_requisiti_su_obblighi.sql:134-184`,
31 righe di cui nove con le ore e ciascuna con la sua `fonte text not null` (`0036:104`).
Dove la fonte è un decreto e non l'accordo, le ore erano `null` finché il decreto non è
entrato in `reference/fonti/`, e la vista `griglia_ore_da_leggere`
(`0038_griglia_ruolo_formazione.sql:80`) le elencava. Oggi antincendio (4, 8, 16 con
aggiornamenti 2, 5, 8 — `reference/ore-fuori-dall-asr.md:32-36`), primo soccorso (16 e
12 — `:86-89`), segnaletica (8 e 12 — `:127-131`) e ponteggi (28 più 4 —
`0053_allegato_xxi.sql:26-31`) sono lette. Restano 19 righe senza ore
(`0053_allegato_xxi.sql`, effetto dichiarato: da 20 a 19).

**Automatico**, se e solo se le ore sono scritte sull'attestato. E qui c'è la regola
che chiude ogni tentazione di aggiustare: **l'integrazione a posteriori non esiste**.
FAQ interregionali 2025 n. 22: «è possibile accettare i corsi già erogati solo se
completamente conformi ai contenuti, **non è prevista l'integrazione**»
(`reference/faq-asr-2025.md:136-140`). Un corso da 4 ore dove ne servivano 10 non
diventa conforme con sei ore in più: si rifà. È il principio su cui la migrazione 0044
ha tolto `assolve_obbligo` a cinque titoli di carroponte
(`0044_transitorio_sul_corso_non_sulla_persona.sql:73-81`), compresi i due di
aggiornamento — «lasciarli assolventi vorrebbe dire che l'aggiornamento di un corso non
conforme sana il corso non conforme» (`AppFormazione/docs/04-motore-scadenze.md:1739-1744`).

E la conseguenza che riguarda direttamente questo percorso: **le ore non bastano**. La
Parte VII riconosce il pregresso «i cui contenuti siano conformi», non «la cui durata
sia sufficiente», e la scheda di ingresso di AppFormazione l'ha già recepito — «sugli
attestati già in possesso la domanda non è *quando li avete fatti* ma *con quali
contenuti*» (`docs/04-motore-scadenze.md:1444-1446`). Dire se i contenuti di un corso
del 2017 di un ente sconosciuto siano conformi «è un giudizio, non una lettura di ore,
e non lo fa una migrazione» (`04-motore-scadenze.md:1754-1755`).

### 1.5 Che sia la persona giusta

Il codice fiscale è elemento minimo obbligatorio dal 2025 (`punto 6 lett. b`) e non lo
era nel 2011, dove l'accordo chiedeva «dati anagrafici e profilo professionale». Sul
parco dati reale l'assenza è la norma e non l'eccezione: nell'import storico di
AppFormazione, **235 codici fiscali assenti, 31 formalmente errati, 12 duplicati di cui
5 su aziende diverse** (`AppFormazione/docs/05-import-storico.md`, tabella dei rilievi),
e 394 righe scartate proprio perché senza CF non sono riconciliabili. Nel foglio dei
ruoli sicurezza, «dodici righe su 153 ne sono prive, e dieci sono della stessa azienda»
(`AppOverall/supabase/migrations/0001_fondamenta_e_anagrafe.sql:254-255`).

Lo schema del repo unico ha già deciso come trattarlo: `persona.codice_fiscale` è
`unique` ma **nullable**, con il commento che impone il ripiego e la sua misura — «chi
lo cerca deve prevedere il ripiego cognome+nome dentro il cliente, e **contare quante
righe non ha agganciato**» (`0001:241-255`). Nel campo il ripiego è già implementato e
misurato: delle 235 righe senza CF, «227 hanno un nome univoco e il ripiego le aggancia,
6 restano `riga:N` perché omonime» (`AppSopralluoghi/docs/diario/2026-09-09.md:43-44`).

**Automatico con riserva.** Il ripiego cognome+nome dentro il cliente funziona e ha un
tasso di fallimento noto; l'omonimia è il caso in cui deve fermarsi e chiedere. Il
punto delicato non è tecnico: agganciare un attestato alla persona sbagliata produce
**due** errori, una persona coperta che non lo è e una scoperta che lo era.

---

## 2. Come si decide a quale obbligo assolve

Il titolo stampato non è un codice. Fra il titolo e l'obbligo c'è una catena di quattro
anelli, tutti già costruiti, tutti provati su dati veri, e tutti tarati su un universo
chiuso.

### 2.1 Anello uno: l'alias del titolo

`corso_alias` (`AppSopralluoghi/supabase/migrations/055_adempimento_corso_alias_import.sql:65-75`)
è un dizionario `testo_gestionale → corso_codice`. La chiave logica è il **testo**:
`testo_gestionale text not null unique` (`055:67`); `corso_codice` è una *soft ref* a
`corso_catalogo.codice` senza chiave esterna, e `null` significa «da mappare»
(`055:68`), con un indice parziale apposta per la coda:
`idx_corso_alias_damappare ... where corso_codice is null` (`055:74-75`).

Sopra ci sono cinque colonne di comportamento, tutte booleane e tutte **decise a mano
dall'operatore in fase di mappatura**, come dichiara la migrazione che le istituisce
(`057_corso_alias_ignorato_pregressa.sql:34-35`): `ignorato` (fuori perimetro),
`pregressa` (l'alias copre un requisito ASR con un attestato di vecchio regime),
`is_aggiornamento` (distingue l'aggiornamento dall'iniziale, perché `corso_catalogo`
non ha un codice separato per gli aggiornamenti — `057:20-32`), `parziale`
(`059_formazione_parziale.sql:41`) ed `evidenza_incompleta`
(`060_evidenza_incompleta.sql:37`).

Le righe sono **268**, contate sul seed: `grep -c "^  ('"` su
`AppSopralluoghi/supabase/scripts/ripristina_alias_gestionale.sql` dà 268, e il file lo
dichiara in testa (`:10`, `:22-25`). Di queste **237 mappate e 31 ignorate, 0 da
mappare** (`supabase/scripts/azzera_anagrafiche.sql:48`, verificato in produzione il
30/07/2026 secondo `docs/TODO.md:180-181`). Sette righe sono `parziale`
(`059:6`). Il seed **non sta nelle migrazioni**: `corso_alias` nasce vuota e le righe
vivono negli script, seminate e poi mappate da 76 `update` scritti a mano — «una
migrazione dati che guardasse solo `migrations/` creerebbe la tabella e perderebbe 268
giudizi, senza accorgersene: la tabella ci sarebbe»
(`AppOverall/docs/PROGRAMMA.md:172-181`).

**La normalizzazione è una funzione sola, e la sua parsimonia è deliberata.**
`normalizzaTestoGestionale` fa maiuscolo, collassa gli spazi e taglia i bordi, e basta
(`AppSopralluoghi/src/lib/admin/aliasCorsi.ts:99-100`). Niente `unaccent`, niente
rimozione di punteggiatura, niente rimozione di parole, e il motivo è scritto: il
catalogo ha quasi-duplicati con ore diverse che **non sono errori** — «Integrazione
formazione specifica lavoratori - rischio alto» a 8 ore contro «...lavoratori-rischio
alto» a 4 — e le 268 righe danno 268 chiavi distinte, zero collisioni
(`aliasCorsi.ts:38-42`).

**Dove si rompe.** La ricerca è un `Map.get` su chiave esatta
(`AppSopralluoghi/src/lib/admin/formazioneImport.ts:483-487`), quindi la formulazione
del caso peggiore — «un titolo che non somiglia a nessuno dei 268 alias» — è più
generosa del vero: **non serve che non somigli**. Un titolo che somiglia moltissimo
fallisce identico a uno che non somiglia per niente, perché non esiste nessuna misura
di somiglianza in questo punto del codice. Un apostrofo tipografico invece di uno
dritto, un accento diverso, una parola in più, e la riga cade.

E cade in silenzio. I tre esiti di `formazioneImport.ts:483-487` sono: alias assente →
`senza_alias`; alias con `ignorato` → conteggio «fuori perimetro»; alias senza
`corso_codice` → `senza_codice`. In tutti e tre i casi la riga **viene saltata**:
nessuna `formazione` creata, nessuna riga di quarantena, **nessun record persistito
lato server di «ho visto un titolo che non conosco»**. `senza_alias` e `senza_codice`
sono due `Set` in memoria dentro `EsitoUnita` (`formazioneImport.ts:110-111`, popolati
a `:530-531`): sono un rapporto a video che sparisce chiudendo la pagina.

### 2.2 Anello due: la classificazione per titolo normalizzato

In AppFormazione l'aggancio corso→obbligo passa per la stessa specie di chiave. La
tabella `obblighi` ha chiave testuale — `codice text primary key`
(`0022_classificazione_catalogo.sql:31`) — e `corsi.gruppo_obbligo` la referenzia
(`0022:128-129`). Le 36 assegnazioni sono `update corsi set gruppo_obbligo = ... where
staging.norm(titolo) in (...)` (`0022:141-488`): **titolo normalizzato**, non uuid.

La lezione che questa parte del progetto ha già imparato, e che vale integralmente per
gli attestati di terzi, è che una decisione di catalogo non va scritta in una
migrazione. Le classificazioni delle migrazioni 0021, 0022 e 0023 erano trentasei
`update` che «su un database vuoto non toccano niente»: sulla base esistente
funzionavano, su una ricostruzione i corsi nascevano dopo e arrivavano tutti senza
`gruppo_obbligo`, e «il motore, che senza quella colonna non sa a quali corsi si
applichi una regola, restituiva zero righe e non se ne lamentava»
(`AppFormazione/docs/04-motore-scadenze.md:846-851`). La 0025 ha spostato le 179
decisioni in `staging.classificazione_corsi`, con chiave `titolo_norm text` primary key
(`0025_classificazione_applicata_dall_import.sql:24-29`), riapplicata a ogni import da
`promuovi.sql` — così che correggere una riga basti a correggere il catalogo.

Sopra ci sono due proprietà del corso che decidono se quel corso **chiude** un
percorso. `corsi.assolve_obbligo` (`0023_assolvimento_e_code_catalogo.sql:38`): `false`
significa «pezzo di percorso, non fa ripartire la validità» (`0023:40-41`), e la
distinzione «non è deducibile dal titolo» — «INTEGRAZIONE FORMAZIONE PARTICOLARE
AGGIUNTIVA PREPOSTI» ha *integrazione* nel nome ma vale come corso pieno
(`0023:32-37`). E `corsi.validita_mesi`, la periodicità **battuta nel gestionale**,
tenuta separata da `obblighi.periodicita_mesi`, la periodicità **della norma**, «per
confrontarle invece di confonderle» (`0022:24-29`).

**Dove si rompe.** Il corso di un ente sconosciuto non ha una riga in `corsi` e non ha
un titolo in `staging.classificazione_corsi`. Cade nella vista `corsi_da_classificare`
(`0022:516-522`), ordinata per numero di eventi — «il corso da classificare per primo è
quello che pesa di più sullo scadenzario» (`0022:512-515`). Ed è, questa, la coda meglio
progettata del progetto: il `null` di `gruppo_obbligo` vuol dire una cosa sola, perché
`'nessuno'` esiste come valore esplicito per «guardato e deciso» (`0022:131-132`). Ma
è una coda **di catalogo**: risponde a «questo titolo che obbligo assolve», non a
«questa carta vale».

### 2.3 Anello tre: i crediti dell'Allegato III

Un corso può assolvere un obbligo **diverso** da quello per cui è nato. La matrice sta
in `crediti_formativi`, chiave composta testuale `primary key (obbligo_posseduto,
obbligo_creditato)` (`0027_crediti_formativi.sql:41-50`), 39 righe con la citazione su
ognuna, trascritta dalla pagina 130 dell'Allegato all'ASR 2025
(`reference/asr-2025-crediti.md:23-44`, codifica dichiarata a `:88-92`).

Il valore ha cinque gradi dopo la 0040, e i gradi sono il punto:
`check (credito in ('totale','totale_stessa_azienda','totale_condizionato','parziale','frequenza'))`
(`0040_crediti_parziali_e_coordinatore.sql:38-39`). **Solo `totale` esonera da solo.**
`totale_stessa_azienda` è l'asterisco dell'allegato — «vale per coloro che svolgono il
ruolo indicato nella prima colonna nella medesima azienda»
(`reference/asr-2025-crediti.md:19-21`) — e `totale_condizionato` porta una colonna
`condizione text` col commento che vale come dichiarazione di progetto: «Testo, perché
il motore non la sa valutare: **la valuta una persona**» (`0040:41`, `:45-46`).

Tre cose della matrice non erano ovvie e cambiano il giudizio su un mazzo di attestati
(`reference/asr-2025-crediti.md:46-64`): **il preposto non dà credito per niente**,
tutta la sua riga è FREQUENZA, e chi ha il corso preposti senza la formazione
lavoratori «non è un caso di credito: è un'anomalia»; **il datore di lavoro si porta
dietro la formazione lavoratori**, ed è la casistica più frequente in archivio;
**l'RLS ha credito totale sulla generale ma non sulla specifica**, perché la specifica
dipende dai rischi della mansione.

**Dove si rompe, e non è dove ci si aspetta.** Il credito non si applica a un
attestato: si applica a un **ruolo ricoperto**. Serve sapere che quella persona è RSPP
presso quel cliente, e nel repo unico il ruolo sta sulla `nomina`
(`AppOverall/supabase/migrations/0001:288-309`), che per un cliente nuovo si compila
con la scheda di ingresso e non con gli attestati. Su 3.177 persone attive, 1.212 non
hanno in archivio nessun corso che assolva la formazione specifica; scremando i crediti
restano **1.001 `mancante` e 211 `credito_da_verificare`**
(`AppFormazione/docs/04-motore-scadenze.md:895-900`), e nessuno dei 211 esce dalla lista
da solo, perché «noi sappiamo che quella persona ha fatto il corso da datore di lavoro,
non per quale azienda» (`:902-908`).

E qui c'è un conflitto fra i due repo che il repo unico dovrà sciogliere e che nessuna
scheda registra. AppFormazione tratta l'asterisco come una condizione da verificare;
AppSopralluoghi lo tratta come sempre vero, e lo dichiara nel commento: «`Tstar` =
credito totale ma *stessa azienda* (nell'app le figure di una persona sono tutte nello
stesso cliente → **vale sempre**)»
(`AppSopralluoghi/src/formazione/creditiAllegatoIII.ts:6-7`). Per un cliente nuovo che
porta gli attestati di una vita lavorativa fatta altrove, **l'assunzione di
AppSopralluoghi è falsa per costruzione**: il corso da RSPP che quella persona ha in
tasca è stato fatto per un'altra azienda, ed è esattamente il caso che l'asterisco
esclude.

Il motore del campo ha però una prudenza che l'altro non ha, e va tenuta: una figura
credita solo se **tutti** i suoi requisiti obbligatori risultano già coperti, in un
solo passaggio e senza chiusura transitiva — «per un tool di conformità non deve MAI
nascondere un gap» (`creditiAllegatoIII.ts:14-17`, implementato a `:63-67`). E i corsi
fuori dalla matrice — **tutte le attrezzature, antincendio, primo soccorso, i moduli
RSPP** — non producono nulla: `continue` senza traccia (`:71-72`). Coerente con la
fonte, che sulla colonna «Operatore attrezzature» è FREQUENZA su ogni riga: «nessuna
formazione dà credito per le abilitazioni dell'art. 73»
(`reference/asr-2025-crediti.md:80-86`).

### 2.4 Anello quattro: le equivalenze, e perché non servono qui

`equivalenze_corsi` (`0017_equivalenze_corsi.sql`) esiste ed è **vuota**
(`AppOverall/docs/decisioni/9-grana-e-chiave-del-catalogo.md:99`). La storia di come è
stata riempita e poi svuotata è la lezione metodologica più utile di tutto il progetto
per questo percorso. Le coppie corso→aggiornamento non erano deducibili dai titoli e
sono state ricostruite dalle date: «in 221 casi su 222 la persona aveva già in archivio
un evento che, sommato a k anni, riproduceva **al giorno esatto** la scadenza generata
dal gestionale» (`docs/04-motore-scadenze.md:225-232`). Il titolo serviva solo a
scartare le coincidenze, non a proporre la coppia. Poi si è scoperto che il vero difetto
era uno spazio in coda dentro `staging.norm` (`0020`), e rifacendo tutto da zero le sole
159 coppie del seed davano il 100%: i tre metodi intermedi «curavano un sintomo… il
metodo funzionava; la malattia era altrove» (`:316-336`).

**Dove si rompe.** La deduzione dalle date funziona perché c'era uno scadenzario
esistente da riprodurre. Un cliente nuovo non ne ha nessuno: non c'è nessun secondo
sistema che abbia già calcolato una data da cui dedurre all'indietro. Il metodo più
forte dei tre non è disponibile per questo caso, e va detto invece di sperare che
qualcuno lo riprovi.

---

## 3. Come diventa una scadenza

### 3.1 Quale data fa fede

**La data di fine corso riportata sull'attestato.** La fonte lo dice tre volte con la
stessa frase, per gli ambienti confinati e per le attrezzature — «l'aggiornamento parte
dalla data di fine corso riportata nell'attestato» (FAQ interregionali 2025, nn. 21 e 28,
in `reference/faq-asr-2025.md:124-132`) — e la Parte VII la ripete per il datore di
lavoro (`reference/asr-2025-parte-vii.md:50-51`) e per le tre attrezzature nuove
(`:116-117`).

Nel motore quella data è `eventi_formativi.data_completamento`
(`AppFormazione/supabase/migrations/0001_init.sql:157`), `date not null`, e nella vista
`scadenze` si chiama `ultimo_attestato` (`0024_motore_scadenze.sql:111`). Il motore
**non legge mai** né `attestati.data_emissione` (`0003:17`) né `edizioni.data_fine`.
L'unico posto dove una data di fine corso viene derivata è `chiudi_progetto_formativo()`,
che scrive `max(momenti_formativi.data)` in `data_completamento`
(`0028_progetti_formativi.sql:152-164`), con la citazione della FAQ accanto (`:122-127`).

**Il problema per l'attestato di carta è che le date sono due e il modello ne ha una.**
Sull'attestato ci sono la data di fine corso e la data di rilascio, e il punto 6
dell'ASR 2025 impone «data e luogo» senza dire quale delle due
(`ASR_59_2025_punto6_ATTESTAZIONI.txt:39`) — mentre le FAQ, rango 4 ma leggendo
l'accordo, dicono che è la fine corso. Su un attestato dove ne compaia una sola, quale
sia è **una deduzione**, e va marcata come tale: sbagliarla di un mese sposta una
scadenza di un mese. Né `eventi_formativi` né `AppSopralluoghi.formazione` hanno un
posto dove dirlo: la seconda ha un solo `data_completamento date`
(`AppSopralluoghi/supabase/migrations/015_formazione_organigramma.sql:141`) e nessun
`data_rilascio`, nessun `numero_attestato`, nessun protocollo.

### 3.2 Periodicità della norma contro periodicità del gestionale

`periodicita_mesi = coalesce(obblighi.periodicita_mesi, corsi.validita_mesi)`
(`0024:123`): **la norma batte il gestionale**, e il gestionale copre il silenzio della
norma. La distinzione è la ragione per cui `obblighi` è una tabella
(`0022:24-29`), e ha già prodotto un risultato: il confronto ha fatto emergere il
transitorio dei preposti. Le divergenze vive stanno nella vista
`corsi_periodicita_divergente` (`0022:530-538`, riscritta `0023:156-166`) e sono due,
dopo che i sette parziali sono usciti di scena grazie ad `assolve_obbligo`.

Il `null` di `periodicita_mesi` diceva due cose diverse e la 0024 le ha separate con
`obblighi.metodo_calcolo` (`0024:33-36`), tre valori: `data_piu_periodicita`,
`monte_ore` — gli RSPP, che la norma misura come ore in un quinquennio e i nostri dati
non sanno calcolare — e `non_scade`, la formazione generale, «quattro ore una volta
sola: la parte generale non si aggiorna» (`0022:49`).

### 3.3 Decadenza dei percorsi abilitanti

`obblighi.decadenza_mesi` (`0022:35`): oltre quel termine dall'ultimo attestato «il
percorso va rifatto da capo e non basta l'aggiornamento» (`0022:44-45`). Nel motore
l'esito è `da_rifare` e viene prima di `scaduto` (`0024:165-166`). L'effetto misurato è
«piccolo e netto»: **28 righe** passano da `scaduto` a `da_rifare` — tredici carrelli,
otto datore-RSPP, quattro trattori, tre fra gru mobili, PLE e spazi confinati — e sono
tutte persone già scadute, per cui «un elenco di solleciti che non distingue i due casi
manda quelle 28 persone a un corso che non le rimette in regola»
(`docs/04-motore-scadenze.md:826-834`).

Per un mazzo di attestati vecchi questo è il controllo con la resa più alta e il costo
più basso: dieci anni sono facili da superare, e un attestato del 2013 su un percorso
abilitante è `da_rifare` prima ancora che si guardi se era conforme.

### 3.4 Regimi transitori

`regole_transitorie` (`0021_asr2025_preposti_transitorio.sql:49`) porta `fonte text not
null` — «dove si legge, per chi la rivedrà». La regola aggancia la finestra all'ultimo
attestato «di formazione **o aggiornamento**» e non al corso base, ed è la Parte VII a
imporlo (`reference/asr-2025-parte-vii.md:55-79`). Con l'entrata in vigore al 19 maggio
2025: ultimo attestato anteriore al 19/05/2023 → termine **19/05/2026** (43 persone);
dal 19/05/2023 in poi → aggiornamento biennale, **19/05/2027** (65 persone)
(`docs/04-motore-scadenze.md:1722-1726`). Il giorno di confine sta nello scaglione col
termine più vicino (`reference/asr-2025-parte-vii.md:77-79`).

La correzione più importante per questo percorso è però la **0044**, e la sua frase va
letta due volte: **il transitorio si dice sul corso, non sulla persona**
(`0044:29-30`). Carroponte, ambienti confinati, raccoglifrutta e caricatori avevano
quattro regole con una data fissa che colpiva chiunque fosse formato prima; la Parte
VII dice due cose e non una — i dodici mesi sono per **frequentare la prima volta**, e
chi ha un corso già erogato e **conforme** è riconosciuto con la scadenza che parte
dalla sua data di fine corso (`reference/asr-2025-parte-vii.md:119-133`). Le quattro
righe sono state **disattivate, non cancellate**: «se un giorno qualcuno chiede perché
una persona nel 2026 è stata sollecitata, la riga deve poter rispondere»
(`0044:34-44`). Il termine di prima frequenza ha già il suo posto in
`requisiti.termine_primo_adempimento` (`0041_attrezzature_mancanti_e_ore.sql:79-82`), e
la non conformità di un corso sta in `corsi.assolve_obbligo`.

**Per il cliente nuovo questa è la regola che regge tutto il percorso.** Non esiste una
terza strada fra «conforme, e allora la scadenza è la sua» e «non conforme, e allora si
rifà»: la conformità non si compra integrando le ore mancanti
(`reference/asr-2025-parte-vii.md:130-133`). Il che vuol dire che il giudizio umano del
§1.4 non è un abbellimento: è **l'unico ingresso** al ramo che produce una scadenza
invece di un corso da vendere.

### 3.5 Cicli frazionati e crediti parziali

Un obbligo può essere coperto da più eventi parziali, e la data utile è quella
dell'ultimo modulo. La regola non è ipotizzata: delle 166 chiusure ricostruite per
accumulo, **142 cadono sulla data esatta già registrata dal gestionale, l'85,5%**; le
altre 24 hanno un evento sullo stesso corso a una data diversa, in media 254 giorni di
scarto, fino a 1.223 (`docs/04-motore-scadenze.md:78-85`). I cicli restano in staging
finché le 24 divergenze non sono spiegate (`:97-98`).

La cosa da non ripetere è scritta lì e vale la pena portarla qui: **la durata del ciclo,
di per sé, non vuol dire niente**. La pagina ha sostenuto a lungo il contrario e si
sbagliava, perché trattava la frazione come un corso con una validità propria: «sei ore
fatte due più due più due fra il 2026 e il 2031 sono sei ore fatte entro la scadenza, e
l'obbligo è assolto». `requisiti.finestra_completamento_mesi` «codifica una regola che
la norma non chiede» (`:87-95`). La domanda giusta è se le ore fossero complete alla
scadenza che dovevano rinnovare, e a quella i dati rispondono da soli (`:100-119`).

La 0045 aggiunge la parte che serve al sollecito e servirà alla lettera che si manda a
un cliente nuovo: `cicli_frazionati_aperti`
(`0045_ore_mancanti_dal_ciclo_interrotto.sql:34-51`) porta `ore_fatte`, `ore_previste`,
`ore_mancanti`. **Il ciclo interrotto non sposta la scadenza: la spiega** (`0045:84`). A
dieci persone manca un'ora e «la lettera che partirebbe oggi le convoca per sei»
(`docs/04-motore-scadenze.md:134-135`). La scelta è dichiarata come tale: «se un giorno
una fonte dirà che quelle ore contano, il dato per applicarla è lì; se dirà che non
contano, non è stato promesso niente a nessuno» (`:1764-1766`).

Nel campo lo stesso concetto vive su due colonne, `corso_alias.parziale` e
`formazione.parziale` (`059:41-42`), e il motore lo legge davvero: uno spezzone è
escluso dalla gara che sceglie l'attestato buono
(`AppSopralluoghi/src/lib/admin/formazione.ts:592`) e sommato per ore in
`componiSpezzoni` (`:635-643`).

**Il credito parziale è un'altra cosa e oggi non è codificato.** Le matrici delle
pagine 127-129 dell'Allegato III quantificano il credito in ore — «RSPP con Modulo A —
PARZIALE. Credito: Modulo giuridico 28 ore. Necessaria frequenza: Modulo tecnico 52
ore…» — e non sono state trascritte: riguardano percorsi con 25 eventi in tutto e «il
credito parziale ha bisogno di un modello a ore che oggi il motore non ha»
(`reference/asr-2025-crediti.md:66-78`). Le due tabelle di pagina 113 e 114 della Parte
VII, che sono proprio quelle del riconoscimento del pregresso per DL-RSPP e per RSPP e
ASPP, «non sono ancora trascritte cella per cella: vanno lette a video»
(`reference/asr-2025-parte-vii.md:156-157`). **Sono le due tabelle che servirebbero di
più a questo percorso, e sono quelle che mancano.**

### 3.6 Il corso fatto sotto un accordo poi abrogato

L'ASR 2025 abroga cinque accordi (`reference/asr-2025-parte-vii.md:159-170`): 221/CSR e
223/CSR del 2011, 53/CSR del 2012, 153/CSR del 2012, 128/CSR del 2016. Restano nel
discorso «perché sotto di loro è stata erogata la formazione che oggi è in archivio, ma
non sono la norma vigente» (`:171-173`) — ed è la correzione che la 0042 ha portato in
`obblighi.norma`.

Un attestato del 2017 è stato emesso sotto accordi che oggi non esistono più. Per
giudicarlo servono le ore di allora, e sono in `quadro-storico-ore-pregresse.md`; per
sapere se vale oggi servono la Parte VII e la matrice dei crediti — la separazione è
dichiarata nella prima pagina di quel file (`:9-12`). Il caso peggiore è quello in cui
le due cose si incrociano male: RSPP e ASPP, dove il quadro storico è `non
verificabile` perché il PDF del 128/CSR è una scansione (`:159-169`), **e** dove la
tabella di pagina 114 che dice quanto credito valga oggi non è trascritta. Su quella
figura, oggi, non si può né dire se l'attestato fosse regolare né quanto crediti.

### 3.7 Quale data fa fede, in una riga

**La data di fine corso scritta sull'attestato**, perché lo dicono tre FAQ che leggono
l'accordo e perché è la sola che il motore usa. Se sull'attestato c'è solo la data di
rilascio, quella che entra è una **deduzione** e va marcata: il modello di oggi non ha
dove marcarla, ed è uno dei tre attributi del §5 che non si aggiungono dopo.

---

## 4. Le decisioni che una macchina non può prendere, e dove vanno messe in coda

### 4.1 Quali sono

Sette, e le ho ordinate per quanto pesano.

**La conformità dei contenuti.** «Dire se quei contenuti siano conformi è un giudizio,
non una lettura di ore, e non lo fa una migrazione»
(`docs/04-motore-scadenze.md:1754-1755`). È il cancello che decide fra «scadenza sua» e
«corso da rifare» (§3.4), e non c'è FAQ che lo automatizzi.

**L'identità della persona,** quando manca il codice fiscale e il ripiego cognome+nome
incontra un'omonimia.

**L'identità del corso,** quando il titolo non è nel dizionario: cioè sempre, per un
ente nuovo (§2.1).

**La condizione dell'asterisco,** e la sua parente `crediti_formativi.condizione`, il
cui commento dichiara già che «la valuta una persona» (`0040:45-46`).

**Quale data sia la data di fine corso,** quando sull'attestato ce n'è una sola.

**Se l'ente fosse un soggetto formatore,** e su questa non c'è nemmeno il criterio
(§1.2): oggi la decisione è umana perché non esiste il testo contro cui automatizzarla,
non perché richieda giudizio.

**Se l'evidenza sia completa,** cioè se quella carta documenti tutto il percorso o solo
un pezzo — il caso dell'aula di un corso iniziato in e-learning
(`060_evidenza_incompleta.sql:5-13`).

### 4.2 I modelli di coda che esistono

**La quarantena della coda offline** — `AppSopralluoghi/src/lib/db.ts:187-189`, schema
Dexie v7, quindi **IndexedDB nel browser del tecnico, non Postgres**. La riga è
`OpBloccata` (`db.ts:47-53`): l'operazione originale integrale, un `motivo` leggibile,
un `codice` SQLSTATE o HTTP, un timestamp. Ci si entra da un solo punto
(`src/lib/sync.ts:499`), dopo una diagnosi che separa il ritentabile dal definitivo —
SQLSTATE nelle classi 08, 40, 53, 57, 58 e `PGRST301` sono ritentabili, il resto è
definitivo (`sync.ts:401-427`) — e l'ingresso è atomico: `add` in quarantena e `delete`
dalla coda (`db.ts:197-200`). **Non ha stato**: l'appartenenza alla tabella *è* lo
stato. **Non ha revisore.** E soprattutto **non ha uscita**: l'unica lettura è un
contatore (`sync.ts:513-515`) mostrato come pillola «· N bloccate» con il title
«Segnalale all'ufficio» (`src/Compilazione.tsx:437-439`). Il TODO lo dice senza giri:
«Resta: la schermata che elenca la quarantena e permette di ritentare o scartare»
(`AppSopralluoghi/docs/TODO.md:128-129`), e lo STATO la segna aperta
(`docs/STATO.md:23`).

**Il `credito_da_verificare`** — è in AppFormazione, ed è di specie opposta: **non è
una coda, è una stringa calcolata**. Compare in un `case` dentro sei viste
(`0027:170`, `0036:267`, `0038:134`, `0040:132`, `0051:202`, `0052:618`). Non ha riga,
non ha id, non ha destinatario, non si può marcare come risolta, e ricompare identica
alla query successiva. La 0051 le ha ristretto il significato a uno solo — «di quel
cliente non sappiamo i ruoli» (`0051_l_asterisco_diventa_un_join.sql:216`) — e la
motivazione dice perché il problema non era il nome: «è onesto, ma è anche una lista
che nessuno finirà mai: la condizione non è esprimibile» (`0051:7-9`). La cura non è
stata una coda: è stata una **colonna**, `ruoli_persona.cliente_id not null`
(`0051:36`), che trasforma la condizione in una join e la spegne da sé quando il ruolo
cessa. Ed è arrivata prima e non dopo, con la ragione scritta: «se la colonna c'è, ogni
ruolo arriva già attaccato alla sua azienda… se non c'è, i ruoli si raccolgono senza il
cliente e allora quelle 212 verifiche restano a mano per sempre» (`0051:23-27`).

Ne ho trovati altri tre, e insieme dicono una cosa sola.
`corsi_da_classificare` (`0022:516-522`) è una coda **derivata**: nessuno la popola, si
svuota quando qualcuno scrive la decisione, ed è ordinata per peso.
`werp_da_rivedere` e `werp_da_chiarire`
(`AppSopralluoghi/supabase/migrations/044_werp_da_rivedere_da_chiarire.sql:16-38`) sono
due tabelle Postgres dedicate, senza colonna di stato, con due `upsert` in scrittura
(`src/lib/admin/werpImport.ts:492`, `:500`) e **nessuna lettura, nessuna interfaccia**.
`formazione.da_confermare` (`054_sede_prima_classe_fase1.sql:58`) è un booleano anonimo,
senza autore e senza data.

**E il fatto che li accomuna tutti e cinque: in nessuno è scritto chi ha risolto e
quando.** Verificato con una ricerca su tutte le migrazioni di AppSopralluoghi per
`verificato|revisionato_da|approvato_da|risolto_da|chiuso_da`: gli unici campi «chi»
del repo sono `sopralluogo.tecnico_id`, `revisione.autore_tecnico_id`,
`organigramma_conferma.tecnico_id` e `organigramma_revisione.autore_tecnico_id` — tutti
sul ramo sopralluogo, **nessuno sul ramo formazione**. In AppFormazione esiste
`esoneri.operatore` e `esoneri.revocato_da`, ma sono `text`
(`0030_esoneri.sql:36`, `:39`), non una chiave verso un operatore.

### 4.3 Serve una terza coda?

**No per la forma, sì per il posto.** E la risposta si articola in tre pezzi, perché le
decisioni del §4.1 non sono tutte della stessa specie.

**Quelle che riguardano il catalogo riusano `corsi_da_classificare`.** «Questo titolo
che obbligo assolve» è la stessa domanda che quella vista fa già, e la risposta è
riusabile per sempre: mappato una volta, ogni import successivo lo risolve da solo, «il
lavoro è decrescente» (`AppSopralluoghi/src/lib/admin/aliasCorsi.ts:8-12`). Rifarla
altrove significherebbe avere due posti dove si decide che cosa sia un corso, che è
esattamente il difetto da cui il repo unico è nato.

**Quelle che riguardano la persona non vogliono una coda: vogliono una colonna.** È la
lezione della 0051, ed è la più importante di tutto questo paragrafo. La condizione
dell'asterisco non è diventata risolvibile perché qualcuno ha fatto una lista: è
diventata risolvibile perché il ruolo ha smesso di essere senza azienda. Prima di
aprire una coda va sempre chiesto se la domanda sia irrisolvibile o solo mal posta.

**Quella che riguarda la carta vuole una coda, e non ce n'è nessuna che le vada
bene** — perché tutte e cinque quelle esistenti condividono lo stesso difetto strutturale:
sono liste di **cose da guardare**, e questa deve produrre un **atto da conservare**.
La differenza è quella fra «qualcuno controlli questo attestato» e «Tizio, il 12 marzo,
ha controllato questo attestato e lo ha accettato con riserva perché le ore non erano
scritte». La prima si svuota; la seconda no, e non deve. Un attestato che oggi ho
accettato con riserva è una posizione che fra due anni, davanti a un ispettore, va
difesa dicendo chi l'ha presa e su quali elementi.

Quindi: **il posto giusto non è una coda ma la riga stessa dell'evidenza**, con la coda
che ne discende come vista — cioè la forma di `corsi_da_classificare`, applicata a un
oggetto che nessuna delle cinque code tocca. La forma da copiare non è nessuna delle
cinque: è `valutazione_sede` della 0001
(`AppOverall/supabase/migrations/0001_fondamenta_e_anagrafe.sql:209-235`), che ha
`motivazione text not null` — «una valutazione senza motivo è un'opinione, e non si
verifica» (`:216`) —, `deciso_il`, `deciso_da uuid not null references operatore(id)`,
e `revocato_il` con un indice unico parziale che tiene una riga viva per attributo
(`:229-230`). È già stata scelta due volte: la scheda 8 l'ha decisa per lo scostamento
dal rischio ATECO, e la 0001 dichiara di averla presa da `risposte_azienda` di
AppFormazione (`0001:204-207`).

E l'accettazione con riserva ha già un precedente esatto nel campo, che va riusato e
non reinventato: `evidenza_incompleta`
(`AppSopralluoghi/supabase/migrations/060_evidenza_incompleta.sql:37-38`). È un flag che
**non tocca la valutazione di conformità** e apre una **pendenza documentale**
(`060:20-25`): «Il requisito resta assolto; la parte mancante va recuperata e
registrata» (`060:44-45`). Genera voci in «Cose da fare»
(`src/lib/admin/formazione.ts:1945-1958`), si vede sul libretto
(`src/formazione/Libretto.tsx:154-164`), e si chiude con `registraParteMancante`, che
crea la riga nuova e spegne il flag sulla vecchia
(`src/lib/admin/libretto.ts:236-271`). È la cosa più vicina che il progetto abbia a
«accettato con riserva» — e ha un difetto che va corretto passando al repo unico: **il
giudizio vive sull'alias, non sull'evidenza.** Si marca una volta sul dizionario e
l'import lo copia sull'attestato (`060:27-31`). Per l'attestato di un cliente nuovo non
c'è nessun alias su cui appoggiare il giudizio, e il giudizio riguarda **quella carta**,
non tutti i corsi che portano quel titolo. Nel repo unico la riserva nasce sulla riga
dell'evidenza; se poi vale per una classe intera di titoli, quella è una seconda cosa e
va detta a parte.

---

## 5. Cosa serve allo schema del repo unico

Nessun SQL: la scheda 9 è aperta e decide la forma delle tabelle formative. Qui c'è la
forma e il perché.

Va detto prima di tutto in che stato si arriva. Lo schema del repo unico ha oggi tre
migrazioni — fondamenta e anagrafe, vocabolario dei ruoli, viste che non scavalcano le
RLS — e **la parte formativa non esiste**. Dei sei pilastri che «non si aggiungono
dopo» (`AppOverall/docs/PROGRAMMA.md:34-58`), la 0001 ne dichiara quattro: 06
concorrenza ottimistica, 03 vocabolario dei ruoli, 02 RLS, 01 viste. Il **pilastro 4,
provenienza su ogni riga formativa, non è dichiarato in nessuna migrazione**, ed è
ovvio: non c'è ancora una riga formativa. Questo documento è il posto in cui quel
pilastro prende forma, ed è per questo che va scritto prima della prima migrazione
formativa e non dopo.

### 5.1 Le entità

**L'evidenza è un'entità propria, e non è l'evento formativo.** Oggi i due sono la
stessa cosa in tutti e tre i repo, e per gli attestati che Overall emette va bene: c'è
un'edizione, c'è un'iscrizione, l'attestato è l'ultimo atto. Per un attestato di terzi
il rapporto si rovescia — **la carta viene prima e il fatto lo si deduce da lei**. Sono
due cicli di vita diversi: una carta può essere respinta e restare agli atti, può
essere sostituita da una copia migliore, può documentare un fatto che si decide di non
riconoscere. Un evento formativo respinto non ha senso.

**Il fatto formativo** resta quello che è già: persona, corso, data di fine, ore, esito.
La forma di `eventi_formativi` (`AppFormazione/0001_init.sql:152-167`) regge, con due
correzioni. La prima: `iscrizione_id` è nullable ed è così che un evento esterno esiste
senza edizione (`:156`) — va tenuto, ma il fatto che sia esterno non si deve dedurre da
un `null`. La seconda, che è un difetto vero: **non c'è nessun vincolo di unicità**, e
lo stesso attestato caricato due volte entra due volte; l'anti-duplicato vive solo in
staging (`0008_staging_impronta_unica.sql:13-14`), cioè solo per la strada dell'import
dal gestionale. Un attestato consegnato a mano non passa da lì.

**L'ente formatore va nominato, non descritto.** Oggi è testo libero in tutti e due i
repo: `eventi_formativi.ente_erogatore text` (`0001_init.sql:160`),
`attestati.ente_emittente text` con `-- null = Overall` (`0003:16`),
`formazione.ente_formatore text` (`AppSopralluoghi/015:143`) — quest'ultimo mai
valorizzato dall'import, che lo lascia sempre `null`
(`src/lib/admin/formazioneImport.ts:634`). Con un cliente nuovo gli enti diventano
molti e ricorrenti, e il giudizio su un ente — se sia un soggetto formatore, quando lo
si è verificato — è un giudizio che si dà una volta e si riusa. Se resta una stringa,
si riscrive a ogni attestato e diverge alla terza grafia dello stesso nome. Non ho una
fonte su disco che dica quali enti siano abilitati (§1.2): l'entità serve **anche** a
tenere il posto dove quella risposta andrà.

**Le tre code non sono entità.** Sono viste sulle righe che portano il giudizio, per la
ragione già scritta nella 0022: «la vista lo rende una domanda a cui si risponde invece
di una colonna da ispezionare» (`0022:513-515`).

### 5.2 Gli attributi che non si possono aggiungere dopo

Sono quattro, e il criterio per cui stanno in questa lista è uno solo: **si possono
scrivere solo mentre il fatto accade.** Aggiungerli dopo non significa fare una
migrazione con un `default`: significa avere N righe per cui il valore è
irrecuperabile, e nessun modo di distinguerle da quelle per cui il valore è
genuinamente vuoto. È lo stesso argomento con cui la 0001 ha scritto le RLS dal primo
giorno invece di aggiungerle poi (`0003_le_viste_non_scavalcano_le_rls.sql:31-36`).

**Uno. La provenienza dell'evidenza.** Il cronoprogramma la vuole «a tre valori:
Sicurweb, ASSIDAL, kit» (`PROGRAMMA.md:55`), confermati dalla decisione 4
(`4-kitformasubito.md:64-66`), e il criterio di uscita della Fase 3 dice «ogni riga
formativa sa da dove viene» (`PROGRAMMA.md:141`). **Nessuno dei tre valori è questo
caso.** Storico Sicurweb, ASSIDAL e kit sono tre modi in cui un attestato nasce
*dentro* l'ecosistema; l'attestato che un cliente nuovo porta in mano nasce fuori, da
un ente che non conosciamo, ed è la quarta provenienza. Va aggiunta ora, perché una
colonna a tre valori con un `check` si allarga con una migrazione ma le righe già
scritte sotto il vincolo vecchio non si riclassificano: chi è entrato come «storico»
perché era l'unico valore plausibile resta «storico» per sempre. E la provenienza non è
la stessa cosa dell'ente: dice **per quale strada** quella carta è arrivata a noi, che
è ciò che permette di sapere quanto fidarsi. Il precedente è
`ruolo_sicurezza_alias.sistema` con il suo `check` (`0002:205-206`), dove l'elenco è
dichiarato completo e «un codice fuori elenco è un dato nuovo, non un refuso da
normalizzare» (`0002:188-190`).

**Due. Chi ha controllato e quando.** Non esiste in nessuno dei tre repo, su nessuna
tabella del ramo formazione (§4.2). La forma è quella di `valutazione_sede`: `deciso_il
date not null` e `deciso_da uuid not null references operatore(id)`
(`0001:219-220`), non una stringa — la 0001 lo dice come differenza voluta rispetto
alla fonte da cui ha copiato: «`deciso_da` punta a un operatore invece di essere una
stringa» (`0001:206-207`). Perché non si aggiunge dopo: perché la data di un controllo
è la data in cui è avvenuto, e un `default current_date` messo in migrazione scriverebbe
su mille righe la data della migrazione. Sarebbe un dato falso che sembra vero — la
stessa forma di difetto per cui il vocabolario dei ruoli è stato rifatto: «lo stesso
errore si riscrive alla prima migrazione e stavolta con la provenienza che lo fa sembrare
verificato» (`0002:29`).

**Tre. Il file scansionato, come oggetto e non come stringa.** Oggi è
`attestati.file_path text -- oggetto su storage` (`0003:19`) e
`formazione.allegato_url text` (`015:148`): un path, senza bucket dichiarato, senza
mime, senza dimensione, **senza impronta**. Il campo ha già una pipeline offline-first
solida in AppSopralluoghi — blob in Dexie, operazione `kind:'attestato'` in coda, upload
nel drenaggio (`src/lib/sync.ts:172-191`, `:446-453`) — e una scelta esplicita che va
tenuta: l'originale non si ridimensiona, «un attestato è un documento legale»
(`sync.ts:170-171`). Quello che manca è l'impronta, e non si aggiunge dopo per una
ragione aritmetica: si calcola sul file al momento in cui arriva, e ricalcolarla su
migliaia di oggetti già in storage è un lavoro che nessuno farà. Serve a due cose che
questo percorso ha entrambe: riconoscere lo stesso attestato consegnato due volte — che
succede, perché un mazzo di carte non è un export idempotente — e provare che il file
di oggi è quello su cui il controllo fu fatto.

**Quattro. Che una riga sia stata accettata con riserva, e quale riserva.** Il
precedente è `evidenza_incompleta` (`060:37-45`), e la sua virtù è la separazione: non
tocca la conformità, apre una pendenza. Va portato con due correzioni. La riserva sta
sull'**evidenza** e non sul dizionario (§4.3). E non è un booleano: le riserve del §4.1
sono di specie diverse — ore non scritte, ente ignoto, data dedotta, contenuti non
verificabili — e trattarle come un flag solo significa non poter dire, fra due anni,
che cosa esattamente si fosse deciso di lasciare aperto. Un flag anonimo lo abbiamo già
e non funziona: `formazione.da_confermare` (`054:58`), senza autore, senza data e senza
motivo. La forma giusta è quella di `crediti_formativi.condizione`: testo, «perché il
motore non la sa valutare: la valuta una persona» (`0040:45-46`), accanto a un valore
che dica di quale specie sia la riserva.

Ce n'è un quinto che non è un attributo ma va detto qui, perché è della stessa specie:
**il valore e la sua provenienza si marcano separatamente**. Lo impone la decisione 5,
sulle tre divisioni ATECO: «il valore è `alto`, ma la sua provenienza non è l'accordo
vigente… le due cose si marcano **separatamente**» e «non è un default silenzioso: una
sede deve poter mostrare da dove viene la sua classe. Se il giorno di un'ispezione la
risposta è *l'ha messo il programma*, la decisione non ha retto»
(`5-divisioni-non-classificate.md:181-195`). Applicato qui: la data di scadenza di un
attestato del 2017 e il fatto che quella data poggi su una data di fine corso dedotta
dalla data di rilascio sono due dati, non uno.

### 5.3 Due cose che non sono attributi e vanno sistemate lo stesso

**Le RLS.** In AppFormazione un operatore `formazione` o `amministrazione` può inserire
`eventi_formativi` e `attestati`, che stanno fra le tabelle `proprie`
(`0010_operatori_e_policy.sql:66-70`), ma **non può inserire `persone`, `clienti`,
`sedi`, `rapporti_lavoro`, `ruoli_persona`**, che stanno fra le `replicate` e hanno la
sola policy di lettura (`0010:72-74`, `:89-92`). Per un cliente nuovo che consegna
attestati di persone che il sistema non ha, **la persona non è creabile
dall'applicazione**: serve il service role. La divisione ha senso finché l'anagrafe
arriva da un import; smette di averlo il giorno in cui il primo dato di un cliente
nuovo entra da una carta.

**La numerazione.** `attestati.numero text not null` (`0003:15`) e l'unicità
`(anno, progressivo)` (`0003:31-32`) sono la numerazione interna di Overall. Un
attestato di terzi ha un suo numero, che non è nostro e non è unico nel nostro
spazio. La migrazione dati che ha popolato quella tabella lo dice: dove il numero
mancava ha scritto la costante `'da_assegnare'` (`0003:74`). Un numero che è un dato
del documento e un numero che è una nostra chiave non sono la stessa colonna.

---

## 6. Cosa è in tensione con la scheda 9

La scheda 9 pone due domande: **grana** — si tiene il corso o l'obbligo — e **chiave** —
testuale curata o uuid (`9-grana-e-chiave-del-catalogo.md:9-24`). Vale la pena separare
gli effetti, perché una delle due tocca questo percorso e l'altra quasi no. È la buona
notizia che il compito chiedeva di scrivere se ci fosse, e c'è, ma solo per metà.

### 6.1 La chiave: il percorso funziona uguale, e questo va scritto

**Su chiave testuale contro uuid il percorso è indifferente.** Il motore delle scadenze
è già oggi un ibrido: `obblighi.codice` è testuale (`0022:31`), `corsi.id` è un uuid, e
la vista `scadenze` li usa entrambi senza che la cosa cambi un esito (`0024:81-172`).
Il campo è tutto testuale — `corso_catalogo.codice text not null unique`
(`015_formazione_organigramma.sql:47`) — e produce lo stesso risultato. Nessuno dei
controlli del §1, nessuno degli anelli del §2, nessuna delle regole del §3 dipende da
come è fatta la chiave primaria di un corso.

Anzi, la raccomandazione della scheda 9 **aiuta** questo percorso, e per una ragione che
la scheda non nomina. La proposta è che l'impronta `GEST-` + md5 del titolo normalizzato
smetta di essere un'identità e diventi la chiave di un **alias**, «esattamente come i 268
alias del campo», così che cambiare la normalizzazione non tocchi più nessuna identità:
«il problema non si risolve meglio, **smette di esistere**» (`9:78-84`). L'argomento è
stato costruito sui 41 corsi su 163 che hanno cambiato codice quando la 0020 ha corretto
un `btrim` (`9:44-47`). Ma la stessa forma serve qui: **il titolo stampato su un
attestato di terzi è per natura un alias e non un'identità.** Se il repo unico nasce con
un dizionario di alias di prima classe, l'attestato del cliente nuovo ha già dove
atterrare; se il titolo resta legato a un'identità di catalogo, ogni titolo nuovo deve
diventare un corso, e il catalogo si riempie di righe che non sono corsi ma modi di
scrivere.

C'è un punto solo di attrito, ed è piccolo: la scheda dà per acquisito che i codici
curati siano stabili e cita il commento che li istituisce come «chiave stabile»
(`015_formazione_organigramma.sql:47` — la scheda 9 lo cita come `:52`, e a quella riga
il commento non c'è; `9:29-32`), notando che in 63 migrazioni non
c'è un solo `update corso_catalogo set codice` e che persino la deprecazione conserva il
codice «perché gli attestati storici lo referenziano» (`9:33-35`). Quella stabilità è
stata pagata tenendo l'universo chiuso — i 40 codici sono «una curatela, non un import
meccanico» (`src/lib/admin/catalogoImport.ts:11-15`). Gli attestati dei clienti nuovi
sono un flusso di titoli che il curatore non controlla. Il modello regge — un titolo
nuovo diventa un alias, non un codice — purché sia detto **da subito** che i codici si
coniano a mano e gli alias no.

### 6.2 La grana: qui la scelta cambia il percorso, e la direzione giusta è già quella

Sulla grana la scheda raccomanda l'**obbligo**, ed è già ratifica più che decisione: è
dove il motore ragiona dalla 0024, e la 0036 ha fatto `drop table requisiti` con la
motivazione scritta — «la sua forma legava una regola a un titolo di catalogo»
(`0036:91-94`, citato in `9:49-54`).

Per gli attestati di terzi l'obbligo è la grana giusta per tre ragioni che questo
documento ha già incontrato. **La prima è la matrice dei crediti**: l'Allegato III mette
in relazione obblighi, non corsi, e `crediti_formativi` ha per chiave una coppia di
codici di obbligo (`0027:47`). A grana-corso quella matrice andrebbe espansa sul
prodotto cartesiano dei titoli, e su un universo aperto di titoli il prodotto non è
calcolabile. **La seconda è che l'obbligo è la cosa che non cambia**: un attestato del
2017 nomina un corso di un catalogo che non esiste più, ma l'obbligo che assolveva è lo
stesso. **La terza è che a grana-obbligo un'intera classe di ambiguità sparisce**: le
279 attribuzioni ambigue fra generale e specifica, che si erogano lo stesso giorno, «a
questa grana non esistono più» (`0024:16-22`).

Ma la grana-obbligo lascia un residuo che il percorso deve gestire e che oggi nessuna
scheda nomina. **La conformità di un percorso è una proprietà del corso, non
dell'obbligo** — è la frase della 0044 (`:29-30`), ed è il perno del §3.4. Se il repo
unico tiene solo l'obbligo e degrada il corso a «catalogo di erogazione»
(`9:66-69`), va garantito che quel catalogo resti **il posto dove si dice che un corso
non è conforme**: è lì che vivono `assolve_obbligo` e la decisione presa sui cinque
titoli di carroponte. E per un attestato di un ente sconosciuto il giudizio non riguarda
un titolo di catalogo ma **quella carta**: serve che la stessa cosa si possa dire a due
livelli, sul corso quando vale per tutti e sull'evidenza quando vale per una sola. È il
medesimo difetto di `evidenza_incompleta` visto dall'altro lato (§4.3), e la scheda 9
oggi non dice dove vada il secondo livello.

Un ultimo punto di tensione, che vale come avvertimento. La scheda prevede che le
13.215 righe di `eventi_formativi` e le `edizioni` si risolvano «una volta sola in
migrazione, per alias», e che «la risoluzione va **verificata prima di scrivere**, non
dopo» (`9:100-102`). Se in quella stessa migrazione entrasse anche il primo mazzo di
attestati di un cliente nuovo, entrerebbe **senza chi ha controllato e senza quando** —
perché nessuno lo ha controllato: è una migrazione. Il percorso di questo documento e la
migrazione della scheda 9 sono due strade diverse verso la stessa tabella, e la seconda
non deve poter scrivere le colonne della prima.

---

## 7. Il caso peggiore, per intero

Un attestato del 2017, ente mai visto, senza il codice fiscale del partecipante, ore
non scritte, titolo che non corrisponde a nessuno dei 268 alias. Ecco cosa succede oggi,
passo per passo, e dove si ferma.

**Passo 1 — la carta arriva.** Non c'è nessun punto di ingresso. La scheda di ingresso
di AppFormazione chiede al cliente l'elenco dei dipendenti e gli attestati già in
possesso — sono due delle 34 domande di `scheda_ingresso`
(`0039_scheda_ingresso.sql`, descritta in `docs/04-motore-scadenze.md:1430-1436`) — ma
chiedere non è ricevere: non esiste una schermata che accetti un mazzo di PDF. Nel campo
si può caricare un allegato su una riga di `formazione` che esiste già
(`src/lib/sync.ts:172-191`), cioè si può attaccare la carta a un fatto già registrato,
non registrare un fatto partendo dalla carta. **Primo punto di arresto, ed è il più
banale e il più bloccante: la porta non c'è.**

**Passo 2 — la persona.** Senza codice fiscale l'aggancio passa dal ripiego cognome+nome
dentro il cliente, che nel campo è implementato e ha una resa misurata: 227 righe su 235
agganciate, 6 restano irrisolte per omonimia
(`AppSopralluoghi/docs/diario/2026-09-09.md:43-44`). Nel repo unico
`persona.codice_fiscale` è nullable apposta e il commento impone di **contare** quante
righe il ripiego non aggancia (`0001:254-255`). In AppFormazione il ripiego non c'è
affatto: le 394 righe senza CF sono state scartate con motivo in `staging.scarti`
(`docs/05-import-storico.md`). Diciamo che l'aggancio riesce. **Non si ferma qui, ma una
riserva è già aperta**, e oggi non ha dove essere scritta.

**Passo 3 — il regime.** L'attestato è del 2017: precede il 19 maggio 2025, quindi si
giudica sotto gli accordi del 2011, 2012 o 2016. Automatico, purché una data ci sia. Le
ore di riferimento stanno in `quadro-storico-ore-pregresse.md`, con l'avvertenza che tre
righe su nove non sono leggibili (`:146-204`).

**Passo 4 — chi l'ha emesso.** Ente mai visto. Non c'è niente contro cui confrontarlo:
la definizione di soggetto formatore non è trascritta in `reference/` (§1.2) e il DM
6/3/2013 sui requisiti dei formatori non è in `fonti/` ed è marcato non citabile
(`DI_06_03_2013_REQUISITI_FORMATORI.txt:12-21`). **Il controllo non si fa, e il sistema
non ha dove dire che non si è fatto.** Nel modello di oggi l'ente finirebbe in
`eventi_formativi.ente_erogatore text` (`0001_init.sql:160`) o
`formazione.ente_formatore text` (`015:143`), stringa libera, indistinguibile da un ente
verificato.

**Passo 5 — il titolo.** Il codice fa `byAlias.get(r.corso_norm)` su chiave esatta
(`formazioneImport.ts:483`). Non esiste alcuna misura di somiglianza in questo punto,
quindi la premessa «non somiglia a nessuno dei 268» è più forte del necessario: **anche
un titolo quasi identico fallirebbe**. La riga finisce in `EsitoUnita.senza_alias`
(`formazioneImport.ts:110`, `:530`), che è un `Set` in memoria: **la riga viene saltata,
nessuna `formazione` viene creata, e chiudendo la pagina non resta traccia lato server
che quel titolo sia mai stato visto.** In AppFormazione la strada parallela porterebbe
il corso in `corsi` senza `gruppo_obbligo`, e da lì in `corsi_da_classificare`
(`0022:516`) — che è meglio, perché la domanda almeno sopravvive, ma è la strada
dell'import dal gestionale e questo attestato non passa di lì.

**Secondo punto di arresto, ed è quello dove il sistema perde informazione invece di
fermarsi.** Un arresto che dice «non so» è un arresto buono; questo dice `continue`.

**Passo 6 — le ore.** Non sono scritte sull'attestato. Il §1.4 chiede di confrontarle
con il minimo del regime del 2017, e senza il numero il confronto non si fa. Non è un
dettaglio recuperabile: le FAQ n. 22 escludono l'integrazione a posteriori
(`faq-asr-2025.md:136-140`), quindi la domanda «erano abbastanza?» decide fra
riconoscere e far rifare, e non ha risposta. Va notato che nemmeno il dizionario
aiuterebbe: le ore lette dall'export del gestionale **non si salvano** in `corso_alias`,
«come le ore, serve a decidere ed è sempre a un upload di distanza»
(`src/lib/admin/aliasCorsi.ts:32-34`).

**Passo 7 — la conformità dei contenuti.** Anche avendo le ore non basterebbero: la
Parte VII riconosce il pregresso «i cui contenuti siano conformi», e la scheda di
ingresso ha già recepito che la domanda giusta non è quando ma con quali contenuti
(`04-motore-scadenze.md:1444-1446`). Nessuna automazione: è un giudizio
(`:1754-1755`). **Terzo punto di arresto, e questo è legittimo**: è una decisione umana
che ha bisogno di una coda, e la coda non c'è.

**Passo 8 — la scadenza.** Il motore riceve la coppia persona×obbligo solo se esiste un
evento con un `corso_id` che abbia `gruppo_obbligo` (`0024:82-96`). Non essendoci né il
corso né l'evento, **non c'è nemmeno una riga**: la persona non compare come `mancante`,
perché `scadenze` include solo le coppie di cui esista almeno un evento, ed è una scelta
dichiarata (`0024:71-76`). Il cliente nuovo resta invisibile allo scadenzario, e il
documento lo dice già: «su un cliente nuovo, che con noi non ha fatto niente,
`scadenze` restituisce zero righe. Non è un difetto ma il limite dichiarato: la domanda
che serve lì è l'altra, *cosa ti serve*, ed è guidata dal ruolo»
(`04-motore-scadenze.md:1221-1226`).

**Dove si ferma, in una riga.** Si ferma al passo 1, perché la porta non esiste. Se la
porta esistesse si fermerebbe al passo 5, **e si fermerebbe male**, perdendo la riga
invece di metterla in coda. Superato anche quello con un intervento manuale, si
fermerebbe al passo 7, e lì si fermerebbe bene: quella è una decisione umana, e il
compito del sistema è metterla davanti a un umano con accanto tutto ciò che serve a
prenderla — l'ente, le ore, il regime, il PDF, e la nota di chi ha già guardato.

**Un'ultima cosa, ed è quella che salva il caso peggiore dal sembrare disperato.** Il
percorso fallisce su un attestato, non sulla persona. Il ramo «cosa ti serve» funziona
già su un cliente che non ha portato niente: la scheda di ingresso raccoglie i ruoli,
`requisiti` dice cosa è dovuto per ruolo, `formazione_dovuta` produce `mancante` per
tutto ciò che non risulta coperto (`0036:232-274`, versione attuale a `0052:563-626`), e
la prova su un cliente inventato è documentata (`04-motore-scadenze.md:1268-1281`). Il
peggio che l'attestato irriconoscibile produce non è un errore: è che quella persona
risulti scoperta essendo coperta, e le venga proposto un corso che non le serve. Il che
è il difetto giusto da avere — «per un tool di conformità non deve MAI nascondere un
gap» (`creditiAllegatoIII.ts:14-17`) — purché sia detto, e purché non si spacci per una
misura della realtà quello che è una misura del nostro archivio. La distinzione esiste
già ed è scritta: dei 1.001 `mancante`, «332 non hanno in archivio nessun corso di
nessun tipo, mentre 670 hanno altri corsi ma non quello: i secondi sono un'assenza più
significativa dei primi» — ed è «senza traccia», non «non formato»
(`04-motore-scadenze.md:917-922`).

---

## Cosa manca alle fonti, in un elenco che è un elenco perché è un elenco

Non sono argomenti: sono cinque documenti da procurare o da leggere, e ognuno sblocca
un pezzo di questo percorso.

Il **DM 6 marzo 2013** sui requisiti dei formatori non è in `fonti/`: senza, il
controllo sul formatore non esiste (`DI_06_03_2013_REQUISITI_FORMATORI.txt:12-16`).

La **Parte I dell'ASR 2025 sui soggetti formatori** è dentro `fonti/ASR-170425.pdf` ma
non è trascritta: senza, non si può dire chi possa emettere un attestato.

L'**Accordo 128/CSR del 2016** su RSPP e ASPP è una scansione da cui `pdftotext` cava 37
byte, e la copia di Organigramma-sicurezza è anch'essa una scansione
(`quadro-storico-ore-pregresse.md:159-169`). Va letto a video o va procurata una resa
con il testo.

Le **tabelle di pagina 113 e 114 della Parte VII** — riconoscimento del pregresso per
DL-RSPP e per RSPP/ASPP — non sono trascritte cella per cella
(`asr-2025-parte-vii.md:156-157`). Sono le due tabelle che questo percorso userebbe più
spesso.

Le **matrici delle pagine 127-129 e 131 dell'Allegato III**, i crediti parziali
quantificati in ore, non sono codificate, e il motivo è dichiarato: manca un modello a
ore (`asr-2025-crediti.md:66-92`).

E un errore da correggere, sotto G3: `ASR_59_2025_punto6_ATTESTAZIONI.txt:27` dice
ancora «applicabile agli attestati emessi dal 24/05/2025», contro il 19 maggio che il
repo usa dalla migrazione 0043. Non è un file di AppOverall: va segnalato alla corsia
che lo tiene, come è già stato fatto per la nota analoga in `faq-asr-2025.md`
(`7-base-normativa.md:137-141`).
