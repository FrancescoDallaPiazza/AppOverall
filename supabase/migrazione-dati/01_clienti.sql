-- AppOverall — migrazione dati, passo 01
-- I clienti e le sedi: un cliente-unita d'origine diventa un cliente piu una sede.
--
-- Uso, dopo il passo 00 e con la `0017` applicata:
--
--   psql -v ON_ERROR_STOP=1 -v clienti_attesi=<count> -v sedi_attese=<count> -f 01_clienti.sql
--
-- ============================================================================
--  LE REGOLE
-- ============================================================================
--
-- All'origine un cliente e un'**unita**; qui il cliente e la P.IVA e l'unita e la
-- sede (`0017`). Le regole, ognuna con la sua ragione:
--
--   1. **Una P.IVA usabile, un cliente.** I clienti d'origine con la stessa P.IVA
--      usabile confluiscono in uno, che tiene l'uuid del **superstite**: il primo
--      per `attivo` (gli attivi prima), poi per data di creazione, poi per id —
--      cosi il risultato non dipende dall'ordine di lettura. E l'unica fusione:
--      la `0001` rende `partita_iva` unica, e la decisione 2 dice perche.
--
--   2. **Senza P.IVA usabile, un cliente per riga, sempre con lo stesso uuid.** Due
--      righe con la stessa ragione sociale o lo stesso codice fiscale **non si
--      fondono**: si ferma tutto (rifiuto f). Fondere per nome e la mossa che
--      questo repo ha gia ritirato piu volte.
--
--   3. **La P.IVA non usabile vale come assente, e la cella resta accanto**
--      (`partita_iva_origine`). Deciso da Francesco il 14 settembre; «usabile» e
--      `partita_iva_usabile` della `0017`, che **non** e la guardia d'origine.
--
--   4. **Ogni sede d'origine diventa una sede con lo stesso uuid**, sotto il cliente
--      in cui e confluito il suo cliente. Resta principale solo la sede legale del
--      superstite; quella di un'unita assorbita diventa una sede come le altre.
--
--   5. **`N DIPENDENTI` va sulla sede legale della sua unita**, perche e un numero
--      per unita (`0017`). Mai sommato in migrazione.
--
-- ============================================================================
--  QUANDO SI RIFIUTA
-- ============================================================================
--
-- In una transazione, prima di scrivere:
--
--   a. il numero di clienti o di sedi non e quello dichiarato;
--   b. un cliente senza ragione sociale — qui e `not null`;
--   c. una sede d'origine punta a un cliente che non e nell'estrazione;
--   d. un cliente d'origine con piu di una sede principale;
--   e. un numero di dipendenti che non e positivo, o che non ha una sede legale
--      dove stare — altrimenti andrebbe perso in silenzio;
--   f. due clienti **senza P.IVA usabile** con la stessa chiave (codice fiscale o
--      ragione sociale): la regola 2 non li fonde, e la chiave unica non li tiene;
--   g. due unita con la stessa P.IVA e **due `werp_id` diversi**: il cliente e uno e
--      il legame con WERP e uno, e sceglierne uno perderebbe l'altro.
--
-- Rieseguibile: un cliente d'origine gia in `cliente_origine` si salta, una sede
-- gia presente si salta, e un'unita nuova con una P.IVA gia presente confluisce
-- nel cliente che c'e.
--
-- ============================================================================
--  COSA NON PORTA, E LO CONTA
-- ============================================================================
--
-- **ATECO**: il codice sta all'origine senza annata, e la `0001` dice che un codice
-- senza annata non si sa leggere (2.166 stringhe in due classificazioni, 62 che
-- cambiano classe). **Livelli di rischio, antincendio, primo soccorso**: qui sono
-- una `valutazione_sede` con una motivazione e un operatore, e all'origine sono un
-- valore senza ne l'una ne l'altro. **Contatti, referenti, coordinate**: fuori dal
-- perimetro dell'anagrafe. Restano nell'estrazione e nel database d'origine; questo
-- passo stampa **quanti clienti ne avevano**, perche un dato non portato e diverso
-- da un dato che non c'era.

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.clienti_attesi', :'clienti_attesi', true);
select set_config('migrazione.sedi_attese', :'sedi_attese', true);

-- ---------- le normalizzazioni, una volta sola ----------
--
-- `den` e `normNome` d'origine: spazi collassati, maiuscolo, punti finali via,
-- trim — in quest'ordine. La chiave segue l'ordine con cui l'origine riconosce un
-- cliente: P.IVA, poi codice fiscale, poi ragione sociale.

create temp view cli_tutti as
select o.*,
       case when partita_iva_usabile(o.partita_iva)
            then regexp_replace(o.partita_iva, '\s', '', 'g') end as piva,
       nullif(upper(regexp_replace(coalesce(o.codice_fiscale, ''), '\s', '', 'g')), '') as codf,
       btrim(regexp_replace(upper(regexp_replace(coalesce(o.ragione_sociale, ''), '\s+', ' ', 'g') collate "und-x-icu"), '\.+$', '')) as den
  from origine.cliente o;

-- ---------- i rifiuti, prima di scrivere ----------

