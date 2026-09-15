-- AppOverall — migrazione dati, passo 03
-- Le nomine: una per persona d'origine e figura diventa una per persona, cliente, sede e ruolo.
--
-- Uso, dopo i passi 00, 01 e 02, con la `0020` applicata e con `origine.persona`
-- ancora carica — la stessa estrazione del passo 02, fatta nello stesso momento:
--
--   psql -v ON_ERROR_STOP=1 -v nomine_attese=<count fatto all'estrazione> -f 03_nomine.sql
--
-- ============================================================================
--  IL CAMBIO DI GRANA, IN CINQUE REGOLE
-- ============================================================================
--
-- Da loro una nomina e (persona, figura), unica per coppia (`015`), e la persona e
-- **per cliente**. Qui e (persona, cliente, sede, ruolo), e la loro persona e un
-- nostro rapporto (passo 02). Le regole, ognuna con la sua ragione:
--
--   1. **Ogni nomina d'origine diventa esattamente una nomina, con lo stesso `id`.**
--      La stessa scelta del rapporto nel passo 02: un surrogato conservato non
--      asserisce niente, e rende il passo rieseguibile senza una chiave nuova.
--
--   2. **Il ruolo e l'alias `sopralluoghi` della `0002`, e nient'altro.** `dl_rspp`
--      diventa `datore_lavoro_rspp` perche lo dice una riga di tabella, non questo
--      file: la `0002` racconta come un `case` scritto a mano abbia mandato 26 datori
--      sull'art. 32. Il loro vocabolario delle figure e di 13 codici (`015`, `018`,
--      `024`, `053`, letti sul loro `origin/main`) e la `0002` ne ha 13 righe. Un codice
--      senza riga, o con la riga senza destinazione (`operatore_attrezzatura`), ferma
--      tutto (rifiuto b): non si indovina.
--
--   3. **La persona e il cliente vengono dal rapporto** che il passo 02 ha scritto
--      con l'`id` della persona d'origine; il cliente, quindi, e gia passato da
--      `cliente_origine` (`0017`). **La sede e quella dell'unita d'origine**,
--      `cliente_origine.sede_id`: da loro l'organigramma sta sull'unita, e l'unita qui
--      e la sua sede — la `0001` dice «gli organigrammi sono N perche stanno sulle
--      sedi». Non la sede del rapporto: la nomina d'origine non nomina una sede,
--      nomina un'unita. Un'unita senza sede principale da una nomina senza sede, che
--      la `0001` legge «la sede non la sappiamo ancora».
--
--   4. **La stessa persona con la stessa figura su due unita fuse per P.IVA resta
--      due nomine**, una per sede. Da loro erano due righe persona e due
--      organigrammi; qui e una persona con due rapporti e due sedi dello stesso
--      cliente, e ogni sede ha il suo organigramma. Fonderle vorrebbe dire scegliere
--      quale data e quale nota tenere e buttare l'altra. **Si contano e si
--      stampano.** Se le due unita non hanno una sede dove stare, le due nomine
--      cadono sulla stessa persona, cliente, sede e ruolo, e li ci si ferma (rifiuto i).
--
--   5. **La provenienza attraversa com'e** (`0020`): `origine`, `origine_testo`, `note`
--      ed `estremi_procura` alla lettera — la stringa vuota vale assente, come nel
--      passo 02 — e `data_nomina` com'e: **una nomina senza data resta senza data**,
--      comprese le `dl_rspp` dai testi. `posizione` (`0010`) si **legge dal dizionario
--      di qui**, per le sole nomine dedotte da un testo; per tutte le altre resta
--      null, perche `non_dichiarato` direbbe di aver letto una frase che non c'era.
--
-- La chiave con cui un testo d'origine trova la sua riga in `ruolo_testo` e quella
-- della `0007` — via tutto cio che non e una lettera o una cifra ASCII, poi maiuscolo
-- — e prima di usarla si verifica che il dizionario sia davvero costruito cosi
-- (rifiuto g). Serve la chiave e non il testo perche il loro import scrive
-- `origine_testo` **in maiuscolo** («SOCIO/ RSPP»), e il nostro `testo` e com'era nel
-- file («SOCIO/ RSPP», ma anche «Lavoratore e preposto»).
--
-- ============================================================================
--  QUANDO SI RIFIUTA, E PERCHE PREFERISCE RIFIUTARE
-- ============================================================================
--
-- Tutto sta in una transazione: o passa intera, o non scrive niente. E si ferma
-- **prima di scrivere** in dieci casi, ognuno dei quali altrimenti passerebbe:
--
--   a. il numero di nomine non e quello dichiarato;
--   b. una figura senza alias `sopralluoghi`, o con l'alias senza destinazione;
--   c. una nomina punta a una persona che non e in `origine.persona`, o che non ha
--      il suo rapporto — **le persone attraversano prima**, nel passo 02;
--   d. una nomina non attiva — qui «cessata» e solo una data, e senza data
--      **tornerebbe attiva**: e il rifiuto (e) del passo 02, sulle nomine;
--   e. una nomina `da_confermare` — e un compito aperto (`054`) che qui non ha una
--      colonna, e passerebbe per una nomina confermata;
--   f. un'`origine` che la `0020` non conosce, o un testo che non torna con l'origine
--      — dedotta senza testo, o un testo accanto a una nomina che non ne viene. Il
--      vincolo della `0020` la rifiuterebbe comunque a meta scrittura; qui lo si dice
--      prima, e con il numero;
--   g. il dizionario non e costruito con la chiave di questo passo, o una nomina e
--      dedotta da un testo che il dizionario di qui non conosce o conosce con due
--      posizioni — la `posizione` non si potrebbe leggere, e i due dizionari gemelli
--      avrebbero divergito;
--   h. una nomina dedotta da un testo, **senza nota**, con un ruolo che il dizionario
--      di qui da quel testo non ricava. Con la nota e una decisione presa fuori dal
--      dizionario e la ragione e scritta: passa, e si conta. Senza, e
--      un'interpretazione che qui nessuna regola sostiene;
--   i. due nomine che cadrebbero sulla stessa persona, cliente, sede e ruolo — fra
--      loro, o con una nomina viva che qui c'e gia con un altro `id`;
--   j. `estremi_procura` su un ruolo che non e il delegato dell'art. 16: la `0002`
--      dice che vale solo per quello.
--
-- d, e ed h **non sono mai stati misurati** sui dati veri: se la prima esecuzione si
-- ferma li, non e un difetto di questo file, e la domanda che nessuno aveva fatto.
--
-- Cosa **non** attraversa, e perche non e una perdita: `attiva` (passano solo le
-- attive, e attiva qui e `data_cessazione` null), `da_confermare` (passano solo le
-- confermate), `created_at` e `updated_at` (come nel passo 02).
--
-- Rieseguibile: le nomine il cui `id` e gia in `nomina` si saltano, e i controlli
-- finali le rileggono lo stesso.

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.nomine_attese', :'nomine_attese', true);

