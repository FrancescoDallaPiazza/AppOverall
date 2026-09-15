-- Dati FINTI per provare il passo 03. Nessuna persona vera: i codici fiscali sono
-- quelli finti di prova_02_persone_dati.sql, i nomi e le note sono di fantasia.
--
-- **Carica solo l'origine.** La destinazione — clienti, sedi, `cliente_origine`,
-- persone e rapporti — la scrivono i passi 01 e 02 veri, in prova_03_nomine.sh: la
-- nomina si aggancia a cio che quei due passi producono, fusione per P.IVA compresa,
-- e una destinazione scritta a mano proverebbe un aggancio che la migrazione non fa.
--
--   unita  P.IVA         diventa
--   UA     01234567897   cliente UA, sede SA
--   UB     01234567897   assorbita in UA perche creata dopo: sede SB dello stesso cliente
--   UC     nessuna       cliente UC, sede SC
--
--   persona  unita  chi
--   P1       UA     ROSSI MARIO, CF valido
--   P2       UB     ROSSI MARIO, lo stesso CF: col passo 02, una persona e due rapporti
--   P3       UC     NERI GIULIA
--   P4       UC     BIANCHI LUCA, senza CF
--   P5       UA     ROSA SARA
--
--   nomina  persona  figura               origine    testo                  cosa prova
--   N1      P1       dl_rspp              colonna    -                      2: diventa datore_lavoro_rspp; data e nota attraversano
--   N2      P2       dl_rspp              colonna    -                      4: stessa persona e figura sull'unita fusa, sede SB
--   N3      P3       addetto_antincendio  mansione   ADD. ANTINCENDIO       5: posizione non_dichiarato, letta dal dizionario
--   N4      P3       rspp                 mansione   RSPP ESTERNO           5: posizione esterno, il conto della 0010
--   N5      P4       dl_rspp              qualifica  RSPP-SOCIO             h: il dizionario non lo ricava, la nota dice perche
--   N6      P5       datore_lavoro_art16  null       -                      gli estremi della procura; l'origine non registrata
--   N7      P5       lavoratore           null       -                      come la crea l'import della formazione: data di assunzione
--   N8      P4       preposto             qualifica  LAVORATORE E PREPOSTO  il testo in maiuscolo contro «Lavoratore e preposto»
--   N9      P2       rls                  qualifica  RLS - LAVORATORE       il lavoratore non si asserisce
--
-- Attese: 9 nomine su 4 persone, 5 senza data, 3 con una nota, 2 senza origine,
-- 1 fuori dal dizionario con la nota, 1 persona con lo stesso ruolo su due sedi.

insert into origine.cliente
  (id, werp_id, ragione_sociale, partita_iva, codice_fiscale, attivo, numero_lavoratori,
   codice_ateco, livello_rischio, livello_antincendio, gruppo_primo_soccorso, created_at)
values
  ('00000000-0000-0000-0000-00000000000a', null, 'ECO SRL', '01234567897', null, true, null,
   null, null, null, null, '2020-01-01 10:00+00'),
  ('00000000-0000-0000-0000-00000000000b', null, 'ECO SRL MAGAZZINO', '01234567897', null, true, null,
   null, null, null, null, '2021-01-01 10:00+00'),
  ('00000000-0000-0000-0000-00000000000c', null, 'BAR SPORT', null, null, true, null,
   null, null, null, null, '2020-01-01 10:00+00');

insert into origine.sede (id, cliente_id, nome, indirizzo, localita, provincia, principale, attivo, created_at) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000000a', 'Sede legale', null, 'Legnago', 'VR', true, true, '2020-01-01 10:00+00'),
  ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-00000000000b', 'Sede legale', null, 'Cerea',   'VR', true, true, '2021-01-01 10:00+00'),
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000000c', 'Sede legale', null, 'Nogara',  'VR', true, true, '2020-01-01 10:00+00');

insert into origine.persona
  (id, cliente_id, sede_id, nome, cognome, codice_fiscale, mansione, data_assunzione, attivo, data_cessazione, import_key, updated_at)
