-- AppOverall — 0007
-- Dove atterrano i ruoli scritti a mano: 29 testi, 34 asserzioni, 9 regole.
--
-- ============================================================================
--  IL FATTO CHE HA CHIESTO QUESTA MIGRAZIONE
-- ============================================================================
--
-- L'11 settembre 2026 AppSopralluoghi ha contato, su tutte le 3.501 righe persona
-- e tutte le 480 societa del foglio «Ruoli SSL» (`8dab00a`):
--
--   153 righe portano un ruolo nelle COLONNE — l'organigramma dichiarato
--   160 righe lo portano scritto dentro la MANSIONE
--    12 righe in entrambi i posti
--   ---
--   301 righe portano un ruolo, e le colonne ne dichiarano il 51%
--
-- **Un import che legge solo le colonne trova meta dell'organigramma.** E il modo
-- in cui lo perde e la parte che conta: **94 societa** — il 15% del portafoglio
-- attivo, 703 persone — dopo quell'import avrebbero l'organigramma **vuoto avendone
-- uno scritto**, e nessuno se ne accorgerebbe, perche «senza organigramma» e uno
-- stato legittimo e indistinguibile dal dato mancante.
--
-- Per il **datore di lavoro** non c'e nemmeno la possibilita di fare meglio: nell'
-- export **non esiste una colonna** per quel ruolo. Le 22 righe che lo scrivono
-- nella mansione sono l'unica traccia che il gestionale ne porti.
--
-- Questa migrazione arriva **prima** dell'import delle nomine, e non per caso: e
-- l'ultima finestra in cui una misura cambia un progetto invece di riparare un
-- danno. L'ATECO lo stiamo contando a valle di quattro anni di celle incollate.
--
-- ============================================================================
--  PERCHE NON E UNA TABELLA DI ALIAS, CHE ERA LA MOSSA OVVIA
-- ============================================================================
--
-- `corso_alias` esiste perche «il titolo stampato su un attestato di terzi e per
-- natura un alias e non un'identita», e 29 forme scritte a mano sembrano chiedere
-- lo stesso trattamento: una tabella `testo -> ruolo` e via.
--
-- **Ma le 22 forme dell'RSPP non sono 22 modi di scrivere «RSPP».** Sono frasi che
-- asseriscono **due fatti indipendenti** — quale incarico, e chi e la persona:
--
--   RSPP/titolare                          RSPP + e il titolare    -> art. 34
--   RSPP- DL                               RSPP + e il datore      -> art. 34
--   RSPP- NO TITOLARE                      RSPP + NON e il titolare-> art. 32
--   RSPP ESTERNO                           RSPP + e di fuori       -> art. 32
--   AMMINISTRATORE/DATORE DI LAVORO/RSPP   RSPP + e il datore      -> art. 34
--
-- Il ruolo non e il testo: e la **combinazione**. Una tabella `testo -> ruolo`
-- funziona sulle 29 di oggi, si rompe sulla trentesima, e soprattutto **seppellisce
-- la ragione**: chi legge `RSPP/titolare -> datore_lavoro_rspp` non sa se sia una
-- regola o un giudizio preso a mano su quella stringa, e non ha modo di scoprirlo.
--
-- La `0002` descrive **gia questo fallimento** e lo attribuisce alla forma:
--
--   «se un codice sconosciuto arriva e la mappa e in tabella, l'import si ferma e
--   lo dice; se la mappa e in un `switch`, qualcuno ci mette il caso mancante a
--   mano — **ed e cosi che `dl_rspp` e diventato `rspp` su 26 righe**.»
--
-- Una tabella di alias e un `switch` in tabella: stessa opacita, indice migliore.
-- E qui lo stesso errore vale **85 righe** invece di 26 — vedi sotto.
--
-- Quindi tre tabelle e non una:
--
--   `ruolo_testo`         cosa c'era scritto, verbatim, e cosa dice della PERSONA
--   `ruolo_testo_parola`  quali incarichi quella frase NOMINA (uno o due)
--   `ruolo_da_parola`     la REGOLA: (incarico, posizione) -> ruolo. Nove righe.
--
-- Il dizionario registra, la regola decide, e la regola si legge in nove righe
-- invece che in un `case`.
--
-- ============================================================================
--  QUANTO VALE SBAGLIARE: 85 RIGHE, E SI SBAGLIA NEI DUE VERSI
-- ============================================================================
--
-- Delle 91 righe che scrivono «RSPP» nella mansione, **85 aggiungono di proprio
-- pugno che la persona e titolare, socio o datore**, e **3 dicono espressamente che
-- non lo e**. Il testo libero distingue i due casi in 88 su 91; la colonna «RSPP»
-- del gestionale porta una data e non li distingue in nessuno.
--
-- **Il testo libero dice piu della colonna, non meno**, ed e un fatto contro-
-- intuitivo che vale la pena scrivere: qui il campo non vincolato ha conservato
-- un'informazione che il campo strutturato ha perso.
--
-- Mandare quelle 85 righe su `rspp` sbaglierebbe **due volte insieme**:
--
--   in eccesso   pretenderebbe i moduli professionali A + B + C — 28 + 48 + 24 ore
--                — da 85 persone che non li devono;
--   in difetto   non pretenderebbe il percorso dell'art. 34 — `DL_RSPP_COMUNE` e
--                `DL_RSPP_SETTORE` — che invece devono.
--
-- E la `0006` ha le righe per tutti e due i percorsi, quindi la `corso_assolve`
-- funzionerebbe **perfettamente** producendo il risultato sbagliato. Un motore
-- corretto alimentato da una nomina sbagliata non si accorge di niente: e la
-- ragione per cui AppSopralluoghi scrive, nel proprio `STATO.md`, che **«una nomina
-- che punta al ruolo sbagliato e peggio di una nomina mancante»**.
--
-- ============================================================================
--  LA CHIAVE DI CONFRONTO STA IN UNA COLONNA, E NON E IL TESTO
-- ============================================================================
--
-- Terza lezione in due giorni sullo stesso tema, e questa l'ha pagata il dizionario
-- dei corsi. AppSopralluoghi, misurando le durate dei confinati (`b0f630c`), ha
-- trovato che **nove titoli del catalogo del gestionale hanno uno SPAZIO DOPPIO**
-- dove `corso_alias` ne ha uno solo — `CORSO PER ADDETTI  AI LAVORI...`. Due dei
-- dieci alias che stava misurando erano fra quei nove, e al primo passaggio
-- risultavano **assenti dal catalogo**: la risposta sarebbe stata «due titoli non
-- esistono», che e falsa.
--
-- Le altre due della serie: la pipeline di AppFormazione **cancella** i caratteri
-- non ASCII (`ATTIVITA'` -> `ATTIVIT`) dove chi usa `unaccent` li traslittera, e
-- dieci titoli su 180 sparivano; e il CAP `37054` nella cella ATECO di SHAMS, dove
-- il primo gruppo di cifre non e il codice.
--
-- **La regola che ne esce, e che questa tabella applica invece di descriverla: il
-- testo che si conserva e la chiave con cui si confronta sono due colonne diverse.**
-- Tenerne una sola costringe a scegliere fra perdere la forma — e con essa il
-- refuso `TITOLRE`, il plurale `Datori`, la negazione `NO TITOLARE` — e non trovare
-- piu niente.
--
-- Qui `testo` e verbatim e `chiave` e generata: via ogni carattere non ASCII, via
-- ogni carattere non alfanumerico, spazi compresi. `RSPP- titolare`, `RSPP -
-- Titolare` e `RSPP  -  titolare` cadono sulla stessa chiave e restano tre righe.
--
-- **E `corso_alias` questa separazione non ce l'ha**, e il suo commento dichiara
-- `testo` «come lo emette l'origine, verbatim» quando per almeno nove titoli su 268
-- l'origine emette uno spazio doppio e noi ne teniamo uno solo. Non si corregge
-- qui: quella tabella e stata caricata e misurata, e la `0004` non si tocca. Sta
-- scritto nel programma, e i nove titoli sono chiesti verbatim.
--
-- ============================================================================
--  LE SEI POSIZIONI, E PERCHE `non_dichiarato` NON E UN VALORE DI COMODO
-- ============================================================================
--
-- 29 forme su 160 righe vuol dire **una riga su cinque scritta in modo nuovo**. Una
-- lettura che non puo dire «non ho capito» su un campo cosi ignora in silenzio, e
-- ignorare in silenzio e il difetto che questo repo ha gia incontrato due volte —
-- nel `null` di `oreModuloSettore`, che vuol dire insieme «nessun modulo dovuto» e
-- «non conosco la divisione», e nell'alias senza destinazione della `0004`, dove
-- «conosciuto e non mappabile» sarebbe stato indistinguibile da «non ancora
-- curato».
--
-- Qui l'ignoranza non ha bisogno di una colonna: **e l'assenza di una riga in
-- `ruolo_da_parola`**, e si vede perche il testo e conservato. Sono 7 righe su 168,
-- e sono due casi diversi che e giusto non risolvere:
--
--   `SOCIO/RSPP`, `SOCIO/ RSPP` (4 righe) — essere socio **non stabilisce** di
--     essere il datore di lavoro. In una ditta individuale titolare e datore
--     coincidono; in una societa di persone no, e i dati non dicono quale sia.
--     Sotto A7 non si sceglie: si chiede.
--   `RSPP` secco e `DIRETTORE TECNICO, RSPP E COMMERCIALE` (3 righe) — non dicono
--     niente della posizione, e senza quella «RSPP» non ha un significato solo.
--
-- Restano **161 righe su 168 risolte, il 96%**, e le 7 non risolte sono nominabili
-- una per una — che e il punto: un buco che si sa elencare non e un buco.

