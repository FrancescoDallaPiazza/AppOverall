-- AppOverall — migrazione dati, passo 00
-- Dove atterra l'estrazione da AppSopralluoghi, prima di diventare dato.
--
-- ============================================================================
--  COSA E, E COSA NON E
-- ============================================================================
--
-- **Non e una migrazione di schema** e non sta in `migrations/`: queste tabelle
-- esistono solo per la durata della migrazione dati e si cancellano dopo. Il
-- loro contenuto sono **dati personali** — nomi e codici fiscali di 3.419 righe —
-- quindi i file CSV da cui si riempiono **non entrano mai in questo repo**, e
-- nemmeno uno di prova ricavato da quelli. Le prove usano dati finti
-- (`prova_01_clienti_dati.sql`, `prova_02_persone_dati.sql`,
-- `prova_03_nomine_dati.sql`).
--
-- Le colonne sono quelle di AppSopralluoghi **come stanno nel loro database**, con
-- i loro nomi: la traduzione avviene nei passi 01, 02 e 03 e da nessun altra parte,
-- cosi che chi confronta l'estrazione con l'origine confronta colonne con lo
-- stesso nome.
--
-- L'ordine dei passi e obbligato dalle chiavi esterne: **01 i clienti e le sedi,
-- 02 le persone, 03 le nomine**, perche ogni rapporto di lavoro punta a un cliente
-- che deve gia esserci, e ogni nomina a un rapporto.
--
-- ============================================================================
--  L'ESTRAZIONE, CHE NON FA QUESTA CORSIA
-- ============================================================================
--
-- La lettura richiede la `service_role` o l'SQL Editor del progetto di
-- AppSopralluoghi, che su questa macchina non ci sono e **non vanno portate qui**.
-- La fa Francesco, con queste quattro select, e salva ogni risultato in CSV **fuori
-- da qualunque repo**:
--
--   select id, werp_id, ragione_sociale, partita_iva, codice_fiscale, attivo,
--          numero_lavoratori, codice_ateco, livello_rischio, livello_antincendio,
--          gruppo_primo_soccorso, created_at
--     from cliente order by id;
--
--   select id, cliente_id, nome, indirizzo, localita, provincia, principale,
--          attivo, created_at
--     from sede order by id;
--
--   select id, cliente_id, sede_id, nome, cognome, codice_fiscale, mansione,
--          data_assunzione, attivo, data_cessazione, import_key, updated_at
--     from persona order by id;
--
--   select id, persona_id, figura_codice, data_nomina, attiva, note,
--          estremi_procura, da_confermare, origine, origine_testo,
--          created_at, updated_at
--     from nomina order by id;
--
-- **La procedura per intero** — la fotografia prima e dopo, come salvare i CSV, e il
-- comando della prova generale — sta in `estrazione.md`, accanto. Se queste select
-- cambiano, cambiano anche li e in `prova_generale_comune.sh`.
--
-- Avvertenze che valgono piu delle select:
--
--   * **una lettura troncata non si annuncia.** PostgREST tronca a 1000 righe e
--     l'export di un editor puo avere un suo limite: un file da 1000 righe e un
--     file plausibile. Per questo i passi 01, 02 e 03 pretendono il numero di righe
--     atteso come parametro e si fermano se non coincide — il numero si prende con
--     un `select count(*)` fatto **nello stesso momento**, non dai 619, 3.419 e 454
--     dei giorni scorsi;
--   * **le quattro select vanno fatte nello stesso momento**, e per le nomine non e
--     una finezza: il passo 03 aggancia ogni nomina alla sua persona d'origine per
--     `id`, quindi una nomina estratta dopo una persona nuova punta a una riga che
--     l'estrazione delle persone non ha — e il passo 03 si ferma (rifiuto c);
--   * **la select delle nomine e anche il controllo di livello, e si fa sugli
--     oggetti.** `origine` e `origine_testo` esistono dalla loro `068`: se mancano,
--     la select fallisce invece di estrarre meta. Che `origine` ammetta `qualifica`
--     (`070`) si legge dal vincolo, **non da `schema_migrations`**, dove le
--     migrazioni date dall'SQL Editor non risultano:
--
--       select pg_get_constraintdef(oid) from pg_constraint
--        where conname = 'nomina_origine_nota';        -- deve contenere 'qualifica'
--
--     La `071` non tocca `nomina`, e questa estrazione non dipende da lei;
--   * `persona.codice_fiscale` di la **non e la cella dell'export**: e gia passato
--     da `cfPulisci` all'import del 9 settembre (consegna dell'anagrafe, §3.2).
--     Quindi `persona.codice_fiscale_origine` di qua conterra la cella
--     **ripulita**, non quella del gestionale. E la stringa piu vicina all'origine
--     che esista ancora, e va chiamata per quello che e;
--   * **`persona.mansione` di la non e la colonna Mansione.** L'import la riempie
--     con la **prima colonna non vuota** fra cinque sinonimi — `mansione`, `ruolo`,
--     `qualifica`, `profilo`, `profiloprofessionale` — e la mette in **maiuscolo**
--     (`anagraficheImport.ts:174` e `:867`, letti il 14 settembre). Quindi dove la
--     Mansione del file e vuota qui arriva la Qualifica, e nessuna riga dice da quale
--     colonna veniva. Il passo 02 la porta in `rapporto_lavoro.mansione` com'e,
--     **senza reinterpretarla**: ricostruire la colonna vorrebbe il file. Chi legge
--     quel campo per dedurne un ruolo sappia che e un campo misto — e il caso di
--     «RLS - LAVORATORE» sulla riga 3401 (`51be35d` di AppSopralluoghi);
--   * **`nomina.note` di la non e un campo di servizio**: sulle `dl_rspp` scritte
--     dagli script del 15 settembre porta la ragione del ruolo, e il passo 03 la
--     porta alla lettera (`0020`). E `nomina.origine` null non vuol dire «prima della
--     068»: la scheda dell'organigramma di la non la scrive;
--   * `cliente.partita_iva` di la **puo contenere segnaposto**: la guardia di
--     `pivaUsabile` non scatta mai (vedi la `0017`), e la colonna non e unica. Il
--     passo 01 li riconosce e li tratta come assenti.
--
-- Il caricamento, da `psql` collegato al database di destinazione:
--
--   \copy origine.cliente from '<percorso fuori dal repo>.csv' csv header
--   \copy origine.sede    from '<percorso fuori dal repo>.csv' csv header
--   \copy origine.persona from '<percorso fuori dal repo>.csv' csv header
--   \copy origine.nomina  from '<percorso fuori dal repo>.csv' csv header

