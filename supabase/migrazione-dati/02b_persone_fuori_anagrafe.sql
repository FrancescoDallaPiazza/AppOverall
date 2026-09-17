-- AppOverall — migrazione dati, passo 02b: le persone che l'anagrafe non ha.
--
--   psql -v ON_ERROR_STOP=1 -v righe_persone_storiche_attese=<count fatto all'estrazione> \
--        -f 02b_persone_fuori_anagrafe.sql
--
-- Va dopo il passo 02 e **prima** dei passi 04, 05 e 07: gli attestati, le sessioni e
-- le visite trovano la persona dal codice fiscale, e queste persone devono esserci
-- quando la cercano. Legge gli stessi file di quei passi, per sapere chi ha una storia.
--
-- ============================================================================
--  LA DECISIONE
-- ============================================================================
--
-- **Francesco, 17 settembre 2026: strada C.** Le persone che hanno attestati o visite
-- nel gestionale e non compaiono nell'anagrafe di AppSopralluoghi — **1.036** sui file
-- del giorno, 1.005 dagli attestati e 233 dalle visite, 202 in entrambi — entrano **con
-- il loro rapporto**: il cliente per cui lavoravano, anche se oggi non e' piu' cliente.
-- Le altre due strade erano lasciarle fuori (A) o portarle senza datore (B).
--
-- ============================================================================
--  LE REGOLE
-- ============================================================================
--
-- **1. Entra chi ha una storia e non ha una scheda.** Codice fiscale valido, presente
-- negli attestati, nelle sessioni o nelle visite, assente da `persona`. Chi
-- AppFormazione conosce senza nessuna storia non entra: non porterebbe niente.
--
-- **2. Il nome da AppFormazione, e per chi ha solo visite dal file delle visite.**
-- AppFormazione le ha gia' promosse — 987 «non attive» dagli eventi piu' le sue attive
-- — con nome e data di nascita. Chi ha **solo** visite AppFormazione non lo conosce
-- (le visite le lascia fuori per perimetro): il nome viene dalla sua visita piu'
-- recente. Senza nome non si entra: `persona.cognome` e' obbligatorio, e un nome
-- inventato e' peggio di una persona che manca. Si conta.
--
-- **3. Il rapporto e' CESSATO, e la data resta vuota se nessuno la dice** (`0025`).
-- Il gestionale toglie dall'anagrafica chi esce e la data non la scrive.
--
-- **Tranne chi AppFormazione da' per attivo: quello entra con il rapporto APERTO.**
-- ~~Entra cessato, perche' vince l'anagrafe piu' recente~~ — era la prima stesura, e
-- sui dati veri del 17 settembre 2026 riguardava **34 persone su 7 aziende**, 28 con
-- una storia dal 2025 e 23 in una sola azienda. **Francesco, lo stesso giorno:
-- «considerali tutti come attivi per le imprese».** Quindi il rapporto resta aperto,
-- a meno che AppFormazione stessa non gli dia una data di cessazione. Si contano a
-- parte, perche' l'anagrafe di AppSopralluoghi continua a non averle: finche' non le
-- ha, e' questo passo a tenerle attive, e lo fa a ogni giro.
--
-- **4. Il cliente si riconosce, e solo se non c'e' si crea.** Prima la P.IVA usabile,
-- poi la ragione sociale con la normalizzazione del passo 01, ma **solo se porta a un
-- cliente solo**. Un cliente che non c'e' si crea **non attivo** — e' un ex cliente —
-- una volta per P.IVA, o per ragione sociale se la P.IVA non c'e'. Una ragione sociale
-- che porta a piu' clienti non si sceglie: si crea a parte, e si conta.
--
-- **5. Da dove viene il rapporto.** Per chi AppFormazione conosce: i suoi rapporti,
-- uno per uno, con mansione e date. Per chi ha solo visite: un rapporto per ogni
-- azienda che le sue visite nominano. Nessuna sede: il gestionale non la dice.
--
-- **Rieseguibile:** la persona per codice fiscale, il cliente e il rapporto per
-- `import_key`.

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.righe_persone_storiche_attese', :'righe_persone_storiche_attese', true);

