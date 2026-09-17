-- AppOverall — migrazione dati, passo 07: la sorveglianza sanitaria.
--
--   psql -v ON_ERROR_STOP=1 -v righe_visite_attese=<N> -v righe_scadenze_attese=<M> \
--        -f 07_sorveglianza.sql
--
-- Porta `origine.visita` in `sorveglianza` (`0005`, `0024`) e, dove lo scadenzario
-- dissente dal calcolo, la scadenza dichiarata. Va dopo il passo 02: la persona si
-- riconosce dal codice fiscale. I due conteggi li stampa `estrai_visite.py`.
--
-- ============================================================================
--  DA DOVE, E PERCHE NON DAL FOGLIO CHE SI CREDEVA
-- ============================================================================
--
-- La scheda 10 e il piano parlano degli «808 accertamenti» del foglio «Visite» del
-- 09/09. Quel foglio porta **l'ultima esecuzione** per persona e tipo. La storia sta
-- in `ExportExcelVisiteFatte` (11/09/2026): 1.383 righe, e contiene il foglio tutto
-- — 800 coppie su 800 — piu' 250 coppie e 167 persone con piu' di una data.
-- Importare il foglio avrebbe tenuto l'ultima visita e buttato le altre, **con i
-- conti che tornavano lo stesso**. Il vincolo `sorveglianza_una_per_data` della
-- `0005` era stato scritto per reggere tutte e due le risposte: e' la storia a
-- esercitarlo.
--
-- ============================================================================
--  LE REGOLE
-- ============================================================================
--
-- **1. Una visita e' persona + accertamento + data.** Il file non ha un id. Due
-- righe con la stessa terna — misurato: 9 — sono la stessa visita registrata due
-- volte (per esempio su due aziende della stessa persona): entra una, e si contano.
--
-- **2. La persona dal codice fiscale**, come nei passi 04 e 05. Senza codice valido,
-- o con uno che l'anagrafe non ha, la visita **non entra e si conta**: 23 righe
-- della storia non hanno codice fiscale, 4 ne hanno uno che non ha la forma.
--
-- **3. L'accertamento dal nome, alla lettera.** I dieci nomi del file sono i dieci
-- `nome_gestionale` della `0005` carattere per carattere. Uno nuovo ferma il passo:
-- un accertamento senza periodicita' non ha una scadenza, e inventarla e' il difetto
-- che la `0005` e' nata per evitare.
--
-- **4. La scadenza dello scadenzario si confronta con la visita che lo scadenzario
-- conosceva.** Il file dichiara la sua data (06/08/2026); la visita di riferimento e'
-- l'ultima **fino a quella data**, non l'ultima in assoluto. Confrontarla con una
-- visita di fine agosto e' l'errore che ha prodotto le «nove anticipate» della scheda
-- 10, e ne ha lasciate vere due (`0024`).
--
--   * uguale al calcolo: non si scrive, si ricalcola;
--   * diversa: si scrive su **quella** visita, con la fonte e la data del file. Se la
--     persona e' stata rivista dopo, la dichiarazione resta sulla visita di prima —
--     dove dice il vero — e **si conta**: il motore legge l'ultima;
--   * nessuna visita fino a quella data: non c'e' dove scriverla, e si conta;
--   * due righe dello scadenzario sulla stessa persona e tipo con date diverse: non
--     si sceglie, e si conta.
--
-- **5. Cosa non si porta.** L'esito, il giudizio, il medico: la `0005` lo esclude
-- (art. 25 c. 1 lett. c, minimizzazione). E lo `Stato` dello scadenzario
-- («PIANIFICATA»): una visita prenotata non e' un fatto — si conta.
--
-- **Rieseguibile:** la visita entra con `on conflict do nothing` sulla sua terna, la
-- scadenza dichiarata si scrive solo dove e' vuota.

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.righe_visite_attese', :'righe_visite_attese', true);
select set_config('migrazione.righe_scadenze_attese', :'righe_scadenze_attese', true);

