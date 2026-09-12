-- AppOverall — 0014
-- I tre meccanismi della scheda 12, e l'estremo superiore non e una data di taglio.
--
-- ============================================================================
--  COSA ENTRA, E PERCHE LA FORMA NON E QUELLA CHE LA SCHEDA DESCRIVEVA
-- ============================================================================
--
-- Scheda 12, decisa il 12 settembre 2026: la validita temporale entra, la
-- condizione sulla dimensione entra con **tre** casi, le varianti combinate
-- prendono un codice proprio. La mappatura sui codici e di AppFormazione
-- (`docs/21-i-tre-meccanismi-sugli-undici-codici.md`, `549f360` e `993e768`), con
-- i valori letti a video sulla Parte II e sugli accordi del 2011.
--
-- **La forma pero non e «una data di taglio», ed e la correzione che ha
-- riaperto la scheda la sera stessa.** La Parte VII punto 2 (pag. 112) lascia
-- **avviare** i corsi col programma vecchio per **dodici mesi**:
--
--   il regime nuovo vale       DAL 19/05/2025
--   il regime vecchio vale     FINO AL 19/05/2026
--   e per dodici mesi          VALGONO TUTTI E DUE
--
-- Due estremi **indipendenti che si sovrappongono**, non un confine. Una colonna
-- sola — «valida fino a», o una data che separa — renderebbe non valido un
-- attestato che la norma dichiara valido.
--
-- ============================================================================
--  1 · IL REGIME CORRENTE PORTA IL SUO ESTREMO INFERIORE
-- ============================================================================
--
-- `corso` continua a essere **il regime corrente**: e cosi che lo leggono la
-- `0006`, la `0008` e le tre migrazioni delle grandezze, e spostare le durate
-- altrove vorrebbe dire portarsi dietro anche quelle marcature. Prende una data
-- e basta.

alter table corso add column valida_dal date;

comment on column corso.valida_dal is
  'Da quando vale il regime che **questa riga** porta. Null non vuol dire «da sempre»: vuol dire **non dichiarato**, come `assente` sulle grandezze — oggi e valorizzata solo dove il regime e cambiato e qualcuno ha letto la pagina. Non ha un estremo superiore per costruzione: la riga corrente e corrente finche non arriva un accordo nuovo, e quel giorno diventa una riga di `corso_regime_precedente`.';

-- ============================================================================
--  2 · IL REGIME CHIUSO E UNA TABELLA, E PORTA UN INSIEME DI NUMERI
-- ============================================================================
--
-- La colonna piu importante di questa migrazione e `ore_possibili`, ed e un
-- **array** invece di un numero per un fatto della fonte: il regime vecchio
-- dell'art. 34 non ha una durata, **ne ha tre** — 6, 10 e 14 ore secondo il
-- livello di rischio — e scriverne una sola vorrebbe dire scegliere al posto di
-- una condizione che non conosciamo.
--
-- **E un insieme si confronta lo stesso, su due estremi.** Col confronto `>=`:
--
--   fatte >= il MASSIMO dell'insieme    sufficienti, CERTO: nessun livello chiede di piu
--   fatte <  il MINIMO  dell'insieme    insufficienti, CERTO: nessun livello chiede di meno
--   in mezzo                            non calcolabile senza il discriminante
--
-- Sulle distribuzioni misurate sono **69 righe su 301 decise** senza sapere niente
-- del livello di rischio, e **228 in mezzo**. La forma regge tutte e due le letture
-- possibili di quel «in mezzo» — «non giudicabile» oppure «pavimento al minimo» —
-- **quindi la decisione che resta aperta non chiede un'altra migrazione**: chiede
-- una riga al motore. E una proprieta voluta: una forma che obbliga a decidere
-- prima di poter essere scritta fa prendere la decisione col calendario in mano.

