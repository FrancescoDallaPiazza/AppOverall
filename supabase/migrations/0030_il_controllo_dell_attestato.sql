-- ============================================================================
--  0030 — IL CONTROLLO DELL'ATTESTATO, A REGOLE FISSE
-- ============================================================================
--
-- Francesco, 17 settembre 2026: «voglio che tu crei a livello deterministico una
-- check di controllo dell'attestato secondo le regole di congruenza dell'ASR 25».
-- Niente servizi esterni e niente lettura automatica del PDF: le regole sono righe
-- di tabella, il controllo e una funzione, e lo stesso attestato da sempre lo stesso
-- esito.
--
-- Quattro esiti, e il terzo e il piu importante:
--
--   conforme        la regola e rispettata;
--   non_conforme    la regola e violata, e si vede dai dati che abbiamo;
--   da_verificare   la regola dipende da un fatto che il database non ha (la classe
--                   di rischio della sede, le ore della sola parte pratica, la
--                   formazione fatta altrove): lo deve guardare una persona;
--   non_applicabile la regola non vale per questo corso (per esempio l'antincendio,
--                   che non e disciplinato dall'ASR 2025).
--
-- Le fonti sono lette sul PDF dell'accordo (`ASR-170425.pdf` della libreria) e citate
-- riga per riga: Parte I punti 3 e 6, Parte II punto 2.1, Parte III, Parte IV punto
-- 3.5, Parte VII punto 2.

-- ============================================================================
--  UNO — CHI HA EMESSO L'ATTESTATO
-- ============================================================================
--
-- ASR 2025, Parte I punto 1: i soggetti formatori sono gli «istituzionali», gli
-- «accreditati» e gli «altri soggetti» (fondi interprofessionali, organismi paritetici,
-- associazioni sindacali). Il datore di lavoro che forma i propri lavoratori e
-- soggetto formatore: la Parte IV punto 3.3.1 lo nomina espressamente.
--
-- Un elenco nazionale non c'e ancora («con atto successivo»), quindi il tipo si
-- dichiara: il controllo non puo verificare l'accreditamento, ma sa quali tipi
-- portano una condizione da guardare.

create table soggetto_formatore_tipo (
  codice      text primary key,
  nome        text not null,
  da_guardare text,
  fonte       text not null
);

insert into soggetto_formatore_tipo (codice, nome, da_guardare, fonte) values
  ('istituzionale', 'Soggetto istituzionale (ministeri, regioni, ASL, universita, INAIL, VVF, ordini…)',
   null, 'ASR 17/04/2025, Parte I, punto 1.1'),
  ('accreditato', 'Soggetto accreditato dalla Regione o Provincia autonoma',
   'Per i corsi diversi da lavoratori, preposti e dirigenti serve anche un''esperienza almeno triennale documentata in salute e sicurezza.',
   'ASR 17/04/2025, Parte I, punto 1.2'),
  ('fondo_interprofessionale', 'Fondo interprofessionale che eroga direttamente formazione',
   'Vale solo se lo statuto lo configura come erogatore diretto.',
   'ASR 17/04/2025, Parte I, punto 1.3, n. 1'),
  ('organismo_paritetico', 'Organismo paritetico (art. 51 d.lgs. 81/2008)',
   'Deve essere nel repertorio dell''art. 51 comma 1-bis; puo erogare anche tramite struttura di diretta emanazione.',
   'ASR 17/04/2025, Parte I, punto 1.3, n. 2'),
  ('associazione_sindacale', 'Associazione sindacale dei datori di lavoro o dei lavoratori',
   'Servono i requisiti del punto 1.3 n. 3, oggi autocertificabili: **gli attestati di associazioni che non li hanno non sono validi**.',
   'ASR 17/04/2025, Parte I, punto 1.3, n. 3'),
  ('datore_di_lavoro', 'Il datore di lavoro, per i propri lavoratori',
   'I docenti devono avere i requisiti del D.I. 6/3/2013.',
   'ASR 17/04/2025, Parte IV, punto 3.3.1 (e Parte I, punto 2)');

alter table soggetto_formatore_tipo enable row level security;
create policy leggono_gli_operatori on soggetto_formatore_tipo for select to authenticated using (e_operatore());

comment on table soggetto_formatore_tipo is
  'I tipi di soggetto formatore dell''ASR 2025, Parte I punto 1 (0030). Si dichiara: l''elenco nazionale non esiste ancora.';

alter table evento_formativo
  add column soggetto_formatore_tipo text references soggetto_formatore_tipo(codice),
  add column controllo_esito text check (controllo_esito in ('conforme', 'da_verificare', 'non_conforme')),
  add column controllo_asr jsonb;

comment on column evento_formativo.soggetto_formatore_tipo is
  'Che tipo di soggetto formatore ha emesso l''attestato (0030). Dichiarato da chi registra.';
comment on column evento_formativo.controllo_esito is
  'L''esito del controllo ASR al momento della registrazione (0030): la fotografia, non il giudizio di oggi. Il controllo si rifa quando serve con controlla_attestato().';

-- ============================================================================
--  DUE — LE MODALITA AMMESSE, CORSO PER CORSO
-- ============================================================================
--
-- ASR 2025, Parte IV, punto 3.5, pagine 102 e 103: due tabelle, una per i corsi di
-- formazione e una per quelli di aggiornamento. Qui diventano righe, un corso per
-- volta, perche il catalogo ha piu codici per la stessa riga della tabella (i moduli
-- del datore di lavoro-RSPP, i moduli RSPP) e perche alcune categorie del catalogo
-- mescolano corsi che l'accordo tratta in modo diverso.
--
-- La modalita mista (Parte IV, punto 3.4) non e nella tabella: alterna presenza e
-- distanza, quindi vale quello che vale per la parte a distanza. Dove ne' la
-- videoconferenza ne' l'e-learning sono consentiti, la mista non lo e.
--
-- I corsi che l'ASR non disciplina (antincendio, primo soccorso, RLS, ponteggi,
-- lavori elettrici, lavori in quota) non hanno righe: il controllo lo dice, invece di
-- inventare un giudizio.

