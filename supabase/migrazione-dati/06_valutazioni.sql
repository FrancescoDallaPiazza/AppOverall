-- AppOverall — migrazione dati, passo 06: l'ATECO e i livelli, sulle sedi.
--
--   psql -v ON_ERROR_STOP=1 -f 06_valutazioni.sql
--
-- Porta da `origine.cliente` la divisione ATECO, la sua cella d'origine e i tre
-- livelli — rischio, antincendio, primo soccorso — sulle sedi che il passo 01 ha
-- creato (`cliente_origine.sede_id`). Va dopo il passo 01, e carica da se' la copia
-- dell'Allegato IV (`allegato_iv.sql`, generata dalla libreria).
--
-- ============================================================================
--  LE TRE COSE DECISE PRIMA, E DA CHI
-- ============================================================================
--
-- **L'annata e' '2007'** (Francesco, 16 settembre 2026). Il piano la lasciava «da
-- verificare» a grana di divisione: verificata il 17. AppFormazione ha misurato che
-- le 88 divisioni dell'Allegato IV e le 88 di ATECO 2022 sono lo stesso insieme (loro
-- `0048`), e l'allegato dice di se' «ancorata ad ATECO 2007 agg. 2022». A due cifre
-- 2007 e 2022 non si distinguono; il valore si chiama '2007' perche' cosi' lo chiama
-- la norma. La differenza vera e' con il **2025**, e questi codici non lo sono: sono
-- divisioni derivate da celle del gestionale, e il gestionale classifica 2007.
--
-- **Firma Francesco** (16 settembre 2026), e la motivazione dice che cosa quella
-- firma significa: che le valutazioni sono **migrate**, non che le ha prese lui una
-- per una.
--
-- **Il livello che la tabella da' non si scrive** (decisione 8, 9 settembre 2026).
-- «Il default resta calcolato dall'ATECO e non si sovrascrive»: in `valutazione_sede`
-- entra solo lo **scostamento**. Il piano del 16 diceva «i livelli qui sono
-- `valutazione_sede`» tutti quanti, ed era impreciso: vale per antincendio e primo
-- soccorso, che una tabella non la hanno, e **non** per il rischio uguale al default.
--
-- ============================================================================
--  LE REGOLE
-- ============================================================================
--
-- **1. L'ATECO va sulla sede, con l'annata e con la cella.** La divisione com'e',
-- portata a due cifre se all'origine ne ha una sola — come fa la libreria
-- (`classificaAteco2007`) — e la cella verbatim in `ateco_origine` (`0023`). Una
-- sede che ha gia' un ATECO diverso non si tocca: si conta.
--
-- **2. Il rischio uguale al default non si scrive.** Uguale al livello che l'Allegato
-- IV da' alla divisione: si ricalcola, e se un giorno la tabella cambia la sede
-- segue la tabella — che e' esattamente cio' che la decisione 8 vuole.
--
-- **3. Il rischio diverso dal default si scrive**, e cosi' quello di una sede senza
-- divisione o con una divisione che l'allegato non ha: in quei casi il default non
-- c'e', e il livello e' per forza una scelta. La motivazione porta il testo che
-- AppSopralluoghi ha scritto accanto (`livello_rischio_definito_mediante`, loro
-- `072`), verbatim, e il default che la tabella darebbe.
--
-- **4. Antincendio e primo soccorso si scrivono sempre**, quando ci sono. Non hanno
-- una tabella da cui ricalcolarli: un livello definito e' una decisione, e il testo
-- di chi l'ha presa (loro `050` e `051`) va nella motivazione. `BC`, il gruppo di
-- prima della loro `050`, si porta com'e' e si conta: il motore lo tratta come B e C
-- (decisione 11), e riscriverlo qui sarebbe scegliere per chi l'ha scritto.
--
-- **5. Una valutazione viva che c'e' gia' non si scavalca.** Se qualcuno ha gia'
-- deciso su quella sede e quell'attributo, la sua riga resta e la migrata no: si
-- conta.
--
-- **6. Cosa non si porta, e si conta.** Il testo di un rischio **tolto** (livello
-- vuoto, testo presente): non c'e' un valore da annotare, e `valutazione_sede` non
-- ha una riga senza valore. E il testo accanto a un rischio **uguale** al default
-- quando non dice `tabella_ateco`: e' il caso in cui la regola 2 perde una frase, e
-- va visto se succede.
--
-- **Rieseguibile:** l'ATECO si scrive solo dove manca, le valutazioni entrano con
-- `on conflict do nothing` sull'unica viva per attributo, l'operatore si crea solo
-- se non c'e'.

