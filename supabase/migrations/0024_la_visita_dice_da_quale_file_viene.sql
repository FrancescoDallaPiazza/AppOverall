-- AppOverall — 0024
-- Una visita dice da quale estrazione viene, e le nove scadenze anticipate erano due.
--
-- ============================================================================
--  UNO — LA CORREZIONE, CHE VIENE PRIMA
-- ============================================================================
--
-- La `0005` (commento di `scadenza_dichiarata`) e la scheda 10 dicono: **«la prima
-- fonte davvero esterna dissente in 9 casi su 769, tutti anticipati»**, e ne fanno
-- la ragione per cui la scadenza si puo' dichiarare — il richiamo anticipato del
-- medico competente. **Sette dei nove non lo sono.** Misurato il 17 settembre 2026
-- con la storia delle visite (`ExportExcelVisiteFatte`, 11/09/2026, 1.383 righe):
--
--   * lo scadenzario (`ExportExcelVisiteScadenze`) dichiara «Dati aggiornati al
--     06/08/2026». Il foglio con cui era stato confrontato e' del 09/09;
--   * per sette di quelle persone **l'ultima visita e' di fine agosto** — dopo il 6 —
--     e la scadenza dello scadenzario e' **esattamente** quella della visita
--     **precedente** piu' la periodicita', al giorno;
--   * confrontando ogni scadenza con l'ultima esecuzione **nota al 6 agosto**: 792
--     uguali, **2 anticipate** (di 286 e 336 giorni), 0 posticipate, su 794.
--
-- Il caso citato come esempio — «esecuzione 31.08.2026, calcolata 31.08.2027,
-- dichiarata 21.11.2026» — e' uno dei sette: 21.11.2026 e' la visita del 21.11.2025
-- piu' un anno. La verifica «fino a otto cicli indietro» contava a ritroso dalla
-- visita nuova, a passi di periodicita'; non guardava la visita vera di prima.
--
-- **Cosa resta vero:** la forma. Una scadenza solo derivata cancellerebbe in silenzio
-- anche uno solo di quei due casi, e i due ci sono. **Cosa cade:** il numero, e la
-- lettura «nove richiami anticipati». E la lezione e' quella della `0008` applicata a
-- se stessa: **due fotografie di date diverse non si confrontano come se fossero
-- una** — la colonna `origine_estrazione.data_dichiarata` esisteva gia' per dirlo.
--
-- ============================================================================
--  DUE — LA PROVENIENZA SULLA RIGA
-- ============================================================================
--
-- Il passo 07 porta le visite da un file del gestionale, non da un database: la
-- storia dell'11 settembre. Come per gli attestati (`0021`) e gli alias (`0008`), la
-- riga dice da quale estrazione viene. E per la scadenza dichiarata serve di piu':
-- una scadenza dichiarata al 6 agosto su una persona rivista il 28 agosto riguarda
-- **la visita di prima**, e senza la data dell'estrazione non lo si puo' dire.

alter table sorveglianza
  add column estrazione text references origine_estrazione(codice);

comment on column sorveglianza.estrazione is
  'Da quale estrazione viene la riga (0008). La scadenza dichiarata, se c''e, viene da un''altra estrazione, e il suo testo in scadenza_fonte porta la data dichiarata di quella: le due date servono insieme, perche una scadenza dichiarata prima di una visita nuova riguarda la visita di prima (0024).';
comment on column sorveglianza.scadenza_dichiarata is
  'La scadenza che una fonte dichiara quando dissente dal calcolo. null = nessuno la dichiara, e vale la calcolata. Sui dati del 06/08/2026 le dissenzienti vere sono 2 su 794, entrambe anticipate: le «nove su 769» della 0005 erano sette visite nuove confrontate con uno scadenzario piu vecchio (0024).';
