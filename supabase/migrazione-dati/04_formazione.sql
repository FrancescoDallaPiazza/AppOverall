-- AppOverall — migrazione dati, passo 04: gli attestati.
--
--   psql -v ON_ERROR_STOP=1 -v righe_formazione_attese=<count fatto all'estrazione> \
--        -f 04_formazione.sql
--
-- Porta `origine.formazione` in `evento_formativo` (`0021`). Va dopo il passo 02,
-- perche' la persona si riconosce dal codice fiscale e quelle righe le scrive il 02,
-- e dopo il seed degli alias, perche' **il corso si risolve dal titolo** e il
-- dizionario e' li'.
--
-- ============================================================================
--  DA DOVE VIENE, E LA VOLTA CHE HO SCELTO SENZA MISURARE
-- ============================================================================
--
-- Gli attestati sono in **AppFormazione**: `eventi_formativi`, 13.215 righe. La
-- prima versione di questo passo leggeva da AppSopralluoghi, e la ragione era buona
-- — li' il codice del corso e' gia' quello curato dai 268 alias, mentre di la'
-- l'identita' e' `GEST-` + md5 del titolo, che la scheda 9 declassa ad alias.
--
-- **La tabella di AppSopralluoghi ha zero righe.** Misurato il 16 settembre 2026,
-- dopo aver scritto il passo intero e la sua prova. L'import esiste
-- (`formazioneImport.ts`), ha la sua chiave di idempotenza, ha i suoi giudizi: non
-- e' mai stato eseguito in produzione. Terza volta in una giornata, dopo
-- `togli_ruoli_rspp.sql` e il seed degli alias.
--
-- **E cio' che ho sbagliato non e' la scelta, e' l'ordine.** Ho confrontato due
-- letture della stessa fonte prima di chiedere quale delle due avesse delle righe.
-- La domanda costava un `count(*)`.
--
-- ============================================================================
--  LE REGOLE, E OGNUNA HA LA SUA RAGIONE
-- ============================================================================
--
-- **1. La persona si riconosce dal codice fiscale.** Fra i due database non c'e'
-- nessun id in comune: `eventi_formativi.persona_id` e' delle **loro** persone, che
-- questa migrazione non importa. Il codice fiscale invece e' la chiave che il passo
-- 02 ha gia' usato per fondere le persone, ed e' l'unica che attraversa il confine.
-- Le righe senza codice fiscale valido, o con un codice che qui non ha una persona,
-- **non entrano e si contano**: sono persone che AppFormazione conosce e l'anagrafe
-- di AppSopralluoghi no, e agganciarle per nome sarebbe inventare.
--
-- **2. Il corso si risolve dal TITOLO, attraverso i 268 alias.** Il loro codice
-- (`GEST-`+md5) e' derivato dal titolo, quindi non aggiunge niente; il titolo invece
-- e' esattamente cio' che il nostro dizionario sa leggere, ed e' curato a mano.
--
-- **E il confronto e' sul testo normalizzato, non verbatim**, perche' i due
-- dizionari sono stati curati separatamente e differiscono per spazi. Normalizzare
-- pero' puo' **fondere due alias distinti**: passando i 268 per la normalizzazione di
-- AppFormazione, una collisione perde una distinzione vera — `PREPOSTI - BIENNALE`
-- (12 ore) contro `PREPOSTI_BIENNALE` (8 ore). Quindi il passo **si ferma** se un
-- titolo normalizzato porta a due codici diversi: preferisce non scrivere piuttosto
-- che scegliere.
--
-- **3. `parziale`, `pregressa` e `is_aggiornamento` vengono dal dizionario.** Su
-- `eventi_formativi` non ci sono: il giudizio «questo titolo documenta uno spezzone»
-- sta sull'alias (7 righe su 268), e da li' si legge.
--
-- **4. I percorsi frazionati entrano APERTI, e si dichiara.** Vale quanto scritto
-- nella `0021`: chi dice se un percorso e' finito non e' questo passo. AppFormazione
-- ha **ricostruito** i cicli (`staging.cicli_frazionati`, 471 righe, con `chiuso` e
-- `fuori_finestra`), ma la loro stessa migrazione avverte che e' una ricostruzione e
-- va confrontata con le chiusure che il gestionale ha gia' registrato — che sono i
-- due export `FormFraz`, 516 e 410. Quel confronto e' un passo suo, e finche' non e'
-- fatto i percorsi restano aperti e si contano.
--
-- **5. Le date fuori squadra entrano, e si contano.** Misurato il 16 settembre 2026
-- sui 13.215 veri: **2 attestati hanno una data nel futuro** (il piu' avanti al
-- 23/11/2026, su due persone diverse) e **96 sono anteriori al D.Lgs 81/2008**, di
-- cui 3 anche al 626/1994. Nessuno dei due casi si rifiuta:
--
--   * due righe su 13.215 sono **refusi da correggere alla fonte**, non una prassi
--     del gestionale da capire prima di importarla. Fermare la migrazione per due
--     righe costerebbe piu' di quanto valga, e cancellarle in silenzio sarebbe peggio
--     di tutte e due le cose;
--   * le 96 anteriori al 2008 **non sono un errore**: e' formazione fatta sotto il
--     626/1994, e oggi e' scaduta comunque.
--
-- **Ma una data nel futuro fa danno nel motore, non qui.** La validita' si conta da
-- quella data, quindi finche' non arriva quella persona risulterebbe **in regola per
-- un corso che non ha ancora fatto** — un falso verde, che e' il contrario di cio'
-- che questo sistema serve a fare. Questo passo le porta e le conta; **il motore
-- della Fase 4 deve trattare un attestato con data futura come non ancora
-- avvenuto**, ed e' scritto qui perche' li' non ci sia da riscoprirlo.
--
-- **6. Cosa non porta, e lo conta.** `esito`, `numero_attestato` e `fonte`
-- (interna/esterna) sono tre colonne che il campo ha e la `0021` no: si contano le
-- righe che le hanno valorizzate, cosi' un dato non portato resta diverso da un dato
-- che non c'era. `file_attestato` e' un documento, e i documenti sono la scheda 13.
--
-- **Rieseguibile:** l'`import_key` qui e' `af:<uuid d'origine>`, perche' e' l'unica
-- cosa che identifica quella riga nel loro database. Le righe gia' presenti si
-- saltano.

