-- AppOverall — 0027
-- Il motore v2: segue anche i corsi fatti senza nomina, e l'emergenza con il suo livello.
--
-- ============================================================================
--  PERCHE ESISTE: IL PRIMO RISCONTRO VERO
-- ============================================================================
--
-- Il 17 settembre 2026 il passo 08 ha messo il motore v1 (`0026`) accanto allo
-- scadenzario di Sicurweb, sui dati veri: **dove ci sono tutti e due, 1.935 coppie su
-- 1.943 sono uguali**, 8 hanno una periodicita' diversa, zero sono diverse senza ragione.
-- Il divario e' di **copertura**, e ha una causa sola: **Sicurweb segue ogni corso fatto,
-- il motore partiva dalle nomine.**
--
--   ruolo non assegnato             1.098   carrelli 274, preposti 199, quota 150, PLE 116...
--   corso senza obbligo nel catalogo 1.530  antincendio 661, primo soccorso 614,
--                                           DL_RSPP_BASE 188, BLSD 67
--
-- ============================================================================
--  LE DUE DECISIONI DI FRANCESCO, 17 SETTEMBRE 2026
-- ============================================================================
--
-- **1. «Si', come Sicurweb — ma va segnalato nell'app per aggiornare l'organigramma».**
-- Un corso periodico fatto da una persona in forza genera una scadenza anche se nessuna
-- nomina lo chiede. La riga dice `obbligo_da = 'attestato'` e `ruolo_da_confermare`, e
-- `v_ruolo_da_confermare` e' la lista che l'app mostra: la persona ha fatto il corso dei
-- carrelli, l'organigramma non la dice carrellista.
--
-- Il ruolo **proposto** e' quello che il corso assolve, **se e' uno solo**. `RSPP_MOD_A`
-- assolve ASPP e RSPP, e la proposta resta vuota: scegliere fra due figure non e' una
-- deduzione. `BLSD` e `DL_RSPP_BASE` non assolvono nessun ruolo, e la scadenza c'e'
-- comunque — e' esattamente quello che fa Sicurweb.
--
-- **2. «Scadenza, e avviso sul livello».** Antincendio e primo soccorso entrano fra gli
-- obblighi che hanno un corso (`corso_assolve`), e ogni riga porta il confronto della
-- decisione 11 fra il livello della sede e quello del corso:
--
--   livello della sede non definito        livello_non_definito  (si segnala, non blocca)
--   antincendio: corso pari o superiore    conforme              (decisione nostra, non norma)
--   antincendio: corso inferiore           non_conforme
--   primo soccorso: A <-> PS_GRA,
--                   B, C, BC <-> PS_GRBC   conforme / non_conforme (corrispondenza, non scala)
--
-- Oggi nessuna sede ha un livello (passo 06): tutte le righe diranno
-- `livello_non_definito`, ed e' la verita'.
--
-- ============================================================================
--  COSA NON FA ANCORA
-- ============================================================================
--
-- I crediti dell'Allegato III, i regimi precedenti, la regola transitoria del
-- preposto, le ore per classe. Il riscontro vero non ne ha mostrato il bisogno fra le
-- coppie che ci sono: si rileggono quando la copertura sara' chiusa.

-- ============================================================================
--  UNO — L'EMERGENZA NEL CATALOGO DEGLI OBBLIGHI
-- ============================================================================
--
-- La `0006` le aveva lasciate fuori «in attesa della decisione 11». La 11 c'e' dall'11
-- settembre, e la 2 di oggi dice come usarla: le righe entrano per corso, **non** per
-- `categoria` (la `0004` spiega perche': l'OR su una scala direbbe conforme un livello 1
-- dove serve il 3). Il livello lo giudica la vista, non questa tabella.

