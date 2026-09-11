-- AppOverall — 0004
-- Il catalogo formativo, con la grana e la chiave decise dalla scheda 9.
--
-- La 0001 ha portato l'anagrafe, la 0002 il vocabolario dei ruoli, la 0003 ha
-- impedito alle viste di scavalcare le RLS. Questa porta lo strato formativo, ed e
-- lo strato a cui si agganciano le due tabelle che pesano: **13.215 eventi
-- formativi**. Per questo la scheda 9 bloccava la Fase 3 — non per il catalogo in
-- se, ma perche una chiave sbagliata qui si paga su tredicimila righe.
--
-- ---------- le due risposte della scheda 9 ----------
--
--   grana:   l'**obbligo**, non il corso. Il corso resta come catalogo di
--            erogazione agganciato all'obbligo che assolve, non come soggetto
--            della regola. Sulla grana e una ratifica: il motore di AppFormazione
--            ragiona per obbligo dalla `0024`, e la sua `0036` aveva gia fatto
--            `drop table requisiti` con la motivazione scritta — «la sua forma
--            legava una regola a un titolo di catalogo».
--
--   chiave:  il **codice testuale curato**, come `ruolo_applicativo` nella 0001 e
--            `ruolo_sicurezza` nella 0002.
--
--   e l'impronta `GEST-` + md5 del titolo normalizzato **smette di essere
--   un'identita e diventa la chiave di un alias**.
--
-- ============================================================================
--  QUESTA E LA RIGA DA LEGGERE PRIMA DELLE ALTRE
-- ============================================================================
--
--   `GEST-a1b2c3d4` NON E UN CODICE DI CORSO. E un'impronta calcolata dal titolo
--   del gestionale, e vive in `corso_alias` come testo di provenienza, mai come
--   identita.
--
-- La scheda 9 chiede di scriverlo qui e a chiare lettere, perche la prima persona
-- che vede `GEST-a1b2c3d4` la tratta da codice. Il motivo non e estetico ed e
-- misurato: quando la funzione di normalizzazione di AppFormazione e cambiata per
-- un `btrim` mancante (loro migrazione `0020`), **41 codici su 163 sono cambiati in
-- un colpo**, e il commento di quella migrazione dice cosa sarebbe successo senza
-- riscrittura — «la prossima promozione creerebbe 41 corsi doppi». Con una chiave
-- testuale derivata, quella riscrittura sarebbe stata una cascata su 13.215 righe.
--
-- La conclusione non e «serve un uuid». E che **una stringa derivata non puo fare
-- da identita**. Togliendola di li la cascata non si risolve meglio: smette di
-- poter accadere, perche non c'e piu niente da riscrivere — si ricalcola l'alias
-- e si rimappa.
--
-- ============================================================================
--  I 40 CODICI CURATI — ricostruiti, non ribattuti
-- ============================================================================
--
-- I codici del campo sono nostri e sono stabili: dichiarati «chiave stabile» nel
-- commento che li istituisce (`015_formazione_organigramma.sql:47`), e in 63
-- migrazioni non c'e un solo `update corso_catalogo set codice`. Persino la
-- deprecazione conserva il codice invece di cancellarlo, perche gli attestati
-- storici lo referenziano.
--
-- **Come sono arrivati qui, perche importa.** Simulazione deterministica degli
-- statement — non lettura a occhio — delle sei migrazioni che toccano
-- `corso_catalogo` in AppSopralluoghi, nell'ordine in cui vanno eseguite:
--
--   015_formazione_organigramma.sql            gli insert iniziali
--   016_formazione_datore_lavoro.sql           DATORE_LAVORO (on conflict do nothing)
--   017_allinea_catalogo_quadro_obblighi.sql   2 update + CANTIERI
--   045_catalogo_asr_2026_attrezzature.sql     le attrezzature
--   049_dl_rspp_prerequisito_e_moduli_settore  2 update, fra cui la deprecazione
--   058_catalogo_attrezzature_mancanti.sql     le attrezzature mancanti
--
-- Lo stato ereditato e quello **finale**, come nella 0002: applicare gli insert
-- senza gli update avrebbe riportato indietro `DIRIGENTE` a 16 ore (l'ASR 2025 le
-- porta a 12) e avrebbe riattivato `DL_RSPP_BASE`, deprecato dalla 049.
--
-- **Riscontro indipendente, ed e il motivo per cui questa riga si puo scrivere.**
-- La ricostruzione da 40 corsi, di cui 39 referenziati dai 268 alias e uno mai
-- usato: `ATTR_GENERICO`. Il file `supabase/seed/corso_alias.sql` — ricostruito il
-- giorno prima per un'altra strada e da un altro insieme di file — dichiarava
-- esattamente questo: «39 dei 40 codici a catalogo usati, `ATTR_GENERICO` non e
-- referenziato da nessun alias, e non e un errore: e un buco da conoscere». Due
-- ricostruzioni indipendenti che concordano su quale sia il codice orfano.
--
-- **Cosa NON e verificato**, e va detto invece di lasciarlo credere (assunzione A9
-- del programma): questa migrazione non e stata eseguita su PostgreSQL, perche su
-- questa macchina non c'e ne `psql` ne Docker. Il controllo che manca e uno solo e
-- va fatto prima di applicarla in produzione: caricare `0001` -> `0004` e poi
-- `seed/corso_alias.sql` su un database vuoto, e verificare 40 righe in `corso` e
-- 268 in `corso_alias` di cui 31 `ignorato`. Le due chiavi esterne di questa
-- migrazione sono la ragione per cui quel carico e una prova: se un codice non
-- torna, l'insert si rifiuta invece di scrivere una riga muta.
--
-- **Il confronto col database vero e cominciato e non e finito**, la sera del 10
-- settembre 2026, perche la sessione che aveva l'accesso in lettura si e chiusa.
-- Dove si riprende, senza rifare la prima meta:
--
--   fatto:      le 40 righe di questo blocco lette da `origin` e parsate con un
--               tokenizer che gestisce gli apici escapati, non con una regex —
--               40 righe, 40 codici distinti, nessuna anomalia. Per ognuna un md5
--               su una stringa canonica dei nove campi (null -> stringa vuota,
--               `attivo` -> 't'/'f')
--   da fare:    lo stesso md5 calcolato in Postgres su `corso_catalogo`, e il
--               confronto dei due elenchi di hash. Solo le righe che divergono
--               vanno guardate campo per campo:
--
--   select codice, md5(codice||'|'||coalesce(nome,'')||'|'||coalesce(categoria,'')
--     ||'|'||coalesce(ore::text,'')||'|'||coalesce(aggiornamento_mesi::text,'')
--     ||'|'||coalesce(ore_aggiornamento::text,'')||'|'||coalesce(prerequisito_codice,'')
--     ||'|'||(case when attivo then 't' else 'f' end)||'|'||coalesce(note,'')) as h
--     from corso_catalogo order by codice;
--
-- **L'unico dato che c'e non e una conferma.** `corso_catalogo` ha 40 righe nel
-- database, misurato lo stesso giorno: stesso numero di queste. Dice che non ci
-- sono codici in piu ne in meno — non dice che i contenuti coincidano. Va trattato
-- come un conteggio e non come una mezza prova: e la stessa forma della coincidenza
-- «24 e 24» che quel giorno ha ingannato entrambe le corsie per due ore.
--
-- Quindi lo «zero divergenze su 21 righe» di `figura_requisito` resta vero **per
-- quella tabella** e non si estende a questi 40 codici.
--
-- ---------- il confronto e finito, e ha trovato una cosa sola ----------
--
-- Chiuso il 10 settembre 2026 (`aa42ced` in AppSopralluoghi): **360 campi
-- confrontati, una divergenza**. Zero codici solo nel database — quindi nessuno ha
-- scritto a catalogo dall'interfaccia, e verificato **sui codici** e non sul
-- conteggio. 39 righe identiche su tutti e nove i campi.
--
-- L'unica divergenza e `DL_RSPP_BASE`, campo `note`, **un carattere**:
--
--   questa migrazione:  «DEPRECATO dalla 049 …»
--   il database:        «DEPRECATO dalla 050 …»
--
-- **Nessuno dei due ha ricostruito male.** Quella migrazione e nata come `050`, con
-- una nota che citava il proprio numero, ed e stata **applicata** in quella forma;
-- poi il file e stato rinumerato a `049`, la nota aggiornata di conseguenza, e il
-- `050` cancellato — `git log -S "DEPRECATO dalla 050"` lo mostra. Il database
-- registra **cio che e stato applicato**; il file registra **una modifica
-- successiva mai arrivata al database**.
--
-- **La decisione, che e mia e non un merge**: la nota qui non cita ne il 049 secco
-- ne il 050 secco. Dice cosa e successo e dove guardare, perche un numero di
-- migrazione di un repo destinato all'archivio (Fase 5) e un puntatore che scade, e
-- un catalogo che porta un riferimento irrisolvibile ha una nota decorativa. **E il
-- solo campo in cui questo catalogo si discosta deliberatamente da entrambe le
-- fonti**, ed e scritto qui perche non sembri una terza ricostruzione sbagliata.
--
-- **Conseguenza operativa, per chi rifara il confronto.** Rifatto con lo stesso
-- metodo, questo campo **divergera di nuovo**: e atteso, non e una regressione. Se
-- divergesse **qualcos'altro**, quella e una notizia. Una differenza attesa che non
-- porta scritto di essere attesa diventa un falso allarme al primo controllo e un
-- allarme ignorato al secondo — che e il modo in cui un controllo muore.

