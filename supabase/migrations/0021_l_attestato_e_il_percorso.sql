-- AppOverall — 0021
-- L'attestato: dove atterra la formazione svolta, e come si sa quando un percorso
-- e' finito.
--
-- ============================================================================
--  PERCHE ARRIVA ADESSO, E COSA BLOCCAVA
-- ============================================================================
--
-- Fino al 16 settembre 2026 questo repo aveva **il catalogo e non le misure**: la
-- `0004` porta i corsi, la `0006` cosa assolvono, la `0009` i 53 crediti
-- dell'Allegato III, la `0014` i regimi precedenti con le loro ore. Tutto il metro.
-- Ma delle **13.350 righe di attestati** che stanno nei repo di partenza non ce
-- n'era una che potesse entrare: nessuna tabella le riceveva.
--
-- Non era una dimenticanza da poco. **Lo scadenzario non si calcola dal catalogo,
-- si calcola dagli attestati contro il catalogo**, quindi la Fase 4 — la verticale
-- che deve dimostrare se l'impianto regge — non aveva su cosa girare. E' stato
-- visto guardando le 25 tabelle una per una e chiedendosi dove finisse una riga
-- dell'export: la parola «formativo» era gia' li' cinque volte, e faceva leggere
-- «la formazione c'e'».
--
-- ============================================================================
--  LE TRE DECISIONI CHE DANNO LA FORMA, PRESE DA FRANCESCO IL 16 SETTEMBRE 2026
-- ============================================================================
--
-- **1. Due righe che cadono sulla stessa identita' SI SEGNALANO.** Non si fondono
-- in silenzio e non si rifiutano. Da cui una cosa che si vede nella tabella: **non
-- c'e' un vincolo di unicita' su (persona, corso, data)**. Un `unique` li' avrebbe
-- l'aria della prudenza e farebbe il contrario — o l'import si ferma su un dato
-- che l'origine considera legittimo, o lo scarta per non fermarsi, e in tutti e due
-- i casi la collisione non arriva a chi deve guardarla. Qui la collisione entra, e
-- il passo di migrazione la **conta e la stampa**, come fa il passo 01 con le unita'
-- fuse per P.IVA.
--
-- **2. La validita' si conta dal COMPLETAMENTO del percorso**, non dalla prima
-- sessione ne' dall'ultima riga che capita. Quindi serviva sapere quando un percorso
-- e' finito — e la risposta **non e' una deduzione nostra**: la da' il gestionale,
-- che esporta due file distinti, `ExportExcelFormFrazCompletata.xlsx` (516 righe) e
-- `ExportExcelFormFrazInCorso.xlsx` (410), con le **stesse 34 colonne**. La
-- differenza fra «completato» e «in corso» **non e' un campo: e' quale file stai
-- leggendo.** Per questo esistono `completa_il_percorso` qui e `estrazione` accanto:
-- unire i due file senza registrare da quale vengono perderebbe l'informazione **e
-- nessun vincolo se ne accorgerebbe**, perche' le righe sono valide in tutti e due i
-- casi. Dove una cosa e' scritta e' parte di cosa dice.
--
-- **3. Le ore dell'export si portano come PROVENIENZA, e il motore non le legge.**
-- Il 12 settembre e' stato misurato che il gestionale ha **riscritto la colonna
-- `ore` dello storico** con le durate dell'ASR 2025: un corso del 2019 che allora
-- durava 12 ore oggi dichiara le ore di adesso. Quel numero quindi non dice quante
-- ore siano state erogate — lo dice solo l'attestato di carta — e non e' nemmeno la
-- regola, perche' la regola ce l'abbiamo **datata** nella `0014`.
--
-- E' Francesco ad avere chiuso questa terza: «se io importo un corso passato, lo si
-- deve verificare rispetto alle regole vigenti alla data del corso». Esatto — e da
-- li' segue che usare la colonna dell'export per giudicare un attestato del 2019
-- significherebbe confrontare **il numero di oggi con la regola di ieri**, che e' la
-- peggiore delle combinazioni possibili e per giunta silenziosa.
--
-- Da cui la differenza fra «portarla dichiarandola inaffidabile» e cio' che fa
-- questa migrazione: **la colonna sta nella tabella e non nella vista**. Una nota in
-- un commento la leggono quelli che non la userebbero comunque; una colonna che il
-- motore non trova dove guarda non si usa per sbaglio. La regola sta nella forma.
--
-- ============================================================================
--  L'IDENTITA, CHE DALLE TRE RISPOSTE SEGUE SENZA UN'ALTRA DECISIONE
-- ============================================================================
--
-- L'import del campo usa `gest:<codice fiscale>:<titolo normalizzato>:<data>`
-- (`formazioneImport.ts:480`) e gli serve a non duplicare. E' una chiave di
-- **import**, non un'identita': e' legata al **titolo** che il gestionale usa oggi,
-- e quel gestionale riscrive — se domani rinomina un corso, gli stessi attestati
-- rientrerebbero come nuovi.
--
-- Quindi, applicando la scheda 9 agli attestati come gia' si applica ai titoli:
-- l'identita' e' **persona + corso curato + data**, il titolo del gestionale resta
-- sulla riga come provenienza (come `ateco_origine`, `testo_origine`,
-- `codice_fiscale_origine`), e la chiave del campo resta come `import_key` e basta
-- — unica dove c'e', perche' serve esattamente a una cosa: reimportare lo stesso
-- export due volte non deve creare doppioni.

