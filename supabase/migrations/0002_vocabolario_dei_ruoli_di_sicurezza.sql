-- AppOverall — 0002
-- Il vocabolario dei ruoli di sicurezza, e la separazione fra l'art. 34 e l'art. 32.
--
-- La 0001 ha chiuso il PILASTRO 03 per meta: i **ruoli applicativi** — chi usa il
-- sistema — hanno una tabella e una chiave esterna. I **ruoli di sicurezza** — chi
-- sta nell'organigramma — no: `nomina.ruolo` e rimasto `text` libero, senza
-- vocabolario e senza vincolo. Questa migrazione chiude l'altra meta, e va prima
-- della migrazione dati: ogni riga che entra su una colonna senza vincolo e una
-- riga da riverificare a mano dopo.
--
-- ---------- perche non e pulizia ----------
--
-- Misurato il 9 settembre 2026: **28 nomine RSPP** caricate, **14 persone** con il
-- corso professionale, sovrapposizione **zero**. Una disgiunzione perfetta non e
-- mai un caso — era una colonna mappata male, e **26 delle 28** erano datori di
-- lavoro che svolgono in proprio i compiti di RSPP. Il riscontro sull'export lo
-- conferma a valle e senza database: 39 righe della famiglia RSPP su 33 persone
-- distinte, di cui **26 «AGGIORNAMENTO DATORE DI LAVORO CHE SVOLGE I COMPITI DI
-- RSPP»** e **7** moduli A/B/C professionali. I certificati c'erano: era la nomina
-- a puntare al ruolo sbagliato.
--
-- Sono due figure, due percorsi e due scadenze:
--
--   art. 34  il datore che assume l'incarico in proprio — percorso abilitante,
--            aggiornamento a cinque anni, decadenza a dieci
--   art. 32  l'RSPP professionale — moduli A/B/C, monte ore nel quinquennio
--
-- Se il vocabolario non li separa, lo stesso errore si riscrive alla prima
-- migrazione dati, e stavolta con la provenienza che lo fa sembrare verificato.
--
-- ---------- si eredita, non si rifa ----------
--
-- La separazione esiste gia in AppFormazione (`ruoli`, migrazione 0036, piu 0040,
-- 0041 e 0053): 13 figure, 12 attrezzature, 9 attivita, ognuna con la sua norma.
-- Da li vengono le righe qui sotto, verbatim dove il testo reggeva.
--
-- **Lo stato ereditato e quello finale, non quello iniziale.** In mezzo c'e un
-- `update ruoli` — uno solo in tutta la storia di quel repo, la 0042 — e leggere
-- la 0036 senza applicarlo avrebbe riportato indietro un nome gia corretto. Il
-- controllo si rifa cosi: `grep -n "update ruoli" AppFormazione/supabase/migrations/*.sql`
-- deve restituire una riga sola, ed e riflessa qui.
--
-- Il campo ne aggiunge **due che la formazione non ha**, e non e una svista: sono
-- ruoli dell'organigramma che non generano un obbligo formativo dell'accordo,
-- quindi in un catalogo corsi non avevano motivo di esistere. Entrano perche qui
-- l'organigramma e un'entita, non un derivato del catalogo:
--
--   medico_competente     art. 38 — si registra la nomina, non un percorso
--   datore_lavoro_art16   il delegato, che assume gli obblighi del datore
--
-- Totale: **15 figure, 12 attrezzature, 9 attivita**.

-- ============================================================================
--  Il vocabolario
-- ============================================================================
--
-- Una tabella e non un enum, per la stessa ragione della 0001: un enum si altera
-- con una migrazione, un vocabolario cresce con una riga. La chiave e il `codice`
-- e non un uuid, perche questa tabella si legge nelle migrazioni dati e nelle
-- query a mano, dove un uuid costringe a una join per capire cosa c'e scritto.

create table ruolo_sicurezza (
  codice text primary key,
  nome text not null,
  tipo text not null
    constraint ruolo_sicurezza_tipo_noto check (tipo in ('figura', 'attrezzatura', 'attivita')),
  -- La norma sta sulla riga e non in un commento: e cio che permette di dire
  -- **perche** due codici che si somigliano sono due codici. `not null` perche
  -- un ruolo di sicurezza senza norma non e un ruolo di sicurezza — nella fonte
  -- era nullable, qui no, ed e l'unico punto in cui il vincolo si alza.
  norma text not null,
  -- Alcuni ruoli non si chiedono: ce li ha chiunque abbia un rapporto di lavoro.
  vale_per_tutti boolean not null default false,
  note text
);

