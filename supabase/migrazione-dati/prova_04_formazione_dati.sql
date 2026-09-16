-- AppOverall — dati finti per il passo 04, gli attestati.
--
-- Si caricano su `origine.formazione` dopo `prova_02_persone_dati.sql`, di cui
-- usano le persone. Coprono i casi che il passo deve saper distinguere, e uno per
-- volta, cosi' un conteggio che non torna dice **quale**:
--
--   1. l'attestato normale, col codice gia' curato all'origine;
--   2. l'attestato senza codice, che si risolve dal dizionario dei 268 alias;
--   3. un titolo che il dizionario dichiara **ignorato**: non entra, e si conta;
--   4. due attestati sulla **stessa persona, corso e data**: entrano tutti e due e
--      la collisione si segnala (decisione del 16.09.2026);
--   5. due spezzoni di un percorso frazionato: entrano **aperti**;
--   6. una scadenza dichiarata, che deve arrivare fino in fondo con la sua fonte;
--   7. un attestato `da_confermare`, che non ha dove stare e si conta.
--
-- I titoli sono testi veri del dizionario: il passo li risolve per alias, e se il
-- seed cambiasse quei testi la prova se ne accorgerebbe invece di passare lo stesso.

insert into origine.formazione
  (id, persona_id, corso_codice, corso_nome, data_completamento, ore, ente_formatore,
   is_aggiornamento, parziale, evidenza_incompleta, da_confermare, scadenza, note, import_key)
values
  -- 1. codice gia' curato all'origine
  ('00000000-0000-0000-0000-0000000000f1', '00000000-0000-0000-0000-000000000001',
   'PONTEGGI', 'ADDETTO AL MONTAGGIO, SMONTAGGIO, TRASFORMAZIONE DI PONTEGGI O PER PREPOSTI ALLA SORVEGLIANZA',
   '2019-05-10', 28, 'Ente Alfa', false, false, false, false, null, null, 'gest:f1'),

  -- 2. senza codice: lo risolve il dizionario
  ('00000000-0000-0000-0000-0000000000f2', '00000000-0000-0000-0000-000000000001',
   null, 'ADDETTO A LAVORI IN SPAZI CONFINATI E SOSPETTI DI INQUINAMENTO',
   '2021-03-01', 12, 'Ente Beta', false, false, false, false, null, null, 'gest:f2'),

  -- 3. un titolo ignorato a mano: non entra
  ('00000000-0000-0000-0000-0000000000f3', '00000000-0000-0000-0000-000000000001',
   null, 'ADDETTO LAVORI IN AMBIENTI SOSPETTI DI PRESENZA AMIANTO',
   '2022-06-15', 5, 'Ente Gamma', false, false, false, false, null, null, 'gest:f3'),

  -- 4. la collisione: stessa persona, stesso corso, stessa data della f1
  ('00000000-0000-0000-0000-0000000000f4', '00000000-0000-0000-0000-000000000001',
   'PONTEGGI', 'ADDETTO AL MONTAGGIO, SMONTAGGIO, TRASFORMAZIONE DI PONTEGGI O PER PREPOSTI ALLA SORVEGLIANZA',
   '2019-05-10', 28, 'Ente Alfa', false, false, false, false, null, 'doppione vero, non un errore di import', 'gest:f4'),

  -- 5. due spezzoni: entrano aperti
  ('00000000-0000-0000-0000-0000000000f5', '00000000-0000-0000-0000-000000000002',
   'LAV_SPEC', 'FORMAZIONE SPECIFICA RISCHIO ALTO PARZIALE 6H 1\2',
   '2026-01-10', 6, 'Ente Delta', false, true, false, false, null, null, 'gest:f5'),
  ('00000000-0000-0000-0000-0000000000f6', '00000000-0000-0000-0000-000000000002',
   'LAV_SPEC', 'FORMAZIONE SPECIFICA RISCHIO ALTO, PARZIALE 6H 2/2',
   '2026-02-20', 6, 'Ente Delta', false, true, false, false, null, null, 'gest:f6'),

  -- 6. una scadenza dichiarata, anticipata rispetto al calcolo
  ('00000000-0000-0000-0000-0000000000f7', '00000000-0000-0000-0000-000000000002',
   'PONTEGGI', 'ADDETTO AL MONTAGGIO, SMONTAGGIO, TRASFORMAZIONE DI PONTEGGI O PER PREPOSTI ALLA SORVEGLIANZA',
   '2024-09-01', 28, 'Ente Alfa', false, false, false, false, '2026-09-01', null, 'gest:f7'),

  -- 7. da confermare: il compito non ha dove stare, e si conta
  ('00000000-0000-0000-0000-0000000000f8', '00000000-0000-0000-0000-000000000002',
   'PONTEGGI', 'ADDETTO AL MONTAGGIO, SMONTAGGIO, TRASFORMAZIONE DI PONTEGGI O PER PREPOSTI ALLA SORVEGLIANZA',
   '2025-04-04', 4, 'Ente Alfa', true, false, true, true, null, 'evidenza incompleta', 'gest:f8');