create temp view visita_norm as
select v.*,
       case when codice_fiscale_valido(v.codice_fiscale)
            then codice_fiscale_pulito(v.codice_fiscale) end as cf,
       'visite_fatte_' || to_char(to_date(substring(v.dichiarazione from '(\d{2}/\d{2}/\d{4})'), 'DD/MM/YYYY'), 'YYYYMMDD') as estrazione_codice
  from origine.visita v;

create temp view scadenza_norm as
select s.*,
       case when codice_fiscale_valido(s.codice_fiscale)
            then codice_fiscale_pulito(s.codice_fiscale) end as cf,
       to_date(substring(s.dichiarazione from '(\d{2}/\d{2}/\d{4})'), 'DD/MM/YYYY') as ancora,
       'visite_scadenze_' || to_char(to_date(substring(s.dichiarazione from '(\d{2}/\d{2}/\d{4})'), 'DD/MM/YYYY'), 'YYYYMMDD') as estrazione_codice
  from origine.visita_scadenza s;

-- ---------- i controlli, prima di scrivere ----------

do $$
declare n int; attese int;
begin
  attese := nullif(current_setting('migrazione.righe_visite_attese', true), '')::int;
  if attese is null then
    raise exception 'manca -v righe_visite_attese=<numero>: lo stampa estrai_visite.py';
  end if;
  select count(*) into n from origine.visita;
  if n <> attese then
    raise exception '(a) origine.visita ha % righe, l''estrazione ne dichiarava %: file troncato o di un altro giro', n, attese;
  end if;

  attese := nullif(current_setting('migrazione.righe_scadenze_attese', true), '')::int;
  if attese is null then
    raise exception 'manca -v righe_scadenze_attese=<numero>: lo stampa estrai_visite.py';
  end if;
  select count(*) into n from origine.visita_scadenza;
  if n <> attese then
    raise exception '(a) origine.visita_scadenza ha % righe, l''estrazione ne dichiarava %: file troncato o di un altro giro', n, attese;
  end if;

  select (select count(*) from origine.visita
           where dichiarazione is null or dichiarazione !~ '^Dati aggiornati al \d{2}/\d{2}/\d{4}')
       + (select count(*) from origine.visita_scadenza
           where dichiarazione is null or dichiarazione !~ '^Dati aggiornati al \d{2}/\d{2}/\d{4}')
       + (select greatest(count(distinct dichiarazione), 1) - 1 from origine.visita)
       + (select greatest(count(distinct dichiarazione), 1) - 1 from origine.visita_scadenza)
    into n;
  if n > 0 then
    raise exception '(b) i due file non hanno ciascuno una data dichiarata unica e leggibile: senza, lo scadenzario non si sa a quale visita riferirlo';
  end if;

  select count(*) into n from (
    select tipo from origine.visita
    union
    select tipo from origine.visita_scadenza) t
   where not exists (select 1 from accertamento a where a.nome_gestionale = t.tipo);
  if n > 0 then
    raise exception '(c) % tipi di accertamento che il vocabolario della 0005 non ha: senza periodicita non c''e una scadenza, si aggiunge prima', n;
  end if;

  select count(*) into n from origine.visita where data_esecuzione is null;
  if n > 0 then
    raise exception '(d) % visite senza data: la data e il fatto, dedurla sarebbe inventarla', n;
  end if;
  select count(*) into n from origine.visita_scadenza where data_scadenza is null;
  if n > 0 then
    raise exception '(d) % righe dello scadenzario senza data', n;
  end if;

  select count(*) into n
    from (select distinct estrazione_codice, dichiarazione from visita_norm
          union
          select distinct estrazione_codice, dichiarazione from scadenza_norm) f
    join origine_estrazione x on x.codice = f.estrazione_codice
   where x.dichiarazione <> f.dichiarazione;
  if n > 0 then
    raise exception '(e) % estrazioni gia registrate con lo stesso codice e un''altra dichiarazione', n;
  end if;
end $$;

-- ---------- da quale estrazione ----------

