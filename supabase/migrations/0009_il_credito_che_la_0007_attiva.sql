-- AppOverall — 0009
-- Il credito formativo: 53 caselle della pagina 130, e le 7 che non si scrivono.
--
-- ============================================================================
--  IL FATTO CHE HA CHIESTO QUESTA MIGRAZIONE
-- ============================================================================
--
-- AppFormazione ha letto la `0007` **prima** che venisse caricata, e il primo dei
-- sei rilievi era quello che da qui non potevo vedere.
--
-- Quattro frasi del campo «mansione» nominano `rspp` **e** `datore_lavoro` con
-- `posizione = 'datore'` — «RSPP - Datori di Lavoro», «DATORE DI LAVORO- RSPP»,
-- «AMMINISTRATORE/DATORE DI LAVORO/RSPP» — e le regole della `0007` le risolvono
-- **due volte, giustamente**: quella persona **e** il datore **ed e** il datore che
-- fa l'RSPP. Sono sette righe.
--
-- Ma due ruoli non sono due percorsi formativi. L'Allegato III dell'ASR 2025 dice
-- che chi ha fatto l'art. 34 **non deve rifare** l'art. 37, e in questo schema una
-- tabella dei crediti **non c'era**: cercata e assente. Quelle sette persone
-- risulterebbero dovere il percorso da datore-RSPP **piu** le 16 ore da datore, e
-- `corso_assolve` funzionerebbe **perfettamente producendo il risultato sbagliato**.
--
-- E la loro formulazione e quella che conta: **non e un difetto della `0007`, e un
-- difetto che la `0007` ATTIVA.** Finche le nomine non entravano, il credito
-- mancante non costava niente — e il giorno in cui entrano non costa un errore
-- visibile: costa **un obbligo in piu**, che a chi lo legge sembra prudenza.
--
-- ============================================================================
--  LA FONTE, LETTA QUI
-- ============================================================================
--
-- ASR 17 aprile 2025 (Rep. Atti n. 59/CSR), **Allegato III, pagina 130** di 136.
-- Trascrizione in `formazione-81-utils-src/reference/asr-2025-crediti.md`, commit
-- `a1827fd` della libreria, con il fascicolo sotto in `reference/fonti/`.
--
-- **Questa e la seconda lettura, e va detto quale sia la prima.** La matrice era
-- gia stata codificata da AppFormazione nella loro `0027`. Quella migrazione non e
-- stata copiata: le 53 caselle qui sotto vengono dalla trascrizione, e il confronto
-- con la loro tabella e un **conto in fondo a questo file**, non una premessa. Due
-- letture della stessa pagina che concordano valgono; una copia che concorda con se
-- stessa non vale niente — assunzione A9.
--
-- ============================================================================
--  PERCHE QUI LA MATRICE ENTRA INTERA, E LA DOVEVA RESTRINGERSI
-- ============================================================================
--
-- La pagina 130 ha **dieci righe e sei colonne**. La `0027` ne codifica sette righe,
-- e le tre differenze sono **dichiarate da loro** come limiti del catalogo, non come
-- letture diverse:
--
--   RSPP e ASPP        -> un codice solo. Le due righe dell'allegato sono identiche
--                         in tutte e sei le colonne, quindi la fusione non perde
--                         niente. **Qui non serve**: `aspp` e `rspp` sono due righe
--                         di `ruolo_sicurezza` dalla `0002`.
--
--   DL-RSPP e DL       -> un codice solo, e **questa fusione perde**: le due righe
--                         differiscono nella colonna DL, dove il DL-RSPP ha credito
--                         totale e il DL ha una barra. **Qui non serve**:
--                         `datore_lavoro` (art. 37) e `datore_lavoro_rspp` (art. 34)
--                         sono due codici, ed e la distinzione da cui nasce meta di
--                         questo progetto.
--
--   Coordinatore CSP/CSE -> nessun codice, perche nel loro catalogo non c'e un corso
--                         a cui appenderlo. **Qui il codice c'e**
--                         (`coordinatore_sicurezza`, art. 98 e allegato XIV), e il
--                         corso no — vedi la nota sulle righe inerti, piu sotto.
--
-- Quindi da questa parte la pagina entra per intero: **53 righe**, che sono le 60
-- caselle meno le 7 barre.
--
-- ============================================================================
--  PERCHE LA CHIAVE HA QUATTRO COLONNE E NON DUE
-- ============================================================================
--
-- Le voci della matrice non sono tutte obblighi interi. **«LAVORATORE generale» e
-- «LAVORATORE specifica» sono due caselle distinte dello stesso ruolo**, e non si
-- comportano allo stesso modo: l'RLS ha **TOTALE** sulla generale e **FREQUENZA**
-- sulla specifica. E l'unica riga in cui i due lavoratori si separano, e da sola
-- basta a decidere la forma.
--
-- Collassarle su `lavoratore` vorrebbe dire scegliere **un** valore per due caselle
-- che la fonte tiene separate: prendere il piu prudente sbaglia per eccesso e in
-- silenzio, prendere il piu largo esonera qualcuno da un corso che deve fare. Le due
-- direzioni sono entrambe sbagliate, e la seconda non si vede.
--
-- Quindi il credito lega **due coppie** (ruolo, corso), dove il corso e nullable:
--
--   corso null        l'obbligo per intero — «chi possiede il percorso RSPP»
--   corso valorizzato una sua parte, e **solo dove e la fonte a distinguerla**
--
-- E le due colonne sono **simmetriche** per una ragione e non per estetica: le righe
-- e le colonne della pagina 130 sono la stessa lista di voci, quindi cio che vale
-- come credito vale anche come cosa posseduta.
--
-- Oggi le uniche righe con il corso valorizzato sono `LAV_GEN` e `LAV_SPEC`. La
-- colonna non e prevista per loro: e prevista per la prossima voce che l'allegato
-- distinguera e il ruolo no.