do $$
declare
  attesi text := current_setting('migrazione.clienti_attesi');
  attese text := current_setting('migrazione.sedi_attese');
  n bigint;
begin
  if attesi !~ '^[0-9]+$' or attese !~ '^[0-9]+$' then
    raise exception 'mancano -v clienti_attesi e -v sedi_attese: senza, un''estrazione troncata passerebbe per intera';
  end if;

  select count(*) into n from origine.cliente;
  if n <> attesi::bigint then
    raise exception '(a) origine.cliente ha % righe, l''estrazione ne dichiarava %', n, attesi;
  end if;
  select count(*) into n from origine.sede;
  if n <> attese::bigint then
    raise exception '(a) origine.sede ha % righe, l''estrazione ne dichiarava %', n, attese;
  end if;

  select count(*) into n from origine.cliente where btrim(coalesce(ragione_sociale, '')) = '';
  if n > 0 then raise exception '(b) % clienti senza ragione sociale', n; end if;

  select count(*) into n from origine.sede s
   where not exists (select 1 from origine.cliente c where c.id = s.cliente_id);
  if n > 0 then raise exception '(c) % sedi puntano a un cliente che non e nell''estrazione', n; end if;

  select count(*) into n from (
    select cliente_id from origine.sede where principale group by 1 having count(*) > 1) x;
  if n > 0 then raise exception '(d) % clienti con piu di una sede principale', n; end if;

  select count(*) into n from origine.cliente where numero_lavoratori <= 0;
  if n > 0 then raise exception '(e) % clienti con un numero di dipendenti non positivo', n; end if;
  select count(*) into n from origine.cliente c
   where c.numero_lavoratori is not null
     and not exists (select 1 from origine.sede s where s.cliente_id = c.id and s.principale);
  if n > 0 then raise exception '(e) % clienti con un numero di dipendenti e nessuna sede legale dove portarlo', n; end if;

  select count(*) into n from (
    select coalesce('cf:' || codf, 'den:' || den) from cli_tutti
     where piva is null group by 1 having count(*) > 1) x;
  if n > 0 then raise exception '(f) % chiavi ripetute fra clienti senza P.IVA usabile: non si fondono, e non si possono chiavare', n; end if;

  select count(*) into n from (
    select piva from cli_tutti
     where piva is not null and nullif(werp_id, '') is not null
     group by 1 having count(distinct werp_id) > 1) x;
  if n > 0 then raise exception '(g) % P.IVA con unita che portano werp_id diversi', n; end if;
end
$$;

-- ---------- i clienti d'origine ancora da portare ----------

create temp table cli on commit drop as
select * from cli_tutti t
 where not exists (select 1 from cliente_origine m where m.origine_id = t.id);

-- ---------- regola 1: un cliente per P.IVA usabile ----------

insert into cliente (id, partita_iva, partita_iva_origine, codice_fiscale, ragione_sociale,
                     attivo, werp_id, import_key)
select distinct on (c.piva)
       c.id, c.piva, nullif(btrim(c.partita_iva), ''), nullif(btrim(c.codice_fiscale), ''), c.ragione_sociale,
       bool_or(c.attivo) over (partition by c.piva),
       max(nullif(c.werp_id, '')) over (partition by c.piva),
       'sedi:piva:' || c.piva
  from cli_tutti c
 where c.piva is not null
   and exists (select 1 from cli n where n.piva = c.piva)
   and not exists (select 1 from cliente x where x.partita_iva = c.piva)
 order by c.piva, c.attivo desc, c.created_at, c.id;

-- un'unita nuova e attiva riaccende il cliente in cui confluisce
update cliente x set attivo = true
  from cli c
 where c.piva is not null and c.attivo and x.partita_iva = c.piva and not x.attivo;

-- ---------- regola 2: un cliente per riga, senza P.IVA usabile ----------

insert into cliente (id, partita_iva, partita_iva_origine, codice_fiscale, ragione_sociale,
                     attivo, werp_id, import_key)
select id, null, nullif(btrim(partita_iva), ''), nullif(btrim(codice_fiscale), ''), ragione_sociale,
       attivo, nullif(werp_id, ''),
       coalesce('sedi:cf:' || codf, 'sedi:den:' || den)
  from cli
 where piva is null;

-- ---------- dove e finito ogni cliente d'origine ----------

insert into cliente_origine (origine_id, cliente_id, assorbito)
select c.id, d.id, d.id <> c.id
  from cli c
  join cliente d on (c.piva is not null and d.partita_iva = c.piva)
                 or (c.piva is null and d.id = c.id);

-- ---------- regole 4 e 5: le sedi ----------

insert into sede (id, cliente_id, denominazione, indirizzo, comune, provincia,
                  principale, attiva, n_dipendenti_gestionale, import_key)
select s.id, m.cliente_id, s.nome,
       nullif(btrim(s.indirizzo), ''), nullif(btrim(s.localita), ''), nullif(btrim(s.provincia), ''),
       s.principale and not m.assorbito,
       s.attivo and oc.attivo,
       case when s.principale then oc.numero_lavoratori end,
       d.import_key || case when s.principale and not m.assorbito then ':legale'
                            else ':sede:' || s.id end
  from origine.sede s
  join cliente_origine m on m.origine_id = s.cliente_id
  join origine.cliente oc on oc.id = s.cliente_id
  join cliente d on d.id = m.cliente_id
 where not exists (select 1 from sede t where t.id = s.id);