create table corso (
  -- Il codice curato, e non un uuid: questa tabella si legge nelle migrazioni
  -- dati e negli scarti dell'import, dove un uuid costringe a una join per
  -- capire cosa c'e scritto.
  codice text primary key,
  nome text not null,
  -- La categoria arriva dal campo cosi' com'e. **Non e l'obbligo**: `attrezzature`
  -- e una categoria sola dove la 0002 ha dodici ruoli distinti, quindi tradurla
  -- qui sarebbe indovinare. L'aggancio all'obbligo sta in `corso_assolve`, e si
  -- eredita da `figura_requisito` del campo invece di essere dedotto.
  categoria text not null,
  -- null = variabile: `LAV_SPEC` dipende dalla classe di rischio della sede, che
  -- la genera la libreria normativa (scheda 7), non questa tabella.
  ore numeric(5,1),
  aggiornamento_mesi int,
  ore_aggiornamento numeric(5,1),
  -- Nel campo era una «soft ref» dichiarata in un commento. Qui e una chiave
  -- esterna vera: verificato in ricostruzione che tutti i prerequisiti esistono a
  -- catalogo, quindi il vincolo non rompe niente e impedisce il prossimo
  -- prerequisito scritto a mano che non esiste.
  prerequisito_codice text references corso(codice),
  attivo boolean not null default true,
  note text,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger corso_updated_at before update on corso
  for each row execute function tocca_updated_at();

comment on table corso is
  'Il catalogo di erogazione: quali corsi esistono, con ore e periodicita. Non e il soggetto della regola — quello e l''obbligo, e la scheda 9 lo ratifica. Un corso deprecato resta a catalogo con `attivo = false`, perche gli attestati storici lo referenziano per codice.';
comment on column corso.codice is
  'Chiave stabile e curata a mano. Zero rinomine in 63 migrazioni del repo di partenza, ed e una stabilita pagata tenendo chiuso l''universo: i titoli che arrivano dagli attestati dei clienti nuovi sono un flusso che nessun curatore controlla, e quelli sono alias, non codici.';
comment on column corso.categoria is
  'La categoria del campo, ereditata verbatim. NON e l''obbligo: `attrezzature` qui e una categoria, in `ruolo_sicurezza` sono dodici ruoli. Serve a leggere il catalogo, non a decidere requisiti.';

insert into corso (codice, nome, categoria, ore, aggiornamento_mesi, ore_aggiornamento, prerequisito_codice, attivo, note) values
  ('AI_LIV1', 'Addetto antincendio - livello 1', 'antincendio', 4, 60, 2, null, true,
   'DM 02/09/2021. Aggiornamento 2h ogni 5 anni.'),
  ('AI_LIV2', 'Addetto antincendio - livello 2', 'antincendio', 8, 60, 5, null, true,
   'DM 02/09/2021. Aggiornamento 5h ogni 5 anni.'),
  ('AI_LIV3', 'Addetto antincendio - livello 3', 'antincendio', 16, 60, 8, null, true,
   'DM 02/09/2021. Aggiornamento 8h ogni 5 anni.'),
  ('ATTR_AMB_CONFINATI', 'Ambienti sospetti di inquinamento o confinati', 'lavori_speciali', 12, 60, 4, null, true,
   null),
  ('ATTR_AUTORIBALTABILI', 'Autoribaltabili a cingoli (art. 73)', 'attrezzature', 10, 60, 4, null, true,
   null),
  ('ATTR_CARRELLO', 'Carrello elevatore (art. 73)', 'attrezzature', 12, 60, 4, null, true,
   'Varianti: industriali semoventi, a braccio telescopico, rotativi (12-16h).'),
  ('ATTR_CARROPONTE', 'Carroponte / gru a ponte (art. 73)', 'attrezzature', 10, 60, 4, null, true,
   'Comando in cabina/pensile/radiocomandato (10-11h).'),
  ('ATTR_CMM', 'Caricatori per movimentazione materiali - CMM (art. 73)', 'attrezzature', 8, 60, 4, null, true,
   null),
  ('ATTR_CRF', 'Macchina agricola raccoglifrutta - CRF (art. 73)', 'attrezzature', 8, 60, 4, null, true,
   null),
  ('ATTR_ESCAVATORI', 'Escavatori, pale caricatrici, terne (art. 73)', 'attrezzature', 10, 60, 4, null, true,
   'Idraulici/a fune; combinato con pale/terne 16h.'),
  ('ATTR_GENERICO', 'Attrezzatura abilitante (art. 73)', 'attrezzature', null, 60, 4, null, true,
   'Carrelli/PLE/gru ecc.: ore per attrezzatura. Aggiornamento min. 4h ogni 5 anni.'),
  ('ATTR_GRU_AUTOCARRO', 'Gru su autocarro (art. 73)', 'attrezzature', 12, 60, 4, null, true,
   null),
  ('ATTR_GRU_MOBILI', 'Gru mobili (art. 73)', 'attrezzature', 14, 60, 4, null, true,
   'Modulo aggiuntivo falcone telescopico/brandeggiabile 8h.'),
  ('ATTR_GRU_TORRE', 'Gru a torre (art. 73)', 'attrezzature', 12, 60, 4, null, true,
   'Rotazione in basso/in alto; entrambe 14h.'),
  ('ATTR_LAV_ELETTRICI', 'Lavori elettrici PES/PAV/PEI (CEI 11-27)', 'lavori_speciali', 16, 60, 4, null, true,
   'Norme e lavori sotto tensione secondo mansione.'),
  ('ATTR_LAV_QUOTA', 'Lavori in quota e DPI anticaduta', 'lavori_speciali', 8, 60, 4, null, true,
   null),
  ('ATTR_PLE', 'Piattaforme di lavoro elevabili PLE (art. 73)', 'attrezzature', 10, 60, 4, null, true,
   'Con e/o senza stabilizzatori.'),
  ('ATTR_POMPE_CLS', 'Pompe per calcestruzzo (art. 73)', 'attrezzature', 14, 60, 4, null, true,
   null),
  ('ATTR_TRATT_CINGOLI', 'Trattori agricoli/forestali a cingoli (art. 73)', 'attrezzature', 8, 60, 4, null, true,
   null),
  ('ATTR_TRATT_RUOTE', 'Trattori agricoli/forestali a ruote (art. 73)', 'attrezzature', 8, 60, 4, null, true,
   null),
  ('ATTR_TRATT_RUOTE_CINGOLI', 'Trattori agricoli/forestali a ruote e a cingoli (art. 73)', 'attrezzature', 13, 60, 4, null, true,
   'Percorso congiunto dell''Allegato A (13h): non e'' la somma dei due corsi separati ATTR_TRATT_RUOTE + ATTR_TRATT_CINGOLI.'),
  ('CANTIERI', 'Modulo aggiuntivo cantieri', 'cantieri', 6, null, null, null, true,
   'Modulo aggiuntivo 6h per datore di lavoro e dirigente dell''impresa affidataria in cantieri (art. 97 c.3-ter). Termine prima applicazione 19/05/2027. Segue il ciclo di aggiornamento della figura.'),
  ('DATORE_LAVORO', 'Formazione datore di lavoro (art. 37)', 'datore_lavoro', 16, 60, 6, null, true,
   'Obbligo introdotto dall''ASR 17/04/2025 per tutti i datori di lavoro; prima applicazione entro 19/05/2027. Aggiornamento 6h ogni 5 anni. Esonero se gia'' in possesso di attestato da dirigente o da DL-RSPP. Piu'' 6h modulo cantieri se datore di lavoro dell''impresa affidataria (art. 97 c.3-ter). Distinto dal percorso DL-RSPP (art. 34).'),
  ('DIRIGENTE', 'Formazione dirigenti', 'dirigente', 12, 60, 6, null, true,
   'ASR 17/04/2025: 12h (erano 16h con accordo 2011). Aggiornamento 6h ogni 5 anni. Piu'' 6h modulo cantieri se dirigente dell''impresa affidataria (art. 97 c.3-ter).'),
  ('DL_RSPP_BASE', 'Datore di lavoro-RSPP - modulo base', 'dl_rspp', 16, 60, 6, null, false,
   'DEPRECATO nel 2026, dalla migrazione del campo che ha reso DATORE_LAVORO il prerequisito: nel repo e la `049`, ma il database la registra come `050`, il numero che il file aveva quando fu applicata (vedi il commento della 0004). Le 16h base del DL-RSPP coincidono col corso DATORE_LAVORO (art. 37) e sono il PREREQUISITO, non un modulo proprio. Conservato solo per compatibilita con attestati storici.'),
  ('DL_RSPP_COMUNE', 'Datore di lavoro-RSPP - modulo comune', 'dl_rspp', 8, 60, 8, 'DATORE_LAVORO', true,
   'Modulo comune 8h (ASR 17/04/2025). Prerequisito: corso base Datore di lavoro 16h (DATORE_LAVORO, art. 37). Aggiornamento 8h ogni 5 anni, distinto e aggiuntivo rispetto al 6h/5a del datore semplice.'),
  ('DL_RSPP_SETTORE', 'Datore di lavoro-RSPP - modulo di settore', 'dl_rspp', null, null, null, 'DL_RSPP_COMUNE', true,
   'Ore variabili per ATECO 2007: A01-02 16h, A03 12h, F 16h, C 19-20 16h; altri settori nessun modulo. Espanso dal motore in app dall ATECO del cliente. Nessun aggiornamento proprio: segue il ciclo del modulo comune.'),
  ('LAV_GEN', 'Formazione generale lavoratori', 'lavoratore', 4, null, null, null, true,
   'Parte comune, non scade di per se; l''aggiornamento quinquennale del lavoratore e'' modellato su LAV_SPEC.'),
  ('LAV_SPEC', 'Formazione specifica lavoratori', 'lavoratore', null, 60, 6, 'LAV_GEN', true,
   'Ore secondo rischio: basso 4, medio 8, alto 12. Aggiornamento 6h ogni 5 anni.'),
  ('PONTEGGI', 'Montaggio, smontaggio e trasformazione di ponteggi', 'lavori_speciali', 28, 48, 4, null, true,
   'Allegato XXI D.Lgs 81/08: vale anche per il preposto alla sorveglianza. Aggiornamento 4h ogni 4 anni.'),
  ('PREPOSTO', 'Formazione preposto', 'preposto', 12, 24, 6, 'LAV_SPEC', true,
   'ASR 17/04/2025: aggiornamento biennale 6h. Richiede la formazione da lavoratore.'),
  ('PS_BLSD_LAICO', 'BLSD laico (IRC)', 'primo_soccorso', 5, 24, 3, null, true,
   'Retraining ogni 24 mesi.'),
  ('PS_BLSD_SANITARIO', 'BLSD sanitario (IRC)', 'primo_soccorso', 8, 24, null, null, true,
   'Solo personale sanitario/soccorritori. Retraining ogni 24 mesi.'),
  ('PS_GRA', 'Addetto primo soccorso - gruppo A', 'primo_soccorso', 16, 36, 6, null, true,
   'DM 388/2003. Aggiornamento 6h ogni 3 anni.'),
  ('PS_GRBC', 'Addetto primo soccorso - gruppi B e C', 'primo_soccorso', 12, 36, 4, null, true,
   'DM 388/2003. Aggiornamento 4h ogni 3 anni.'),
  ('RLS', 'Rappresentante dei lavoratori (RLS)', 'rls', 32, 12, 4, null, true,
   'Aggiornamento annuale 4h (fino a 50 lavoratori) o 8h (oltre): verificare dimensione.'),
  ('RSPP_MOD_A', 'RSPP/ASPP - Modulo A', 'rspp_aspp', 28, null, null, null, true,
   'Propedeutico, comune a RSPP e ASPP.'),
  ('RSPP_MOD_B', 'RSPP/ASPP - Modulo B (comune)', 'rspp_aspp', 48, 60, 40, 'RSPP_MOD_A', true,
   'Aggiornamento RSPP 40h/5 anni, ASPP 20h/5 anni: verificare figura.'),
  ('RSPP_MOD_B_SETTORE', 'RSPP/ASPP - Modulo B modulo di settore', 'rspp_aspp', null, null, null, 'RSPP_MOD_B', true,
   'Ore variabili per ATECO 2007: A01-02 16h, A03 12h, F 16h, Q 86.1 e 87 12h, C 19-20 16h; altri settori nessun modulo. Espanso dal motore in app dall ATECO del cliente. Nessun aggiornamento proprio: segue il ciclo del Modulo B.'),
  ('RSPP_MOD_C', 'RSPP - Modulo C', 'rspp_aspp', 24, null, null, 'RSPP_MOD_B', true,
   'Solo per RSPP.');

-- ---------- il riscontro esterno, e i quattro buchi che ha trovato ----------
--
-- L'11 settembre 2026 queste 40 righe sono state confrontate con le **undici pagine
-- di corso** del sito di Overall — la prima fonte **esterna** al sistema, perche non
-- l'ha scritta chi ha scritto il catalogo. Dettaglio in
-- `docs/riscontro-catalogo-sito.md`.
--
-- **Nove famiglie su undici combaciano al numero**, aggiornamenti e periodicita
-- compresi, incluse le due che si sbagliano piu facilmente: il preposto a **due**
-- anni e il primo soccorso a **tre**. Quattro buchi, in ordine di conseguenza:
--
--   1. `RLS` — il sito dice aggiornamento **annuale differenziato**: 4 ore da 15 a
--      50 lavoratori, **8 oltre 50**, e sotto 15 la norma non fissa durata. Questa
--      riga ne tiene **uno solo**, il 4, quindi **dice 4 a tutti**: in un'azienda
--      sopra i 50 dichiarerebbe assolto un aggiornamento che non lo e. E una
--      conformita apparente, e il dato che serve — il numero di dipendenti — nell'
--      anagrafe **c'e** (letto su 481 delle 619 attive). Va sciolto prima che il
--      motore giudichi gli RLS.
--   2. **i corsi combinati non hanno un codice.** Carrello 12 h per tipo ma **16 h
--      per entrambi**; PLE **8 h** per una variante e 10 per il percorso completo;
--      carroponte 10 h e **11 h** con cabina e radiocomando. Qui le ore sono quelle
--      della variante combinata, quindi un attestato PLE da 8 ore risulterebbe
--      **sotto-durata** pur essendo completo. Il controllo delle durate produrra
--      divergenze che **non sono errori**: sono varianti.
--   3. `ATTR_LAV_QUOTA` — il sito e esplicito: «la norma **non fissa scadenze
--      specifiche**», i cinque anni sono **prassi** allineata ai lavoratori, e
--      l'addestramento si ripete quando cambiano dispositivi, luogo o mansione.
--      Questa riga scrive 60 mesi come qualunque altra: **una prassi presentata come
--      dato**, e sotto A7 va marcata derivata.
--   4. **manca l'accesso con funi**, 32 ore nell'allegato XXI. E combacia con una
--      misura arrivata da AppFormazione per un'altra strada: fra i sei obblighi senza
--      corso ci sono `lavori_funi` e `sorveglianza_funi`. Due fonti che non si sono
--      parlate dicono la stessa cosa — l'obbligo esiste, il corso a catalogo no,
--      perche Overall non lo eroga. E un'informazione commerciale, non un difetto.
--
-- **La terza gamba e arrivata lo stesso giorno** (`eddbb44`): le durate attese di
-- queste 40 righe contro la **distribuzione** di quelle reali su 13.348 righe di
-- export. Il sito dice cosa prevede l'accordo, questo catalogo cosa ci aspettiamo,
-- l'export cosa e stato erogato. In sintesi:
--
--   - **zero titoli dell'export fuori dal dizionario**: i 268 alias coprono tutto;
--   - `RLS` **confermato sotto-specificato**: 4 h x128 **e 8 h x31**, e le 31 sono le
--     aziende oltre i cinquanta;
--   - primo soccorso e antincendio **puliti al 100%**, dieci righe su dieci: il dubbio
--     che il sito aveva sollevato sulla triennalita era infondato, c'era gia;
--   - le **seconde durate legittime** — carrello 16 x30, escavatori 16 x32, gru torre
--     14 x22 — chiedono **un codice in piu**, non un numero diverso: sono i corsi
--     combinati, e la nota di `ATTR_ESCAVATORI` li citava gia;
--   - `PS_BLSD_SANITARIO` e invece un'**attesa sbagliata**: qui non ha aggiornamento e
--     nei dati ne ha 20 righe;
--   - `DL_RSPP_BASE` raccoglie **quattro regimi** (6/10/14 per rischio piu l'8
--     generico) su un codice **deprecato**, con 161 aggiornamenti e 166 iniziali che ci
--     mappano. Fa quello per cui la deprecazione lo aveva conservato — reggere gli
--     attestati storici — ma non ha un successore per le varianti di rischio;
--   - `DIRIGENTE` (atteso 12, reale 16 x12) e `PREPOSTO` (8 x276 e 12 x38) **non sono
--     attese sbagliate**: sono due regimi separati **nel tempo**, e la nota di
--     `DIRIGENTE` qui sopra lo dice — «erano 16h con accordo 2011». Il test e la
--     **data** degli attestati, non la loro durata.
--
-- **Cosa il riscontro non copre, e va detto:** il sito ha undici famiglie, qui ci
-- sono 40 codici. Restano senza terza fonte i tre moduli RSPP professionali, i due
-- BLSD e undici attrezzature che il sito non vende come pagina propria. Per quelle
-- valgono i due riscontri interni, non tre.

-- ============================================================================
--  IL DIZIONARIO DEGLI ALIAS — di prima classe, non una tabella di servizio
-- ============================================================================
--
-- Qui atterrano i testi che qualcun altro ha scritto: i 167 titoli del catalogo
-- del gestionale e, in prospettiva, i titoli stampati sugli attestati che un
-- cliente nuovo porta in mano. La scheda 9 lo dice in una riga che vale oltre
-- questo import: **il titolo stampato su un attestato di terzi e per natura un
-- alias e non un'identita.** Un repo che nasce con un dizionario di alias di
-- prima classe ha dove far atterrare quelle carte; uno che lega ogni titolo a
-- un'identita di catalogo si riempie di righe che non sono corsi ma modi di
-- scrivere.
--
-- **Perche non c'e una colonna `sistema`**, a differenza di
-- `ruolo_sicurezza_alias` della 0002: i 268 alias non ce l'hanno, e un titolo e un
-- titolo qualunque sia la carta su cui e stampato. La colonna servirebbe il giorno
-- in cui **lo stesso testo** debba puntare a **due corsi diversi** secondo chi
-- l'ha emesso: quel giorno si aggiunge, e sara una decisione con un caso vero
-- sotto invece di una previsione.

create table corso_alias (
  -- Il testo come lo emette l'origine, verbatim. E la chiave perche e cio che si
  -- riceve: 268 testi distinti su 268 righe, verificato sul seed.
  testo text primary key,
  -- Nullable: null vuol dire «questo testo non porta a un corso», e la ragione
  -- deve essere scritta — `ignorato` per i 31 giudizi presi a mano, o una nota.
  corso_codice text references corso(codice),
  -- I cinque giudizi che la curatela del campo ha prodotto su questi testi. Non
  -- sono flag tecnici: dicono come si legge un attestato che porta quel titolo.
  ignorato boolean not null default false,
  pregressa boolean not null default false,
  is_aggiornamento boolean not null default false,
  parziale boolean not null default false,
  evidenza_incompleta boolean not null default false,
  note text,
  -- Stessa disciplina della 0002: un alias senza destinazione ha un motivo. Senza
  -- questo vincolo «conosciuto e non mappabile» e indistinguibile da «non ancora
  -- curato», e la distinzione vivrebbe solo in un commento che nessun import legge.
  constraint alias_senza_corso_ha_un_motivo
    check (corso_codice is not null or ignorato or note is not null)
);

comment on table corso_alias is
  'Come i testi delle altre origini si leggono in questo catalogo: 268 giudizi presi a mano, non una normalizzazione automatica. Qui vive anche l''impronta `GEST-` + md5 del gestionale, come testo di provenienza e non come chiave.';
comment on column corso_alias.corso_codice is
  'null non significa «non ancora tradotto»: significa «guardato e non traducibile in un corso». Gli undici titoli che sono visite ed esami di sorveglianza sanitaria (art. 41, non art. 37) sono l''esempio: non sono corsi, e forzarli a catalogo li renderebbe adempimenti finti.';
comment on column corso_alias.is_aggiornamento is
  'Il testo dichiara un aggiornamento invece di un corso iniziale: 98 dei 268. E la distinzione che permette al motore di non contare due volte lo stesso obbligo.';

-- Il seed sta in `supabase/seed/corso_alias.sql` e si carica dopo questa
-- migrazione: 268 righe, 237 mappate su 39 codici, 31 ignorate.
--
-- ---------- e non e piu una ricostruzione non verificata ----------
--
-- Quel file e nato come **ricostruzione** dagli script e dalle migrazioni di un altro
-- repo, e si dichiarava tale: «resta da confermare contro il database vivo». L'11
-- settembre 2026 il confronto e stato fatto, e **combacia riga per riga**:
--
--   n 268 · somma delle impronte -8115840040 · ignorato 31 · is_aggiornamento 98
--   parziale 7 · pregressa 2 · evidenza_incompleta 1 · con note 1
--   codici distinti 39 · somma lunghezze dei testi 21055 · dei codici 2953
--
-- Undici valori su undici. **I 268 giudizi presi a mano sono quelli che stanno in
-- produzione**, e la qualificazione cade: non «i file dicono», ma i file **e** il
-- database.
--
-- **Il primo confronto aveva detto il contrario, ed era il confronto a essere rotto.**
-- Usava `md5(string_agg(... order by testo))`, e un digest su un'aggregazione
-- **ordinata** non e confrontabile fra sistemi: l'`order by` di PostgreSQL segue la
-- collation del database, un ordinamento in Python segue i codepoint. Misurato sulle
-- stesse 268 righe, i due ordini differiscono in **71 posizioni**, e i tre hash
-- calcolati erano tre valori diversi della stessa identica tabella. La conclusione
-- «qualcuno ha ritoccato a mano dall'interfaccia» era a un passo dall'essere scritta.
-- Vedi **A11**, che questa e la sua seconda applicazione nello stesso giorno.

-- ============================================================================
--  L'AGGANCIO ALL'OBBLIGO — la tabella che la grana richiede, e resta vuota
-- ============================================================================
--
-- La grana e l'obbligo, quindi da qualche parte deve stare **quale obbligo un
-- corso assolve**. La forma e decisa; il contenuto no, e non si inventa qui.
--
-- Le sorgenti sono **due**, e si incrociano invece di scegliere una. Le regole
-- obbligo -> corso di AppFormazione, che e il repo dove la grana e l'obbligo (loro
-- `0036`), e `figura_requisito` di AppSopralluoghi, che lega figura e corso ed e
-- stata riscritta piu volte (la 049 ne cancella una riga con una motivazione
-- precisa). Dove concordano si scrive; dove divergono diventa una riga da decidere,
-- non una media. Una sola fonte sarebbe coerente con se stessa e non per questo
-- vera — assunzione A9.
--
-- Dedurre l'aggancio dalla colonna `categoria` sarebbe invece indovinare:
-- `attrezzature` sono dodici ruoli distinti, e `altro` non e un obbligo.
--
-- Resta vuota per disciplina, non per pigrizia: una tabella vuota dichiara la
-- forma, una tabella riempita a intuito la nasconde.

