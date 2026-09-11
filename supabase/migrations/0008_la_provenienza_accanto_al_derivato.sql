-- AppOverall — 0008
-- La provenienza accanto al derivato: quattro colonne, una tabella, una forma sola.
--
-- ============================================================================
--  PERCHE QUESTE QUATTRO COSE STANNO INSIEME
-- ============================================================================
--
-- L'11 settembre 2026, in una giornata sola, la stessa forma di difetto si e
-- presentata **sette volte su cinque tabelle e tre repository diversi**. Ogni
-- volta il sintomo era diverso e la diagnosi la stessa:
--
--   1. `cliente.codice_ateco`   `37` preso dal CAP di Nogara: un'impresa edile
--                               archiviata come gestione reti fognarie. La cella
--                               d'origine non c'era piu, quindi il dubbio non era
--                               nemmeno esprimibile
--   2. i ruoli nelle mansioni   `RSPP- NO TITOLARE`, il refuso `TITOLRE`: meta
--                               dell'organigramma sta in un campo di testo libero
--                               e la colonna strutturata non la vede
--   3. `corso_alias.testo`      si dichiara «come lo emette l'origine, verbatim» e
--                               **non lo e per 211 righe su 268**
--   4. `persona.codice_fiscale` dieci segnaposto `XXXYYY123456X###` hanno la forma
--                               giusta, sono distinti per costruzione e **nessun
--                               `unique` puo rifiutarli**
--   5. le date dei file         tre export letti insieme portano tre freschezze
--                               diverse, e «Dati aggiornati al» **non e** la data
--                               dell'estrazione
--   6. `corso.ore_aggiornamento` un `4` che su sedici codici significa «quattro ore
--                               di **parte pratica**» e su `PONTEGGI` «quattro ore
--                               **totali**»
--   7. le scadenze dichiarate   sette «richiami anticipati» erano **penultima
--                               esecuzione + periodicita** su una fotografia vecchia
--
-- **La regola che le lega, e che questa migrazione applica invece di descriverla:
-- quando si deriva un dato da un testo altrui, il testo altrui e parte del dato.**
-- Il derivato da solo non sa dire se sia affidabile, e chi arriva dopo non ha modo
-- di chiederglielo. Ogni volta che lo si e scoperto, lo si e scoperto tardi.
--
-- ---------- cosa NON fa questa migrazione, e non per dimenticanza ----------
--
-- **Il secondo codice degli ambienti confinati non entra qui**, benche fosse
-- annunciato. Sotto `ATTR_AMB_CONFINATI` vivono **due** corsi di aggiornamento —
-- 4 ore ai lavoratori, 12 a preposto, DL-RSPP e RSPP modulo B — e il catalogo ne
-- porta uno: quello e un difetto vero e resta da riparare.
--
-- Ma un codice nuovo **senza il rimappamento dei tre alias** sarebbe un orfano
-- come `ATTR_GENERICO`, e il rimappamento **tocca il dizionario dei 268**, che e
-- verificato contro la produzione del campo su undici valori su undici. Spezzare
-- un codice **e** riportare tre alias sul nuovo e **una decisione che diverge da
-- una fonte verificata**, e la `0004` dice cosa farne: «dove divergono diventa una
-- riga da decidere, non una media». Si decide con la `0009`, insieme, o non si
-- decide: **mezzo lavoro qui produrrebbe un codice che nessuno usa e un dizionario
-- che nessuno sa piu se combacia.**