insert into origine_estrazione (codice, file, data_dichiarata, dichiarazione, righe, note)
select estrazione_codice, 'ExportExcelVisiteFatte.xlsx',
       to_date(substring(dichiarazione from '(\d{2}/\d{2}/\d{4})'), 'DD/MM/YYYY'),
       dichiarazione, count(*),
       'La storia delle visite: una riga per esecuzione. Letta da estrai_visite.py (passo 07).'
  from visita_norm group by estrazione_codice, dichiarazione
union all
select estrazione_codice, 'ExportExcelVisiteScadenze.xlsx', ancora, dichiarazione, count(*),
       'Lo scadenzario delle visite: una riga per persona e tipo. Si usa solo dove dissente dal calcolo sull''ultima visita nota a questa data (0024).'
  from scadenza_norm group by estrazione_codice, ancora, dichiarazione
on conflict (codice) do nothing;

-- ---------- regole 1, 2, 3: le visite ----------

create temp table visita_tradotta on commit drop as
select v.*, p.id as persona_dest, a.codice as accertamento_dest
  from visita_norm v
  left join persona p on p.codice_fiscale = v.cf
  join accertamento a on a.nome_gestionale = v.tipo;

create temp table visite_scritte on commit drop as
with scritte as (
  insert into sorveglianza (persona_id, accertamento, data_esecuzione, estrazione)
  select distinct on (persona_dest, accertamento_dest, data_esecuzione)
         persona_dest, accertamento_dest, data_esecuzione, estrazione_codice
    from visita_tradotta
   where persona_dest is not null
   order by persona_dest, accertamento_dest, data_esecuzione, riga
  on conflict (persona_id, accertamento, data_esecuzione) do nothing
  returning persona_id
)
select persona_id from scritte;

-- ---------- regola 4: la scadenza dichiarata ----------

create temp table confronto on commit drop as
with s as (
  select s.*, p.id as persona_dest, a.codice as accertamento_dest, a.periodicita_mesi,
         d.date_per_coppia
    from scadenza_norm s
    left join persona p on p.codice_fiscale = s.cf
    join accertamento a on a.nome_gestionale = s.tipo
    left join (select cf, tipo, count(distinct data_scadenza) as date_per_coppia
                 from scadenza_norm group by cf, tipo) d
           on d.cf is not distinct from s.cf and d.tipo = s.tipo
)
select s.*,
       (select max(x.data_esecuzione) from sorveglianza x
         where x.persona_id = s.persona_dest and x.accertamento = s.accertamento_dest
           and x.data_esecuzione <= s.ancora) as visita_nota,
       exists (select 1 from sorveglianza x
                where x.persona_id = s.persona_dest and x.accertamento = s.accertamento_dest
                  and x.data_esecuzione > s.ancora) as rivista_dopo
  from s;

create temp table dichiarate on commit drop as
with scritte as (
  update sorveglianza x
     set scadenza_dichiarata = c.data_scadenza,
         scadenza_fonte = 'ExportExcelVisiteScadenze («' || c.dichiarazione || '»): scadenza diversa da quella calcolata sull''ultima visita nota a quella data (migrazione dati, passo 07)'
    from confronto c
   where c.persona_dest is not null
     and c.date_per_coppia = 1
     and c.visita_nota is not null
     and c.data_scadenza > c.visita_nota
     and c.data_scadenza <> (c.visita_nota + (c.periodicita_mesi || ' months')::interval)::date
     and x.persona_id = c.persona_dest
     and x.accertamento = c.accertamento_dest
     and x.data_esecuzione = c.visita_nota
     and x.scadenza_dichiarata is null
  returning x.id
)
select id from scritte;

-- ---------- i conti ----------

do $$
declare
  righe int; terne int; doppie int; senza_cf int; senza_persona int; scritte int; gia int; persone int;
  nel_futuro int; per_tipo text;
  s_righe int; s_senza_cf int; s_senza_persona int; s_ambigue int; s_senza_visita int;
  s_uguali int; s_anticipate int; s_posticipate int; s_rotte int; s_rivisti int; s_scritte int; s_pianificate int;
  anticipate_vive int;