create table corso_assolve (
  ruolo text not null references ruolo_sicurezza(codice),
  -- **Esattamente uno dei due.** Un obbligo si assolve con un corso preciso
  -- (`preposto` -> `PREPOSTO`) oppure con **qualsiasi corso di una categoria**
  -- (`addetto_antincendio` -> un corso della categoria `antincendio`, che sia
  -- livello 1, 2 o 3). La seconda forma non e una comodita: e il significato che
  -- la fonte porta, e copiarla come coppia sarebbe un errore di merito.
  corso_codice text references corso(codice),
  categoria text,
  -- **Una riga parziale non assolve da sola.** Viene dalla trappola simmetrica a
  -- quella di `per_categoria`, consegnata da AppFormazione l'11 settembre 2026: 7
  -- dei loro 180 titoli hanno `assolve_obbligo = false` perche sono **moduli
  -- parziali** — «MODULO AGGIUNTIVO CANTIERI», «FORMAZIONE SPECIFICA RISCHIO ALTO
  -- PARZIALE 6H 1 2». Importarli come righe piene direbbe che una persona a meta
  -- percorso e in regola.
  --
  -- Le due trappole sbagliano in direzioni opposte, e per questo servono entrambe:
  -- `categoria` senza questa colonna sbaglia **per difetto** (un rappresentante
  -- rende obbligatorio il livello 2 e dichiara scoperti gli altri); questa colonna
  -- senza `categoria` sbaglia **per eccesso** (mezzo corso chiude l'obbligo).
  parziale boolean not null default false,
  note text,
  constraint assolve_un_corso_o_una_categoria
    check ((corso_codice is not null) <> (categoria is not null)),
  -- Un parziale e sempre di un corso preciso: «meta di una categoria» non vuol
  -- dire niente.
  constraint parziale_solo_su_un_corso
    check (not parziale or corso_codice is not null)
);

-- I null non collidono fra loro in un vincolo di unicita, quindi senza questo
-- indice la stessa regola potrebbe entrare due volte.
create unique index corso_assolve_unico
  on corso_assolve (ruolo, coalesce(corso_codice, ''), coalesce(categoria, ''));

comment on table corso_assolve is
  'Quale obbligo — cioe quale riga di `ruolo_sicurezza` — un corso assolve. Vuota per scelta: si riempie incrociando il modello di AppFormazione (fonte principale, perche la grana e l''obbligo) con `figura_requisito` del campo (riscontro), non deducendola dalla categoria del corso.';
comment on column corso_assolve.categoria is
  'La famiglia che assolve l''obbligo, quando non e un corso singolo: vale **qualsiasi** corso di `corso.categoria` uguale a questo valore. **Non basta per antincendio e primo soccorso**: vedi la scheda 11 — «qualsiasi corso della categoria» accetta un livello 1 dove serve un livello 3, ed e il difetto che AppFormazione ha misurato dal proprio lato.';

-- ---------- e questa forma ha un limite noto, scritto prima di scoprirlo ----------
--
-- «Qualsiasi corso della categoria» chiude la trappola del rappresentante — non
-- dichiara piu scoperti i livelli 1 e 3 dell'antincendio — ma **ne riproduce una
-- opposta**: accetta `AI_LIV1` dove la sede richiede il livello 3. Il difetto
-- speculare, misurato l'11 settembre 2026 in AppFormazione, dove tutti gli 11 titoli
-- antincendio puntano allo stesso obbligo e il livello scritto nel testo di sei di
-- essi viene buttato via.
--
-- Non si chiude qui e non per pigrizia: chiuderlo vuol dire decidere **quale livello
-- assolve quale**, che e norma (DM 02/09/2021, DM 388/2003) e sotto A7 aspetta parte,
-- punto e pagina — e per i gruppi di primo soccorso non e nemmeno un ordinamento
-- nello stesso verso. E la **scheda 11**, aperta, e blocca il motore e non questo
-- schema. Finche e aperta, questa colonna non va usata per antincendio e primo
-- soccorso: la forma prudente e la corrispondenza esatta, che sbaglia per difetto —
-- il verso in cui un errore si vede.

-- ---------- la trappola che questa forma esiste per evitare ----------
--
-- Nel campo la stessa cosa e una colonna booleana, `figura_requisito.per_categoria`,
-- e il commento che la istituisce dice: «il requisito e soddisfatto da qualsiasi
-- corso della stessa categoria del corso indicato (es. addetto antincendio: vale
-- liv. 1/2/3)». Su 21 righe e vera **tre volte**, ed e vera esattamente dove i
-- corsi sono una famiglia:
--
--   addetto_antincendio     -> AI_LIV2        (rappresentante, non requisito)
--   addetto_primo_soccorso  -> PS_GRBC        (rappresentante)
--   operatore_attrezzatura  -> ATTR_GENERICO  (rappresentante)
--
-- Una `corso_assolve` che avesse copiato quelle coppie alla lettera avrebbe reso
-- **obbligatorio il livello 2** dell'antincendio e **dichiarato scoperti** i
-- livelli 1 e 3 — cioe avrebbe prodotto non conformita inventate su clienti in
-- regola. Il difetto sarebbe stato invisibile: la riga e formalmente corretta e la
-- coppia esiste davvero nella fonte. Segnalato dalla corsia AppSopralluoghi il 10
-- settembre 2026 leggendo il commento dello schema, non la tabella.
--
-- **E spiega il codice orfano.** `ATTR_GENERICO` e l'unico dei 40 codici che
-- nessuno dei 268 alias referenzia, e qui si vede perche: non e un corso che
-- qualcuno frequenta, e il **rappresentante della famiglia** delle abilitazioni
-- alle attrezzature. Un titolo di attestato non porta mai quel nome. Non era un
-- buco: era una riga di un altro tipo.
--
-- ---------- cosa questa tabella NON porta, e non per dimenticanza ----------
--
-- **1. La distinzione iniziale / aggiornamento.** La prima versione di questa
-- tabella aveva `is_aggiornamento` in chiave primaria. La fonte **non lo porta**:
-- `figura_requisito` ha `id, figura_codice, corso_codice, obbligatorio,
-- per_categoria, note` e nulla piu, e in quel modello la distinzione vive
-- **altrove** — su `corso`, che porta `aggiornamento_mesi` e `ore_aggiornamento`.
-- Un requisito punta a un corso, e il corso sa da se ogni quanto si rinnova.
-- Trasformare una riga di requisito in due righe di `corso_assolve` sarebbe una
-- **decisione**, non una deduzione, e sotto A7 una decisione non presa non entra
-- nelle tabelle: la colonna e uscita.
--
-- **2. `obbligatorio`.** Nella fonte e `true` su tutte e 21 le righe, e `note` e
-- `null` su tutte e 21. Due colonne che esistono e non hanno mai portato
-- informazione: ereditarle avrebbe importato la forma di una scelta mai fatta.
-- Rientrano il giorno in cui esiste un requisito **non** obbligatorio, e quel
-- giorno sara un caso vero.
--
-- **3. Le attrezzature come figure.** La domanda «quali delle dodici attrezzature
-- non hanno requisito» non ha risposta, e la risposta e piu interessante della
-- domanda: nel campo **nessuna** ce l'ha e nessuna dovrebbe averlo. Le migrazioni
-- 045 e 058 lo dichiarano — le abilitazioni non sono figure dell'organigramma —
-- e in `figura_requisito` esiste una riga sola, `operatore_attrezzatura` con
-- `per_categoria`. Le 15 figure + 12 attrezzature + 9 attivita della 0002 sono la
-- **tassonomia**; questa tabella e la regola, e non ha la stessa forma.
--
-- **Il riscontro che c'e gia, e quello che manca.** Il campo ha consegnato lo stato
-- finale di `figura_requisito` in **due letture confrontate** — ricostruita dalle
-- migrazioni e letta dal database — con **zero divergenze su 21 righe** (loro
-- `b50003f`). Non prova che le migrazioni descrivano ogni tabella: prova che il
-- **metodo** di ricostruzione funziona, e quindi che confrontare allo stesso modo
-- i 40 codici curati di questa migrazione ha senso e non e stato ancora fatto.
-- ---------- la divergenza su DATORE_LAVORO, sciolta dalle ore ----------
--
-- L'incrocio delle due fonti ha fatto emergere un disaccordo che da una sola non si
-- vedeva: i quattro testi che il dizionario del campo mette sotto `DATORE_LAVORO`
-- vanno, nel modello di AppFormazione, su **due obblighi diversi** — il corso
-- iniziale all'**art. 37**, il suo aggiornamento all'**art. 34**.
--
-- Il caso concreto: un datore con RSPP esterno che frequenta «DATORE DI LAVORO»
-- (2023) e poi «AGGIORNAMENTO DATORE DI LAVORO» (2026) risulterebbe con l'art. 37
-- **non aggiornato** e con soddisfatto un art. 34 **che non ha**. Non conforme pur
-- essendo in regola.
--
-- **Sciolto da Francesco l'11 settembre 2026 indicando le due pagine con cui Overall
-- vende i due corsi** — e il discriminante non e il titolo, sono **le ore**:
--
--   art. 37   corso 16 ore, **aggiornamento 6 ore** ogni 5 anni, prima
--             applicazione entro il **19 maggio 2027**, piu 6 ore di modulo
--             cantieri per l'impresa affidataria (art. 97 c. 3-ter).
--             ASR 17/04/2025, parte II punto 3
--   art. 34   modulo comune 8 ore piu settore (12 o 16), **aggiornamento 8 ore**
--             ogni 5 anni, decadenza del titolo a dieci anni. D.Lgs. 81/2008 art.
--             34, ASR 17/04/2025
--
-- Nel **nostro** catalogo i due aggiornamenti hanno ore diverse — qui sopra
-- `DATORE_LAVORO` ha `ore_aggiornamento` **6** e `DL_RSPP_COMUNE` ha **8** — e la
-- prima versione di questa nota ne aveva ricavato una regola di instradamento: «6
-- ore -> art. 37, 8 ore -> art. 34». **Era sbagliata, e rovesciata proprio sul 6**;
-- misurata e fermata dalla corsia AppSopralluoghi l'11 settembre 2026 (`18366ae`)
-- prima che diventasse un import.
--
-- L'export **porta** le ore (colonna «Durata Formazione», 13.350 righe, 2 vuote e
-- zero non numeriche), quindi il dato c'era. Ma le ore **non separano** i due
-- articoli:
--
--   6 ore   1.651 righe, 14 tipi distinti — il piu frequente e «Aggiornamento
--           Lavoratori 6 ore» con 1.031 righe, poi primo soccorso e preposto
--   8 ore   1.749 righe, 21 tipi distinti
--
-- E il colpo di grazia: **l'unico tipo a 6 ore che riguardi il datore e
-- «AGGIORNAMENTO R.S.P.P. DATORE DI LAVORO RISCHIO BASSO», 76 righe — che e
-- art. 34**, esattamente cio che la regola voleva mandare dall'altra parte. Nel
-- gestionale gli aggiornamenti dell'art. 34 seguono il **rischio** (6 basso, 10
-- medio, 14 alto), non il numero del nostro modello semplificato. Il 6 dell'art. 37
-- e il 6 dell'art. 34-rischio-basso **sono lo stesso numero**, e collidono proprio
-- dove la regola doveva tagliare: 76 aggiornamenti dell'art. 34 sarebbero finiti
-- nell'art. 37 in silenzio, con la riga che sembra giusta.
--
-- **Il discriminante e il TITOLO, e ce l'abbiamo gia.** I quattro tipi si
-- distinguono dal testo senza ambiguita, ed e esattamente cio che `corso_alias`
-- mappa: «AGGIORNAMENTO DATORE DI LAVORO» -> `DATORE_LAVORO`, «AGGIORNAMENTO DATORE
-- DI LAVORO **CHE SVOLGE I COMPITI DI RSPP**» -> `DL_RSPP_BASE`, «AGGIORNAMENTO
-- R.S.P.P. DATORE DI LAVORO RISCHIO *» -> `DL_RSPP_BASE`. Non serviva un
-- discriminatore nuovo: serviva **non sostituire quello che c'e con uno piu debole**.
--
-- Quindi **`DATORE_LAVORO` entra** in `corso_assolve` sull'obbligo dell'**art. 37**,
-- e la lettura di AppFormazione che mandava il titolo nudo all'art. 34 resta la
-- divergenza risolta: storicamente difendibile — prima dell'ASR 2025 l'art. 37 non
-- aveva aggiornamento — ma superata dall'esistenza di un titolo esplicito per l'art.
-- 34.
--
-- **Le ore restano utili, come controllo e non come chiave:** verificare che un
-- attestato mappato abbia la durata attesa, e **segnalare** quando non l'ha.
--
-- **E il ripiego della nomina resta, per una ragione migliore di quella per cui
-- l'avevo proposto.** Non serve perche manchino le ore — non mancano. Serve perche
-- un attestato dice cosa una persona **ha fatto** e la nomina dice cosa **deve
-- fare**: per decidere se un aggiornamento sia dovuto come art. 37 o come art. 34, la
-- fonte e la seconda. E la grana della scheda 9 — l'obbligo sta sul ruolo — applicata
-- a un caso concreto.
--
-- Nota che il gestionale distingue gia i due mondi, e pende contro la lettura per
-- titolo: esiste un testo separato ed esplicito, «AGGIORNAMENTO DATORE DI LAVORO
-- **CHE SVOLGE I COMPITI DI RSPP**», che il dizionario manda su `DL_RSPP_BASE`. Se
-- l'art. 34 ha il suo titolo, il titolo nudo probabilmente non e quello.
--
-- **L'altra meta e arrivata l'11 settembre 2026** (AppFormazione `75d10ee`,
-- `docs/08-le-regole-obbligo-corso.md` e la mappa di 180 righe). Ha una forma
-- diversa da quella del campo, e la differenza e la ragione per cui la grana
-- obbligo e quella giusta: **loro non legano il ruolo al corso.** `requisiti` (43
-- righe) lega ruolo + livello -> **obbligo**; `staging.classificazione_corsi` (180)
-- lega **titolo** -> obbligo. Quindi la traduzione verso questa tabella passa per
-- due dizionari e non per uno: i loro titoli sono **alias** (e si risolvono con
-- `corso_alias`), i loro 35 obblighi si risolvono sui 36 codici di
-- `ruolo_sicurezza`, e i codici del campo con `ruolo_sicurezza_alias` della 0002.
--
-- **La qualificazione «i file dicono» e caduta l'11 settembre 2026.** La seconda
-- lettura e stata fatta — non con Docker, che avrebbe alzato una terza ricostruzione,
-- ma con l'**SQL Editor del progetto** in sola lettura — e le quattro tabelle su cui
-- poggiano queste consegne **combaciano**: `staging.classificazione_corsi` 180 e 180,
-- `obblighi` 35 e 35, `requisiti` 43 e 43, `staging.catalogo_gestionale` 167 e 167,
-- `ruoli` 34 e 34, terza colonna vuota da entrambi i lati. Su quelle tabelle «le
-- migrazioni descrivono il database», e in quel repo nessuno poteva dirlo prima.
--
-- Resta un controllo aperto e va detto: il confronto **per `version`** e completo, il
-- confronto **per `name`** no — ed e proprio quello che troverebbe un file modificato
-- dopo essere stato applicato, cioe A10 in senso stretto.
--
-- **Il join non si puo fare da qui, ed e stato misurato invece di essere tentato.**
-- I loro 180 `titolo_norm` sono passati per la **loro** funzione di normalizzazione
-- (`staging.norm`: maiuscole, punteggiatura via, accenti via — «DELL EMERGENZA»,
-- «ATTIVIT A RISCHIO D INCENDIO»); i miei 268 alias sono il **testo grezzo** del
-- gestionale. Confrontati l'11 settembre 2026: **63 su 180 combaciano verbatim**, e
-- gli altri 117 no. A meno di spazi e maiuscole il numero non cambia: 63.
--
-- Quindi un join fatto qui reinventando la loro normalizzazione perderebbe in
-- silenzio **117 titoli su 180** — un risultato coerente con se stesso e falso, che
-- e la forma di A11. La funzione vive nel loro repo, quindi **il join e loro**: a
-- loro i miei 268 testi, a me la corrispondenza. Non si ricostruisce una funzione di
-- normalizzazione a occhio dai suoi effetti.
--
-- **Cosa NON si copia dalle 180 righe, e sono tre cose misurate:**
--
--   1. `nessuno` **non e un obbligo: e il cestino**, e ha **12 titoli** — qualita,
--      privacy, ABC rifiuti, qualifica saldatore, gli otto moduli `MV` della
--      manutenzione ferroviaria. Si escludono, non si traducono.
--   2. i **7 titoli parziali**: vedi la colonna `parziale` qui sopra.
--   3. **i due casi che rompono una traduzione 1:1**, consegnati insieme alla
--      traduzione obbligo -> ruolo (loro `5d684e6`, 34 obblighi su 34 tradotti, zero
--      codici inventati): `rspp_aspp` -> **`rspp` + `aspp`** (un obbligo loro, due
--      codici miei: condividono il modulo A e si distinguono sulle ore di
--      aggiornamento, 40 e 20 — tradurre 1:1 perde una figura); e
--      `lavoratore_generale` + `lavoratore_specifica` -> **`lavoratore`** (due
--      obblighi loro, un codice mio: la generale **non scade**, la specifica si
--      aggiorna a 60 mesi — collassarle fa scadere la generale o non fa scadere la
--      specifica).
--
--      E il fatto che rende quella tabella necessaria invece di ovvia: **il codice
--      dell'obbligo non e il codice del ruolo**. `haccp` -> `alimenti`,
--      `ponteggi_art136` -> `ponteggi`, `lavori_quota_dpi3` -> `lavori_quota`,
--      `datore_lavoro_art37` -> `datore_lavoro`, e tutte e undici le
--      `attrezzatura_*` -> `conduce_*`. Chi avesse assunto `obbligo.codice =
--      ruolo.codice` **avrebbe sbagliato su 19 righe su 34**.
--
--   4. **sei obblighi che nessun corso assolve**, e per questa tabella sono vuoti
--      **per misura**: `attrezzatura_cmm`, `attrezzatura_pompe_calcestruzzo`,
--      `attrezzatura_raccoglifrutta`, `coordinatore_sicurezza`, `lavori_funi`,
--      `sorveglianza_funi`. I primi tre sono le abilitazioni nuove dell'ASR 2025
--      (8.3.8-8.3.10): l'obbligo esiste dal 2025 e non sono mai stati erogati.
--
-- **E una conferma che vale come una decisione.** Da loro la distinzione iniziale /
-- aggiornamento **non esiste nella regola**, esattamente come nel campo: esiste a
-- valle in `corsi.tipo`, **derivata da una stringa** — `case when titolo like
-- '%AGGIORNAMENTO%'`, che sui 180 titoli da 74 e 106. E una convenzione di titolo
-- del gestionale, non un dato dichiarato. Togliere `is_aggiornamento` da questa
-- tabella era giusto, e ora lo dicono due modelli invece di uno.

