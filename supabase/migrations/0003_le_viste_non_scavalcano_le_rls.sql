-- AppOverall — 0003
-- Le viste smettono di scavalcare le RLS.
--
-- La 0001 ha scritto policy che isolano davvero — nessuna `using (true)`, che era
-- il difetto misurato nei due repo di partenza — e le ha chiamate PILASTRO 02. La
-- stessa migrazione ha fatto delle viste l'unica superficie di lettura, e l'ha
-- chiamato PILASTRO 01. Messi insieme, e senza questa riga, **si annullano**.
--
-- ---------- il meccanismo, che non e un dettaglio di configurazione ----------
--
-- Una vista PostgreSQL esegue con i diritti del **proprietario**, non di chi la
-- interroga. Il proprietario e chi applica le migrazioni. Le RLS delle tabelle
-- sotto vengono quindi valutate su di lui — che le scavalca — e non su chi ha
-- fatto la query.
--
-- Da cui: `v_cliente`, `v_sede` e `v_valutazione_sede` oggi mostrano **tutto a
-- chiunque sia autenticato**, operatore o no. Le policy sono scritte, sono giuste,
-- e non le legge nessuno. E siccome l'applicazione per il PILASTRO 01 legge solo
-- viste, l'isolamento non c'e da nessuna delle due parti.
--
-- Il criterio di uscita della Fase 3 dice: «un utente senza abilitazione non vede
-- niente perche lo dice la policy, non l'applicazione». Oggi vede tutto, e lo dice
-- la policy — al contrario.
--
-- `security_invoker` sposta la valutazione su chi interroga. E stato scritto sulle
-- due viste della 0002 nel momento in cui sono nate; queste tre vengono da prima e
-- sono rimaste indietro. Non e una svista scoperta per caso: e stata trovata
-- scrivendo la 0002, dichiarata nel suo commento, e chiusa qui invece che li
-- perche riguarda un pilastro diverso.
--
-- ---------- perche adesso e non dopo ----------
--
-- Perche **prima che entri il primo dato** una policy sbagliata non ha esposto
-- niente, e dopo si. E perche una vista che cambia semantica quando le tabelle
-- sono gia lette da due applicazioni si scopre rotta in produzione: e la stessa
-- ragione per cui la 0001 ha scritto le RLS da subito invece di aggiungerle poi.

alter view v_cliente          set (security_invoker = on);
alter view v_sede             set (security_invoker = on);
alter view v_valutazione_sede set (security_invoker = on);

-- ---------- il prezzo, e va pagato per intero ----------
--
-- Con `security_invoker` la vista verifica **privilegi e** RLS sull'invocante:
-- senza `select` sulle tabelle sotto, adesso risponde «permission denied» invece
-- di una riga in meno. Su Supabase funzionerebbe lo stesso, perche i default
-- privileges dell'istanza hanno gia concesso tutto a `authenticated` — cioe
-- dipenderebbe da uno stato che il repo non dichiara, e che un giorno cambia
-- senza che nessuno colleghi le due cose.
--
-- La 0002 ha dichiarato cio che serviva a se stessa. Qui si completa l'elenco:
-- `valutazione_sede` e `operatore` servono a `v_valutazione_sede`,
-- `ruolo_applicativo` serve a chiunque debba leggere il vocabolario dei livelli.

grant select on valutazione_sede, operatore, ruolo_applicativo to authenticated;

-- ---------- cosa questo NON risolve, per non crederlo risolto ----------
--
-- Le tabelle restano leggibili direttamente. Quindi «l'applicazione non nomina mai
-- una tabella» resta una **disciplina**, non un vincolo — e va bene cosi, purche
-- si sappia: l'isolamento non lo fa la vista, lo fanno le RLS, e da adesso valgono
-- identiche sui due percorsi. La vista serve a poter spostare una tabella senza
-- rompere il client, che e un'altra cosa e altrettanto utile.
--
-- Chi volesse anche il vincolo dovrebbe revocare il `select` sulle tabelle — ma
-- con `security_invoker` revocarlo romperebbe le viste stesse, perche l'invocante
-- perderebbe il privilegio che gli serve. Le due strade si escludono, e questa e
-- quella che protegge le righe invece dei nomi.

comment on view v_cliente is
  'I clienti, col numero di sedi attive. Da qui in avanti le RLS di `cliente` valgono anche attraverso questa vista: prima della 0003 non valevano, e chiunque fosse autenticato vedeva tutto.';
