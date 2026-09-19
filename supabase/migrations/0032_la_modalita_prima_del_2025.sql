-- ============================================================================
--  0032 — LA MODALITA SUGLI ATTESTATI DI PRIMA DEL 24 MAGGIO 2025
-- ============================================================================
--
-- Visto provando, il 19 settembre 2026: l'attestato di Baccini e del 2016 e il
-- controllo lo diceva non conforme perche non riporta la modalita di erogazione. Ma
-- l'elemento d) della Parte I punto 6 e dell'ASR 2025, e l'accordo del 21/12/2011 non
-- chiedeva di scriverlo. Francesco: prima del 24/05/2025 la modalita mancante diventa
-- «da guardare», non «non conforme».
--
-- Due posti, perche il controllo e il trigger della 0029 devono dire la stessa cosa:
-- un attestato che il controllo dice «da guardare» si deve poter registrare. Gli altri
-- cinque elementi minimi restano come sono.

create or replace function controlla_attestato(
  p_persona_id   uuid,
  p_cliente_id   uuid,
  p_corso        text,
  p_data         date,
  p_aggiornamento boolean,
  p_ore          numeric,
  p_modalita     text,
  p_ente         text,
  p_tipo_ente    text,
  p_luogo        text,
  p_firmato      boolean
) returns table (regola text, titolo text, esito text, messaggio text, riferimento text)
language plpgsql stable as $$
declare
  c            corso%rowtype;
  cf           text;
  classe_rischio       text;
  classi       int;
  m            corso_modalita%rowtype;
  ore_minime   numeric;
  fonte_ore    text;
  ore_nota     text;
  grandezza    text;
  regime       corso_regime_precedente%rowtype;
  ore_regime   numeric;
  manca        text[] := '{}';
  tipo         soggetto_formatore_tipo%rowtype;
  quanti       int;
  -- 0032: prima del 24/05/2025 vale l'accordo del 2011, che la modalita non la chiedeva.
  vecchio      boolean := coalesce(p_data < date '2025-05-24', false);
