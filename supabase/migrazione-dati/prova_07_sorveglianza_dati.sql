-- AppOverall — dati finti per il passo 07, la sorveglianza sanitaria.
--
-- Codici fiscali finti di `prova_02_persone_dati.sql` (JQIO... e HOZU... sono
-- nell'anagrafe). Un caso per riga di commento:
--
--   1. la storia: tre visite annuali della stessa persona — entrano tutte e tre;
--   2. la stessa visita registrata due volte — entra una, si conta;
--   3. un codice fiscale che l'anagrafe non ha, e una riga senza codice;
--   4. lo scadenzario del 06/08 con la persona RIVISTA il 28/08: la scadenza e'
--      quella della visita del 2025 piu' un anno — uguale al calcolo sulla visita
--      nota a quella data. E' la forma delle «sette» della 0024: non si scrive;
--   5. una scadenza davvero anticipata sulla biennale — si scrive sulla visita giusta;
--   6. una scadenza senza nessuna visita fino al 06/08 — si conta;
--   7. una riga PIANIFICATA — si conta e non si porta;
--   8. due righe dello scadenzario sulla stessa coppia con date diverse — si conta.

insert into origine.visita (riga, codice_fiscale, tipo, data_esecuzione, dichiarazione) values
  -- 1. la storia
  (4,  'JQIOBW08B92B915V', 'Visita Medica annuale',  '2024-08-20', 'Dati aggiornati al 11/09/2026 15:23'),
  (5,  'JQIOBW08B92B915V', 'Visita Medica annuale',  '2025-08-21', 'Dati aggiornati al 11/09/2026 15:23'),
  (6,  'JQIOBW08B92B915V', 'Visita Medica annuale',  '2026-08-28', 'Dati aggiornati al 11/09/2026 15:23'),
  -- 2. la stessa visita due volte
  (7,  'HOZUNW31P60Q756F', 'Visita Medica Biennale', '2025-03-10', 'Dati aggiornati al 11/09/2026 15:23'),
  (8,  'HOZUNW31P60Q756F', 'Visita Medica Biennale', '2025-03-10', 'Dati aggiornati al 11/09/2026 15:23'),
  -- 3. fuori anagrafe, e senza codice
  (9,  'BNCLRA75D45L219R', 'Esame Audiometrico',     '2025-05-05', 'Dati aggiornati al 11/09/2026 15:23'),
  (10, null,               'Esame Audiometrico',     '2025-05-05', 'Dati aggiornati al 11/09/2026 15:23'),
  -- l'accertamento che al 9/9 non aveva righe
  (11, 'HOZUNW31P60Q756F', 'Visita oculistica quinquennale', '2025-01-15', 'Dati aggiornati al 11/09/2026 15:23');

insert into origine.visita_scadenza (riga, codice_fiscale, tipo, data_scadenza, stato, dichiarazione) values
  -- 4. rivisto dopo il 6/8: la scadenza e' quella della visita del 2025
  (4,  'JQIOBW08B92B915V', 'Visita Medica annuale',  '2026-08-21', '', 'Dati aggiornati al 06/08/2026 07:56'),
  -- 5. anticipata: il calcolo darebbe 10/03/2027
  (5,  'HOZUNW31P60Q756F', 'Visita Medica Biennale', '2026-05-10', '', 'Dati aggiornati al 06/08/2026 07:56'),
  -- 6. nessuna visita
  (6,  'HOZUNW31P60Q756F', 'Esame Spirometrico',     '2026-12-01', '', 'Dati aggiornati al 06/08/2026 07:56'),
  -- 7. pianificata
  (7,  'HOZUNW31P60Q756F', 'Visita oculistica quinquennale', '2030-01-15', 'PIANIFICATA', 'Dati aggiornati al 06/08/2026 07:56'),
  -- 8. due date sulla stessa coppia
  (8,  'JQIOBW08B92B915V', 'Esame Elettrocardiografico', '2026-10-01', '', 'Dati aggiornati al 06/08/2026 07:56'),
  (9,  'JQIOBW08B92B915V', 'Esame Elettrocardiografico', '2026-11-01', '', 'Dati aggiornati al 06/08/2026 07:56');