begin
  select count(*), count(*) filter (where cf is null),
         count(*) filter (where cf is not null and persona_dest is null)
    into righe, senza_cf, senza_persona
    from visita_tradotta;
  select count(*) into terne from (
    select distinct persona_dest, accertamento_dest, data_esecuzione
      from visita_tradotta where persona_dest is not null) t;
  select count(*) filter (where persona_dest is not null) - terne into doppie from visita_tradotta;
  select count(*) into scritte from visite_scritte;
  gia := terne - scritte;
  select count(distinct persona_id) into persone from sorveglianza;
  select count(*) into nel_futuro from visita_tradotta
   where persona_dest is not null and data_esecuzione > current_date;
  select string_agg(accertamento || ' ' || n, ', ' order by n desc, accertamento) into per_tipo
    from (select accertamento, count(*) n from sorveglianza group by accertamento) t;

  select count(*),
         count(*) filter (where cf is null),
         count(*) filter (where cf is not null and persona_dest is null),
         count(*) filter (where persona_dest is not null and date_per_coppia > 1),
         count(*) filter (where persona_dest is not null and date_per_coppia = 1 and visita_nota is null),
         count(*) filter (where persona_dest is not null and date_per_coppia = 1 and visita_nota is not null
                            and data_scadenza = (visita_nota + (periodicita_mesi || ' months')::interval)::date),
         count(*) filter (where persona_dest is not null and date_per_coppia = 1 and visita_nota is not null
                            and data_scadenza > visita_nota
                            and data_scadenza < (visita_nota + (periodicita_mesi || ' months')::interval)::date),
         count(*) filter (where persona_dest is not null and date_per_coppia = 1 and visita_nota is not null
                            and data_scadenza > (visita_nota + (periodicita_mesi || ' months')::interval)::date),
         count(*) filter (where persona_dest is not null and date_per_coppia = 1 and visita_nota is not null
                            and data_scadenza <= visita_nota),
         count(*) filter (where persona_dest is not null and date_per_coppia = 1 and visita_nota is not null
                            and data_scadenza <> (visita_nota + (periodicita_mesi || ' months')::interval)::date
                            and rivista_dopo),
         count(*) filter (where stato is not null and stato <> '')
    into s_righe, s_senza_cf, s_senza_persona, s_ambigue, s_senza_visita,
         s_uguali, s_anticipate, s_posticipate, s_rotte, s_rivisti, s_pianificate
    from confronto;
  select count(*) into s_scritte from dichiarate;
  select count(*) into anticipate_vive from v_sorveglianza where anticipata;

  raise notice 'visite d''origine %  ->  visite scritte %, su % persone (%)', righe, scritte, persone, per_tipo;
  if gia > 0 then
    raise notice '  gia presenti da un giro precedente: %', gia;
  end if;
  raise notice '  la stessa visita registrata piu volte (persona, tipo, data): % righe in piu, entrate una volta', doppie;
  raise notice '  NON entrate: % senza codice fiscale valido, % con un codice fiscale che l''anagrafe non ha', senza_cf, senza_persona;
  raise notice '  visite con una data nel futuro: %', nel_futuro;
  raise notice 'scadenzario %: uguali al calcolo % (non si scrivono), anticipate %, posticipate %, prima della visita stessa % (dato rotto, non scritto)', s_righe, s_uguali, s_anticipate, s_posticipate, s_rotte;
  raise notice '  scadenze dichiarate scritte: % (anticipate vive nella vista: %), di cui su una persona rivista dopo la data del file: %', s_scritte, anticipate_vive, s_rivisti;
  raise notice '  NON usate: % senza codice fiscale valido, % fuori anagrafe, % senza nessuna visita fino alla data del file, % su una coppia con piu date', s_senza_cf, s_senza_persona, s_senza_visita, s_ambigue;
  raise notice '  righe con uno Stato (PIANIFICATA): % (una visita prenotata non e un fatto: non si porta)', s_pianificate;
end $$;

commit;