-- ============================================================================
--  IL DIZIONARIO: 29 testi, come sono stati scritti
-- ============================================================================

create table ruolo_testo (
  -- Verbatim, come sta nella cella. Il refuso `TITOLRE`, il plurale `Datori di
  -- Lavoro` su una riga sola, lo spazio dopo la barra: sono il dato, non rumore.
  testo text primary key,
  -- Generata, e serve solo a confrontare. Mai da mostrare, mai da esportare:
  -- `RSPPTITOLARE` non e un testo che qualcuno abbia scritto.
  chiave text not null,
  -- Cosa la frase dice della PERSONA, non dell'incarico. E il secondo fatto, ed e
  -- quello che la colonna del gestionale non porta.
  posizione text not null
    constraint posizione_nota check (posizione in (
      'datore',          -- lo dice con quelle parole: «Datore di Lavoro», «DL»
      'titolare',        -- «titolare», «amministratore»
      'socio',           -- socio e basta: NON stabilisce che sia il datore
      'non_titolare',    -- lo nega: «RSPP- NO TITOLARE»
      'esterno',         -- «RSPP ESTERNO»
      'non_dichiarato'   -- la frase non ne parla
    )),
  righe int not null check (righe > 0),
  note text
);

comment on table ruolo_testo is
  'I 29 modi in cui un ruolo di sicurezza e stato scritto dentro il campo «mansione» del gestionale, misurati su 3.501 righe persona l''11 settembre 2026. Non e una tabella di traduzione: registra cosa c''era scritto. La traduzione e in `ruolo_da_parola`.';