-- ---------- la traduzione, scritta una volta sola ----------
--
-- Viste e non tabelle: i rifiuti, la scrittura e i controlli finali leggono la
-- stessa traduzione, e non ce n'e una seconda copia da tenere allineata.

create temp view nom_tutte as
select o.*,
       a.ruolo,
       (a.codice_esterno is not null) as alias_noto,
       (op.id is not null) as persona_estratta,
       r.id as rapporto_id,
       r.persona_id as persona_dest,
       r.cliente_id as cliente_dest,
       m.sede_id as sede_dest,
       case when o.origine in ('mansione', 'qualifica')
            then upper(regexp_replace(o.origine_testo, '[^A-Za-z0-9]', '', 'g')) end as chiave
  from origine.nomina o
  left join ruolo_sicurezza_alias a on a.sistema = 'sopralluoghi' and a.codice_esterno = o.figura_codice
  left join origine.persona op on op.id = o.persona_id
  left join rapporto_lavoro r on r.id = o.persona_id
  left join cliente_origine m on m.origine_id = op.cliente_id;

-- cosa un testo dice della persona, per chiave
create temp view testo_letto as
select chiave, min(posizione) as posizione, count(distinct posizione) as posizioni
  from ruolo_testo
 group by chiave;

-- quali ruoli la regola della 0007 ricava da un testo, per chiave
create temp view testo_ruolo as
select distinct t.chiave, d.ruolo
  from ruolo_testo t
  join ruolo_testo_parola p on p.testo = t.testo
  join ruolo_da_parola d on d.parola = p.parola
                        and (d.posizione is null or d.posizione = t.posizione);

-- ---------- i rifiuti, prima di scrivere ----------

do $$
declare
  attese text := current_setting('migrazione.nomine_attese');
  n bigint;