-- ============================================================================
--  IL CONFINE: QUESTA MIGRAZIONE NON PORTA LA SORVEGLIANZA SANITARIA
-- ============================================================================
--
-- Va dichiarato qui, perche una rinuncia taciuta si scopre in migrazione dati.
--
-- Il 10 settembre 2026 la corsia AppSopralluoghi ha enumerato i quattro fogli di
-- `ExportExcel (4).xlsx` e ha trovato che il foglio «Visite» e **sorveglianza
-- sanitaria**: 671 visite mediche annuali, 107 biennali, 24 quinquennali, 3
-- trimestrali, 3 quadriennali, piu audiometrie, spirometrie, elettrocardiogrammi
-- e oculistiche — **808 accertamenti** gia raccolti, ognuno come coppia data +
-- scadenza. Il numero era 818 fino a poche ore dopo: il foglio ha **due righe di
-- intestazione** e ogni colonna contava la sua come un dato. La scadenza, misurata,
-- **si deriva** — 796 su 796 uguale a data + intervallo dichiarato, zero deviazioni.
--
-- E l'art. 41 del D.Lgs. 81/2008, non l'art. 37: un dominio con scadenze proprie,
-- che questo catalogo non copre. Il codice del campo lo sa gia e lo dice —
-- `formazioneImport.ts:13` scarta le visite perche «il loro posto e adempimento
-- categoria sorveglianza» — e **quel posto non e mai stato riempito**.
--
-- Non entra qui per due ragioni: non e un obbligo formativo, e la scheda 9 decide
-- la grana del catalogo dei corsi. Se debba esistere nello schema nuovo e una
-- domanda di perimetro, quindi di Francesco: posta il 10 settembre, e la risposta
-- va scritta come decisione prima che qualcuno la risolva importando 808 righe in
-- una tabella di corsi. **Decisa il 10 settembre: entra, come dominio proprio**
-- (scheda 10), quindi questa rinuncia non e piu un confine ma la prossima migrazione.

