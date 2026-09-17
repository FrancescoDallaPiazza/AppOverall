-- AppOverall — migrazione dati, passo 08: il riscontro con lo scadenzario di Sicurweb.
--
--   psql -v ON_ERROR_STOP=1 -v righe_scadenzario_attese=<N> -f 08_riscontro_sicurweb.sql
--
-- **Non scrive niente.** E' il criterio d'uscita della Fase 4 messo in numeri
-- (`docs/piano-fase-4.md`): per ogni persona e corso, la scadenza di Sicurweb accanto a
-- quella del motore (`0026`), e ogni coppia in una categoria sola. Va dopo tutti gli
-- altri passi, perche' il motore legge quello che hanno scritto.
--
-- ============================================================================
--  LA GRANA DEL CONFRONTO
-- ============================================================================
--
-- Sicurweb tiene lo scadenzario **per titolo**, il motore **per obbligo**. Il punto
-- d'incontro e' il **corso curato**: il titolo diventa corso con i 268 alias (come nel
-- passo 04), e il motore dice, per ogni obbligo, **quale corso** ha dato la scadenza.
-- Quando piu' titoli portano allo stesso corso — `Aggiornamento lavoratori 6 ore` e
-- `Formazione specifica rischio alto` sono entrambi `LAV_SPEC` — per Sicurweb vale la
-- scadenza **piu' lontana**: e' l'ultimo rinnovo, ed e' quella che il gestionale
-- solleciterebbe.
--
-- Le due fotografie sono dello stesso istante: lo scadenzario dichiara il 06/08/2026
-- come gli attestati di AppFormazione. Si confrontano **le date**, non gli stati: lo
-- stato dipende dal giorno in cui si guarda.
--
-- ============================================================================
--  LE CATEGORIE, E OGNUNA DICE COSA FARE
-- ============================================================================
--
--   uguale                     la stessa data: non c'e' niente da fare
--   diversa · transitoria      PREPOSTO con 19/05/2026 o 19/05/2027: la regola del
--                              preposto che il motore v1 non ha ancora
--   diversa · periodicita      Sicurweb conta dallo stesso attestato con un'altra
--                              periodicita': si dice quale, e si decide chi ha ragione
--   diversa · dichiarata       il motore usa una scadenza dichiarata sull'attestato
--   diversa · altro            nessuna delle ragioni sopra: si guardano una per una
--   solo Sicurweb · ...        il motore non ha quella coppia, e la ragione e' una fra
--                              persona fuori anagrafe, non attiva, corso senza obbligo
--                              nel catalogo, nessun attestato di quel corso (Sicurweb
--                              conta da una riga che qui non c'e'), ruolo non assegnato
--   solo motore                il motore ha una scadenza che Sicurweb non tiene

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.righe_scadenzario_attese', :'righe_scadenzario_attese', true);

create temp view alias_norm as
select btrim(regexp_replace(upper(testo collate "und-x-icu"), '\s+', ' ', 'g')) as norm,
       corso_codice, ignorato
  from corso_alias;

-- ---------- i controlli ----------

do $$
declare n int; attese int;
begin
  attese := nullif(current_setting('migrazione.righe_scadenzario_attese', true), '')::int;
  if attese is null then
    raise exception 'manca -v righe_scadenzario_attese=<numero>: lo stampa estrai_scadenzario.py';
  end if;
  select count(*) into n from origine.corso_scadenza;
  if n <> attese then
    raise exception '(a) origine.corso_scadenza ha % righe, l''estrazione ne dichiarava %', n, attese;
  end if;
  select count(*) into n from origine.corso_scadenza where data_scadenza is null;
  if n > 0 then
    raise exception '(b) % righe dello scadenzario senza data', n;
  end if;
end $$;

-- ---------- Sicurweb, per persona e corso ----------

create temp table sw_riga on commit drop as
select s.riga, s.data_scadenza, s.dichiarazione,
       case when codice_fiscale_valido(s.codice_fiscale) then codice_fiscale_pulito(s.codice_fiscale) end as cf,
       a.corso_codice, coalesce(a.ignorato, false) as ignorato, (a.norm is not null) as titolo_noto
  from origine.corso_scadenza s
  left join alias_norm a
         on a.norm = btrim(regexp_replace(upper(s.tipo collate "und-x-icu"), '\s+', ' ', 'g'));

create temp table sw on commit drop as
select p.id as persona_id, r.cf, r.corso_codice,
       max(r.data_scadenza) as scadenza,
       count(*) as righe,
       count(distinct r.data_scadenza) as date
  from sw_riga r
  left join persona p on p.codice_fiscale = r.cf
 where r.cf is not null and r.corso_codice is not null
 group by p.id, r.cf, r.corso_codice;

-- ---------- il motore, per persona e corso ----------

create temp table mo on commit drop as
select distinct on (persona_id, corso)
       persona_id, corso as corso_codice, completato_il, scadenza, scadenza_calcolata,
       scadenza_dichiarata, stato
  from v_scadenza_formazione
 where corso is not null
 order by persona_id, corso, scadenza desc nulls last;

-- ---------- il confronto ----------

