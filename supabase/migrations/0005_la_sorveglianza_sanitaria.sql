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
--   NON porta: le **righe**. L'import e il passo successivo e legge **due file**,
--              non uno: `ExportExcel (4).xlsx` foglio «Visite» come primario —
--              porta l'esecuzione, che e il fatto, e copre il perimetro piu largo
--              (63 societa contro 62, 31 coppie in piu) — e
--              `ExportExcelVisiteScadenze.xlsx` come fonte delle scadenze
--              **dichiarate**, che dal foglio non si possono derivare. I nomi dei
--              nove tipi coincidono carattere per carattere fra i due, quindi
--              nessuna tabella di corrispondenza da scrivere.
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
-- L'aritmetica e **sul calendario** (`+ interval 'N months'`) e non in giorni, cosi
-- le differenze 365/366, 730/731, 1826/1827 tornano senza casi speciali.
--
-- **Un comportamento che va dichiarato perche non e una nostra regola.** Su una
-- esecuzione del **29 febbraio** di un anno bisestile, `+ interval '60 months'` in
-- PostgreSQL **tronca all'ultimo giorno valido** — 2024-02-29 diventa 2029-02-28,
-- non il 1 marzo. Provato l'11 settembre 2026 su PostgreSQL 16. E una decisione
-- dell'operatore, non una riga scritta qui: se un giorno la regola dovesse essere
-- «rotola al 1 marzo», questa vista **non lo fa** e nessuno se ne accorgerebbe,
-- perche il caso si presenta solo su un accertamento eseguito il 29 febbraio.
--
-- ---------- i tre vocabolari esterni coincidono, verificato ----------
--
-- `nome_gestionale` porta il testo **verbatim** del gestionale, maiuscole
-- incoerenti comprese — «Visita Medica Biennale» con la B grande e «Visita medica
-- quinquennale» con la m piccola, nello stesso export. Non si normalizza, perche e
-- la chiave con cui l'import riconosce la colonna.
--
-- I testi arrivano da tre posti, e l'11 settembre 2026 sono stati confrontati tutti
-- e tre: le **intestazioni del foglio «Visite»**, i **nove tipi dello scadenzario**
-- (identici al foglio carattere per carattere, misura del campo) e le **dieci
-- descrizioni di `staging.catalogo_gestionale`** di AppFormazione. Le dieci righe
-- qui sotto coincidono con le loro dieci **carattere per carattere**, zero
-- differenze in entrambi i versi.
--
-- **Quindi non serve una tabella di alias per gli accertamenti**, e va scritto
-- perche e stato proposto e sarebbe stato costruire per una previsione: `corso_alias`
-- esiste perche i 268 testi dei corsi **divergono** dai codici, qui i testi
-- coincidono. Servira il giorno in cui un quarto vocabolario dira la stessa cosa in
-- un altro modo — e quel giorno ci sara un caso vero sotto.

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
--  LE ESECUZIONI — e la scadenza si calcola, salvo quando qualcuno la dichiara
-- ============================================================================
--
-- **La scadenza si deriva per default, e si puo dichiarare.** La prima versione di
-- questa migrazione la derivava e basta, e sarebbe stata un difetto grave: va
-- raccontato per intero perche il ragionamento sbagliato era mio e sembrava solido.
--
-- La misura diceva: «796 scadenze su 796 uguali a `data + intervallo`, zero
-- deviazioni», e la chiamavamo terza fonte indipendente. **Non lo era.** La colonna
-- «Prossima Scadenza» del foglio **e calcolata dal gestionale** da esecuzione piu
-- intervallo: verificarla contro esecuzione piu intervallo verifica **una formula
-- contro se stessa**, e un risultato che non poteva non tornare non e una verifica.
-- Era la stessa fonte guardata due volte.
--
-- **La prima fonte davvero esterna dissente in 9 casi su 769.** E
-- `ExportExcelVisiteScadenze.xlsx`, l'export dedicato, e le nove differenze non
-- sono rumore: **sono tutte e nove piu VICINE** della scadenza calcolata, zero piu
-- lontane, e nessuna e un ciclo precedente (verificato fino a otto cicli indietro).
-- Una differenza casuale andrebbe nei due sensi; questa ha una direzione sola,
-- quindi ha una causa. E la causa ha un nome: il **richiamo anticipato** deciso dal
-- medico competente su una persona da rivedere prima della periodicita ordinaria.
--
-- Esempio misurato: esecuzione 31.08.2026, calcolata 31.08.2027, **dichiarata
-- 21.11.2026**.
--
-- E il caso **clinicamente piu importante** che esista in sorveglianza sanitaria, ed
-- e esattamente quello che una scadenza solo calcolata cancella — **in silenzio**,
-- perche la riga resta e sembra giusta. Nove persone da rivedere prima sarebbero
-- diventate nove persone in regola, e nessun conteggio lo avrebbe segnalato.
--
-- Quindi: la scadenza resta **derivata** dove nessuno dice altro — e le 12 righe
-- senza scadenza restano un'informazione **in meno**, non diversa — ma dove una
-- fonte la **dichiara** il valore dichiarato vince, e la vista mostra entrambi
-- perche l'anticipo si veda invece di essere assorbito.

create table sorveglianza (
  id uuid primary key default gen_random_uuid(),
  persona_id uuid not null references persona(id) on delete cascade,
  accertamento text not null references accertamento(codice),
  data_esecuzione date not null,
  -- **null vuol dire «nessuno l'ha dichiarata», non «non c'e scadenza»**: la
  -- scadenza in quel caso e quella calcolata, e si legge in `v_sorveglianza`.
  -- Valorizzata solo dove una fonte esterna dissente dal calcolo — 9 righe su 769
  -- nella misura dell'11 settembre 2026, tutte e nove **anticipate**.
  scadenza_dichiarata date,
  -- Da dove viene la dichiarazione, perche una scadenza che nessuno sa da dove
  -- venga non e opponibile e non si puo riverificare.
  scadenza_fonte text,
  note text,
  constraint scadenza_dichiarata_ha_una_fonte
    check ((scadenza_dichiarata is null) = (scadenza_fonte is null)),
  -- Una scadenza prima dell'esecuzione non e un anticipo: e un dato rotto.
  constraint scadenza_dopo_esecuzione
    check (scadenza_dichiarata is null or scadenza_dichiarata > data_esecuzione),
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
         -- la scadenza che vale
         coalesce(s.scadenza_dichiarata,
                  (s.data_esecuzione + (a.periodicita_mesi || ' months')::interval)::date)
           as scadenza,
         -- e le due componenti, perche un anticipo non si deve poter nascondere
         (s.data_esecuzione + (a.periodicita_mesi || ' months')::interval)::date
           as scadenza_calcolata,
         s.scadenza_dichiarata,
         s.scadenza_fonte,
         (s.scadenza_dichiarata is not null
          and s.scadenza_dichiarata < (s.data_esecuzione + (a.periodicita_mesi || ' months')::interval)::date)
           as anticipata,
         a.periodicita_mesi,
         s.note,
         s.updated_at
    from sorveglianza s
    join accertamento a on a.codice = s.accertamento;

comment on view v_sorveglianza is
  'La scadenza che vale, piu le due componenti da cui viene: quella **calcolata** sul calendario e quella eventualmente **dichiarata** da una fonte. `anticipata` e vero quando la dichiarata e piu vicina della calcolata — cioe il richiamo anticipato del medico competente, il caso che una scadenza solo derivata cancellerebbe in silenzio.';

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