comment on column ruolo_testo.chiave is
  'Forma di confronto: via i caratteri non ASCII, via i non alfanumerici, spazi compresi. Esiste come colonna separata perche il testo che si conserva e la chiave con cui si confronta sono due cose diverse — nove titoli di `corso_alias` hanno insegnato che tenerne una sola costringe a scegliere fra perdere la forma e non trovare piu niente.';
comment on column ruolo_testo.posizione is
  'Il secondo fatto della frase. «RSPP» da solo non decide fra l''art. 32 e l''art. 34: lo decide questa colonna, ed e l''informazione che la colonna «RSPP» del gestionale non porta in nessuno dei suoi casi.';

insert into ruolo_testo (testo, chiave, posizione, righe, note) values
  -- ---------- RSPP + il titolare: 72 righe su 160, il gruppo che pesa ----------
  ('RSPP/titolare',                        'RSPPTITOLARE',              'titolare', 37, null),
  ('RSPP- titolare',                       'RSPPTITOLARE',              'titolare', 14, null),
  ('RSPP/Titolare',                        'RSPPTITOLARE',              'titolare', 11, null),
  ('TITOLARE/RSPP',                        'TITOLARERSPP',              'titolare',  2, null),
  ('TITOLARE- RSPP',                       'TITOLARERSPP',              'titolare',  2, null),
  ('RSPP/TITOLARE',                        'RSPPTITOLARE',              'titolare',  1, null),
  ('RSPP/ Titolare',                       'RSPPTITOLARE',              'titolare',  1, null),
  ('TITOLARE - RSPP',                      'TITOLARERSPP',              'titolare',  1, null),
  ('SOCIO - TITOLARE - RSPP',              'SOCIOTITOLARERSPP',         'titolare',  1,
   'Dice socio E titolare. Vince `titolare`, che e il fatto piu forte: chi e titolare e il datore, chi e solo socio non necessariamente.'),
  ('TITOLRE/RSPP',                         'TITOLRERSPP',               'titolare',  1,
   'Refuso conservato. Se si normalizzasse il testo invece della chiave, questa riga non esisterebbe e nessuno saprebbe che il gestionale accetta un titolare scritto storto.'),
  ('TITOLARE ASPP e RSPP',                 'TITOLAREASPPERSPP',         'titolare',  1,
   'Due incarichi in una frase, ed e uno dei due casi che hanno fatto scartare il disegno a una colonna sola: con una `posizione` a valori chiusi si sarebbe dovuto perdere l''ASPP o spezzare la persona in due. Due righe in `ruolo_testo_parola` sono la lettura giusta, non il ripiego.'),

  -- ---------- RSPP + lo dice datore: 9 righe, e cinque forme su cinque ----------
  ('RSPP - Datori di Lavoro',              'RSPPDATORIDILAVORO',        'datore',    3,
   'Plurale su una riga di persona singola: e una formula del compilatore, non due persone.'),
  ('RSPP - Datore di Lavoro',              'RSPPDATOREDILAVORO',        'datore',    2, null),
  ('RSPP- DL',                             'RSPPDL',                    'datore',    2,
   '`DL` sciolto in «datore di lavoro»: e l''unica abbreviazione del gruppo, e il fatto che ce ne sia una sola e una misura della varieta, non un dettaglio.'),
  ('DATORE DI LAVORO- RSPP',               'DATOREDILAVORORSPP',        'datore',    1, null),
  ('AMMINISTRATORE/DATORE DI LAVORO/RSPP', 'AMMINISTRATOREDATOREDILAVORORSPP', 'datore', 1,
   'Tre segmenti, due incarichi. L''altro caso che ha fatto scartare il disegno a una colonna sola.'),

  -- ---------- RSPP e NON il titolare: 3 righe, e sono le piu preziose ----------
  ('RSPP- NO TITOLARE',                    'RSPPNOTITOLARE',            'non_titolare', 1,
   'Una negazione scritta a mano in un campo di testo libero. Non e rumore: e la persona che compilava che ha sentito il bisogno di distinguere, ed e la prova che la distinzione conta anche per chi sta dall''altra parte.'),
  ('RSPP ESTERNO',                         'RSPPESTERNO',               'esterno',   2,
   'La 0002 dice dell''RSPP: «spesso esterno, va chiesto se sia interno prima di aspettarselo fra i dipendenti». Qui l''origine lo dichiara da se.'),

  -- ---------- RSPP e non si sa: 7 righe che questa migrazione NON risolve ----------
  ('SOCIO/RSPP',                           'SOCIORSPP',                 'socio',     2,
   'Socio non vuol dire datore. In una ditta individuale coincidono, in una societa di persone no, e i dati non dicono quale sia: `ruolo_da_parola` non ha una riga per questo caso, ed e voluto.'),
  ('SOCIO/ RSPP',                          'SOCIORSPP',                 'socio',     2,
   'Stessa chiave della precedente, riga distinta: due modi di scriverlo che il dizionario conserva e il confronto unisce.'),
  ('RSPP',                                 'RSPP',                      'non_dichiarato', 2,
   'Il caso in cui il campo libero NON dice piu della colonna. Due righe su 91.'),
  ('DIRETTORE TECNICO, RSPP E COMMERCIALE','DIRETTORETECNICORSPPECOMMERCIALE', 'non_dichiarato', 1,
   'Direttore tecnico non e il datore e non lo esclude. Tre incarichi aziendali di cui uno solo e di sicurezza.'),

  -- ---------- il datore da solo: 15 righe, e non ha una colonna dove stare ----------
  ('DATORE DI LAVORO',                     'DATOREDILAVORO',            'datore',   15,
   'Nell''export **non esiste una colonna** per il datore di lavoro: queste 15 righe piu le 7 che lo nominano insieme all''RSPP sono l''unica traccia che il gestionale ne porti. Il campo libero non e qui un ripiego di chi compilava: e l''unico posto disponibile.'),

  -- ---------- preposto: 6 righe, e la posizione non c'entra ----------
  ('PREPOSTO',                             'PREPOSTO',                  'non_dichiarato', 2, null),
  ('Preposto- Supervisore',                'PREPOSTOSUPERVISORE',       'non_dichiarato', 2, null),
  ('PREPOSTO- Operaio',                    'PREPOSTOOPERAIO',           'non_dichiarato', 1, null),
  ('GOVERNANTE- PREPOSTO',                 'GOVERNANTEPREPOSTO',        'non_dichiarato', 1,
   'Le quattro forme del preposto hanno tutte la stessa struttura — mestiere + incarico — e nessuna nomina la posizione. Per il preposto la posizione e irrilevante, e infatti la regola non la guarda.'),

  -- ---------- antincendio e dirigente: una forma ciascuno ----------
  ('ADD. ANTINCENDIO',                     'ADDANTINCENDIO',            'non_dichiarato', 47,
   'Quarantasette righe, **una sola societa** (CROCE VERDE) e una sola forma. Non e una convenzione diffusa del gestionale: e l''abitudine di chi ha compilato quella scheda. Un numero grande che descrive una persona sola, ed e la ragione per cui questa tabella porta `righe` — senza, 47 sembrerebbe una misura di diffusione.'),
  ('DIRIGENTE',                            'DIRIGENTE',                 'non_dichiarato', 1, null);

