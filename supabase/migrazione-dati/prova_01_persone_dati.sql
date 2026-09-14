-- Dati FINTI per provare il passo 01. Nessuna persona vera: i codici fiscali sono
-- stringhe casuali a cui la funzione di produzione di AppSopralluoghi ha dato
-- l'esito scritto accanto, e i nomi sono di fantasia.
--
-- Dieci righe, scelte perche ognuna esercita una regola del passo 01:
--
--   riga  cliente  codice fiscale              regola che prova
--   01    A        valido                      2: stesso CF su due clienti...
--   02    B        valido, lo stesso della 01  ...una persona, due rapporti; e 4: nome diverso, vince la 02
--   03    A        valido con omocodia         la 0016 non lo scarta
--   04    B        valido, minuscolo e spazi   la cella resta in codice_fiscale_origine
--   05    A        forma giusta, controllo no  3: nessun CF, cella conservata
--   06    B        una P.IVA                   3: idem
--   07    A        assente (null)              3: BIANCHI LUCA...
--   08    B        assente (stringa vuota)     ...e BIANCHI LUCA su un altro cliente: due persone
--   09    C        assente, cessato con data   la data attraversa
--   10    C        valido, senza sede          sede_id null
--
-- Attese: 10 rapporti, 9 persone (4 codici validi distinti + 5 senza codice valido).

insert into cliente (id, ragione_sociale) values
  ('00000000-0000-0000-0000-00000000000a', 'CLIENTE FINTO A'),
  ('00000000-0000-0000-0000-00000000000b', 'CLIENTE FINTO B'),
  ('00000000-0000-0000-0000-00000000000c', 'CLIENTE FINTO C');

insert into sede (id, cliente_id, denominazione, principale) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000000a', 'Sede legale', true),
  ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-00000000000b', 'Sede legale', true),
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000000c', 'Sede legale', true);

insert into origine.persona
  (id, cliente_id, sede_id, nome, cognome, codice_fiscale, mansione, data_assunzione, attivo, data_cessazione, import_key, updated_at)
values
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-0000000000a1',
   'MARIO', 'ROSSI', 'JQIOBW08B92B915V', 'Magazziniere', '2020-03-01', true, null,
   'anag:00000000-0000-0000-0000-00000000000a:JQIOBW08B92B915V', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-0000000000b1',
   'MARIA', 'ROSSI', 'JQIOBW08B92B915V', 'Impiegata', '2024-01-15', true, null,
   'anag:00000000-0000-0000-0000-00000000000b:JQIOBW08B92B915V', '2026-09-10 10:00+00'),
  ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-0000000000a1',
   'GIULIA', 'NERI', 'ZSGCRSQ3HV1S5Q8P', null, null, true, null,
   'anag:00000000-0000-0000-0000-00000000000a:ZSGCRSQ3HV1S5Q8P', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-0000000000b1',
   'PAOLO', 'GIALLI', 'ojpkdd 62t79u607y', null, null, true, null,
   'anag:00000000-0000-0000-0000-00000000000b:OJPKDD62T79U607Y', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-0000000000a1',
   'LUCIA', 'BLU', 'KWRUYJ45T73F788G', null, null, true, null,
   'anag:00000000-0000-0000-0000-00000000000a:KWRUYJ45T73F788G', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-0000000000b1',
   'ANDREA', 'VIOLA', '01234567890', null, null, true, null,
   'anag:00000000-0000-0000-0000-00000000000b:01234567890', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-0000000000a1',
   'LUCA', 'BIANCHI', null, null, null, true, null,
   'anag:00000000-0000-0000-0000-00000000000a:n:BIANCHI|LUCA', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-0000000000b1',
   'LUCA', 'BIANCHI', '', null, null, true, null,
   'anag:00000000-0000-0000-0000-00000000000b:n:BIANCHI|LUCA', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-0000000000c1',
   'ANNA', 'VERDI', null, 'Operaia', '2019-05-02', false, '2025-12-31',
   'anag:00000000-0000-0000-0000-00000000000c:n:VERDI|ANNA', '2026-09-09 10:00+00'),
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-00000000000c', null,
   'SARA', 'ROSA', 'HOZUNW31P60Q756F', null, null, true, null,
   'anag:00000000-0000-0000-0000-00000000000c:HOZUNW31P60Q756F', '2026-09-09 10:00+00');
