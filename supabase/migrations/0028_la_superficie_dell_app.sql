-- AppOverall — 0028
-- La superficie dell'app della Fase 4: cosa legge, e chi ha scritto cosa.
--
-- ============================================================================
--  PERCHE ESISTE
-- ============================================================================
--
-- Francesco, 17 settembre 2026: Sicurweb si spegne entro un mese, e **i corsi e le
-- visite nuovi si registrano in AppOverall**. L'app della Fase 4 (`app/`) fa quindi due
-- cose: **mostra** lo scadenzario del motore (`0026`, `0027`) e **registra** attestati e
-- visite. Pilastro 01: l'app legge viste, non tabelle — e queste sono le viste.
--
-- E una riga scritta a mano deve dire **chi** l'ha scritta: fino a oggi ogni riga
-- formativa veniva da un'estrazione, e `estrazione` bastava a dirlo. Da oggi no.

-- ============================================================================
--  UNO — CHI HA INSERITO LA RIGA
-- ============================================================================
--
-- Lo scrive il database, non l'app: un campo che il client puo' riempire lo puo'
-- anche falsare. Il trigger legge l'operatore dall'utente autenticato; una riga
-- scritta dalla migrazione dati (senza utente) resta con `inserito_da` vuoto e con la
-- sua `estrazione`, ed e' cosi' che le due provenienze si distinguono.

create or replace function operatore_corrente() returns uuid
language sql security definer stable set search_path = public as $$
  select o.id from operatore o where o.utente_id = auth.uid() and o.attivo
$$;

comment on function operatore_corrente is
  'L''operatore dell''utente autenticato, o null. Serve ai trigger che firmano le righe scritte dall''app.';

alter table evento_formativo
  add column inserito_da uuid references operatore(id) on delete restrict,
  add column inserito_il timestamptz;

alter table sorveglianza
  add column inserito_da uuid references operatore(id) on delete restrict,
  add column inserito_il timestamptz;

create or replace function firma_inserimento() returns trigger
language plpgsql as $$
declare
  fatto_il date := coalesce(to_jsonb(new) ->> 'data', to_jsonb(new) ->> 'data_esecuzione')::date;
begin
  new.inserito_da := operatore_corrente();
  new.inserito_il := case when new.inserito_da is not null then now() end;
  -- Dall'app si registra quello che e' stato fatto, non quello che e' previsto: il
  -- modulo lo impedisce, e il database non si fida del modulo.
  if new.inserito_da is not null and fatto_il > current_date then
    raise exception 'La data % e nel futuro: si registra un corso o una visita fatti', fatto_il
      using errcode = 'check_violation';
  end if;
  return new;
end
$$;

create trigger evento_formativo_firma before insert on evento_formativo
  for each row execute function firma_inserimento();
create trigger sorveglianza_firma before insert on sorveglianza
  for each row execute function firma_inserimento();

comment on column evento_formativo.inserito_da is
  'Chi ha registrato l''attestato dall''app (0028). Vuoto sulle righe della migrazione dati, che portano invece estrazione o import_key. Lo scrive un trigger, non il client.';
comment on column sorveglianza.inserito_da is
  'Chi ha registrato la visita dall''app (0028). Vuoto sulle righe della migrazione dati. Lo scrive un trigger, non il client.';

-- ============================================================================
--  DUE — LO SCADENZARIO, IN UNA VISTA SOLA
-- ============================================================================
--
-- Formazione e visite hanno forme diverse (`v_scadenza_formazione`,
-- `v_scadenza_visita`), e chi legge lo scadenzario le vuole in una lista. Le visite
-- non hanno un cliente: si mostrano **per ogni rapporto vivo** della persona, perche'
-- chi sollecita scrive all'azienda.

create view v_scadenzario with (security_invoker = on) as
select 'formazione'::text as tipo,
       s.persona_id, p.cognome, p.nome, p.codice_fiscale,
       s.cliente_id, c.ragione_sociale, s.sede_id, d.denominazione as sede,
       s.ruolo as obbligo, rs.nome as obbligo_nome, s.obbligo_da,
       s.corso, co.nome as corso_nome,
       s.completato_il, s.scadenza, s.scadenza_dichiarata, s.anticipata,
       s.giorni_residui, s.stato,
       s.ruolo_da_confermare, s.esito_livello, s.livello_richiesto
  from v_scadenza_formazione s
  join persona p on p.id = s.persona_id
  join cliente c on c.id = s.cliente_id
  left join sede d on d.id = s.sede_id
  left join ruolo_sicurezza rs on rs.codice = s.ruolo
  left join corso co on co.codice = s.corso
union all
select 'sorveglianza',
       v.persona_id, p.cognome, p.nome, p.codice_fiscale,
       r.cliente_id, c.ragione_sociale, r.sede_id, d.denominazione,
       null, null, 'visita',
       v.accertamento, v.accertamento_nome,
       v.data_esecuzione, v.scadenza, v.scadenza_dichiarata, v.anticipata,
       v.giorni_residui, v.stato,
       false, null, null
  from v_scadenza_visita v
  join persona p on p.id = v.persona_id
  join (select distinct on (persona_id, cliente_id) persona_id, cliente_id, sede_id
          from rapporto_lavoro where not cessato
         order by persona_id, cliente_id, sede_id nulls last) r on r.persona_id = v.persona_id
  join cliente c on c.id = r.cliente_id
  left join sede d on d.id = r.sede_id;