create table corso_regime_precedente (
  corso_codice text not null references corso(codice),
  -- Quale delle due durate del corso: la stessa riga di catalogo puo avere un
  -- regime chiuso sull'iniziale **e** uno sull'aggiornamento, con insiemi diversi.
  -- `DL_RSPP_BASE` li ha tutti e due, ed e il motivo per cui questa colonna esiste.
  colonna text not null
    constraint regime_colonna_nota check (colonna in ('ore', 'ore_aggiornamento')),
  -- L'estremo superiore. Non e «l'ultimo giorno in cui il corso era valido»: e
  -- l'ultimo giorno in cui il corso poteva essere **avviato** col programma
  -- vecchio — vedi il blocco sull'inapplicabilita, qui sotto.
  valida_fino_a date not null,
  -- **L'insieme, e non il numero.** Un elemento quando il regime vecchio aveva una
  -- durata sola (`DIRIGENTE`), tre quando dipendeva da una condizione.
  ore_possibili numeric(5,1)[] not null
    constraint regime_insieme_non_vuoto check (array_length(ore_possibili, 1) >= 1),
  -- Da cosa dipendeva quale elemento dell'insieme. Null = l'insieme ha un solo
  -- valore e non dipende da niente. **Valorizzato = il dato che servirebbe e che
  -- non abbiamo**, ed e per questo che si scrive: dice *perche* il caso in mezzo
  -- non e calcolabile, invece di lasciarlo sembrare una dimenticanza.
  discriminante text
    constraint regime_discriminante_noto check (discriminante in ('livello_rischio')),
  fonte text not null,
  nota text,
  primary key (corso_codice, colonna),
  constraint regime_insieme_e_discriminante check (
    (array_length(ore_possibili, 1) = 1) = (discriminante is null))
);

comment on table corso_regime_precedente is
  'Il regime **chiuso** di una riga di catalogo: cosa la norma chiedeva prima, e fino a quando un corso poteva ancora essere avviato con quel programma. Sta accanto a `corso` e non dentro, perche `corso` e il regime **corrente** e lo leggono gia sei migrazioni. I due estremi — `corso.valida_dal` e `valida_fino_a` qui — sono **indipendenti e si sovrappongono**: per dodici mesi entrambi i programmi erano legittimi, e una forma che non lo esprimesse dichiarerebbe non valido un attestato che la Parte VII dichiara valido.';
comment on column corso_regime_precedente.ore_possibili is
  'L''insieme dei numeri che il regime vecchio poteva chiedere, non uno di essi. Col confronto `>=` due estremi si decidono comunque: chi ha fatto almeno il **massimo** e sufficiente certo, chi sta sotto il **minimo** e insufficiente certo, e solo in mezzo serve il discriminante. Scriverne uno solo — anche il piu prudente — sarebbe scegliere al posto di una condizione che non conosciamo, e lo sarebbe **in silenzio**.';
comment on column corso_regime_precedente.discriminante is
  'Il dato da cui dipendeva quale elemento dell''insieme valesse. `livello_rischio` = il livello dell''azienda **al tempo dell''attestato**, che non e cio che abbiamo: quello che abbiamo e la classe di oggi, dedotta dall''ATECO di oggi. Questa colonna esiste per dire che il caso in mezzo non e calcolabile **e perche**, invece di lasciare che sembri una svista.';

alter table corso_regime_precedente enable row level security;
create policy leggono_gli_operatori on corso_regime_precedente for select to authenticated using (e_operatore());
create policy scrive_amministrazione on corso_regime_precedente for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
grant select on corso_regime_precedente to authenticated;

-- ---------- i due codici che hanno un regime chiuso, e il payload e rovesciato ----------
--
-- **`DIRIGENTE` non ripara niente, e resta.** 12 ore dal 19/05/2025 (Parte II punto
-- 2.3, pag. 15) contro 16 del 2011. Il confronto e `>=` e **16 >= 12**: i dodici
-- attestati da 16 ore passano gia oggi. Il regime vecchio era **piu severo**, e la
-- riga qui sotto e una **registrazione** — dice il vero su com'era il mondo — non
-- una riparazione. La scheda 12 lo presentava come il caso che motiva il
-- meccanismo, ed era al contrario.
--
-- **`DL_RSPP_BASE` e dove il meccanismo vale tutto.** Delle 161 righe di
-- aggiornamento misurate, **76 sono a 6 ore** e oggi vengono confrontate con 8:
-- sono **76 giudizi `insufficienti` falsi** su persone che avevano fatto per intero
-- l'aggiornamento che il loro livello chiedeva.

update corso set valida_dal = date '2025-05-19' where codice in ('DIRIGENTE', 'DL_RSPP_BASE');