\set ON_ERROR_STOP on

begin;

\ir allegato_iv.sql

-- ---------- la base, una riga per unita' d'origine ----------

create temp view base as
select o.id as origine_id,
       m.sede_id,
       nullif(btrim(o.codice_ateco), '') as ateco_grezzo,
       case when btrim(o.codice_ateco) ~ '^\d{1,2}$'
            then lpad(btrim(o.codice_ateco), 2, '0') end as divisione,
       o.ateco_origine,
       nullif(btrim(o.livello_rischio), '') as rischio,
       nullif(btrim(o.livello_antincendio), '') as antincendio,
       nullif(btrim(o.gruppo_primo_soccorso), '') as primo_soccorso,
       nullif(btrim(o.livello_rischio_definito_mediante), '') as rischio_come,
       nullif(btrim(o.antincendio_definito_mediante), '') as antincendio_come,
       nullif(btrim(o.primo_soccorso_definito_mediante), '') as primo_soccorso_come
  from origine.cliente o
  left join cliente_origine m on m.origine_id = o.id;

create temp view base_classe as
select b.*, a.livello as di_tabella, a.dedotto
  from base b
  left join origine.allegato_iv a on a.divisione = b.divisione;

-- ---------- i controlli, prima di scrivere ----------

do $$
declare n int;
begin
  select count(*) into n from origine.allegato_iv;
  if n <> 88 then
    raise exception '(a) la copia dell''Allegato IV ha % divisioni, non 88: rigenerarla con genera_allegato_iv.js', n;
  end if;

  -- Un'unita senza sede legale all'origine non ha una sede qui (passo 01, regola 5):
  -- e' un problema solo se ha qualcosa da portare, perche' non c'e' dove metterlo.
  select count(*) into n from base
   where sede_id is null
     and coalesce(ateco_grezzo, rischio, antincendio, primo_soccorso) is not null;
  if n > 0 then
    raise exception '(b) % unita d''origine con ATECO o livelli e senza una sede: il passo 01 non e stato eseguito, o l''unita non ha una sede legale, e il dato non ha dove andare', n;
  end if;

  select count(*) into n from base where ateco_grezzo is not null and divisione is null;
  if n > 0 then
    raise exception '(c) % codici ATECO che non sono una divisione a una o due cifre: la grana e cambiata, si guarda prima di portarla', n;
  end if;

  select count(*) into n from base
   where (rischio is not null and rischio not in ('basso', 'medio', 'alto'))
      or (antincendio is not null and antincendio not in ('1', '2', '3'))
      or (primo_soccorso is not null and primo_soccorso not in ('A', 'B', 'C', 'BC'));
  if n > 0 then
    raise exception '(d) % unita con un livello fuori dal vocabolario d''origine: non si traduce, si guarda', n;
  end if;

  select count(*) into n from operatore where cognome = 'Dalla Piazza' and nome = 'Francesco';
  if n > 1 then
    raise exception '(e) % operatori Francesco Dalla Piazza: la firma deve puntare a uno solo', n;
  end if;
end $$;

-- ---------- chi firma ----------

insert into operatore (cognome, nome, ruolo)
select 'Dalla Piazza', 'Francesco', 'amministrazione'
 where not exists (select 1 from operatore where cognome = 'Dalla Piazza' and nome = 'Francesco');