-- ============================================================================
--  UNO — DA QUALE ESTRAZIONE VIENE UN DATO
-- ============================================================================
--
-- Gli export del gestionale portano in fondo una riga che dichiara una data, e
-- **le due formule non dicono la stessa cosa**:
--
--   «Report aggiornato al 09/09/2026»           data la PRODUZIONE del foglio
--   «Dati aggiornati al 06/08/2026 07:44»       data la FRESCHEZZA del contenuto
--
-- E la seconda **non descrive il file**. Provato in due versi lo stesso giorno:
-- `ExportExcelCorsiScadenze.zip`, salvato il **03/09 alle 13:12**, contiene quattro
-- `.xlsx` con timestamp interni del **03/09 alle 13:11** che dichiarano «Dati
-- aggiornati al **06/08**» — un file non e stato prodotto prima di esistere. E
-- `elencoAnagraficaFormazioni`, salvato alle **17:01**, dichiara **17:04**: tre
-- minuti **dopo** l'istante in cui esisteva.
--
-- **Ma non e nemmeno una legge**: i due export delle visite scaricati l'11
-- settembre alle 15:23 dichiarano «Dati aggiornati al 11/09/2026 **15:23**», cioe
-- l'istante dello scaricamento. **La dicitura dice quale delle due cose la data
-- misura; non dice se le due coincidano.** Lo dice solo un timestamp esterno.
--
-- Quindi **non c'e nessuna regola che permetta di dedurla, e l'unico modo di
-- saperla e leggerla da ogni file e conservarla.**

create table origine_estrazione (
  -- Corto e parlante: si legge negli errori di carico e nelle query di riscontro,
  -- dove un uuid costringe a una join per capire di cosa si parla. Stessa scelta
  -- di `corso.codice` e per la stessa ragione.
  codice text primary key,
  file text not null,
  -- **La data dichiarata, e nient'altro.** Non «vecchia» o «fresca»: e un valore,
  -- non una valutazione. Il giudizio lo fa chi confronta due righe di questa
  -- tabella — che e esattamente il motivo per cui esiste.
  data_dichiarata date not null,
  -- La riga di pie di pagina **verbatim**, perche i due formati non hanno lo
  -- stesso contenuto: uno porta l'ora e l'altro no. Con un `timestamp` unico
  -- bisognerebbe mettere **mezzanotte** sui file senza ora — un valore dedotto che
  -- non si distingue da uno vero, cioe il difetto che questa migrazione esiste per
  -- chiudere, commesso nell'atto di chiuderlo.
  dichiarazione text not null,
  -- Dove esiste: l'impronta dei testi estratti, per sapere se due letture guardano
  -- la stessa estrazione. Nullable perche non tutti gli export ne hanno una.
  impronta text,
  righe int,
  note text,
  creato_il timestamptz not null default now()
);

comment on table origine_estrazione is
  'Da quale estrazione viene un dato importato. Serve in due versi, e il secondo e quello che di solito si perde: dice che due file NON sono confrontabili, e dice che due file SONO lo stesso istante anche se scaricati a un mese di distanza. Senza il secondo ci si astiene da paragoni legittimi, e una cautela inutile costa quanto un allarme falso — per la stessa ragione: la seconda volta non ci si crede.';
comment on column origine_estrazione.data_dichiarata is
  'Quella che il file dichiara, non quella in cui e stato scaricato, e non un giudizio su quanto sia vecchia. Le due possono differire di un mese (misurato) o di tre minuti nel verso opposto (misurato): la dicitura dice quale delle due cose la data misura, non se coincidano.';
comment on column origine_estrazione.dichiarazione is
  'La riga di pie di pagina come sta nel file. «Report aggiornato al 09/09/2026» non ha l''ora, «Dati aggiornati al 06/08/2026 07:44» ce l''ha: stesso gestionale, stesso giorno, due formati.';

insert into origine_estrazione (codice, file, data_dichiarata, dichiarazione, impronta, righe, note) values
  ('catalogo_20260730', 'elencoAnagraficaFormazioni.xlsx', '2026-07-30',
   'Dati aggiornati al 30/07/2026 17:04',
   '9742ecef39efb97daf27279a6cfb17e0991884729eec053570f224ff50865f30', 268,
   'Il catalogo dei corsi del gestionale, da cui vengono i 268 testi d''origine degli alias. Il file ha 272 righe: 3 di testa e 2 di piede — l''URL e la data — e le 268 sono cio'' che resta. L''impronta e'' sui `testo_origine` concatenati con newline **in ordine di riga del foglio**: ordinata per `testo` darebbe un hash diverso, perche'' l''`order by` di PostgreSQL segue la collation (A11).');

