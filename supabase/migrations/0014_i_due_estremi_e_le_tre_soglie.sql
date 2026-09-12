-- AppOverall — 0014
-- I tre meccanismi della scheda 12, e l'estremo superiore non e una data di taglio.
--
-- ============================================================================
--  CORRETTA PRIMA DI QUALUNQUE CARICO, E LA LETTURA HA TROVATO UN DIFETTO ATTIVO
-- ============================================================================
--
-- Scritta il 12 settembre 2026 e **riscritta la sera stessa** dopo la lettura di
-- AppFormazione (`docs/22-lettura-della-0014-prima-del-carico.md`, `0294855`), che
-- e la terza volta che quella lettura arriva prima di un carico e la terza volta
-- che trova qualcosa. **Non e stata caricata da nessuna parte**: il criterio che
-- questo repo usa per non toccare una migrazione e «caricata e misurata», non
-- «spinta», e la storia di git conserva com'era.
--
-- Cosa la lettura ha trovato, in ordine di gravita:
--
--   1. **il vincolo «insieme non vuoto» non rifiutava l'insieme vuoto** — vedi qui
--      sotto: e il difetto attivo, e i quattro controlli negativi della prima
--      stesura non lo toccavano;
--   2. **l'insieme anonimo era la forma sbagliata**: `array[6,10,14]` non dice
--      quale sia BASSO, e la corrispondenza esisteva **in prosa dentro `fonte`**.
--      Nella stessa migrazione `corso_durata_per_dimensione` risolve lo stesso
--      problema bene. Adesso le ore sono una tabella figlia e ogni numero ha il
--      suo nome;
--   3. **il vincolo che legava insieme e discriminante era una biimplicazione**, e
--      rifiutava un caso che sta nello stesso accordo gia citato — 221/CSR punto 9
--      pag. 11, «un aggiornamento quinquennale, di durata minima di 6 ore, **per
--      tutti e tre i livelli di rischio** sopra individuati»: un numero solo, e la
--      fonte nomina la condizione **apposta** per dire che non morde;
--   4. **mancava un conto**, e senza quello il conto della sovrapposizione dice la
--      cosa sbagliata quando il difetto e un altro.
--
-- I nove valori e le due date sono stati verificati contro le fonti, uno per uno,
-- e sono giusti: quella parte non e cambiata.
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
--  2 · IL REGIME CHIUSO, E OGNI NUMERO HA IL SUO NOME
-- ============================================================================
--
-- Il regime vecchio dell'art. 34 non ha una durata, **ne ha tre** — 6, 10 e 14 ore
-- secondo il livello di rischio — e la prima stesura le teneva in un array:
-- `ore_possibili numeric[]`. **Sbagliato, e la ragione vale oltre questa tabella.**
--
-- Un array **non dice quale numero corrisponda a quale livello**. La
-- corrispondenza esisteva lo stesso — in **prosa, dentro `fonte`**, «BASSO 6,
-- MEDIO 10, ALTO 14» — cioe leggibile da una persona e non da una query: e
-- *esattamente* la forma di difetto che la `0008` esiste per chiudere. E nella
-- **stessa migrazione**, dodici righe piu in basso, `corso_durata_per_dimensione`
-- risolve lo stesso identico problema **bene**: una riga per ramo, con la soglia
-- accanto al numero. Due forme per lo stesso problema nello stesso file, e una
-- delle due era anonima.
--
-- Quindi le ore sono una **tabella figlia**, una riga per variante. Il guadagno non
-- e solo di espressivita:
--
--   il caso del 221/CSR punto 9 si scrive senza eccezioni   tre righe con lo stesso
--   numero dicono «6 ore per tutti e tre i livelli», che e cio che la fonte dice
--
--   la terza lettura diventa possibile                      «usa il discriminante»,
--   la strada esatta, con l'array non era esprimibile e la frase che diceva il
--   contrario e corretta qui sotto
--
--   i vincoli tornano LOCALI                                niente array vuoti,
--   niente null dentro un array, niente cardinalita da controllare
--
-- **E un insieme si confronta lo stesso, su due estremi.** Col confronto `>=`:
--
--   fatte >= il MASSIMO delle varianti   sufficienti, CERTO: nessun livello chiede di piu
--   fatte <  il MINIMO  delle varianti   insufficienti, CERTO: nessun livello chiede di meno
--   in mezzo                             non calcolabile SENZA il discriminante
--
-- Sulle distribuzioni misurate sono **69 righe su 301 decise** senza sapere niente
-- del livello di rischio, e **228 in mezzo**.
--
-- **La frase della prima stesura era comoda e falsa, e va corretta e non tolta.**
-- Diceva che la forma regge *tutte e due* le letture del «in mezzo». Le letture
-- sono **tre**, e la terza e una di quelle messe davanti a Francesco — «usa il
-- discriminante», la strada esatta. Con l'array non era esprimibile; **con questa
-- tabella lo e**, ed e il motivo per cui la correzione non e cosmetica: una forma
-- che regge due letture su tre costringe la decisione a essere presa fra le due che
-- la forma consente, che e il modo in cui uno schema decide al posto di chi decide.