comment on view v_scadenzario is
  'Lo scadenzario che l''app mostra: le scadenze della formazione (motore 0027) e delle visite (0026), con persona, cliente e sede. Una visita compare una volta per ogni rapporto vivo della persona.';

-- ============================================================================
--  TRE — IL CLIENTE, IN UNA RIGA
-- ============================================================================

create view v_scadenzario_cliente with (security_invoker = on) as
select c.id as cliente_id, c.ragione_sociale, c.partita_iva, c.attivo,
       (select count(distinct r.persona_id) from rapporto_lavoro r
         where r.cliente_id = c.id and not r.cessato) as persone,
       count(*) filter (where s.stato = 'scaduto') as scadute,
       count(*) filter (where s.stato = 'in_scadenza') as in_scadenza,
       count(*) filter (where s.stato = 'mancante') as mancanti,
       count(*) filter (where s.stato in ('incompleto', 'in_corso')) as incomplete,
       count(*) filter (where s.ruolo_da_confermare) as ruoli_da_confermare,
       count(*) filter (where s.esito_livello = 'livello_non_definito') as livello_non_definito,
       count(*) filter (where s.esito_livello = 'non_conforme') as livello_non_conforme,
       min(s.scadenza) filter (where s.stato in ('scaduto', 'in_scadenza')) as prima_scadenza
  from cliente c
  left join v_scadenzario s on s.cliente_id = c.id
 group by c.id, c.ragione_sociale, c.partita_iva, c.attivo;

comment on view v_scadenzario_cliente is
  'Una riga per cliente: quante persone in forza, quante scadenze scadute, in scadenza, mancanti, da completare, quanti ruoli da confermare nell''organigramma e quanti livelli di emergenza non definiti. La pagina Clienti dell''app.';

-- ============================================================================
--  QUATTRO — CHI SI PUO' SCEGLIERE NEI MODULI
-- ============================================================================

create view v_persona_in_forza with (security_invoker = on) as
select p.id as persona_id, p.cognome, p.nome, p.codice_fiscale, p.data_nascita,
       r.cliente_id, c.ragione_sociale,
       count(*)::int as rapporti,
       string_agg(distinct r.mansione, ', ' order by r.mansione) as mansione
  from persona p
  join rapporto_lavoro r on r.persona_id = p.id and not r.cessato
  join cliente c on c.id = r.cliente_id
 group by p.id, r.cliente_id, c.ragione_sociale;

comment on view v_persona_in_forza is
  'Le persone con un rapporto non cessato, una riga per persona e cliente (chi lavora in due sedi dello stesso cliente compare una volta: l''attestato e della persona): e l''elenco da cui i moduli dell''app scelgono a chi registrare un attestato o una visita.';

create view v_evento_registrato with (security_invoker = on) as
select e.id, 'formazione'::text as tipo, e.persona_id, p.cognome, p.nome,
       e.corso_codice as codice, c.nome as descrizione, e.data, e.ente_formatore, e.nota,
       o.cognome || ' ' || o.nome as inserito_da, e.inserito_il
  from evento_formativo e
  join persona p on p.id = e.persona_id
  join corso c on c.codice = e.corso_codice
  join operatore o on o.id = e.inserito_da
union all
select s.id, 'sorveglianza', s.persona_id, p.cognome, p.nome,
       s.accertamento, a.nome, s.data_esecuzione, null, s.note,
       o.cognome || ' ' || o.nome, s.inserito_il
  from sorveglianza s
  join persona p on p.id = s.persona_id
  join accertamento a on a.codice = s.accertamento
  join operatore o on o.id = s.inserito_da;

comment on view v_evento_registrato is
  'Gli attestati e le visite registrati dall''app, con chi e quando (0028). Le righe della migrazione dati non ci sono: non hanno un operatore.';

grant select on v_scadenzario, v_scadenzario_cliente, v_persona_in_forza, v_evento_registrato to authenticated;
grant insert on evento_formativo, sorveglianza to authenticated;

-- ============================================================================
--  CINQUE — LA LISTA PER L'ORGANIGRAMMA, CON IL NOME DEL CLIENTE
-- ============================================================================
--
-- La `0027` l'ha fatta per persona; l'app la mostra per cliente, e PostgREST non
-- unisce due viste da solo. La colonna va in coda, cosi' la vista si sostituisce.

create or replace view v_ruolo_da_confermare with (security_invoker = on) as
select s.cliente_id, s.sede_id, s.persona_id, p.cognome, p.nome,
       s.corso, c.nome as corso_nome, s.ruolo as ruolo_proposto,
       s.completato_il, s.scadenza, s.stato,
       cl.ragione_sociale, rs.nome as ruolo_proposto_nome
  from v_scadenza_formazione s
  join persona p on p.id = s.persona_id
  join corso c on c.codice = s.corso
  join cliente cl on cl.id = s.cliente_id
  left join ruolo_sicurezza rs on rs.codice = s.ruolo
 where s.ruolo_da_confermare;
