-- AppOverall — 0020
-- La nomina porta da dove viene: `origine`, `origine_testo` e `note`, prima che la migrazione dati le perda.
--
-- ============================================================================
--  PERCHE ESISTE
-- ============================================================================
--
-- Il passo `03` della migrazione dati porta le nomine di AppSopralluoghi, e la loro
-- `nomina` ha tre colonne che la nostra non ha. Lette sul loro `origin/main` il 15
-- settembre 2026, non a memoria:
--
--   origine        `068`, allargata dalla `070`: colonna, mansione, qualifica, manuale
--   origine_testo  `068` e `070`: il testo verbatim da cui la nomina e dedotta
--   note           `015`: testo libero
--
-- Le altre due colonne che la loro nomina ha e la `0001` no le hanno gia portate la
-- `0002` (`estremi_procura`) e la `0010` (`posizione`), con una ragione che vale
-- identica qui: «se non la si apre qui, il codice passa il vincolo e il suo unico
-- attributo distintivo viene scartato dall'import — e lo si scopre quando serve».
-- Senza queste tre colonne il passo `03` avrebbe due scelte, tutte e due sbagliate:
-- scartarle in silenzio, o non partire mai.
--
-- ============================================================================
--  ORIGINE: DICHIARATA O INTERPRETATA
-- ============================================================================
--
-- La loro `068` lo dice meglio di come lo direi io: «una nomina letta dalla colonna
-- e DICHIARATA: porta una data di incarico. Una dedotta da "RSPP/titolare" e
-- INTERPRETATA da una regola. Non hanno lo stesso peso quando qualcuno dovra
-- fidarsene».
--
-- **E `posizione` non la sostituisce.** `posizione` dice cosa la frase dice della
-- persona, ed e null per tutte le nomine che non vengono da un testo: quelle dalla
-- colonna, con la loro data, e quelle di cui nessuno ha registrato niente. Null in
-- `posizione` non distingue le due cose; `origine` si.
--
-- **Il null di `origine` va letto per quello che e, e non e «anteriore alla 068»**,
-- come dice il commento di la. Da loro `origine` la scrivono solo l'import delle
-- nomine e gli script del 15 settembre: la scheda dell'organigramma (`salvaNomina`,
-- `src/lib/admin/formazione.ts`) e l'import della formazione, che crea i lavoratori
-- (`formazioneImport.ts`), **non la scrivono**, e il valore `manuale` che il loro
-- vincolo ammette oggi non lo emette nessun codice. Quindi null vuol dire «l'origine
-- non ha registrato da dove viene», anche per le nomine messe a mano dopo la `068`.
-- Qui non diventa `manuale`: sarebbe dichiarare una provenienza che nessuno ha
-- scritto.
--
-- ============================================================================
--  NOTE: DOVE STA IL PERCHE DI UN RUOLO
-- ============================================================================
--
-- `note` sembra un campo di servizio, e sulle nomine di oggi non lo e. Le `dl_rspp`
-- scritte dagli script del 15 settembre (20 dalla colonna RSPP, 7 dai testi, e le 5
-- delle risposte di Francesco) portano li **la ragione per cui il ruolo e quello**:
-- «la persona ha un attestato da datore di lavoro RSPP. Decisione di Francesco,
-- 15.09.2026». E per quelle dai testi — «RSPP» secco, «SOCIO/RSPP», «RSPP-SOCIO» — il
-- dizionario della `0007` **non ricava** `datore_lavoro_rspp`: sono le combinazioni
-- che lascia fuori apposta. Senza la nota, di qua sarebbero nomine dedotte da un
-- testo che contraddicono la regola, e nessuno saprebbe piu perche.
--
-- ============================================================================
--  UN CHECK, E NON UN VOCABOLARIO COME NELLA 0010
-- ============================================================================
--
-- La `0010` ha tolto una lista da un `check` perche serviva a **due colonne**, e due
-- `check` identici sono due copie. Qui la lista serve a una colonna sola, e il
-- significato dei quattro valori sta nel commento della colonna. Il giorno in cui
-- servira a una seconda, diventa una tabella per la stessa ragione della `0010`.
--
-- Il secondo vincolo lega il testo all'origine, nei due versi: una nomina dedotta
-- da un testo **ha** il testo, e un testo sta **solo** accanto a una nomina dedotta.
-- E la frase del loro commento — «null quando origine non e mansione o qualifica» —
-- scritta dove un import la legge invece che dove una persona la ricorda.