create table corso_modalita (
  corso_codice  text not null references corso(codice),
  aggiornamento boolean not null,
  modalita      text not null check (modalita in ('presenza', 'videoconferenza_sincrona', 'e_learning', 'mista')),
  esito         text not null check (esito in ('consentita', 'non_consentita', 'condizionata')),
  condizione    text,
  fonte         text not null,
  primary key (corso_codice, aggiornamento, modalita),
  constraint condizionata_ha_condizione check ((esito = 'condizionata') = (condizione is not null))
);

alter table corso_modalita enable row level security;
create policy leggono_gli_operatori on corso_modalita for select to authenticated using (e_operatore());

comment on table corso_modalita is
  'ASR 2025, Parte IV punto 3.5 (pag. 102-103) in righe: per ogni corso e per formazione o aggiornamento, quali modalita di erogazione sono ammesse (0030). I corsi fuori dall''ASR non hanno righe.';

insert into corso_modalita (corso_codice, aggiornamento, modalita, esito, condizione, fonte)
with gruppo as (
  select * from (values
    ('lav_gen',      array['LAV_GEN']),
    ('lav_spec',     array['LAV_SPEC']),
    ('preposto',     array['PREPOSTO']),
    ('dirigente',    array['DIRIGENTE', 'CANTIERI']),
    ('datore',       array['DATORE_LAVORO']),
    ('dl_rspp',      array['DL_RSPP_BASE', 'DL_RSPP_COMUNE', 'DL_RSPP_SETTORE']),
    ('rspp_a',       array['RSPP_MOD_A']),
    ('rspp_altri',   array['RSPP_MOD_B', 'RSPP_MOD_B_SETTORE', 'RSPP_MOD_C']),
    ('confinati',    array['ATTR_AMB_CONFINATI']),
    ('attrezzature', array['ATTR_GENERICO', 'ATTR_AUTORIBALTABILI', 'ATTR_CARRELLO', 'ATTR_CARROPONTE',
                           'ATTR_CMM', 'ATTR_CRF', 'ATTR_ESCAVATORI', 'ATTR_GRU_AUTOCARRO', 'ATTR_GRU_MOBILI',
                           'ATTR_GRU_TORRE', 'ATTR_PLE', 'ATTR_PLE_UNA', 'ATTR_POMPE_CLS', 'ATTR_TRATT_CINGOLI',
                           'ATTR_TRATT_RUOTE', 'ATTR_TRATT_RUOTE_CINGOLI'])
  ) as g(chiave, corsi)
),
regola as (
  select * from (values
    -- formazione (pag. 102)
    ('lav_gen',      false, 'presenza',                 'consentita',     null::text),
    ('lav_gen',      false, 'videoconferenza_sincrona', 'consentita',     null),
    ('lav_gen',      false, 'e_learning',               'consentita',     null),
    ('lav_gen',      false, 'mista',                    'consentita',     null),
    ('lav_spec',     false, 'presenza',                 'consentita',     null),
    ('lav_spec',     false, 'videoconferenza_sincrona', 'consentita',     null),
    ('lav_spec',     false, 'e_learning',               'condizionata',
       'Consentita solo per il rischio basso. Per rischio medio e alto solo con progetti formativi eventualmente individuati dalle Regioni (nota 1); e nelle aziende a rischio basso non vale per chi svolge mansioni a rischio medio o alto (nota 2).'),
    ('lav_spec',     false, 'mista',                    'consentita',     null),
    ('preposto',     false, 'presenza',                 'consentita',     null),
    ('preposto',     false, 'videoconferenza_sincrona', 'consentita',     null),
    ('preposto',     false, 'e_learning',               'non_consentita', null),
    ('preposto',     false, 'mista',                    'condizionata',
       'La parte a distanza puo essere solo in videoconferenza sincrona: per il preposto l''e-learning non e consentito.'),
    ('dirigente',    false, 'presenza',                 'consentita',     null),
    ('dirigente',    false, 'videoconferenza_sincrona', 'consentita',     null),
    ('dirigente',    false, 'e_learning',               'consentita',     null),
    ('dirigente',    false, 'mista',                    'consentita',     null),
    ('datore',       false, 'presenza',                 'consentita',     null),
    ('datore',       false, 'videoconferenza_sincrona', 'consentita',     null),
    ('datore',       false, 'e_learning',               'consentita',     null),
    ('datore',       false, 'mista',                    'consentita',     null),
    ('dl_rspp',      false, 'presenza',                 'consentita',     null),
    ('dl_rspp',      false, 'videoconferenza_sincrona', 'consentita',     null),
    ('dl_rspp',      false, 'e_learning',               'non_consentita', null),
    ('dl_rspp',      false, 'mista',                    'condizionata',
       'La parte a distanza puo essere solo in videoconferenza sincrona: per il datore di lavoro-RSPP l''e-learning non e consentito.'),
    ('rspp_a',       false, 'presenza',                 'consentita',     null),
    ('rspp_a',       false, 'videoconferenza_sincrona', 'consentita',     null),
    ('rspp_a',       false, 'e_learning',               'consentita',     null),
    ('rspp_a',       false, 'mista',                    'consentita',     null),
    ('rspp_altri',   false, 'presenza',                 'consentita',     null),
    ('rspp_altri',   false, 'videoconferenza_sincrona', 'consentita',     null),
    ('rspp_altri',   false, 'e_learning',               'non_consentita', null),
    ('rspp_altri',   false, 'mista',                    'condizionata',
       'L''e-learning e consentito solo per il modulo A: per gli altri moduli la parte a distanza puo essere solo in videoconferenza sincrona.'),
    ('confinati',    false, 'presenza',                 'consentita',     null),
    ('confinati',    false, 'videoconferenza_sincrona', 'non_consentita', null),
    ('confinati',    false, 'e_learning',               'non_consentita', null),
    ('confinati',    false, 'mista',                    'non_consentita', null),
    ('attrezzature', false, 'presenza',                 'consentita',     null),
    ('attrezzature', false, 'videoconferenza_sincrona', 'non_consentita', null),
    ('attrezzature', false, 'e_learning',               'non_consentita', null),
    ('attrezzature', false, 'mista',                    'non_consentita', null),
    -- aggiornamento (pag. 103)
    ('lav_spec',     true,  'presenza',                 'consentita',     null),
    ('lav_spec',     true,  'videoconferenza_sincrona', 'consentita',     null),
    ('lav_spec',     true,  'e_learning',               'consentita',     null),
    ('lav_spec',     true,  'mista',                    'consentita',     null),
    ('preposto',     true,  'presenza',                 'consentita',     null),
    ('preposto',     true,  'videoconferenza_sincrona', 'consentita',     null),
    ('preposto',     true,  'e_learning',               'non_consentita', null),
    ('preposto',     true,  'mista',                    'condizionata',
       'La parte a distanza puo essere solo in videoconferenza sincrona: per l''aggiornamento del preposto l''e-learning non e consentito.'),
    ('dirigente',    true,  'presenza',                 'consentita',     null),
    ('dirigente',    true,  'videoconferenza_sincrona', 'consentita',     null),
    ('dirigente',    true,  'e_learning',               'consentita',     null),
    ('dirigente',    true,  'mista',                    'consentita',     null),
    ('datore',       true,  'presenza',                 'consentita',     null),
    ('datore',       true,  'videoconferenza_sincrona', 'consentita',     null),
    ('datore',       true,  'e_learning',               'consentita',     null),
    ('datore',       true,  'mista',                    'consentita',     null),
    ('dl_rspp',      true,  'presenza',                 'consentita',     null),
    ('dl_rspp',      true,  'videoconferenza_sincrona', 'consentita',     null),
    ('dl_rspp',      true,  'e_learning',               'consentita',     null),
    ('dl_rspp',      true,  'mista',                    'consentita',     null),
    ('rspp_a',       true,  'presenza',                 'consentita',     null),
    ('rspp_a',       true,  'videoconferenza_sincrona', 'consentita',     null),
    ('rspp_a',       true,  'e_learning',               'consentita',     null),
    ('rspp_a',       true,  'mista',                    'consentita',     null),
    ('rspp_altri',   true,  'presenza',                 'consentita',     null),
    ('rspp_altri',   true,  'videoconferenza_sincrona', 'consentita',     null),
    ('rspp_altri',   true,  'e_learning',               'consentita',     null),
    ('rspp_altri',   true,  'mista',                    'consentita',     null),
    ('confinati',    true,  'presenza',                 'consentita',     null),
    ('confinati',    true,  'videoconferenza_sincrona', 'non_consentita', null),
    ('confinati',    true,  'e_learning',               'non_consentita', null),
    ('confinati',    true,  'mista',                    'non_consentita', null),
    ('attrezzature', true,  'presenza',                 'consentita',     null),
    ('attrezzature', true,  'videoconferenza_sincrona', 'non_consentita', null),
    ('attrezzature', true,  'e_learning',               'non_consentita', null),
    ('attrezzature', true,  'mista',                    'non_consentita', null)
  ) as r(chiave, aggiornamento, modalita, esito, condizione)
)
select c.codice, r.aggiornamento, r.modalita, r.esito, r.condizione,
       'ASR 17/04/2025, Parte IV, punto 3.5, pag. ' || case when r.aggiornamento then '103' else '102' end
  from regola r
  join gruppo g on g.chiave = r.chiave
  join corso c on c.codice = any (g.corsi)
 where r.aggiornamento = false
    or c.aggiornamento_mesi is not null;