-- ============================================================================
--  LA TABELLA
-- ============================================================================

create table evento_formativo (
  id uuid primary key default gen_random_uuid(),
  persona_id uuid not null references persona(id) on delete cascade,
  -- Il codice **curato**, non l'impronta del gestionale: quella e' un alias e sta
  -- in `corso_alias` (scheda 9). La chiave esterna e' vera, quindi un attestato che
  -- punta a un corso che non esiste non entra — e il passo di migrazione lo
  -- dichiara invece di lasciarlo cadere.
  corso_codice text not null references corso(codice),
  -- La data dell'attestato. Per un percorso frazionato e' la data della sessione,
  -- e il completamento e' la riga con `completa_il_percorso`.
  data date not null,

  -- ---------- il completamento (decisione 2) ----------
  --
  -- Vero di default perche' il caso normale e' un attestato che chiude da solo il
  -- suo percorso: 13.350 righe su ~14.300 sono cosi'. Falso sulle sessioni di un
  -- percorso frazionato che non lo completano — e chi lo dice e' il file da cui la
  -- riga viene, non un calcolo sulle ore.
  completa_il_percorso boolean not null default true,

  -- ---------- i giudizi della curatela del campo ----------
  --
  -- Arrivano da `corso_alias` (i 268 giudizi presi a mano) e dalle colonne che il
  -- campo ha aggiunto sugli attestati. Non sono flag tecnici: dicono **come si
  -- legge** quell'attestato, e senza di loro una riga che documenta mezzo percorso
  -- e' indistinguibile da una che lo documenta tutto.
  is_aggiornamento boolean not null default false,
  pregressa boolean not null default false,
  parziale boolean not null default false,
  evidenza_incompleta boolean not null default false,
  ente_formatore text,
  nota text,

  -- ---------- la provenienza (decisione 3) ----------
  --
  -- Il titolo come lo scrive il gestionale. Serve a ritrovare la riga nell'export e
  -- a rileggere il giudizio dell'alias: due titoli diversi possono portare allo
  -- stesso codice curato, e quando succede si vede qui.
  titolo_origine text,
  -- **Le ore come le dichiara il gestionale OGGI.** Non sono le ore erogate e non
  -- sono la regola: vedi la decisione 3 in testa. Questa colonna **non compare in
  -- `v_evento_formativo`**, che e' la superficie da cui il motore legge.
  ore_origine numeric(5,1),
  -- Da quale estrazione viene la riga. E' la colonna che tiene in piedi la
  -- decisione 2: «completata» e «in corso» sono due file, non due valori.
  estrazione text references origine_estrazione(codice),
  -- La chiave di idempotenza del campo, `gest:<cf>:<titolo>:<data>`. Unica dove
  -- c'e': le righe nate qui non ne hanno, e non devono averne una finta.
  import_key text,

  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  -- Una sessione che non completa il percorso e' per definizione una parte di un
  -- percorso: se non e' `parziale`, uno dei due campi e' sbagliato e va guardato
  -- prima di scrivere, non dopo.
  constraint sessione_non_completa_e_parziale
    check (completa_il_percorso or parziale)
);