begin
  if attese !~ '^[0-9]+$' then
    raise exception 'manca -v nomine_attese=<numero>: senza, un''estrazione troncata passerebbe per intera';
  end if;

  select count(*) into n from origine.nomina;
  if n <> attese::bigint then
    raise exception '(a) origine.nomina ha % righe, l''estrazione ne dichiarava %: file troncato o count di un altro momento', n, attese;
  end if;

  select count(*) into n from nom_tutte where not alias_noto;
  if n > 0 then raise exception '(b) % nomine con una figura che la 0002 non conosce per sopralluoghi: un codice nuovo si guarda, non si traduce', n; end if;
  select count(*) into n from nom_tutte where alias_noto and ruolo is null;
  if n > 0 then raise exception '(b) % nomine con una figura conosciuta e senza destinazione: quale ruolo sia lo dice un attestato, non la nomina', n; end if;

  select count(*) into n from nom_tutte where not persona_estratta;
  if n > 0 then raise exception '(c) % nomine puntano a una persona che non e in origine.persona: estrazioni di due momenti diversi', n; end if;
  select count(*) into n from nom_tutte where persona_estratta and rapporto_id is null;
  if n > 0 then raise exception '(c) % nomine puntano a una persona che non ha il suo rapporto: prima deve attraversare il passo 02', n; end if;

  select count(*) into n from origine.nomina where not attiva;
  if n > 0 then raise exception '(d) % nomine non attive: qui una nomina cessata e una data, e senza data tornerebbero attive', n; end if;

  select count(*) into n from origine.nomina where da_confermare;
  if n > 0 then raise exception '(e) % nomine da confermare: qui il compito non ha dove stare, e passerebbero per confermate', n; end if;

  select count(*) into n from origine.nomina
   where origine is not null and origine not in ('colonna', 'mansione', 'qualifica', 'manuale');
  if n > 0 then raise exception '(f) % nomine con un''origine che la 0020 non conosce', n; end if;
  select count(*) into n from origine.nomina
   where (nullif(origine_testo, '') is not null) <> coalesce(origine in ('mansione', 'qualifica'), false);
  if n > 0 then raise exception '(f) % nomine con un testo che non torna con l''origine: dedotte senza testo, o un testo accanto a una nomina che non ne viene', n; end if;

  select count(*) into n from ruolo_testo
   where chiave <> upper(regexp_replace(testo, '[^A-Za-z0-9]', '', 'g'));
  if n > 0 then raise exception '(g) % righe di ruolo_testo con una chiave che questo passo non ricalcola: il confronto con i testi d''origine sarebbe falso', n; end if;
  select count(*) into n from nom_tutte x
   where x.chiave is not null
     and not exists (select 1 from testo_letto t where t.chiave = x.chiave and t.posizioni = 1);
  if n > 0 then raise exception '(g) % nomine dedotte da un testo che il dizionario di qui non conosce, o conosce con due posizioni: i due dizionari gemelli hanno divergito', n; end if;

  select count(*) into n from nom_tutte x
   where x.chiave is not null
     and nullif(btrim(x.note), '') is null
     and not exists (select 1 from testo_ruolo t where t.chiave = x.chiave and t.ruolo = x.ruolo);
  if n > 0 then raise exception '(h) % nomine dedotte da un testo, senza nota, con un ruolo che il dizionario di qui da quel testo non ricava', n; end if;

  select count(*) into n from (
    select persona_dest, cliente_dest, sede_dest, ruolo from nom_tutte
     group by 1, 2, 3, 4 having count(*) > 1) d;
  if n > 0 then raise exception '(i) % volte due nomine d''origine cadono sulla stessa persona, cliente, sede e ruolo: fonderle vorrebbe dire scegliere quale tenere', n; end if;
  select count(*) into n from nom_tutte x
    join nomina q on q.persona_id = x.persona_dest and q.cliente_id = x.cliente_dest
                 and q.sede_id is not distinct from x.sede_dest and q.ruolo = x.ruolo
                 and q.data_cessazione is null
   where q.id <> x.id;
  if n > 0 then raise exception '(i) % nomine d''origine cadono su una nomina viva che qui c''e gia con un altro id', n; end if;

  select count(*) into n from nom_tutte
   where nullif(estremi_procura, '') is not null and ruolo is distinct from 'datore_lavoro_art16';
  if n > 0 then raise exception '(j) % nomine con gli estremi di una procura su un ruolo che non e il delegato dell''art. 16', n; end if;
end
$$;

-- ---------- regole 1-5: una nomina per nomina d'origine ----------

insert into nomina (id, persona_id, cliente_id, sede_id, ruolo, data_nomina,
                    estremi_procura, posizione, origine, origine_testo, note)