-- ============================================================================
--  TRE — LE ORE MINIME QUANDO DIPENDONO DALLA CLASSE DI RISCHIO
-- ============================================================================
--
-- ASR 2025, Parte II punto 2.1, pag. 12: la formazione specifica dei lavoratori dura
-- «4 ore per i settori della classe di rischio basso, 8 per il medio, 12 per l'alto».
-- E il solo corso del catalogo la cui durata dipende dalla classe: per gli altri la
-- durata sta in `corso.ore` (0004) o nelle varianti gia registrate.

create table corso_ore_per_rischio (
  corso_codice text not null references corso(codice),
  classe       text not null check (classe in ('basso', 'medio', 'alto')),
  ore          numeric(5,1) not null check (ore > 0),
  fonte        text not null,
  primary key (corso_codice, classe)
);

alter table corso_ore_per_rischio enable row level security;
create policy leggono_gli_operatori on corso_ore_per_rischio for select to authenticated using (e_operatore());

insert into corso_ore_per_rischio (corso_codice, classe, ore, fonte) values
  ('LAV_SPEC', 'basso',  4.0, 'ASR 17/04/2025, Parte II, punto 2.1, pag. 12'),
  ('LAV_SPEC', 'medio',  8.0, 'ASR 17/04/2025, Parte II, punto 2.1, pag. 12'),
  ('LAV_SPEC', 'alto',  12.0, 'ASR 17/04/2025, Parte II, punto 2.1, pag. 12');