create trigger evento_formativo_updated_at before update on evento_formativo
  for each row execute function tocca_updated_at();

-- L'unico vincolo di unicita', e su cosa serve davvero: non duplicare un import.
create unique index evento_formativo_import_unico
  on evento_formativo (import_key) where import_key is not null;

-- Le due letture che il motore fa: la storia di una persona su un corso, e chi ha
-- fatto un certo corso.
create index on evento_formativo (persona_id, corso_codice, data desc);
create index on evento_formativo (corso_codice, data desc);

comment on table evento_formativo is
  'Un attestato, o una sessione di un percorso frazionato: che una persona ha fatto un corso, quando, e con che giudizi di lettura. **Non c''e un vincolo di unicita su (persona, corso, data)**: due righe uguali sono un fatto che si segnala e si conta nel passo di migrazione, non un errore che il database rifiuta — decisione di Francesco del 16 settembre 2026. La scadenza non sta qui: si calcola, e si calcola dal completamento del percorso.';
comment on column evento_formativo.completa_il_percorso is
  'Se questa riga chiude il percorso. La validita si conta da qui (decisione del 16.09.2026), e chi lo dice e il gestionale con DUE FILE diversi - FormFrazCompletata e FormFrazInCorso - non un calcolo sulle ore. Falso = sessione di un percorso ancora aperto: l''obbligo non e assolto, e la vista non produce nessuna scadenza.';
comment on column evento_formativo.ore_origine is
  'Le ore che il gestionale dichiara OGGI per quell''attestato, e nient''altro. Il 12.09.2026 e stato misurato che lo storico e stato riscritto con le durate dell''ASR 2025: questa colonna non dice quante ore siano state erogate - lo dice solo l''attestato di carta - e non e la regola, che sta datata in corso_regime_precedente (0014). Si conserva come provenienza e **non compare nella vista**: un motore che non la trova non la usa per sbaglio.';
comment on column evento_formativo.estrazione is
  'Da quale estrazione viene la riga (0008). Non e un dettaglio di tracciabilita: per i percorsi frazionati e l''unico posto in cui sopravvive la differenza fra «completato» e «in corso», che alla fonte e il NOME DEL FILE e non un campo.';
comment on column evento_formativo.import_key is
  'La chiave di idempotenza dell''export, gest:<cf>:<titolo>:<data>. E una chiave di import e non un''identita: e legata al titolo che il gestionale usa oggi, e quel gestionale riscrive. L''identita e persona + corso curato + data, e non ha un vincolo (vedi il commento della tabella).';

-- ============================================================================
--  LA VISTA, CHE E LA SUPERFICIE DA CUI SI LEGGE (PILASTRO 01)
-- ============================================================================
--
-- Due cose la distinguono dalla tabella, e tutte e due sono decisioni:
--
--   1. **non porta `ore_origine`.** La decisione 3 dice che il motore non le legge,
--      e questo e' il modo di dirlo che non dipende da chi legge il commento.
--   2. porta `completato_il`: **quando il percorso e' stato chiuso**, che e' la
--      data da cui si conta, e che per un attestato normale coincide con la sua.

create view v_evento_formativo as
  select e.id,
         e.persona_id,
         e.corso_codice,
         c.nome as corso_nome,
         e.data,
         e.completa_il_percorso,
         e.is_aggiornamento,
         e.pregressa,
         e.parziale,
         e.evidenza_incompleta,
         e.ente_formatore,
         e.nota,
         e.titolo_origine,
         e.estrazione,
         e.creato_il,
         e.updated_at
    from evento_formativo e
    join corso c on c.codice = e.corso_codice;