create temp table firma on commit drop as
select id as operatore_id,
       to_char(current_date, 'DD/MM/YYYY') as oggi
  from operatore where cognome = 'Dalla Piazza' and nome = 'Francesco';

-- ---------- regola 1: l'ATECO ----------

create temp table ateco_scritto on commit drop as
with scritte as (
  update sede s
     set codice_ateco = b.divisione,
         ateco_versione = '2007',
         ateco_origine = b.ateco_origine
    from base b
   where b.sede_id = s.id
     and b.divisione is not null
     and s.codice_ateco is null
  returning s.id
)
select id from scritte;

-- ---------- regole 2, 3 e 4: le valutazioni ----------

create temp table da_scrivere on commit drop as
select b.sede_id, 'livello_rischio'::text as attributo, b.rischio as valore,
       'Migrato dal gestionale (AppSopralluoghi) il ' || f.oggi || '. '
       || case when b.di_tabella is null and b.divisione is null
               then 'La sede non ha una divisione ATECO, quindi un default non c''e: il livello e una scelta. '
               when b.di_tabella is null
               then 'La divisione ' || b.divisione || ' non e nell''Allegato IV, quindi un default non c''e. '
               else 'L''Allegato IV darebbe ' || b.di_tabella || ' alla divisione ' || b.divisione
                    || case when b.dedotto then ' (valore dedotto dal 2011, decisione 5)' else '' end || '. '
          end
       || case when b.rischio_come is null
               then 'Come e stato deciso non risulta.'
               else 'Come e stato deciso, secondo il gestionale: «' || b.rischio_come || '»'
          end as motivazione,
       'AppSopralluoghi, cliente.livello_rischio e livello_rischio_definito_mediante (migrazione dati, passo 06)' as fonte
  from base_classe b cross join firma f
 where b.rischio is not null
   and b.rischio is distinct from b.di_tabella
union all
select b.sede_id, 'livello_antincendio', b.antincendio,
       'Migrato dal gestionale (AppSopralluoghi) il ' || f.oggi || '. '
       || case when b.antincendio_come is null
               then 'Come e stato deciso non risulta.'
               else 'Come e stato deciso, secondo il gestionale: «' || b.antincendio_come || '»'
          end,
       'AppSopralluoghi, cliente.livello_antincendio e antincendio_definito_mediante (migrazione dati, passo 06)'
  from base b cross join firma f
 where b.antincendio is not null
union all
select b.sede_id, 'gruppo_primo_soccorso', b.primo_soccorso,
       'Migrato dal gestionale (AppSopralluoghi) il ' || f.oggi || '. '
       || case when b.primo_soccorso_come is null
               then 'Come e stato deciso non risulta.'
               else 'Come e stato deciso, secondo il gestionale: «' || b.primo_soccorso_come || '»'
          end,
       'AppSopralluoghi, cliente.gruppo_primo_soccorso e primo_soccorso_definito_mediante (migrazione dati, passo 06)'
  from base b cross join firma f
 where b.primo_soccorso is not null;

create temp table valutazioni_scritte on commit drop as
with scritte as (
  insert into valutazione_sede (sede_id, attributo, valore, motivazione, fonte, deciso_da)
  select d.sede_id, d.attributo, d.valore, d.motivazione, d.fonte, f.operatore_id
    from da_scrivere d cross join firma f
  on conflict (sede_id, attributo) where revocato_il is null do nothing
  returning attributo
)
select attributo from scritte;

-- ---------- i conti, e cosa non e' entrato ----------

do $$
declare
  unita int; con_ateco int; ateco_nuovi int; allargate int; fuori_tabella int; con_cella int; ateco_diversi int;
  rischi int; uguali int; uguali_dedotti int; scostamenti int; senza_default int;
  come_tabella int; come_altro int; come_nullo int; frasi_perse int; tolti int;
  antincendi int; soccorsi int; bc int;
  scritti_r int; scritti_a int; scritti_p int; gia_vive int; gia_vive_diverse int;