-- ============================================================================
--  Le viste, che restano l'unica superficie di lettura (PILASTRO 01)
-- ============================================================================

create view v_corso as
  select codice, nome, categoria, ore, aggiornamento_mesi, ore_aggiornamento,
         prerequisito_codice, attivo, note, updated_at
    from corso;

create view v_corso_alias as
  select a.testo, a.corso_codice, c.nome as corso_nome, a.ignorato, a.pregressa,
         a.is_aggiornamento, a.parziale, a.evidenza_incompleta, a.note
    from corso_alias a
    left join corso c on c.codice = a.corso_codice;

-- Senza questa riga PILASTRO 01 e PILASTRO 02 si annullano: una vista esegue con i
-- diritti del proprietario, quindi scavalcherebbe le RLS delle tabelle sotto. E la
-- stessa riga della 0003, e va scritta a ogni vista nuova.
alter view v_corso       set (security_invoker = on);
alter view v_corso_alias set (security_invoker = on);

-- ============================================================================
--  Le policy
-- ============================================================================
--
-- Il catalogo e una curatela: lo legge chiunque sia operatore, lo scrive
-- l'amministrazione. E la stessa soglia dell'anagrafe nella 0001, e non e una
-- scelta di comodo: l'import Excel del catalogo nel campo si rifiuta di scrivere
-- sui codici e dice perche — «la mappatura nome->codice e una curatela, non un
-- import meccanico» (`catalogoImport.ts:11-15`).

alter table corso         enable row level security;
alter table corso_alias   enable row level security;
alter table corso_assolve enable row level security;

create policy leggono_gli_operatori on corso         for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on corso_alias   for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on corso_assolve for select to authenticated using (e_operatore());

create policy scrive_amministrazione on corso for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
create policy scrive_amministrazione on corso_alias for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
create policy scrive_amministrazione on corso_assolve for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);

grant select on corso, corso_alias, corso_assolve to authenticated;
grant select on v_corso, v_corso_alias to authenticated;
