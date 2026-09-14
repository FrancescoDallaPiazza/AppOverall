-- AppOverall — 0017
-- Il cliente d'origine e un'unita: cosa diventa cliente, cosa diventa sede.
--
-- ============================================================================
--  LA GRANA, UN'ALTRA VOLTA
-- ============================================================================
--
-- In AppSopralluoghi **una riga = un cliente, anche a parita di P.IVA**: due
-- stabilimenti della stessa societa sono due clienti (deciso il 31 luglio sul caso
-- Ecodent), e `cliente.partita_iva` **non ha vincolo di unicita apposta**
-- (`anagraficheImport.ts:30-33`). Il loro cliente e quindi un'**unita**.
--
-- Qui il cliente e la P.IVA e le unita sono sedi (decisione 2, e la `0001`:
-- «qui il cliente e **uno**, ed e la P.IVA»). Quindi, attraversando:
--
--   * cio che identifica l'**azienda** — P.IVA, codice fiscale, ragione sociale —
--     va su `cliente`;
--   * cio che descrive l'**unita** — indirizzo, e il numero di persone gestite —
--     va su `sede`;
--   * due clienti d'origine con la **stessa P.IVA usabile** diventano **un**
--     cliente con due sedi. Le sole fusioni che si fanno: senza P.IVA usabile non
--     si fonde niente, nemmeno a ragione sociale identica.
--
-- ============================================================================
--  LA P.IVA USABILE, E UN DIFETTO DELLA FUNZIONE DI ORIGINE
-- ============================================================================
--
-- La regola e decisa (Francesco, 14 settembre 2026): **una P.IVA inutilizzabile
-- vale come assente, e la cella originale si conserva accanto** — la stessa
-- forma della `0008` per il codice fiscale. E la `0001` dice gia quali sono:
-- «Un segnaposto come 00000000000 aggancia righe che non c'entrano».
--
-- **La funzione di origine non fa quello che il suo commento dice.** In
-- `anagraficheImport.ts:71`:
--
--   !!s && /^\d{11}$/.test(s) && !/^(\d){10}$/.test(s)
--
-- Il commento sopra dice «non e un segnaposto (tutte cifre uguali)», ma
-- `(\d){10}` ripete il **gruppo**, non la **cifra**: vuol dire «dieci cifre
-- qualsiasi», e su una stringa gia verificata a undici cifre non corrisponde mai.
-- La guardia e muta. **Eseguita, non letta**, il 14 settembre: `00000000000` e
-- `11111111111` risultano usabili. E siccome di la la P.IVA non e unica, i
-- segnaposto possono essere scritti su piu clienti — quanti, lo dice solo il
-- database.
--
-- Quindi **questa funzione NON e un port fedele**, a differenza della `0016`: fa
-- cio che il commento d'origine intende e cio che la `0001` scrive. La
-- differenza con la funzione di produzione e **esattamente** sulle dieci stringhe
-- di undici cifre tutte uguali, ed e provata nel commit che la introduce.

create function partita_iva_usabile(cella text) returns boolean
language sql immutable parallel safe
as $$
  select coalesce(
    regexp_replace(cella, '\s', '', 'g') ~ '^[0-9]{11}$'
    and regexp_replace(cella, '\s', '', 'g') !~ '^([0-9])\1{10}$',
    false)
$$;

comment on function partita_iva_usabile(text) is
  'Undici cifre, non tutte uguali, spazi esclusi. **Non e il port di `pivaUsabile` di AppSopralluoghi**: quella ha una guardia sul segnaposto che non scatta mai (`(\d){10}` al posto di `(\d)\1{10}`) e accetta 00000000000. Questa fa cio che quel commento e la `0001` dicono. Nessun controllo della cifra di controllo, come all''origine.';

-- ---------- la cella conservata ----------

alter table cliente add column partita_iva_origine text;

comment on column cliente.partita_iva_origine is
  'La P.IVA come stava nel cliente d''origine, anche quando non e usabile: `XXXX`, `00000000000`, dieci cifre. Stessa forma di `persona.codice_fiscale_origine` (`0008`): **null in `partita_iva` non vuol dire «non c''era»**, e questa colonna distingue «niente» da «qualcosa che non era una P.IVA». Per un cliente nato dalla fusione di piu unita, e la cella dell''unita superstite.';

-- ---------- il legame con WERP, che non si ricostruisce dopo ----------
--
-- `cliente.werp_id` esiste all'origine ed e unico. La decisione 3 dice che WERP
-- resta e che lo scambio e un import periodico con riconciliazione: perdere il
-- legame in migrazione vorrebbe dire riconciliare da capo per ragione sociale,
-- che e la chiave piu fragile.

alter table cliente add column werp_id text unique;

comment on column cliente.werp_id is
  'L''identificativo del cliente in WERP, portato dall''origine. Unico: se due unita fuse ne avessero due diversi, la migrazione si ferma invece di sceglierne uno.';