create table corso_regime_precedente (
  corso_codice text not null references corso(codice),
  -- Quale delle due durate del corso: la stessa riga di catalogo puo avere un
  -- regime chiuso sull'iniziale **e** uno sull'aggiornamento, con varianti diverse.
  -- `DL_RSPP_BASE` li ha tutti e due, ed e il motivo per cui questa colonna esiste.
  colonna text not null
    constraint regime_colonna_nota check (colonna in ('ore', 'ore_aggiornamento')),
  -- L'estremo superiore: l'ultimo giorno in cui il corso poteva essere **avviato**
  -- col programma vecchio — vedi il blocco sull'inapplicabilita, piu sotto.
  valida_fino_a date not null,
  -- Da cosa dipendeva quale variante valesse. Null = una variante sola, e non
  -- dipendeva da niente. **Valorizzato = il dato che servirebbe e che non
  -- abbiamo**, e si scrive per dire *perche* il caso in mezzo non e calcolabile,
  -- invece di lasciarlo sembrare una dimenticanza.
  discriminante text
    constraint regime_discriminante_noto check (discriminante in ('livello_rischio')),
  fonte text not null,
  nota text,
  primary key (corso_codice, colonna)
);

create table corso_regime_precedente_ore (
  corso_codice text not null,
  colonna text not null,
  -- Il **nome** della variante, non la sua posizione in un array. `unica` quando il
  -- regime vecchio aveva una durata sola; i tre livelli quando dipendeva da quelli.
  variante text not null
    constraint regime_variante_nota check (variante in ('unica', 'basso', 'medio', 'alto')),
  ore numeric(5,1) not null
    constraint regime_ore_positive check (ore > 0),
  primary key (corso_codice, colonna, variante),
  foreign key (corso_codice, colonna)
    references corso_regime_precedente (corso_codice, colonna) on delete cascade
);

comment on table corso_regime_precedente is
  'Il regime **chiuso** di una riga di catalogo: cosa la norma chiedeva prima, e fino a quando un corso poteva ancora essere avviato con quel programma. Sta accanto a `corso` e non dentro, perche `corso` e il regime **corrente** e lo leggono gia sei migrazioni. I due estremi — `corso.valida_dal` e `valida_fino_a` qui — sono **indipendenti e si sovrappongono**: per dodici mesi entrambi i programmi erano legittimi, e una forma che non lo esprimesse dichiarerebbe non valido un attestato che la Parte VII dichiara valido.';
comment on column corso_regime_precedente.discriminante is
  'Il dato da cui dipendeva quale variante valesse. `livello_rischio` = il livello dell''azienda **al tempo dell''attestato**, che non e cio che abbiamo: quello che abbiamo e la classe di oggi, dedotta dall''ATECO di oggi. Questa colonna esiste per dire che il caso in mezzo non e calcolabile **e perche**, invece di lasciare che sembri una svista.';
