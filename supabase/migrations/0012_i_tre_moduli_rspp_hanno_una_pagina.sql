-- AppOverall — 0012
-- Tre righe tornano a essere un'affermazione, perche adesso qualcuno le ha lette.
--
-- ============================================================================
--  COSA E CAMBIATO IN DODICI ORE
-- ============================================================================
--
-- La `0011` ha portato ad `assente` **13 marche** senza fonte leggibile, e fra
-- quelle c'erano `RSPP_MOD_A.ore = 28`, `RSPP_MOD_B.ore = 48` e `RSPP_MOD_C.ore
-- = 24`. Il motivo era buono: l'Accordo del 7/7/2016 in `fonti/` e una scansione
-- **senza livello di testo**, `pdftotext` ne cava 37 byte, e lo era anche la copia
-- di Organigramma-sicurezza.
--
-- **Il motivo era buono e guardava la fonte sbagliata.** Le durate dei tre moduli
-- stanno anche nella **Parte II dell'ASR 2025**, che nessuno aveva trascritto — ed
-- era il passo assegnato ad AppFormazione la sera stessa. Trascritta il 12
-- settembre in `formazione-81-utils-src/reference/asr-2025-parte-ii-durate-iniziali.md`
-- (`4b8376d`), letta a video pagina per pagina:
--
--   Modulo A         punto 5.2, pag. 23   «La durata complessiva e di 28 ore,
--                                          escluse le verifiche di apprendimento finali»
--   Modulo B comune  punto 5.3, pag. 26   «un Modulo comune a tutti i settori
--                                          produttivi della durata di 48 ore»
--   Modulo C         punto 5.4, pag. 31   stessa formula del Modulo A, 24 ore
--
-- Verificato da questa parte aprendo il file, come per il monte ore della `0011`.
--
-- **La `0011` non e stata smentita: e stata superata da una lettura.** E la
-- differenza fra le due categorie che quella migrazione aveva istituito — «fonte
-- non leggibile» e «fonte non trascritta» — ha fatto esattamente il suo lavoro in
-- tutte e due le direzioni: le sei della Parte II non erano state marcate `assente`
-- e non hanno mai gridato a vuoto; queste tre lo erano, ed e bastata mezza giornata
-- di lettura per toglierle. **La linea era nel posto giusto, e si e visto quando si
-- e mossa.**

update corso set ore_grandezza = 'durata_corso'
 where codice in ('RSPP_MOD_A', 'RSPP_MOD_B', 'RSPP_MOD_C');

-- ---------- e cio che si e letto NON e cio che si voleva sapere ieri ----------
--
-- Qui e facile prendersi piu di quello che si e letto, e chi ha trascritto lo ha
-- detto per primo: **quello che la Parte II dichiara e il valore VIGENTE.** La
-- durata di un corso erogato oggi si cita da li; un attestato rilasciato **fra il
-- 2016 e il 2024** resta da giudicare su una fonte che non abbiamo, e la riga del
-- quadro storico che lo dichiara non e stata tolta.
--
-- **I numeri coincidono, e coincidere col testo nuovo non e leggere il vecchio.** E
-- la stessa distinzione gia in uso per l'antincendio del 1998 — e, da oggi, il caso
-- d'uso della **validita temporale** decisa nella scheda 12: il meccanismo che
-- serve qui esiste da stasera, e il valore che ci andrebbe dentro non lo abbiamo
-- ancora. Le due cose si tengono separate.

update corso set note = 'Modulo A: **28 ore**, ASR 17/04/2025 Parte II punto 5.2, pag. 23 — «escluse le verifiche di apprendimento finali». E il valore **vigente**: per un attestato rilasciato fra il 2016 e il 2024 la fonte e l''Accordo 7/7/2016, che in `fonti/` e una scansione senza livello di testo e resta non leggibile.'
 where codice = 'RSPP_MOD_A';

update corso set note = 'Modulo B comune: **48 ore**, ASR 17/04/2025 Parte II punto 5.3, pag. 26. Pag. 27: «Il Modulo B comune e propedeutico per l''accesso ai moduli di specializzazione» e «la durata dei corsi non comprende le verifiche di apprendimento finali». Vale la stessa riserva del Modulo A sugli attestati 2016-2024. L''**aggiornamento** invece e un monte ore quinquennale, vedi `ore_aggiornamento_grandezza`.'
 where codice = 'RSPP_MOD_B';

update corso set note = 'Modulo C: **24 ore**, ASR 17/04/2025 Parte II punto 5.4, pag. 31 — «escluse le verifiche di apprendimento finali». Solo RSPP, non ASPP. Vale la stessa riserva del Modulo A sugli attestati 2016-2024.'
 where codice = 'RSPP_MOD_C';

-- ============================================================================
--  DOVE FINISCE IL RIGHELLO, CHE NON E UNA GRANDEZZA
-- ============================================================================
--
-- Trovato leggendo, e non era nell'assegnazione. **Due famiglie del catalogo
-- contano la stessa giornata in due modi:**
--
--   moduli RSPP          «escluse le verifiche di apprendimento finali»
--                        (punti 5.2 e 5.4, e pag. 27 sull'intera famiglia)
--   antincendio          i totali del DM 02/09/2021 sono «compresa verifica di
--                        apprendimento»
--
-- **Non e una grandezza diversa** — nessuna delle due e parte pratica e nessuna e
-- un monte ore — quindi `ore_grandezza` resta `durata_corso` su entrambe e sarebbe
-- sbagliato marcarle diverse. E **e dove finisce il righello**, che e un'altra cosa
-- ancora, e oggi non produce falsi per una ragione precisa: il confronto e `>=` e
-- la verifica **allunga**. Un attestato che porta il totale con la verifica supera
-- la soglia scritta senza la verifica; il viceversa non capita.
--
-- Va saputo **prima** di stringere un confronto in `=` o in una tolleranza, non
-- dopo. Sta scritto qui e non in una colonna perche una colonna che nessuno usa e
-- impalcatura, e perche il giorno in cui servisse la si scrive sapendo gia quali
-- due famiglie separa.
--
-- E la premessa che quella lettura ha messo sotto tutte le durate della Parte II —
-- punto 1, pag. 10: **«I percorsi formativi, gli argomenti e la loro durata vanno
-- intesi come minimi»**. Sono pavimenti, e il confronto e `>=`. Questo e l'asse
-- dell'operatore, non quello della grandezza: due cose che si somigliano nel
-- discorso e stanno in due colonne diverse.
--
-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select ore_grandezza, count(*) from corso group by 1 order by 1;
--         assente 9 · durata_corso 31
--   select count(*) from corso where ore is not null and ore_grandezza = 'assente';
--         -- 5, ed erano 8
--
-- **Il filo teso si accorcia di tre, e si e accorciato nel verso giusto**: non
-- rimettendo un'affermazione al posto di un «non lo so», ma perche qualcuno e
-- andato a leggere la pagina. E l'unico modo in cui quel numero puo scendere, e la
-- `0011` lo aveva scritto come condizione.
--
-- Le cinque che restano sono quelle che **nessuna lettura chiude**, perche la fonte
-- o non esiste o non e acquisibile: la CEI 11-27 a pagamento, il protocollo IRC su
-- due codici, la prassi dei lavori in quota, e il 12 degli ambienti confinati che e
-- una scelta di erogazione. Piu cinque sulla colonna dell'aggiornamento, invariate.