comment on table ruolo_sicurezza is
  'Il vocabolario dei ruoli dell''organigramma e delle mansioni che generano obblighi formativi: dice **quali** figure esistono, non ancora a chi vanno chieste. Da non confondere con `ruolo_applicativo`, che dice chi usa il sistema — questa dice chi e nominato presso il cliente.';
comment on column ruolo_sicurezza.tipo is
  'figura = ruolo dell''organigramma della sicurezza; attrezzatura = abilitazione alla conduzione (art. 73 c. 5); attivita = lavorazione che genera un obbligo suo.';
comment on column ruolo_sicurezza.norma is
  'Parte e articolo da cui il ruolo esiste. Su `datore_lavoro_rspp` e `rspp` e la colonna che tiene separate le due figure confuse su 26 nomine, e per questo non e decorativa.';

-- ---------- cosa questa tabella non porta, e non per dimenticanza ----------
--
-- Due cose esistono nelle fonti e qui non entrano. Restano scritte perche una
-- rinuncia taciuta si scopre in migrazione dati, quando costa.
--
-- **1. Quando una figura va chiesta.** L'organigramma del campo distingue una
-- figura sempre dovuta da una condizionale (il medico competente, solo dove il
-- DVR prevede sorveglianza sanitaria) e da una eventuale (il delegato dell'art.
-- 16, solo se la delega esiste) — colonne `obbligo` e `macro` di
-- `figura_sicurezza`, scritte e riscritte in tre migrazioni. Qui non entrano
-- perche il valore esiste per 13 codici su 36 e assegnarlo agli altri 23 sarebbe
-- inventarlo. Entrano quando entra la scheda di ingresso, che e chi le usa.
--
-- **2. Che un ruolo ne copra un altro.** Nel campo `dl_rspp` **copre** `rspp` e
-- **implica** `datore_lavoro`: l'organigramma nasconde l'RSPP scoperto se il
-- datore lo svolge in proprio, e c'e un caso vero in cui la stessa persona ha
-- richiesto **due** nomine invece di una. Qui l'alias e uno a uno, quindi la
-- migrazione dati trovera persone con una nomina e persone con due, e questa
-- tabella non dice quale sia la forma canonica. Va deciso prima dell'import, e
-- va deciso come dato — una tabella di copertura — non dentro un import: e la
-- stessa ambiguita da cui sono nate le 26 nomine sbagliate.

-- ---------- le figure ----------

