-- AppOverall — 0010
-- Il fatto piu azionabile che il testo libero abbia prodotto, e che si fermava li.
--
-- ============================================================================
--  IL RILIEVO, E PERCHE NON L'HO CHIUSO CON LA 0007
-- ============================================================================
--
-- Terzo dei sei rilievi con cui AppFormazione ha letto la `0007` prima del carico,
-- e l'unico rimasto aperto dopo la `0009`:
--
--   «`posizione = 'esterno'` e il fatto piu azionabile che il testo libero abbia
--    prodotto, quello che la colonna non poteva dire: un RSPP esterno **non e un
--    dipendente**, e la sua formazione **non e a carico di quell'azienda**. E si
--    ferma in `ruolo_testo`: **non viaggia con la nomina**.»
--
-- La `0007` ha fatto bene meta del lavoro. `ruolo_testo.posizione` registra cosa
-- la frase dice della **persona** — «RSPP/titolare», «RSPP ESTERNO» — e quella
-- colonna e cio che decide fra l'art. 32 e l'art. 34, che e la distinzione da cui
-- sono nate le 26 nomine sbagliate. Ma la `0007` si ferma al **dizionario**: dopo
-- l'import, la nomina porta il ruolo giusto e **la frase non c'e piu**.
--
-- E il ruolo non basta a ricostruirla, perche i due fatti sono indipendenti.
-- `rspp` + `titolare` e `rspp` + `esterno` producono **la stessa nomina** e sono
-- due situazioni diverse: nella prima quella persona e un dipendente da formare,
-- nella seconda e un professionista di cui l'azienda **non deve** la formazione.
-- Un motore che le confonde non sbaglia per eccesso: **chiede un corso a
-- un'azienda che non lo deve**, e lo chiede con l'aria di essere in regola.
--
-- ============================================================================
--  PERCHE UN VOCABOLARIO E NON UNA SECONDA COPIA DELLA LISTA
-- ============================================================================
--
-- La mossa corta era un `check` su `nomina` con gli stessi sei valori del `check`
-- della `0007`. **Sarebbe stata la seconda copia della stessa lista**, ed e la
-- forma di difetto che questo progetto ha gia pagato tre volte — `ateco.ts`, il
-- dizionario dei 268 alias, `ateco_rischio` — sempre allo stesso modo: le due copie
-- restano uguali finche qualcuno ne tocca una.
--
-- Quindi il vocabolario diventa una tabella e le due colonne ci puntano. E la
-- stessa scelta della `0002` — «una tabella e non un enum: un enum si altera con
-- una migrazione, un vocabolario cresce con una riga» — applicata alla lista che
-- la `0007` aveva lasciato dentro un vincolo.
--
-- **Non aggiunge un posto: ne toglie uno.** Dopo questa migrazione i sei valori
-- stanno in un punto solo, e le due colonne che li usano lo dicono con una foreign
-- key invece che con due elenchi identici.

create table posizione_persona (
  codice text primary key,
  nome text not null,
  -- Cosa la frase **asserisce** della persona. Serve a non rileggere un'astensione
  -- come una negazione: `socio` non dice che non sia il datore, dice che non lo
  -- stabilisce. Sono due ignoranze diverse e vanno tenute separate.
  asserisce text not null,
  -- Se questo valore cambia una risposta del motore, oggi. Uno solo lo fa, ed e
  -- scritto qui perche chi legge la tabella sappia dove guardare.
  cambia_l_esito boolean not null default false,
  note text
);

comment on table posizione_persona is
  'Cosa la frase scritta a mano dice della **persona**, non dell''incarico: il secondo dei due fatti che le 29 forme del campo «mansione» asseriscono. Era un `check` dentro la `0007` e diventa un vocabolario quando serve a due colonne — `ruolo_testo.posizione`, che lo registra, e `nomina.posizione`, che lo porta con se dopo l''import.';
comment on column posizione_persona.cambia_l_esito is
  'Oggi vale solo per `esterno`, e non e una previsione: e la misura di cosa il motore sa farci. Un esterno non e un dipendente e la sua formazione non e a carico di quell''azienda; gli altri cinque valori spiegano **da dove viene** il ruolo assegnato, e il ruolo lo porta gia.';

