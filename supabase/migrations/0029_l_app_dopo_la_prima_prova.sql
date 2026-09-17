-- ============================================================================
--  0029 — L'APP DOPO LA PRIMA PROVA DI FRANCESCO
-- ============================================================================
--
-- Francesco ha provato l'app sul banco il 17 settembre 2026. Cosa ne viene, per il
-- database:
--
--   UNO     l'attestato registrato dall'app porta gli elementi minimi dell'ASR 2025
--           (Parte I, punto 6), e il database li pretende;
--   DUE     lo scadenzario ha una priorita: prima le mancanti, poi le scadute dalla
--           piu vecchia, poi quelle in scadenza;
--   TRE     i promemoria in una vista sola: ruoli da confermare, livelli di
--           emergenza, ruoli per cui il catalogo non dice quale corso serve;
--   QUATTRO il cliente in una riga, con formazione e visite separate;
--   CINQUE  i corsi che chiudono un obbligo, per proporli quando si registra da una
--           scadenza.

-- ============================================================================
--  UNO — GLI ELEMENTI MINIMI DELL'ATTESTATO
-- ============================================================================
--
-- ASR 17/04/2025 (Rep. Atti 59/CSR), Parte I, punto 6 «Attestazioni», pag. 9 di 136:
--
--   a) denominazione del soggetto formatore;        -> ente_formatore
--   b) nome, cognome, codice fiscale;               -> persona
--   c) tipologia di corso con riferimento normativo
--      e durata;                                    -> corso_codice, ore_attestato
--   d) modalita di erogazione del corso;            -> modalita_erogazione
--   e) firma del legale rappresentante del soggetto
--      formatore o suoi incaricati;                 -> attestato_firmato
--   f) data e luogo.                                -> data, luogo
--
-- Le modalita sono le quattro del punto 4 della stessa Parte I (pag. 8). Le righe
-- della migrazione dati non le hanno, e non le avranno: il vincolo vale solo per
-- quelle che registra un operatore dall'app.

alter table evento_formativo
  add column ore_attestato numeric(5,1) check (ore_attestato > 0),
  add column modalita_erogazione text check (modalita_erogazione in
    ('presenza', 'videoconferenza_sincrona', 'e_learning', 'mista')),
  add column luogo text,
  add column attestato_firmato boolean;

comment on column evento_formativo.ore_attestato is
  'La durata scritta sull''attestato (ASR 2025, Parte I, punto 6 c). Solo per le righe registrate dall''app (0029); quelle importate hanno ore_origine.';
comment on column evento_formativo.modalita_erogazione is
  'ASR 2025, Parte I, punti 4 e 6 d: presenza, videoconferenza_sincrona, e_learning, mista.';
comment on column evento_formativo.luogo is
  'Il luogo scritto sull''attestato (ASR 2025, Parte I, punto 6 f).';
comment on column evento_formativo.attestato_firmato is
  'Chi registra ha visto la firma del soggetto formatore sull''attestato (ASR 2025, Parte I, punto 6 e).';

create or replace function attestato_dati_minimi() returns trigger
language plpgsql as $$
declare
  manca text[] := '{}';
begin
  -- Solo le righe dell'app: la migrazione dati gira senza un operatore.
  if operatore_corrente() is null then
    return new;
  end if;
  if coalesce(btrim(new.ente_formatore), '') = '' then manca := manca || 'soggetto formatore'::text; end if;
  if new.ore_attestato is null then manca := manca || 'durata'::text; end if;
  if new.modalita_erogazione is null then manca := manca || 'modalita di erogazione'::text; end if;
  if coalesce(btrim(new.luogo), '') = '' then manca := manca || 'luogo'::text; end if;
  if new.attestato_firmato is distinct from true then manca := manca || 'firma del soggetto formatore'::text; end if;
  if cardinality(manca) > 0 then
    raise exception 'Mancano gli elementi minimi dell''attestato (ASR 2025, Parte I, punto 6): %',
      array_to_string(manca, ', ')
      using errcode = 'check_violation';
  end if;
  return new;
