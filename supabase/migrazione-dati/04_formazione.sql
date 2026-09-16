-- AppOverall — migrazione dati, passo 04: gli attestati.
--
--   psql -v ON_ERROR_STOP=1 -v righe_formazione_attese=<count fatto all'estrazione> \
--        -f 04_formazione.sql
--
-- Porta `origine.formazione` in `evento_formativo` (`0021`). Va dopo il passo 02,
-- perche' l'aggancio alla persona passa per il rapporto di lavoro, e dopo il seed
-- degli alias, perche' due giudizi su tre li porta il dizionario e non l'attestato.
--
-- ============================================================================
--  DA DOVE VIENE, E PERCHE NON DALL'ALTRA PARTE
-- ============================================================================
--
-- Gli attestati stanno in tutti e due i repo di partenza. Si prendono da
-- AppSopralluoghi, e non e' una preferenza: **li' il codice del corso e' gia' quello
-- curato**, mappato dai 268 giudizi di `corso_alias`, mentre in AppFormazione
-- l'identita' del corso e' l'impronta `GEST-`+md5 del titolo, che la scheda 9
-- declassa ad **alias**. E' la stessa conclusione a cui il 16 settembre e' arrivata
-- la storia dei ruoli, e per la stessa via: due letture della stessa fonte, e una
-- delle due e' gia' stata dimostrata piu' povera da chi la usava.
--
-- ============================================================================
--  LE REGOLE, E OGNUNA HA LA SUA RAGIONE
-- ============================================================================
--
-- **1. Una riga d'origine, un evento.** Nessuna fusione: se due righe cadono sulla
-- stessa persona, corso e data, **entrano tutte e due e il passo le conta**. E' la
-- decisione di Francesco del 16 settembre, ed e' il motivo per cui la `0021` non ha
-- un `unique` su quella terna. Fondere vorrebbe dire scegliere quale tenere, e
-- nessuno qui ha gli elementi per farlo.
--
-- **2. La persona si raggiunge dal rapporto.** `origine.formazione.persona_id` e'
-- l'id della **loro** persona, che il passo 02 conserva alla lettera come
-- `rapporto_lavoro.id` (regola 1 di quel passo). Quindi l'aggancio e'
-- `rapporto_lavoro.id = origine.formazione.persona_id`, e da li' si legge
-- `persona_id`. Una riga che non trova il suo rapporto **ferma il passo**: vorrebbe
-- dire che le due estrazioni sono di due momenti diversi.
--
-- **3. Il corso si risolve in due modi, in quest'ordine.** Prima il codice curato
-- che l'origine porta gia'; se manca, il **dizionario degli alias** sul titolo
-- verbatim. Un titolo che l'alias dichiara `ignorato` non e' un errore: e' un
-- giudizio preso a mano, e quelle righe **non entrano e si contano**. Un titolo che
-- il dizionario non conosce affatto **ferma il passo**: e' un corso nuovo del
-- gestionale, e va guardato prima di decidere dove finisce.
--
-- **4. `pregressa` viene dall'alias, non dall'attestato.** La colonna sull'attestato
-- non esiste in origine: il giudizio «questa e' formazione pregressa» sta sul
-- dizionario (loro `057`), ed e' li' che si legge. `is_aggiornamento`, `parziale` e
-- `evidenza_incompleta` invece stanno gia' sulla riga.
--
-- **5. Il completamento entra ancora tutto aperto, e si dichiara.** La `0021` dice
-- che la validita' si conta dal completamento del percorso. Dall'origine si sa se
-- una riga e' uno **spezzone** (`parziale`), non se gli spezzoni di quella persona
-- siano tutti li': la loro `059` lo spiega — «6 + 6 = 12h, assolto solo avendo
-- entrambi». Quindi qui `completa_il_percorso = not parziale`, e i percorsi
-- frazionati entrano **aperti**.
--
-- **E non si prova a calcolarlo dalle ore, per una ragione che oggi e' una
-- decisione:** sommare `ore` per vedere se si arriva alla durata richiesta userebbe
-- la colonna che il gestionale ha **riscritto** con le durate del 2025. Sarebbe
-- esattamente il «numero di oggi contro la regola di ieri» che la `0021` vieta.
-- Quali percorsi siano completi lo dicono i due export del gestionale
-- (`FormFrazCompletata` e `FormFrazInCorso`), e quelli entrano con un passo loro.
--
-- **6. Cosa non porta, e lo conta.** `da_confermare` — il compito aperto sull'import
-- del campo — qui non ha dove stare: si contano le righe che ce l'hanno, cosi' un
-- dato non portato resta diverso da un dato che non c'era. `categoria` e
-- `allegato_url` restano all'origine: la prima e' del catalogo, il secondo e' un
-- documento e i documenti sono un dominio che questo repo non ha ancora.
--
-- **Rieseguibile:** le righe la cui `import_key` e' gia' in `evento_formativo` si
-- saltano. Le righe senza `import_key` non si possono riconoscere, e il passo si
-- ferma se ne trova: sarebbero doppioni al secondo giro.

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.righe_formazione_attese', :'righe_formazione_attese', true);