comment on table corso_ore_per_rischio is
  'Le durate minime che dipendono dalla classe di rischio del settore (0030): oggi solo la formazione specifica dei lavoratori.';

-- ============================================================================
--  QUATTRO — IL CONTROLLO
-- ============================================================================
--
-- Una funzione, una riga per regola. Non scrive niente e non decide se registrare:
-- lo decide chi registra, guardando l'esito.

create or replace function controlla_attestato(
  p_persona_id   uuid,
  p_cliente_id   uuid,
  p_corso        text,
  p_data         date,
  p_aggiornamento boolean,
  p_ore          numeric,
  p_modalita     text,
  p_ente         text,
  p_tipo_ente    text,
  p_luogo        text,
  p_firmato      boolean
) returns table (regola text, titolo text, esito text, messaggio text, riferimento text)
language plpgsql stable as $$
declare
  c            corso%rowtype;
  cf           text;
  classe_rischio       text;
  classi       int;
  m            corso_modalita%rowtype;
  ore_minime   numeric;
  fonte_ore    text;
  ore_nota     text;
  grandezza    text;
  regime       corso_regime_precedente%rowtype;
  ore_regime   numeric;
  manca        text[] := '{}';
  tipo         soggetto_formatore_tipo%rowtype;
  quanti       int;