insert into posizione_persona (codice, nome, asserisce, cambia_l_esito, note) values
  ('datore',         'Datore di lavoro',
   'La frase lo dice con quelle parole: «Datore di Lavoro», «DL».', false, null),
  ('titolare',       'Titolare o amministratore',
   'Chi e titolare e il datore.', false, null),
  ('socio',          'Socio, e basta',
   'NON stabilisce che sia il datore: e un''astensione, non una negazione.', false,
   'La `0007` si astiene su questo valore, e l''asimmetria con `esterno` — che invece risolve — e voluta: le due ignoranze sono diverse.'),
  ('non_titolare',   'Dichiarato non titolare',
   'La frase lo nega: «RSPP- NO TITOLARE».', false, null),
  ('esterno',        'Esterno all''azienda',
   'La persona non e un dipendente di quell''azienda: «RSPP ESTERNO».', true,
   '**L''unico valore che cambia una risposta.** La formazione di un RSPP esterno non e a carico del cliente presso cui svolge l''incarico: senza questa riga il motore gliela chiede.'),
  ('non_dichiarato', 'La frase non ne parla',
   'Il testo c''era e non diceva niente della posizione.', false,
   'Diverso dal `null` di `nomina.posizione`, che vuol dire che la nomina non viene da un testo libero. Le due assenze non si confondono.');

alter table posizione_persona enable row level security;
create policy leggono_gli_operatori on posizione_persona for select to authenticated using (e_operatore());
create policy scrive_amministrazione on posizione_persona for all to authenticated
  using (livello_operatore() >= 4) with check (livello_operatore() >= 4);
grant select on posizione_persona to authenticated;

-- ---------- la lista esce dal vincolo della 0007 ----------
--
-- Il `check` viene sostituito da una foreign key sullo stesso insieme di valori.
-- Non e un allentamento: una foreign key su un vocabolario e piu forte di un
-- `check`, perche il vocabolario porta anche **cosa significa** ciascun valore, e
-- un valore nuovo entra con la sua riga invece che con un `alter`.
--
-- Se i sei codici qui sopra non coprissero cio che sta gia in `ruolo_testo`, la
-- foreign key fallirebbe **al carico** — che e esattamente il controllo che serve.

alter table ruolo_testo drop constraint posizione_nota;
alter table ruolo_testo
  add constraint ruolo_testo_posizione_nota
    foreign key (posizione) references posizione_persona(codice);

-- E il terzo posto, che cercandolo e venuto fuori da solo: `ruolo_da_parola
-- .posizione` non aveva **nessun** vincolo — ne un `check` ne una foreign key.
-- Nullable a ragione, perche li null vuol dire «per quell'incarico la posizione non
-- discrimina», ma sui valori scritti non c'era niente: una posizione inventata o un
-- refuso sarebbero entrati **in silenzio**, e la regola avrebbe smesso di agganciare
-- senza che nessun conto lo dicesse. Una foreign key nullable dice tutte e due le
-- cose — «puo mancare» e «se c'e, e una di queste sei».

alter table ruolo_da_parola
  add constraint ruolo_da_parola_posizione_nota
    foreign key (posizione) references posizione_persona(codice);

-- ---------- e la nomina la porta con se ----------
--
-- Stessa forma di `estremi_procura` nella `0002`, e per la stessa ragione scritta
-- li: «se non la si apre qui, il codice passa il vincolo e il suo unico attributo
-- distintivo viene scartato dall'import — e lo si scopre quando serve, cioe troppo
-- tardi». Quella colonna serviva alla delega dell'art. 16; questa serve a non
-- chiedere un corso a chi non lo deve.

alter table nomina add column posizione text references posizione_persona(codice);

comment on column nomina.posizione is
  'Cosa diceva della persona la frase da cui questa nomina e stata ricavata. **Null non e `non_dichiarato`**: null vuol dire che la nomina non viene da un testo libero — per esempio dalle colonne del foglio «Ruoli SSL», che la posizione non la portano in nessuno dei loro casi — mentre `non_dichiarato` vuol dire che il testo c''era e non ne parlava. Un import che scrivesse `non_dichiarato` al posto di null direbbe di aver letto una frase che non ha mai avuto.';

create index on nomina (posizione) where posizione is not null;

