-- AppOverall — dati finti per il passo 08, il riscontro con lo scadenzario di Sicurweb.
--
-- Righe di uno scadenzario finto sulle persone finte dei passi precedenti, piu' due
-- attestati perche' il motore abbia qualcosa da confrontare. Una riga per categoria:
--
--   4   uguale: VRDL ha LAV_SPEC del 10/10/2025, scadenza 10/10/2030
--   5   un secondo titolo sullo stesso corso con una data piu' vicina: per Sicurweb vale
--       la piu' lontana, e la coppia resta «uguale»
--   6   periodicita: HOZU ha LAV_SPEC del 02/02/2024, e Sicurweb conta 24 mesi
--   7   ruolo non assegnato: VRDL non e' preposto
--   14  ruolo non assegnato, l'altra forma: JQIO e' datore-RSPP presso il suo cliente, quindi
--       non e' «lavoratore» per il motore, e Sicurweb gli tiene l'aggiornamento lavoratori
--   8   corso senza obbligo nel catalogo: l'antincendio (decisione 11, ancora aperta)
--   9   persona non attiva: BNCL ha solo rapporti cessati
--   10  persona fuori anagrafe: BLUM non ha una scheda
--   11  senza codice fiscale
--   12  un titolo che il dizionario non conosce
--   13  un titolo ignorato a mano
--   e ZSGC ha un LAV_SPEC che Sicurweb non tiene: «solo motore»
--
-- La regola transitoria del preposto non ha un caso: nessuna persona finta e' preposto
-- con un attestato. Si aggiunge quando il motore v2 la porta.

-- i due attestati
insert into origine.formazione
  (id, codice_fiscale, corso_titolo, corso_codice_origine, data_completamento, ore,
   ente_erogatore, esito, fonte)
values
  ('00000000-0000-0000-0000-0000000000fd', 'HOZUNW31P60Q756F',
   'Aggiornamento Lavoratori 6 ore', 'GEST-ffffffff', '2024-02-02', 6, 'Ente Alfa', null, 'interna'),
  ('00000000-0000-0000-0000-0000000000fe', 'ZSGCRSQ3HV1S5Q8P',
   'Aggiornamento Lavoratori 6 ore', 'GEST-ffffffff', '2023-06-06', 6, 'Ente Alfa', null, 'interna');

insert into origine.corso_scadenza (riga, codice_fiscale, tipo, data_scadenza, stato, dichiarazione) values
  (4,  'VRDLCU80A01L781W', 'Aggiornamento Lavoratori 6 ore', '2030-10-10', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (5,  'VRDLCU80A01L781W', 'AGGIORNAMENTO LAVORATORI 6 ORE', '2029-01-01', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (6,  'HOZUNW31P60Q756F', 'Aggiornamento Lavoratori 6 ore', '2026-02-02', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (7,  'VRDLCU80A01L781W', 'AGGIORNAMENTO LAVORATORI PREPOSTI', '2027-10-10', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (8,  'JQIOBW08B92B915V', 'CORSO DI AGGIORNAMENTO ANTINCENDIO PER ADDETTI ANTINCENDIO IN ATTIVITÀ DI LIVELLO 2', '2028-01-01', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (9,  'BNCLRA75D45L219R', 'Aggiornamento Lavoratori 6 ore', '2029-01-01', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (10, 'BLUMRC70E10H501T', 'Aggiornamento Lavoratori 6 ore', '2029-01-01', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (11, null,               'Aggiornamento Lavoratori 6 ore', '2029-01-01', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (12, 'JQIOBW08B92B915V', 'CORSO INVENTATO DI SANA PIANTA', '2029-01-01', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (13, 'JQIOBW08B92B915V', 'ADDETTO LAVORI IN AMBIENTI SOSPETTI DI PRESENZA AMIANTO', '2029-01-01', '', 'Dati aggiornati al 06/08/2026 07:55'),
  (14, 'JQIOBW08B92B915V', 'Aggiornamento Lavoratori 6 ore', '2030-03-10', '', 'Dati aggiornati al 06/08/2026 07:55');