begin
  select * into c from corso where codice = p_corso;
  if not found then
    return query select 'corso', 'Corso', 'non_conforme',
      'Il corso ' || coalesce(p_corso, '(vuoto)') || ' non e nel catalogo.', 'catalogo 0004';
    return;
  end if;
  select codice_fiscale into cf from persona where id = p_persona_id;

  -- La classe_rischio di rischio del cliente, se le sedi dove la persona lavora concordano.
  select count(distinct vs.classe), min(vs.classe) into classi, classe_rischio
    from rapporto_lavoro r
    join v_classe_sede vs on vs.sede_id = r.sede_id
   where r.persona_id = p_persona_id and r.cliente_id = p_cliente_id
     and not r.cessato and vs.classe is not null;
  if coalesce(classi, 0) <> 1 then classe_rischio := null; end if;

  -- ---------- 1. gli elementi minimi (Parte I, punto 6) ----------
  if coalesce(btrim(p_ente), '') = '' then manca := manca || 'denominazione del soggetto formatore (a)'::text; end if;
  if cf is null then manca := manca || 'codice fiscale del partecipante (b)'::text; end if;
  if p_ore is null or p_ore <= 0 then manca := manca || 'durata (c)'::text; end if;
  if p_modalita is null then manca := manca || 'modalita di erogazione (d)'::text; end if;
  if p_firmato is distinct from true then manca := manca || 'firma del soggetto formatore (e)'::text; end if;
  if p_data is null or coalesce(btrim(p_luogo), '') = '' then manca := manca || 'data e luogo (f)'::text; end if;
  return query select 'elementi_minimi', 'Elementi minimi dell''attestato',
    case when cardinality(manca) = 0 then 'conforme' else 'non_conforme' end,
    case when cardinality(manca) = 0
         then 'Ci sono tutti e sei gli elementi minimi.'
         else 'Mancano: ' || array_to_string(manca, '; ') || '.' end,
    'ASR 17/04/2025, Parte I, punto 6, pag. 9';

  -- ---------- 2. la data ----------
  return query select 'data', 'Data dell''attestato',
    case when p_data is null then 'non_conforme'
         when p_data > current_date then 'non_conforme'
         when p_data < date '2025-05-24' then 'da_verificare'
         else 'conforme' end,
    case when p_data is null then 'La data manca.'
         when p_data > current_date then 'La data e nel futuro: si registra un corso fatto.'
         when p_data < date '2025-05-24' then
           'Attestato anteriore al 24/05/2025: vale l''accordo del 21/12/2011, e le regole di questo controllo sono quelle dell''ASR 2025. Le durate sono confrontate anche con il regime precedente, il resto va guardato a mano.'
         else 'Attestato emesso sotto l''ASR 2025.' end,
    'ASR 17/04/2025, Parte VII, punti 1 e 2, pag. 112';

  -- ---------- 3. la modalita di erogazione (Parte IV, punto 3.5) ----------
  select * into m from corso_modalita
   where corso_codice = c.codice and aggiornamento = coalesce(p_aggiornamento, false)
     and modalita = p_modalita;
  if p_modalita is null then
    return query select 'modalita', 'Modalita di erogazione', 'non_conforme',
      'La modalita non e indicata.', 'ASR 17/04/2025, Parte IV, punto 3.5';
  elsif not exists (select 1 from corso_modalita where corso_codice = c.codice) then
    return query select 'modalita', 'Modalita di erogazione', 'non_applicabile',
      'L''ASR 2025 non disciplina questo corso: la modalita ammessa la dice la sua fonte (antincendio: D.M. 2/9/2021; primo soccorso: D.M. 388/2003; RLS: art. 37 c. 10-11 e CCNL; ponteggi: Allegato XXI; lavori elettrici: CEI 11-27).',
      'ASR 17/04/2025, Parte IV, punto 3.5';
  elsif not found then
    return query select 'modalita', 'Modalita di erogazione', 'da_verificare',
      'Per questo corso la tabella 3.5 non ha una riga su questa modalita.', 'ASR 17/04/2025, Parte IV, punto 3.5';
  elsif m.esito = 'non_consentita' then
    return query select 'modalita', 'Modalita di erogazione', 'non_conforme',
      'Questa modalita non e consentita per ' || c.nome ||
      case when p_aggiornamento then ' (aggiornamento).' else ' (formazione).' end, m.fonte;
  elsif m.esito = 'condizionata' then
    -- La formazione specifica dei lavoratori in e-learning: dipende dalla classe_rischio.
    if c.codice = 'LAV_SPEC' and p_modalita = 'e_learning' and classe_rischio is not null then
      return query select 'modalita', 'Modalita di erogazione',
        case when classe_rischio = 'basso' then 'da_verificare' else 'non_conforme' end,
        case when classe_rischio = 'basso'
             then 'Classe di rischio basso: l''e-learning e consentito, ma non per chi svolge mansioni a rischio medio o alto (nota 2 della tabella).'
             else 'Classe di rischio ' || classe_rischio || ': l''e-learning e consentito solo con progetti formativi individuati dalle Regioni (nota 1 della tabella).' end,
        m.fonte;
    else
      return query select 'modalita', 'Modalita di erogazione', 'da_verificare', m.condizione, m.fonte;
    end if;
  else
    return query select 'modalita', 'Modalita di erogazione', 'conforme',
      'Modalita ammessa per questo corso.', m.fonte;
  end if;

  -- ---------- 4. la durata ----------
  grandezza := case when p_aggiornamento then c.ore_aggiornamento_grandezza else c.ore_grandezza end;
  ore_minime := case when p_aggiornamento then c.ore_aggiornamento else c.ore end;
  fonte_ore := 'catalogo 0004, fonte del corso';

  if c.codice = 'LAV_SPEC' and not coalesce(p_aggiornamento, false) then
    if classe_rischio is null then
      return query select 'durata', 'Durata', 'da_verificare',
        'La durata dipende dalla classe_rischio di rischio del settore (4, 8 o 12 ore) e la classe_rischio di questo cliente non e definita o le sedi non concordano.',
        'ASR 17/04/2025, Parte II, punto 2.1, pag. 12';
      ore_minime := null;
    else
      select o.ore, o.fonte into ore_minime, fonte_ore from corso_ore_per_rischio o
       where o.corso_codice = c.codice and o.classe = classe_rischio;
      grandezza := 'durata_corso';
      ore_nota := ' (classe di rischio ' || classe_rischio || ')';
    end if;
  end if;

  if ore_minime is not null and grandezza = 'durata_corso' then
    -- Regime precedente: per gli attestati vecchi il minimo era un altro.
    select * into regime from corso_regime_precedente
     where corso_codice = c.codice
       and colonna = case when p_aggiornamento then 'ore_aggiornamento' else 'ore' end;
    if found and p_data is not null and p_data <= regime.valida_fino_a then
      select min(ore) into ore_regime from corso_regime_precedente_ore
       where corso_codice = regime.corso_codice and colonna = regime.colonna;
      if ore_regime is not null and ore_regime < ore_minime then
        ore_minime := ore_regime;
        fonte_ore := regime.fonte;
        ore_nota := ' (regime precedente, valido per gli attestati fino al ' || to_char(regime.valida_fino_a, 'DD/MM/YYYY') || ')';
      end if;
    end if;
    return query select 'durata', 'Durata',
      case when p_ore is null then 'non_conforme'
           when p_ore >= ore_minime then 'conforme' else 'non_conforme' end,
      case when p_ore is null then 'La durata manca.'
           when p_ore >= ore_minime then 'L''attestato riporta ' || p_ore || ' ore, il minimo e ' || ore_minime || coalesce(ore_nota, '') || '.'
           else 'L''attestato riporta ' || p_ore || ' ore, sotto il minimo di ' || ore_minime || coalesce(ore_nota, '') || '.' end,
      fonte_ore;
  elsif ore_minime is not null and grandezza = 'parte_pratica' then
    return query select 'durata', 'Durata', 'da_verificare',
      'Il minimo di ' || ore_minime || ' ore riguarda la sola parte pratica, che l''attestato non separa: va letto sull''attestato.',
      'ASR 17/04/2025, Parte III, punti 5 e 6, pag. 82';
  elsif ore_minime is not null and grandezza = 'monte_ore_quinquennio' then
    return query select 'durata', 'Durata', 'non_applicabile',
      'Il minimo di ' || ore_minime || ' ore e un monte ore del quinquennio: un singolo attestato puo esserne una parte.',
      'ASR 17/04/2025, Parte III, punto 3, pag. 82';
  elsif ore_minime is null and c.codice <> 'LAV_SPEC' then
    return query select 'durata', 'Durata', 'da_verificare',
      'Il catalogo non fissa una durata per questo corso: va confrontata con la fonte del corso.', 'catalogo 0004';
  end if;

  -- ---------- 5. il percorso a cui l'attestato si appoggia ----------
  if c.prerequisito_codice is not null then
    select count(*) into quanti from evento_formativo e
     where e.persona_id = p_persona_id and e.corso_codice = c.prerequisito_codice;
    return query select 'prerequisito', 'Formazione richiesta prima',
      case when quanti > 0 then 'conforme' else 'da_verificare' end,
      case when quanti > 0 then 'La persona ha il corso richiesto prima: ' || (select nome from corso where codice = c.prerequisito_codice) || '.'
           else 'Qui non risulta ' || (select nome from corso where codice = c.prerequisito_codice) ||
                ', che questo corso presuppone: se e stato fatto altrove va registrato.' end,
      'catalogo 0004, prerequisito del corso';
  end if;

  if coalesce(p_aggiornamento, false) then
    select count(*) into quanti from evento_formativo e
     where e.persona_id = p_persona_id and e.corso_codice = c.codice and not e.is_aggiornamento;
    return query select 'aggiornamento', 'Aggiornamento',
      case when quanti > 0 then 'conforme' else 'da_verificare' end,
      case when quanti > 0 then 'Il corso base risulta registrato: l''aggiornamento decorre dalla data di fine corso di questo attestato.'
           else 'Qui non risulta il corso base di ' || c.nome || '. L''aggiornamento presuppone il corso: se e stato fatto altrove va registrato.' end,
      'ASR 17/04/2025, Parte III, pag. 80';
  end if;

  -- ---------- 6. chi ha emesso l'attestato ----------
  if p_tipo_ente is null then
    return query select 'soggetto_formatore', 'Soggetto formatore', 'da_verificare',
      'Il tipo di soggetto formatore non e indicato: l''ASR ammette solo i soggetti del punto 1.',
      'ASR 17/04/2025, Parte I, punto 1, pag. 6';
  else
    select * into tipo from soggetto_formatore_tipo where codice = p_tipo_ente;
    return query select 'soggetto_formatore', 'Soggetto formatore',
      case when tipo.da_guardare is null then 'conforme' else 'da_verificare' end,
      coalesce(tipo.da_guardare, tipo.nome || ': ammesso dall''accordo.'), tipo.fonte;
  end if;

  -- ---------- 7. il corso e ancora quello del catalogo ----------
  if not c.attivo then
    return query select 'corso_attivo', 'Corso nel catalogo', 'da_verificare',
      'Il corso non e piu attivo nel catalogo: lo si registra come storia, non come formazione di oggi.', 'catalogo 0004';
  end if;
