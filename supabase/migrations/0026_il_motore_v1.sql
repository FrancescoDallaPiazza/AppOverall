-- AppOverall — 0026
-- Il motore v1: la classe della sede, gli obblighi per persona, le scadenze.
--
-- ============================================================================
--  PERCHE ESISTE, E COSA NON FA ANCORA
-- ============================================================================
--
-- E' il primo passo della Fase 4 (`docs/piano-fase-4.md`): lo scadenzario che deve
-- permettere di spegnere Sicurweb. Riusa l'impianto del motore di AppFormazione —
-- obbligo per persona, ultimo attestato che assolve, scadenza = completamento +
-- periodicita', stati in ordine di precedenza, preavviso per obbligo — con quello che
-- il repo unico sa in piu': il completamento del percorso (`0021`), i rapporti cessati
-- (`0025`), la classe sulla sede (decisione 1) e la posizione dell'RSPP esterno (`0010`).
--
-- **Non fa ancora, e lo dice invece di sbagliare:** i crediti dell'Allegato III
-- (`0009`), i regimi precedenti (`0014`), la regola transitoria del preposto, le ore
-- per classe di rischio, i livelli di emergenza (decisione 11). Il riscontro con lo
-- scadenzario di Sicurweb dira' in che ordine servono. Gli obblighi che dipendono da
-- queste cose escono `senza_regola` o con lo stato che il solo calendario da', e la
-- vista porta le colonne per riconoscerli.
--
-- ============================================================================
--  UNO — LA CLASSE DELL'ALLEGATO IV, GENERATA DALLA LIBRERIA
-- ============================================================================
--
-- Decisione 7: le tabelle con una chiave **stanno nella libreria**, e chi le consuma
-- le rigenera invece di trascriverle. Questa e' la copia: generata da
-- `formazione-81-utils-src/allegato_iv_asr2025.js`, commit 736699e, 88 divisioni ATECO
-- 2007 agg. 2022. Non si modifica a mano: se la libreria cambia, si rigenera con una
-- migrazione nuova. La classe **della sede** invece non si scrive (decisione 8): si
-- calcola in `v_classe_sede`.

create table ateco_classe (
  divisione text primary key constraint divisione_forma check (divisione ~ '^[0-9]{2}$'),
  sezione text not null,
  classe text not null constraint classe_nota check (classe in ('basso', 'medio', 'alto')),
  -- Vero sulle tre divisioni che il testo vigente non stampa (30, 86, 87): il valore
  -- viene dal 2011 e la deduzione e' nostra (decisione 5). Chi mostra la classe deve
  -- poterlo dire.
  dedotto boolean not null,
  fonte text,
  generato_da text not null default 'formazione-81-utils-src allegato_iv_asr2025.js @736699e'
);