insert into ruolo_sicurezza (codice, nome, tipo, norma, vale_per_tutti, note) values
  ('lavoratore', 'Lavoratore', 'figura', 'D.Lgs. 81/2008 art. 37 c. 1', true,
   'Non si chiede: ce l''ha chiunque abbia un rapporto di lavoro.'),
  ('preposto', 'Preposto', 'figura', 'D.Lgs. 81/2008 art. 19 e art. 37 c. 7-ter', false,
   'Anche il preposto di fatto, che l''accordo nomina espressamente.'),
  ('dirigente', 'Dirigente', 'figura', 'D.Lgs. 81/2008 art. 37 c. 7', false, null),
  ('datore_lavoro', 'Datore di lavoro', 'figura', 'D.Lgs. 81/2008 art. 37 c. 7; legge 215/2021', false,
   'Negli export del gestionale c''e una colonna «Datore di lavoro» col nome della persona: e l''unico ruolo gia ricavabile dai dati, su 141 clienti su 480.'),
  ('datore_lavoro_art16', 'Datore di lavoro delegato (ex art. 16)', 'figura', 'D.Lgs. 81/2008 art. 16', false,
   'Il delegato assume gli obblighi del datore, formazione inclusa. Viene dall''organigramma del campo, che ne memorizza anche gli estremi della procura: la delega e un atto, e senza quegli estremi non e opponibile.'),
  ('datore_lavoro_rspp', 'Datore di lavoro che svolge i compiti di RSPP', 'figura', 'D.Lgs. 81/2008 art. 34', false,
   '**Non e un RSPP.** E il datore che assume l''incarico in proprio: percorso abilitante, aggiornamento quinquennale, decadenza a dieci anni con l''ASR 2025. Nel campo lo stesso ruolo si chiama `dl_rspp`, e l''alias sta in `ruolo_sicurezza_alias` perche l''import non debba indovinarlo.'),
  ('rspp', 'Responsabile del servizio di prevenzione e protezione', 'figura', 'D.Lgs. 81/2008 art. 32', false,
   '**Non e il datore dell''art. 34.** Moduli A/B/C, e l''aggiornamento e un monte ore nel quinquennio invece di una scadenza. Spesso esterno: va chiesto se sia interno prima di aspettarselo fra i dipendenti.'),
  ('aspp', 'Addetto al servizio di prevenzione e protezione', 'figura', 'D.Lgs. 81/2008 art. 32', false, null),
  ('rls', 'Rappresentante dei lavoratori per la sicurezza', 'figura', 'D.Lgs. 81/2008 art. 37 c. 10 e 11', false, null),
  ('medico_competente', 'Medico competente', 'figura', 'D.Lgs. 81/2008 art. 38', false,
   'Non ha un percorso formativo di sicurezza: e una specializzazione, e si registra la **nomina**. Obbligo condizionale, solo dove il DVR prevede sorveglianza sanitaria. Viene dall''organigramma del campo: in un catalogo corsi non poteva esserci.'),
  ('addetto_antincendio', 'Addetto alla prevenzione incendi e gestione emergenze', 'figura', 'D.Lgs. 81/2008 art. 46; DM 2 settembre 2021', false, null),
  ('addetto_primo_soccorso', 'Addetto al primo soccorso', 'figura', 'D.Lgs. 81/2008 art. 45; DM 388/2003', false, null),
  ('addetto_blsd', 'Addetto all''uso del defibrillatore', 'figura', 'Legge 4 agosto 2021 n. 116', false,
   'Non e formazione dell''art. 45 e non sostituisce l''addetto al primo soccorso.'),
  ('coordinatore_sicurezza', 'Coordinatore per la sicurezza (CSP/CSE)', 'figura', 'D.Lgs. 81/2008 art. 98 e allegato XIV', false,
   'Di solito un professionista esterno, come l''RSPP: nella scheda di ingresso va chiesto se sia interno.'),
  ('sorveglianza_funi', 'Sorveglia i lavori su funi come preposto', 'figura', 'D.Lgs. 81/2008 art. 116 c. 4; allegato XXI', false,
   'L''allegato lo chiama preposto e ne fa un modulo aggiuntivo: al corso accedono i lavoratori che hanno gia frequentato quello per operatori su funi.')
on conflict (codice) do nothing;

-- ---------- le attrezzature ----------
--
-- La grana e quella dell'accordo: una riga per attrezzatura, perche l'abilitazione
-- e per attrezzatura. Il campo ne tiene **una sola**, generica
-- (`operatore_attrezzatura`), ed e per questo che quel codice ha un alias senza
-- destinazione: una riga generica non si sa riscrivere in una specifica, e
-- indovinarla e esattamente la mossa da cui nasce questa migrazione.