select x.id, x.persona_dest, x.cliente_dest, x.sede_dest, x.ruolo, x.data_nomina,
       nullif(x.estremi_procura, ''),
       t.posizione,
       x.origine, nullif(x.origine_testo, ''), nullif(x.note, '')
  from nom_tutte x
  left join testo_letto t on t.chiave = x.chiave
 where not exists (select 1 from nomina q where q.id = x.id);

-- ---------- i conti, calcolati dall'origine e non scritti a mano ----------
--
-- Il 454 del 15 settembre non compare qui come costante, e nemmeno il 459 che
-- verra: si confronta cio che e uscito con cio che le cinque regole dicono che doveva
-- uscire da QUESTA origine. E i controlli rileggono anche le nomine scritte da
-- un'esecuzione precedente, che l'insert qui sopra ha saltato.

do $$
declare
  righe bigint; nomine bigint; n bigint;
  fuse bigint; fuori_regola bigint; senza_origine bigint; senza_data bigint;
  con_nota bigint; esterni bigint; persone bigint;
  per_origine text; per_ruolo text;
begin
  select count(*) into righe from origine.nomina;
  select count(*), count(distinct q.persona_id) into nomine, persone
    from nomina q join origine.nomina o on o.id = q.id;
  if nomine <> righe then
    raise exception 'nomine %, righe d''origine %: la regola 1 non tiene', nomine, righe;
  end if;

  select count(*) into n from nomina q join nom_tutte x on x.id = q.id
   where q.ruolo is distinct from x.ruolo
      or q.persona_id is distinct from x.persona_dest
      or q.cliente_id is distinct from x.cliente_dest
      or q.sede_id is distinct from x.sede_dest;
  if n > 0 then raise exception '% nomine che non stanno dove le regole 2 e 3 le mettono', n; end if;

  select count(*) into n from nomina q join origine.nomina o on o.id = q.id
   where q.origine is distinct from o.origine
      or q.origine_testo is distinct from nullif(o.origine_testo, '')
      or q.note is distinct from nullif(o.note, '')
      or q.estremi_procura is distinct from nullif(o.estremi_procura, '')
      or q.data_nomina is distinct from o.data_nomina;
  if n > 0 then raise exception '% nomine con una provenienza diversa da quella d''origine: la regola 5 non tiene', n; end if;

  select count(*) into n from nomina q join origine.nomina o on o.id = q.id
   where (q.posizione is not null) <> (q.origine_testo is not null);
  if n > 0 then raise exception '% nomine con una posizione dove non c''era un testo, o senza posizione dove c''era', n; end if;

  -- regola 4: quante volte la stessa persona ha lo stesso ruolo su piu sedi dello stesso cliente
  select count(*) into fuse from (
    select q.persona_id, q.cliente_id, q.ruolo
      from nomina q join origine.nomina o on o.id = q.id
     group by 1, 2, 3 having count(*) > 1) d;

  select count(*) into fuori_regola from nom_tutte x
   where x.chiave is not null
     and not exists (select 1 from testo_ruolo t where t.chiave = x.chiave and t.ruolo = x.ruolo);

  select count(*) filter (where origine is null),
         count(*) filter (where data_nomina is null),
         count(*) filter (where nullif(note, '') is not null)
    into senza_origine, senza_data, con_nota
    from origine.nomina;

  select count(*) into esterni
    from nomina q join origine.nomina o on o.id = q.id
   where q.posizione = 'esterno';

  select string_agg(k || ' ' || c, ', ' order by k) into per_origine
    from (select coalesce(origine, 'null') k, count(*) c from origine.nomina group by 1) s;
  select string_agg(k || ' ' || c, ', ' order by c desc, k) into per_ruolo
    from (select q.ruolo k, count(*) c from nomina q join origine.nomina o on o.id = q.id group by 1) s;

  raise notice 'nomine d''origine %  ->  nomine %, su % persone', righe, nomine, persone;
  raise notice '  per origine: %', per_origine;
  raise notice '  per ruolo: %', per_ruolo;
  raise notice '  senza data: % (restano senza), con una nota: %, senza origine registrata: %', senza_data, con_nota, senza_origine;
  raise notice '  dedotte da un testo con un ruolo che il dizionario non ricava, e la ragione in nota: %', fuori_regola;
  raise notice '  stessa persona e stesso ruolo su piu sedi dello stesso cliente (unita fuse): %', fuse;
  raise notice '  con posizione esterno: % (la 0010: se un RSPP ESTERNO e nominato, non deve essere zero)', esterni;
end
$$;

commit;
