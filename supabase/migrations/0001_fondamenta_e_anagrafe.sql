-- AppOverall — 0001
-- Le fondamenta e l'anagrafe, con la grana decisa il 9 settembre 2026.
--
-- E la prima migrazione del repo unico, e apre la Fase 3. Il README portava una
-- guardia — «finche le decisioni non sono scritte, qui non entra SQL» — perche
-- due di quelle decisioni determinano colonne e aggiungerle dopo significa
-- riscrivere le righe gia scritte. Adesso sono scritte:
--
--   scheda 1  rischio, ATECO, antincendio e primo soccorso stanno sulla SEDE
--   scheda 2  la chiave e P.IVA + sede: un cliente, N sedi, un organigramma per sede
--   scheda 7  la libreria normativa resta il generatore unico
--   scheda 8  lo scostamento dal default ATECO si annota, con data e autore
--
-- Questa migrazione non porta dati. Porta la forma in cui i dati entreranno, e i
-- pilastri che dopo non si aggiungono: `updated_at` letto e non solo scritto, un
-- vocabolario solo di ruoli applicativi, RLS che isolano davvero, e le viste come
-- unica superficie di lettura.

create extension if not exists pgcrypto;

-- ============================================================================
--  PILASTRO 06 — la concorrenza ottimistica, dal primo giorno
-- ============================================================================
--
-- Nei due repo di partenza `updated_at` c'e con i trigger, ma nessuno lo legge:
-- il drenaggio della coda offline fa un upsert cieco della riga intera e i tipi
-- del client non contengono nemmeno il campo. Il trigger registra il danno
-- invece di prevenirlo.
--
-- La colonna da sola non basta e non e mai bastata. Quello che serve e che il
-- client la **rilegga** e la rimandi indietro: `update ... where updated_at = $1`.
-- Il trigger sta qui perche il valore sia affidabile; il resto e disciplina
-- dell'applicazione, e va scritta nel client alla prima riga che si scrive.

create or replace function tocca_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

comment on function tocca_updated_at is
  'Aggiorna updated_at a ogni scrittura. Serve alla concorrenza ottimistica: chi scrive rilegge il valore e lo rimanda in `where`, cosi due modifiche sovrapposte si accorgono l''una dell''altra invece di sovrascriversi.';

-- ============================================================================
--  PILASTRO 03 — un vocabolario solo di ruoli applicativi
-- ============================================================================
--
-- I due repo di partenza hanno `tecnico / admin / interno` da una parte e
-- `formazione / amministrazione / lettore` dall'altra: **nessun valore in
-- comune**, e due modelli diversi — gate applicativo contro gate in RLS. L'SSO da
-- solo non basterebbe, perche non traduce i ruoli.
--
-- Qui ce n'e uno solo, ed e una tabella e non un enum: un enum si altera con una
-- migrazione, un vocabolario cresce con una riga.

create table ruolo_applicativo (
  codice text primary key,
  nome text not null,
  descrizione text not null,
  -- L'ordine serve al confronto: chi puo fare X puo fare tutto cio che sta sotto.
  livello smallint not null unique
);

insert into ruolo_applicativo (codice, nome, descrizione, livello) values
  ('lettore', 'Lettore', 'Vede, non scrive. E il ruolo di chi consulta lo scadenzario senza gestirlo.', 1),
  ('tecnico', 'Tecnico', 'Compila sopralluoghi e organigrammi, e scrive cio che raccoglie in campo.', 2),
  ('formazione', 'Formazione', 'Gestisce corsi, iscrizioni, attestati e solleciti.', 3),
  ('amministrazione', 'Amministrazione', 'Anagrafiche, sedi e configurazione. Vede tutto.', 4);

