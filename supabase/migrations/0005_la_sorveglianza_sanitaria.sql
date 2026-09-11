-- AppOverall — 0005
-- La sorveglianza sanitaria: la scadenza, non la cartella.
--
-- Decisa dalla scheda 10 il 10 settembre 2026: **entra come dominio proprio**,
-- accanto alla formazione e non dentro. L'art. 41 del D.Lgs. 81/2008 non e l'art.
-- 37 — due obblighi, due soggetti che li assolvono, e un accertamento non ha ore
-- ne prerequisiti. Nel catalogo dei corsi avrebbe prodotto 808 adempimenti finti.
--
-- ---------- cosa questa migrazione porta, e cosa no ----------
--
--   porta:     la **forma** — il vocabolario degli accertamenti con la loro
--              periodicita, e le esecuzioni per persona
--   NON porta: le **808 righe**. Non per prudenza: perche il conteggio non e
--              sciolto. Sullo stesso dominio AppFormazione ne conta **1.148**, e
--              la scheda 10 dice cosa misurare per capire se sono lo stesso
--              insieme letto in due modi (storico contro aperto) o due perimetri
--              diversi. **Una migrazione dati che nasce su un conteggio aperto
--              nasce storta**, e l'import e il passo successivo, non questo.
--
-- ============================================================================
--  IL VOCABOLARIO — e l'intervallo si memorizza perche e una regola
-- ============================================================================
--
-- I dieci accertamenti sono quelli che il gestionale emette, con il nome **come lo
-- stampa** (riga 0 del foglio «Visite» di `ExportExcel (4).xlsx`) e la periodicita
-- **come la dichiara** (riga 1, fra parentesi: «Prossima Scadenza (1 anno)»).
--
-- **Perche l'intervallo sta qui e non si deriva dai dati.** E un dato di *regola*,
-- non di fatto, e nel file vive in un posto fragile: fra parentesi, dentro una
-- sotto-intestazione. Se il gestionale un giorno cambia quel testo, la regola
-- sparisce senza che nessuno se ne accorga — e tre dei dieci accertamenti **non
-- hanno la periodicita nel titolo**, quindi senza quella riga entrerebbero qui
-- senza regola o con una inventata.
--
-- Misurato sulle date vere prima di scriverlo, non dedotto dai nomi: **796 scadenze
-- su 796** coincidono esattamente con `data + intervallo dichiarato`, zero
-- deviazioni. Le differenze 365/366, 730/731, 1826/1827 non sono deviazioni: sono
-- gli anni bisestili, e infatti l'aritmetica qui e **sul calendario** (`+ interval
-- 'N months'`), non in giorni.

create table accertamento (
  codice text primary key,
  -- Il nome **verbatim** del gestionale: e la chiave con cui l'import riconoscera
  -- la colonna, e cambiarlo per farlo piu bello romperebbe il riconoscimento.
  nome_gestionale text not null unique,
  nome text not null,
  periodicita_mesi int not null
    constraint periodicita_positiva check (periodicita_mesi > 0),
  -- Da dove viene la periodicita. Serve a distinguere i tre accertamenti la cui
  -- regola sta **solo** nella sotto-intestazione da quelli che la dichiarano anche
  -- nel titolo: se un giorno il gestionale cambia quel testo, si sa quali righe
  -- restano senza fonte.
  periodicita_fonte text not null
    constraint fonte_nota check (periodicita_fonte in ('titolo e sottointestazione', 'solo sottointestazione')),
  norma text not null,
  note text
);

comment on table accertamento is
  'Il vocabolario degli accertamenti di sorveglianza sanitaria: quali esistono e ogni quanto si ripetono. Non e un catalogo di corsi — non ha ore, non ha prerequisiti, e il soggetto che lo assolve e il medico competente.';
comment on column accertamento.periodicita_mesi is
  'In mesi, e si somma **sul calendario**: 365 o 366 giorni per un anno secondo il bisestile. Misurato su 796 coppie data/scadenza con zero deviazioni.';

insert into accertamento (codice, nome_gestionale, nome, periodicita_mesi, periodicita_fonte, norma, note) values
  ('visita_annuale',       'Visita Medica annuale',          'Visita medica annuale',        12, 'titolo e sottointestazione', 'D.Lgs. 81/2008 art. 41', null),
  ('visita_biennale',      'Visita Medica Biennale',         'Visita medica biennale',       24, 'titolo e sottointestazione', 'D.Lgs. 81/2008 art. 41', null),
  ('visita_trimestrale',   'Visita Trimestrale',             'Visita medica trimestrale',     3, 'titolo e sottointestazione', 'D.Lgs. 81/2008 art. 41', null),
  ('visita_quadriennale',  'Visita medica quadriennale',     'Visita medica quadriennale',   48, 'titolo e sottointestazione', 'D.Lgs. 81/2008 art. 41', null),
  ('visita_quinquennale',  'Visita medica quinquennale',     'Visita medica quinquennale',   60, 'titolo e sottointestazione', 'D.Lgs. 81/2008 art. 41', null),
  ('oculistica_biennale',  'Visita Oculistica biennale',     'Visita oculistica biennale',   24, 'titolo e sottointestazione', 'D.Lgs. 81/2008 art. 41', null),
  ('oculistica_quinquennale', 'Visita oculistica quinquennale', 'Visita oculistica quinquennale', 60, 'titolo e sottointestazione', 'D.Lgs. 81/2008 art. 41',
   'Nel gestionale la colonna c''e e i dati no: zero righe al 10 settembre 2026. Il vocabolario la tiene perche la colonna esiste ed emettera righe, non perche ne abbia.'),
  ('audiometrico',         'Esame Audiometrico',             'Esame audiometrico',           12, 'solo sottointestazione', 'D.Lgs. 81/2008 art. 41',
   'La periodicita non e nel titolo: sta solo nella sotto-intestazione «(1 anno)». Se il gestionale cambia quel testo, questa riga resta senza fonte.'),
  ('elettrocardiografico', 'Esame Elettrocardiografico',     'Elettrocardiogramma',          24, 'solo sottointestazione', 'D.Lgs. 81/2008 art. 41',
   'Come sopra: «(2 anni)» solo nella sotto-intestazione.'),
  ('spirometrico',         'Esame Spirometrico',             'Esame spirometrico',           12, 'solo sottointestazione', 'D.Lgs. 81/2008 art. 41',
   'Come sopra: «(1 anno)» solo nella sotto-intestazione.');

-- ============================================================================
--  LE ESECUZIONI — e la scadenza NON e una colonna
-- ============================================================================
--
-- **La scadenza si deriva**, e non e una preferenza di stile: e una misura. Nelle
-- 808 righe del gestionale non ce n'e **una** scritta a mano — 796 su 796 uguali a
-- `data + intervallo`, e **zero righe con la scadenza e senza la data**, che
-- esclude anche il caso che sembrava plausibile: una scadenza imposta dal medico su
-- una visita non registrata.
--
-- Le 12 righe con la data e senza la scadenza non sono un controesempio: non
-- portano un'informazione **diversa**, ne portano una **in meno**. Derivandola si
-- ottiene esattamente cio che il gestionale avrebbe scritto, e quelle 12 smettono
-- di essere un buco.
--
-- Memorizzarla sarebbe **la stessa cosa scritta due volte**, cioe il difetto che
-- questo repo esiste per chiudere: due copie divergono, e a divergere per prima
-- sarebbe quella che nessuno ricalcola.

create table sorveglianza (
  id uuid primary key default gen_random_uuid(),
  persona_id uuid not null references persona(id) on delete cascade,
  accertamento text not null references accertamento(codice),
  data_esecuzione date not null,
  note text,
  creato_il timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- La stessa persona puo rifare lo stesso accertamento negli anni: la chiave
  -- ammette la storia. Quale delle due cose contenga il gestionale — l'ultima
  -- esecuzione o tutte — e la domanda aperta della scheda 10, e questo schema non
  -- la decide: **regge entrambe**.
  constraint sorveglianza_una_per_data unique (persona_id, accertamento, data_esecuzione)
);

create trigger sorveglianza_updated_at before update on sorveglianza
  for each row execute function tocca_updated_at();

create index on sorveglianza (persona_id, accertamento, data_esecuzione desc);

comment on table sorveglianza is
  'Che una persona ha fatto un accertamento, e quando. **Non porta l''esito**: il giudizio di idoneita e i dati sanitari restano del medico competente, e non entrano qui — art. 25 c. 1 lett. c) del D.Lgs. 81/2008 e principio di minimizzazione. Questo sistema deve sapere *che* una visita e dovuta e *quando*, non cosa ha detto.';

-- ---------- cosa questa tabella NON porta, e non per dimenticanza ----------
--
-- **1. L'esito, l'idoneita, le prescrizioni.** Sopra: e una rinuncia, non una
-- mancanza, e va riletta prima di aggiungere una colonna «esito» perche sembra
-- comoda.
--
-- **2. A chi appartiene l'accertamento oltre alla persona.** L'obbligo dell'art. 41
-- e del **datore di lavoro**, quindi in astratto una visita appartiene al rapporto
-- di lavoro e non alla persona — e la scheda 1 ha deciso che i fatti stanno sulla
-- **sede**. Qui pero la fonte porta una riga per persona, e attribuirla a un
-- rapporto sarebbe dedurre quale, quando una persona ne ha avuti due. Entra il
-- giorno in cui l'import dice **da quale export** viene la riga: e una colonna in
-- piu, non una riscrittura.
--
-- **3. Il protocollo sanitario.** Le periodicita qui sono un **esito** del
-- protocollo, non il protocollo: chi le decide e il medico, per mansione e per
-- rischio. Tenere solo le scadenze rende il sistema un registro; tenere il
-- protocollo lo renderebbe capace di dire che una visita **manca**, che e la
-- domanda utile. La scheda 10 lo lascia aperto e dice con chi si decide: **con il
-- medico competente, non fra noi.**

-- ============================================================================
--  La vista, dove la scadenza si calcola (PILASTRO 01)
-- ============================================================================

create view v_sorveglianza as
  select s.id,
         s.persona_id,
         s.accertamento,
         a.nome as accertamento_nome,
         s.data_esecuzione,
         (s.data_esecuzione + (a.periodicita_mesi || ' months')::interval)::date as scadenza,
         a.periodicita_mesi,
         s.note,
         s.updated_at
    from sorveglianza s
    join accertamento a on a.codice = s.accertamento;

comment on view v_sorveglianza is
  'Le esecuzioni con la scadenza **calcolata**, non memorizzata: `data_esecuzione + periodicita_mesi` sul calendario. E l''unico posto dove la scadenza esiste, e per questo non puo divergere dalla regola che la produce.';

alter view v_sorveglianza set (security_invoker = on);

-- ============================================================================
--  Le policy
-- ============================================================================
--
-- Il vocabolario e una curatela come il catalogo: lo scrive l'amministrazione. Le
-- esecuzioni le scrive chi le raccoglie, cioe lo stesso livello dell'organigramma
-- nella 0001 — ma vale la pena dirlo: **«non e un dato sanitario» non significa
-- «e un dato qualunque»**. Che una persona faccia un audiometrico dice qualcosa sul
-- suo lavoro e sul suo corpo, e la minimizzazione qui e gia applicata a monte
-- togliendo l'esito. Se un giorno servira restringere anche la lettura, il posto e
-- questo e non l'applicazione.

alter table accertamento  enable row level security;
alter table sorveglianza  enable row level security;

create policy leggono_gli_operatori on accertamento for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on sorveglianza for select to authenticated using (e_operatore());

create policy scrive_amministrazione on accertamento for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
create policy scrive_il_tecnico on sorveglianza for all to authenticated
  using (livello_operatore() >= 2) with check (livello_operatore() >= 2);

grant select on accertamento, sorveglianza to authenticated;
grant select on v_sorveglianza to authenticated;
