-- AppOverall — 0018
-- La Qualifica e una seconda fonte: cinque forme nuove, e la gemella della 070.
--
-- ============================================================================
--  PERCHE ESISTE
-- ============================================================================
--
-- La `0007` e il dizionario dei ruoli scritti a mano, e ha una **copia gemella** in
-- AppSopralluoghi: il seme della loro `068`. Il 14 settembre Francesco ha deciso che
-- l'import delle nomine legge anche la colonna **Qualifica** quando la Mansione e
-- piena, **come fonte distinta** (sezione 8, «1 e 2 ok»). Da li sono uscite cinque
-- forme che nessuno dei due dizionari conosceva, e la loro `070` le aggiunge.
-- Questa migrazione le aggiunge qui **nella stessa stringa**: la forma e stata
-- mandata prima del loro commit apposta, e le cinque grafie sono lette dal loro file
-- (`070_qualifica_fonte_distinta.sql`, ramo `qualifica-fonte-distinta`), non
-- ricopiate dal messaggio.
--
-- ============================================================================
--  LA POPOLAZIONE CAMBIA, I CONTI DELLA 0007 NO
-- ============================================================================
--
-- La `0007` dice di se: «I 29 modi in cui un ruolo di sicurezza e stato scritto
-- dentro il campo mansione», 160 righe. **Resta vero**: la misura `8dab00a` leggeva
-- la sola colonna Mansione, e AppSopralluoghi l'ha verificato (`afbb88e`) riapplicando
-- il seme alla sola colonna Y — 160 righe e 168 coppie, esatti. Quello che cambia e
-- che il dizionario **non descrive piu una colonna sola**: da qui in poi le forme
-- vengono da due, e la nota di ogni forma nuova dice quale. Il commento della tabella
-- e riscritto qui sotto invece di lasciare alla `0007` una frase che smette di
-- descrivere la popolazione — la stessa forma della `0015`.
--
-- ============================================================================
--  LE CINQUE FORME, E COSA ASSERISCONO
-- ============================================================================
--
--   Lavoratore e preposto        13 righe   preposto                 posizione non dichiarata
--   RLS                           4 righe   rls                      posizione non dichiarata
--   RLS - LAVORATORE              3 righe   rls                      il lavoratore NON si asserisce
--   RSPP-SOCIO                    1 riga    rspp, socio              non si risolve
--   Legale Rappresentante/RSPP    1 riga    rspp, non dichiarata     non si risolve
--
-- **«RLS - LAVORATORE» nomina un incarico solo.** La lettura e di Francesco: sono due
-- ruoli, e dal dizionario conta la meta RLS. Il lavoratore il dizionario non lo
-- asserisce mai — ogni persona dell'anagrafe lo e gia — quindi una seconda parola
-- `lavoratore` sarebbe un fatto che nessun'altra forma porta.
--
-- **Le ultime due non si risolvono, e non per dimenticanza.** `(rspp, socio)` e
-- `(rspp, non_dichiarato)` sono le due combinazioni che la `0007` lascia fuori
-- apposta: essere socio non stabilisce di essere il datore, e «RSPP» senza posizione
-- non dice fra art. 32 e art. 34. «Legale rappresentante» non e scritto «datore di
-- lavoro»: AppSopralluoghi lo porta a Francesco come domanda aperta, e finche non
-- risponde **qui non si sceglie** (A7). I non risolti passano da 7 a 9.
--
-- ============================================================================
--  LA PAROLA CHE MANCAVA
-- ============================================================================
--
-- Nel campo mansione l'RLS non compariva mai — la misura dell'11 settembre dava
-- «RLS, primo soccorso ed emergenze: zero» — e la `0007` ha scritto il vocabolario
-- delle parole su cio che c'era. Il `check` non conosceva `rls`: **la prima forma
-- RLS avrebbe fatto fallire il carico**, che e il modo giusto di scoprirlo. Si
-- allarga il vocabolario, e si aggiunge la regola con il suo motivo.

alter table ruolo_testo_parola drop constraint parola_nota;
alter table ruolo_testo_parola add constraint parola_nota check (parola in (
  'rspp', 'aspp', 'datore_lavoro', 'preposto', 'dirigente', 'addetto_antincendio', 'rls'
));

alter table ruolo_da_parola drop constraint parola_della_regola_nota;
alter table ruolo_da_parola add constraint parola_della_regola_nota check (parola in (
  'rspp', 'aspp', 'datore_lavoro', 'preposto', 'dirigente', 'addetto_antincendio', 'rls'
));

