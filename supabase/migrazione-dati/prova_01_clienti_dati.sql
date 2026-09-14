-- Dati FINTI per provare il passo 01. Nessuna azienda vera: ragioni sociali di
-- fantasia, P.IVA scelte per la loro forma.
--
--   cliente  P.IVA d'origine   regola che prova
--   K1       01234567897       1: due unita con la stessa P.IVA...
--   K2       01234567897       ...un cliente, K1 superstite perche creato prima; nome diverso
--   K3       00000000000       3: segnaposto, assente; chiave dal codice fiscale
--   K4       00000000000       3: lo stesso segnaposto non collide; chiave dalla ragione sociale normalizzata
--   K5       XXXX              3: assente
--   K6       98765432109       4: non attivo, con una seconda sede non principale
--   K7       11111111111       3: segnaposto che la guardia d'origine lascia passare
--   K8       12345678903       un cliente senza sedi
--
-- Attese: 7 clienti (3 P.IVA usabili distinte + 4 senza), 7 sedi, 1 unita assorbita,
-- 55 dipendenti (30 + 12 + 5 + 8).

insert into origine.cliente
  (id, werp_id, ragione_sociale, partita_iva, codice_fiscale, attivo, numero_lavoratori,
   codice_ateco, livello_rischio, livello_antincendio, gruppo_primo_soccorso, created_at)
values
  ('00000000-0000-0000-0000-0000000000c1', 'W1', 'ECO SRL', '01234567897', null, true, 30, '25', 'alto', null, null, '2026-07-01'),
  ('00000000-0000-0000-0000-0000000000c2', null, 'ECO S.R.L.', '01234567897', null, true, 12, null, null, null, null, '2026-07-31'),
  ('00000000-0000-0000-0000-0000000000c3', null, 'BAR ROMA', '00000000000', '01234567890', true, null, null, null, null, null, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000000c4', null, 'bar  sport.', '00000000000', null, true, 5, null, null, null, null, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000000c5', null, 'OFFICINA NERI', 'XXXX', null, true, null, '45', null, null, null, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000000c6', null, 'LAVANDERIA BLU', '98765432109', null, false, 8, null, null, null, null, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000000c7', null, 'STUDIO ROSA', '11111111111', null, true, null, null, null, null, null, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000000c8', null, 'MAGAZZINI GIALLI', '12345678903', null, true, null, null, null, null, null, '2026-08-01');

insert into origine.sede (id, cliente_id, nome, indirizzo, localita, provincia, principale, attivo, created_at) values
  ('00000000-0000-0000-0000-0000000005c1', '00000000-0000-0000-0000-0000000000c1', 'Sede legale', 'Via Uno 1', 'Verona', 'VR', true, true, '2026-07-01'),
  ('00000000-0000-0000-0000-0000000005c2', '00000000-0000-0000-0000-0000000000c2', 'Sede legale', 'Via Due 2', 'Trevenzuolo', 'VR', true, true, '2026-07-31'),
  ('00000000-0000-0000-0000-0000000005c3', '00000000-0000-0000-0000-0000000000c3', 'Sede legale', null, null, null, true, true, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000005c4', '00000000-0000-0000-0000-0000000000c4', 'Sede legale', '', 'Legnago', 'VR', true, true, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000005c5', '00000000-0000-0000-0000-0000000000c5', 'Sede legale', null, null, null, true, true, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000005c6', '00000000-0000-0000-0000-0000000000c6', 'Sede legale', null, null, null, true, true, '2026-08-01'),
  ('00000000-0000-0000-0000-0000000006c6', '00000000-0000-0000-0000-0000000000c6', 'Magazzino', null, null, null, false, true, '2026-08-02');