insert into ruolo_sicurezza (codice, nome, tipo, norma, vale_per_tutti, note) values
  ('conduce_carrelli', 'Conduce carrelli elevatori semoventi', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null),
  ('conduce_ple', 'Conduce piattaforme di lavoro mobili elevabili', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null),
  ('conduce_gru_torre', 'Conduce gru a torre', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null),
  ('conduce_gru_autocarro', 'Conduce gru per autocarro', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null),
  ('conduce_gru_mobili', 'Conduce gru mobili', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null),
  ('conduce_movimento_terra', 'Conduce escavatori, pale caricatrici, terne e autoribaltabili a cingoli', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false,
   'Il nome porta quattro voci e non tre perche il punto 8.3.7 dell''ASR 2025 le nomina tutte: chi conduce solo autoribaltabili a cingoli, col nome corto, non si riconosceva nella riga. La correzione e della migrazione 0042 di AppFormazione, ed e l''unico `update ruoli` della sua storia — ereditare la 0036 senza la 0042 avrebbe riportato indietro il nome.'),
  ('conduce_trattori', 'Conduce trattori agricoli o forestali', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null),
  ('conduce_carroponte', 'Conduce carriponte o gru a cavalletto', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5; ASR 2025 punto 8.3.11', false,
   'Abilitante solo dall''ASR 2025. La gru a bandiera non rientra.'),
  ('conduce_transpallet', 'Conduce transpallet', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 4', false,
   'Fuori dai cataloghi dell''accordo: la formazione e dovuta, la periodicita la decide Overall.'),
  ('conduce_pompe_calcestruzzo', 'Conduce pompe per calcestruzzo', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null),
  ('conduce_raccoglifrutta', 'Conduce macchine agricole raccoglifrutta', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null),
  ('conduce_cmm', 'Conduce caricatori per la movimentazione di materiali', 'attrezzatura', 'D.Lgs. 81/2008 art. 73 c. 5', false, null)
on conflict (codice) do nothing;

-- ---------- le attivita ----------

insert into ruolo_sicurezza (codice, nome, tipo, norma, vale_per_tutti, note) values
  ('spazi_confinati', 'Opera in ambienti sospetti di inquinamento o confinati', 'attivita', 'DPR 177/2011', false, null),
  ('ponteggi', 'Monta, smonta o trasforma ponteggi', 'attivita', 'D.Lgs. 81/2008 art. 136 e allegato XXI', false, null),
  ('lavori_quota', 'Lavora in quota con DPI anticaduta di terza categoria', 'attivita', 'D.Lgs. 81/2008 artt. 77 e 111', false, null),
  ('lavori_funi', 'Opera con sistemi di accesso e posizionamento mediante funi', 'attivita', 'D.Lgs. 81/2008 art. 116; allegato XXI', false,
   'Non e il lavoro in quota con DPI anticaduta di terza categoria, che sta in `lavori_quota` e risponde all''art. 77: qui la fune e il mezzo di accesso e di posizionamento.'),
  ('rischio_elettrico', 'Esegue lavori elettrici (PES, PAV, PEI)', 'attivita', 'D.Lgs. 81/2008 art. 82; CEI 11-27', false, null),
  ('segnaletica_stradale', 'Posa segnaletica stradale in cantiere', 'attivita', 'DM 22 gennaio 2019', false,
   'Nomina il preposto ma non e l''obbligo preposto.'),
  ('diisocianati', 'Usa diisocianati', 'attivita', 'Regolamento UE 2020/1149', false, null),
  ('alimenti', 'Manipola alimenti', 'attivita', 'Reg. CE 852/2004', false, null),
  ('fitosanitari', 'Acquista o usa prodotti fitosanitari', 'attivita', 'D.Lgs. 150/2012', false, null)
on conflict (codice) do nothing;

-- ============================================================================
--  Gli alias: come i codici vecchi arrivano qui
-- ============================================================================
--
-- La mappatura fra i codici dei sistemi di partenza e questo vocabolario e **un
-- dato**, non una riga dentro un import. La differenza conta: se un codice
-- sconosciuto arriva e la mappa e in tabella, l'import si ferma e lo dice; se la
-- mappa e in un `switch`, qualcuno ci mette il caso mancante a mano — ed e cosi
-- che `dl_rspp` e diventato `rspp` su 26 righe.
--
-- Per ogni sistema che ha righe qui, l'elenco e **completo**: dice anche «di piu
-- di questo l'origine non sa emettere», e un codice fuori elenco e un dato nuovo,
-- non un refuso da normalizzare. Per questo ci sono anche gli alias identici a se
-- stessi.
--
-- **AppFormazione non ha righe, e non e una lacuna**: i codici qui sopra *sono* i
-- suoi, tolti i due che il campo aggiunge. Il suo elenco completo e il vocabolario
-- stesso, e duplicarlo qui creerebbe la seconda copia che tutto il repo esiste per
-- evitare. Il valore resta ammesso dal `check` perche il giorno in cui quel repo
-- emettesse un codice suo, la riga avrebbe dove stare.
--
-- Gli altri due sistemi ammessi: **`organigramma`**, che il piano dichiara
-- assorbito e che ha un vocabolario suo, e **`sicurweb`**, che oggi non emette
-- ruoli ma detta il calendario della Fase 4.