-- ============================================================================
--  DUE — `corso_alias` non tiene il testo: tiene la chiave
-- ============================================================================
--
-- Il commento della `0004` dice che `testo` e «il testo come lo emette l'origine,
-- verbatim». **E falso su 211 righe su 268**, contate carattere per carattere:
--
--   identiche all'origine                          57
--   diverse solo per maiuscole e minuscole        196
--   diverse anche per gli spazi                    15
--
-- Fra le quindici: **otto** con uno spazio doppio interno, **sei** con uno spazio
-- in coda, e **una con un ritorno a capo dentro il titolo del corso**. Il catalogo
-- del gestionale **non e tutto maiuscolo**: ha titoli in Frase, titoli maiuscoli e
-- titoli misti dentro la stessa riga.
--
-- **L'import non si rompe** — quello del campo normalizza tutti e due i lati del
-- confronto con la stessa funzione — e quindi il difetto **non e nei dati**: e in
-- un commento che descrive una cosa diversa da quella che il codice fa, e che da
-- questa parte **non ha nessun codice accanto a smentirlo**. Uno stesso commento
-- falso **vale di piu dove c'e meno codice**, che e il contrario di quel che si
-- immagina.
--
-- La `0004` non si corregge — caricata e misurata — quindi il commento si sostituisce
-- qui.

alter table corso_alias
  -- Il testo come il gestionale lo emette davvero. Il doppio spazio, lo spazio in
  -- coda, il ritorno a capo: sono il dato, non rumore.
  add column testo_origine text,
  -- **Non una colonna di comodo.** L'impronta dei 268 si ricontrolla solo ordinando
  -- come e stata calcolata, e `corso_alias` ha per chiave `testo`: ordinare per
  -- quello seguirebbe la collation e darebbe un **terzo** hash, facendo concludere
  -- che il carico e rotto. E la trappola A11 spostata a valle, dove il falso allarme
  -- costa di piu perche arriva quando il dato e gia dentro.
  add column riga_foglio int,
  add column estrazione text references origine_estrazione(codice);

comment on column corso_alias.testo is
  '**Una CHIAVE NORMALIZZATA, non il testo dell''origine** — la `0004` diceva «verbatim» ed era falso su 211 righe su 268: 196 differiscono per maiuscole e minuscole, 15 anche per gli spazi. Il testo com''e'' emesso sta in `testo_origine`. Chi scrive un import confronti **chiavi con chiavi**: l''origine non promette ne'' il case ne'' la spaziatura.';
comment on column corso_alias.testo_origine is
  'Il titolo come il gestionale lo stampa, verbatim. Uno dei 268 contiene un **ritorno a capo**: se un giorno finisse in una chiave confrontata alla lettera, non e'' lo spazio doppio il caso da temere.';
comment on column corso_alias.riga_foglio is
  'La riga del foglio da cui viene il testo. Esiste perche'' l''impronta dell''estrazione si ricalcola **solo** in quest''ordine: ordinare per `testo` segue la collation e da'' un hash diverso sulla stessa tabella.';

-- I 268 valori stanno in `supabase/seed/corso_alias_origine.sql`, che si carica
-- dopo questa migrazione e verifica l'impronta da se. Le tre colonne restano
-- nullable: il giorno in cui un alias arriva da un'origine senza foglio — un
-- attestato di un cliente nuovo — non avra ne riga ne estrazione, e va bene.