end
$$;

comment on function controlla_attestato is
  'Il controllo di congruenza dell''attestato con l''ASR 2025 (0030), a regole fisse: una riga per regola, con esito e fonte. Non scrive e non decide: chi registra guarda.';

-- L'esito complessivo: la regola piu severa vince.
create or replace function esito_controllo(p_righe jsonb) returns text
language sql immutable as $$
  select case
    when p_righe @> '[{"esito": "non_conforme"}]'  then 'non_conforme'
    when p_righe @> '[{"esito": "da_verificare"}]' then 'da_verificare'
    else 'conforme' end
$$;

-- ============================================================================
--  CINQUE — L'ESITO RESTA ATTACCATO ALL'ATTESTATO
-- ============================================================================
--
-- Il controllo si rifa quando si vuole, ma quello del momento della registrazione e
-- un fatto: chi ha registrato ha visto quello. Lo scrive il database, come la firma.

create or replace function firma_controllo_asr() returns trigger
language plpgsql as $$
declare
  cliente uuid;
  righe   jsonb;
begin
  if operatore_corrente() is null then
    return new;
  end if;
  select r.cliente_id into cliente from rapporto_lavoro r
   where r.persona_id = new.persona_id and not r.cessato
   order by r.data_assunzione desc nulls last limit 1;
  select coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) into righe
    from controlla_attestato(new.persona_id, cliente, new.corso_codice, new.data,
                             new.is_aggiornamento, new.ore_attestato, new.modalita_erogazione,
                             new.ente_formatore, new.soggetto_formatore_tipo, new.luogo,
                             new.attestato_firmato) x;
  new.controllo_asr := righe;
  new.controllo_esito := esito_controllo(righe);
  return new;