create table credito_formativo (
  ruolo_posseduto text not null references ruolo_sicurezza(codice),
  corso_posseduto text references corso(codice),
  ruolo_creditato text not null references ruolo_sicurezza(codice),
  corso_creditato text references corso(codice),
  -- L'asterisco della pagina 130 e un **valore**, non una nota a pie di pagina:
  -- «il credito viene riconosciuto totale per coloro che svolgono il ruolo indicato
  -- nella prima colonna nella medesima azienda, negli altri casi la formazione deve
  -- essere svolta». Un booleano `totale` con l'asterisco nel commento avrebbe
  -- esonerato in silenzio chi il ruolo lo svolgeva altrove.
  credito text not null
    constraint credito_valore_noto check (credito in (
      'totale',                -- non deve frequentare
      'totale_stessa_azienda', -- totale se svolge il ruolo nella medesima azienda
      'frequenza')),           -- nessun credito: il corso va fatto
  fonte text not null,
  nota text,
  -- Le barre dell'allegato non si scrivono, e un credito verso se stessi non
  -- esiste. Il confronto e sulla **coppia** perche `lavoratore/LAV_GEN` e
  -- `lavoratore/LAV_SPEC` sono due voci diverse dello stesso ruolo.
  constraint credito_non_riflessivo check (
    ruolo_posseduto <> ruolo_creditato
    or coalesce(corso_posseduto, '') <> coalesce(corso_creditato, ''))
);

-- I null non collidono fra loro in un vincolo di unicita: senza `coalesce` la
-- stessa casella potrebbe entrare due volte. Stessa forma di `corso_assolve_unico`.
create unique index credito_formativo_unico
  on credito_formativo (ruolo_posseduto, coalesce(corso_posseduto, ''),
                        ruolo_creditato, coalesce(corso_creditato, ''));

create index on credito_formativo (ruolo_creditato, coalesce(corso_creditato, ''));