insert into ateco_classe (divisione, sezione, classe, dedotto, fonte) values
  ('01', 'A', 'medio', false, null),
  ('02', 'A', 'medio', false, null),
  ('03', 'A', 'medio', false, null),
  ('05', 'B', 'alto', false, null),
  ('06', 'B', 'alto', false, null),
  ('07', 'B', 'alto', false, null),
  ('08', 'B', 'alto', false, null),
  ('09', 'B', 'alto', false, null),
  ('10', 'C', 'alto', false, null),
  ('11', 'C', 'alto', false, null),
  ('12', 'C', 'alto', false, null),
  ('13', 'C', 'alto', false, null),
  ('14', 'C', 'alto', false, null),
  ('15', 'C', 'alto', false, null),
  ('16', 'C', 'alto', false, null),
  ('17', 'C', 'alto', false, null),
  ('18', 'C', 'alto', false, null),
  ('19', 'C', 'alto', false, null),
  ('20', 'C', 'alto', false, null),
  ('21', 'C', 'alto', false, null),
  ('22', 'C', 'alto', false, null),
  ('23', 'C', 'alto', false, null),
  ('24', 'C', 'alto', false, null),
  ('25', 'C', 'alto', false, null),
  ('26', 'C', 'alto', false, null),
  ('27', 'C', 'alto', false, null),
  ('28', 'C', 'alto', false, null),
  ('29', 'C', 'alto', false, null),
  ('30', 'C', 'alto', true, 'Allegato II Accordo 221/CSR del 21/12/2011, GU n.8 dell''11/01/2012 p. 48, atto 12A00059 — il testo vigente tace per guasto tipografico, non per scelta'),
  ('31', 'C', 'alto', false, null),
  ('32', 'C', 'alto', false, null),
  ('33', 'C', 'alto', false, null),
  ('35', 'D', 'alto', false, null),
  ('36', 'E', 'alto', false, null),
  ('37', 'E', 'alto', false, null),
  ('38', 'E', 'alto', false, null),
  ('39', 'E', 'alto', false, null),
  ('41', 'F', 'alto', false, null),
  ('42', 'F', 'alto', false, null),
  ('43', 'F', 'alto', false, null),
  ('45', 'G', 'basso', false, null),
  ('46', 'G', 'basso', false, null),
  ('47', 'G', 'basso', false, null),
  ('49', 'H', 'medio', false, null),
  ('50', 'H', 'medio', false, null),
  ('51', 'H', 'medio', false, null),
  ('52', 'H', 'medio', false, null),
  ('53', 'H', 'medio', false, null),
  ('55', 'I', 'basso', false, null),
  ('56', 'I', 'basso', false, null),
  ('58', 'J', 'basso', false, null),
  ('59', 'J', 'basso', false, null),
  ('60', 'J', 'basso', false, null),
  ('61', 'J', 'basso', false, null),
  ('62', 'J', 'basso', false, null),
  ('63', 'J', 'basso', false, null),
  ('64', 'K', 'basso', false, null),
  ('65', 'K', 'basso', false, null),
  ('66', 'K', 'basso', false, null),
  ('68', 'L', 'basso', false, null),
  ('69', 'M', 'basso', false, null),
  ('70', 'M', 'basso', false, null),
  ('71', 'M', 'basso', false, null),
  ('72', 'M', 'basso', false, null),
  ('73', 'M', 'basso', false, null),
  ('74', 'M', 'basso', false, null),
  ('75', 'M', 'basso', false, null),
  ('77', 'N', 'basso', false, null),
  ('78', 'N', 'basso', false, null),
  ('79', 'N', 'basso', false, null),
  ('80', 'N', 'basso', false, null),
  ('81', 'N', 'basso', false, null),
  ('82', 'N', 'basso', false, null),
  ('84', 'O', 'medio', false, null),
  ('85', 'P', 'medio', false, null),
  ('86', 'Q', 'alto', true, 'Allegato II Accordo 221/CSR del 21/12/2011, GU n.8 dell''11/01/2012 p. 48, atto 12A00059 — il testo vigente tace per guasto tipografico, non per scelta'),
  ('87', 'Q', 'alto', true, 'Allegato II Accordo 221/CSR del 21/12/2011, GU n.8 dell''11/01/2012 p. 48, atto 12A00059 — il testo vigente tace per guasto tipografico, non per scelta'),
  ('88', 'Q', 'medio', false, null),
  ('90', 'R', 'basso', false, null),
  ('91', 'R', 'basso', false, null),
  ('92', 'R', 'basso', false, null),
  ('93', 'R', 'basso', false, null),
  ('94', 'S', 'basso', false, null),
  ('95', 'S', 'basso', false, null),
  ('96', 'S', 'basso', false, null),
  ('97', 'T', 'basso', false, null),
  ('98', 'T', 'basso', false, null),
  ('99', 'U', 'basso', false, null);

comment on table ateco_classe is
  'Allegato IV ASR 17/04/2025: divisione ATECO 2007 agg. 2022 -> classe di rischio. COPIA GENERATA dalla libreria formazione-81-utils-src (decisione 7): non si modifica a mano, si rigenera. A due cifre 2007 e 2022 sono le stesse 88 divisioni (AppFormazione 0048). Per un codice ATECO 2025 serve il raccordo, che qui non c''e: la classe resta ignota.';

-- ============================================================================
--  DUE — IL PREAVVISO, CHE E' UNA SCELTA E NON UNA NORMA
-- ============================================================================
--
-- 180 giorni per la formazione e 90 per l'aggiornamento dell'RLS sono quelli di
-- AppFormazione, che li ha scelti per le sue lettere. **L'RLS e' formazione come le
-- altre**: la riga a parte non la separa, le da' solo un preavviso piu' corto, perche' il
-- suo aggiornamento e' annuale e 180 giorni sarebbero meta' del ciclo. 60 per le visite:
-- proposto qui e confermato da Francesco il 17 settembre 2026. Una tabella e non una
-- costante, perche' cambiarli non deve chiedere una migrazione.