-- ---------- il numero di persone, con la sua etichetta ----------
--
-- «Un dato che trasloca porta con se la sua etichetta» (sezione 8). `N DIPENDENTI`
-- dell'export **non e la forza lavoro dell'impresa**: coincide col conteggio delle
-- persone in anagrafica in 601 casi su 619, quindi dice **quante ne gestiamo**.
-- Ed e un numero **per unita**, perche all'origine ogni riga di ElencoSedi e un
-- cliente-unita: per questo sta sulla sede, e non sul cliente. Il totale aziendale
-- — quello che la soglia dei 50 dell'RLS chiede — e la somma sulle sedi **solo
-- sotto questa etichetta**, e sulla soglia e proprio dove le due domande divergono.

alter table sede add column n_dipendenti_gestionale integer
  constraint sede_n_dipendenti_positivo check (n_dipendenti_gestionale > 0);

comment on column sede.n_dipendenti_gestionale is
  '`N DIPENDENTI` del gestionale per questa unita. **Non e quanti lavoratori ha l''impresa: e quante persone ne gestiamo** — coincide col conteggio in anagrafica in 601 unita su 619. Per un artigiano le due cose coincidono; per una societa di cui seguiamo un reparto no, ed e sulla soglia dei 50 dell''RLS che la differenza morde. Zero non e un numero di lavoratori: all''origine vale gia come assente.';

-- ---------- la corrispondenza, che la 0013 non voleva e la fusione rende necessaria ----------
--
-- La `0013` ha deciso che i clienti attraversano **con lo stesso uuid**, e che per
-- questo una tabella di corrispondenza non serviva: `rapporto_lavoro.import_key`
-- porta dentro l'uuid del cliente, e quell'uuid qui esiste davvero.
--
-- **Regge per ogni cliente d'origine tranne quelli assorbiti da una fusione per
-- P.IVA**: il loro uuid non diventa un `cliente.id`, perche il cliente e uno solo e
-- ha l'uuid del superstite. Senza questa tabella il conto che la `0013` chiamava
-- «l'unico che puo fallire in silenzio» — l'uuid dentro la chiave aggancia il
-- cliente — fallirebbe proprio li, e le persone di quelle unita non avrebbero un
-- cliente a cui puntare.
--
-- La tabella porta **tutti** i clienti d'origine, non solo gli assorbiti, perche un
-- join che vale per tutti non ha un ramo dimenticato. Per la gran parte delle righe
-- `origine_id = cliente_id`, ed e la decisione 1 della `0013` che si vede.

create table cliente_origine (
  origine_id uuid primary key,
  cliente_id uuid not null references cliente(id) on delete restrict,
  sede_id uuid references sede(id) on delete restrict,
  assorbito boolean not null,
  creato_il timestamptz not null default now()
);

comment on table cliente_origine is
  'Un cliente-unita di AppSopralluoghi, e dove e finito qui: il cliente (lo stesso uuid, salvo fusione per P.IVA) e la sede che era la sua sede legale. E il passaggio per cui le chiavi `anag:<uuid d''origine>:...` di `rapporto_lavoro` agganciano ancora un cliente dopo una fusione.';
comment on column cliente_origine.assorbito is
  'Vero quando il cliente d''origine e confluito in un cliente con un altro uuid, perche aveva la stessa P.IVA usabile. E il caso in cui `origine_id <> cliente_id`, e l''unico in cui la decisione 1 della `0013` non vale alla lettera.';

-- ---------- le chiavi, con la forma che mancava ----------
--
-- La `0013` scriveva due forme per il cliente, `sedi:piva:` e `sedi:den:`. Ma
-- l'import d'origine riconosce un cliente con **P.IVA, poi codice fiscale, poi
-- ragione sociale** (`anagraficheImport.ts:381-386`): la forma del codice fiscale
-- mancava, e una chiave che non dice il criterio con cui e costruita e quella che
-- la `0013` stessa voleva evitare. E la sede prende una seconda forma, perche dopo
-- una fusione non tutte le sedi sono il riflesso della sede legale.

comment on column cliente.import_key is
  'Da dove viene questo cliente, come fatto sulla riga. Tre forme, nell''ordine con cui l''origine riconosce un cliente: `sedi:piva:<11 cifre>` quando la P.IVA e usabile, altrimenti `sedi:cf:<codice fiscale>`, altrimenti `sedi:den:<RAGIONE SOCIALE NORMALIZZATA>`. Il criterio sta dentro perche i tre non sono equivalenti, e l''ultimo e il piu fragile. Null vuol dire **creato qui**. (La `0013` ne scriveva due: la forma del codice fiscale e aggiunta dalla `0017`.)';

comment on column sede.import_key is
  'La chiave del cliente piu `:legale` per la sede legale del cliente superstite, oppure `:sede:<uuid della sede d''origine>` per ogni altra sede — quella di un''unita assorbita da una fusione, o una sede non principale gia all''origine. (La `0013` prevedeva `:legale` e `:produttivo`: il sito produttivo non e ancora stato importato, e quando entrera avra la sua forma.)';

alter table cliente_origine enable row level security;
create policy leggono_gli_operatori on cliente_origine for select to authenticated using (e_operatore());
create policy scrive_amministrazione on cliente_origine for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
grant select on cliente_origine to authenticated;