-- ---------- chi ha una storia ----------

create temp view storia as
select codice_fiscale_pulito(codice_fiscale) as cf, data_completamento as data, 'attestato' as fonte
  from origine.formazione where codice_fiscale_valido(codice_fiscale)
union all
select codice_fiscale_pulito(codice_fiscale), data_sessione, 'sessione'
  from origine.formazione_frazionata where codice_fiscale_valido(codice_fiscale)
union all
select codice_fiscale_pulito(codice_fiscale), data_esecuzione, 'visita'
  from origine.visita where codice_fiscale_valido(codice_fiscale);

create temp view af as
select s.*,
       case when codice_fiscale_valido(s.codice_fiscale)
            then codice_fiscale_pulito(s.codice_fiscale) end as cf
  from origine.persona_storica s;

-- la normalizzazione della ragione sociale, come nel passo 01
create function pg_temp.den(t text) returns text language sql immutable as $$
  select btrim(regexp_replace(upper(regexp_replace(coalesce(t, ''), '\s+', ' ', 'g') collate "und-x-icu"), '\.+$', ''))
$$;

-- ---------- i controlli, prima di scrivere ----------

do $$
declare n int; attese int;
begin
  attese := nullif(current_setting('migrazione.righe_persone_storiche_attese', true), '')::int;
  if attese is null then
    raise exception 'manca -v righe_persone_storiche_attese=<numero>: senza, un''estrazione troncata passerebbe per intera';
  end if;
  select count(*) into n from origine.persona_storica;
  if n <> attese then
    raise exception '(a) origine.persona_storica ha % righe, l''estrazione ne dichiarava %', n, attese;
  end if;

  select count(*) into n from (
    select cf from af where cf is not null group by cf having count(distinct persona_id) > 1) x;
  if n > 0 then
    raise exception '(b) % codici fiscali su piu persone di AppFormazione: la persona non si sa quale sia', n;
  end if;

  select count(*) into n from (
    select persona_id from af group by persona_id
    having count(distinct coalesce(cognome, '') || '|' || coalesce(nome, '')) > 1) x;
  if n > 0 then
    raise exception '(c) % persone di AppFormazione con nomi diversi sulle proprie righe: l''estrazione non e quella attesa', n;
  end if;
end $$;

-- ---------- regola 1 e 2: chi entra, e con che nome ----------

create temp table entra on commit drop as
with candidati as (
  select s.cf,
         max(s.data) as ultima,
         bool_or(s.fonte <> 'visita') as ha_formazione,
         bool_or(s.fonte = 'visita') as ha_visite
    from storia s
   where not exists (select 1 from persona p where p.codice_fiscale = s.cf)
   group by s.cf
),
da_af as (
  select distinct on (cf) cf, persona_id, codice_fiscale, cognome, nome, data_nascita, attiva
    from af where cf is not null
   order by cf
),
da_visita as (
  select distinct on (codice_fiscale_pulito(codice_fiscale))
         codice_fiscale_pulito(codice_fiscale) as cf, codice_fiscale, cognome, nome, data_nascita
    from origine.visita
   where codice_fiscale_valido(codice_fiscale)
     and nullif(btrim(cognome), '') is not null
   order by codice_fiscale_pulito(codice_fiscale), data_esecuzione desc, riga desc
)
select c.*,
       a.persona_id as af_persona,
       a.attiva as af_attiva,
       coalesce(nullif(btrim(a.cognome), ''), nullif(btrim(v.cognome), '')) as cognome,
       coalesce(nullif(btrim(a.nome), ''), nullif(btrim(v.nome), ''), '') as nome,
       coalesce(a.data_nascita, v.data_nascita) as data_nascita,
       coalesce(nullif(a.codice_fiscale, ''), v.codice_fiscale) as cf_origine,
       case when a.persona_id is not null then 'appformazione' else 'visite' end as nome_da
  from candidati c
  left join da_af a on a.cf = c.cf
  left join da_visita v on v.cf = c.cf;

