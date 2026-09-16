-- AppOverall — dati finti per il passo 04, gli attestati.
--
-- Si caricano su `origine.formazione` dopo `prova_02_persone_dati.sql`, di cui usano
-- i **codici fiscali**: fra i due database non c'e' nessun id in comune, e la persona
-- si riconosce da li'. Coprono i casi che il passo deve saper distinguere, e uno per
-- volta, cosi' un conteggio che non torna dice **quale**:
--
--   1. l'attestato normale, con un titolo che il dizionario mappa;
--   2. lo stesso titolo scritto con **due spazi**: si risolve lo stesso, perche' il
--      confronto e' sul testo normalizzato — ed e' il caso per cui la
--      normalizzazione esiste;
--   3. un titolo che il dizionario dichiara **ignorato**: non entra, e si conta;
--   4. due attestati sulla **stessa persona, corso e data**: entrano tutti e due e la
--      collisione si segnala (decisione del 16.09.2026);
--   5. due spezzoni di un percorso frazionato: entrano **aperti**;
--   6. un codice fiscale che l'anagrafe non ha: non entra, e si conta;
--   7. una riga senza codice fiscale: non entra, e si conta a parte — le due ragioni
--      non sono la stessa cosa;
--   8. `esito`, `numero_attestato` e `fonte` valorizzati: si contano e non entrano.
--
-- I titoli sono testi veri del dizionario: se il seed cambiasse, la prova se ne
-- accorgerebbe invece di passare lo stesso.

insert into origine.formazione
  (id, codice_fiscale, corso_titolo, corso_codice_origine, data_completamento, ore,
   ente_erogatore, numero_attestato, esito, fonte)
values
  -- 1. il caso normale
  ('00000000-0000-0000-0000-0000000000f1', 'JQIOBW08B92B915V',
   'ADDETTO AL MONTAGGIO, SMONTAGGIO, TRASFORMAZIONE DI PONTEGGI O PER PREPOSTI ALLA SORVEGLIANZA',
   'GEST-aaaaaaaa', '2019-05-10', 28, 'Ente Alfa', null, null, 'interna'),

  -- 2. lo stesso titolo con due spazi in mezzo: lo prende la normalizzazione
  ('00000000-0000-0000-0000-0000000000f2', 'JQIOBW08B92B915V',
   'ADDETTO A LAVORI IN SPAZI  CONFINATI E SOSPETTI DI INQUINAMENTO',
   'GEST-bbbbbbbb', '2021-03-01', 12, 'Ente Beta', null, null, 'interna'),

  -- 3. un titolo ignorato a mano
  ('00000000-0000-0000-0000-0000000000f3', 'JQIOBW08B92B915V',
   'ADDETTO LAVORI IN AMBIENTI SOSPETTI DI PRESENZA AMIANTO',
   'GEST-cccccccc', '2022-06-15', 5, 'Ente Gamma', null, null, 'interna'),

  -- 4. la collisione: stessa persona, stesso corso, stessa data della f1
  ('00000000-0000-0000-0000-0000000000f4', 'JQIOBW08B92B915V',
   'ADDETTO AL MONTAGGIO, SMONTAGGIO, TRASFORMAZIONE DI PONTEGGI O PER PREPOSTI ALLA SORVEGLIANZA',
   'GEST-aaaaaaaa', '2019-05-10', 28, 'Ente Alfa', null, null, 'interna'),

  -- 5. due spezzoni: entrano aperti
  ('00000000-0000-0000-0000-0000000000f5', 'HOZUNW31P60Q756F',
   'FORMAZIONE SPECIFICA RISCHIO ALTO PARZIALE 6H 1\2',
   'GEST-dddddddd', '2026-01-10', 6, 'Ente Delta', null, null, 'interna'),
  ('00000000-0000-0000-0000-0000000000f6', 'HOZUNW31P60Q756F',
   'FORMAZIONE SPECIFICA RISCHIO ALTO, PARZIALE 6H 2/2',
   'GEST-eeeeeeee', '2026-02-20', 6, 'Ente Delta', null, null, 'interna'),

  -- 6. un codice fiscale valido che l'anagrafe non ha
  ('00000000-0000-0000-0000-0000000000f7', 'BNCLRA75D45L219R',
   'ADDETTO AL MONTAGGIO, SMONTAGGIO, TRASFORMAZIONE DI PONTEGGI O PER PREPOSTI ALLA SORVEGLIANZA',
   'GEST-aaaaaaaa', '2024-09-01', 28, 'Ente Alfa', 'ATT-2024-001', 'idoneo', 'esterna'),

  -- 7. senza codice fiscale: e un'altra ragione, e si conta a parte
  ('00000000-0000-0000-0000-0000000000f8', null,
   'ADDETTO AL MONTAGGIO, SMONTAGGIO, TRASFORMAZIONE DI PONTEGGI O PER PREPOSTI ALLA SORVEGLIANZA',
   'GEST-aaaaaaaa', '2025-04-04', 4, 'Ente Alfa', 'ATT-2025-002', 'idoneo', 'esterna');