-- ============================================================================
--  TRE — un codice fiscale che ha la forma giusta e non e un'identita
-- ============================================================================
--
-- `persona.codice_fiscale` e `unique` con `check (~ '^[A-Z0-9]{16}$')`. Misurato
-- sulle 3.500 righe persona dell'export del 09/09, con tre soglie diverse:
--
--   16 alfanumerici sul grezzo .....................  3.261
--   16 alfanumerici dopo la pulizia ................  3.266
--   pulizia + forma + CARATTERE DI CONTROLLO .......  3.238
--
-- **Fra la seconda e la terza ci sono 28 righe che hanno sedici alfanumerici e non
-- sono codici fiscali**, e dieci di quelle sono il caso peggiore possibile per un
-- `unique`: `XXXYYY123456X126`, `X187`, `X190`… — un segnaposto del gestionale con
-- **il suffisso incrementale**. Dieci righe, **dieci valori distinti**: passano il
-- `check`, **non collidono mai per costruzione**, ed entrerebbero come dieci
-- identita buone. *Un segnaposto che si ripete si vede al primo conflitto; uno
-- incrementale un conflitto non lo produce mai.*
--
-- Le altre diciotto sono **persone vere con un refuso**: diciassette col carattere
-- di controllo sbagliato — `CRNNRC79D18L781V` per CORNALE ENRICO, dove l'ultima
-- lettera dovrebbe essere `Y` — e una che finisce con una cifra.
--
-- **Il `check` non si irrigidisce**, e non per prudenza: metterci il carattere di
-- controllo rifiuterebbe **diciassette persone vere** per una lettera, e perdere
-- una riga e peggio che tenerla imprecisa. La soglia del **formato** resta dov'e;
-- quella dell'**identita** si sposta nell'import, che calcola il controllo e tratta
-- ogni fallimento come **assente** — cosi i dieci segnaposto finiscono nel ripiego
-- cognome+nome invece che in dieci identita inventate.
--
-- **E cio che c'era scritto non si perde.**

alter table persona
  add column codice_fiscale_origine text;

comment on column persona.codice_fiscale is
  '**null non vuol dire «non ce n''era»**: vuol dire «non ce n''e'' uno usabile come identita''». La cella d''origine resta in `codice_fiscale_origine`, quindi «non c''era niente» e «c''era qualcosa e non era un codice fiscale» restano distinguibili. L''import calcola il carattere di controllo e tratta ogni fallimento come assente: e'' l''unico modo di rifiutare i dieci segnaposto `XXXYYY123456X###`, che il `check` accetta e che l''`unique` non puo'' far collidere.';
comment on column persona.codice_fiscale_origine is
  'La cella come stava nell''export, anche quando non e'' un codice fiscale: una P.IVA, un nome proprio, un codice con una lettera di troppo. Tre righe su 3.500 lo sono, e una — GRISI ELENA — compare con lo **stesso** difetto in **due export diversi**, quindi sta nel dato a monte e non nell''estrazione.';

-- ---------- e il vincolo `unique` globale resta, contro il parere del campo ----
--
-- AppSopralluoghi ha misurato che **sette codici fiscali compaiono su piu di una
-- riga**: **sei sono la stessa persona presso due clienti** — MOUSTAHSSEN HAJAR fra
-- due societa del gruppo Velox, AMARI e NEGRETTI fra due aziende agricole — e
-- **uno** e una riga doppia dentro lo stesso cliente. La loro conclusione e che
-- `codice_fiscale unique` globale **rifiuterebbe l'import** e che l'unicita vada su
-- `(cliente, codice_fiscale)`.
--
-- **Vero da loro, e falso qui**, e la differenza e di modello e non di prudenza: la
-- `0001` tiene `persona` e `rapporto_lavoro` **separate**, quindi una persona con
-- due datori e **una riga di `persona` e due di `rapporto_lavoro`**. I sei casi non
-- sono un ostacolo al vincolo: **sono la prova che il modello e giusto**, e con
-- `(cliente, codice_fiscale)` MOUSTAHSSEN HAJAR diventerebbe **due persone**.
--
-- **Ma il mio modello ha un rischio che il loro non ha, e vale due righe**: un
-- ripiego su cognome+nome, qui, **fonderebbe fra clienti diversi**. `MORANDINI
-- ACHILLE` e `TECCHIO STEFANO` compaiono senza codice fiscale valido presso **due
-- clienti ciascuno**, e non c'e modo di sapere dai dati se siano la stessa persona.
-- Il ripiego dell'import porta quindi **il cliente dentro la chiave**, e quando il
-- nome non distingue **non fonde**: *meglio un doppione che si vede, di due persone
-- fuse per sbaglio, che non si vede piu.*

