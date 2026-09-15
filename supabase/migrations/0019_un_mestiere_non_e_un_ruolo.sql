-- AppOverall — 0019
-- Un mestiere che contiene la parola «antincendio» non e un ruolo: la gemella della 071.
--
-- ============================================================================
--  PERCHE ESISTE
-- ============================================================================
--
-- Nove righe di DER ERSTE s.r.l. nell'export del 09/09/2026 (`ExportExcel (4).xlsx`,
-- foglio «Ruoli SSL», righe 180, 277, 278, 919, 1825, 2260, 2381, 2670, 2868) hanno la
-- Mansione «INSTALLATORE/MANUTENTORE IMPIANTI ANTINCENDIO E ANTIFURTO». Il testo non
-- era a dizionario e contiene ANTINCENDIO, quindi l'import delle nomine di
-- AppSopralluoghi le metteva fra le «da decidere». **Chi installa impianti
-- antincendio non e per questo l'addetto antincendio della sua azienda.**
--
-- Decisione di Francesco del 15 settembre 2026: la forma entra nel dizionario come
-- testo che **non asserisce nessun incarico**. AppSopralluoghi l'ha scritta nella
-- loro `071` (`45c7193`), applicata dall'SQL Editor lo stesso giorno, e ha segnalato
-- che la gemella di qui non la aveva. La stringa e letta dal loro file, non ricopiata
-- dal messaggio.
--
-- ============================================================================
--  COME, NELLA STRUTTURA DI QUI
-- ============================================================================
--
-- La loro `071` scrive una riga in `ruolo_testo` e nessuna in `ruolo_testo_figura`.
-- Qui la forma e la stessa con i nomi della `0007`: una riga in `ruolo_testo` e
-- **nessuna in `ruolo_testo_parola`**. Le query della `0007` partono da
-- `ruolo_testo join ruolo_testo_parola`, quindi la riga non conta ne fra le
-- asserzioni ne fra le non risolte: non e un «non risolto», e un testo che non
-- nomina niente. `posizione` e `non_dichiarato`, come la loro: la frase non dice
-- niente della persona.
--
-- **Cosa cambia di significato**: fino alla `0018` ogni riga di `ruolo_testo` nominava
-- almeno un incarico. Da qui non piu, e il commento della tabella lo dice — la stessa
-- forma della `0018`, che l'ha riscritto quando e cambiata la popolazione invece di
-- lasciare una frase che smette di descriverla.

insert into ruolo_testo (testo, chiave, posizione, righe, note) values
  ('INSTALLATORE/MANUTENTORE IMPIANTI ANTINCENDIO E ANTIFURTO',
   'INSTALLATOREMANUTENTOREIMPIANTIANTINCENDIOEANTIFURTO',
   'non_dichiarato', 9,
   'Mestiere, non ruolo: 9 righe di DER ERSTE s.r.l. nell''export del 09/09/2026, colonna Mansione. Nessun incarico nominato, per decisione di Francesco del 15 settembre 2026; gemella della 071 di AppSopralluoghi.');

comment on table ruolo_testo is
  'I testi scritti **a mano** nel gestionale che il dizionario conosce, verbatim. Due fonti: il campo «mansione» (29 forme su 160 righe, misurate l''11 settembre 2026 sulla sola colonna Mansione, `0007`) e la colonna «Qualifica» (5 forme su 22 righe, `0018`). Quasi tutti nominano un incarico in `ruolo_testo_parola`; quelli che non ne nominano nessuno sono testi che sembrano un ruolo e non lo sono, decisi uno per uno (`0019`: un mestiere con la parola «antincendio»). Non e una tabella di traduzione: la regola sta in `ruolo_da_parola`.';

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from ruolo_testo;                          -- 35  (34 + 1)
--   select sum(righe) from ruolo_testo;                        -- 191 (182 + 9)
--   select count(*) from ruolo_testo_parola;                   -- 39  invariato
--   select count(*) from ruolo_da_parola;                      -- 10  invariato
--
--   -- le asserzioni e le non risolte, con le query della 0007: 190, e 181 e 9, invariati
--
--   -- e il conto che dice se la forma e stata capita: i testi senza incarico,  1
--   select count(*) from ruolo_testo t
--    where not exists (select 1 from ruolo_testo_parola p where p.testo = t.testo);
--
-- Se le asserzioni passassero a 199, qualcuno avrebbe dato al mestiere una parola —
-- `addetto_antincendio` — e le nove persone di DER ERSTE diventerebbero addetti.
--
-- **Il conto con la gemella**: la stringa di `testo` e **identica** a `chiave` e a
-- `varianti` della `071_ruolo_testo_mestiere_antincendio.sql` di AppSopralluoghi,
-- byte per byte, confrontata sul loro `origin/main` il 15 settembre 2026.
