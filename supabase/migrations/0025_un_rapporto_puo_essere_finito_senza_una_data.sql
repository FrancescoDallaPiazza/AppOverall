-- AppOverall — 0025
-- Un rapporto di lavoro puo' essere finito senza che nessuno sappia quando.
--
-- ============================================================================
--  PERCHE ESISTE
-- ============================================================================
--
-- Il 17 settembre 2026 Francesco ha deciso che le **1.036 persone** che hanno
-- attestati o visite nel gestionale e non compaiono nell'anagrafe di AppSopralluoghi
-- **entrano con il loro rapporto** — il cliente per cui lavoravano — e non solo come
-- storia senza datore (strada C fra le tre messe davanti).
--
-- Il gestionale quelle persone le toglie dall'anagrafica quando escono, e la data di
-- uscita **non la scrive**: «Data di Licenziamento» e' valorizzata su 4 righe in tutto
-- (AppFormazione, `docs/05`). Quindi di quei rapporti si sa **che** sono finiti, non
-- **quando**.
--
-- In `rapporto_lavoro` questo non si poteva dire. L'unico segno di fine era
-- `data_cessazione`, e un rapporto con la data vuota **sembra aperto**: mille ex
-- lavoratori sarebbero entrati nello scadenzario come persone da convocare. AppFormazione
-- ha risolto lo stesso problema mettendo il segno sulla persona (`persone.attiva`);
-- qui il segno va sul **rapporto**, perche' la stessa persona puo' essere uscita da un
-- cliente e lavorare per un altro — la `0001` separa le due cose per questo.
--
-- ============================================================================
--  LA COLONNA
-- ============================================================================

alter table rapporto_lavoro
  add column cessato boolean not null default false;

-- I rapporti gia' scritti con una data diventano cessati **prima** del vincolo, che
-- altrimenti li rifiuterebbe.
update rapporto_lavoro set cessato = true where data_cessazione is not null;

alter table rapporto_lavoro
  -- Una data di cessazione vuol dire per forza che il rapporto e' finito. Il
  -- contrario no: cessato con la data vuota e' esattamente il caso di questa
  -- migrazione.
  add constraint cessazione_datata_e_cessata
    check (data_cessazione is null or cessato);

comment on column rapporto_lavoro.cessato is
  'Il rapporto e finito. Vero anche quando la data non si sa: data_cessazione null e cessato true vuol dire «finito, non si sa da quando» — il caso delle persone uscite dall''anagrafica del gestionale, che la data non la scrive (0025). Uno scadenzario legge i rapporti con cessato = false.';