create table scadenzario_preavviso (
  ambito text primary key,
  giorni int not null constraint giorni_positivi check (giorni > 0),
  deciso boolean not null,
  nota text
);

insert into scadenzario_preavviso (ambito, giorni, deciso, nota) values
  ('formazione', 180, true,  'Come AppFormazione (obblighi.giorni_preavviso), per le lettere di sollecito.'),
  ('formazione_rls', 90, true, 'E formazione: cambia solo il preavviso, perche l''aggiornamento dell''RLS e annuale e 180 giorni sarebbero meta del ciclo. Come AppFormazione.'),
  ('sorveglianza', 60, true,  'Proposto il 17/09/2026 e confermato da Francesco lo stesso giorno. Nessuna fonte lo fissa.');

-- ============================================================================
--  TRE — LA CLASSE DELLA SEDE
-- ============================================================================
--
-- Il default dall'ATECO, lo scostamento se qualcuno l'ha annotato (decisione 8), e la
-- classe che vale. Un codice 2025, o una sede senza ATECO, danno un default ignoto: la
-- vista non lo indovina.

create view v_classe_sede with (security_invoker = on) as
select s.id as sede_id,
       s.cliente_id,
       s.codice_ateco,
       s.ateco_versione,
       a.classe as classe_ateco,
       a.dedotto as classe_ateco_dedotta,
       v.valore as classe_valutata,
       v.motivazione as classe_valutata_perche,
       coalesce(v.valore, a.classe) as classe,
       case when v.valore is not null then 'valutazione'
            when a.classe is not null then 'ateco'
       end as classe_da
  from sede s
  left join ateco_classe a
         on s.ateco_versione in ('2007', '2022')
        and a.divisione = left(s.codice_ateco, 2)
  left join valutazione_sede v
         on v.sede_id = s.id and v.attributo = 'livello_rischio' and v.revocato_il is null;

comment on view v_classe_sede is
  'La classe di rischio di ogni sede: il default dell''Allegato IV dalla divisione ATECO, lo scostamento annotato (valutazione_sede) e quella che vale. Il default non si memorizza (decisione 8). classe null = nessuno la sa: ATECO assente, o 2025 senza raccordo.';

-- ============================================================================
--  QUATTRO — CHI E' TENUTO A COSA
-- ============================================================================
--
-- Una riga per persona, cliente e ruolo, **solo sui rapporti non cessati** (`0025`):
--
--   * i ruoli delle **nomine vive** della persona presso quel cliente, tranne quelli
--     con una posizione che cambia l'esito (l'RSPP esterno: `0010`);
--   * i ruoli **che valgono per tutti** (`lavoratore`) per ogni rapporto — tranne per
--     chi presso quel cliente e' nominato datore di lavoro, come fa AppFormazione.
--
-- Una nomina senza un rapporto vivo presso quel cliente non genera un obbligo: chi e'
-- uscito non si convoca.

create view v_obbligo_persona with (security_invoker = on) as
with rapporto_vivo as (
  select distinct on (r.persona_id, r.cliente_id)
         r.persona_id, r.cliente_id, r.sede_id
    from rapporto_lavoro r
   where not r.cessato
   order by r.persona_id, r.cliente_id, r.sede_id nulls last
),
dalle_nomine as (
  select n.persona_id, n.cliente_id, coalesce(n.sede_id, r.sede_id) as sede_id,
         n.ruolo, 'nomina'::text as da
    from nomina n
    join rapporto_vivo r on r.persona_id = n.persona_id and r.cliente_id = n.cliente_id
    left join posizione_persona pp on pp.codice = n.posizione
   where n.data_cessazione is null
     and not coalesce(pp.cambia_l_esito, false)
),
per_tutti as (
  select r.persona_id, r.cliente_id, r.sede_id, rs.codice as ruolo, 'rapporto'::text as da
    from rapporto_vivo r
    cross join ruolo_sicurezza rs
   where rs.vale_per_tutti
     and not exists (select 1 from nomina n
                      where n.persona_id = r.persona_id and n.cliente_id = r.cliente_id
                        and n.data_cessazione is null
                        and n.ruolo like 'datore_lavoro%')
)
select distinct on (persona_id, cliente_id, ruolo)
       persona_id, cliente_id, sede_id, ruolo, da
  from (select * from dalle_nomine union all select * from per_tutti) o
 order by persona_id, cliente_id, ruolo, da;

