-- AppOverall — migrazione dati, passo 02
-- Le persone: 3.419 righe per cliente diventano persone piu rapporti.
--
-- Uso, dopo il passo 00 e il passo 01 (clienti e sedi):
--
--   psql -v ON_ERROR_STOP=1 -v righe_attese=<count fatto all'estrazione> -f 01_persone.sql
--
-- ============================================================================
--  IL CAMBIO DI GRANA, IN QUATTRO REGOLE
-- ============================================================================
--
-- Da loro `persona` e per cliente; qui e una riga per persona e il legame col
-- cliente e `rapporto_lavoro` (`0013`). Le regole, e ognuna ha la sua ragione:
--
--   1. **Ogni riga d'origine diventa esattamente un rapporto**, e il rapporto
--      conserva l'`id` d'origine e la `import_key` alla lettera. L'id conservato
--      e la stessa scelta della `0013` per i clienti: un surrogato opaco non
--      asserisce niente e non costa niente, e cosi `formazione.persona_id` di la
--      trovera il suo rapporto con un join, senza una tabella di corrispondenza.
--      **Il cliente del rapporto invece passa da `cliente_origine`** (`0017`): per
--      un'unita assorbita da una fusione per P.IVA l'uuid d'origine non e un
--      `cliente.id`, e dentro la chiave resta verbatim, come provenienza.
--
--   2. **Le righe con un codice fiscale VALIDO si fondono per codice fiscale** —
--      valido per `codice_fiscale_valido` della `0016`, cioe con il carattere di
--      controllo, non per forma. Sono le fusioni che vanno fatte: la stessa
--      persona su due clienti e una persona con due rapporti.
--
--   3. **Le righe senza un codice fiscale valido NON si fondono mai**, nemmeno a
--      nome identico: una persona ciascuna. Qui non hanno nessun vincolo di
--      unicita (`0001:261`, un unique non morde sui null), quindi l'unica cosa
--      che le tiene separate e questa regola. «Meglio un doppione che si vede di
--      due persone fuse per sbaglio, che non si vede piu» — la regola di
--      AppSopralluoghi, portata di qua senza cambiarla.
--
--   4. **Quando le righe fuse non concordano sul nome, vince la riga aggiornata
--      per ultima** (a parita, l'id minore, perche il risultato non dipenda
--      dall'ordine di lettura). E una scelta e non una verita, quindi le
--      discordanze si **contano e si stampano**, non si risolvono in silenzio.
--
-- ============================================================================
--  QUANDO SI RIFIUTA, E PERCHE PREFERISCE RIFIUTARE
-- ============================================================================
--
-- Tutto sta in una transazione: o passa intera, o non scrive niente. E si ferma
-- **prima di scrivere** in sei casi, ognuno dei quali altrimenti passerebbe:
--
--   a. il numero di righe non e quello dichiarato — un'estrazione troncata e
--      plausibile, e questo e l'unico punto in cui si vede;
--   b. una riga non ha `import_key` — la regola 1 non avrebbe cosa trasportare;
--   c. una riga punta a un cliente che qui non c'e, o a una sede che non e di quel
--      cliente — **i clienti attraversano prima**, nel passo 01, e il cliente si
--      cerca in `cliente_origine`;
--   d. una riga ha `cognome` null — qui e `not null`, e trasformarlo in stringa
--      vuota sarebbe inventare un dato per far passare un vincolo;
--   e. una riga ha `attivo = false` e nessuna `data_cessazione` — qui «cessato»
--      esiste solo come data, e senza data un ex lavoratore **tornerebbe attivo**,
--      con i suoi obblighi formativi: l'errore che non si vede;
--   f. lo stesso codice fiscale valido compare due volte **nello stesso cliente** —
--      misurato zero il 13 settembre; se non lo e piu, la fusione produrrebbe due
--      rapporti identici e va guardato prima.
--
-- d ed e **non sono mai stati misurati** sui dati veri: se la prima esecuzione si
-- ferma li, non e un difetto di questo file, e la domanda che nessuno aveva fatto.
--
-- Rieseguibile: le righe la cui `import_key` e gia in `rapporto_lavoro` si
-- saltano, e una riga nuova con un codice fiscale gia presente si aggancia alla
-- persona che c'e.

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.righe_attese', :'righe_attese', true);

-- ---------- i rifiuti, prima di scrivere ----------

do $$
declare
  attese text := current_setting('migrazione.righe_attese');
  n bigint;
begin
  if attese !~ '^[0-9]+$' then
    raise exception 'manca -v righe_attese=<numero>: senza, un''estrazione troncata passerebbe per intera';
  end if;

  select count(*) into n from origine.persona;
  if n <> attese::bigint then
    raise exception '(a) origine.persona ha % righe, l''estrazione ne dichiarava %: file troncato o count di un altro momento', n, attese;
  end if;

  select count(*) into n from origine.persona where import_key is null or import_key = '';
  if n > 0 then raise exception '(b) % righe senza import_key', n; end if;

  select count(*) into n from origine.persona o
   where not exists (select 1 from cliente_origine m where m.origine_id = o.cliente_id);
  if n > 0 then raise exception '(c) % righe puntano a un cliente che qui non esiste: prima devono attraversare i clienti', n; end if;

  select count(*) into n from origine.persona o
   where o.sede_id is not null
     and not exists (select 1 from sede s join cliente_origine m on m.origine_id = o.cliente_id
                      where s.id = o.sede_id and s.cliente_id = m.cliente_id);
  if n > 0 then raise exception '(c) % righe puntano a una sede che qui non esiste o non e del loro cliente', n; end if;

  select count(*) into n from origine.persona where cognome is null;
  if n > 0 then raise exception '(d) % righe con cognome null: qui e obbligatorio, e non si inventa', n; end if;

  select count(*) into n from origine.persona where not attivo and data_cessazione is null;
  if n > 0 then raise exception '(e) % righe non attive senza data di cessazione: di qua tornerebbero attive', n; end if;

  select count(*) into n from (
    select cliente_id, codice_fiscale_pulito(codice_fiscale)
      from origine.persona
     where codice_fiscale_valido(codice_fiscale)
     group by 1, 2 having count(*) > 1) d;
  if n > 0 then raise exception '(f) % codici fiscali validi ripetuti dentro lo stesso cliente', n; end if;
end
$$;

-- ---------- le righe ancora da portare ----------

create temp table riga on commit drop as
select o.*,
       case when codice_fiscale_valido(o.codice_fiscale)
            then codice_fiscale_pulito(o.codice_fiscale) end as cf,
       m.cliente_id as cliente_dest,
       null::uuid as persona_id
  from origine.persona o
  join cliente_origine m on m.origine_id = o.cliente_id
 where not exists (select 1 from rapporto_lavoro r where r.import_key = o.import_key);

-- ---------- regola 2 e 4: una persona per codice fiscale valido ----------

insert into persona (codice_fiscale, codice_fiscale_origine, cognome, nome)
select distinct on (cf) cf, nullif(codice_fiscale, ''), cognome, nome
  from riga
 where cf is not null
 order by cf, updated_at desc, id
on conflict (codice_fiscale) do nothing;

update riga r set persona_id = p.id
  from persona p
 where r.cf is not null and p.codice_fiscale = r.cf;

-- ---------- regola 3: una persona per riga, senza eccezioni ----------

update riga set persona_id = gen_random_uuid() where cf is null;

insert into persona (id, codice_fiscale, codice_fiscale_origine, cognome, nome)
select persona_id, null, nullif(codice_fiscale, ''), cognome, nome
  from riga
 where cf is null;

-- ---------- regola 1: un rapporto per riga ----------

-- `cessato` dalla `0025`: una data di cessazione, o una riga che l'origine dichiara
-- non attiva. Il secondo caso e' «finito, non si sa da quando».
insert into rapporto_lavoro (id, persona_id, cliente_id, sede_id, mansione,
                             data_assunzione, data_cessazione, cessato, import_key)
select id, persona_id, cliente_dest, sede_id, mansione,
       data_assunzione, data_cessazione, data_cessazione is not null or not attivo, import_key
  from riga;

-- ---------- i conti, calcolati dall'origine e non scritti a mano ----------
--
-- Il 3.415 del 13 settembre non compare qui come costante: l'archivio d'origine
-- puo essere cambiato, e un numero atteso scritto nel file certificherebbe il
-- giorno della misura invece dell'estrazione. Si confronta cio che e uscito con
-- cio che le quattro regole dicono che doveva uscire da QUESTA origine.

do $$
declare
  righe bigint; validi_distinti bigint; senza_valido bigint;
  rapporti bigint; persone bigint; n bigint;
begin
  select count(*),
         count(distinct codice_fiscale_pulito(codice_fiscale)) filter (where codice_fiscale_valido(codice_fiscale)),
         count(*) filter (where not codice_fiscale_valido(codice_fiscale))
    into righe, validi_distinti, senza_valido
    from origine.persona;

  select count(*), count(distinct r.persona_id) into rapporti, persone
    from rapporto_lavoro r join origine.persona o on o.import_key = r.import_key;

  if rapporti <> righe then
    raise exception 'rapporti %, righe d''origine %: la regola 1 non tiene', rapporti, righe;
  end if;
  if persone <> validi_distinti + senza_valido then
    raise exception 'persone %, attese % (% codici validi distinti + % senza codice valido)',
      persone, validi_distinti + senza_valido, validi_distinti, senza_valido;
  end if;

  -- regola 3 vista dal risultato: nessuna persona senza codice fiscale ha due rapporti
  select count(*) into n from (
    select r.persona_id from rapporto_lavoro r join persona p on p.id = r.persona_id
     where p.codice_fiscale is null group by 1 having count(*) > 1) x;
  if n > 0 then raise exception '% persone senza codice fiscale hanno piu di un rapporto: fusione non voluta', n; end if;

  -- l'uuid dentro la chiave aggancia il cliente del rapporto (`0013`, il conto che
  -- fallisce in silenzio), attraverso `cliente_origine` della `0017`
  select count(*) into n from rapporto_lavoro r
   where r.import_key like 'anag:%'
     and not exists (select 1 from cliente_origine m
                      where m.origine_id::text = split_part(r.import_key, ':', 2)
                        and m.cliente_id = r.cliente_id);
  if n > 0 then raise exception '% rapporti con una import_key che nomina un altro cliente', n; end if;

  select count(*) into n from persona p
   where not exists (select 1 from rapporto_lavoro r where r.persona_id = p.id);
  if n > 0 then raise exception '% persone senza nessun rapporto', n; end if;

  select count(*) into n from (
    select p.id from persona p join rapporto_lavoro r on r.persona_id = p.id
      join origine.persona o on o.import_key = r.import_key
     where p.codice_fiscale is not null
     group by p.id
    having count(distinct upper(regexp_replace(o.cognome || '|' || o.nome, '\s+', ' ', 'g') collate "und-x-icu")) > 1) d;

  raise notice 'righe d''origine %  ->  rapporti %, persone %', righe, rapporti, persone;
  raise notice '  codici fiscali validi distinti %, righe senza codice valido %', validi_distinti, senza_valido;
  raise notice '  persone fuse che non concordano sul nome: % (vince la riga aggiornata per ultima)', n;
  raise notice '  rapporti cessati: % (di cui senza una data: %)',
    (select count(*) from rapporto_lavoro where cessato),
    (select count(*) from rapporto_lavoro where cessato and data_cessazione is null);
end
$$;

commit;