create table operatore (
  id uuid primary key default gen_random_uuid(),
  utente_id uuid unique,               -- l'utenza di autenticazione, quando c'e
  cognome text not null,
  nome text not null,
  email text unique,
  ruolo text not null references ruolo_applicativo(codice),
  attivo boolean not null default true,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger operatore_updated_at before update on operatore
  for each row execute function tocca_updated_at();

comment on table operatore is
  'Chi lavora nel sistema. Un utente autenticato senza riga qui non vede niente, e la policy a dirlo — non l''applicazione.';

-- ============================================================================
--  PILASTRO 02 — le RLS isolano, e lo fanno qui e non nel client
-- ============================================================================
--
-- Nei repo di partenza le policy sono tutte `for all to authenticated using
-- (true) with check (true)`: non c'e isolamento da replicare, va scritto da zero.
-- E va scritto **adesso**, perche una policy aggiunta quando ci sono gia due
-- applicazioni a leggere si scopre rotta in produzione.
--
-- La funzione e `security definer` e legge `operatore`: senza, ogni policy che la
-- usa ricadrebbe nella policy di `operatore` e si avvitherebbe.

create or replace function e_operatore() returns boolean
language sql security definer stable set search_path = public as $$
  select exists (
    select 1 from operatore
     where utente_id = auth.uid() and attivo
  );
$$;

create or replace function livello_operatore() returns smallint
language sql security definer stable set search_path = public as $$
  select r.livello
    from operatore o join ruolo_applicativo r on r.codice = o.ruolo
   where o.utente_id = auth.uid() and o.attivo;
$$;

comment on function e_operatore is
  'Vero se chi sta interrogando ha una riga attiva in `operatore`. E il cardine di ogni policy: un utente autenticato ma non abilitato legge zero righe, e lo decide il database.';

-- ============================================================================
--  L'ANAGRAFE — la grana decisa
-- ============================================================================

-- ---------- il cliente: la P.IVA, quando c'e ----------
--
-- «Un'azienda con due sedi chiama per forza due organigrammi» (scheda 2). Ma
-- quella frase dice dove sta l'organigramma, non quanti clienti ci sono: qui il
-- cliente e **uno**, ed e la P.IVA. Gli organigrammi sono N perche stanno sulle
-- sedi.
--
-- La P.IVA e nullable e non e un ripiego: misurata sui file veri, non e usabile
-- su 95 righe di 3.416 nell'export dipendenti e su 58 di 615 fra le aziende
-- attive — fra cui `XXXX`, `00000000000` e due partite IVA di dieci cifre. Per
-- quelle il cliente si identifica per ragione sociale, e la P.IVA resta **vuota**
-- invece di essere riempita con un segnaposto che avvelena gli import successivi.

create table cliente (
  id uuid primary key default gen_random_uuid(),
  partita_iva text unique
    constraint cliente_piva_forma check (partita_iva ~ '^[0-9]{11}$'),
  codice_fiscale text,
  ragione_sociale text not null,
  attivo boolean not null default true,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger cliente_updated_at before update on cliente
  for each row execute function tocca_updated_at();

comment on column cliente.partita_iva is
  'Undici cifre, o niente. Un segnaposto come 00000000000 aggancia righe che non c''entrano e l''errore non si vede piu: meglio nessuna chiave che una chiave falsa. Chi non ce l''ha si identifica per ragione sociale.';

-- ---------- la sede: dove stanno i fatti ----------
--
-- Scheda 1: rischio, ATECO, livello antincendio e gruppo di primo soccorso
-- appartengono alla sede. Non sono attributi aziendali con eccezioni — sono
-- attributi di sede che **spesso** hanno lo stesso valore ovunque.

create table sede (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references cliente(id) on delete restrict,
  denominazione text not null,
  indirizzo text,
  comune text,
  provincia text,
  principale boolean not null default false,
  -- Il codice ATECO e la sua annata. Servono tutte e due: 2.166 stringhe
  -- esistono in entrambe le classificazioni e per 62 la classe cambia, quindi un
  -- codice senza annata non si sa leggere.
  codice_ateco text,
  ateco_versione text
    constraint sede_ateco_versione_nota check (ateco_versione in ('2007', '2022', '2025')),
  -- Il codice di tariffa INAIL: la scheda 1 lo chiede perche il gruppo di primo
  -- soccorso dipende da quello, e oggi il wizard DM 388 lo usa e non lo scrive.
  tariffa_inail text,
  attiva boolean not null default true,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint sede_id_cliente_unico unique (id, cliente_id)
);

create trigger sede_updated_at before update on sede
  for each row execute function tocca_updated_at();

create unique index sede_una_principale_per_cliente
  on sede (cliente_id) where principale;

comment on table sede is
  'L''unita locale. E la grana dell''organigramma e dei fatti che determinano la formazione dovuta: due capannoni della stessa azienda possono avere livelli diversi perche ci si fanno cose diverse.';
comment on column sede.tariffa_inail is
  'Il codice di tariffa INAIL della sede. Il gruppo di primo soccorso del DM 388/2003 dipende da questo e da come si distribuisce fra le sedi: senza memorizzarlo, la regola non e verificabile ne ricalcolabile.';

-- ---------- lo scostamento: una forma sola per tre attributi ----------
--
-- Scheda 8, decisa il 9 settembre. La classe che l'Allegato IV assegna a una
-- divisione ATECO **non e un verdetto: e un default**, e si sposta nei due versi
-- — l'Interpello MLPS 1/2025 cita il 153/CSR allegato A punto 4 per l'alto e il
-- punto 2.1.1 dell'ASR 2025 per il basso.
--
-- Il valore calcolato **non si memorizza**: resta un derivato della tabella
-- normativa, cosi non puo divergere in silenzio da essa. Si scrive solo quando
-- qualcuno decide, e allora si scrive **perche**, **da dove**, **quando** e **chi**.
--
-- La forma non e inventata: e quella di `risposte_azienda` in AppFormazione
-- (migrazione 0052), che gia porta motivazione, fonte, data e autore. Qui vale
-- per tutti e tre gli attributi invece che per due, e `deciso_da` punta a un
-- operatore invece di essere una stringa.

create table valutazione_sede (
  id uuid primary key default gen_random_uuid(),
  sede_id uuid not null references sede(id) on delete cascade,
  attributo text not null
    constraint valutazione_attributo_noto
    check (attributo in ('livello_rischio', 'livello_antincendio', 'gruppo_primo_soccorso')),
  valore text not null,
  -- Obbligatorie: una valutazione senza motivo e un'opinione, e non si verifica.
  motivazione text not null,
  fonte text,
  deciso_il date not null default current_date,
  deciso_da uuid not null references operatore(id) on delete restrict,
  revocato_il date,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger valutazione_sede_updated_at before update on valutazione_sede
  for each row execute function tocca_updated_at();

create unique index valutazione_una_viva_per_attributo
  on valutazione_sede (sede_id, attributo) where revocato_il is null;

comment on table valutazione_sede is
  'Dove si annota che il valore applicato non e quello che la tabella normativa calcola. Una riga viva per attributo e per sede; le precedenti si revocano e non si cancellano, perche la storia di come si e arrivati a una classe e essa stessa un documento.';
comment on column valutazione_sede.motivazione is
  'Non e un campo di servizio. «Rischio alto» non si verifica; «rischio alto perche il DVR del 12 marzo rileva saldatura in ambiente confinato» si verifica. E la differenza fra una lettera e un archivio.';

-- ---------- le persone e i rapporti ----------

create table persona (
  id uuid primary key default gen_random_uuid(),
  codice_fiscale text unique
    constraint persona_cf_forma check (codice_fiscale ~ '^[A-Z0-9]{16}$'),
  cognome text not null,
  nome text not null,
  data_nascita date,
  email text,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger persona_updated_at before update on persona
  for each row execute function tocca_updated_at();

comment on column persona.codice_fiscale is
  'Unico quando c''e, e puo non esserci: nel foglio dei ruoli sicurezza dodici righe su 153 ne sono prive, e dieci sono della stessa azienda. Chi lo cerca deve prevedere il ripiego cognome+nome dentro il cliente, e **contare quante righe non ha agganciato**.';

-- Il rapporto porta la sede, e non e un dettaglio rimandabile: la formazione
-- dovuta dipende dal rischio della sede, quindi finche `sede_id` e null la
-- persona eredita il rischio dell'azienda e questo va saputo. Nei repo di
-- partenza questa colonna esiste dal primo giorno ed e null su tutte e 4.176 le
-- righe.
create table rapporto_lavoro (
  id uuid primary key default gen_random_uuid(),
  persona_id uuid not null references persona(id) on delete cascade,
  cliente_id uuid not null references cliente(id) on delete restrict,
  sede_id uuid,
  mansione text,
  data_assunzione date,
  data_cessazione date,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint rapporto_sede_del_cliente
    foreign key (sede_id, cliente_id) references sede (id, cliente_id)
);

create trigger rapporto_lavoro_updated_at before update on rapporto_lavoro
  for each row execute function tocca_updated_at();

-- ---------- l'organigramma, che sta sulla sede ----------
--
-- `cliente_id` non e un derivato di `sede_id` e non si toglie, anche se la sede
-- punta al cliente. Rispondono a due domande diverse: la sede dice **dove** la
-- persona ricopre il ruolo, il cliente serve alla condizione «medesima azienda»
-- dell'Allegato III, che la norma scrive sull'azienda e non sulla sede. Chi e
-- RSPP in una sede e preposto in un'altra della stessa azienda soddisfa comunque
-- la condizione.

create table nomina (
  id uuid primary key default gen_random_uuid(),
  persona_id uuid not null references persona(id) on delete cascade,
  cliente_id uuid not null references cliente(id) on delete restrict,
  sede_id uuid,
  ruolo text not null,
  data_nomina date,
  data_cessazione date,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint nomina_sede_del_cliente
    foreign key (sede_id, cliente_id) references sede (id, cliente_id)
);

create trigger nomina_updated_at before update on nomina
  for each row execute function tocca_updated_at();

create index on nomina (sede_id, ruolo);
create index on nomina (cliente_id, ruolo);

comment on column nomina.sede_id is
  'Presso quale sede la persona ricopre il ruolo. Nullable, e null va letto «la sede non la sappiamo ancora» — non «tutte le sedi».';

-- ============================================================================
--  PILASTRO 01 — le viste sono l'unica superficie di lettura
-- ============================================================================
--
-- Nei repo di partenza non esiste **una sola** `create view` in 62 migrazioni:
-- ogni query e un `from('<tabella>')` diretto, e non c'e niente dietro cui
-- spostare una tabella senza rompere il client. Qui la regola e opposta e vale
-- dal primo giorno: **l'applicazione non nomina mai una tabella.**

create view v_cliente as
select c.id, c.partita_iva, c.ragione_sociale, c.attivo,
       (select count(*) from sede s where s.cliente_id = c.id and s.attiva) as sedi,
       c.updated_at
  from cliente c;

create view v_sede as
select s.id, s.cliente_id, c.ragione_sociale, s.denominazione, s.principale,
       s.comune, s.provincia, s.codice_ateco, s.ateco_versione, s.tariffa_inail,
       s.attiva, s.updated_at
  from sede s join cliente c on c.id = s.cliente_id;

-- Il valore applicato per attributo, con accanto **da cosa discende**. La classe
-- calcolata dall'ATECO non compare qui: la produce la libreria normativa, e
-- questa vista dice solo dove qualcuno l'ha scavalcata e perche.
create view v_valutazione_sede as
select v.sede_id, s.cliente_id, s.denominazione,
       v.attributo, v.valore, v.motivazione, v.fonte,
       v.deciso_il, o.cognome || ' ' || o.nome as deciso_da
  from valutazione_sede v
  join sede s on s.id = v.sede_id
  join operatore o on o.id = v.deciso_da
 where v.revocato_il is null;

create view v_organigramma as
select n.id, n.cliente_id, c.ragione_sociale, n.sede_id, s.denominazione as sede,
       n.persona_id, p.cognome, p.nome, p.codice_fiscale,
       n.ruolo, n.data_nomina, n.updated_at
  from nomina n
  join cliente c on c.id = n.cliente_id
  join persona p on p.id = n.persona_id
  left join sede s on s.id = n.sede_id
 where n.data_cessazione is null;

-- ============================================================================
--  Le policy
-- ============================================================================
--
-- Tutte le tabelle chiuse. La lettura vuole un operatore attivo; la scrittura
-- vuole il livello. Non c'e nessuna `using (true)`, ed e il punto.

alter table ruolo_applicativo enable row level security;
alter table operatore        enable row level security;
alter table cliente          enable row level security;
alter table sede             enable row level security;
alter table valutazione_sede enable row level security;
alter table persona          enable row level security;
alter table rapporto_lavoro  enable row level security;
alter table nomina           enable row level security;

create policy leggono_gli_operatori on ruolo_applicativo for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on operatore        for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on cliente          for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on sede             for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on valutazione_sede for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on persona          for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on rapporto_lavoro  for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on nomina           for select to authenticated using (e_operatore());

-- L'anagrafe la scrive l'amministrazione; l'organigramma anche il tecnico, che e
-- chi lo raccoglie in campo.
create policy scrive_amministrazione on cliente for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
create policy scrive_amministrazione on sede for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
create policy scrive_il_tecnico on persona for all to authenticated
  using (livello_operatore() >= 2) with check (livello_operatore() >= 2);
create policy scrive_il_tecnico on rapporto_lavoro for all to authenticated
  using (livello_operatore() >= 2) with check (livello_operatore() >= 2);
create policy scrive_il_tecnico on nomina for all to authenticated
  using (livello_operatore() >= 2) with check (livello_operatore() >= 2);
create policy scrive_il_tecnico on valutazione_sede for all to authenticated
  using (livello_operatore() >= 2) with check (livello_operatore() >= 2);

grant select on v_cliente, v_sede, v_valutazione_sede, v_organigramma to authenticated;