comment on view v_obbligo_persona is
  'Chi e tenuto a quale obbligo, presso quale cliente: le nomine vive e i ruoli che valgono per tutti, sui soli rapporti non cessati (0025). L''RSPP esterno non genera obblighi (0010). Il datore di lavoro non e anche lavoratore presso il proprio cliente.';

-- ============================================================================
--  CINQUE — LA SCADENZA DI OGNI OBBLIGO
-- ============================================================================
--
-- **Quale attestato conta.** Uno che chiude il percorso (`0021`), con una data non nel
-- futuro (passo 04, regola 5), di un corso che assolve il ruolo per intero
-- (`corso_assolve`, righe non `parziale`).
--
-- **Da dove si conta la scadenza.** Dall'ultimo attestato di un corso **periodico**:
-- `lavoratore` si assolve con `LAV_GEN` o `LAV_SPEC`, ma si aggiorna solo la
-- specifica; l'RSPP con i moduli A, B, C, ma si aggiorna solo il B. Chi ha soltanto la
-- parte che non scade e' **incompleto**, non in regola per sempre. La periodicita' e'
-- quella del corso che ha dato la data.
--
-- **La scadenza dichiarata** di quell'attestato, se c'e', vale al posto della
-- calcolata, e le due restano visibili (`0005`, `0021`).
--
-- **Gli stati, in quest'ordine:** `senza_regola` (il ruolo non ha corsi che lo
-- assolvono), `mancante`, `in_corso` (solo sessioni aperte), `non_scade`, `incompleto`,
-- `scaduto`, `in_scadenza`, `valido`.

create view v_scadenza_formazione with (security_invoker = on) as
with regola as (
  select ca.ruolo,
         count(*) as corsi,
         bool_or(c.aggiornamento_mesi is not null) as periodica
    from corso_assolve ca
    join corso c on c.codice = ca.corso_codice
   where not ca.parziale and ca.corso_codice is not null
   group by ca.ruolo
),
attestato as (
  select e.persona_id, e.corso_codice, e.data, e.scadenza_dichiarata, e.scadenza_fonte,
         e.pregressa, e.evidenza_incompleta, e.id,
         c.aggiornamento_mesi, ca.ruolo
    from evento_formativo e
    join corso c on c.codice = e.corso_codice
    join corso_assolve ca on ca.corso_codice = e.corso_codice and not ca.parziale
   where e.completa_il_percorso
     and e.data <= current_date
),
ultimo_periodico as (
  select distinct on (a.persona_id, a.ruolo) a.*
    from attestato a
   where a.aggiornamento_mesi is not null
   order by a.persona_id, a.ruolo, a.data desc, a.id
),
ultimo_qualunque as (
  select distinct on (a.persona_id, a.ruolo) a.persona_id, a.ruolo, a.data, a.corso_codice
    from attestato a
   order by a.persona_id, a.ruolo, a.data desc, a.id
),
sessioni_aperte as (
  select e.persona_id, ca.ruolo, count(*) as n
    from evento_formativo e
    join corso_assolve ca on ca.corso_codice = e.corso_codice and not ca.parziale
   where not e.completa_il_percorso
     and e.percorso_dichiarato is distinct from 'completato'
     and e.data <= current_date
   group by e.persona_id, ca.ruolo
),
calcolo as (
  select o.persona_id, o.cliente_id, o.sede_id, o.ruolo, o.da as obbligo_da,
         (g.ruolo is not null) as ha_regola,
         coalesce(g.periodica, false) as periodica,
         p.corso_codice as corso,
         p.data as completato_il,
         (p.data + (p.aggiornamento_mesi || ' months')::interval)::date as scadenza_calcolata,
         p.scadenza_dichiarata,
         p.scadenza_fonte,
         coalesce(p.pregressa, false) as pregressa,
         coalesce(p.evidenza_incompleta, false) as evidenza_incompleta,
         q.data as ultimo_attestato_il,
         q.corso_codice as ultimo_corso,
         coalesce(s.n, 0) as sessioni_aperte,
         case when o.ruolo = 'rls' then 'formazione_rls' else 'formazione' end as ambito
    from v_obbligo_persona o
    left join regola g on g.ruolo = o.ruolo
    left join ultimo_periodico p on p.persona_id = o.persona_id and p.ruolo = o.ruolo
    left join ultimo_qualunque q on q.persona_id = o.persona_id and q.ruolo = o.ruolo
    left join sessioni_aperte s on s.persona_id = o.persona_id and s.ruolo = o.ruolo
)
select c.*,
       coalesce(c.scadenza_dichiarata, c.scadenza_calcolata) as scadenza,
       (c.scadenza_dichiarata is not null and c.scadenza_dichiarata < c.scadenza_calcolata) as anticipata,
       coalesce(c.scadenza_dichiarata, c.scadenza_calcolata) - current_date as giorni_residui,
       case
         when not c.ha_regola                                          then 'senza_regola'
         when c.ultimo_attestato_il is null and c.sessioni_aperte = 0  then 'mancante'
         when c.ultimo_attestato_il is null                            then 'in_corso'
         when not c.periodica                                          then 'non_scade'
         when c.completato_il is null                                  then 'incompleto'
         when coalesce(c.scadenza_dichiarata, c.scadenza_calcolata) < current_date then 'scaduto'
         when coalesce(c.scadenza_dichiarata, c.scadenza_calcolata) <= current_date + pv.giorni then 'in_scadenza'
         else 'valido'
       end as stato
  from calcolo c
  join scadenzario_preavviso pv on pv.ambito = c.ambito;