\set ON_ERROR_STOP on

begin;

select set_config('migrazione.righe_formazione_attese', :'righe_formazione_attese', true);

-- ---------- il titolo normalizzato, una volta sola ----------
--
-- Maiuscolo, spazi collassati, bordi tagliati. Non tocca la punteggiatura: due
-- dizionari curati a mano divergono sugli spazi, non sulle virgole, e ogni pezzo di
-- normalizzazione in piu' e' una collisione in piu' che aspetta.

create temp view alias_norm as
select btrim(regexp_replace(upper(testo), '\s+', ' ', 'g')) as norm,
       testo, corso_codice, ignorato, pregressa, parziale, is_aggiornamento
  from corso_alias;

create temp view origine_norm as
select o.*,
       btrim(regexp_replace(upper(o.corso_titolo), '\s+', ' ', 'g')) as titolo_norm,
       case when codice_fiscale_valido(o.codice_fiscale)
            then codice_fiscale_pulito(o.codice_fiscale) end as cf
  from origine.formazione o;

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

  select count(*) into n from origine.formazione where data_completamento is null;
  if n > 0 then
    raise exception '(b) % attestati senza data: la validita si conta da una data, e dedurla sarebbe inventarla', n;
  end if;

  -- Un titolo che il dizionario non conosce e' un corso che il gestionale ha e noi
  -- non abbiamo mai letto. Si guarda, non si traduce.
  select count(distinct titolo_norm) into n
    from origine_norm o
   where not exists (select 1 from alias_norm a where a.norm = o.titolo_norm);
  if n > 0 then
    raise exception '(c) % titoli distinti che il dizionario dei 268 alias non conosce: sono corsi nuovi del gestionale, si guardano prima di tradurli', n;
  end if;

  -- La collisione della normalizzazione: due alias distinti che collassano sullo
  -- stesso testo e portano a codici diversi. Misurata il 12 settembre su
  -- `PREPOSTI - BIENNALE` contro `PREPOSTI_BIENNALE`, 12 ore contro 8.
  select count(*) into n from (
    select norm from alias_norm
     where corso_codice is not null
     group by norm
    having count(distinct corso_codice) > 1) x;
  if n > 0 then
    raise exception '(d) % titoli normalizzati portano a piu di un corso: normalizzare qui perderebbe una distinzione presa a mano', n;
  end if;

  select count(*) into n
    from origine_norm o
    join alias_norm a on a.norm = o.titolo_norm
   where not a.ignorato and a.corso_codice is null;
  if n > 0 then
    raise exception '(e) % attestati con un alias conosciuto, non ignorato e senza destinazione: il dizionario e a meta su quel titolo', n;
  end if;
