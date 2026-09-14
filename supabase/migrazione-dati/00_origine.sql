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
-- (`prova_01_clienti_dati.sql`, `prova_02_persone_dati.sql`).
--
-- Le colonne sono quelle di AppSopralluoghi **come stanno nel loro database**, con
-- i loro nomi: la traduzione avviene nei passi 01 e 02 e da nessun altra parte,
-- cosi che chi confronta l'estrazione con l'origine confronta colonne con lo
-- stesso nome.
--
-- L'ordine dei passi e obbligato dalle chiavi esterne: **01 i clienti e le sedi,
-- 02 le persone**, perche ogni rapporto di lavoro punta a un cliente che deve gia
-- esserci.
--
-- ============================================================================
--  L'ESTRAZIONE, CHE NON FA QUESTA CORSIA
-- ============================================================================
--
-- La lettura richiede la `service_role` o l'SQL Editor del progetto di
-- AppSopralluoghi, che su questa macchina non ci sono e **non vanno portate qui**.
-- La fa Francesco, con queste tre select, e salva ogni risultato in CSV **fuori da
-- qualunque repo**:
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
-- Avvertenze che valgono piu delle select:
--
--   * **una lettura troncata non si annuncia.** PostgREST tronca a 1000 righe e
--     l'export di un editor puo avere un suo limite: un file da 1000 righe e un
--     file plausibile. Per questo i passi 01 e 02 pretendono il numero di righe
--     atteso come parametro e si fermano se non coincide — il numero si prende con
--     un `select count(*)` fatto **nello stesso momento**, non dai 619 e 3.419 dei
--     giorni scorsi;
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
--   * `cliente.partita_iva` di la **puo contenere segnaposto**: la guardia di
--     `pivaUsabile` non scatta mai (vedi la `0017`), e la colonna non e unica. Il
--     passo 01 li riconosce e li tratta come assenti.
--
-- Il caricamento, da `psql` collegato al database di destinazione:
--
--   \copy origine.cliente from '<percorso fuori dal repo>.csv' csv header
--   \copy origine.sede    from '<percorso fuori dal repo>.csv' csv header
--   \copy origine.persona from '<percorso fuori dal repo>.csv' csv header

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