alter table nomina
  add column origine text
    constraint nomina_origine_nota
    check (origine is null or origine in ('colonna', 'mansione', 'qualifica', 'manuale')),
  add column origine_testo text,
  add column note text;

alter table nomina
  add constraint nomina_testo_solo_se_dedotta
    check ((origine_testo is not null) = coalesce(origine in ('mansione', 'qualifica'), false));

comment on column nomina.origine is
  'Da dove viene la nomina, con i valori di AppSopralluoghi (`068`, `070`): `colonna` = dichiarata in una colonna di ruolo del foglio, e porta la data dell''incarico; `mansione` o `qualifica` = **dedotta** dal testo libero di quella colonna con il dizionario, e senza data; `manuale` = inserita a mano. **Null vuol dire «l''origine non l''ha registrato»**, non «anteriore alla 068»: la scheda dell''organigramma e l''import della formazione di la non scrivono questa colonna. Non si azzera mai: descrive un fatto, non un compito.';
comment on column nomina.origine_testo is
  'Il testo **verbatim** da cui la nomina e dedotta, com''era nella loro colonna — in maiuscolo, perche cosi lo scrive il loro import. C''e se e solo se `origine` e `mansione` o `qualifica`. Conserva anche cio che il dizionario non traduce: «RSPP ESTERNO», «SOCIO/RSPP».';
comment on column nomina.note is
  'Testo libero, portato dall''origine alla lettera. **Non e un campo di servizio**: sulle `dl_rspp` scritte a mano il 15 settembre 2026 dice perche il ruolo e quello — l''attestato da datore RSPP, la decisione di Francesco — anche dove il dizionario, dallo stesso testo, non lo ricava.';

-- ---------- e si vede, perche l'applicazione non nomina una tabella ----------
--
-- PILASTRO 01, e la stessa riga della `0010`: una colonna che non entra in una vista
-- e, per chi la deve usare, una colonna che non esiste. Le tre nuove vanno in coda,
-- perche `create or replace view` accetta colonne solo in fondo.

create or replace view v_organigramma with (security_invoker = true) as
select n.id, n.cliente_id, c.ragione_sociale, n.sede_id, s.denominazione as sede,
       n.persona_id, p.cognome, p.nome, p.codice_fiscale,
       n.ruolo, n.data_nomina, n.updated_at,
       r.nome as ruolo_nome, r.tipo as ruolo_tipo, r.norma as ruolo_norma,
       n.posizione, pp.nome as posizione_nome, pp.cambia_l_esito as posizione_cambia_l_esito,
       n.estremi_procura,
       n.origine, n.origine_testo, n.note
  from nomina n
  join cliente c on c.id = n.cliente_id
  join persona p on p.id = n.persona_id
  join ruolo_sicurezza r on r.codice = n.ruolo
  left join sede s on s.id = n.sede_id
  left join posizione_persona pp on pp.codice = n.posizione
 where n.data_cessazione is null;

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from nomina;                                        -- 0, nessuna riga
--   select count(*) from pg_constraint
--    where conrelid = 'nomina'::regclass
--      and conname in ('nomina_origine_nota', 'nomina_testo_solo_se_dedotta');   -- 2
--
-- E dopo il passo `03`, quelli che dicono se le colonne sono state **scritte** — la
-- trappola della `0010`, dove un conto a zero puo voler dire «nessuno» o «nessuno ha
-- scritto la colonna»:
--
--   select coalesce(origine, 'null'), count(*) from nomina group by 1;  -- come all'origine
--   select count(*) from nomina where note is not null;                 -- non zero, se le
--                                                                       -- dl_rspp degli script ci sono