insert into corso_regime_precedente
  (corso_codice, colonna, valida_fino_a, ore_possibili, discriminante, fonte, nota) values

  ('DIRIGENTE', 'ore', date '2026-05-19', array[16]::numeric(5,1)[], null,
   'Accordo 21/12/2011 (221/CSR) punto 6, pag. 9: «La durata minima della formazione per i dirigenti e di 16 ore»',
   'Registrazione e non riparazione: 16 >= 12, quindi i dodici attestati da 16 ore passavano gia contro l''attesa corrente. Il regime vecchio era **piu severo**, e questa riga non cambia nessun giudizio — dice com''era.'),

  ('DL_RSPP_BASE', 'ore_aggiornamento', date '2026-05-19', array[6, 10, 14]::numeric(5,1)[], 'livello_rischio',
   'Accordo 21/12/2011 (223/CSR) Allegato A punto 7, pag. 8: «ha durata, modulata in relazione ai tre livelli di rischio» — BASSO 6, MEDIO 10, ALTO 14',
   '**La riga che il meccanismo esiste per portare.** 76 righe a 6 ore oggi valgono 76 `insufficienti` falsi contro l''attesa corrente di 8. Col minimo a 6 e il massimo a 14: 36 righe a 14 ore sono sufficienti CERTE, 99 restano in mezzo (76 a 6 e 23 a 10). E la fonte dice «ha durata» e non «monte ore», quindi non e la forma del punto 3 della Parte III.'),

  ('DL_RSPP_BASE', 'ore', date '2026-05-19', array[16, 32, 48]::numeric(5,1)[], 'livello_rischio',
   'Accordo 21/12/2011 (223/CSR) Allegato A punto 5, pag. 6',
   '33 righe a 48 ore sono sufficienti CERTE. **E le 4 righe a 8 ore stanno sotto il minimo e NON vanno date per insufficienti**: 8 e esattamente la durata del modulo comune dell''art. 34 (Parte II punto 4, pag. 20), quindi sono un attestato di modulo comune **mappato sul codice del percorso intero** — una riga classificata male, non una formazione mancante. La regola dei due estremi vale a patto che la riga sia davvero quel corso.');

-- ---------- e l'estremo superiore, alla lettera, oggi non e applicabile ----------
--
-- La clausola dice «possono essere **avviati** i corsi», quindi `valida_fino_a` si
-- confronta con la data di **avvio**. **L'export non porta la data di avvio.** Porta
-- una colonna `Data` sola, di significato **mai dichiarato** — un corso ha un inizio
-- e una fine e il gestionale ne espone una — e le altre tre colonne con «data» sono
-- nascita, assunzione e licenziamento.
--
-- Quindi non e che sbagliamo il confronto: **non abbiamo il campo**. Le due uscite
-- sono tutte e due **dichiarazioni e non letture**:
--
--   usare la data che c'e    accetta come «programma vecchio» tutto cio che e datato
--                            entro il 19/05/2026. Se `Data` e la fine corso, si
--                            scarta qualche corso avviato in tempo e finito dopo:
--                            sbaglia per DIFETTO, su pochi casi
--   allargare l'estremo      di una durata di corso plausibile: introduce un numero
--                            INVENTATO
--
-- **Si usa la prima, ed e dichiarata qui perche e una scelta e non una lettura.** La
-- domanda vera — *cosa misura la colonna `Data`* — non si scioglie con un'altra
-- misura: e una domanda a chi tiene il gestionale, ed e la stessa che la scheda 12
-- pone da se sotto «la colonna della data non dichiara cosa contiene».

-- ============================================================================
--  3 · LA CONDIZIONE SULLA DIMENSIONE, E IL RAMO CHE PESA NON E UN NUMERO
-- ============================================================================
--
-- **Un codice solo, `RLS`**, e non e una restrizione prudente: `DL_RSPP_BASE` varia
-- per livello di rischio, che e una condizione sul cliente **ma non questa**.
--
-- Il ramo che pesa e il primo: **432 delle 481 aziende con un numero stanno sotto i
-- 15 lavoratori**, il 90%. Per quel 90% la risposta corretta **non e un numero**: e
-- «la durata la fissa il contratto». Se quel ramo non esiste come stato proprio, il
-- motore confronta con 4 ore un obbligo che la legge non quantifica, e ogni RLS di
-- una micro-impresa con 2 ore di aggiornamento risulta `insufficienti` **senza che
-- nessuna norma lo dica**.
--
-- E i due numeri sono **pavimenti**, non durate: il testo dice «la cui durata **non
-- puo essere inferiore a** 4 ore annue [...] e a 8 ore annue». Sta nel nome della
-- colonna e non in un commento.