end
$$;

create trigger evento_formativo_dati_minimi before insert on evento_formativo
  for each row execute function attestato_dati_minimi();

-- ============================================================================
--  DUE — LA PRIORITA NELLO SCADENZARIO
-- ============================================================================
--
-- «Lo stato mancante dev'essere in testa, mentre le scadenze da scaduto devono poi
-- essere messe in ordine di priorita dalla piu scaduta» (Francesco). La colonna va in
-- coda, cosi la vista si sostituisce; l'app ordina per `priorita, scadenza`.

create or replace view v_scadenzario with (security_invoker = on) as
select 'formazione'::text as tipo,
       s.persona_id, p.cognome, p.nome, p.codice_fiscale,
       s.cliente_id, c.ragione_sociale, s.sede_id, d.denominazione as sede,
       s.ruolo as obbligo, rs.nome as obbligo_nome, s.obbligo_da,
       s.corso, co.nome as corso_nome,
       s.completato_il, s.scadenza, s.scadenza_dichiarata, s.anticipata,
       s.giorni_residui, s.stato,
       s.ruolo_da_confermare, s.esito_livello, s.livello_richiesto,
       case s.stato when 'mancante' then 0 when 'scaduto' then 1 when 'in_scadenza' then 2
                    when 'incompleto' then 3 when 'in_corso' then 4 when 'senza_regola' then 5
                    when 'valido' then 6 else 7 end as priorita
  from v_scadenza_formazione s
  join persona p on p.id = s.persona_id
  join cliente c on c.id = s.cliente_id
  left join sede d on d.id = s.sede_id
  left join ruolo_sicurezza rs on rs.codice = s.ruolo
  left join corso co on co.codice = s.corso
union all
select 'sorveglianza',
       v.persona_id, p.cognome, p.nome, p.codice_fiscale,
       r.cliente_id, c.ragione_sociale, r.sede_id, d.denominazione,
       null, null, 'visita',
       v.accertamento, v.accertamento_nome,
       v.data_esecuzione, v.scadenza, v.scadenza_dichiarata, v.anticipata,
       v.giorni_residui, v.stato,
       false, null, null,
       case v.stato when 'scaduto' then 1 when 'in_scadenza' then 2 else 6 end
  from v_scadenza_visita v
  join persona p on p.id = v.persona_id
  join (select distinct on (persona_id, cliente_id) persona_id, cliente_id, sede_id
          from rapporto_lavoro where not cessato
         order by persona_id, cliente_id, sede_id nulls last) r on r.persona_id = v.persona_id
  join cliente c on c.id = r.cliente_id
  left join sede d on d.id = r.sede_id;

-- ============================================================================
--  TRE — I PROMEMORIA
-- ============================================================================
--
-- «Ruoli da confermare e livello da definire andrebbero messi in un tab a parte come
-- memo, spiegando a cosa si riferiscono» (Francesco). Non sono scadenze: sono cose da
-- sistemare nell'organigramma o nel catalogo perche le scadenze siano giuste. Tre
-- generi, una riga per cosa da fare:
--
--   ruolo_da_confermare   un corso fatto che nessuna nomina segue (decisione 1 del 17/09);
--   livello_emergenza     l'addetto ha un corso, ma la sede non ha un livello
--                         (livello_non_definito) o il corso e sotto quello della sede
--                         (livello_non_conforme) — decisione 11;
--   corso_non_definito    il ruolo c'e, ma il catalogo non dice quale corso serve: era
--                         lo stato «senza regola», che nello scadenzario non si capiva.

create view v_promemoria with (security_invoker = on) as
select s.cliente_id, s.ragione_sociale, s.persona_id, s.cognome, s.nome,
       'ruolo_da_confermare'::text as genere, null::text as esito,
       s.obbligo as ruolo, s.obbligo_nome as ruolo_nome,
       s.corso, s.corso_nome, s.completato_il, s.scadenza, s.livello_richiesto
  from v_scadenzario s
 where s.tipo = 'formazione' and s.ruolo_da_confermare
