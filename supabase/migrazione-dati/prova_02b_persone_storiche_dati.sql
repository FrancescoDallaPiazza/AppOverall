-- AppOverall — dati finti per il passo 02b, le persone che l'anagrafe non ha.
--
-- Codici fiscali di fantasia con il carattere di controllo giusto. Si caricano dopo i
-- dati dei passi 01-07, e toccano anche le loro tabelle: e' il punto del passo, che
-- fa entrare persone che gli attestati e le visite finora lasciavano fuori.
--
--   BNCL  nota ad AppFormazione, NON attiva, due rapporti:
--           ECO SRL con la P.IVA che c'e' gia'          -> riconosciuto per P.IVA
--           VECCHIA OFFICINA, P.IVA che non c'e'        -> ex cliente creato, con la data di cessazione
--         la sua storia c'era gia' nei dati finti (attestato, sessione, visita) e finora restava fuori
--   VRDL  nota ad AppFormazione, ATTIVA, con un attestato del 2025: entra cessata, e si conta
--           un ex cliente senza P.IVA                   -> creato per ragione sociale
--           STUDIO ROSA con una P.IVA segnaposto        -> riconosciuto per ragione sociale
--   GLLS  nota ad AppFormazione, senza nessuna storia   -> non entra
--   NREG  solo visite, con nome e azienda «bar  sport.» -> nome dalla visita, cliente per ragione sociale
--   BLUM  solo visite, senza nome                       -> non entra, e si conta

insert into origine.persona_storica
  (persona_id, codice_fiscale, cognome, nome, data_nascita, attiva, rapporto_id, mansione,
   data_assunzione, data_cessazione, cliente_id, ragione_sociale, partita_iva)
values
  ('00000000-0000-0000-0000-00000000b001', 'BNCLRA75D45L219R', 'BIANCO', 'LAURA', '1975-04-05', false,
   '00000000-0000-0000-0000-00000000b101', 'Saldatrice', '2020-01-01', null,
   '00000000-0000-0000-0000-00000000bc01', 'ECO SRL', '01234567897'),
  ('00000000-0000-0000-0000-00000000b001', 'BNCLRA75D45L219R', 'BIANCO', 'LAURA', '1975-04-05', false,
   '00000000-0000-0000-0000-00000000b102', 'Saldatrice', '2021-01-01', '2023-06-30',
   '00000000-0000-0000-0000-00000000bc02', 'VECCHIA OFFICINA SNC', '09876543210'),
  ('00000000-0000-0000-0000-00000000b002', 'VRDLCU80A01L781W', 'VERDI', 'LUCA', '1980-01-01', true,
   '00000000-0000-0000-0000-00000000b103', 'Magazziniere', null, null,
   '00000000-0000-0000-0000-00000000bc03', 'Ex Cliente Senza Partita.', null),
  ('00000000-0000-0000-0000-00000000b002', 'VRDLCU80A01L781W', 'VERDI', 'LUCA', '1980-01-01', true,
   '00000000-0000-0000-0000-00000000b104', null, null, null,
   '00000000-0000-0000-0000-00000000bc04', 'STUDIO ROSA', '11111111111'),
  ('00000000-0000-0000-0000-00000000b003', 'GLLSRA90C50D969J', 'GIALLI', 'SARA', null, false,
   null, null, null, null, null, null, null);

-- la storia di VRDL: un attestato del 2025
insert into origine.formazione
  (id, codice_fiscale, corso_titolo, corso_codice_origine, data_completamento, ore,
   ente_erogatore, esito, fonte)
values
  ('00000000-0000-0000-0000-0000000000fc', 'VRDLCU80A01L781W',
   'Aggiornamento Lavoratori 6 ore', 'GEST-ffffffff', '2025-10-10', 6, 'Ente Alfa', null, 'interna');

-- chi ha solo visite
insert into origine.visita
  (riga, codice_fiscale, tipo, data_esecuzione, dichiarazione, cognome, nome, data_nascita, societa, partita_iva)
values
  (12, 'NREGNN85M41F205Y', 'Visita Medica annuale', '2023-03-03', 'Dati aggiornati al 11/09/2026 15:23',
   'NERI', 'GIANNA', '1985-08-01', 'bar  sport.', ''),
  (13, 'BLUMRC70E10H501T', 'Visita Medica annuale', '2023-03-03', 'Dati aggiornati al 11/09/2026 15:23',
   null, null, null, 'bar  sport.', '');
