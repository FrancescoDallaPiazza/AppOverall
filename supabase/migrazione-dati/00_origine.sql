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
-- quindi il file CSV da cui si riempiono **non entra mai in questo repo**, e
-- nemmeno uno di prova ricavato da quello. Le prove usano dati finti
-- (`prova_01_persone_dati.sql`).
--
-- Le colonne sono quelle di `persona` di AppSopralluoghi **come stanno nel loro
-- database**, con i loro nomi: la traduzione avviene nel passo 01 e da nessun
-- altra parte, cosi che chi confronta l'estrazione con l'origine confronta
-- colonne con lo stesso nome.
--
-- ============================================================================
--  L'ESTRAZIONE, CHE NON FA QUESTA CORSIA
-- ============================================================================
--
-- La lettura delle 3.419 righe richiede la `service_role` o l'SQL Editor del
-- progetto di AppSopralluoghi, che su questa macchina non ci sono e **non vanno
-- portate qui**. La fa Francesco, con questa select, e salva il risultato in CSV
-- **fuori da qualunque repo**:
--
--   select id, cliente_id, sede_id, nome, cognome, codice_fiscale, mansione,
--          data_assunzione, attivo, data_cessazione, import_key, updated_at
--     from persona
--    order by id;
--
-- Due avvertenze che valgono piu della select:
--
--   * **una lettura troncata non si annuncia.** PostgREST tronca a 1000 righe e
--     l'export di un editor puo avere un suo limite: un file da 1000 righe e un
--     file plausibile. Per questo il passo 01 pretende il numero di righe atteso
--     come parametro e si ferma se non coincide — il numero si prende con un
--     `select count(*) from persona` fatto **nello stesso momento**, non dal 3.419
--     del 13 settembre;
--   * `codice_fiscale` di la **non e la cella dell'export**: e gia passato da
--     `cfPulisci` all'import del 9 settembre (consegna dell'anagrafe, §3.2). Quindi
--     `persona.codice_fiscale_origine` di qua conterra la cella **ripulita**, non
--     quella del gestionale. E la stringa piu vicina all'origine che esista ancora,
--     e va chiamata per quello che e;
--   * **`mansione` di la non e la colonna Mansione.** L'import la riempie con la
--     **prima colonna non vuota** fra cinque sinonimi — `mansione`, `ruolo`,
--     `qualifica`, `profilo`, `profiloprofessionale` — e la mette in **maiuscolo**
--     (`anagraficheImport.ts:174` e `:867`, letti il 14 settembre). Quindi dove la
--     Mansione del file e vuota qui arriva la Qualifica, e nessuna riga dice da quale
--     colonna veniva. Il passo 01 la porta in `rapporto_lavoro.mansione` com'e,
--     **senza reinterpretarla**: ricostruire la colonna vorrebbe il file. Chi legge
--     quel campo per dedurne un ruolo sappia che e un campo misto — e il caso di
--     «RLS - LAVORATORE» sulla riga 3401 (`51be35d` di AppSopralluoghi).
--
-- Il caricamento, da `psql` collegato al database di destinazione:
--
--   \copy origine.persona from '<percorso fuori dal repo>.csv' csv header

create schema if not exists origine;

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
  'La `persona` di AppSopralluoghi com''e, per la sola durata della migrazione dati: **per cliente**, con i nomi di colonna di la. Contiene dati personali e si svuota a migrazione finita. Il passo 01 la traduce in `persona` piu `rapporto_lavoro`.';