-- ============================================================================
--  LE ASSERZIONI: quali incarichi ogni frase nomina
-- ============================================================================
--
-- Cinque frasi su 29 ne nominano **due**, ed e la ragione per cui questa tabella
-- esiste separata: la somma per incarico fa 34 dove le frasi distinte sono 29, e
-- la differenza di cinque non e un errore di conteggio — sono cinque persone a cui
-- il gestionale attribuisce due cose in una riga.

create table ruolo_testo_parola (
  testo text not null references ruolo_testo(testo) on delete cascade,
  -- L'incarico **nominato**, non il ruolo risolto. `rspp` qui vuol dire «la frase
  -- contiene la parola RSPP», non «questa persona e l'RSPP dell'art. 32».
  parola text not null
    constraint parola_nota check (parola in (
      'rspp', 'aspp', 'datore_lavoro', 'preposto', 'dirigente', 'addetto_antincendio'
    )),
  primary key (testo, parola)
);

comment on table ruolo_testo_parola is
  'Quali incarichi una frase nomina. Separata da `ruolo_testo` perche cinque frasi su 29 ne nominano due: «TITOLARE ASPP e RSPP» e «AMMINISTRATORE/DATORE DI LAVORO/RSPP» non sono ambigue, sono doppie, e una riga sola costringerebbe a perderne meta.';