insert into corso_assolve (ruolo, corso_codice, categoria, parziale, note) values
  ('addetto_antincendio',    'AI_LIV1', null, false, 'Decisione 11 e decisione di Francesco del 17.09.2026: la riga dice che il corso assolve il ruolo; se il livello basta lo dice v_scadenza_formazione.esito_livello.'),
  ('addetto_antincendio',    'AI_LIV2', null, false, 'Come AI_LIV1.'),
  ('addetto_antincendio',    'AI_LIV3', null, false, 'Come AI_LIV1.'),
  ('addetto_primo_soccorso', 'PS_GRA',  null, false, 'Decisione 11: corrispondenza col gruppo A, non una scala.'),
  ('addetto_primo_soccorso', 'PS_GRBC', null, false, 'Decisione 11: corrispondenza coi gruppi B e C.');

create table corso_livello_emergenza (
  corso_codice text not null references corso(codice),
  attributo text not null
    constraint livello_attributo_noto check (attributo in ('livello_antincendio', 'gruppo_primo_soccorso')),
  livello text not null,
  primary key (corso_codice, attributo, livello)
);

insert into corso_livello_emergenza (corso_codice, attributo, livello) values
  ('AI_LIV1', 'livello_antincendio', '1'),
  ('AI_LIV2', 'livello_antincendio', '2'),
  ('AI_LIV3', 'livello_antincendio', '3'),
  ('PS_GRA',  'gruppo_primo_soccorso', 'A'),
  ('PS_GRBC', 'gruppo_primo_soccorso', 'B'),
  ('PS_GRBC', 'gruppo_primo_soccorso', 'C'),
  -- `BC` e' il gruppo di prima della loro `050`, e il passo 06 lo porta com'e'.
  ('PS_GRBC', 'gruppo_primo_soccorso', 'BC');

comment on table corso_livello_emergenza is
  'A quale livello antincendio o gruppo di primo soccorso corrisponde un corso (decisione 11). Per l''antincendio il motore confronta «pari o superiore» (decisione nostra, marcata tale); per il primo soccorso cerca la corrispondenza.';

-- ============================================================================
--  DUE — IL MOTORE, RISCRITTO
-- ============================================================================

drop view v_scadenza_formazione;