comment on table credito_formativo is
  'Quale formazione posseduta esonera da quale corso: la matrice dell''Allegato III dell''ASR 17/04/2025, pagina 130, per intero — **53 righe**, che sono le 60 caselle meno le 7 barre. Le righe `frequenza` sono un terzo della tabella e vanno tenute: dicono che quella casella e stata **letta**, non che non e stata guardata. Senza di loro, fra sei mesi l''assenza di una riga si rileggerebbe come «non ancora codificato».';
comment on column credito_formativo.corso_posseduto is
  'Null = l''obbligo per intero. Valorizzato = una sua parte, e **solo dove e la fonte a distinguerla**: oggi `LAV_GEN` e `LAV_SPEC`, perche la riga RLS della pagina 130 da TOTALE sulla generale e FREQUENZA sulla specifica. Un ruolo solo non sa dire due valori.';
comment on column credito_formativo.credito is
  'totale = non deve frequentare; totale_stessa_azienda = totale **solo** se svolge il ruolo indicato nella medesima azienda (l''asterisco della pagina 130); frequenza = nessun credito. La condizione della medesima azienda e sull''**azienda** e non sulla sede, ed e la ragione per cui `nomina` porta `cliente_id` accanto a `sede_id` fin dalla `0001`: chi e RSPP in una sede e preposto in un''altra della stessa azienda la soddisfa.';
comment on column credito_formativo.fonte is
  'Parte, punto e pagina su ogni riga, come tutte le regole destinate alle tabelle applicative (A7). Qui e la stessa per tutte e 53, e va scritta lo stesso: il giorno in cui una riga verra da un''altra pagina, la differenza si dovra vedere sulla riga e non nella storia del file.';

alter table credito_formativo enable row level security;
create policy leggono_gli_operatori on credito_formativo for select to authenticated using (e_operatore());
create policy scrive_amministrazione on credito_formativo for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
grant select on credito_formativo to authenticated;

-- ============================================================================
--  LA MATRICE DI PAGINA 130
-- ============================================================================
--
-- Righe: la formazione posseduta. Colonne: il corso per cui vale il credito.
-- L'ordine qui sotto e quello della pagina, riga per riga, cosi che il confronto
-- con la trascrizione si faccia guardando e non ricostruendo.