insert into ruolo_testo_parola (testo, parola) values
  ('RSPP/titolare', 'rspp'), ('RSPP- titolare', 'rspp'), ('RSPP/Titolare', 'rspp'),
  ('TITOLARE/RSPP', 'rspp'), ('TITOLARE- RSPP', 'rspp'), ('RSPP/TITOLARE', 'rspp'),
  ('RSPP/ Titolare', 'rspp'), ('TITOLARE - RSPP', 'rspp'), ('SOCIO - TITOLARE - RSPP', 'rspp'),
  ('TITOLRE/RSPP', 'rspp'), ('TITOLARE ASPP e RSPP', 'rspp'),
  ('RSPP - Datori di Lavoro', 'rspp'), ('RSPP - Datore di Lavoro', 'rspp'),
  ('RSPP- DL', 'rspp'), ('DATORE DI LAVORO- RSPP', 'rspp'),
  ('AMMINISTRATORE/DATORE DI LAVORO/RSPP', 'rspp'),
  ('RSPP- NO TITOLARE', 'rspp'), ('RSPP ESTERNO', 'rspp'),
  ('SOCIO/RSPP', 'rspp'), ('SOCIO/ RSPP', 'rspp'), ('RSPP', 'rspp'),
  ('DIRETTORE TECNICO, RSPP E COMMERCIALE', 'rspp'),
  -- le cinque seconde asserzioni
  ('TITOLARE ASPP e RSPP', 'aspp'),
  ('RSPP - Datori di Lavoro', 'datore_lavoro'),
  ('RSPP - Datore di Lavoro', 'datore_lavoro'),
  ('DATORE DI LAVORO- RSPP', 'datore_lavoro'),
  ('AMMINISTRATORE/DATORE DI LAVORO/RSPP', 'datore_lavoro'),
  -- gli incarichi che stanno da soli
  ('DATORE DI LAVORO', 'datore_lavoro'),
  ('PREPOSTO', 'preposto'), ('Preposto- Supervisore', 'preposto'),
  ('PREPOSTO- Operaio', 'preposto'), ('GOVERNANTE- PREPOSTO', 'preposto'),
  ('ADD. ANTINCENDIO', 'addetto_antincendio'),
  ('DIRIGENTE', 'dirigente');

