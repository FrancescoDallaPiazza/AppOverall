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
  created_at timestamptz not null,
  -- Le quattro colonne del passo 06, aggiunte il 17 settembre 2026 IN CODA, perche'
  -- l'ordine delle colonne e' quello del CSV. Dicono **come** e' nato il valore
  -- accanto: la cella da cui la divisione e' derivata (loro `065`), e il testo che
  -- ogni gesto sui tre livelli scrive nella stessa patch (loro `072`, `050`, `051`).
  -- Senza, il passo 06 non saprebbe distinguere un livello preso dalla tabella da
  -- uno scelto a mano — e la decisione 8 tratta i due in modo opposto.
  ateco_origine text,
  livello_rischio_definito_mediante text,
  antincendio_definito_mediante text,
  primo_soccorso_definito_mediante text
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

-- ---------- la quinta tabella, e la fonte che non era quella che credevo ----------
--
-- **Gli attestati non stanno in AppSopralluoghi.** La loro `formazione` esiste dalla
-- `015`, ha le colonne giuste, ha un import scritto con la sua chiave di idempotenza
-- — e il 16 settembre 2026, misurata, ha **zero righe**: quell'import non e mai stato
-- eseguito in produzione. E la terza volta nella stessa giornata che uno strumento
-- pronto non e mai girato, dopo `togli_ruoli_rspp.sql` e il seed degli alias.
--
-- Avevo scelto quella fonte **ragionando**: li il codice del corso e gia quello curato
-- dai 268 alias, mentre in AppFormazione l'identita del corso e `GEST-` + md5 del
-- titolo, che la scheda 9 declassa ad alias. Il ragionamento reggeva. Non ho chiesto
-- **se ci fossero le righe**, ed e l'unica domanda che contava.
--
-- Le righe sono in **AppFormazione**: `eventi_formativi`, **13.215**. Quindi questa
-- tabella ha la forma della loro, e l'estrazione viene da **due database** invece che
-- da uno. Il prezzo e dichiarato: due estrazioni sono due momenti, e le due
-- fotografie vanno prese vicine.
--
-- Cosa porta, e perche ognuna:
--   * `codice_fiscale` e non un id: fra i due database non c'e nessun id in comune,
--     e la persona si riconosce dal codice fiscale come ovunque in questa migrazione;
--   * `corso_titolo`: il titolo del gestionale, che e da dove il loro codice e
--     derivato (`GEST-` + md5 del titolo normalizzato, loro `0020`). E' la chiave per
--     il **nostro** dizionario dei 268 alias, che e quello curato a mano;
--   * `ore`: come provenienza, non per decidere — vedi la `0021`;
--   * `esito` e `fonte`: due colonne che il campo ha e noi no, e si contano invece di
--     sparire.
--
-- **Cosa non c'e, e non per scelta nostra:** il numero e il file dell'attestato. La
-- loro `0003` li ha tolti da `eventi_formativi` e spostati in una tabella
-- `attestati` con il suo stato e la sua numerazione — scoperto il 16 settembre
-- lanciando la query sulla produzione, dopo averli letti nella loro `0001`. **Una
-- migrazione dice com'era, non com'e**, e la differenza si chiede al database.

create table if not exists origine.formazione (
  id uuid primary key,
  codice_fiscale text,
  corso_titolo text not null,
  corso_codice_origine text not null,
  data_completamento date,
  ore numeric(5,1),
  ente_erogatore text,
  esito text,
  fonte text
);

comment on table origine.formazione is
  'Gli `eventi_formativi` di AppFormazione com''e, per la sola durata della migrazione dati: un attestato per riga, con il codice fiscale della persona e il TITOLO del corso del gestionale. Non viene da AppSopralluoghi: li la tabella omologa esiste ed e vuota, misurato il 16 settembre 2026. Il passo 04 la traduce in `evento_formativo`, mappando il titolo sui 268 alias.';

