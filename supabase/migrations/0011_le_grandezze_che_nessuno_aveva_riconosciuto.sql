-- AppOverall — 0011
-- Il blanket della 0008 contato bene: 53 marche, una sola grandezza sbagliata,
-- e tredici che non dovevano essere un'affermazione.
--
-- ============================================================================
--  DA DOVE VIENE
-- ============================================================================
--
-- Assegnazione del 12 settembre 2026 ad AppFormazione, e consegna dello stesso
-- giorno: `AppFormazione/docs/20-le-grandezze-dei-quaranta-codici.md` (`2632cbf`).
-- Sola lettura da parte loro, nessuna scrittura su nessun database.
--
-- La domanda che avevo mandato era: quante delle 40 righe portano un
-- `durata_corso` che nessuna regola ha riconosciuto, e quante di quelle sono in
-- realta un'altra grandezza. Tornano **tre** risposte, e due non erano fra quelle
-- che avevo previsto.
--
-- ---------- 1. il numero, e l'errore e mio ----------
--
-- Non 36: **53 marche su 37 righe distinte**. La `0008` fa **due** update per
-- presenza di un numero — 36 su `ore` e 17 su `ore_aggiornamento` — e nella
-- domanda li avevo **citati tutti e due e contato uno**. Sedici righe le prendono
-- entrambe, `LAV_SPEC` solo la seconda.
--
-- E il rilievo che vale piu del numero e sulla **forma delle due colonne**, che non
-- e la stessa:
--
--   ore_aggiornamento   il blanket prende il RESIDUO di una regola che ha
--                       riconosciuto sedici righe (l'art. 73 nel titolo)
--   ore                 non c'e nessuna regola: il blanket e l'UNICA cosa che
--                       scrive quella colonna
--
-- Quindi **zero righe su 40 hanno un `ore_grandezza` che qualcuno abbia
-- riconosciuto**, e la frase che la `0008` scrive di se — «si marca solo in
-- positivo» — e vera per **16 marche su 69**. Il `default` invertito protegge le
-- righe che arriveranno domani; su quelle di oggi ho scritto un'affermazione e l'ho
-- chiamata riconoscimento.
--
-- ============================================================================
--  2. LA GRANDEZZA SBAGLIATA E UNA, E NON E QUELLA CHE AVEVO INDICATO
-- ============================================================================
--
-- **`RSPP_MOD_B.ore_aggiornamento = 40` e un monte ore quinquennale, non la durata
-- di un corso.** ASR 17/04/2025, Parte III punto 3 (pagg. 79-82 di 136),
-- trascritto in `formazione-81-utils-src/reference/asr-2025-aggiornamenti.md`:
--
--   «Il monte ore complessivo di aggiornamento potra essere distribuito nell'arco
--    temporale del quinquennio.»
--
-- La trascrizione aggiunge la cosa che rende la lettura decidibile e non
-- interpretativa: **«E qui, e solo qui, che l'accordo dice espressamente»** quella
-- frase. Verificato da questa parte aprendo il file, non preso dal loro documento.
--
-- Un numero che si puo spalmare su cinque anni confrontato con le ore di un
-- attestato non da un risultato sbagliato per poco: ne da uno che non significa
-- niente, e lo da in silenzio (A13).
--
-- ---------- e il secondo sospetto era mio, ed era infondato ----------
--
-- Nell'assegnazione avevo indicato **due** candidati: il modulo B e l'aggiornamento
-- dell'art. 34. Il secondo **non regge, e la fonte lo dice**:
--
--   Parte III punto 2  «Datore di lavoro che svolge i compiti di RSPP — cadenza
--                       quinquennale, 8 ore»: una durata, non un monte ore
--   Accordo 223/CSR    Allegato A punto 7: l'aggiornamento quinquennale «HA DURATA,
--   del 21/12/2011      modulata in relazione ai tre livelli di rischio»
--
-- La clausola di distribuzione non c'e, e non c'e per nessun'altra cadenza
-- quinquennale della Parte III. **«Quinquennale, quindi monte ore» e dedurre, non
-- leggere** — che e la regola A7 applicata contro chi l'ha invocata.
--
-- Sta scritto qui con lo stesso rilievo del risultato buono, perche il sospetto era
-- in un'assegnazione: **un sospetto assegnato si ritira dove era stato dato**, o
-- resta a orientare la prossima lettura di qualcun altro.

update corso set ore_aggiornamento_grandezza = 'monte_ore_quinquennio'
 where codice = 'RSPP_MOD_B';

-- ============================================================================
--  3. LA TERZA CATEGORIA, CHE L'ASSEGNAZIONE NON PREVEDEVA
-- ============================================================================
--
-- «Il blanket e giusto» e «il blanket e sbagliato» non esauriscono i casi, e la
-- risposta vera per **13 marche** e una terza: *la grandezza e plausibilmente
-- `durata_corso`, e nessuna fonte leggibile lo dice.*
--
-- Sotto A7 quelle 13 non sono un'affermazione da scrivere: sono il valore che la
-- `0008` ha istituito apposta per «nessuno ha marcato questa riga». Tornano ad
-- `assente`, e il conto degli `assente` smette di essere una constatazione e
-- diventa quello che quella migrazione diceva di volere: **un filo teso**.
--
--   RSPP_MOD_A/B/C .ore        l'Accordo 7/7/2016 in `fonti/` e una scansione senza
--                              livello di testo: `pdftotext` ne cava 37 byte
--   ATTR_LAV_ELETTRICI         CEI 11-27 e una norma tecnica **a pagamento**, non e
--                              in `fonti/` e non ci sara
--   ATTR_LAV_QUOTA             nessuna norma, e **lo dice la 0004 stessa**: «la
--                              norma non fissa scadenze specifiche», i 60 mesi sono
--                              prassi
--   PS_BLSD_LAICO/SANITARIO    protocollo IRC: non e una fonte normativa
--   PS_GRA / PS_GRBC .ore_agg  il DM 388/2003 **non fissa le ore**: vedi sotto
--   ATTR_AMB_CONFINATI .ore    ne il DPR 177/2011 ne l'ASR danno durate per platea:
--                              12 e una scelta di erogazione, vedi sotto
--
-- Otto marche su `ore`, cinque su `ore_aggiornamento`.

update corso set ore_grandezza = 'assente'
 where codice in ('RSPP_MOD_A', 'RSPP_MOD_B', 'RSPP_MOD_C',
                  'ATTR_LAV_ELETTRICI', 'ATTR_LAV_QUOTA',
                  'PS_BLSD_LAICO', 'PS_BLSD_SANITARIO',
                  'ATTR_AMB_CONFINATI');

update corso set ore_aggiornamento_grandezza = 'assente'
 where codice in ('ATTR_LAV_ELETTRICI', 'ATTR_LAV_QUOTA',
                  'PS_BLSD_LAICO', 'PS_GRA', 'PS_GRBC');

-- ---------- e le altre sei restano, e la linea passa qui ----------
--
-- Ci sono altre **sei** marche senza citazione in `reference/`: `DATORE_LAVORO.ore
-- = 16`, `DIRIGENTE.ore = 12`, `PREPOSTO.ore = 12`, `LAV_GEN.ore = 4`,
-- `DL_RSPP_COMUNE.ore = 8`, `CANTIERI.ore = 6`. **Non tornano ad `assente`**, e la
-- differenza non e di comodo:
--
--   le 13   la fonte NON E LEGGIBILE — non esiste, e a pagamento, e prassi, o e una
--           scelta di erogazione. Nessuno puo chiudere il buco leggendo.
--   le 6    la fonte e leggibilissima e NON E TRASCRITTA: sono le durate iniziali
--           della **Parte II** dell'ASR 2025, e in `reference/` stanno la Parte III,
--           la Parte VII, l'Allegato IV e i punti 8.3.9-8.3.11. Si chiude
--           trascrivendo, non decidendo.
--
-- Marcare `assente` le sei direbbe «non si puo sapere», che e **falso**, e un
-- guardrail che grida a vuoto perde valore la prima volta che grida, non la prima
-- volta che sbaglia. Resta invece un lavoro assegnabile, e l'ha dichiarato la corsia
-- che tiene quella reference: **trascrivere la Parte II**.
--
-- ============================================================================
--  4. TRE NOTE DEL CATALOGO CITANO UNA NORMA CHE NON DICE QUELLO
-- ============================================================================
--
-- Le prime due le porta la loro consegna, la terza e venuta fuori leggendo le righe
-- accanto. Non sono commenti: sono **dati**, la colonna `corso.note`, ed e la
-- colonna che qualcuno leggera in ispezione.
--
-- **1 e 2. Il DM 388/2003 non fissa le ore dell'aggiornamento.** La periodicita
-- triennale e nel decreto (art. 3 c. 5); le 6 e le 4 ore no. Gli allegati 3 e 4
-- portano solo i corsi di **formazione** — 16 ore per il gruppo A, 12 per i gruppi
-- B e C — e per l'aggiornamento il testo dice «andra ripetuta con cadenza triennale
-- **almeno per quanto attiene alla capacita di intervento pratico**», senza fissare
-- nessuna durata. Le 6 e le 4 sono **prassi Overall**, e in
-- `reference/ore-fuori-dall-asr.md` sono marcate come tali: «l'unica riga della
-- reference che non viene da un testo».
--
-- E la frase del decreto va letta due volte, perche «almeno per quanto attiene alla
-- capacita di intervento pratico» e **la stessa formula che altrove genera
-- `parte_pratica`**. Qui non la genera — non c'e un numero a cui attaccarla — ma il
-- giorno in cui qualcuno leggesse quelle ore come pratiche, il 4 di `PS_GRBC`
-- cambierebbe significato senza cambiare valore.

update corso set note = 'DM 388/2003 per la periodicita triennale (art. 3 c. 5). **Le 6 ore no**: il decreto non fissa la durata dell''aggiornamento, dice «almeno per quanto attiene alla capacita di intervento pratico». Le 6 ore sono prassi Overall — `reference/ore-fuori-dall-asr.md`.'
 where codice = 'PS_GRA';

update corso set note = 'DM 388/2003 per la periodicita triennale (art. 3 c. 5). **Le 4 ore no**: il decreto non fissa la durata dell''aggiornamento. Le 4 ore sono prassi Overall — `reference/ore-fuori-dall-asr.md`. Questo codice resta fra i cinque «4 ore che non sono parte pratica» per la ragione giusta, con la citazione corretta.'
 where codice = 'PS_GRBC';

-- **3. E l'RLS, che nessuno aveva chiesto di guardare.** La nota diceva
-- «Aggiornamento annuale 4h (fino a 50 lavoratori) o 8h (oltre): verificare
-- dimensione». E la regola di **prima del 31 dicembre 2025**. L'ultimo periodo
-- dell'art. 37 c. 11 e stato modificato dall'art. 5 del D.L. 31/10/2025 n. 159,
-- convertito con L. 29/12/2025 n. 198: i casi sono **tre** e non due, e le 4 e le 8
-- sono un **pavimento** e non una durata — «la cui durata non puo essere inferiore
-- a». Sotto i 15 lavoratori la legge non fissa niente e rinvia al CCNL.
--
-- La nota si corregge **adesso** e non aspetta la scheda 12: quella decide *quanti
-- meccanismi* il catalogo debba avere per esprimere una durata che dipende dalla
-- dimensione, e **non** se il testo vigente dica quello che questa riga gli fa dire.
-- Una decisione aperta non e una licenza a tenere in tabella una norma vecchia.

update corso set note = 'Aggiornamento **annuale**. Art. 37 c. 11 come modificato dall''art. 5 del D.L. 31/10/2025 n. 159 (conv. L. 29/12/2025 n. 198), in vigore dal 31/12/2025: **tre casi** — sotto i 15 lavoratori la durata la fissa il **CCNL**, da 15 a 50 **non meno di** 4 ore annue, oltre i 50 **non meno di** 8. Le 4 e le 8 sono un **minimo**, non la durata. Il valore in `ore_aggiornamento` e il minimo del caso centrale: quale meccanismo esprima le tre varianti e la **scheda 12**, aperta.'
 where codice = 'RLS';

-- ---------- e una nota che mancava del tutto ----------
--
-- `ATTR_AMB_CONFINATI.ore = 12` non ha mai avuto una nota, e quel 12 non viene da
-- una norma: **ne il DPR 177/2011 ne l'ASR danno durate per platea**. L'ASR conosce
-- una figura sola sugli ambienti confinati e il DPR rimanda all'accordo. Il 12 e la
-- durata di **una** delle platee, e combacia con cio che il dizionario dei dieci
-- alias diceva gia da un'altra parte: 4 ore ai lavoratori, 12 a preposto, DL-RSPP e
-- RSPP modulo B.

update corso set note = 'Le **12 ore sono una scelta di erogazione, non una durata di norma**: ne il DPR 177/2011 ne l''ASR danno durate per platea, e l''ASR conosce una figura sola. Il dizionario porta **dieci alias** sotto questo codice con **due** durate — 4 ai lavoratori, 12 a preposto, DL-RSPP e RSPP modulo B — quindi il 12 e la platea alta. L''aggiornamento invece si legge: Parte III punto 5, 4 ore **di sola parte pratica**.'
 where codice = 'ATTR_AMB_CONFINATI';

-- ============================================================================
--  5. IL PERICOLO CHE QUESTA COLONNA ESISTE PER IMPEDIRE, E CHE OGGI NON IMPEDISCE
-- ============================================================================
--
-- Non e una riga da cambiare: e un fatto da lasciare scritto dove lo si ritrovera,
-- cioe accanto alla colonna che dovrebbe pararlo.
--
-- **Otto attrezzature portano lo stesso codice nei due repo e due grandezze
-- diverse.** Il documento 16 di AppFormazione le classifica come «solo modulo
-- teorico» sull'attesa iniziale; la `0004` di qui porta invece il **totale**
-- dell'allegato — `ATTR_CARRELLO.ore = 12`, cioe 1 + 7 + 4. Nessuno dei due
-- sbaglia: la loro `0041` mise le sole ore di teoria in `ore_teoriche` e lascio
-- `ore_iniziali` a null, ed e per questo che da loro quelle otto non producono
-- giudizi falsi.
--
-- **Il giorno in cui qualcuno riconcilia i due cataloghi per codice, otto righe si
-- confronteranno con due grandezze diverse sotto lo stesso nome — e
-- `ore_grandezza`, la colonna che esiste apposta per impedirlo, direbbe
-- `durata_corso` su tutte e due.** Una colonna che marca la grandezza non serve a
-- niente se le due parti la riempiono guardando due numeri diversi: la marcatura va
-- confrontata **insieme al valore**, e la migrazione dati passa di li.
--
-- Segnalato da loro il 12 settembre, prima che quella riconciliazione esistesse,
-- che e l'unico momento in cui questa nota costa una riga invece di un progetto.
--
-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select ore_grandezza, count(*) from corso group by 1 order by 1;
--         assente 12 · durata_corso 28
--   select ore_aggiornamento_grandezza, count(*) from corso group by 1 order by 1;
--         assente 12 · durata_corso 11 · monte_ore_quinquennio 1 · parte_pratica 16
--
-- **Prima erano 4 e 7 gli `assente`, adesso sono 12 e 12.** Le due cifre uguali
-- sono una coincidenza e vanno guardate separate: 4 + 8 sulla prima colonna, 7 + 5
-- sulla seconda.
--
--   -- i codici a 4 ore di aggiornamento che restano `durata_corso`
--   select codice from corso
--    where ore_aggiornamento = 4 and ore_aggiornamento_grandezza = 'durata_corso'
--    order by codice;                          -- 2: PONTEGGI, RLS
--
-- **Erano cinque e sono due.** Il conto della `0008` diceva «cinque, e sono questi»
-- come prova che la regola sul nome avesse **separato e non spostato**; adesso
-- ATTR_LAV_ELETTRICI, ATTR_LAV_QUOTA e PS_GRBC non sono piu un'affermazione, e i
-- due che restano sono quelli con una fonte che si legge — l'ASR per il ponteggio,
-- l'art. 37 c. 11 per l'RLS. **Il conto vecchio non e stato smentito: e stato
-- rifatto su meno affermazioni**, e va riportato cosi, perche un conto che cambia
-- valore senza dire perche e il modo in cui si perde un controllo.
--
--   -- e il filo teso: quante righe il motore si rifiuterebbe di giudicare
--   select count(*) from corso
--    where ore is not null and ore_grandezza = 'assente';            -- 8
--   select count(*) from corso
--    where ore_aggiornamento is not null and ore_aggiornamento_grandezza = 'assente';
--                                                                     -- 5
--
-- Questi due numeri **devono scendere trascrivendo fonti, non aggiornando la
-- colonna**. Il giorno in cui scendono senza che `reference/` sia cresciuta,
-- qualcuno ha rimesso un'affermazione al posto di un «non lo so».