comment on view v_scadenza_formazione is
  'Motore v1 (0026): per ogni persona, cliente e obbligo, l''ultimo attestato che lo assolve e la scadenza. Stati: senza_regola, mancante, in_corso, non_scade, incompleto, scaduto, in_scadenza, valido. NON considera ancora crediti, regimi precedenti, regola transitoria del preposto, ore per classe e livelli di emergenza: lo dice il piano della Fase 4, e il riscontro con Sicurweb decide l''ordine.';

-- ============================================================================
--  SEI — LA SCADENZA DI OGNI VISITA
-- ============================================================================
--
-- L'ultima visita per persona e accertamento, sui soli rapporti non cessati. **Non
-- dice che una visita manca**: servirebbe il protocollo sanitario per mansione, che
-- non c'e' (`0005`, scheda 10).

create view v_scadenza_visita with (security_invoker = on) as
with ultima as (
  select distinct on (v.persona_id, v.accertamento) v.*
    from v_sorveglianza v
   where v.data_esecuzione <= current_date
   order by v.persona_id, v.accertamento, v.data_esecuzione desc
)
select u.persona_id, u.accertamento, u.accertamento_nome, u.data_esecuzione,
       u.scadenza, u.scadenza_calcolata, u.scadenza_dichiarata, u.scadenza_fonte, u.anticipata,
       u.scadenza - current_date as giorni_residui,
       case when u.scadenza < current_date then 'scaduto'
            when u.scadenza <= current_date + pv.giorni then 'in_scadenza'
            else 'valido' end as stato
  from ultima u
  join scadenzario_preavviso pv on pv.ambito = 'sorveglianza'
 where exists (select 1 from rapporto_lavoro r where r.persona_id = u.persona_id and not r.cessato);

comment on view v_scadenza_visita is
  'Motore v1 (0026): l''ultima visita per persona e accertamento, con la scadenza che vale e lo stato, sulle persone con almeno un rapporto non cessato. Non dice che una visita manca: il protocollo sanitario per mansione non c''e (0005).';

-- ============================================================================
--  RLS E GRANT
-- ============================================================================

alter table ateco_classe enable row level security;
alter table scadenzario_preavviso enable row level security;
create policy leggono_gli_operatori on ateco_classe for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on scadenzario_preavviso for select to authenticated using (e_operatore());
create policy scrive_amministrazione on scadenzario_preavviso for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
grant select on ateco_classe, scadenzario_preavviso to authenticated;
grant select on v_classe_sede, v_obbligo_persona, v_scadenza_formazione, v_scadenza_visita to authenticated;