end $$;

-- ---------- la traduzione ----------

create temp table riga_formazione on commit drop as
select o.*,
       p.id as persona_dest,
       a.corso_codice as corso_dest,
       coalesce(a.ignorato, false)         as alias_ignorato,
       coalesce(a.pregressa, false)        as alias_pregressa,
       coalesce(a.parziale, false)         as alias_parziale,
       coalesce(a.is_aggiornamento, false) as alias_aggiornamento,
       'af:' || o.id::text                 as chiave
  from origine_norm o
  left join alias_norm a on a.norm = o.titolo_norm
  left join persona p on p.codice_fiscale = o.cf
 where not exists (select 1 from evento_formativo e where e.import_key = 'af:' || o.id::text);

insert into evento_formativo (
  persona_id, corso_codice, data, completa_il_percorso,
  is_aggiornamento, pregressa, parziale, evidenza_incompleta,
  ente_formatore, titolo_origine, ore_origine, import_key)
select persona_dest,
       corso_dest,
       data_completamento,
       not alias_parziale,
       alias_aggiornamento,
       alias_pregressa,
       alias_parziale,
       false,
       ente_erogatore,
       corso_titolo,
       ore,
       chiave
  from riga_formazione
 where persona_dest is not null
   and corso_dest is not null;

-- ---------- i conti, e cosa non e' entrato ----------

do $$
declare
  ingresso int; scritti int; ignorati int; senza_persona int; senza_cf int;
  frazionati int; collisioni int; con_esito int; con_numero int; esterni int;
  gia_presenti int; persone int; nel_futuro int; prima_del_81 int;
begin
  select count(*) into ingresso from origine.formazione;
  select count(*) into gia_presenti
    from origine.formazione o
   where not exists (select 1 from riga_formazione f where f.id = o.id);
  select count(*) into scritti from riga_formazione
   where persona_dest is not null and corso_dest is not null;
  select count(*) into ignorati from riga_formazione where corso_dest is null and alias_ignorato;
  select count(*) into senza_cf from riga_formazione where cf is null;
  select count(*) into senza_persona from riga_formazione
   where cf is not null and persona_dest is null;
  select count(*) into frazionati from riga_formazione
   where alias_parziale and persona_dest is not null and corso_dest is not null;
  select count(distinct persona_dest) into persone from riga_formazione
   where persona_dest is not null and corso_dest is not null;
  select count(*) into con_esito from riga_formazione f where f.esito is not null;
  select count(*) into con_numero from riga_formazione f where f.numero_attestato is not null;
  select count(*) into esterni from riga_formazione f where f.fonte = 'esterna';
  select count(*) into nel_futuro from riga_formazione f
   where f.persona_dest is not null and f.corso_dest is not null
     and f.data_completamento > current_date;
  select count(*) into prima_del_81 from riga_formazione f
   where f.persona_dest is not null and f.corso_dest is not null
     and f.data_completamento < date '2008-05-15';

  select count(*) into collisioni from (
    select persona_id, corso_codice, data
      from evento_formativo
     group by persona_id, corso_codice, data
    having count(*) > 1) x;

  raise notice 'attestati d''origine %  ->  eventi scritti %, su % persone', ingresso, scritti, persone;
  if gia_presenti > 0 then
    raise notice '  gia presenti da un giro precedente: % (saltati per import_key)', gia_presenti;
  end if;
  raise notice '  NON entrati: % con un titolo ignorato a mano, % senza codice fiscale valido, % con un codice fiscale che l''anagrafe non ha', ignorati, senza_cf, senza_persona;
  raise notice '  percorsi frazionati entrati APERTI: % (chi li chiude e un passo suo, coi due export FormFraz)', frazionati;
  raise notice '  persone, corsi e date su cui cadono due o piu attestati: % (si segnalano, non si fondono)', collisioni;
  raise notice '  NON portati: % con un esito, % con un numero di attestato, % dichiarati di fonte esterna', con_esito, con_numero, esterni;
  raise notice '  date fuori squadra, entrate e da guardare: % nel futuro (il motore le tratti come non avvenute), % anteriori al D.Lgs 81/2008', nel_futuro, prima_del_81;
end $$;

commit;