create view v_scadenza_formazione with (security_invoker = on) as
with regola as (
  select ca.ruolo,
         bool_or(c.aggiornamento_mesi is not null) as periodica
    from corso_assolve ca
    join corso c on c.codice = ca.corso_codice
   where not ca.parziale and ca.corso_codice is not null
   group by ca.ruolo
),
-- gli attestati che chiudono il percorso e non sono nel futuro, di qualunque corso
completato as (
  select e.id, e.persona_id, e.corso_codice, e.data, e.scadenza_dichiarata, e.scadenza_fonte,
         e.pregressa, e.evidenza_incompleta, c.aggiornamento_mesi
    from evento_formativo e
    join corso c on c.codice = e.corso_codice
   where e.completa_il_percorso
     and e.data <= current_date
),
-- ---------- la parte per obbligo, come la v1 ----------
attestato as (
  select a.*, ca.ruolo
    from completato a
    join corso_assolve ca on ca.corso_codice = a.corso_codice and not ca.parziale
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
da_obbligo as (
  select o.persona_id, o.cliente_id, o.sede_id, o.ruolo, o.da as obbligo_da,
         (g.ruolo is not null) as ha_regola,
         coalesce(g.periodica, false) as periodica,
         p.corso_codice as corso,
         p.data as completato_il,
         (p.data + (p.aggiornamento_mesi || ' months')::interval)::date as scadenza_calcolata,
         p.scadenza_dichiarata, p.scadenza_fonte,
         coalesce(p.pregressa, false) as pregressa,
         coalesce(p.evidenza_incompleta, false) as evidenza_incompleta,
         q.data as ultimo_attestato_il,
         q.corso_codice as ultimo_corso,
         coalesce(s.n, 0) as sessioni_aperte,
         false as ruolo_da_confermare
    from v_obbligo_persona o
    left join regola g on g.ruolo = o.ruolo
    left join ultimo_periodico p on p.persona_id = o.persona_id and p.ruolo = o.ruolo
    left join ultimo_qualunque q on q.persona_id = o.persona_id and q.ruolo = o.ruolo
    left join sessioni_aperte s on s.persona_id = o.persona_id and s.ruolo = o.ruolo
),
-- ---------- la parte per attestato (decisione 1 del 17.09.2026) ----------
rapporto_vivo as (
  select distinct on (r.persona_id, r.cliente_id) r.persona_id, r.cliente_id, r.sede_id
    from rapporto_lavoro r
   where not r.cessato
   order by r.persona_id, r.cliente_id, r.sede_id nulls last
),
per_corso as (
  select distinct on (a.persona_id, a.corso_codice) a.*
    from completato a
   where a.aggiornamento_mesi is not null
   order by a.persona_id, a.corso_codice, a.data desc, a.id
),
-- i corsi che un obbligo della persona, presso quel cliente, gia' segue
coperto as (
  select o.persona_id, o.cliente_id, ca.corso_codice
    from v_obbligo_persona o
    join corso_assolve ca on ca.ruolo = o.ruolo and not ca.parziale
),
ruolo_proposto as (
  select ca.corso_codice, min(ca.ruolo) as ruolo
    from corso_assolve ca
   where not ca.parziale and ca.corso_codice is not null
   group by ca.corso_codice
  having count(distinct ca.ruolo) = 1
),
da_attestato as (
  select r.persona_id, r.cliente_id, r.sede_id, rp.ruolo, 'attestato'::text as obbligo_da,
         true as ha_regola, true as periodica,
         p.corso_codice as corso,
         p.data as completato_il,
         (p.data + (p.aggiornamento_mesi || ' months')::interval)::date as scadenza_calcolata,
         p.scadenza_dichiarata, p.scadenza_fonte,
         p.pregressa, p.evidenza_incompleta,
         p.data as ultimo_attestato_il,
         p.corso_codice as ultimo_corso,
         0::bigint as sessioni_aperte,
         true as ruolo_da_confermare
    from rapporto_vivo r
    join per_corso p on p.persona_id = r.persona_id
    left join ruolo_proposto rp on rp.corso_codice = p.corso_codice
   where not exists (select 1 from coperto k
                      where k.persona_id = r.persona_id and k.cliente_id = r.cliente_id
                        and k.corso_codice = p.corso_codice)
),
calcolo as (
  select * from da_obbligo
  union all
  select * from da_attestato
),
-- ---------- il livello di emergenza (decisione 2 del 17.09.2026) ----------
livello as (
  select c.*,
         case when c.ruolo = 'addetto_antincendio' or c.corso in ('AI_LIV1', 'AI_LIV2', 'AI_LIV3')
                   then 'livello_antincendio'
              when c.ruolo = 'addetto_primo_soccorso' or c.corso in ('PS_GRA', 'PS_GRBC')
                   then 'gruppo_primo_soccorso'
         end as attributo_emergenza
    from calcolo c
)
select l.persona_id, l.cliente_id, l.sede_id, l.ruolo, l.obbligo_da, l.ha_regola, l.periodica,
       l.corso, l.completato_il, l.scadenza_calcolata, l.scadenza_dichiarata, l.scadenza_fonte,
       l.pregressa, l.evidenza_incompleta, l.ultimo_attestato_il, l.ultimo_corso, l.sessioni_aperte,
       case when l.ruolo = 'rls' or l.corso = 'RLS' then 'formazione_rls' else 'formazione' end as ambito,
       coalesce(l.scadenza_dichiarata, l.scadenza_calcolata) as scadenza,
       (l.scadenza_dichiarata is not null and l.scadenza_dichiarata < l.scadenza_calcolata) as anticipata,
       coalesce(l.scadenza_dichiarata, l.scadenza_calcolata) - current_date as giorni_residui,
       case
         when not l.ha_regola                                          then 'senza_regola'
         when l.ultimo_attestato_il is null and l.sessioni_aperte = 0  then 'mancante'
         when l.ultimo_attestato_il is null                            then 'in_corso'
         when not l.periodica                                          then 'non_scade'
         when l.completato_il is null                                  then 'incompleto'
         when coalesce(l.scadenza_dichiarata, l.scadenza_calcolata) < current_date then 'scaduto'
         when coalesce(l.scadenza_dichiarata, l.scadenza_calcolata) <= current_date + pv.giorni then 'in_scadenza'
         else 'valido'
       end as stato,
       l.ruolo_da_confermare,
       vs.valore as livello_richiesto,
       case
         when l.attributo_emergenza is null then null
         when l.corso is null then null
         when vs.valore is null then 'livello_non_definito'
         when l.attributo_emergenza = 'livello_antincendio'
              then case when exists (select 1 from corso_livello_emergenza e
                                      where e.corso_codice = l.corso and e.attributo = 'livello_antincendio'
                                        and e.livello >= vs.valore)
                        then 'conforme' else 'non_conforme' end
         else case when exists (select 1 from corso_livello_emergenza e
                                 where e.corso_codice = l.corso and e.attributo = 'gruppo_primo_soccorso'
                                   and e.livello = vs.valore)
                   then 'conforme' else 'non_conforme' end
       end as esito_livello
  from livello l
  join scadenzario_preavviso pv
    on pv.ambito = case when l.ruolo = 'rls' or l.corso = 'RLS' then 'formazione_rls' else 'formazione' end
  left join valutazione_sede vs
         on vs.sede_id = l.sede_id and vs.attributo = l.attributo_emergenza and vs.revocato_il is null;

comment on view v_scadenza_formazione is
  'Motore v2 (0027): per ogni persona e cliente, le scadenze degli obblighi (dalle nomine e da lavoratore) e, come fa Sicurweb, quelle dei corsi periodici fatti che nessuna nomina segue (obbligo_da = attestato, ruolo_da_confermare). Per antincendio e primo soccorso, esito_livello confronta il livello della sede con quello del corso (decisione 11): livello_non_definito, conforme, non_conforme. NON considera ancora crediti, regimi precedenti, regola transitoria del preposto e ore per classe.';
comment on column v_scadenza_formazione.ruolo_da_confermare is
  'Vero sulle scadenze che vengono da un attestato e non da una nomina: la persona ha fatto il corso, l''organigramma non le da il ruolo. Decisione di Francesco del 17.09.2026: si segue la scadenza, e l''app lo segnala perche l''organigramma si aggiorni.';

-- ============================================================================
--  TRE — LA LISTA PER L'ORGANIGRAMMA
-- ============================================================================

create view v_ruolo_da_confermare with (security_invoker = on) as
select s.cliente_id, s.sede_id, s.persona_id, p.cognome, p.nome,
       s.corso, c.nome as corso_nome, s.ruolo as ruolo_proposto,
       s.completato_il, s.scadenza, s.stato
  from v_scadenza_formazione s
  join persona p on p.id = s.persona_id
  join corso c on c.codice = s.corso
 where s.ruolo_da_confermare;

comment on view v_ruolo_da_confermare is
  'Chi ha fatto un corso periodico che nessuna nomina presso quel cliente segue: da proporre all''organigramma. ruolo_proposto e vuoto quando il corso assolve piu ruoli (RSPP_MOD_A) o nessuno (BLSD, DL_RSPP_BASE): li la scelta e di chi aggiorna l''organigramma.';

alter table corso_livello_emergenza enable row level security;
create policy leggono_gli_operatori on corso_livello_emergenza for select to authenticated using (e_operatore());
grant select on corso_livello_emergenza to authenticated;
grant select on v_scadenza_formazione, v_ruolo_da_confermare to authenticated;