alter view v_evento_formativo set (security_invoker = on);

-- ---------- il percorso: una riga per persona e per corso ----------
--
-- Qui vive la decisione 2. `completato_il` e' la data dell'**ultima riga che
-- chiude** il percorso; se non ce n'e' nessuna il percorso e' aperto, e allora
-- `completato_il` e' null — che non vuol dire «scaduto», vuol dire **non ancora
-- assolto**, e sono due stati diversi che il motore della Fase 4 deve distinguere.
--
-- `aggiornamento_dovuto_il` e' calcolato con la periodicita' del catalogo **di
-- oggi**. E' una data di comodo, non un verdetto: se quel corso, col programma
-- vigente alla sua data, fosse sufficiente o no lo dice `corso_regime_precedente`
-- (`0014`), e chi mette insieme le due cose e' il motore della Fase 4. Questa vista
-- non giudica: dice quando e' stato completato e quando scadrebbe col metro di
-- adesso.

create view v_percorso_formativo as
  select e.persona_id,
         e.corso_codice,
         c.nome as corso_nome,
         max(e.data) filter (where e.completa_il_percorso) as completato_il,
         (max(e.data) filter (where e.completa_il_percorso)) is not null as completo,
         count(*) as righe,
         count(*) filter (where not e.completa_il_percorso) as sessioni_aperte,
         bool_or(e.evidenza_incompleta) as evidenza_incompleta,
         bool_or(e.pregressa) as pregressa,
         case when c.aggiornamento_mesi is not null
              then ((max(e.data) filter (where e.completa_il_percorso))
                    + (c.aggiornamento_mesi || ' months')::interval)::date
         end as aggiornamento_dovuto_il,
         c.aggiornamento_mesi
    from evento_formativo e
    join corso c on c.codice = e.corso_codice
   group by e.persona_id, e.corso_codice, c.nome, c.aggiornamento_mesi;

alter view v_percorso_formativo set (security_invoker = on);

comment on view v_percorso_formativo is
  'Il percorso di una persona su un corso: quando e stato completato, quante sessioni restano aperte, e quando scadrebbe col catalogo di OGGI. Non e lo scadenzario e non giudica: se il programma vigente alla data fosse sufficiente lo dice corso_regime_precedente (0014), e a metterli insieme e il motore della Fase 4. completato_il null = percorso aperto, che non e «scaduto» ma «non ancora assolto».';

-- ============================================================================
--  RLS — le policy sono la regola, non l'applicazione (PILASTRO 03)
-- ============================================================================

alter table evento_formativo enable row level security;

create policy leggono_gli_operatori on evento_formativo for select to authenticated
  using (e_operatore());
create policy scrive_il_tecnico on evento_formativo for all to authenticated
  using (livello_operatore() >= 2) with check (livello_operatore() >= 2);

grant select on evento_formativo to authenticated;
grant select on v_evento_formativo, v_percorso_formativo to authenticated;

-- ============================================================================
--  COSA QUESTA MIGRAZIONE NON FA, E NON PER DIMENTICANZA
-- ============================================================================
--
-- **1. Non calcola lo scadenzario.** Serve mettere insieme requisiti, crediti
-- dell'Allegato III, regimi precedenti e livello di rischio della sede: e' la Fase
-- 4, ed e' un motore, non una vista. Qui c'e' il dato su cui girera'.
--
-- **2. Non porta gli esoneri.** Nel campo sono una tabella a parte con motivazione
-- e riferimento normativo, e sono un **atto**, non un attestato: entrano con la
-- loro forma, non appiattiti qui dentro.
--
-- **3. Non decide cosa fare delle collisioni.** Le ammette e le fa contare al passo
-- di migrazione, che e' la decisione del 16 settembre. Il giorno in cui si volesse
-- risolverle, la domanda sara' **quale delle due righe vale**, e non e' una domanda
-- di schema.
