-- AppOverall — dati finti per il passo 06, l'ATECO e i livelli.
--
-- Non inserisce righe: **ritocca** le unita' d'origine di `prova_01_clienti_dati.sql` e
-- `prova_03_nomine_dati.sql`, che hanno gia' le loro sedi. Un caso per unita', e i
-- testi hanno la forma che AppSopralluoghi scrive davvero (loro `072`: la riga piu'
-- recente in testa). Nomi dei tecnici di fantasia.
--
--   c1  25 alto, «tabella_ateco»          uguale al default: NON si scrive
--       antincendio 2 con motivazione     si scrive
--       primo soccorso BC senza testo     si scrive, e BC si conta
--   c2  «5», basso, senza testo           la divisione diventa 05 (alto): scostamento, si scrive
--   c3  nessun ATECO, medio, a mano       senza default: si scrive
--   c4  rischio vuoto, testo «tolto»      non c'e' valore: si conta e non si porta
--   c5  45 alto, a mano, con la cella     45 e' basso: scostamento, si scrive; la cella va sulla sede
--   c6  86 alto, testo che non e' tabella uguale al default dedotto: non si scrive, e la frase si conta
--   a   01, primo soccorso A con testo    si scrive
--   c   antincendio 1 senza testo         si scrive

update origine.cliente set
  livello_rischio_definito_mediante = 'tabella_ateco, applicato il 16/09/2026 da Tecnico Uno',
  livello_antincendio = '2',
  antincendio_definito_mediante = 'Valutazione del rischio incendio, DVR rev. 2',
  gruppo_primo_soccorso = 'BC'
 where id = '00000000-0000-0000-0000-0000000000c1';

update origine.cliente set codice_ateco = '5', livello_rischio = 'basso'
 where id = '00000000-0000-0000-0000-0000000000c2';

update origine.cliente set
  livello_rischio = 'medio',
  livello_rischio_definito_mediante = 'livello MEDIO scelto a mano il 16/09/2026 da Tecnico Due: DVR rev. 3'
 where id = '00000000-0000-0000-0000-0000000000c3';

update origine.cliente set
  livello_rischio_definito_mediante = 'livello tolto il 16/09/2026 da Tecnico Uno: ATECO sbagliato, corretto in visura'
    || chr(10) || 'tabella_ateco, applicato il 15/09/2026 da Tecnico Uno'
 where id = '00000000-0000-0000-0000-0000000000c4';

update origine.cliente set
  livello_rischio = 'alto',
  livello_rischio_definito_mediante = 'livello ALTO scelto a mano il 16/09/2026 da Tecnico Due: saldatura in officina',
  ateco_origine = '(G.45.20) Manutenzione e riparazione di autoveicoli;'
 where id = '00000000-0000-0000-0000-0000000000c5';

update origine.cliente set
  codice_ateco = '86', livello_rischio = 'alto',
  livello_rischio_definito_mediante = 'confermato a voce dal datore di lavoro'
 where id = '00000000-0000-0000-0000-0000000000c6';

update origine.cliente set
  codice_ateco = '01',
  gruppo_primo_soccorso = 'A',
  primo_soccorso_definito_mediante = 'Comparto agricoltura, 8 addetti'
 where id = '00000000-0000-0000-0000-00000000000a';

update origine.cliente set livello_antincendio = '1'
 where id = '00000000-0000-0000-0000-00000000000c';