-- ============================================================================
--  QUATTRO — un `4` che non dice di che cosa sia
-- ============================================================================
--
-- La parte III dell'ASR 2025 usa **due formule diverse** per lo stesso formato:
--
--   punto 1.1  lavoratori            «durata minima di 6 ore»
--   punto 1.2  preposti              «biennale, durata minima 6 ore»
--   punto 2    DL-RSPP               «quinquennale, 8 ore»
--   punto 5    ambienti confinati    «durata minima 4 ore DI PARTE PRATICA»
--   punto 6    attrezzature art. 73  «durata minima 4 ore DI PARTE PRATICA»
--
-- Sulle prime tre il numero e un pavimento sulla **durata del corso**; sulle ultime
-- due sulla **sola parte pratica**, e il totale la fonte **non lo dice**. Che sia
-- una distinzione vera e non una sfumatura di trascrizione lo prova l'allegato XXI,
-- che per i ponteggi scrive l'altra formula: «durata minima di 4 ore **di cui 3** di
-- contenuti tecnico pratici». **Stesso numero, grandezza diversa.**
--
-- In questo catalogo `ore_aggiornamento = 4` sta su **ventuno righe**, e sedici di
-- quelle — i quindici dell'art. 73 piu `ATTR_AMB_CONFINATI` — **non sono
-- confrontabili con le ore di un attestato**, che riporta il totale. Le altre
-- **cinque** lo sono, e portano lo stesso `4`:
--
--   PONTEGGI             allegato XXI: «4 ore **di cui 3** tecnico pratiche»
--   PS_GRBC              DM 388/2003: quattro ore ogni tre anni, totali
--   RLS                  art. 37 c. 11: quattro ore annue — **un pavimento**, e i
--                        casi sono tre e non due (vedi la scheda 12)
--   ATTR_LAV_ELETTRICI   CEI 11-27, un'altra norma
--   ATTR_LAV_QUOTA       nessuna norma: i sessanta mesi sono **prassi**, e il
--                        riscontro col sito lo dice esplicito
--
-- **Ventuno e non diciotto, e cinque e non tre: i primi due numeri erano miei e
-- sbagliati.** Venivano da un `grep` che filtrava su `ATTR_*` e `PONTEGGI`, quindi
-- **escludeva per costruzione** `PS_GRBC` e `RLS` — e il conteggio filtrato e stato
-- citato come se fosse il totale. E la terza volta in un giorno che un numero
-- prodotto da una selezione viene riusato come se descrivesse la popolazione. Il
-- controllo in fondo a questa migrazione l'ha trovato **prima** del carico, ed e la
-- ragione per cui i conti attesi si scrivono insieme alle righe e non dopo.
--
-- Oggi nessuno li confronta: **non e un difetto attivo, e una mina su ogni
-- estensione futura** — e la stessa mina sta in due cataloghi diversi, perche il
-- numero e stato copiato dalla stessa fonte **senza la sua grandezza**.
--
-- **Due colonne e non una**, e la ragione l'ha trovata AppFormazione prima che la
-- scrivessi: `corso` ha **due attese per riga**, e su `ATTR_CARRELLO` sono grandezze
-- diverse — `12` e un totale, `4` e la sola parte pratica. Una colonna sola avrebbe
-- marcato la riga **descrivendo male meta dei suoi numeri**, che e la forma esatta
-- del difetto che la colonna doveva chiudere.