values
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-0000000000a1',
   'MARIO', 'ROSSI', 'JQIOBW08B92B915V', 'TITOLARE', null, true, null,
   'anag:00000000-0000-0000-0000-00000000000a:JQIOBW08B92B915V', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-0000000000b1',
   'MARIO', 'ROSSI', 'JQIOBW08B92B915V', 'TITOLARE', null, true, null,
   'anag:00000000-0000-0000-0000-00000000000b:JQIOBW08B92B915V', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-0000000000c1',
   'GIULIA', 'NERI', 'ZSGCRSQ3HV1S5Q8P', 'ADD. ANTINCENDIO', null, true, null,
   'anag:00000000-0000-0000-0000-00000000000c:ZSGCRSQ3HV1S5Q8P', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-0000000000c1',
   'LUCA', 'BIANCHI', null, 'BARISTA', null, true, null,
   'anag:00000000-0000-0000-0000-00000000000c:n:BIANCHI|LUCA', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-0000000000a1',
   'SARA', 'ROSA', 'HOZUNW31P60Q756F', 'IMPIEGATA', '2019-05-02', true, null,
   'anag:00000000-0000-0000-0000-00000000000a:HOZUNW31P60Q756F', '2026-09-09 10:00+00');

insert into origine.nomina
  (id, persona_id, figura_codice, data_nomina, attiva, note, estremi_procura, da_confermare,
   origine, origine_testo, created_at, updated_at)
values
  ('00000000-0000-0000-0000-0000000000e1', '00000000-0000-0000-0000-000000000001', 'dl_rspp', '2020-09-10', true,
   'Colonna RSPP letta come datore di lavoro RSPP (art. 34): nota finta della prova.', null, false,
   'colonna', null, '2026-09-15 10:00+00', '2026-09-15 10:00+00'),
  ('00000000-0000-0000-0000-0000000000e2', '00000000-0000-0000-0000-000000000002', 'dl_rspp', '2020-09-10', true,
   'Colonna RSPP letta come datore di lavoro RSPP (art. 34): nota finta della prova.', null, false,
   'colonna', null, '2026-09-15 10:00+00', '2026-09-15 10:00+00'),
  ('00000000-0000-0000-0000-0000000000e3', '00000000-0000-0000-0000-000000000003', 'addetto_antincendio', null, true,
   null, null, false,
   'mansione', 'ADD. ANTINCENDIO', '2026-09-14 10:00+00', '2026-09-14 10:00+00'),
  ('00000000-0000-0000-0000-0000000000e4', '00000000-0000-0000-0000-000000000003', 'rspp', null, true,
   null, null, false,
   'mansione', 'RSPP ESTERNO', '2026-09-14 10:00+00', '2026-09-14 10:00+00'),
  ('00000000-0000-0000-0000-0000000000e5', '00000000-0000-0000-0000-000000000004', 'dl_rspp', null, true,
   'Datore di lavoro che fa da RSPP in proprio (art. 34): decisione finta della prova.', null, false,
   'qualifica', 'RSPP-SOCIO', '2026-09-15 10:00+00', '2026-09-15 10:00+00'),
  ('00000000-0000-0000-0000-0000000000e6', '00000000-0000-0000-0000-000000000005', 'datore_lavoro_art16', '2024-01-02', true,
   null, 'Rep. 1234 del 2 gennaio 2024, notaio FINTO', false,
   null, null, '2026-08-01 10:00+00', '2026-08-01 10:00+00'),
  ('00000000-0000-0000-0000-0000000000e7', '00000000-0000-0000-0000-000000000005', 'lavoratore', '2019-05-02', true,
   null, null, false,
   null, null, '2026-08-01 10:00+00', '2026-08-01 10:00+00'),
  ('00000000-0000-0000-0000-0000000000e8', '00000000-0000-0000-0000-000000000004', 'preposto', null, true,
   null, null, false,
   'qualifica', 'LAVORATORE E PREPOSTO', '2026-09-14 10:00+00', '2026-09-14 10:00+00'),
  ('00000000-0000-0000-0000-0000000000e9', '00000000-0000-0000-0000-000000000002', 'rls', null, true,
   null, null, false,
   'qualifica', 'RLS - LAVORATORE', '2026-09-14 10:00+00', '2026-09-14 10:00+00');