-- ---------- la sesta tabella: le sessioni dei percorsi frazionati ----------
--
-- **Anche questa viene da AppFormazione, ma non dalle sue tabelle applicative.** I
-- due export `ExportExcelFormFrazCompletata` e `ExportExcelFormFrazInCorso` loro li
-- hanno caricati in `staging.righe_import` e **li hanno lasciati li' per scelta**
-- (`docs/05`): «sono frazioni, non eventi conclusi: sommarle a `corsi_fatti`
-- conterebbe due volte lo stesso corso». Quindi i 13.215 `eventi_formativi` del
-- passo 04 **non le contengono**, e questa tabella non duplica niente.
--
-- Cosa porta, e perche' ognuna:
--   * `id` ed `esecuzione_id`: la riga e il caricamento di staging. Il primo e'
--     l'unica cosa che identifica una sessione — il gestionale non ha un id di
--     percorso ne' di sessione. Il secondo serve a un controllo: se nello staging ci
--     sono **due** caricamenti dello stesso file, le righe dei due si sommano (lo
--     staging scarta solo le righe identiche), e il passo 05 si ferma;
--   * `file`: `fraz_completata` o `fraz_in_corso`. **E' il dato**, non un'etichetta:
--     vedi la `0021`, decisione 2, e la `0022`;
--   * `dettagli_ore` **com'e'**, `1/6`: le ore della sessione su quelle previste. Si
--     porta come provenienza e il passo non ci somma niente;
--   * `dichiarazione`: il piede del file, «Dati aggiornati al 06/08/2026 07:47».
--     Lo staging lo tiene come una riga fra le altre, e l'estrazione lo attacca a
--     ogni sessione del suo file.

create table if not exists origine.formazione_frazionata (
  id bigint primary key,
  esecuzione_id uuid not null,
  file text not null,
  codice_fiscale text,
  corso_titolo text,
  data_sessione date,
  dettagli_ore text,
  durata text,
  dichiarazione text
);

comment on table origine.formazione_frazionata is
  'Le sessioni dei due export FormFraz del gestionale, come le tiene lo staging di AppFormazione, per la sola durata della migrazione dati. Non sono negli eventi_formativi del passo 04: AppFormazione le ha lasciate in staging per non contare due volte lo stesso corso. Il passo 05 le traduce in evento_formativo.';

-- ---------- le visite: due file del gestionale, non un database ----------
--
-- Le scrive `estrai_visite.py` dai due export, perche' nessun database le ha: e' la
-- sola parte dell'estrazione che non passa da un SQL Editor. Le colonne sono quelle
-- dei file, con il loro significato:
--   * `riga`: il numero di riga nel foglio, l'unica cosa che identifica una riga
--     d'export — il gestionale non ha un id della visita;
--   * `tipo`: il nome dell'accertamento **verbatim**, che e' `accertamento.nome_gestionale`
--     della `0005` carattere per carattere (misurato il 17 settembre 2026, 10 su 10);
--   * `dichiarazione`: il piede del file, «Dati aggiornati al ...». Per lo
--     scadenzario non e' un dettaglio: dice a quale visita si riferisce la scadenza
--     (vedi la `0024`).

create table if not exists origine.visita (
  riga int primary key,
  codice_fiscale text,
  tipo text,
  data_esecuzione date,
  dichiarazione text
);

create table if not exists origine.visita_scadenza (
  riga int primary key,
  codice_fiscale text,
  tipo text,
  data_scadenza date,
  stato text,
  dichiarazione text
);

comment on table origine.visita is
  'La storia delle visite (ExportExcelVisiteFatte), una riga per esecuzione, per la sola durata della migrazione dati. La scrive estrai_visite.py; il passo 07 la traduce in sorveglianza.';
comment on table origine.visita_scadenza is
  'Lo scadenzario delle visite (ExportExcelVisiteScadenze), una riga per persona e tipo. Il passo 07 lo usa solo dove la scadenza dissente dal calcolo sull''ultima visita nota alla data del file.';