-- ---------- e il `default` e `assente`, che e il pezzo che avevo sbagliato ----------
--
-- La prima stesura aveva `default 'durata_corso'`, e AppFormazione l'ha fermata
-- leggendo la migrazione **prima del carico**. La regola sul nome e un **proxy**: la
-- grandezza viene dalla **fonte** — parte III punto 6 — e la regola legge una stringa
-- nel **titolo commerciale**. Funziona perche quel catalogo e stato costruito citando
-- l'articolo, e non c'e niente che glielo imponga.
--
-- Il difetto non era il proxy: era **cosa succede quando manca**.
--
--   default 'durata_corso'   un corso non marcato e CONFRONTABILE   -> fallisce APERTO
--   default 'assente'        un corso non marcato NON si giudica    -> fallisce CHIUSO
--
-- Con il primo, il giorno in cui Overall aggiunge un corso dell'art. 73 senza
-- scrivere «(art. 73)» nel nome, quel codice **eredita un'affermazione che nessuno ha
-- fatto**. Con il secondo, «nessuno ha marcato questa riga» smette di essere
-- un'affermazione e **torna a essere una domanda** — e il conteggio degli `assente`
-- smette di essere una constatazione e diventa un filo teso.
--
-- Invertirlo non costa niente, ed e la stessa cosa che questo repo ha gia deciso tre
-- volte oggi su tre tabelle: fra «non lo so» e un valore di comodo, **si sceglie il
-- non lo so**.

alter table corso
  add column ore_grandezza text not null default 'assente'
    constraint ore_grandezza_nota check (ore_grandezza in (
      'durata_corso', 'parte_pratica', 'modulo_teorico', 'monte_ore_quinquennio', 'assente')),
  add column ore_aggiornamento_grandezza text not null default 'assente'
    constraint ore_agg_grandezza_nota check (ore_aggiornamento_grandezza in (
      'durata_corso', 'parte_pratica', 'modulo_teorico', 'monte_ore_quinquennio', 'assente'));

comment on column corso.ore_grandezza is
  'Di che cosa sono le ore di `ore`. Esiste perche'' un confronto fra due numeri presuppone che misurino la stessa grandezza, e questa condizione viene **prima** delle altre (A13). `assente` e'' un **valore** e non l''assenza della colonna, ed e'' anche il **default**: una riga non marcata non e'' confrontabile, cosi'' quando la regola non riconosce un codice il motore si ferma invece di giudicare. **Dice di che cosa sia il numero, non se sia completo**: `ATTR_CARRELLO.ore = 12` e'' una durata di corso — grandezza giusta — ma e'' la durata di **una variante**, e il percorso combinato ne vuole 16. Quell''altro asse e'' «quale corso», non «quale grandezza», e questa colonna non lo porta.';
comment on column corso.ore_aggiornamento_grandezza is
  'Come sopra, per `ore_aggiornamento`. Sono **due** colonne e non una perche'' su `ATTR_CARRELLO` le due attese hanno grandezze diverse: 12 ore totali di corso iniziale, 4 ore di sola parte pratica in aggiornamento.';

-- ---------- popolate per REGOLA e non per elenco ----------
--
-- Un elenco di codici scritto a mano e sempre vecchio di una scoperta: il codice
-- nuovo che arrivera domani non ci sara, e nessuno se ne accorgera perche il
-- `default` gli dara `durata_corso`. La regola invece lo marca da se.
--
-- La regola e la **fonte**, e nel nome: i corsi dell'art. 73 la portano scritta —
-- `Carrello elevatore (art. 73)`, `Gru mobili (art. 73)` — perche quel catalogo e
-- stato costruito citando l'articolo nel titolo.

-- **Si marca solo in positivo.** Partendo da `assente`, ogni riga che finisce
-- marcata lo e perche una regola l'ha **riconosciuta**, e nessuna lo e per averlo
-- ereditato da un `default`.

update corso set ore_aggiornamento_grandezza = 'parte_pratica'
 where ore_aggiornamento is not null
   and (nome like '%(art. 73)%' or codice = 'ATTR_AMB_CONFINATI');

-- `ATTR_AMB_CONFINATI` e l'unica **eccezione nominata**, e va nominata: risponde al
-- **punto 5** e non al 6, quindi l'art. 73 nel titolo non ce l'ha e nessuna regola
-- sul nome lo prenderebbe. Un'eccezione dichiarata e diversa da un elenco: e una, e
-- porta scritto perche.
--
-- Nota su chi entra: fra i sedici c'e **`ATTR_GENERICO`**, «Attrezzatura abilitante
-- (art. 73)», che questa stessa migrazione chiama orfano — nessuno dei 268 alias lo
-- referenzia. E corretto che ci sia, ed e utile sapere che i sedici **ne contengono
-- uno che non e un corso** ma il rappresentante di una famiglia.