begin
  select * into c from corso where codice = p_corso;
  if not found then
    return query select 'corso', 'Corso', 'non_conforme',
      'Il corso ' || coalesce(p_corso, '(vuoto)') || ' non e nel catalogo.', 'catalogo 0004';
    return;
  end if;
  select codice_fiscale into cf from persona where id = p_persona_id;

  -- La classe_rischio di rischio del cliente, se le sedi dove la persona lavora concordano.
  select count(distinct vs.classe), min(vs.classe) into classi, classe_rischio
    from rapporto_lavoro r
    join v_classe_sede vs on vs.sede_id = r.sede_id
   where r.persona_id = p_persona_id and r.cliente_id = p_cliente_id
     and not r.cessato and vs.classe is not null;
  if coalesce(classi, 0) <> 1 then classe_rischio := null; end if;

  -- ---------- 1. gli elementi minimi (Parte I, punto 6) ----------
  if coalesce(btrim(p_ente), '') = '' then manca := manca || 'denominazione del soggetto formatore (a)'::text; end if;
  if cf is null then manca := manca || 'codice fiscale del partecipante (b)'::text; end if;
  if p_ore is null or p_ore <= 0 then manca := manca || 'durata (c)'::text; end if;
  if p_modalita is null and not vecchio then manca := manca || 'modalita di erogazione (d)'::text; end if;
  if p_firmato is distinct from true then manca := manca || 'firma del soggetto formatore (e)'::text; end if;
  if p_data is null or coalesce(btrim(p_luogo), '') = '' then manca := manca || 'data e luogo (f)'::text; end if;
  return query select 'elementi_minimi', 'Elementi minimi dell''attestato',
    case when cardinality(manca) > 0 then 'non_conforme'
         when p_modalita is null then 'da_verificare'
         else 'conforme' end,
    case when cardinality(manca) > 0
         then 'Mancano: ' || array_to_string(manca, '; ') || '.'
           || case when p_modalita is null and vecchio then ' La modalita di erogazione manca, ma l''accordo del 2011 non chiedeva di scriverla.' else '' end
         when p_modalita is null
         then 'Manca la modalita di erogazione (d), che per un attestato anteriore al 24/05/2025 l''accordo del 2011 non chiedeva di scrivere: da guardare sull''attestato.'
         else 'Ci sono tutti e sei gli elementi minimi.' end,
    'ASR 17/04/2025, Parte I, punto 6, pag. 9';

  -- ---------- 2. la data ----------
  return query select 'data', 'Data dell''attestato',
    case when p_data is null then 'non_conforme'
         when p_data > current_date then 'non_conforme'
         when p_data < date '2025-05-24' then 'da_verificare'
         else 'conforme' end,
    case when p_data is null then 'La data manca.'
         when p_data > current_date then 'La data e nel futuro: si registra un corso fatto.'
         when p_data < date '2025-05-24' then
           'Attestato anteriore al 24/05/2025: vale l''accordo del 21/12/2011, e le regole di questo controllo sono quelle dell''ASR 2025. Le durate sono confrontate anche con il regime precedente, il resto va guardato a mano.'
         else 'Attestato emesso sotto l''ASR 2025.' end,
    'ASR 17/04/2025, Parte VII, punti 1 e 2, pag. 112';

  -- ---------- 3. la modalita di erogazione (Parte IV, punto 3.5) ----------
  select * into m from corso_modalita
   where corso_codice = c.codice and aggiornamento = coalesce(p_aggiornamento, false)
     and modalita = p_modalita;
  if p_modalita is null then
    return query select 'modalita', 'Modalita di erogazione',
      case when vecchio then 'da_verificare' else 'non_conforme' end,
      case when vecchio
           then 'La modalita non e indicata: per un attestato anteriore al 24/05/2025 l''accordo del 2011 non chiedeva di scriverla.'
           else 'La modalita non e indicata.' end,
      'ASR 17/04/2025, Parte IV, punto 3.5';
  elsif not exists (select 1 from corso_modalita where corso_codice = c.codice) then
    return query select 'modalita', 'Modalita di erogazione', 'non_applicabile',
      'L''ASR 2025 non disciplina questo corso: la modalita ammessa la dice la sua fonte (antincendio: D.M. 2/9/2021; primo soccorso: D.M. 388/2003; RLS: art. 37 c. 10-11 e CCNL; ponteggi: Allegato XXI; lavori elettrici: CEI 11-27).',
      'ASR 17/04/2025, Parte IV, punto 3.5';
  elsif not found then
    return query select 'modalita', 'Modalita di erogazione', 'da_verificare',
      'Per questo corso la tabella 3.5 non ha una riga su questa modalita.', 'ASR 17/04/2025, Parte IV, punto 3.5';
  elsif m.esito = 'non_consentita' then
    return query select 'modalita', 'Modalita di erogazione', 'non_conforme',
      'Questa modalita non e consentita per ' || c.nome ||
      case when p_aggiornamento then ' (aggiornamento).' else ' (formazione).' end, m.fonte;
  elsif m.esito = 'condizionata' then
    -- La formazione specifica dei lavoratori in e-learning: dipende dalla classe_rischio.
    if c.codice = 'LAV_SPEC' and p_modalita = 'e_learning' and classe_rischio is not null then
      return query select 'modalita', 'Modalita di erogazione',
        case when classe_rischio = 'basso' then 'da_verificare' else 'non_conforme' end,
        case when classe_rischio = 'basso'
             then 'Classe di rischio basso: l''e-learning e consentito, ma non per chi svolge mansioni a rischio medio o alto (nota 2 della tabella).'
             else 'Classe di rischio ' || classe_rischio || ': l''e-learning e consentito solo con progetti formativi individuati dalle Regioni (nota 1 della tabella).' end,
        m.fonte;
    else
      return query select 'modalita', 'Modalita di erogazione', 'da_verificare', m.condizione, m.fonte;
    end if;
  else
    return query select 'modalita', 'Modalita di erogazione', 'conforme',
      'Modalita ammessa per questo corso.', m.fonte;
  end if;

  -- ---------- 4. la durata ----------
  grandezza := case when p_aggiornamento then c.ore_aggiornamento_grandezza else c.ore_grandezza end;
  ore_minime := case when p_aggiornamento then c.ore_aggiornamento else c.ore end;
  fonte_ore := 'catalogo 0004, fonte del corso';

  if c.codice = 'LAV_SPEC' and not coalesce(p_aggiornamento, false) then
    if classe_rischio is null then
      return query select 'durata', 'Durata', 'da_verificare',
        'La durata dipende dalla classe_rischio di rischio del settore (4, 8 o 12 ore) e la classe_rischio di questo cliente non e definita o le sedi non concordano.',
        'ASR 17/04/2025, Parte II, punto 2.1, pag. 12';
      ore_minime := null;
    else
      select o.ore, o.fonte into ore_minime, fonte_ore from corso_ore_per_rischio o
       where o.corso_codice = c.codice and o.classe = classe_rischio;
      grandezza := 'durata_corso';
      ore_nota := ' (classe di rischio ' || classe_rischio || ')';
    end if;
  end if;

  if ore_minime is not null and grandezza = 'durata_corso' then
    -- Regime precedente: per gli attestati vecchi il minimo era un altro.
    select * into regime from corso_regime_precedente
     where corso_codice = c.codice
       and colonna = case when p_aggiornamento then 'ore_aggiornamento' else 'ore' end;
    if found and p_data is not null and p_data <= regime.valida_fino_a then
      select min(ore) into ore_regime from corso_regime_precedente_ore
       where corso_codice = regime.corso_codice and colonna = regime.colonna;
      if ore_regime is not null and ore_regime < ore_minime then
        ore_minime := ore_regime;
        fonte_ore := regime.fonte;
        ore_nota := ' (regime precedente, valido per gli attestati fino al ' || to_char(regime.valida_fino_a, 'DD/MM/YYYY') || ')';
      end if;
    end if;
    return query select 'durata', 'Durata',
      case when p_ore is null then 'non_conforme'
           when p_ore >= ore_minime then 'conforme' else 'non_conforme' end,
      case when p_ore is null then 'La durata manca.'
           when p_ore >= ore_minime then 'L''attestato riporta ' || p_ore || ' ore, il minimo e ' || ore_minime || coalesce(ore_nota, '') || '.'
           else 'L''attestato riporta ' || p_ore || ' ore, sotto il minimo di ' || ore_minime || coalesce(ore_nota, '') || '.' end,
      fonte_ore;
  elsif ore_minime is not null and grandezza = 'parte_pratica' then
    return query select 'durata', 'Durata', 'da_verificare',
      'Il minimo di ' || ore_minime || ' ore riguarda la sola parte pratica, che l''attestato non separa: va letto sull''attestato.',
      'ASR 17/04/2025, Parte III, punti 5 e 6, pag. 82';
  elsif ore_minime is not null and grandezza = 'monte_ore_quinquennio' then
    return query select 'durata', 'Durata', 'non_applicabile',
      'Il minimo di ' || ore_minime || ' ore e un monte ore del quinquennio: un singolo attestato puo esserne una parte.',
      'ASR 17/04/2025, Parte III, punto 3, pag. 82';
  elsif ore_minime is null and c.codice <> 'LAV_SPEC' then
    return query select 'durata', 'Durata', 'da_verificare',
      'Il catalogo non fissa una durata per questo corso: va confrontata con la fonte del corso.', 'catalogo 0004';
  end if;

  -- ---------- 5. il percorso a cui l'attestato si appoggia ----------
  if c.prerequisito_codice is not null then
    select count(*) into quanti from evento_formativo e
     where e.persona_id = p_persona_id and e.corso_codice = c.prerequisito_codice;
    return query select 'prerequisito', 'Formazione richiesta prima',
      case when quanti > 0 then 'conforme' else 'da_verificare' end,
      case when quanti > 0 then 'La persona ha il corso richiesto prima: ' || (select nome from corso where codice = c.prerequisito_codice) || '.'
           else 'Qui non risulta ' || (select nome from corso where codice = c.prerequisito_codice) ||
                ', che questo corso presuppone: se e stato fatto altrove va registrato.' end,
      'catalogo 0004, prerequisito del corso';
  end if;

  if coalesce(p_aggiornamento, false) then
    select count(*) into quanti from evento_formativo e
     where e.persona_id = p_persona_id and e.corso_codice = c.codice and not e.is_aggiornamento;
    return query select 'aggiornamento', 'Aggiornamento',
      case when quanti > 0 then 'conforme' else 'da_verificare' end,
      case when quanti > 0 then 'Il corso base risulta registrato: l''aggiornamento decorre dalla data di fine corso di questo attestato.'
           else 'Qui non risulta il corso base di ' || c.nome || '. L''aggiornamento presuppone il corso: se e stato fatto altrove va registrato.' end,
      'ASR 17/04/2025, Parte III, pag. 80';
  end if;

  -- ---------- 6. chi ha emesso l'attestato ----------
  if p_tipo_ente is null then
    return query select 'soggetto_formatore', 'Soggetto formatore', 'da_verificare',
      'Il tipo di soggetto formatore non e indicato: l''ASR ammette solo i soggetti del punto 1.',
      'ASR 17/04/2025, Parte I, punto 1, pag. 6';
  else
    select * into tipo from soggetto_formatore_tipo where codice = p_tipo_ente;
    return query select 'soggetto_formatore', 'Soggetto formatore',
      case when tipo.da_guardare is null then 'conforme' else 'da_verificare' end,
      coalesce(tipo.da_guardare, tipo.nome || ': ammesso dall''accordo.'), tipo.fonte;
  end if;

  -- ---------- 7. il corso e ancora quello del catalogo ----------
  if not c.attivo then
    return query select 'corso_attivo', 'Corso nel catalogo', 'da_verificare',
      'Il corso non e piu attivo nel catalogo: lo si registra come storia, non come formazione di oggi.', 'catalogo 0004';
  end if;
end
$$;

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
  -- 0032: la modalita la chiede l'ASR 2025, non l'accordo del 2011.
  if new.modalita_erogazione is null and new.data >= date '2025-05-24' then
    manca := manca || 'modalita di erogazione'::text;
  end if;
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