union all
select s.cliente_id, s.ragione_sociale, s.persona_id, s.cognome, s.nome,
       'livello_emergenza', s.esito_livello,
       s.obbligo, s.obbligo_nome,
       s.corso, s.corso_nome, s.completato_il, s.scadenza, s.livello_richiesto
  from v_scadenzario s
 where s.tipo = 'formazione' and s.esito_livello in ('livello_non_definito', 'non_conforme')
union all
select s.cliente_id, s.ragione_sociale, s.persona_id, s.cognome, s.nome,
       'corso_non_definito', null,
       s.obbligo, s.obbligo_nome,
       null, null, null, null, null
  from v_scadenzario s
 where s.tipo = 'formazione' and s.stato = 'senza_regola';

comment on view v_promemoria is
  'Le cose da sistemare nell''organigramma o nel catalogo perche le scadenze siano giuste (0029): ruoli da confermare, livelli di emergenza, ruoli senza un corso nel catalogo. Non sono scadenze.';

-- ============================================================================
--  QUATTRO — IL CLIENTE IN UNA RIGA, FORMAZIONE E VISITE SEPARATE
-- ============================================================================
--
-- Le visite non hanno «mancanti»: il motore non sa quali visite servono, perche il
-- protocollo sanitario per mansione non c'e (0005). I promemoria stanno nella loro
-- vista (TRE), e qui c'e solo quanti sono.

drop view v_scadenzario_cliente;

create view v_scadenzario_cliente with (security_invoker = on) as
select c.id as cliente_id, c.ragione_sociale, c.partita_iva, c.attivo,
       (select count(distinct r.persona_id) from rapporto_lavoro r
         where r.cliente_id = c.id and not r.cessato) as persone,
       count(*) filter (where s.tipo = 'formazione' and s.stato = 'mancante') as formazione_mancanti,
       count(*) filter (where s.tipo = 'formazione' and s.stato = 'scaduto') as formazione_scadute,
       count(*) filter (where s.tipo = 'formazione' and s.stato = 'in_scadenza') as formazione_in_scadenza,
       count(*) filter (where s.tipo = 'formazione' and s.stato in ('incompleto', 'in_corso')) as formazione_da_completare,
       count(*) filter (where s.tipo = 'sorveglianza' and s.stato = 'scaduto') as visite_scadute,
       count(*) filter (where s.tipo = 'sorveglianza' and s.stato = 'in_scadenza') as visite_in_scadenza,
       (select count(*) from v_promemoria m where m.cliente_id = c.id) as promemoria,
       min(s.scadenza) filter (where s.stato in ('scaduto', 'in_scadenza')) as prima_scadenza
  from cliente c
  left join v_scadenzario s on s.cliente_id = c.id
 group by c.id, c.ragione_sociale, c.partita_iva, c.attivo;

comment on view v_scadenzario_cliente is
  'Un cliente per riga (0029): persone in forza, formazione e visite separate, quanti promemoria. Le visite non hanno mancanti: il protocollo sanitario per mansione non c''e.';

-- ============================================================================
--  CINQUE — I CORSI CHE CHIUDONO UN OBBLIGO
-- ============================================================================
--
-- «Non e forse meglio chiuderlo direttamente dalla scadenza?» (Francesco). Da una
-- scadenza mancante l'app sa il ruolo, non il corso: questi sono i corsi da proporre
-- per primi. `corso_assolve` dice il corso o l'intera categoria.

create view v_corso_per_obbligo with (security_invoker = on) as
select a.ruolo, a.corso_codice, a.parziale
  from corso_assolve a
 where a.corso_codice is not null
union
select a.ruolo, c.codice, false
  from corso_assolve a
  join corso c on c.categoria = a.categoria
 where a.categoria is not null;

comment on view v_corso_per_obbligo is
  'Per ogni ruolo, i corsi che lo assolvono (0029), con le categorie di corso_assolve sciolte nei loro corsi.';

grant select on v_promemoria, v_scadenzario_cliente, v_corso_per_obbligo to authenticated;