comment on table corso_regime_precedente_ore is
  'Le ore del regime chiuso, **una riga per variante e col nome della variante accanto**. Era un array, ed era la forma sbagliata: `array[6,10,14]` non dice quale sia BASSO, e la corrispondenza finiva in prosa dentro `fonte` — leggibile da una persona e non da una query, che e il difetto che la `0008` esiste per chiudere. Tre righe con lo **stesso** numero sono una scrittura legittima e dicono cio che il 221/CSR punto 9 dice: «6 ore per tutti e tre i livelli di rischio».';
comment on column corso_regime_precedente_ore.variante is
  'Il nome, non la posizione. `unica` quando il regime vecchio aveva una durata sola: **non e un null travestito**, e l''affermazione «qui non c''era niente da distinguere».';

alter table corso_regime_precedente enable row level security;
alter table corso_regime_precedente_ore enable row level security;
create policy leggono_gli_operatori on corso_regime_precedente for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on corso_regime_precedente_ore for select to authenticated using (e_operatore());
create policy scrive_amministrazione on corso_regime_precedente for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
create policy scrive_amministrazione on corso_regime_precedente_ore for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
grant select on corso_regime_precedente to authenticated;
grant select on corso_regime_precedente_ore to authenticated;

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

update corso set valida_dal = date '2025-05-19' where codice in ('DIRIGENTE', 'DL_RSPP_BASE', 'PREPOSTO');

insert into corso_regime_precedente
  (corso_codice, colonna, valida_fino_a, discriminante, fonte, nota) values

  ('DIRIGENTE', 'ore', date '2026-05-19', null,
   'Accordo 21/12/2011 (221/CSR) punto 6, pag. 9: «La durata minima della formazione per i dirigenti e di 16 ore»',
   'Registrazione e non riparazione: 16 >= 12, quindi i dodici attestati da 16 ore passavano gia contro l''attesa corrente. Il regime vecchio era **piu severo**, e questa riga non cambia nessun giudizio — dice com''era. **E la clausola dei fatti salvi vale anche qui**: ASR 2025 Parte VII pag. 112, «per i lavoratori sono fatti salvi i percorsi... credito formativo totale», identica per i dirigenti. Quindi non e solo storia: e la ragione per cui quegli attestati non vanno integrati.'),

  ('DL_RSPP_BASE', 'ore_aggiornamento', date '2026-05-19', 'livello_rischio',
   'Accordo 21/12/2011 (223/CSR) Allegato A punto 7, pag. 8: «ha durata, modulata in relazione ai tre livelli di rischio»',
   '**La riga che il meccanismo esiste per portare.** 76 righe a 6 ore oggi valgono 76 `insufficienti` falsi contro l''attesa corrente di 8. Col minimo a 6 e il massimo a 14: 36 righe a 14 ore sono sufficienti CERTE, 99 restano in mezzo (76 a 6 e 23 a 10). E la fonte dice «ha durata» e non «monte ore», quindi non e la forma del punto 3 della Parte III.'),

  ('PREPOSTO', 'ore', date '2026-05-19', null,
   'Accordo 21/12/2011 (221/CSR) punto 5, pag. 8: «La durata minima del modulo per preposti e di 8 ore» — e ASR 2025 Parte VII, pag. 112: «Per i preposti sono fatti salvi i percorsi formativi effettuati in vigenza dell''accordo Stato-Regioni del 21 dicembre 2011, per il quali e riconosciuto **credito formativo totale**»',
   '**La popolazione piu grande che questo meccanismo ripara: 276 righe da 8 ore** contro l''attesa corrente di 12, cioe 276 `insufficienti` falsi — 3,6 volte le 76 di `DL_RSPP_BASE`. E non poggia su un''inferenza: la Parte VII lo dice **in una clausola esplicita**, quindi confrontare quegli attestati con l''attesa di oggi e falso **per il testo** e non per una lettura del regime. **E vale sotto tutte e due le letture di `PREPOSTO`**: che le 276 righe siano il corso del regime vecchio o uno dei tre corsi distinti, il corso che portano e quello del 2011 in entrambi i casi, e il credito totale non dipende da quella risposta. Questa riga NON separa niente e non anticipa la scheda 12.'),

  ('DL_RSPP_BASE', 'ore', date '2026-05-19', 'livello_rischio',
   'Accordo 21/12/2011 (223/CSR) Allegato A punto 5, pag. 6',
   '33 righe a 48 ore sono sufficienti CERTE. **E le 4 righe a 8 ore stanno sotto il minimo e NON vanno date per insufficienti**: 8 e esattamente la durata del modulo comune dell''art. 34 (Parte II punto 4, pag. 20), quindi sono un attestato di modulo comune **mappato sul codice del percorso intero** — una riga classificata male, non una formazione mancante. La regola dei due estremi vale a patto che la riga sia davvero quel corso.');