insert into persona (codice_fiscale, codice_fiscale_origine, cognome, nome, data_nascita)
select cf, cf_origine, cognome, nome, data_nascita
  from entra
 where cognome is not null
on conflict (codice_fiscale) do nothing;

-- ---------- regola 4: i clienti ----------

create temp table azienda on commit drop as
-- da AppFormazione: il cliente dei rapporti delle persone che entrano
select distinct e.cf, s.rapporto_id, s.mansione, s.data_assunzione, s.data_cessazione,
       s.ragione_sociale, s.partita_iva, 'appformazione'::text as da
  from entra e
  join af s on s.persona_id = e.af_persona
 where s.rapporto_id is not null
   and e.cognome is not null
union all
-- dalle visite: per chi AppFormazione non conosce, le aziende delle sue visite
select distinct e.cf, null::uuid, null, null::date, null::date,
       v.societa, v.partita_iva, 'visite'
  from entra e
  join origine.visita v on codice_fiscale_valido(v.codice_fiscale)
                       and codice_fiscale_pulito(v.codice_fiscale) = e.cf
 where e.af_persona is null
   and e.cognome is not null
   and nullif(btrim(v.societa), '') is not null;

alter table azienda add column piva text, add column den text, add column cliente_dest uuid, add column come text;
update azienda set
  piva = case when partita_iva_usabile(partita_iva)
              then regexp_replace(partita_iva, '\s', '', 'g') end,
  den = pg_temp.den(ragione_sociale);

-- per P.IVA
update azienda a set cliente_dest = c.id, come = 'piva'
  from cliente c
 where a.piva is not null and c.partita_iva = a.piva;

-- per ragione sociale, solo se porta a un cliente solo
update azienda a set cliente_dest = u.id, come = 'ragione sociale'
  from (select pg_temp.den(ragione_sociale) as den, min(id::text)::uuid as id
          from cliente group by 1 having count(*) = 1) u
 where a.cliente_dest is null and a.piva is null and u.den = a.den;

create temp table ambigue on commit drop as
select distinct a.den
  from azienda a
 where a.cliente_dest is null and a.piva is null
   and (select count(*) from cliente c where pg_temp.den(c.ragione_sociale) = a.den) > 1;

-- gli ex clienti che non ci sono: uno per P.IVA, uno per ragione sociale
insert into cliente (partita_iva, partita_iva_origine, ragione_sociale, attivo, import_key)
select distinct on (piva) piva, nullif(btrim(partita_iva), ''), btrim(ragione_sociale), false,
       'storico:piva:' || piva
  from azienda
 where cliente_dest is null and piva is not null
 order by piva, ragione_sociale
on conflict (import_key) do nothing;

insert into cliente (partita_iva, partita_iva_origine, ragione_sociale, attivo, import_key)
select distinct on (den) null, nullif(btrim(partita_iva), ''), btrim(ragione_sociale), false,
       'storico:den:' || den
  from azienda
 where cliente_dest is null and piva is null and den <> ''
 order by den, ragione_sociale
on conflict (import_key) do nothing;

update azienda a set cliente_dest = c.id, come = coalesce(a.come, 'creato')
  from cliente c
 where a.cliente_dest is null
   and c.import_key = case when a.piva is not null then 'storico:piva:' || a.piva
                           else 'storico:den:' || a.den end;

-- ---------- regole 3 e 5: i rapporti ----------
--
-- Aperto solo se AppFormazione da' la persona per attiva e il rapporto non ha una
-- data di cessazione. Tutto il resto entra cessato.

insert into rapporto_lavoro (persona_id, cliente_id, mansione, data_assunzione, data_cessazione,
                             cessato, import_key)