insert into credito_formativo
  (ruolo_posseduto, corso_posseduto, ruolo_creditato, corso_creditato, credito, fonte, nota) values

  -- ---------- RSPP (moduli A + B + C) ----------
  ('rspp', null, 'rls',           null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('rspp', null, 'datore_lavoro', null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('rspp', null, 'lavoratore',    'LAV_GEN',  'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('rspp', null, 'lavoratore',    'LAV_SPEC', 'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('rspp', null, 'dirigente',     null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('rspp', null, 'preposto',      null,       'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),

  -- ---------- ASPP (moduli A + B) ----------
  -- Riga identica a quella dell'RSPP in tutte e sei le colonne. **Entra lo stesso**:
  -- l'identita di oggi e un fatto della pagina, non una regola, e fonderle
  -- costringerebbe a disfare la fusione il giorno in cui l'allegato le separa.
  ('aspp', null, 'rls',           null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('aspp', null, 'datore_lavoro', null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('aspp', null, 'lavoratore',    'LAV_GEN',  'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('aspp', null, 'lavoratore',    'LAV_SPEC', 'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('aspp', null, 'dirigente',     null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('aspp', null, 'preposto',      null,       'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),

  -- ---------- Coordinatore per la sicurezza (CSP/CSE) ----------
  -- **Sei righe che oggi non possono accendersi**, e restano: nel catalogo non c'e
  -- nessun corso CSP/CSE, quindi `corso_assolve` non ha una riga per questo ruolo e
  -- nessun attestato potra mai provare il possesso. Non e una svista ed e lo stesso
  -- limite che AppFormazione ha dichiarato lasciandole fuori. La differenza e che
  -- qui il **ruolo** esiste dalla `0002`, quindi la riga si puo scrivere — e una
  -- riga inerte che cita la pagina e meglio di un vuoto che fra sei mesi qualcuno
  -- leggera come «il coordinatore non da credito».
  ('coordinatore_sicurezza', null, 'rls',           null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130',
   'Inerte finche il catalogo non ha un corso CSP/CSE: nessun attestato puo provare il possesso.'),
  ('coordinatore_sicurezza', null, 'datore_lavoro', null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('coordinatore_sicurezza', null, 'lavoratore',    'LAV_GEN',  'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('coordinatore_sicurezza', null, 'lavoratore',    'LAV_SPEC', 'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('coordinatore_sicurezza', null, 'dirigente',     null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('coordinatore_sicurezza', null, 'preposto',      null,       'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),

  -- ---------- DL-RSPP (art. 34) ----------
  -- **La riga per cui questa migrazione esiste.** La seconda casella e quella delle
  -- sette persone: chi ha fatto l'art. 34 ha credito totale sull'art. 37.
  ('datore_lavoro_rspp', null, 'rls',           null,       'frequenza',             'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('datore_lavoro_rspp', null, 'datore_lavoro', null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130',
   'La casella che scioglie il doppio obbligo delle sette righe che la `0007` risolve due volte: due ruoli, un percorso.'),
  ('datore_lavoro_rspp', null, 'lavoratore',    'LAV_GEN',  'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('datore_lavoro_rspp', null, 'lavoratore',    'LAV_SPEC', 'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('datore_lavoro_rspp', null, 'dirigente',     null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('datore_lavoro_rspp', null, 'preposto',      null,       'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),

  -- ---------- DL (art. 37) ----------
  -- Cinque righe: la colonna DL e una barra, ed e la casella che la fusione della
  -- `0027` doveva perdere.
  ('datore_lavoro', null, 'rls',        null,       'frequenza',             'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('datore_lavoro', null, 'lavoratore', 'LAV_GEN',  'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('datore_lavoro', null, 'lavoratore', 'LAV_SPEC', 'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('datore_lavoro', null, 'dirigente',  null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('datore_lavoro', null, 'preposto',   null,       'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),

  -- ---------- RLS ----------
  -- **L'unica riga in cui i due lavoratori si separano**, ed e la riga che ha
  -- deciso la forma di questa tabella: totale sulla generale, frequenza sulla
  -- specifica. Ha un senso che si puo dire: la parte specifica dipende dai rischi
  -- della mansione, e il corso RLS non li copre.
  ('rls', null, 'datore_lavoro', null,       'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('rls', null, 'lavoratore',    'LAV_GEN',  'totale',    'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('rls', null, 'lavoratore',    'LAV_SPEC', 'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130',
   'La sola casella della pagina in cui la generale e la specifica prendono valori diversi.'),
  ('rls', null, 'dirigente',     null,       'totale',    'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('rls', null, 'preposto',      null,       'totale',    'ASR 17/04/2025, Allegato III, pag. 130',
   'Totale **senza** asterisco: e l''unico credito verso il preposto che non chiede la medesima azienda.'),

  -- ---------- LAVORATORE, formazione generale ----------
  ('lavoratore', 'LAV_GEN', 'rls',           null,       'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('lavoratore', 'LAV_GEN', 'datore_lavoro', null,       'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('lavoratore', 'LAV_GEN', 'lavoratore',    'LAV_SPEC', 'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('lavoratore', 'LAV_GEN', 'dirigente',     null,       'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('lavoratore', 'LAV_GEN', 'preposto',      null,       'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),

  -- ---------- LAVORATORE, formazione specifica ----------
  -- **Quattro e non cinque, e la quinta non e una dimenticanza mia.** Nella casella
  -- specifica -> generale l'allegato scrive una **barra**, non FREQUENZA: tratta le
  -- due parti come la stessa formazione ai fini della diagonale, pur tenendole
  -- separate come colonne. E cio che la pagina fa, e non e cio che ci si aspetta:
  -- resta scritto qui perche la prossima rilettura non lo prenda per un buco.
  ('lavoratore', 'LAV_SPEC', 'rls',           null, 'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('lavoratore', 'LAV_SPEC', 'datore_lavoro', null, 'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('lavoratore', 'LAV_SPEC', 'dirigente',     null, 'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('lavoratore', 'LAV_SPEC', 'preposto',      null, 'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),

  -- ---------- DIRIGENTE ----------
  ('dirigente', null, 'rls',           null,       'frequenza',             'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('dirigente', null, 'datore_lavoro', null,       'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('dirigente', null, 'lavoratore',    'LAV_GEN',  'totale',                'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('dirigente', null, 'lavoratore',    'LAV_SPEC', 'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('dirigente', null, 'preposto',      null,       'totale_stessa_azienda', 'ASR 17/04/2025, Allegato III, pag. 130', null),

  -- ---------- PREPOSTO ----------
  -- **Tutta la riga e frequenza**, ed e la cosa meno ovvia della pagina: il corso da
  -- preposto non esonera dalla formazione lavoratori, ne generale ne specifica. La
  -- FAQ della Regione del Veneto dice il contrario del contrario — per **accedere**
  -- al corso da preposto la formazione lavoratori e propedeutica — quindi chi ha il
  -- preposto e non ha il lavoratore non e un caso di credito: **e un'anomalia**, e
  -- il motore deve poterla dire.
  ('preposto', null, 'rls',           null,       'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('preposto', null, 'datore_lavoro', null,       'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('preposto', null, 'lavoratore',    'LAV_GEN',  'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('preposto', null, 'lavoratore',    'LAV_SPEC', 'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null),
  ('preposto', null, 'dirigente',     null,       'frequenza', 'ASR 17/04/2025, Allegato III, pag. 130', null);

-- ============================================================================
--  COSA QUESTA MIGRAZIONE NON PORTA, E NON PER DIMENTICANZA
-- ============================================================================
--
-- **Pagine 127-129, i crediti verso i percorsi lunghi** (CSP/CSE, DL-RSPP modulo
-- comune e integrativi, RSPP moduli A+B+C). La quasi totalita e **PARZIALE**, e
-- l'allegato la quantifica in ore: «RSPP con Modulo A — PARZIALE. Credito: Modulo
-- giuridico 28 ore. Necessaria frequenza: Modulo tecnico 52 ore…». Un credito
-- parziale vuole un modello a ore che questo schema non ha, e scriverlo come
-- `totale` sarebbe **esattamente** il difetto che questa tabella esiste per
-- chiudere, nel verso opposto.
--
-- **Pagina 131, cantieri e ambienti confinati e attrezzature.** Una cosa di quella
-- pagina va detta perche e un'assenza che sembra un buco: la colonna «Operatore
-- attrezzature di lavoro» e **FREQUENZA su ogni riga** — nessuna formazione da
-- credito per le abilitazioni dell'art. 73. Quindi le dodici attrezzature di
-- `ruolo_sicurezza` non compaiono qui **per lettura**, non per dimenticanza.
--
-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from credito_formativo;                                 -- 53
--   select credito, count(*) from credito_formativo group by 1 order by 1;
--         frequenza 19 · totale 22 · totale_stessa_azienda 12
--   select ruolo_posseduto, coalesce(corso_posseduto,'-'), count(*)
--     from credito_formativo group by 1,2 order by 1,2;
--         aspp 6 · coordinatore_sicurezza 6 · datore_lavoro 5 ·
--         datore_lavoro_rspp 6 · dirigente 5 · lavoratore/LAV_GEN 5 ·
--         lavoratore/LAV_SPEC 4 · preposto 5 · rls 5 · rspp 6
--
-- **Dieci voci in riga e 53 caselle: 60 meno le 7 barre.** Il conto per voce e piu
-- utile del totale, perche e quello che si rompe se una riga viene copiata male: un
-- totale giusto con due caselle scambiate di riga resta giusto.
--
-- ---------- il conto che NON e un vincolo, e va girato con gli altri ----------
--
-- Un `corso_creditato` valorizzato deve essere un corso che quel ruolo assolve
-- davvero. Un `check` non puo vederlo — e una condizione **fra tabelle**, e
-- `corso_assolve` non ha una chiave su cui appoggiare una foreign key composta,
-- perche la sua unicita e su un `coalesce` — quindi resta un conto:
--
--   select k.ruolo_creditato, k.corso_creditato from credito_formativo k
--    where k.corso_creditato is not null
--      and not exists (select 1 from corso_assolve a
--                       where a.ruolo = k.ruolo_creditato
--                         and a.corso_codice = k.corso_creditato);   -- 0 righe
--
--   -- e lo stesso sul lato posseduto
--   select k.ruolo_posseduto, k.corso_posseduto from credito_formativo k
--    where k.corso_posseduto is not null
--      and not exists (select 1 from corso_assolve a
--                       where a.ruolo = k.ruolo_posseduto
--                         and a.corso_codice = k.corso_posseduto);   -- 0 righe
--
-- ---------- e il conto che dice quante righe sono inerti, oggi ----------
--
-- Una riga di credito serve solo se il possesso si puo provare, cioe se quel ruolo
-- ha almeno un corso in `corso_assolve`. Oggi non e vero per il coordinatore:
--
--   select distinct k.ruolo_posseduto from credito_formativo k
--    where not exists (select 1 from corso_assolve a where a.ruolo = k.ruolo_posseduto);
--         -- 1 riga: coordinatore_sicurezza (6 caselle inerti su 53)
--
-- **Il giorno in cui torna vuoto, il catalogo ha imparato il CSP/CSE** — e il
-- giorno in cui torna con un nome in piu, qualcuno ha tolto righe da
-- `corso_assolve` senza guardare qui.
--
-- ============================================================================
--  LA SECONDA LETTURA, E IL SUO ESITO
-- ============================================================================
--
-- Promesso in testa a questo file: il confronto con la `0027` di AppFormazione e
-- un conto, non una premessa. Fatto traducendo i loro codici nei miei — le tre
-- fusioni che loro dichiarano — e confrontando **casella per casella**, non con
-- un'impronta: un digest dice *se* due cose differiscono e non *in cosa* (A11).
--
--   caselle loro 35 · caselle mie 53
--   confrontabili dopo la traduzione                  41
--   **divergenze                                       0**
--   caselle loro che qui mancano                       0
--   caselle che ho io e loro no                       12
--
-- Le 41 confrontabili sono 35 piu 6, perche la loro riga `rspp_aspp` si apre in due
-- righe mie e vanno verificate entrambe.
--
-- **E le dodici in piu sono esattamente le tre fusioni, contate:** 6 del
-- coordinatore, 5 del DL dell'art. 37 come formazione posseduta, e **1 che e la
-- casella per cui questa migrazione esiste** — `datore_lavoro_rspp -> datore_lavoro
-- = totale`, quella che la fusione DL-RSPP/DL doveva perdere e che loro avevano
-- dichiarato di perdere. Le tre differenze non sono letture diverse della pagina:
-- sono un catalogo piu largo. **Sulla pagina, due letture indipendenti, zero
-- disaccordi.**
--
-- ---------- dove e stato provato ----------
--
-- Le `0001` -> `0009` caricate in ordine su **PostgreSQL 16** in un container usa e
-- getta (`postgres:16`, immagine gia in locale, auth `trust`, cancellato a fine
-- lavoro): nessuna credenziale di nessuno, niente che tocchi la produzione. Lo
-- scheletro Supabase che il cluster nudo non ha — i ruoli `anon`, `authenticated`,
-- `service_role` e le due funzioni di `auth` — e stato creato come impalcatura
-- prima del carico, e non fa parte di nessuna migrazione.
--
-- Tutti i conti di questo file sono **girati li e riportati da li**: 53 totali,
-- 19 `frequenza` / 22 `totale` / 12 `totale_stessa_azienda`, i dieci conti per voce,
-- i due controlli su `corso_assolve` a zero righe, e il coordinatore come unica voce
-- inerte. Nessuno di questi numeri e stato contato a mano sul file.