insert into corso_regime_precedente_ore (corso_codice, colonna, variante, ore) values
  ('DIRIGENTE',    'ore',               'unica', 16),
  ('PREPOSTO',     'ore',               'unica',  8),
  ('DL_RSPP_BASE', 'ore_aggiornamento', 'basso',  6),
  ('DL_RSPP_BASE', 'ore_aggiornamento', 'medio', 10),
  ('DL_RSPP_BASE', 'ore_aggiornamento', 'alto',  14),
  ('DL_RSPP_BASE', 'ore',               'basso', 16),
  ('DL_RSPP_BASE', 'ore',               'medio', 32),
  ('DL_RSPP_BASE', 'ore',               'alto',  48);

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
-- misura: e una domanda a chi tiene il gestionale.
--
-- **E qui NON entra una colonna `estremo_su`, per una ragione che non e "e
-- impalcatura".** La prima stesura la sospettava mancante sotto A13. La lettura di
-- AppFormazione ha spostato il bersaglio, ed e giusto: `valida_fino_a` **non e
-- ambiguo** — la clausola dice «avviati» e quella data misura l'avvio, con certezza.
-- **L'ambiguo e l'altro operando**, la colonna `Data` dell'export: A13 marca il
-- numero dove il numero e ambiguo, quindi quella marcatura va sull'**import**,
-- accanto alla data importata, dove la `0008` ha messo `testo_origine` e
-- `codice_fiscale_origine`.
--
-- **Ma l'innesco si dichiara adesso, perche l'estremo non e costante per natura: e
-- costante per l'accidente che tutte e tre le righe vengono da una clausola sola.**
-- La stessa Parte VII usa entrambe le formule — «avviati» al punto 2, «concluso»
-- nella clausola dei 24 mesi del datore. **Il giorno in cui entra la prima riga la
-- cui fonte dice «concluso», questa tabella prende una colonna che dice su cosa si
-- misura l'estremo.** Scritto qui perche chi scrivera quella riga lo trovi.

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
--   select count(*) from corso_regime_precedente;                      -- 4
--   select count(*) from corso_regime_precedente_ore;                  -- 8
--   select count(*) from corso where valida_dal is not null;           -- 4
--         DIRIGENTE, DL_RSPP_BASE, PREPOSTO, ATTR_PLE_UNA
--   select count(*) from corso_durata_per_dimensione;                  -- 3
--   select count(*) from corso;                                        -- 41, ed erano 40
--
-- ---------- i conti che un check non puo fare, e vanno in QUEST'ORDINE ----------
--
-- Sono condizioni **fra tabelle**, e la `0008` ha gia scritto perche restino conti:
-- «un `check` non puo vederlo — e una condizione fra righe — quindi resta un conto».
-- **L'ordine non e estetico**: il primo deve tornare zero perche il secondo
-- significhi quello che dice.
--
--   -- 1. ogni regime chiuso ha un corso che dichiara da quando vale il nuovo
--   select r.corso_codice, r.colonna from corso_regime_precedente r
--     join corso c on c.codice = r.corso_codice where c.valida_dal is null;   -- 0
--
--   -- 2. e allora i due estremi si SOVRAPPONGONO. Se questo tornasse zero la forma
--   --    sarebbe sbagliata: vorrebbe dire che nessun regime vecchio sopravvive al nuovo
--   select count(*) from corso_regime_precedente r join corso c on c.codice = r.corso_codice
--    where r.valida_fino_a > c.valida_dal;                                    -- 4 su 4
--
-- **Perche in quest'ordine, e perche il primo conto e nuovo.** `valida_dal` e
-- nullable e la tabella figlia non puo controllarlo. Senza il primo conto, una riga
-- scritta senza `valida_dal` farebbe tornare il secondo **3 su 4** — e quel 3
-- direbbe «manca una sovrapposizione» mentre il difetto e «manca una data». Un conto
-- che prende il difetto sbagliato e peggio di un conto che non lo prende: il primo
-- manda a cercare nel posto sbagliato, il secondo lascia cercare.
--
--   -- 3. ogni regime ha almeno una variante di ore. **Questo conto sostituisce un
--   --    vincolo che non funzionava**: vedi il difetto, qui sotto
--   select r.corso_codice, r.colonna from corso_regime_precedente r
--    where not exists (select 1 from corso_regime_precedente_ore o
--                       where o.corso_codice = r.corso_codice and o.colonna = r.colonna);  -- 0
--
--   -- 4. discriminante e varianti si corrispondono, nei due versi
--   select r.corso_codice, r.colonna, r.discriminante, count(o.*), min(o.variante)
--     from corso_regime_precedente r
--     join corso_regime_precedente_ore o
--       on o.corso_codice = r.corso_codice and o.colonna = r.colonna
--    group by 1,2,3
--   having (r.discriminante is null) <> (count(o.*) = 1 and min(o.variante) = 'unica');  -- 0
--
-- **Il quarto e la biimplicazione che era un `check` e non doveva esserlo.** Come
-- vincolo rifiutava un caso vero: 221/CSR punto 9, pag. 11 — «un aggiornamento
-- quinquennale, di durata minima di **6 ore**, per **tutti e tre i livelli di
-- rischio** sopra individuati». Un numero solo, e la fonte nomina la condizione
-- **apposta per dire che non morde**. Come conto, quel caso si scrive come va
-- scritto — tre righe `basso`/`medio`/`alto` con lo stesso 6 — e il conto lo accetta,
-- perche le varianti sono tre e il discriminante c'e.
--
-- ---------- e il conto che fa da controllo negativo a se stesso ----------
--
--   select count(*) from corso_alias where corso_codice = 'ATTR_PLE_UNA';   -- 0
--
-- Deve tornare **zero oggi** e **diverso da zero** il giorno in cui i titoli sono
-- mappati. Se resta zero dopo quella lettura, il codice e stato creato e non
-- collegato — che e esattamente come `import_key` e rimasta vuota per una
-- migrazione intera nel repo del campo, con l'indice unique gia al suo posto.
--
-- **E la riga inerte della `0009` prende lo stesso trattamento**, perche due righe
-- inerti in due migrazioni consecutive cominciano a somigliare a un'abitudine.
-- Rilievo di AppFormazione, e la prova che le distingue non e l'intenzione:
--
--   ATTR_PLE_UNA     inerte, ma ha un FILO TESO (il conto qui sopra) e un
--                    proprietario del passo successivo — chi mappa i titoli
--   coordinatore     inerte, e aspetta una DECISIONE COMMERCIALE che nessuno ha in
--                    mano: se Overall eroghi o no il CSP/CSE
--
--   select 'coordinatore', count(*) from corso_assolve where ruolo = 'coordinatore_sicurezza';  -- 0
--
-- Lo stesso conto, e il valore atteso e **zero finche la decisione non e presa**:
-- cosi la riga della `0009` smette di essere «inerte» e diventa «in attesa di una
-- decisione commerciale», che e uno stato e non un'omissione.
--
-- ============================================================================
--  IL DIFETTO CHE LA LETTURA HA TROVATO, E CHE I CONTROLLI NON TOCCAVANO
-- ============================================================================
--
-- La prima stesura teneva le ore in un array con questo vincolo:
--
--   ore_possibili numeric(5,1)[] not null
--     constraint regime_insieme_non_vuoto check (array_length(ore_possibili, 1) >= 1)
--
-- **`array_length` su un array vuoto torna NULL, non zero — e un `check` che vale
-- NULL e SODDISFATTO**, perche PostgreSQL rifiuta solo su `false`. Quindi il vincolo
-- che si chiamava «insieme non vuoto» era esattamente quello che **lasciava passare
-- l'insieme vuoto**. Verificato su PostgreSQL 16 prima di riscrivere: `insert into t
-- values ('{}')` con quel check risponde `INSERT 0 1`.
--
-- E il costo sarebbe stato silenzioso nel modo peggiore: con l'insieme vuoto il
-- minimo e il massimo sono `null`, quindi la riga **sparisce da tutti e tre i rami**
-- — non sufficiente, non insufficiente, e nemmeno in mezzo. Un `null` dentro
-- l'array e un'altra forma della stessa cosa: `max` e `min` lo **ignorano** invece di
-- propagarlo, quindi `array[6, null, 14]` risponde tranquillamente 14 e 6 e il
-- giudizio si calcola su un insieme che qualcuno ha scritto male.
--
-- **I quattro controlli negativi della prima stesura provavano i due vincoli che
-- funzionavano, e non toccavano questo.** Non e una svista dei controlli: il caso
-- vuoto non e venuto in mente a nessuno dei due, finche AppFormazione non l'ha
-- girato. **Un controllo negativo prova che un vincolo morde, non che sia il
-- vincolo giusto** — ed e il pezzo che mancava ad A12.
--
-- La tabella figlia lo chiude **per costruzione e non per vincolo**: non esiste un
-- array da svuotare, `ore` e `not null`, e «nessuna variante» e un conto con un
-- nome — il terzo, qui sopra.
--
-- ---------- i controlli, rifatti sulla forma nuova ----------
--
-- Provati su PostgreSQL 16 (A12: un test che non sbaglia mai non prova niente).
--
--   variante fuori dai quattro nomi                    RIFIUTATO
--   ore a zero                                         RIFIUTATO
--   ore negative                                       RIFIUTATO
--   una riga di ore senza il suo regime padre          RIFIUTATO
--   dimensione con un numero E un rinvio               RIFIUTATO
--   dimensione senza ne numero ne rinvio               RIFIUTATO
--   un regime padre legittimo                          accettato
--   tre varianti con lo STESSO numero (il 221/CSR)     accettato
--   una riga di dimensione legittima                   accettato
--
-- **Le tre accettate sono quelle che rendono le sei una prova**, e la penultima in
-- particolare: e il caso che il vincolo vecchio rifiutava, e dopo averlo inserito il
-- quarto conto continua a tornare **zero** — cioe la forma nuova lo riconosce come
-- legittimo invece di tollerarlo.
--
-- **E una nota di metodo che e costata un giro.** La prima esecuzione metteva i nove
-- controlli in **una transazione sola**: il primo `ERROR` l'ha abortita e gli altri
-- otto hanno risposto «current transaction is aborted». Letto di corsa sembrava che
-- avessero fallito tutti — cioe **sembrava una prova riuscita** — e invece era un
-- controllo eseguito e otto silenzi. Ogni controllo negativo va eseguito **da solo**,
-- altrimenti il primo rifiuto nasconde gli altri e il risultato si legge come li si
-- voleva leggere.