create temp table confronto on commit drop as
select s.persona_id, s.cf, s.corso_codice, s.scadenza as sw_scadenza, s.date as sw_date,
       m.scadenza as mo_scadenza, m.completato_il, m.scadenza_dichiarata,
       c.aggiornamento_mesi,
       case
         when s.persona_id is null then 'solo Sicurweb · persona fuori anagrafe'
         when m.persona_id is null and not exists (
                select 1 from rapporto_lavoro r where r.persona_id = s.persona_id and not r.cessato)
              then 'solo Sicurweb · persona non attiva'
         -- Prima «nessun attestato»: dal 0027 un corso senza obbligo nel catalogo ha
         -- comunque una scadenza, se l'attestato c'e'. Se la coppia manca, e' quasi sempre
         -- perche' l'attestato qui non c'e'.
         when m.persona_id is null and not exists (
                select 1 from evento_formativo e
                 where e.persona_id = s.persona_id and e.corso_codice = s.corso_codice
                   and e.completa_il_percorso and e.data <= current_date)
              then 'solo Sicurweb · nessun attestato del corso'
         when m.persona_id is null and not exists (
                select 1 from corso_assolve ca where ca.corso_codice = s.corso_codice and not ca.parziale)
              then 'solo Sicurweb · corso senza obbligo nel catalogo'
         when m.persona_id is null and not exists (
                select 1 from v_obbligo_persona o
                  join corso_assolve ca on ca.ruolo = o.ruolo and not ca.parziale
                 where o.persona_id = s.persona_id and ca.corso_codice = s.corso_codice)
              then 'solo Sicurweb · ruolo non assegnato'
         when m.persona_id is null
              then 'solo Sicurweb · il motore conta un altro corso'
         when m.scadenza = s.scadenza then 'uguale'
         when s.corso_codice = 'PREPOSTO' and s.scadenza in (date '2026-05-19', date '2027-05-19')
              then 'diversa · transitoria del preposto'
         when m.scadenza_dichiarata is not null then 'diversa · dichiarata'
         when m.completato_il is not null
              and exists (select 1 from generate_series(1, 120) k
                           where (m.completato_il + (k || ' months')::interval)::date = s.scadenza)
              then 'diversa · periodicita'
         else 'diversa · altro'
       end as categoria,
       (select min(k) from generate_series(1, 120) k
         where (m.completato_il + (k || ' months')::interval)::date = s.scadenza) as sw_mesi
  from sw s
  left join mo m on m.persona_id = s.persona_id and m.corso_codice = s.corso_codice
  left join corso c on c.codice = s.corso_codice;

-- ---------- i conti ----------

do $$
declare
  righe int; senza_cf int; titoli_ignoti int; ignorate int; coppie int;
  cat text; per_mesi text; altro text; solo_motore int; solo_motore_corsi text;
  senza_obbligo text; non_assegnato text;
begin
  select count(*), count(*) filter (where cf is null),
         count(*) filter (where cf is not null and not titolo_noto),
         count(*) filter (where cf is not null and titolo_noto and corso_codice is null)
    into righe, senza_cf, titoli_ignoti, ignorate
    from sw_riga;
  select count(*) into coppie from confronto;

  select string_agg(categoria || ' ' || n, ', ' order by ord, n desc) into cat
    from (select categoria, count(*) n,
                 case when categoria = 'uguale' then 0 when categoria like 'diversa%' then 1 else 2 end as ord
            from confronto group by categoria) x;

  select string_agg(corso_codice || ' ' || sw_mesi || ' mesi invece di ' || coalesce(aggiornamento_mesi::text, 'nessuna') || ' (' || n || ')',
                    ', ' order by n desc)
    into per_mesi
    from (select corso_codice, sw_mesi, aggiornamento_mesi, count(*) n
            from confronto where categoria = 'diversa · periodicita'
           group by 1, 2, 3) x;

  select string_agg(corso_codice || ' ' || n, ', ' order by n desc)
    into altro
    from (select corso_codice, count(*) n from confronto where categoria = 'diversa · altro' group by 1) x;

  select string_agg(corso_codice || ' ' || n, ', ' order by n desc, corso_codice) into senza_obbligo
    from (select corso_codice, count(*) n from confronto
           where categoria = 'solo Sicurweb · corso senza obbligo nel catalogo' group by 1) x;
  select string_agg(corso_codice || ' ' || n, ', ' order by n desc, corso_codice) into non_assegnato
    from (select corso_codice, count(*) n from confronto
           where categoria = 'solo Sicurweb · ruolo non assegnato' group by 1) x;

  select count(*), string_agg(corso_codice || ' ' || n, ', ' order by n desc)
    into solo_motore, solo_motore_corsi
    from (select m.corso_codice, count(*) n
            from mo m
           where m.scadenza is not null
             and not exists (select 1 from sw s where s.persona_id = m.persona_id and s.corso_codice = m.corso_codice)
           group by 1) x;
  select count(*) into solo_motore from mo m
   where m.scadenza is not null
     and not exists (select 1 from sw s where s.persona_id = m.persona_id and s.corso_codice = m.corso_codice);

  raise notice 'scadenzario Sicurweb %  ->  coppie persona-corso confrontate %', righe, coppie;
  raise notice '  righe NON confrontabili: % senza codice fiscale valido, % con un titolo che il dizionario non conosce, % con un titolo ignorato a mano', senza_cf, titoli_ignoti, ignorate;
  raise notice 'riscontro: %', coalesce(cat, 'nessuna coppia');
  raise notice '  periodicita diverse (corso, mesi di Sicurweb, mesi del catalogo, coppie): %', coalesce(per_mesi, 'nessuna');
  raise notice '  diverse senza ragione, per corso: %', coalesce(altro, 'nessuna');
  raise notice '  solo motore: % (per corso: %)', solo_motore, coalesce(solo_motore_corsi, 'nessuno');
  raise notice '  corso senza obbligo nel catalogo, per corso: %', coalesce(senza_obbligo, 'nessuno');
  raise notice '  ruolo non assegnato, per corso: %', coalesce(non_assegnato, 'nessuno');
end $$;

commit;