select distinct on (chiave) p.id, a.cliente_dest, nullif(btrim(a.mansione), ''),
       a.data_assunzione, a.data_cessazione,
       not (a.da = 'appformazione' and coalesce(e.af_attiva, false) and a.data_cessazione is null),
       chiave
  from (select a.*,
               case when a.rapporto_id is not null then 'af:rapporto:' || a.rapporto_id
                    else 'visite:' || a.cf || ':' || a.cliente_dest end as chiave
          from azienda a where a.cliente_dest is not null) a
  join entra e on e.cf = a.cf
  join persona p on p.codice_fiscale = a.cf
 order by chiave
on conflict (import_key) do nothing;

-- ---------- i conti ----------

do $$
declare
  candidati int; da_af int; da_visite int; senza_nome int; scritte int;
  af_attive int; af_attive_recenti int; recenti int; senza_rapporto int;
  per_piva int; per_den int; creati int; creati_ora int; ambigui int; senza_azienda int;
  rapporti int; aperti int; aperti_su_non_attivi int;
begin
  select count(*),
         count(*) filter (where nome_da = 'appformazione' and cognome is not null),
         count(*) filter (where nome_da = 'visite' and cognome is not null),
         count(*) filter (where cognome is null),
         count(*) filter (where af_attiva and cognome is not null),
         count(*) filter (where af_attiva and cognome is not null and ultima >= date '2025-01-01'),
         count(*) filter (where cognome is not null and ultima >= date '2025-01-01')
    into candidati, da_af, da_visite, senza_nome, af_attive, af_attive_recenti, recenti
    from entra;
  select count(*) into scritte
    from entra e join persona p on p.codice_fiscale = e.cf
   where e.cognome is not null;
  select count(*) into senza_rapporto
    from entra e
   where e.cognome is not null
     and not exists (select 1 from azienda a where a.cf = e.cf and a.cliente_dest is not null);
  select count(distinct coalesce(piva, den)) filter (where come = 'piva'),
         count(distinct coalesce(piva, den)) filter (where come = 'ragione sociale'),
         count(distinct coalesce(piva, den)) filter (where come = 'creato')
    into per_piva, per_den, creati
    from azienda;
  select count(*) into creati_ora from cliente where import_key like 'storico:%';
  select count(*) into ambigui from ambigue;
  select count(*) into senza_azienda from azienda where cliente_dest is null;
  select count(*) filter (where r.cessato),
         count(*) filter (where not r.cessato),
         count(*) filter (where not r.cessato and not c.attivo)
    into rapporti, aperti, aperti_su_non_attivi
    from rapporto_lavoro r join cliente c on c.id = r.cliente_id
   where r.import_key like 'af:rapporto:%' or r.import_key like 'visite:%';

  raise notice 'persone con una storia e senza scheda %  ->  schede scritte % (nome da AppFormazione %, dalle visite %)', candidati, scritte, da_af, da_visite;
  raise notice '  NON entrate: % senza un nome da nessuna delle due fonti', senza_nome;
  raise notice '  con una storia dal 2025 in poi: %', recenti;
  raise notice '  ATTIVE per AppFormazione e assenti dall''anagrafe: % (di cui con una storia dal 2025: %) — entrano con il rapporto aperto (Francesco, 17.09.2026)', af_attive, af_attive_recenti;
  raise notice 'aziende: riconosciute per P.IVA %, per ragione sociale %, ex clienti creati non attivi % (in tutto nel database: %)', per_piva, per_den, creati, creati_ora;
  raise notice '  ragioni sociali che portano a piu clienti, create a parte: %; aziende senza un cliente: %', ambigui, senza_azienda;
  raise notice 'rapporti scritti da questo passo: cessati %, aperti % (di cui su un cliente non attivo: %); persone entrate senza nessun rapporto: %', rapporti, aperti, aperti_su_non_attivi, senza_rapporto;
end $$;

commit;