insert into ruolo_testo (testo, chiave, posizione, righe, note) values
  ('Lavoratore e preposto',      'LAVORATOREEPREPOSTO',      'non_dichiarato', 13,
   '13 righe nell''export del 09/09/2026, colonna Qualifica. Quasi sempre accanto a una Mansione piena e senza colonna di ruolo.'),
  ('RLS',                        'RLS',                      'non_dichiarato',  4,
   '4 righe nell''export del 09/09/2026, colonna Qualifica.'),
  ('RLS - LAVORATORE',           'RLSLAVORATORE',            'non_dichiarato',  3,
   '3 righe nell''export del 09/09/2026, colonna Qualifica, e in nessuna la colonna RLS e compilata. Due ruoli nella frase, un incarico nel dizionario: il lavoratore non si asserisce (lettura di Francesco, 14 settembre 2026).'),
  ('RSPP-SOCIO',                 'RSPPSOCIO',                'socio',           1,
   '1 riga nell''export del 09/09/2026, colonna Qualifica. E «SOCIO/RSPP» rovesciata, e come quella non si risolve.'),
  ('Legale Rappresentante/RSPP', 'LEGALERAPPRESENTANTERSPP', 'non_dichiarato',  1,
   '1 riga nell''export del 09/09/2026, colonna Qualifica. «Legale rappresentante» non e scritto «datore di lavoro»: domanda aperta per Francesco, e finche e aperta la riga non si risolve.');

insert into ruolo_testo_parola (testo, parola) values
  ('Lavoratore e preposto',      'preposto'),
  ('RLS',                        'rls'),
  ('RLS - LAVORATORE',           'rls'),
  ('RSPP-SOCIO',                 'rspp'),
  ('Legale Rappresentante/RSPP', 'rspp');

insert into ruolo_da_parola (parola, posizione, ruolo, motivo) values
  ('rls', null, 'rls',
   'Art. 47 e 37 c. 10. La posizione non discrimina: l''RLS e eletto o designato dai lavoratori, e chi scrive «RLS» ha nominato l''incarico senza bisogno di dire chi e. Entrata con la 0018, dalla colonna Qualifica: nel campo mansione l''RLS non compariva mai.');

comment on table ruolo_testo is
  'I modi in cui un ruolo di sicurezza e stato scritto **a mano** nel gestionale, verbatim. Due fonti: il campo «mansione» (29 forme su 160 righe, misurate l''11 settembre 2026 sulla sola colonna Mansione, `0007`) e la colonna «Qualifica» (5 forme su 22 righe, `0018`); la nota di ogni forma della `0018` dice da quale colonna viene. Non e una tabella di traduzione: registra cosa c''era scritto e cosa la frase dice della persona, e la regola sta in `ruolo_da_parola`.';

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from ruolo_testo;                          -- 34  (29 + 5)
--   select sum(righe) from ruolo_testo;                        -- 182 (160 + 22)
--   select count(*) from ruolo_testo_parola;                   -- 39  (34 + 5)
--   select count(*) from ruolo_da_parola;                      -- 10  (9 + 1)
--
--   -- le asserzioni:                                          190 (168 + 22)
--   -- risolte e non risolte, con la query della 0007:         181 e 9
--   --   le 20 nuove risolte sono 13 preposto + 7 rls; i 2 nuovi non risolti sono
--   --   RSPP-SOCIO e Legale Rappresentante/RSPP
--
-- **E il conto che la gemella deve tenere con la `070`**: le cinque stringhe di
-- `ruolo_testo.testo` qui sono **identiche** alle cinque `varianti` di la, byte per
-- byte. Se una delle due cambia prima del loro commit, questa migrazione va
-- riallineata, non la loro riletta a memoria. **Confrontate sui file il 14 settembre**:
-- identiche a `d849073` di AppSopralluoghi, con le stesse posizioni e le stesse figure.

-- ============================================================================
--  UNA CORREZIONE ALLA 0017, CHE NON C'ENTRA CON LA QUALIFICA E VA SCRITTA QUI
-- ============================================================================
--
-- La `0017` dice che la guardia sul segnaposto di `pivaUsabile` «scrive
-- `(\d){10}`». **Giusto l'effetto, sbagliata la causa.** Nel sorgente, dopo `(\d)`,
-- c'era il **byte di controllo 0x01**: un `\1` diventato invisibile, entrato con
-- `0d0c8a0` il 9 settembre. Il terminale da cui la riga e stata letta lo mostrava come
-- `(\d){10}`, e da li e stato trascritto. Visto con `od -c` su `origin/main` di
-- AppSopralluoghi il 14 settembre — `( \ d ) 001 { 1 0 }` — dopo che la corsia l'ha
-- trovato riparandolo (`5fb57ab`). La regex cercava una cifra seguita da dieci byte
-- 0x01: non corrispondeva mai, e 00000000000 risultava usabile, come misurato.
--
-- **La `0017` non si riscrive**: si corregge qui il commento della funzione, che e cio
-- che si legge dal database. E lo stesso byte e stato cercato in tutti i 51 file di
-- questo repo, con uno strumento provato prima su una sonda che lo conteneva: nessuno.

comment on function partita_iva_usabile(text) is
  'Undici cifre, non tutte uguali, spazi esclusi. Fa cio che fa `pivaUsabile` di AppSopralluoghi **dopo** la riparazione del 14 settembre (`5fb57ab`): fino ad allora un byte di controllo 0x01 al posto di `\1` rendeva muta la guardia sul segnaposto e 00000000000 risultava usabile. (La `0017` descriveva quel byte come `(\d){10}`, che e come lo mostrava un terminale: corretto dalla `0018`.) Nessun controllo della cifra di controllo, come all''origine.';