-- ============================================================================
--  LA REGOLA: nove righe, e si leggono
-- ============================================================================
--
-- Qui sta la decisione, in un posto dove si discute invece che dentro un `case`.
-- `posizione` null vuol dire «qualunque»: per il preposto, il dirigente e l'addetto
-- antincendio la posizione della persona non cambia l'obbligo, e scrivere sei righe
-- identiche per ciascuno avrebbe nascosto proprio questo.
--
-- **Le due combinazioni che mancano mancano apposta** — `(rspp, socio)` e
-- `(rspp, non_dichiarato)` — e sono 7 righe su 168. L'assenza di una riga qui e
-- l'unico modo che questa struttura ha di dire «non lo so», e funziona perche il
-- testo e conservato: chi guardera potra vedere **quale frase** non e stata
-- risolta, non solo che qualcosa non lo e stato.

create table ruolo_da_parola (
  parola text not null,
  -- null = qualunque posizione. Non e una scorciatoia: dice che per quell'incarico
  -- la posizione **non e un discriminante**, che e un'affermazione e non un'assenza.
  posizione text,
  ruolo text not null references ruolo_sicurezza(codice),
  motivo text not null,
  constraint parola_della_regola_nota check (parola in (
    'rspp', 'aspp', 'datore_lavoro', 'preposto', 'dirigente', 'addetto_antincendio'
  ))
);

create unique index ruolo_da_parola_unico
  on ruolo_da_parola (parola, coalesce(posizione, ''));

comment on table ruolo_da_parola is
  'La regola (incarico nominato, posizione della persona) -> ruolo. Nove righe, ognuna col proprio motivo, invece di un `case` dentro l''import: la 0002 attribuisce a un `case` il difetto per cui «dl_rspp e diventato rspp su 26 righe», e qui lo stesso errore varrebbe 85 righe.';
comment on column ruolo_da_parola.posizione is
  'null = la posizione non discrimina per quell''incarico. Una combinazione **assente** non e una dimenticanza: e il modo in cui questa struttura dice «non lo so», e oggi vale 7 righe su 168 — `(rspp, socio)` e `(rspp, non_dichiarato)`.';