begin
  select count(*), count(divisione), count(*) filter (where ateco_grezzo ~ '^\d$'),
         count(*) filter (where divisione is not null and di_tabella is null),
         count(*) filter (where divisione is not null and ateco_origine is not null)
    into unita, con_ateco, allargate, fuori_tabella, con_cella
    from base_classe;
  select count(*) into ateco_nuovi from ateco_scritto;
  select count(*) into ateco_diversi
    from base b join sede s on s.id = b.sede_id
   where b.divisione is not null and s.codice_ateco is distinct from b.divisione;

  select count(*) filter (where rischio is not null),
         count(*) filter (where rischio is not null and rischio = di_tabella),
         count(*) filter (where rischio is not null and rischio = di_tabella and dedotto),
         count(*) filter (where rischio is not null and di_tabella is not null and rischio <> di_tabella),
         count(*) filter (where rischio is not null and di_tabella is null),
         count(*) filter (where rischio is not null and rischio_come ~ '^tabella_ateco'),
         count(*) filter (where rischio is not null and rischio_come is not null and rischio_come !~ '^tabella_ateco'),
         count(*) filter (where rischio is not null and rischio_come is null),
         count(*) filter (where rischio = di_tabella and rischio_come is not null and rischio_come !~ '^tabella_ateco'),
         count(*) filter (where rischio is null and rischio_come is not null),
         count(*) filter (where antincendio is not null),
         count(*) filter (where primo_soccorso is not null),
         count(*) filter (where primo_soccorso = 'BC')
    into rischi, uguali, uguali_dedotti, scostamenti, senza_default,
         come_tabella, come_altro, come_nullo, frasi_perse, tolti,
         antincendi, soccorsi, bc
    from base_classe;

  select count(*) filter (where attributo = 'livello_rischio'),
         count(*) filter (where attributo = 'livello_antincendio'),
         count(*) filter (where attributo = 'gruppo_primo_soccorso')
    into scritti_r, scritti_a, scritti_p
    from valutazioni_scritte;

  select count(*), count(*) filter (where v.valore <> d.valore)
    into gia_vive, gia_vive_diverse
    from da_scrivere d
    join valutazione_sede v on v.sede_id = d.sede_id and v.attributo = d.attributo and v.revocato_il is null
   where v.fonte is distinct from d.fonte;

  raise notice 'unita d''origine %  ->  divisioni ATECO %, scritte ora su % sedi (annata 2007)', unita, con_ateco, ateco_nuovi;
  raise notice '  divisioni a una cifra portate a due: %, divisioni che l''Allegato IV non ha: %, con la cella d''origine: %', allargate, fuori_tabella, con_cella;
  raise notice '  sedi con un ATECO gia diverso, non toccate: %', ateco_diversi;
  raise notice 'livelli di rischio %: uguali al default % (non si scrivono, si ricalcolano; % su una divisione dedotta), diversi dal default %, senza un default %', rischi, uguali, uguali_dedotti, scostamenti, senza_default;
  raise notice '  come e stato deciso, secondo il gestionale: tabella_ateco %, altro testo %, non risulta %', come_tabella, come_altro, come_nullo;
  raise notice '  valutazioni di rischio scritte: %', scritti_r;
  raise notice 'livelli antincendio %, valutazioni scritte %', antincendi, scritti_a;
  raise notice 'gruppi di primo soccorso % (di cui BC, il gruppo di prima della loro 050: %), valutazioni scritte %', soccorsi, bc, scritti_p;
  raise notice '  NON portati: % testi di un rischio tolto (nessun valore da annotare), % testi accanto a un rischio uguale al default che non dicono tabella_ateco', tolti, frasi_perse;
  raise notice '  valutazioni gia vive da un''altra mano, non scavalcate: % (di cui con un valore diverso: %)', gia_vive, gia_vive_diverse;
end $$;

commit;
