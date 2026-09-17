-- AppOverall — migrazione dati, passo 05: le sessioni dei percorsi frazionati.
--
--   psql -v ON_ERROR_STOP=1 -v righe_frazionata_attese=<count fatto all'estrazione> \
--        -f 05_frazionata.sql
--
-- Porta `origine.formazione_frazionata` in `evento_formativo`. Va dopo il passo 04,
-- perche' **le chiusure dei percorsi sono gia' li'**: sono attestati, e questo passo
-- le riconosce invece di crearle.
--
-- ============================================================================
--  COSA SI CREDEVA CHE FACESSE, E COSA FA
-- ============================================================================
--
-- Il passo 04 e il programma del 16 settembre dicevano: «i percorsi frazionati
-- entrano aperti, e li chiude il passo 05 con i due export `FormFraz`». **Falso in
-- tutte e due le meta'**, misurato il 17 settembre 2026 sui file del 6 agosto:
--
--   * le righe che il passo 04 lascia aperte sono i **sette** attestati con un
--     titolo `... PARZIALE ...` (alias `parziale`). **Nessuno di quei titoli e' nei
--     due export**: questo passo non li chiude, e non li chiude nessuno. Restano
--     aperti, e il passo 04 lo dice;
--   * e i percorsi completati **non vanno chiusi**, perche' lo sono gia': tutti i 154
--     (persona e corso) hanno un attestato dello stesso corso fra i `corsi_fatti`, e
--     163 sessioni su 513 cadono esattamente su un attestato della stessa persona,
--     dello stesso corso e dello stesso giorno. Il gestionale registra la chiusura
--     come un attestato, e il passo 04 l'ha portata.
--
-- Quindi questo passo **aggiunge le sessioni**, che oggi non ci sono da nessuna
-- parte — AppFormazione le ha lasciate in staging per non contarle due volte — e
-- **riconosce le chiusure**, che ci sono gia'.
--
-- ============================================================================
--  LE REGOLE, E OGNUNA HA LA SUA RAGIONE
-- ============================================================================
--
-- **1. Quale file e' il dato, e non si calcola niente dalle ore.** Una sessione del
-- file «Completata» appartiene a un percorso chiuso, una del file «In corso» a uno
-- aperto (`0021`, decisione 2). Si scrive in `percorso_dichiarato` (`0022`). Le ore
-- `1/6` si portano come provenienza (`ore_origine`, la prima cifra) e **non si
-- sommano per decidere niente**: sono la colonna che il gestionale ha riscritto
-- (`0021`, decisione 3).
--
-- **2. Una sessione «Completata» che cade su un attestato E' quell'attestato.**
-- Stessa persona, stesso corso curato, stesso giorno: e' la chiusura, registrata due
-- volte dal gestionale in due export. Non si scrive una seconda riga — sarebbe una
-- collisione finta, e la decisione 1 le collisioni le segnala come fatti — e
-- l'attestato del passo 04 **prende i due segni** che gli mancavano: `parziale`
-- (documenta l'ultimo pezzo di un percorso, non un corso intero) e
-- `percorso_dichiarato = 'completato'`. Resta `completa_il_percorso = true`, ed e'
-- da li' che si conta la validita'.
--
-- **3. Una sessione «In corso» si scrive sempre**, anche quando cade su un
-- attestato. Misurato: **8** lo fanno, e in **7** lo stesso giorno c'e' anche una
-- sessione «Completata» dello stesso corso — la giornata che chiude un percorso e
-- apre il successivo. L'ottava non ha quella spiegazione, e non ne invento una.
-- Sono due fatti, entrano tutti e due e **la coincidenza si conta**.
--
-- **4. La persona dal codice fiscale, il corso dal titolo**, come nel passo 04 e per
-- le stesse ragioni. Chi non ha un codice fiscale valido, o ne ha uno che
-- l'anagrafe non ha, **non entra e si conta**.
--
-- **5. Un percorso completato senza nessun attestato dello stesso corso entra, e si
-- conta.** Misurato: zero. Se uno comparisse, le sue sessioni avrebbero
-- `percorso_dichiarato = 'completato'` e nessuna riga che lo chiude, e
-- `v_percorso_formativo` lo mostrerebbe **non completo e senza sessioni aperte** —
-- uno stato che il motore deve vedere, non uno che questo passo deve risolvere
-- inventando una data.
--
-- **6. Due caricamenti dello stesso file nello staging fermano il passo.** Lo
-- staging di AppFormazione scarta solo le righe **identiche**: una seconda
-- estrazione aggiungerebbe le sessioni cambiate di un solo campo — e una sessione
-- passata da «In corso» a «Completata» ci sarebbe **due volte, nei due file**.
-- Quale dei due caricamenti valga non si decide qui.
--
-- **Rieseguibile:** l'`import_key` e' `ff:<id di staging>`. Le sessioni gia'
-- presenti si saltano, e il riconoscimento delle chiusure riscrive gli stessi due
-- segni sulle stesse righe.

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.righe_frazionata_attese', :'righe_frazionata_attese', true);

-- ---------- il titolo normalizzato, come nel passo 04 ----------
--
-- Con la stessa collazione e per la stessa ragione: senza, `upper()` dipende da
-- come e' nato il cluster (passo 04, 16 settembre 2026).

create temp view alias_norm as
select btrim(regexp_replace(upper(testo collate "und-x-icu"), '\s+', ' ', 'g')) as norm,
       testo, corso_codice, ignorato, pregressa, parziale, is_aggiornamento
  from corso_alias;

create temp view fraz_norm as
select o.*,
       btrim(regexp_replace(upper(o.corso_titolo collate "und-x-icu"), '\s+', ' ', 'g')) as titolo_norm,
       case when codice_fiscale_valido(o.codice_fiscale)
            then codice_fiscale_pulito(o.codice_fiscale) end as cf,
       case o.file when 'fraz_completata' then 'completato'
                   when 'fraz_in_corso'   then 'in_corso' end as dichiarato,
       o.file || '_' || to_char(to_date(substring(o.dichiarazione from '(\d{2}/\d{2}/\d{4})'), 'DD/MM/YYYY'), 'YYYYMMDD') as estrazione_codice
  from origine.formazione_frazionata o;

-- ---------- i controlli, prima di scrivere ----------

do $$
declare n int; attese int;
begin
  attese := nullif(current_setting('migrazione.righe_frazionata_attese', true), '')::int;
  if attese is null then
    raise exception 'manca -v righe_frazionata_attese=<numero>: senza, un''estrazione troncata passerebbe per intera';
  end if;

  select count(*) into n from origine.formazione_frazionata;
  if n <> attese then
    raise exception '(a) origine.formazione_frazionata ha % righe, l''estrazione ne dichiarava %: file troncato o count di un altro momento', n, attese;
  end if;

  select count(*) into n from origine.formazione_frazionata
   where file not in ('fraz_completata', 'fraz_in_corso');
  if n > 0 then
    raise exception '(b) % righe con un file che non e ne fraz_completata ne fraz_in_corso: il significato della riga sta nel file, e questo non lo ha', n;
  end if;

  select count(*) into n from (
    select file from origine.formazione_frazionata
     group by file having count(distinct esecuzione_id) > 1) x;
  if n > 0 then
    raise exception '(c) % file caricati piu di una volta nello staging: le sessioni dei due caricamenti si sommerebbero, e quale valga non si decide qui', n;
  end if;

  select count(*) into n from (
    select file from origine.formazione_frazionata
     group by file
    having count(distinct dichiarazione) <> 1
        or bool_or(dichiarazione is null)
        or bool_or(dichiarazione !~ '^Dati aggiornati al \d{2}/\d{2}/\d{4}')) x;
  if n > 0 then
    raise exception '(d) % file senza una data dichiarata unica e leggibile («Dati aggiornati al gg/mm/aaaa»): senza, non si sa di quale istante sono le sessioni', n;
  end if;

  select count(*) into n from origine.formazione_frazionata where data_sessione is null;
  if n > 0 then
    raise exception '(e) % sessioni senza data: la data e il dato della sessione, e dedurla sarebbe inventarla', n;
  end if;

  select count(*) into n from origine.formazione_frazionata
   where dettagli_ore is null or dettagli_ore !~ '^\d+(\.\d+)?/[1-9]\d*$';
  if n > 0 then
    raise exception '(f) % sessioni con le ore non nella forma «fatte/previste»: il gestionale ha cambiato come le scrive, si guarda prima', n;
  end if;

  select count(distinct titolo_norm) into n
    from fraz_norm o
   where not exists (select 1 from alias_norm a where a.norm = o.titolo_norm);
  if n > 0 then
    raise exception '(g) % titoli distinti che il dizionario dei 268 alias non conosce: sono corsi nuovi del gestionale, si guardano prima di tradurli', n;
  end if;

  select count(*) into n
    from fraz_norm o
    join alias_norm a on a.norm = o.titolo_norm
   where not a.ignorato and a.corso_codice is null;
  if n > 0 then
    raise exception '(h) % sessioni con un alias conosciuto, non ignorato e senza destinazione: il dizionario e a meta su quel titolo', n;
  end if;

  select count(*) into n
    from (select distinct estrazione_codice, dichiarazione from fraz_norm) f
    join origine_estrazione x on x.codice = f.estrazione_codice
   where x.dichiarazione <> f.dichiarazione;
  if n > 0 then
    raise exception '(i) % estrazioni gia registrate con lo stesso codice e un''altra dichiarazione: due file dello stesso giorno, e non si sa quale sia questo', n;
  end if;
end $$;

-- ---------- da quale estrazione ----------

insert into origine_estrazione (codice, file, data_dichiarata, dichiarazione, righe, note)
select estrazione_codice,
       case file when 'fraz_completata' then 'ExportExcelFormFrazCompletata.xlsx'
                 else 'ExportExcelFormFrazInCorso.xlsx' end,
       to_date(substring(dichiarazione from '(\d{2}/\d{2}/\d{4})'), 'DD/MM/YYYY'),
       dichiarazione,
       count(*),
       'Le sessioni dei percorsi frazionati ' ||
       case file when 'fraz_completata' then 'che il gestionale dichiara COMPLETATI'
                 else 'che il gestionale dichiara ANCORA IN CORSO' end ||
       '. Lette dallo staging di AppFormazione (staging.righe_import), dove il file e stato caricato una volta sola. Il nome del file e il dato: vedi 0021 e 0022.'
  from fraz_norm
 group by estrazione_codice, file, dichiarazione
on conflict (codice) do nothing;

-- ---------- la traduzione ----------

create temp table riga_fraz on commit drop as
select o.*,
       p.id as persona_dest,
       a.corso_codice as corso_dest,
       coalesce(a.ignorato, false)         as alias_ignorato,
       coalesce(a.pregressa, false)        as alias_pregressa,
       coalesce(a.is_aggiornamento, false) as alias_aggiornamento,
       split_part(o.dettagli_ore, '/', 1)::numeric as ore_fatte,
       split_part(o.dettagli_ore, '/', 2)::numeric as ore_previste,
       'ff:' || o.id::text as chiave,
       exists (select 1 from evento_formativo e
                where e.import_key = 'ff:' || o.id::text) as gia_presente,
       -- regola 2: la chiusura e' un attestato del passo 04, stesso giorno
       exists (select 1 from evento_formativo e
                where e.persona_id = p.id
                  and e.corso_codice = a.corso_codice
                  and e.data = o.data_sessione
                  and e.import_key like 'af:%') as su_attestato
  from fraz_norm o
  left join alias_norm a on a.norm = o.titolo_norm
  left join persona p on p.codice_fiscale = o.cf;

insert into evento_formativo (
  persona_id, corso_codice, data, completa_il_percorso,
  is_aggiornamento, pregressa, parziale, evidenza_incompleta,
  titolo_origine, ore_origine, estrazione, percorso_dichiarato, import_key)
select persona_dest,
       corso_dest,
       data_sessione,
       false,
       alias_aggiornamento,
       alias_pregressa,
       true,
       false,
       corso_titolo,
       ore_fatte,
       estrazione_codice,
       dichiarato,
       chiave
  from riga_fraz
 where persona_dest is not null
   and corso_dest is not null
   and not gia_presente
   and not (dichiarato = 'completato' and su_attestato);

-- regola 2, il secondo verso: l'attestato che chiude prende i due segni
update evento_formativo e
   set parziale = true,
       percorso_dichiarato = 'completato'
  from (select distinct persona_dest, corso_dest, data_sessione
          from riga_fraz
         where dichiarato = 'completato' and su_attestato) c
 where e.persona_id = c.persona_dest
   and e.corso_codice = c.corso_dest
   and e.data = c.data_sessione
   and e.import_key like 'af:%'
   and e.percorso_dichiarato is distinct from 'completato';

-- ---------- i conti, e cosa non e' entrato ----------

do $$
declare
  ingresso int; completate int; in_corso int; scritte int; gia int; persone int;
  chiusure_sessioni int; chiusure_attestati int; ignorate int; senza_cf int; senza_persona int;
  senza_chiusura int; in_corso_su_attestato int; in_corso_piene int; previste_diverse int;
  nel_futuro int; estrazioni text;
begin
  select count(*), count(*) filter (where file = 'fraz_completata'), count(*) filter (where file = 'fraz_in_corso')
    into ingresso, completate, in_corso
    from origine.formazione_frazionata;

  select count(*) into scritte from riga_fraz
   where persona_dest is not null and corso_dest is not null and not gia_presente
     and not (dichiarato = 'completato' and su_attestato);
  select count(*) into gia from riga_fraz where gia_presente;
  select count(distinct persona_id) into persone from evento_formativo where import_key like 'ff:%';

  select count(*) into chiusure_sessioni from riga_fraz
   where dichiarato = 'completato' and su_attestato;
  select count(*) into chiusure_attestati from evento_formativo
   where import_key like 'af:%' and percorso_dichiarato = 'completato';

  select count(*) into ignorate from riga_fraz where corso_dest is null and alias_ignorato;
  select count(*) into senza_cf from riga_fraz where cf is null;
  select count(*) into senza_persona from riga_fraz where cf is not null and persona_dest is null;

  -- regola 5
  select count(*) into senza_chiusura from (
    select distinct persona_dest, corso_dest from riga_fraz f
     where dichiarato = 'completato' and persona_dest is not null and corso_dest is not null
       and not exists (select 1 from evento_formativo e
                        where e.persona_id = f.persona_dest and e.corso_codice = f.corso_dest
                          and e.completa_il_percorso)) x;

  -- regola 3
  select count(*) into in_corso_su_attestato from riga_fraz
   where dichiarato = 'in_corso' and su_attestato;

  -- Non decide niente: dice se il file e le ore si contraddicono. Misurato: mai.
  select count(*) into in_corso_piene from (
    select cf, corso_dest from riga_fraz
     where dichiarato = 'in_corso' and corso_dest is not null and cf is not null
     group by cf, corso_dest
    having sum(ore_fatte) >= max(ore_previste)) x;

  select count(*) into previste_diverse from riga_fraz
   where durata is distinct from split_part(dettagli_ore, '/', 2);

  select count(*) into nel_futuro from riga_fraz
   where persona_dest is not null and corso_dest is not null and data_sessione > current_date;

  select string_agg(distinct estrazione_codice || ' («' || dichiarazione || '»)', ', ')
    into estrazioni from riga_fraz;

  raise notice 'sessioni d''origine % (% di percorsi completati, % di percorsi in corso)  ->  sessioni scritte %, su % persone', ingresso, completate, in_corso, scritte, persone;
  raise notice '  estrazioni: %', estrazioni;
  if gia > 0 then
    raise notice '  gia presenti da un giro precedente: % (saltate per import_key)', gia;
  end if;
  raise notice '  chiusure gia dentro dal passo 04: % sessioni su un attestato dello stesso giorno, % attestati segnati come chiusura di un percorso frazionato', chiusure_sessioni, chiusure_attestati;
  raise notice '  NON entrate: % con un titolo ignorato a mano, % senza codice fiscale valido, % con un codice fiscale che l''anagrafe non ha', ignorate, senza_cf, senza_persona;
  raise notice '  percorsi dichiarati completati senza nessun attestato che li chiuda: % (entrano, e restano senza data di chiusura)', senza_chiusura;
  raise notice '  sessioni in corso sul giorno di un attestato dello stesso corso: % (entrano tutte e due, e si guardano)', in_corso_su_attestato;
  raise notice '  percorsi in corso le cui ore arrivano gia alle previste: % (il file e le ore non concordano)', in_corso_piene;
  raise notice '  sessioni con le ore previste diverse dalla durata del corso: %', previste_diverse;
  raise notice '  sessioni con una data nel futuro: % (il motore le tratti come non avvenute)', nel_futuro;
end $$;

commit;