create table ruolo_sicurezza_alias (
  sistema text not null
    constraint alias_sistema_noto
    check (sistema in ('sopralluoghi', 'organigramma', 'formazione', 'sicurweb')),
  codice_esterno text not null,
  -- Nullable, e null vuol dire **«conosciuto e non mappabile»**, che e diverso da
  -- sconosciuto: la riga va guardata da qualcuno, non tradotta.
  ruolo text references ruolo_sicurezza(codice),
  note text,
  primary key (sistema, codice_esterno),
  -- Il null e una decisione e va motivato: senza questo vincolo «conosciuto e
  -- non mappabile» e indistinguibile da «non ancora tradotto», e la distinzione
  -- vivrebbe solo in un commento che nessun import legge.
  constraint alias_senza_destinazione_ha_un_motivo
    check (ruolo is not null or note is not null)
);

comment on table ruolo_sicurezza_alias is
  'Come i codici dei sistemi di partenza si leggono in questo vocabolario. E l''elenco completo di cio che ogni origine sa emettere: un codice che non c''e non si normalizza a mano, si scarta e si guarda.';
comment on column ruolo_sicurezza_alias.ruolo is
  'null non significa «non ancora tradotto»: significa «conosciuto e non traducibile da solo», come `operatore_attrezzatura`, che e una figura sola dove qui ce ne sono dodici.';

insert into ruolo_sicurezza_alias (sistema, codice_esterno, ruolo, note) values
  ('sopralluoghi', 'datore_lavoro',          'datore_lavoro',          null),
  ('sopralluoghi', 'datore_lavoro_art16',    'datore_lavoro_art16',    null),
  ('sopralluoghi', 'dl_rspp',                'datore_lavoro_rspp',
   'L''unico codice che cambia nome, ed e anche l''unico su cui si e sbagliato: 26 nomine finite su `rspp`, che e l''art. 32.'),
  ('sopralluoghi', 'rspp',                   'rspp',                   null),
  ('sopralluoghi', 'aspp',                   'aspp',                   null),
  ('sopralluoghi', 'dirigente',              'dirigente',              null),
  ('sopralluoghi', 'preposto',               'preposto',               null),
  ('sopralluoghi', 'lavoratore',             'lavoratore',             null),
  ('sopralluoghi', 'rls',                    'rls',                    null),
  ('sopralluoghi', 'medico_competente',      'medico_competente',      null),
  ('sopralluoghi', 'addetto_antincendio',    'addetto_antincendio',    null),
  ('sopralluoghi', 'addetto_primo_soccorso', 'addetto_primo_soccorso', null),
  ('sopralluoghi', 'operatore_attrezzatura', null,
   'Figura generica dell''art. 73 c. 5, senza dire quale attrezzatura. Qui le attrezzature sono dodici: quale sia lo dice l''attestato e non la nomina, e finche non lo si legge la riga resta da guardare.')
on conflict (sistema, codice_esterno) do nothing;

-- Il terzo vocabolario: `Organigramma-sicurezza`, che il piano dichiara assorbito
-- e non mantenuto. Sono 23 codici in camelCase dentro una costante JavaScript, e
-- **tutti e 23 trovano una figura qui** — nessuno resta fuori. Entrano perche
-- assorbire un'applicazione significa saper leggere cio che ha scritto: se il
-- giorno della migrazione questi codici non hanno una riga, qualcuno li tradurra
-- a mano, che e il modo in cui si e sbagliato la prima volta.
--
-- Da notare, perche vale piu di un alias: quel sistema scrive l'articolo **dentro
-- l'etichetta** — «Datore di lavoro–RSPP (art. 34)» — e tiene i due ruoli
-- mutuamente esclusivi per configurazione. La distinzione che qui va difesa con
-- una colonna, li era gia ovvia.

