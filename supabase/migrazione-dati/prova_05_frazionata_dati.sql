-- AppOverall — dati finti per il passo 05, le sessioni dei percorsi frazionati.
--
-- Si caricano dopo `prova_04_formazione_dati.sql` e usano gli stessi **codici
-- fiscali** finti. Un caso per riga di commento, cosi' un conteggio che non torna
-- dice quale:
--
--   1. un percorso completato di due sessioni, **la seconda sullo stesso giorno di un
--      attestato dello stesso corso**: la prima entra, la seconda e' la chiusura e non
--      si riscrive — l'attestato prende i due segni. L'attestato e' qui sotto, in
--      `origine.formazione`, perche' e' il passo 04 a portarlo;
--   2. due sessioni in corso sullo stesso corso della 1, **una sul giorno della
--      chiusura**: entrano tutte e due, e la coincidenza si conta;
--   3. una sessione in corso con le ore previste **diverse dalla durata**: entra, e
--      si conta;
--   4. un percorso completato **senza nessun attestato**: entra, e si conta;
--   5. un codice fiscale che l'anagrafe non ha: non entra, e si conta;
--   6. una sessione senza codice fiscale: non entra, e si conta a parte;
--   7. un titolo ignorato a mano: non entra, e si conta.
--
-- I due file hanno due caricamenti di staging diversi e due piedi diversi di un
-- minuto, come i veri.

-- la chiusura del caso 1, come la registra il gestionale: un attestato normale
insert into origine.formazione
  (id, codice_fiscale, corso_titolo, corso_codice_origine, data_completamento, ore,
   ente_erogatore, esito, fonte)
values
  ('00000000-0000-0000-0000-0000000000fb', 'JQIOBW08B92B915V',
   'Aggiornamento Lavoratori 6 ore', 'GEST-ffffffff', '2025-03-10', 6, 'Ente Alfa', null, 'interna');

insert into origine.formazione_frazionata
  (id, esecuzione_id, file, codice_fiscale, corso_titolo, data_sessione, dettagli_ore, durata, dichiarazione)
values
  -- 1. il percorso completato, e la sua chiusura
  (101, '00000000-0000-0000-0000-0000000000d1', 'fraz_completata', 'JQIOBW08B92B915V',
   'Aggiornamento Lavoratori 6 ore', '2025-01-10', '2/6', '6', 'Dati aggiornati al 06/08/2026 07:47'),
  (102, '00000000-0000-0000-0000-0000000000d1', 'fraz_completata', 'JQIOBW08B92B915V',
   'Aggiornamento Lavoratori 6 ore', '2025-03-10', '4/6', '6', 'Dati aggiornati al 06/08/2026 07:47'),

  -- 2. il percorso successivo, aperto il giorno della chiusura
  (201, '00000000-0000-0000-0000-0000000000d2', 'fraz_in_corso', 'JQIOBW08B92B915V',
   'Aggiornamento Lavoratori 6 ore', '2025-03-10', '1/6', '6', 'Dati aggiornati al 06/08/2026 07:46'),
  (202, '00000000-0000-0000-0000-0000000000d2', 'fraz_in_corso', 'JQIOBW08B92B915V',
   'AGGIORNAMENTO  LAVORATORI 6 ORE', '2026-02-01', '2/6', '6', 'Dati aggiornati al 06/08/2026 07:46'),

  -- 3. le ore previste non sono la durata
  (203, '00000000-0000-0000-0000-0000000000d2', 'fraz_in_corso', 'HOZUNW31P60Q756F',
   'AGGIORNAMENTO LAVORATORI PREPOSTI', '2026-03-01', '1/6', '8', 'Dati aggiornati al 06/08/2026 07:46'),

  -- 4. completato, e nessuno lo chiude
  (103, '00000000-0000-0000-0000-0000000000d1', 'fraz_completata', 'HOZUNW31P60Q756F',
   'AGGIORNAMENTO R.L.S. 4 ORE', '2024-05-05', '2/4', '4', 'Dati aggiornati al 06/08/2026 07:47'),
  (104, '00000000-0000-0000-0000-0000000000d1', 'fraz_completata', 'HOZUNW31P60Q756F',
   'AGGIORNAMENTO R.L.S. 4 ORE', '2024-06-06', '2/4', '4', 'Dati aggiornati al 06/08/2026 07:47'),

  -- 5. un codice fiscale che l'anagrafe non ha
  (204, '00000000-0000-0000-0000-0000000000d2', 'fraz_in_corso', 'BNCLRA75D45L219R',
   'AGGIORNAMENTO LAVORATORI PREPOSTI', '2026-04-01', '2/6', '6', 'Dati aggiornati al 06/08/2026 07:46'),

  -- 6. senza codice fiscale
  (205, '00000000-0000-0000-0000-0000000000d2', 'fraz_in_corso', null,
   'AGGIORNAMENTO LAVORATORI PREPOSTI', '2026-04-01', '2/6', '6', 'Dati aggiornati al 06/08/2026 07:46'),

  -- 7. un titolo ignorato a mano
  (105, '00000000-0000-0000-0000-0000000000d1', 'fraz_completata', 'JQIOBW08B92B915V',
   'ADDETTO LAVORI IN AMBIENTI SOSPETTI DI PRESENZA AMIANTO', '2023-01-01', '2/4', '4', 'Dati aggiornati al 06/08/2026 07:47');