update corso set ore_grandezza = 'durata_corso' where ore is not null;
update corso set ore_aggiornamento_grandezza = 'durata_corso'
 where ore_aggiornamento is not null
   and ore_aggiornamento_grandezza = 'assente';

-- ============================================================================
--  LE RLS, COME LE ALTRE TABELLE DI VOCABOLARIO
-- ============================================================================

alter table origine_estrazione enable row level security;
create policy leggono_gli_operatori on origine_estrazione for select to authenticated using (e_operatore());
create policy scrive_amministrazione on origine_estrazione for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
grant select on origine_estrazione to authenticated;

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from origine_estrazione;                          --  1
--   select count(*) from corso where ore_grandezza = 'assente';       --  4
--   select count(*) from corso
--     where ore_aggiornamento_grandezza = 'parte_pratica';            -- 16
--   select count(*) from corso
--     where ore_aggiornamento_grandezza = 'assente';                  --  7
--   select count(*) from corso where ore_aggiornamento = 4;          -- 21
--   select codice from corso
--    where ore_aggiornamento = 4 and ore_aggiornamento_grandezza
--          = 'durata_corso' order by codice;                          --  5, e sono
--          ATTR_LAV_ELETTRICI, ATTR_LAV_QUOTA, PONTEGGI, PS_GRBC, RLS
--
-- **L'ultima e la piu importante, e va letta nei due versi.** Se tornasse **zero**,
-- la regola sul nome ha morso troppo e cinque numeri buoni sono stati marcati
-- inconfrontabili. Se tornasse **ventuno**, non ha morso affatto e sedici numeri
-- continuano a non dire di che cosa siano. **Cinque, e questi cinque**: e il solo
-- esito che dice che la regola ha separato e non spostato — un controllo che puo
-- fallire in una direzione sola non e un controllo.
--
-- ---------- e un conto che NON e un vincolo, e va detto perche ----------
--
-- `ruolo_da_parola_unico` della `0007` impedisce **due righe identiche**, e non
-- impedisce che per la stessa parola coesistano una riga con `posizione = null` —
-- «qualunque posizione» — e una con una posizione specifica. Il predicato che
-- risolve, `(r.posizione is null or r.posizione = t.posizione)`, **le matcherebbe
-- tutte e due**: il totale delle asserzioni crescerebbe, continuerebbe a sembrare
-- plausibile, e l'import creerebbe **due nomine per la stessa persona**.
--
-- Un `check` non puo vederlo — e una condizione **fra righe** — quindi resta un
-- conto, e va girato insieme agli altri:
--
--   select parola from ruolo_da_parola group by parola
--    having count(*) filter (where posizione is null) > 0 and count(*) > 1;   -- 0 righe
--
-- **Oggi torna vuoto. Il giorno in cui non torna vuoto, i 168 della `0007` sono gia
-- sbagliati e nessuno se n'e accorto.** E la stessa forma del `not in` scritto a mano
-- che la `0060` di AppFormazione ha dovuto proteggere: una struttura che **si allunga
-- per sbaglio** e non ha modo di accorgersene. Segnalata da loro leggendo la `0007`.
--
-- E dopo il seed, in `supabase/seed/corso_alias_origine.sql`:
--
--   select count(*) from corso_alias where testo_origine is not null;  -- 268
--   select encode(sha256(convert_to(
--            string_agg(testo_origine, chr(10) order by riga_foglio), 'UTF8')), 'hex')
--     from corso_alias;   -- 9742ecef39efb97daf27279a6cfb17e0991884729eec053570f224ff50865f30
--
-- **Ordinare per `riga_foglio` e non per `testo`**: la seconda segue la collation e
-- da un hash diverso sulla stessa tabella. Un'impronta che non torna per una ragione
-- **procedurale** segnala un problema che non c'e — e la prossima volta nessuno ci
-- crede piu. Un controllo perde valore la prima volta che grida a vuoto, non la
-- prima volta che sbaglia.