create table corso_durata_per_dimensione (
  corso_codice text not null references corso(codice),
  da_lavoratori int not null,
  -- Null = «e oltre». L'estremo superiore aperto non e un caso mancante.
  a_lavoratori int,
  -- **Un pavimento.** Null quando la legge non fissa nessun numero.
  ore_minime numeric(5,1),
  -- Dove la legge rinvia invece di quantificare. Non e «non lo so»: e un'altra
  -- fonte, che il sistema non ha e che **esiste**.
  rinvio text
    constraint dimensione_rinvio_noto check (rinvio in ('ccnl')),
  fonte text not null,
  nota text,
  primary key (corso_codice, da_lavoratori),
  -- O un numero, o un rinvio. **Mai nessuno dei due**: sarebbe la casella vuota che
  -- il motore legge come zero.
  constraint dimensione_numero_o_rinvio check ((ore_minime is not null) <> (rinvio is not null)),
  constraint dimensione_intervallo_sensato check (a_lavoratori is null or a_lavoratori >= da_lavoratori)
);

comment on table corso_durata_per_dimensione is
  'La durata che dipende da quanti lavoratori ha l''azienda. Oggi una riga sola la usa — `RLS` — e le sue tre varianti non sono «due piu un''eccezione»: il ramo **sotto i 15** copre il **90%** delle aziende in archivio, ed e quello in cui la risposta **non e un numero**. Le soglie sono 15 e 50 e i valori sono **minimi**: art. 37 c. 11 ultimo periodo, come modificato dall''art. 5 del D.L. 159/2025 conv. L. 198/2025, in vigore dal 31/12/2025.';
comment on column corso_durata_per_dimensione.rinvio is
  'La legge non quantifica e manda a un''altra fonte. `ccnl` = «nel rispetto del principio di proporzionalita», e il contratto che fissa la durata. **Va tenuto distinto da un null di ignoranza**: qui la risposta esiste, sta scritta altrove e si puo andare a prendere — chiedendola al cliente. Un motore che lo confonde con «non lo so» produce la stessa lista di lavoro per due problemi diversi.';

alter table corso_durata_per_dimensione enable row level security;
create policy leggono_gli_operatori on corso_durata_per_dimensione for select to authenticated using (e_operatore());
create policy scrive_amministrazione on corso_durata_per_dimensione for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
grant select on corso_durata_per_dimensione to authenticated;

insert into corso_durata_per_dimensione
  (corso_codice, da_lavoratori, a_lavoratori, ore_minime, rinvio, fonte, nota) values
  ('RLS',  0, 14,   null, 'ccnl',
   'D.Lgs. 81/2008 art. 37 c. 11, ultimo periodo (D.L. 159/2025 conv. L. 198/2025, in vigore dal 31/12/2025)',
   '**Il ramo che pesa: 432 aziende su 481.** La legge non fissa nessun numero e rinvia al CCNL «nel rispetto del principio di proporzionalita». Sapere quanti dipendenti ha il cliente **non chiude** questa variante: la manda in un caso che rinvia al contratto.'),
  ('RLS', 15, 50,      4, null,
   'D.Lgs. 81/2008 art. 37 c. 11, ultimo periodo (D.L. 159/2025 conv. L. 198/2025)',
   'Minimo, non durata: «non puo essere inferiore a 4 ore annue».'),
  ('RLS', 51, null,    8, null,
   'D.Lgs. 81/2008 art. 37 c. 11, ultimo periodo (D.L. 159/2025 conv. L. 198/2025)',
   'Minimo, non durata. **Qui sta il difetto che questo meccanismo previene, e va nel verso che fa danno**: 4 righe a 4 ore vengono da aziende sopra i 50 e oggi sarebbero dichiarate **conformi quando non lo sono**. Il meccanismo 1 previene falsi `insufficienti`, questo previene falsi `sufficienti` — e un allarme mancato non si vede.');

-- L'aggiornamento dell'RLS e **annuale**, e il catalogo lo dice gia
-- (`aggiornamento_mesi = 12`). La riga resta a 4 ore come valore corrente perche e
-- il minimo del caso centrale; quale ramo si applichi lo dice questa tabella
-- insieme a quanti lavoratori ha il cliente.
--
-- **E `RLS` non prende anche il meccanismo 1**, benche la regola sia cambiata il
-- 31/12/2025 (prima erano due casi: 4 fino a 50, 8 oltre). La ragione e la
-- direzione: il caso nuovo — sotto i 15 — e **piu permissivo** di quello vecchio,
-- quindi giudicare col metro di oggi un attestato di ieri non produce mai un falso
-- `insufficienti`. Sarebbe esattezza storica, non riparazione.