insert into ruolo_sicurezza_alias (sistema, codice_esterno, ruolo, note) values
  ('organigramma', 'datore',            'datore_lavoro',          null),
  ('organigramma', 'datoreRspp',        'datore_lavoro_rspp',     'Etichettato «Datore di lavoro–RSPP (art. 34)»: l''articolo e scritto nel nome.'),
  ('organigramma', 'dirigente',         'dirigente',              null),
  ('organigramma', 'preposto',          'preposto',               null),
  ('organigramma', 'rspp',              'rspp',                   null),
  ('organigramma', 'aspp',              'aspp',                   null),
  ('organigramma', 'mc',                'medico_competente',      null),
  ('organigramma', 'rls',               'rls',                    null),
  ('organigramma', 'lavoratore',        'lavoratore',             null),
  ('organigramma', 'antincendio',       'addetto_antincendio',    null),
  ('organigramma', 'primoSoccorso',     'addetto_primo_soccorso', null),
  ('organigramma', 'blsd',              'addetto_blsd',           null),
  ('organigramma', 'carrello',          'conduce_carrelli',       null),
  ('organigramma', 'ple',               'conduce_ple',            null),
  ('organigramma', 'trattori',          'conduce_trattori',       null),
  ('organigramma', 'escavatori',        'conduce_movimento_terra', 'Li chiama «Escavatori / mov. terra»: e la stessa voce del punto 8.3.7, col nome corto.'),
  ('organigramma', 'gruAutocarro',      'conduce_gru_autocarro',  null),
  ('organigramma', 'gruTorre',          'conduce_gru_torre',      null),
  ('organigramma', 'gruMobili',         'conduce_gru_mobili',     null),
  ('organigramma', 'carroponte',        'conduce_carroponte',     null),
  ('organigramma', 'lavoriQuota',       'lavori_quota',           null),
  ('organigramma', 'pesPavPei',         'rischio_elettrico',      'Li tiene per sigla (PES/PAV/PEI); qui il ruolo e nominato per attivita.'),
  ('organigramma', 'ambientiConfinati', 'spazi_confinati',        null)
on conflict (sistema, codice_esterno) do nothing;

-- ============================================================================
--  Il vincolo, che e il punto
-- ============================================================================
--
-- `nomina` e vuota: il vincolo non rompe niente adesso, e impedisce tutto dopo.

alter table nomina
  add constraint nomina_ruolo_noto foreign key (ruolo) references ruolo_sicurezza(codice);

-- Gli indici della 0001 hanno `ruolo` in seconda posizione, quindi non servono al
-- vincolo: senza questo, ogni tocco a una riga del vocabolario scandisce l'intera
-- `nomina`. Irrilevante oggi che e vuota, non dopo la migrazione dati.
create index on nomina (ruolo);

comment on column nomina.ruolo is
  'Il ruolo di sicurezza, dal vocabolario di `ruolo_sicurezza`. Dalla 0001 alla 0002 e stato testo libero, e in quella finestra non e entrata nessuna riga: la distinzione fra l''art. 34 e l''art. 32 vive nel vocabolario, e una stringa scritta a mano la cancella senza far rumore.';

-- ---------- dove atterrano gli estremi della procura ----------
--
-- `datore_lavoro_art16` entra come ruolo, e la sua nota dice che senza gli estremi
-- della procura la delega non e opponibile. Il campo quel dato ce l'ha, in una
-- colonna sua. Se non la si apre qui, il codice passa il vincolo e il suo unico
-- attributo distintivo viene scartato dall'import — e lo si scopre quando serve
-- esibire la delega, cioe troppo tardi.

alter table nomina add column estremi_procura text;

comment on column nomina.estremi_procura is
  'Repertorio, data e notaio della procura, per il datore delegato dell''art. 16. Vale solo per quel ruolo, e resta null per tutti gli altri: e il documento che rende la delega opponibile, non un campo di servizio.';

-- ============================================================================
--  Le viste e le policy
-- ============================================================================
--
-- Il vocabolario si legge, non si scrive: come `ruolo_applicativo`, cresce con una
-- migrazione. Nessuna policy di scrittura, e non e una dimenticanza — una figura
-- nuova porta con se una norma, e quella si cita in una riga di file, dove resta
-- nella storia, non in un campo compilato di fretta.

alter table ruolo_sicurezza       enable row level security;
alter table ruolo_sicurezza_alias enable row level security;