insert into ruolo_da_parola (parola, posizione, ruolo, motivo) values
  ('rspp', 'datore',       'datore_lavoro_rspp',
   'Art. 34: il datore che assume l''incarico in proprio. Lo dice la frase stessa, con quelle parole.'),
  ('rspp', 'titolare',     'datore_lavoro_rspp',
   'Chi si dichiara titolare e il datore di lavoro. E la lettura che regge 72 righe su 91, e concorda con la misura sull''altra popolazione: dei 28 marcati nella colonna RSPP, 26 hanno un corso da datore e ZERO hanno i moduli professionali A/B/C.'),
  ('rspp', 'non_titolare', 'rspp',
   'La frase lo nega esplicitamente. Una riga, e vale piu di molte: e l''unico caso in cui l''origine distingue i due articoli di propria iniziativa.'),
  ('rspp', 'esterno',      'rspp',
   'Art. 32, e con una conseguenza che non e di questa tabella: un RSPP esterno non e un dipendente, e la 0002 avverte di chiedere se sia interno prima di aspettarselo fra le persone dell''azienda.'),
  ('aspp', 'titolare',     'aspp',
   'L''unica riga con ASPP, e viene da una frase che nomina due incarichi. `aspp` non ha una variante da datore: l''art. 34 riguarda l''RSPP, non l''addetto.'),
  ('datore_lavoro',       null, 'datore_lavoro',
   'Art. 37 c. 7. La posizione non discrimina perche la parola **e** la posizione: chi scrive «datore di lavoro» ha gia detto chi e.'),
  ('preposto',            null, 'preposto',
   'Art. 19 e 37 c. 7-ter. Tutte e quattro le forme hanno la struttura mestiere + incarico e nessuna nomina la posizione, che per questo obbligo e irrilevante.'),
  ('dirigente',           null, 'dirigente',
   'Art. 37 c. 7.'),
  ('addetto_antincendio', null, 'addetto_antincendio',
   'Art. 46. Quarantasette righe di una societa sola: il ruolo e chiaro, la diffusione no.');

-- ============================================================================
--  LE RLS, COME LE ALTRE TRE TABELLE DI VOCABOLARIO
-- ============================================================================

alter table ruolo_testo enable row level security;
alter table ruolo_testo_parola enable row level security;
alter table ruolo_da_parola enable row level security;

create policy leggono_gli_operatori on ruolo_testo for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on ruolo_testo_parola for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on ruolo_da_parola for select to authenticated using (e_operatore());

create policy scrive_amministrazione on ruolo_testo for all to authenticated
  using (e_amministrazione()) with check (e_amministrazione());
create policy scrive_amministrazione on ruolo_testo_parola for all to authenticated
  using (e_amministrazione()) with check (e_amministrazione());
create policy scrive_amministrazione on ruolo_da_parola for all to authenticated
  using (e_amministrazione()) with check (e_amministrazione());

grant select on ruolo_testo, ruolo_testo_parola, ruolo_da_parola to authenticated;

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from ruolo_testo;                          -- 29
--   select sum(righe) from ruolo_testo;                        -- 160
--   select count(*) from ruolo_testo_parola;                   -- 34
--   select count(*) from ruolo_da_parola;                      --  9
--
--   -- le asserzioni, cioe le coppie (riga di persona, incarico):     168
--   select sum(t.righe) from ruolo_testo t
--     join ruolo_testo_parola p on p.testo = t.testo;
--
--   -- quante si risolvono, e quante no:                       161 e 7
--   select coalesce(r.ruolo, 'NON RISOLTO') as esito, sum(t.righe)
--     from ruolo_testo t
--     join ruolo_testo_parola p on p.testo = t.testo
--     left join ruolo_da_parola r
--       on r.parola = p.parola
--      and (r.posizione is null or r.posizione = t.posizione)
--    group by 1 order by 2 desc;
--
--   -- e il numero che questa migrazione esiste per non sbagliare:     81
--   -- le righe che finiscono su `datore_lavoro_rspp` invece che su `rspp`
--
-- Il 34 contro 29 e il conto che dice se la struttura e stata capita: se tornasse
-- 29, qualcuno avrebbe tenuto una riga per frase e perso cinque secondi incarichi.
--
-- Il 7 e l'altro: se tornasse 0, qualcuno avrebbe aggiunto le due regole mancanti
-- per far quadrare il conto, che e esattamente cio che la `0002` descrive quando
-- dice «qualcuno ci mette il caso mancante a mano».