-- ============================================================================
--  4 · LA VARIANTE, E SE NE CREA UNA SOLA PERCHE UNA SOLA RIPARA UN FALSO
-- ============================================================================
--
-- Sei codici prendono il meccanismo 3, cinque hanno i valori nella Parte II punto
-- 8.3 — **non** nell'accordo del 2012, che la Parte VII punto 3 abroga. Ma su
-- quattro dei sei **il catalogo tiene gia il valore piu basso** della coppia, quindi
-- la variante lunga passa comunque (`16 >= 12`, `16 >= 10`, `14 >= 12`, `11 >= 10`):
-- li manca un codice, **non c'e un falso**, e un codice che manca si aggiunge quando
-- serve a qualcuno.
--
-- **`ATTR_PLE` e l'eccezione e va nel verso che fa male.** Il catalogo tiene **10**,
-- che e il percorso completo — teorico 4 + pratica 6, con e senza stabilizzatori —
-- mentre chi si abilita a **una sola** tipologia ha **8 ore** legittime e complete, e
-- oggi verrebbe confrontato con 10 e dichiarato `insufficienti`. **E l'unico dei sei
-- in cui il codice nuovo va creato col valore piu BASSO.**

insert into corso (codice, nome, categoria, ore, aggiornamento_mesi, ore_aggiornamento,
                   prerequisito_codice, attivo, note, valida_dal) values
  ('ATTR_PLE_UNA', 'Piattaforme di lavoro elevabili PLE - una sola tipologia (art. 73)',
   'attrezzature', 8, 60, 4, null, true,
   'Teorico 4 + pratica 4 su **una** tipologia — con stabilizzatori **oppure** senza. ASR 17/04/2025, Parte II punto 8.3.1, pagg. 41-42. Il percorso completo (entrambe, pratica 6, totale 10) resta `ATTR_PLE`: **questo non e mezzo corso**, e un''abilitazione valida e completa su una tipologia.',
   date '2025-05-19');

update corso set ore_grandezza = 'durata_corso',
                 ore_aggiornamento_grandezza = 'parte_pratica'
 where codice = 'ATTR_PLE_UNA';

-- L'aggiornamento e quello dell'art. 73: **4 ore di sola parte pratica**, Parte III
-- punto 6. Stessa marcatura dei sedici codici della `0008`, messa a mano perche
-- quella regola girava una volta sola su una tabella che allora non aveva questa riga.

insert into corso_assolve (ruolo, corso_codice, categoria, parziale, note) values
  ('conduce_ple', 'ATTR_PLE_UNA', null, false,
   'Assolve l''obbligo come `ATTR_PLE`: il ruolo dice «conduce PLE» e non **quale** tipologia — e la stessa cosa che la `0002` dichiara per tutte le attrezzature, «quale sia lo dice l''attestato e non la nomina».');

-- **E il falso non e ancora riparato, ed e onesto dirlo qui.** Nessuno dei 268 alias
-- punta a `ATTR_PLE_UNA`: finche i titoli non sono mappati, un attestato da 8 ore
-- continua ad atterrare su `ATTR_PLE` e a risultare insufficiente. Questa migrazione
-- rende la riparazione **possibile**; la chiude una lettura dei titoli, che vuole
-- l'export e non sta qui.
--
-- **E quante righe costi oggi non lo sappiamo.** Che il falso esista e certo dalla
-- fonte; quante volte si verifichi e una misura che ha bisogno dell'export dei corsi
-- fatti. Non si stima: si conta, e la conta chi ce l'ha.

-- ---------- i quattro che non riparano niente, coi valori, perche non si ricerchino ----------

update corso set note = coalesce(note || ' ', '') ||
  '**Varianti della fonte**: teorico 8 + pratica 4 (rotazione in basso) **o** 4 (in alto) **o** 6 (entrambe) → **12 o 14**. ASR 2025, Parte II punto 8.3.3, pagg. 48-50. Il catalogo tiene il valore piu basso, quindi la variante lunga passa comunque: **manca un codice, non c''e un falso**.'
 where codice = 'ATTR_GRU_TORRE';