create schema if not exists origine;

create table if not exists origine.cliente (
  id uuid primary key,
  werp_id text,
  ragione_sociale text,
  partita_iva text,
  codice_fiscale text,
  attivo boolean not null,
  numero_lavoratori integer,
  codice_ateco text,
  livello_rischio text,
  livello_antincendio text,
  gruppo_primo_soccorso text,
  created_at timestamptz not null
);

comment on table origine.cliente is
  'Il `cliente` di AppSopralluoghi com''e, per la sola durata della migrazione dati: **un''unita**, non un''azienda — due stabilimenti con la stessa P.IVA sono due righe. Il passo 01 la traduce in `cliente` piu `sede`. ATECO e livelli sono estratti per essere **contati**, non portati: vedi il passo 01.';

create table if not exists origine.sede (
  id uuid primary key,
  cliente_id uuid not null,
  nome text not null,
  indirizzo text,
  localita text,
  provincia text,
  principale boolean not null,
  attivo boolean not null,
  created_at timestamptz not null
);

comment on table origine.sede is
  'La `sede` di AppSopralluoghi com''e. In gran parte e la «Sede legale» che la loro `054` crea per ogni cliente copiandone i campi: un riflesso, non un secondo insieme.';

create table if not exists origine.persona (
  id uuid primary key,
  cliente_id uuid not null,
  sede_id uuid,
  nome text not null,
  cognome text,
  codice_fiscale text,
  mansione text,
  data_assunzione date,
  attivo boolean not null,
  data_cessazione date,
  import_key text,
  updated_at timestamptz not null
);

comment on table origine.persona is
  'La `persona` di AppSopralluoghi com''e, per la sola durata della migrazione dati: **per cliente**, con i nomi di colonna di la. Contiene dati personali e si svuota a migrazione finita. Il passo 02 la traduce in `persona` piu `rapporto_lavoro`.';

create table if not exists origine.nomina (
  id uuid primary key,
  persona_id uuid not null,
  figura_codice text not null,
  data_nomina date,
  attiva boolean not null,
  note text,
  estremi_procura text,
  da_confermare boolean not null,
  origine text,
  origine_testo text,
  created_at timestamptz not null,
  updated_at timestamptz not null
);

comment on table origine.nomina is
  'La `nomina` di AppSopralluoghi com''e, per la sola durata della migrazione dati: una riga per **persona-per-cliente** e figura (`015`), con la provenienza della `068` e della `070`. Il passo 03 la traduce in una nomina per persona, cliente, sede e ruolo.';

-- ---------- la quinta tabella, aggiunta il 16 settembre 2026 ----------
--
-- Gli attestati. Arrivano dalla `formazione` di AppSopralluoghi e non da quella di
-- AppFormazione, per la stessa ragione per cui i ruoli arrivano dal passo 03: **il
-- codice qui e gia quello curato**, mappato dai 268 giudizi di `corso_alias`,
-- mentre di la l'identita del corso e l'impronta `GEST-`+md5 del titolo, che la
-- scheda 9 declassa ad alias. Le due fonti non sono equivalenti, e questa e quella
-- che porta i giudizi presi a mano.
--
-- `ore` entra **perche il passo 04 la porti come provenienza**, non perche serva a
-- decidere: e la colonna che il gestionale ha riscritto (12.09.2026), e nella
-- destinazione finisce in `evento_formativo.ore_origine`, fuori dalla vista.

create table if not exists origine.formazione (
  id uuid primary key,
  persona_id uuid not null,
  corso_codice text,
  corso_nome text not null,
  data_completamento date,
  ore numeric(5,1),
  ente_formatore text,
  is_aggiornamento boolean not null,
  parziale boolean not null,
  evidenza_incompleta boolean not null,
  da_confermare boolean not null,
  scadenza date,
  note text,
  import_key text
);

comment on table origine.formazione is
  'La `formazione` di AppSopralluoghi com''e, per la sola durata della migrazione dati: un attestato per riga, con il codice gia curato e i giudizi di lettura (`parziale` dalla loro 059, `evidenza_incompleta` dalla 060). Il passo 04 la traduce in `evento_formativo`. `persona_id` e l''id della loro `persona`, che qui sopravvive come `rapporto_lavoro.id` (passo 02, regola 1).';