end
$$;

create trigger evento_formativo_controllo before insert on evento_formativo
  for each row execute function firma_controllo_asr();

grant select on soggetto_formatore_tipo, corso_modalita, corso_ore_per_rischio to authenticated;
grant execute on function controlla_attestato(uuid, uuid, text, date, boolean, numeric, text, text, text, text, boolean) to authenticated;

-- L'elenco delle registrazioni porta l'esito del controllo: chi registra lo rivede.
create or replace view v_evento_registrato with (security_invoker = on) as
select e.id, 'formazione'::text as tipo, e.persona_id, p.cognome, p.nome,
       e.corso_codice as codice, c.nome as descrizione, e.data, e.ente_formatore, e.nota,
       o.cognome || ' ' || o.nome as inserito_da, e.inserito_il, e.controllo_esito
  from evento_formativo e
  join persona p on p.id = e.persona_id
  join corso c on c.codice = e.corso_codice
  join operatore o on o.id = e.inserito_da
union all
select s.id, 'sorveglianza', s.persona_id, p.cognome, p.nome,
       s.accertamento, a.nome, s.data_esecuzione, null, s.note,
       o.cognome || ' ' || o.nome, s.inserito_il, null
  from sorveglianza s
  join persona p on p.id = s.persona_id
  join accertamento a on a.codice = s.accertamento
  join operatore o on o.id = s.inserito_da;

