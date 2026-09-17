-- AppOverall — 0023
-- La cella ATECO da cui la divisione e' stata derivata viaggia con la divisione.
--
-- ============================================================================
--  PERCHE ESISTE
-- ============================================================================
--
-- Il passo 06 porta sulle sedi la divisione ATECO che AppSopralluoghi tiene sul
-- cliente. Quella divisione **non e' un dato inserito**: e' derivata da una cella di
-- testo libero del gestionale prendendo il primo gruppo di 1-2 cifre, ed e' giusta
-- 261 volte su 262 (loro `065`). La 262esima si riconosce **solo** confrontandola con
-- la cella — `SHAMS SERVICE SRLS`, dove vince il CAP di Nogara e l'impresa edile
-- diventa «gestione reti fognarie».
--
-- AppSopralluoghi ha chiamato questo terzo stato `incerto` e ha scritto la colonna
-- che lo rende esistente, `cliente.ateco_origine`. Se la migrazione porta la divisione
-- e lascia la cella, **il difetto non si ripara: si sposta**, con le loro parole. La
-- stessa forma di `corso_alias.testo_origine` (`0008`) e di `titolo_origine` (`0021`).
--
-- ============================================================================
--  LA COLONNA
-- ============================================================================

alter table sede
  -- La cella verbatim. Null = nessuna cella conservata: all'origine lo e' per le
  -- righe anteriori alla loro `065`, e allora la divisione e' «nota ma non
  -- verificabile» — niente la smentisce e niente la conferma.
  add column ateco_origine text;

comment on column sede.ateco_origine is
  'La cella ATECO del gestionale, VERBATIM, da cui codice_ateco e stato derivato (AppSopralluoghi, cliente.ateco_origine, loro 065). Non si normalizza e non si corregge: serve proprio perche e diversa dal derivato, ed e l''unico modo di riconoscere una divisione derivata male. Null = cella non conservata.';

-- ============================================================================
--  COSA QUESTA MIGRAZIONE NON FA
-- ============================================================================
--
-- **Non aggiunge il livello alla sede.** La decisione 8 lo dice e la `0001` lo
-- scrive: la classe che l'Allegato IV da' alla divisione **si ricalcola**, e si
-- annota in `valutazione_sede` solo quando si applica una classe diversa. Il passo 06
-- segue la stessa regola.
