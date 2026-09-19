-- ============================================================================
--  0031 — LA PERSONA CHE ARRIVA CON L'ATTESTATO
-- ============================================================================
--
-- Francesco, 19 settembre 2026: se il codice fiscale letto dall'attestato non e di
-- nessuno, la persona si aggiunge da li. Scelta fra due strade, «1»: l'app la crea,
-- e la segna come da riportare nel gestionale.
--
-- Perche il segno: l'anagrafe unica sta dove ci sono le sedi (A4 del PROGRAMMA), cioe
-- nel gestionale da cui AppSopralluoghi importa. Una persona nata qui non c'e, e finche
-- nessuno ce la riporta e lo stesso caso delle 34 del 17 settembre. Il segno la tiene
-- nei promemoria finche qualcuno non dice che e stata riportata.

alter table persona add column da_riportare_nel_gestionale boolean not null default false;

comment on column persona.da_riportare_nel_gestionale is
  'Vero per chi e stato aggiunto dall''app, partendo da un attestato, e non c''e ancora nel gestionale (0031). Si toglie quando qualcuno ce lo riporta.';

-- Persona e rapporto insieme, o niente. Se il codice fiscale c'e gia (la persona e
-- cessata, o lavora per un altro cliente) non si crea un doppione: si aggiunge solo
-- il rapporto con questo cliente, se non ce n'e uno aperto. Invoker: valgono le RLS
-- di chi chiama, quindi serve il livello 2 come per scrivere persona e rapporto.
create function aggiungi_persona_da_attestato(
  p_codice_fiscale text, p_cognome text, p_nome text, p_data_nascita date,
  p_cliente_id uuid, p_mansione text
) returns uuid language plpgsql security invoker as $$
declare
  v_id uuid;
begin
  select id into v_id from persona where codice_fiscale = upper(trim(p_codice_fiscale));
  if v_id is null then
    insert into persona (codice_fiscale, cognome, nome, data_nascita, da_riportare_nel_gestionale)
    values (upper(trim(p_codice_fiscale)), upper(trim(p_cognome)), upper(trim(p_nome)), p_data_nascita, true)
    returning id into v_id;
  end if;
  if not exists (select 1 from rapporto_lavoro
                  where persona_id = v_id and cliente_id = p_cliente_id and not cessato) then
    insert into rapporto_lavoro (persona_id, cliente_id, mansione)
    values (v_id, p_cliente_id, nullif(trim(p_mansione), ''));
    -- Il rapporto nuovo non e nel gestionale nemmeno se la persona c'era.
    update persona set da_riportare_nel_gestionale = true where id = v_id;
  end if;
  return v_id;
end $$;

comment on function aggiungi_persona_da_attestato is
  'Aggiunge la persona letta da un attestato e il suo rapporto con il cliente (0031), segnandola da riportare nel gestionale. Non crea doppioni sul codice fiscale.';

grant execute on function aggiungi_persona_da_attestato to authenticated;

-- Il quarto genere di promemoria: le colonne della 0029, piu il codice fiscale in
-- fondo (serve per riportare la persona nel gestionale), e un ramo in piu.
create or replace view v_promemoria with (security_invoker = on) as
select s.cliente_id, s.ragione_sociale, s.persona_id, s.cognome, s.nome,
       'ruolo_da_confermare'::text as genere, null::text as esito,
       s.obbligo as ruolo, s.obbligo_nome as ruolo_nome,
       s.corso, s.corso_nome, s.completato_il, s.scadenza, s.livello_richiesto,
       s.codice_fiscale
  from v_scadenzario s
 where s.tipo = 'formazione' and s.ruolo_da_confermare
union all
select s.cliente_id, s.ragione_sociale, s.persona_id, s.cognome, s.nome,
       'livello_emergenza', s.esito_livello,
       s.obbligo, s.obbligo_nome,
       s.corso, s.corso_nome, s.completato_il, s.scadenza, s.livello_richiesto,
       s.codice_fiscale
  from v_scadenzario s
 where s.tipo = 'formazione' and s.esito_livello in ('livello_non_definito', 'non_conforme')
union all
select s.cliente_id, s.ragione_sociale, s.persona_id, s.cognome, s.nome,
       'corso_non_definito', null,
       s.obbligo, s.obbligo_nome,
       null, null, null, null, null,
       s.codice_fiscale
  from v_scadenzario s
 where s.tipo = 'formazione' and s.stato = 'senza_regola'
union all
select p.cliente_id, p.ragione_sociale, p.persona_id, p.cognome, p.nome,
       'da_riportare', null,
       null, null,
       null, null, null, null, null,
       p.codice_fiscale
  from v_persona_in_forza p
  join persona x on x.id = p.persona_id
 where x.da_riportare_nel_gestionale;

comment on view v_promemoria is
  'Le cose da sistemare nell''organigramma, nel catalogo o nel gestionale perche le scadenze siano giuste (0029, 0031): ruoli da confermare, livelli di emergenza, ruoli senza un corso nel catalogo, persone aggiunte da un attestato e da riportare nel gestionale. Non sono scadenze.';