update corso set note = coalesce(note || ' ', '') ||
  '**Varianti della fonte**: teorico 8 + pratica 4 (una delle tre tipologie) **o** 8 (tutte e tre) **o** 6 (carichi sospesi e persone) → **12, 16, 14**. ASR 2025, Parte II punto 8.3.4, pagg. 52-54. Il catalogo tiene il piu basso: manca un codice, non c''e un falso. **E il 16 non identifica una variante sola**: due tipologie prese come due abilitazioni separate fanno 8+4+4, che e ancora 16 — le ore non lo distinguono, serve il titolo.'
 where codice = 'ATTR_CARRELLO';

update corso set note = coalesce(note || ' ', '') ||
  '**Varianti della fonte**: teorico 4 + pratica 6 (una macchina) **o** 12 (idraulici, caricatori frontali e terne) → **10 o 16**. ASR 2025, Parte II punto 8.3.7, pagg. 63-66. Il catalogo tiene il piu basso: manca un codice, non c''e un falso.'
 where codice = 'ATTR_ESCAVATORI';

update corso set note = coalesce(note || ' ', '') ||
  '**Varianti della fonte**: teorico 4 + pratica 6 (una tipologia di comando) **o** 7 (tutte) → **10 o 11**. ASR 2025, Parte II punto 8.3.11, pagg. 76-77. Il catalogo tiene il piu basso: manca un codice, non c''e un falso.'
 where codice = 'ATTR_CARROPONTE';

update corso set note = coalesce(note || ' ', '') ||
  '**Prende il meccanismo delle varianti e NON prende i valori**: PES, PAV e PEI sono tre qualifiche distinte con percorsi distinti, ma la CEI 11-27 e una norma tecnica **a pagamento**, non e in `fonti/` e non e citabile. Il meccanismo si dichiara, i valori aspettano: e la stessa riga che resta fra quelle senza fonte leggibile della `0011`.'
 where codice = 'ATTR_LAV_ELETTRICI';

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from corso_regime_precedente;                      -- 3
--   select count(*) from corso where valida_dal is not null;           -- 3
--         DIRIGENTE, DL_RSPP_BASE, ATTR_PLE_UNA
--   select count(*) from corso_durata_per_dimensione;                  -- 3
--   select count(*) from corso;                                        -- 41, ed erano 40
--
--   -- i due estremi si SOVRAPPONGONO, e se questo tornasse zero la forma sarebbe
--   -- sbagliata: vorrebbe dire che nessun regime vecchio sopravvive al nuovo
--   select count(*) from corso_regime_precedente r join corso c on c.codice = r.corso_codice
--    where r.valida_fino_a > c.valida_dal;                             -- 3 su 3
--
--   -- l'insieme con piu di un valore porta sempre il suo discriminante, e viceversa
--   select corso_codice, colonna, array_length(ore_possibili,1), discriminante
--     from corso_regime_precedente order by 1, 2;
--         DIRIGENTE/ore 1 null · DL_RSPP_BASE/ore 3 livello_rischio
--         DL_RSPP_BASE/ore_aggiornamento 3 livello_rischio
--
--   -- la copertura della dimensione non ha buchi: 0-14, 15-50, 51 e oltre
--   select da_lavoratori, a_lavoratori, ore_minime, rinvio
--     from corso_durata_per_dimensione where corso_codice = 'RLS' order by 1;
--
-- **E il conto che vale come controllo negativo:** `ATTR_PLE_UNA` esiste, assolve
-- l'obbligo, e **nessun alias ci punta**.
--
--   select count(*) from corso_alias where corso_codice = 'ATTR_PLE_UNA';   -- 0
--
-- Deve tornare **zero oggi** e **diverso da zero** il giorno in cui i titoli sono
-- mappati. Se resta zero dopo quella lettura, il codice e stato creato e non
-- collegato — che e esattamente come `import_key` e rimasta vuota per una
-- migrazione intera nel repo del campo, con l'indice unique gia al suo posto.
--
-- ---------- e i controlli negativi, perche un vincolo che accetta tutto non e un vincolo ----------
--
-- Provati su PostgreSQL 16, sul database di prova, prima di chiudere la migrazione
-- (A12: un test che non sbaglia mai non prova niente).
--
--   insieme di tre valori SENZA discriminante          rifiutato
--   un valore solo CON discriminante                   rifiutato
--   dimensione con un numero E un rinvio               rifiutato
--   dimensione senza ne numero ne rinvio               rifiutato
--   una riga di dimensione legittima                   ACCETTATA
--
-- L'ultima riga e quella che rende le prime quattro una prova: quattro rifiuti da
-- soli si ottengono anche con un vincolo rotto che nega tutto.