-- ---------- e si vede, perche l'applicazione non nomina una tabella ----------
--
-- PILASTRO 01: l'applicazione legge solo viste. Una colonna che non entra in una
-- vista e, dal lato di chi la deve usare, **una colonna che non esiste** — e
-- questa migrazione sarebbe meta lavoro come lo era la `0007`.
--
-- Con `posizione` entra anche `estremi_procura`, che la `0002` ha aggiunto a
-- `nomina` e non ha mai messo in vista: e lo stesso difetto, nello stesso posto, e
-- si chiude con la stessa riga. Correggerne una e lasciare l'altra a due righe di
-- distanza e il modo in cui i difetti si ripresentano — «un posto in piu dove la
-- stessa regola non era applicata».

create or replace view v_organigramma with (security_invoker = true) as
select n.id, n.cliente_id, c.ragione_sociale, n.sede_id, s.denominazione as sede,
       n.persona_id, p.cognome, p.nome, p.codice_fiscale,
       n.ruolo, n.data_nomina, n.updated_at,
       r.nome as ruolo_nome, r.tipo as ruolo_tipo, r.norma as ruolo_norma,
       n.posizione, pp.nome as posizione_nome, pp.cambia_l_esito as posizione_cambia_l_esito,
       n.estremi_procura
  from nomina n
  join cliente c on c.id = n.cliente_id
  join persona p on p.id = n.persona_id
  join ruolo_sicurezza r on r.codice = n.ruolo
  left join sede s on s.id = n.sede_id
  left join posizione_persona pp on pp.codice = n.posizione
 where n.data_cessazione is null;

-- `left join` e non `join`: una nomina senza posizione e il caso **normale** —
-- tutte quelle che verranno dalle colonne invece che dalle frasi — e un inner join
-- la farebbe sparire dall'organigramma. E la trappola della prima misura sui 141
-- codici fiscali, dove le righe senza chiave erano uscite dal conteggio stesso.

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
--   select count(*) from posizione_persona;                            --  6
--   select count(*) from posizione_persona where cambia_l_esito;       --  1, esterno
--
--   -- il vocabolario copre cio che la 0007 ha gia scritto: se non fosse vero,
--   -- la foreign key sopra sarebbe fallita al carico invece di dare un numero
--   select count(*) from ruolo_testo;                                  -- 29
--   select posizione, count(*) from ruolo_testo group by 1 order by 1;
--         datore 6 · esterno 1 · non_dichiarato 8 · non_titolare 1 ·
--         socio 2 · titolare 11
--
--   -- le righe di `ruolo_da_parola` che asseriscono qualcosa sulla posizione
--   select count(*) from ruolo_da_parola where posizione is not null;   -- 5
--
-- **Sei valori su sei ricorrono, e questo numero l'ho scritto due volte.** La prima
-- stesura di questo blocco portava una distribuzione a memoria — «`datore` non
-- compare fra i testi, e ha una riga lo stesso» — con sopra un paragrafo che
-- spiegava perche un valore mai osservato vada tenuto lo stesso. Il paragrafo era
-- giusto in generale e **falso qui**: `datore` ricorre 6 volte, e `titolare` sono
-- 11 e non 20. Il conto girato sul database ha corretto tutte e sei le cifre.
--
-- Vale la pena lasciarlo scritto perche l'errore e l'unico che questo file poteva
-- fare: **una distribuzione plausibile non si distingue da una misurata guardando
-- la pagina.** E il costo sarebbe stato una nota vera in mezzo a numeri falsi, che
-- e il modo in cui un dato senza peso passa.
--
-- Che ricorrano tutti e sei dice anche una cosa sul vincolo che questa migrazione
-- sostituisce: l'elenco della `0007` non era ne largo ne stretto sul suo campione.
-- Il che **non prova** che sia completo — un vocabolario osservato resta un
-- campione — ma toglie la domanda dal tavolo per le 29 forme che conosciamo.
--
-- ---------- e il conto che non torna oggi, e deve tornare dopo l'import ----------
--
--   select count(*) from nomina where posizione = 'esterno';           -- 0, e va bene
--
-- **Zero perche `nomina` e vuota**, non perche non ci siano esterni: il dizionario
-- della `0007` ne porta uno fra le 29 forme. Il giorno dell'import delle nomine
-- questo conto deve diventare diverso da zero, e se resta zero **la colonna non e
-- stata scritta** — che e esattamente come `import_key` e rimasta vuota per una
-- migrazione intera in AppSopralluoghi, con l'indice unique gia al suo posto.