-- ---------- i controlli, prima di scrivere ----------

do $$
declare n int; attese int;
begin
  attese := nullif(current_setting('migrazione.righe_formazione_attese', true), '')::int;
  if attese is null then
    raise exception 'manca -v righe_formazione_attese=<numero>: senza, un''estrazione troncata passerebbe per intera';
  end if;

  select count(*) into n from origine.formazione;
  if n <> attese then
    raise exception '(a) origine.formazione ha % righe, l''estrazione ne dichiarava %: file troncato o count di un altro momento', n, attese;
  end if;

  select count(*) into n from origine.formazione where import_key is null or import_key = '';
  if n > 0 then
    raise exception '(b) % attestati senza import_key: al secondo giro rientrerebbero come nuovi', n;
  end if;

  select count(*) into n from origine.formazione o
   where not exists (select 1 from rapporto_lavoro r where r.id = o.persona_id);
  if n > 0 then
    raise exception '(c) % attestati puntano a una persona che non ha il suo rapporto: prima deve attraversare il passo 02, o le due estrazioni sono di due momenti diversi', n;
  end if;

  select count(*) into n from origine.formazione where data_completamento is null;
  if n > 0 then
    raise exception '(d) % attestati senza data: la validita si conta da una data, e dedurla sarebbe inventarla', n;
  end if;

  -- Il corso: prima il codice d'origine, poi l'alias. Cio che non si risolve ne
  -- con l'uno ne con l'altro non e un dato sporco, e un corso che non conosciamo.
  select count(*) into n
    from origine.formazione o
    left join corso c on c.codice = o.corso_codice
    left join corso_alias a on a.testo = o.corso_nome
   where c.codice is null
     and a.testo is null;
  if n > 0 then
    raise exception '(e) % attestati con un titolo che il dizionario dei 268 alias non conosce: e un corso nuovo del gestionale, si guarda prima di tradurlo', n;
  end if;

  select count(*) into n
    from origine.formazione o
    left join corso c on c.codice = o.corso_codice
    join corso_alias a on a.testo = o.corso_nome
   where c.codice is null
     and not a.ignorato
     and a.corso_codice is null;
  if n > 0 then
    raise exception '(e) % attestati con un alias conosciuto, non ignorato e senza destinazione: il dizionario e a meta su quel titolo', n;
  end if;

  select count(*) into n from origine.formazione o
   where o.scadenza is not null and o.scadenza <= o.data_completamento;
  if n > 0 then
    raise exception '(f) % attestati con una scadenza dichiarata non successiva alla data: non e un anticipo, e un dato rotto', n;
  end if;
end $$;

-- ---------- la traduzione ----------
--
-- In una tabella temporanea perche' le righe si leggono due volte: per scriverle e
-- per contarle. Il codice risolto e il giudizio dell'alias si calcolano una volta
-- sola, cosi' i conteggi in fondo parlano di cio' che e' stato scritto davvero e
-- non di una seconda lettura che potrebbe divergere.

