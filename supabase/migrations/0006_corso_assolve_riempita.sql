-- AppOverall — 0006
-- `corso_assolve` riempita: 31 righe, e ognuna ha due fonti o una ragione.
--
-- La 0004 ha creato questa tabella **vuota per disciplina**, e ha scritto perche:
-- «una tabella vuota dichiara la forma, una tabella riempita a intuito la
-- nasconde». Le due fonti che servivano sono arrivate l'11 settembre 2026:
--
--   fonte A · il modello di AppFormazione — `staging.classificazione_corsi`, 180
--             righe titolo -> obbligo, piu la traduzione dei 34 obblighi nei
--             codici di `ruolo_sicurezza` della 0002 (le loro consegne `docs/08`
--             e `docs/09`). E la fonte principale perche li la grana **e**
--             l'obbligo.
--   fonte B · `figura_requisito` di AppSopralluoghi, 21 righe figura -> corso,
--             confrontate riga per riga col database in produzione: zero solo
--             nelle migrazioni, zero solo nel database.
--
-- Nessuna delle due e stata presa per buona da sola. Dove concordano si scrive,
-- dove divergono la riga **non entra** ed e scritto qui sotto perche — che e la
-- regola della 0004 applicata, non riformulata.
--
-- ============================================================================
--  COME SI PASSA DA 180 TITOLI A 31 RIGHE — il giunto, e perche non e ovvio
-- ============================================================================
--
-- I loro 180 titoli e i nostri 268 alias sono lo stesso universo scritto da due
-- normalizzatori diversi, e **il confronto ingenuo perde dieci righe**:
--
--   noi:  CORSO DI FORMAZIONE ANTINCENDIO ... IN ATTIVITA' DI LIVELLO 1
--   loro: CORSO DI FORMAZIONE ANTINCENDIO ... IN ATTIVIT DI LIVELLO 1
--
-- La loro pipeline **perde i caratteri non ASCII** invece di traslitterarli:
-- `ATTIVITA'` diventa `ATTIVIT`, e l'apostrofo tipografico di `DELL'EMERGENZA`
-- diventa uno spazio. Chi normalizza con `unaccent` sul proprio lato ottiene
-- `ATTIVITA` e i due non si incontrano. Dieci titoli su 180 sparivano cosi, ed
-- **erano tutti e dieci antincendio**: una coincidenza che, letta di corsa,
-- avrebbe confermato la conclusione che gia si voleva («l'antincendio e un caso
-- a parte»). Non lo era: era il giunto rotto.
--
-- La chiave usata qui e insensibile a entrambe le normalizzazioni — via ogni
-- carattere non ASCII, via ogni carattere non alfanumerico, spazi compresi:
--
--   ATTIVITA' A RISCHIO   ->  ATTIVITAARISCHIO
--   ATTIVIT A RISCHIO     ->  ATTIVITAARISCHIO
--
-- Con quella: **180 su 180**. Ha un costo dichiarato — collassa 268 alias in 262
-- chiavi, cioe **cinque coppie** diventano indistinguibili (`R.L.S.` e `RLS`,
-- `PREPOSTI - BIENNALE` e `PREPOSTI_BIENNALE`, e tre simili). E innocuo qui, e
-- verificato invece che supposto: in tutte e cinque le collisioni i testi
-- **puntano allo stesso codice di corso**, quindi la destinazione non e mai
-- ambigua. Una chiave piu grossolana e sicura per questo uso e non per altri:
-- **non va riusata per scrivere su `corso_alias`**, dove quelle cinque coppie
-- sono cinque righe distinte con una loro storia.
--
-- ============================================================================
--  LE TRE COSE CHE LE FONTI DICEVANO DI NON COPIARE, E CHE INFATTI NON SONO QUI
-- ============================================================================
--
-- **1. Il cestino `nessuno`: 12 titoli, esclusi.** Qualita, privacy, ABC rifiuti,
-- qualifica saldatore e gli otto moduli `MV` della manutenzione ferroviaria. Non
-- e un obbligo, e un codice che dice «questo corso non assolve niente».
--
-- **2. I sette moduli parziali.** La colonna `assolve_obbligo = false` di
-- AppFormazione e la **nostra** `corso_alias.parziale`: sette righe di qua e
-- sette di la, e **sei chiavi su sei coincidono** (la settima e il modulo
-- cantieri, su cui vedi sotto). Ma qui c'e una cosa che nessuna delle due
-- consegne diceva, ed e uscita dall'incrocio:
--
--   **la parzialita sta sul titolo, non sulla coppia.** `AGGIORNAMENTO PARZIALE
--   PER LAVORATORI` e `FORMAZIONE SPECIFICA LAVORATORI` mappano **sullo stesso
--   codice** `LAV_SPEC`, e la coppia `lavoratore -> LAV_SPEC` e quindi **mista**:
--   quattro titoli parziali e quattordici pieni. Stessa forma su `rls -> RLS` e
--   su `datore_lavoro_rspp -> DL_RSPP_BASE`.
--
-- Scrivere `parziale = true` su quelle coppie direbbe che **la formazione
-- specifica non assolve l'obbligo del lavoratore** — cioe dichiarerebbe scoperti
-- tutti i lavoratori formati. La colonna `parziale` di questa tabella vale solo
-- dove il **corso intero** e un modulo che non chiude niente da solo, e nel
-- catalogo ce n'e **uno**: `CANTIERI`. Per gli altri, la distinzione resta dove
-- gia vive e dove e gia verificata contro la produzione: `corso_alias.parziale`.
--
-- Non e una limatura: e la differenza fra una colonna usata al suo livello e una
-- usata un livello troppo in alto, che e il modo in cui un flag giusto produce
-- un dato falso.
--
-- **3. I tre rappresentanti di `figura_requisito` non sono coppie.**
-- `addetto_antincendio -> AI_LIV2`, `addetto_primo_soccorso -> PS_GRBC`,
-- `operatore_attrezzatura -> ATTR_GENERICO` hanno `per_categoria = true`: sono
-- famiglie scritte col nome di un membro. Copiate alla lettera renderebbero
-- obbligatorio il livello 2 e dichiarerebbero scoperti l'1 e il 3. Non entrano.
--
-- ============================================================================
--  ANTINCENDIO E PRIMO SOCCORSO RESTANO FUORI — e la ragione non e la prudenza
-- ============================================================================
--
-- Sette codici su quaranta (`AI_LIV1/2/3`, `PS_GRA`, `PS_GRBC`, `PS_BLSD_LAICO`,
-- `PS_BLSD_SANITARIO`), quindi si scrive **sui 33 restanti**.
--
-- La 0004 lo aveva legato alla colonna `categoria`: «qualsiasi corso della
-- categoria accetta un livello 1 dove serve un livello 3». Incrociando le fonti
-- si vede che **il difetto non e della colonna `categoria`**, e della tabella:
--
--   `corso_assolve` non ha un posto dove scrivere «questo corso assolve **a
--   partire dal** livello 3». Piu righe sullo stesso ruolo si leggono in OR —
--   una qualunque basta. Quindi tre righe esatte `addetto_antincendio ->
--   AI_LIV1 | AI_LIV2 | AI_LIV3` dicono **esattamente la stessa cosa** di una
--   riga `categoria = 'antincendio'`: che il livello 1 chiude l'obbligo.
--
-- La forma esatta non e la forma prudente: e la stessa forma con piu righe. Per
-- questo non basta «tenere fuori la colonna `categoria`», e vanno tenuti fuori i
-- corsi. Lo conferma la fonte A, che misura il difetto dal proprio lato: tutti e
-- 11 i titoli antincendio puntano allo stesso obbligo, e il livello scritto nel
-- testo di sei di essi viene buttato via.
--
-- Il dato che chiuderebbe la questione esiste da entrambi i lati e **non e mai
-- stato messo accanto**: `clienti.livello_rischio_incendio` e
-- `clienti.gruppo_primo_soccorso` di AppFormazione (raccolti e mai confrontati
-- con nulla), e il livello della sede nel campo, **vuoto su 619 righe**. La
-- scheda 11 e decisa ma pretende quel livello. Finche non c'e, questa tabella
-- tace sull'emergenza, e tacere e il verso in cui l'errore si vede.
--
-- **`addetto_blsd` cade fuori con loro, e la sua ragione e piu debole.** I due
-- BLSD sono nella categoria `primo_soccorso` e la regola dei sette codici li
-- prende. Ma laico e sanitario non sono due livelli di una scala con un campo
-- vuoto sul cliente: sono due platee. E la prima riga che deve rientrare quando
-- la scheda 11 si chiude, ed e detto qui perche non si perda nel mucchio.
--
-- ============================================================================
--  LE TRE RIGHE CHE LE DUE FONTI NON SI SONO DETTE UGUALI
-- ============================================================================
--
-- Sulle **figure** entrambe le fonti possono parlare, e li l'incrocio e vero:
-- **14 coppie su 14 concordano**. Le divergenze sono tre, e nessuna e una media.
--
-- **(a) `datore_lavoro_rspp -> DATORE_LAVORO`, e sarebbe stata la riga
-- pericolosa.** La fonte A ce la porta con due titoli, e sono questi:
--
--   AGGIORNAMENTO DATORE DI LAVORO
--   AGGIORNAMENTO DATORE DI LAVORO CON MODULO AGGIUNTIVO CANTIERI
--
-- cioe **due aggiornamenti da datore semplice** classificati sotto l'obbligo
-- dell'**art. 34**. Le due varianti iniziali degli stessi titoli («DATORE DI
-- LAVORO», «DATORE DI LAVORO CON MODULO AGGIUNTIVO CANTIERI») stanno invece
-- sotto `datore_lavoro_art37`, dove ci si aspetta. La fonte B non ha niente di
-- simile: la sua `049` ha **cancellato** la riga del DL-RSPP verso il corso base.
--
-- Scritta, questa riga farebbe **chiudere l'obbligo dell'art. 34 a chi ha fatto
-- l'aggiornamento da datore dell'art. 37** — il percorso abilitante di dieci anni
-- assolto da un corso di sei ore. Non entra. La classificazione asimmetrica
-- (iniziali di qua, aggiornamenti di la) e segnalata ad AppFormazione: e da
-- guardare sul loro lato, non da compensare sul nostro.
--
-- **(b) `datore_lavoro_rspp -> DL_RSPP_BASE`: undici titoli, e non entra.** La
-- `049` del campo l'ha cancellata con la motivazione scritta — le 16 ore base
-- coincidono col corso `DATORE_LAVORO` dell'art. 37 e sono il **prerequisito**,
-- non un modulo proprio — e nel nostro catalogo quel codice e `attivo = false`.
-- Le due fonti qui divergono per una ragione **di tempo**: quegli undici titoli
-- sono attestati storici, e il codice deprecato esiste apposta per reggerli. Un
-- attestato storico e una cosa che si legge; un obbligo che si chiude e un'altra.
--
-- **(c) `preposto -> LAV_GEN` e `preposto -> LAV_SPEC`: nel campo ci sono, qui
-- no.** Non perche il preposto non debba la formazione da lavoratore: perche la
-- deve **gia due volte per altra via**. `ruolo_sicurezza.lavoratore` ha
-- `vale_per_tutti = true` — «ce l'ha chiunque abbia un rapporto di lavoro» — e
-- `corso.PREPOSTO` ha `prerequisito_codice = 'LAV_SPEC'`, che a sua volta ha
-- `LAV_GEN`. Ripeterlo qui e la terza copia della stessa regola, e la terza
-- copia e quella che un giorno dira una cosa diversa dalle altre due.
--
-- E per simmetria va detto **cosa questa ragione non giustifica**: la catena dei
-- prerequisiti *non* e un motivo per togliere `rspp -> RSPP_MOD_A` e
-- `RSPP_MOD_B`, che pure sono una catena. Li **entrambe** le fonti elencano il
-- percorso per intero, e una fonte che parla vince su un ragionamento che
-- generalizza.
--
-- ============================================================================
--  LE DUE RIGHE CHE ENTRANO CON UNA FONTE SOLA, DICHIARATE
-- ============================================================================
--
-- **`datore_lavoro_rspp -> DL_RSPP_SETTORE`** viene dalla sola fonte B. Il
-- silenzio della fonte A e **strutturale e non un dissenso**: il modulo di
-- settore ha ore variabili per ATECO e il gestionale non gli ha mai dato un
-- titolo proprio, quindi non puo comparire in un elenco di titoli. La prova che
-- questa forma e accettata da entrambe sta un rigo sopra: `RSPP_MOD_B_SETTORE`
-- **e in tutte e due**, e li un titolo per caso esiste.
--
-- **`dirigente -> CANTIERI`** non viene da nessuna delle due consegne, e viene da
-- tre affermazioni di questo repo che si reggono a vicenda: la nota di
-- `corso.CANTIERI` («modulo aggiuntivo 6h per datore di lavoro **e dirigente**
-- dell'impresa affidataria, art. 97 c. 3-ter»), la nota di `corso.DIRIGENTE` che
-- lo ripete, e l'alias `MODULO AGGIUNTIVO "CANTIERI" PER DIRIGENTE`, che esiste
-- fra i 268 verificati in produzione. E una riga `parziale`, e una riga
-- `parziale` **non puo creare una conformita**: puo solo rifiutarsi di chiudere
-- un obbligo. Sbaglia nel verso che si vede.
--
-- ============================================================================
--  E QUELLO CHE NON C'E, CONTATO INVECE CHE DIMENTICATO
-- ============================================================================
--
-- **Sedici dei 36 ruoli della 0002 non hanno nessuna riga**, e non sono un buco
-- unico: sono quattro buchi di natura diversa, e il motore deve poterli
-- distinguere prima di dichiarare qualcuno non conforme.
--
--   tre   · l'emergenza tenuta fuori qui e ora: `addetto_antincendio`,
--           `addetto_primo_soccorso`, `addetto_blsd` (scheda 11);
--   sei   · obbligo senza corso a catalogo, misurato da AppFormazione:
--           `conduce_cmm`, `conduce_pompe_calcestruzzo`,
--           `conduce_raccoglifrutta`, `coordinatore_sicurezza`, `lavori_funi`,
--           `sorveglianza_funi`. I primi tre sono le abilitazioni nuove
--           dell'ASR 2025 (punti 8.3.8, 8.3.9, 8.3.10), che Overall non eroga;
--   cinque· obbligo i cui **unici titoli sono fra i 31 `ignorato`** del nostro
--           dizionario: `diisocianati`, `fitosanitari`, `alimenti`,
--           `segnaletica_stradale`, `conduce_transpallet`. E il riscontro piu
--           pulito di tutto l'incrocio: nove titoli, nove `ignorato`, zero
--           eccezioni. Due curatele indipendenti — chi ha giudicato i 268 alias
--           e chi ha classificato i 180 titoli — hanno separato lo stesso
--           insieme senza parlarsi;
--   due   · `datore_lavoro_art16` e `medico_competente`, che al modello di
--           AppFormazione **mancano** e su cui questa tabella non decide. Il
--           campo ha `datore_lavoro_art16 -> DATORE_LAVORO` e potrebbe bastare,
--           ma se al delegato dell'art. 16 spettino gli obblighi del datore o
--           quelli del dirigente e **una domanda di norma**, non di mappatura, e
--           sotto A7 aspetta parte, punto e pagina.
--
-- **Sei dei 33 codici non compaiono**: `ATTR_GENERICO` (il rappresentante di
-- famiglia, l'unico dei 40 che nessun alias referenzia), `ATTR_CMM`, `ATTR_CRF`,
-- `ATTR_POMPE_CLS` (le tre abilitazioni ASR 2025: il corso a catalogo c'e,
-- l'attestato no), `ATTR_AUTORIBALTABILI` — che e il caso piu sottile, perche il
-- ruolo `conduce_movimento_terra` **lo nomina** nel proprio nome e nessun titolo
-- ci mappa sopra — e `DL_RSPP_BASE`, per la (b) qui sopra.
--
-- ============================================================================
--  A10: cosa e verificato e cosa no
-- ============================================================================
--
-- La fonte A e «i file dicono»: AppFormazione ha rieseguito le proprie 56
-- migrazioni su PostgreSQL 16 e **non** ha potuto confrontarle col database
-- applicato, perche l'accesso in lettura al loro progetto Supabase non ce l'ha.
-- La fonte B e confrontata con la produzione riga per riga. Il dizionario dei 268
-- alias e confrontato con la produzione su undici valori su undici.
--
-- Quindi: **le righe che nascono dalla sola fonte A portano la qualificazione di
-- quella fonte.** Sono le 14 di attrezzature e attivita, dove la fonte B tace per
-- scelta dichiarata delle sue `045` e `058` (le abilitazioni non sono figure
-- dell'organigramma). Non e un difetto di questa migrazione ed e il motivo per
-- cui e scritto qui: quando quell'accesso arrivera, sono quelle 14 le righe da
-- rileggere per prime.

insert into corso_assolve (ruolo, corso_codice, categoria, parziale, note) values

-- ---------- figure · le 14 coppie su cui le due fonti concordano ----------
  ('aspp',               'RSPP_MOD_A',         null, false, null),
  ('aspp',               'RSPP_MOD_B',         null, false, null),
  ('aspp',               'RSPP_MOD_B_SETTORE', null, false, null),
  ('rspp',               'RSPP_MOD_A',         null, false, null),
  ('rspp',               'RSPP_MOD_B',         null, false, null),
  ('rspp',               'RSPP_MOD_B_SETTORE', null, false, null),
  ('rspp',               'RSPP_MOD_C',         null, false,
   'Solo RSPP. Il modulo C non e'' dell''ASPP: lo dicono la nota del catalogo e `figura_requisito`, che non ha la riga. La fonte A ce l''avrebbe portato per artefatto della traduzione 1:N — un obbligo `rspp_aspp` diviso su due ruoli duplica tutti i titoli su entrambi — e l''incrocio e'' servito esattamente a questo.'),
  ('datore_lavoro',      'DATORE_LAVORO',      null, false, null),
  ('datore_lavoro_rspp', 'DL_RSPP_COMUNE',     null, false, null),
  ('dirigente',          'DIRIGENTE',          null, false, null),
  ('preposto',           'PREPOSTO',           null, false, null),
  ('rls',                'RLS',                null, false,
   'La coppia e'' piena: i tre titoli interi assolvono, e `AGGIORNAMENTO PARZIALE PER R.L.S.` resta parziale **sull''alias**. Nota aperta e nota qui: il catalogo tiene un solo aggiornamento (4 ore) dove la norma ne ha due — 4 fino a 50 lavoratori, 8 oltre — e nei dati reali le due durate ci sono entrambe (4h x128, 8h x31). Questa riga dice quale corso assolve, non quante ore bastano: il secondo pezzo manca ancora.'),
  ('lavoratore',         'LAV_GEN',            null, false, null),
  ('lavoratore',         'LAV_SPEC',           null, false,
   'Coppia piena malgrado quattro dei diciotto titoli siano moduli parziali: la parzialita e'' del titolo e vive su `corso_alias.parziale`. Scritta qui direbbe che la formazione specifica non assolve l''obbligo del lavoratore.'),

-- ---------- figure · la riga con una fonte sola, e il perche in tabella ----------
  ('datore_lavoro_rspp', 'DL_RSPP_SETTORE',    null, false,
   'Solo `figura_requisito`. La fonte A tace per struttura e non per dissenso: il modulo di settore ha ore variabili per ATECO ed e'' espanso dal motore, quindi il gestionale non gli ha mai dato un titolo proprio e non puo'' comparire in un elenco di titoli. La forma e'' accettata da entrambe le fonti su `RSPP_MOD_B_SETTORE`, dove un titolo per caso esiste.'),

-- ---------- i due moduli che non chiudono niente da soli ----------
  ('datore_lavoro',      'CANTIERI',           null, true,
   'Art. 97 c. 3-ter: 6 ore aggiuntive per il datore dell''impresa affidataria in cantieri. Unico corso del catalogo che e'' un modulo parziale per intero, e unico posto dove `parziale` va usata a questo livello.'),
  ('dirigente',          'CANTIERI',           null, true,
   'Stessa norma, e **nessuna delle due consegne la porta**: viene dalle note di `corso.CANTIERI` e `corso.DIRIGENTE`, che nominano entrambe il dirigente dell''impresa affidataria, e dall''alias `MODULO AGGIUNTIVO "CANTIERI" PER DIRIGENTE` che sta fra i 268 verificati. Una riga `parziale` non puo'' creare una conformita'': puo'' solo rifiutarsi di chiudere un obbligo.'),

-- ---------- attrezzature · solo fonte A, che e'' l'unica che le copre ----------
-- `figura_requisito` non ha righe per le attrezzature, e lo dichiara: le `045` e
-- `058` del campo dicono che le abilitazioni non sono figure dell'organigramma.
-- Quindi qui non c'e un secondo parere, e queste righe portano la qualificazione
-- «i file dicono» della fonte A.
  ('conduce_carrelli',        'ATTR_CARRELLO',            null, false, null),
  ('conduce_carroponte',      'ATTR_CARROPONTE',          null, false, null),
  ('conduce_gru_autocarro',   'ATTR_GRU_AUTOCARRO',       null, false, null),
  ('conduce_gru_mobili',      'ATTR_GRU_MOBILI',          null, false, null),
  ('conduce_gru_torre',       'ATTR_GRU_TORRE',           null, false, null),
  ('conduce_movimento_terra', 'ATTR_ESCAVATORI',          null, false,
   'Il ruolo nomina anche gli autoribaltabili a cingoli (ASR 2025 punto 8.3.7) e il catalogo ha `ATTR_AUTORIBALTABILI`, ma nessuno dei 180 titoli ci mappa sopra: la riga non si scrive per simmetria di nome.'),
  ('conduce_ple',             'ATTR_PLE',                 null, false, null),
  ('conduce_trattori',        'ATTR_TRATT_RUOTE',         null, false, null),
  ('conduce_trattori',        'ATTR_TRATT_CINGOLI',       null, false, null),
  ('conduce_trattori',        'ATTR_TRATT_RUOTE_CINGOLI', null, false,
   'Tre righe per un ruolo solo, e sono tre percorsi distinti dell''Allegato A: il congiunto e'' 13 ore e **non** la somma dei due separati. Qui la lettura in OR e'' quella giusta — chi ha il congiunto e'' abilitato a entrambi — ed e'' il caso che mostra che l''OR non e'' sbagliato in se: e'' sbagliato dove i corsi sono una scala, come nell''antincendio.'),

-- ---------- attivita · solo fonte A, stessa qualificazione ----------
  ('spazi_confinati',    'ATTR_AMB_CONFINATI', null, false, null),
  ('ponteggi',           'PONTEGGI',           null, false,
   'L''Allegato XXI vale anche per il preposto alla sorveglianza, che nel vocabolario e'' `sorveglianza_funi` solo per le funi: per i ponteggi il ruolo del preposto non ha una riga propria, e non e'' una dimenticanza di qui.'),
  ('lavori_quota',       'ATTR_LAV_QUOTA',     null, false,
   'La periodicita'' di 60 mesi su questo corso e'' **prassi e non norma** — il riscontro col sito dell''11 settembre lo dice esplicito: «la norma non fissa scadenze specifiche». Questa riga dice quale corso assolve; quando il motore ne leggera'' la scadenza, quella va marcata derivata.'),
  ('rischio_elettrico',  'ATTR_LAV_ELETTRICI', null, false, null);

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from corso_assolve;                             -- 31
--   select count(*) from corso_assolve where parziale;               --  2
--   select count(*) from corso_assolve where categoria is not null;  --  0
--   select count(distinct ruolo) from corso_assolve;                 -- 20
--   select count(distinct corso_codice) from corso_assolve;          -- 27
--   select count(*) from corso_assolve a join corso c
--     on c.codice = a.corso_codice
--    where c.categoria in ('antincendio', 'primo_soccorso');         --  0
--   select count(*) from corso_assolve a join corso c
--     on c.codice = a.corso_codice where not c.attivo;               --  0
--
-- Lo zero sulla colonna `categoria` non e un caso: **nessuna riga di questa
-- migrazione la usa**. Quella colonna esiste per la forma «qualsiasi corso della
-- famiglia», e le uniche famiglie del catalogo sono antincendio e primo
-- soccorso, che restano fuori. Il primo uso di `categoria` sara la scheda 11, e
-- avra bisogno di una cosa che oggi la tabella non ha — un modo per dire «della
-- categoria, ma non sotto il livello N».
--
-- Lo zero sui corsi non attivi e il controllo che tiene ferma la decisione (b):
-- se un giorno torna `1`, qualcuno ha rimesso `DL_RSPP_BASE` a chiudere un
-- obbligo.