update cliente_origine m set sede_id = s.id
  from origine.sede s
 where s.cliente_id = m.origine_id and s.principale and m.sede_id is null;

-- ---------- i conti, calcolati dall'origine ----------

do $$
declare
  clienti_attesi bigint; clienti bigint; sedi bigint; n bigint;
  dip_origine bigint; dip_qui bigint;
  fusi bigint; assorbiti bigint; discordi bigint; scartate bigint; segnaposto bigint;
  con_ateco bigint; con_livello bigint; non_legali bigint; doppi bigint;
begin
  select count(distinct piva) + count(*) filter (where piva is null)
    into clienti_attesi from cli_tutti;

  select count(*) into n from origine.cliente o
   where not exists (select 1 from cliente_origine m where m.origine_id = o.id);
  if n > 0 then raise exception '% clienti d''origine senza una destinazione', n; end if;

  select count(distinct m.cliente_id) into clienti
    from cliente_origine m join origine.cliente o on o.id = m.origine_id;
  if clienti <> clienti_attesi then
    raise exception 'clienti %, attesi % (P.IVA usabili distinte + clienti senza P.IVA usabile)', clienti, clienti_attesi;
  end if;

  select count(*) into n from origine.sede s where not exists (select 1 from sede t where t.id = s.id);
  if n > 0 then raise exception '% sedi d''origine non portate', n; end if;
  select count(*) into sedi from sede t join origine.sede s on s.id = t.id;

  select count(*) into n from cliente x join cliente_origine m on m.cliente_id = x.id
   where x.import_key is null;
  if n > 0 then raise exception '% clienti portati senza import_key', n; end if;

  select count(*) into n from cliente x join cliente_origine m on m.cliente_id = x.id
   where x.partita_iva is not null and not partita_iva_usabile(x.partita_iva);
  if n > 0 then raise exception '% clienti con una P.IVA non usabile scritta come chiave', n; end if;

  select coalesce(sum(o.numero_lavoratori), 0) into dip_origine from origine.cliente o;
  select coalesce(sum(t.n_dipendenti_gestionale), 0) into dip_qui
    from sede t join origine.sede s on s.id = t.id;
  if dip_qui <> dip_origine then
    raise exception 'dipendenti sulle sedi %, all''origine %: la regola 5 ne ha perso o inventato', dip_qui, dip_origine;
  end if;

  select count(*) filter (where n_unita > 1), coalesce(sum(n_unita - 1) filter (where n_unita > 1), 0),
         count(*) filter (where n_nomi > 1)
    into fusi, assorbiti, discordi
    from (select piva, count(*) n_unita, count(distinct den) n_nomi
            from cli_tutti where piva is not null group by piva) g;
  select count(*) filter (where btrim(coalesce(partita_iva, '')) <> '' and piva is null),
         count(*) filter (where regexp_replace(coalesce(partita_iva, ''), '\s', '', 'g') ~ '^([0-9])\1{10}$')
    into scartate, segnaposto from cli_tutti;
  select count(*) filter (where nullif(btrim(codice_ateco), '') is not null),
         count(*) filter (where coalesce(livello_rischio, livello_antincendio, gruppo_primo_soccorso) is not null)
    into con_ateco, con_livello from origine.cliente;
  select count(*) into non_legali from sede t join origine.sede s on s.id = t.id
   where t.import_key not like '%:legale';

  -- Il doppione che la regola 1 non vede e la regola 2 non ferma: la stessa unita
  -- scritta due volte all'origine, una con la P.IVA e una senza. Diventa due clienti
  -- qui, e nessun vincolo protesta. Si CONTA e non si fonde — fondere per nome e la
  -- mossa che questo repo non fa — perche il posto giusto per chiuderlo e l'origine,
  -- prima dell'estrazione. Trovato il 14 settembre sul caso PROGETTO EMERA ONLUS.
  select count(*) into doppi from cli_tutti a
   where a.piva is null
     and exists (select 1 from cli_tutti b where b.piva is not null and b.den = a.den);

  raise notice 'clienti d''origine %  ->  clienti %, sedi %', (select count(*) from origine.cliente), clienti, sedi;
  raise notice '  fusioni per P.IVA: % clienti da piu unita, % unita assorbite, % con ragioni sociali discordi (vince il superstite)', fusi, assorbiti, discordi;
  raise notice '  P.IVA scritte e non usabili: %, di cui % segnaposto a cifre tutte uguali (usabili per la guardia d''origine)', scartate, segnaposto;
  raise notice '  sedi che non sono la sede legale del loro cliente: %', non_legali;
  raise notice '  NON portati: ATECO su % clienti, almeno un livello su %', con_ateco, con_livello;
  raise notice '  possibili doppioni non fusi: % clienti senza P.IVA usabile con la ragione sociale di uno che ce l''ha', doppi;
end
$$;

commit;