create temp table riga_formazione on commit drop as
select o.*,
       r.persona_id            as persona_dest,
       coalesce(o.corso_codice, a.corso_codice) as corso_dest,
       coalesce(a.ignorato, false)  as alias_ignorato,
       coalesce(a.pregressa, false) as alias_pregressa,
       (a.testo is not null)   as ha_alias
  from origine.formazione o
  join rapporto_lavoro r on r.id = o.persona_id
  left join corso_alias a on a.testo = o.corso_nome
 where not exists (select 1 from evento_formativo e where e.import_key = o.import_key);

insert into evento_formativo (
  persona_id, corso_codice, data, completa_il_percorso,
  is_aggiornamento, pregressa, parziale, evidenza_incompleta,
  ente_formatore, nota, titolo_origine, ore_origine,
  scadenza_dichiarata, scadenza_fonte, import_key)
select persona_dest,
       corso_dest,
       data_completamento,
       not parziale,
       is_aggiornamento,
       alias_pregressa,
       parziale,
       evidenza_incompleta,
       ente_formatore,
       note,
       corso_nome,
       ore,
       scadenza,
       -- La fonte della scadenza dichiarata, che la `0021` vuole accanto al valore:
       -- qui e sempre la stessa, e va scritta lo stesso. Il giorno in cui una
       -- scadenza verra da un'altra parte, la differenza si dovra vedere sulla riga.
       case when scadenza is not null then 'dichiarata nel gestionale, migrata il ' || current_date end,
       import_key
  from riga_formazione
 where corso_dest is not null;

-- ---------- i conti, e quello che non e entrato ----------

do $$
declare
  ingresso int; scritti int; ignorati int; senza_codice int;
  per_alias int; collisioni int; frazionati int; n_da_confermare int;
  con_scadenza int; gia_presenti int;
begin
  select count(*) into ingresso from origine.formazione;
  select count(*) into gia_presenti from origine.formazione o
    where exists (select 1 from evento_formativo e where e.import_key = o.import_key)
      and not exists (select 1 from riga_formazione f where f.id = o.id);
  select count(*) into scritti from riga_formazione where corso_dest is not null;
  select count(*) into ignorati from riga_formazione where corso_dest is null and alias_ignorato;
  select count(*) into senza_codice from riga_formazione where corso_dest is null and not alias_ignorato;
  select count(*) into per_alias from riga_formazione where corso_codice is null and corso_dest is not null;
  select count(*) into frazionati from riga_formazione where parziale;
  select count(*) into n_da_confermare from riga_formazione f where f.da_confermare;
  select count(*) into con_scadenza from riga_formazione where scadenza is not null;

  -- Le collisioni: la decisione del 16 settembre dice che si segnalano. Si contano
  -- sulla destinazione e non sull'origine, perche due titoli diversi che portano
  -- allo stesso codice curato collidono **qui** e non la.
  select count(*) into collisioni from (
    select persona_id, corso_codice, data
      from evento_formativo
     group by persona_id, corso_codice, data
    having count(*) > 1) x;

  raise notice 'attestati d''origine %  ->  eventi scritti %', ingresso, scritti;
  if gia_presenti > 0 then
    raise notice '  gia presenti da un giro precedente: % (saltati per import_key)', gia_presenti;
  end if;
  raise notice '  codice risolto dal dizionario alias e non dall''origine: %', per_alias;
  raise notice '  NON entrati: % con un titolo ignorato a mano, % senza destinazione', ignorati, senza_codice;
  raise notice '  percorsi frazionati entrati APERTI: % (quali siano completi lo dicono i due export FormFraz)', frazionati;
  raise notice '  scadenze dichiarate portate: %', con_scadenza;
  raise notice '  NON portati: % attestati da confermare (il compito non ha dove stare qui)', n_da_confermare;
  raise notice '  persone, corsi e date su cui cadono due o piu attestati: % (si segnalano, non si fondono)', collisioni;
end $$;

commit;