create policy leggono_gli_operatori on ruolo_sicurezza       for select to authenticated using (e_operatore());
create policy leggono_gli_operatori on ruolo_sicurezza_alias for select to authenticated using (e_operatore());

-- `security_invoker` non e un dettaglio, ed e il motivo per cui e scritto qui e
-- non lasciato al default. Una vista in PostgreSQL esegue con i diritti del
-- **proprietario**, e il proprietario e chi applica le migrazioni: le RLS delle
-- tabelle sotto vengono valutate su di lui e quindi **non si applicano affatto**.
-- Con il PILASTRO 01 — l'applicazione legge solo viste — questo significa che il
-- PILASTRO 02 sarebbe scavalcato da tutte e due i lati: policy scritte bene,
-- lette da nessuno. Con `security_invoker` la policy si valuta su chi interroga,
-- che e quello che il criterio di uscita della Fase 3 chiede a parole.
--
-- **Le quattro viste della 0001 non ce l'hanno.** `v_organigramma` la riscrivo qui
-- sotto e quindi la sistemo, ma `v_cliente`, `v_sede` e `v_valutazione_sede`
-- restano com'erano: mostrano tutto a qualunque utente autenticato, operatore o
-- no. Non le tocco in questa migrazione, che parla d'altro — ma vanno chiuse
-- prima che entri il primo dato, ed e una riga per vista.

create view v_ruolo_sicurezza with (security_invoker = true) as
select r.codice, r.nome, r.tipo, r.norma, r.vale_per_tutti, r.note
  from ruolo_sicurezza r;

-- Anche gli alias hanno la loro vista, e non e simmetria: la tesi di questa
-- migrazione e che l'import legga la mappa **dalla tabella** e si fermi sul codice
-- che non c'e. Un import che gira come un operatore qualunque, senza vista e senza
-- grant, non vedrebbe nessuna riga — quindi non si fermerebbe: scarterebbe tutto,
-- in silenzio, che e il contrario di cio che il file dichiara.
create view v_ruolo_sicurezza_alias with (security_invoker = true) as
select a.sistema, a.codice_esterno, a.ruolo, a.note
  from ruolo_sicurezza_alias a;

-- L'organigramma mostrava il codice. Adesso porta anche il nome, il tipo e la
-- norma, cosi l'applicazione non tiene una seconda copia delle etichette — che e
-- il modo in cui i due vocabolari di partenza hanno finito per divergere.
create or replace view v_organigramma with (security_invoker = true) as
select n.id, n.cliente_id, c.ragione_sociale, n.sede_id, s.denominazione as sede,
       n.persona_id, p.cognome, p.nome, p.codice_fiscale,
       n.ruolo, n.data_nomina, n.updated_at,
       r.nome as ruolo_nome, r.tipo as ruolo_tipo, r.norma as ruolo_norma
  from nomina n
  join cliente c on c.id = n.cliente_id
  join persona p on p.id = n.persona_id
  join ruolo_sicurezza r on r.codice = n.ruolo
  left join sede s on s.id = n.sede_id
 where n.data_cessazione is null;

-- I `grant`, che con `security_invoker` non sono una formalita.
--
-- Una vista `security_invoker` verifica **privilegi e** RLS sull'invocante: senza
-- `select` sulle tabelle sotto, la vista risponde «permission denied» invece che
-- una riga in meno. La 0001 non concede niente sulle tabelle e concede solo le sue
-- quattro viste: funziona perche i default privileges dell'istanza Supabase hanno
-- gia dato tutto a `authenticated` — cioe **dipende da uno stato che il repo non
-- dichiara**. Qui si dichiara.
--
-- E va detto cosa questo significa per il PILASTRO 01: se le tabelle sono
-- leggibili, «l'applicazione non nomina mai una tabella» resta una **disciplina**,
-- non un vincolo. Non e un cedimento: l'isolamento non lo fa la vista, lo fanno le
-- RLS, e con `security_invoker` le RLS si applicano identiche per la vista e per la
-- tabella. La vista serve a poter spostare una tabella senza rompere il client.

grant select on ruolo_sicurezza, ruolo_sicurezza_alias to authenticated;
grant select on nomina, cliente, persona, sede to authenticated;

grant select on v_ruolo_sicurezza, v_ruolo_sicurezza_alias to authenticated;
