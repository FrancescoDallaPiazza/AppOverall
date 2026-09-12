-- AppOverall — 0015
-- Un commento che descrive una popolazione e verra letto su un'altra.
--
-- ============================================================================
--  IL RILIEVO, E PERCHE NON E «UN NUMERO PICCOLO»
-- ============================================================================
--
-- La `0001` commenta `persona.codice_fiscale` cosi:
--
--   «nel foglio dei ruoli sicurezza **dodici righe su 153** ne sono prive, e dieci
--    sono della stessa azienda. Chi lo cerca deve prevedere il ripiego cognome+nome
--    dentro il cliente, e **contare quante righe non ha agganciato**.»
--
-- Il consiglio e giusto e il numero era vero. **Ma descrive una popolazione sola**,
-- quella delle righe che portano il ruolo nelle **colonne** dell'export — e il 12
-- settembre 2026 AppSopralluoghi ha misurato l'altra meta, quella che il ruolo lo
-- porta scritto **dentro la mansione** (`5fa92d3`):
--
--   ruolo nelle COLONNE      204 righe    16 senza codice fiscale     7,8%
--   ruolo nella MANSIONE      74 righe    47 senza codice fiscale    63,5%
--
-- **Otto volte peggio.** E la loro formulazione e quella che ha chiesto questa
-- migrazione, perche dice **cosa** c'e di sbagliato e non solo che il numero e
-- piccolo:
--
-- > Non e lo stesso commento che dice una cosa piu piccola: **e un commento che
-- > descrive una popolazione e verra letto su un'altra.**
--
-- E il momento in cui verra letto sull'altra e gia fissato: la **migrazione dati**,
-- dove la meta dedotta dell'organigramma diventa **rapporti di lavoro su persone
-- senza identita propria**. Sotto A17 questo e un **errore inerte che sta per
-- diventare utilizzabile**: la `0001` sta ferma da giorni senza costare niente
-- perche nessuno ha ancora scritto una persona.
--
-- **La `0001` non si corregge** — stessa regola con cui la `0008` ha sostituito il
-- commento di `corso_alias.testo` invece di riscrivere la `0004` — quindi il
-- commento si sostituisce qui.
--
-- ============================================================================
--  E LA DIFESA CONTRO A18 E DOVE IL NUMERO GRANDE SI TROVA
-- ============================================================================
--
-- La classe di difetto l'ha nominata la stessa corsia poche ore prima: **una
-- conclusione giusta appoggiata a una ragione troppo piccola sopravvive finche
-- nessuno la discute**. Il ripiego cognome+nome era stato acceso citando 19 incarichi
-- persi e un ASPP — numeri veri e **piccoli** — e regge invece **meta del lavoro che
-- l'import esiste per fare**.
--
-- Nessuna rilettura la trova, perche chi rilegge controlla se la **conclusione**
-- regge, e regge. Cade al primo che dice «per diciannove righe non vale la pena».
-- **La difesa e scrivere il numero grande dove la decisione si rilegge**, e per
-- questo schema quel posto e questo commento: e cio che leggera chi scrivera la
-- migrazione dati.

comment on column persona.codice_fiscale is
  'Unico quando c''e, e **puo non esserci** — ma quanto spesso dipende da DOVE la riga viene, ed e la cosa da sapere prima di scrivere un import. Misurato il 12 settembre 2026 su `ExportExcel.xlsx`: sulle **204** righe che portano il ruolo nelle **colonne** manca su 16 (**7,8%**); sulle **74** che lo portano dentro la **mansione** manca su 47 (**63,5%**), cioe **otto volte peggio**. Il «dodici su 153» della `0001` descriveva la prima popolazione e non la seconda. **Quindi il ripiego cognome+nome dentro il cliente non e un rammendo per pochi casi: regge quasi due terzi della meta dedotta dell''organigramma**, e chi lo trovasse motivato da «19 incarichi persi» starebbe guardando la meta buona del problema. Due riserve, e la seconda conta piu del numero: il dizionario dei ruoli e stato costruito sull''export del **2026** e applicato al **2023** riconosce solo le forme che gia conosce, quindi **74 e un limite inferiore** — e il 63,5% e probabilmente **ottimista**, perche le forme non riconosciute sono per costruzione le piu irregolari e non c''e ragione di credere che chi scrive il ruolo in modo irregolare compili meglio il codice fiscale. E resta il consiglio della `0001`, che vale piu di prima: **contare quante righe non si sono agganciate**.';

-- E dove atterra l'identita di quelle righe sta nella `0013` e non qui: una persona
-- senza codice fiscale **non ha identita propria in questo schema**, e l'unica cosa
-- che la tiene separata da un'altra e la `import_key` del **rapporto** — `anag:
-- <cliente>:n:<COGNOME>|<NOME>`. Le due righe si leggono insieme: questa dice
-- **quante** sono, quella dice **come** sopravvivono al confine.

comment on column rapporto_lavoro.import_key is
  'La chiave d''origine **verbatim**, uuid compreso: `anag:<cliente.id>:<cf>` oppure `anag:<cliente.id>:n:<COGNOME>|<NOME>`. Sta qui e non su `persona` perche identifica **una persona presso un cliente**, che in questo schema e il rapporto e non la persona — la loro `persona` e per cliente, questa e globale. Regge il join solo perche i clienti attraversano con lo **stesso** uuid: e la ragione della decisione, non un effetto collaterale. **E la seconda forma non e il caso raro**: sulla meta dell''organigramma che porta il ruolo dentro la mansione il codice fiscale manca sul **63,5%** delle righe (vedi `persona.codice_fiscale`), quindi e questa colonna a tenere separate quelle persone — non un vincolo, non un indice: **una stringa**. Il giorno in cui un import la scrive male, due persone diventano una e nessun vincolo protesta.';

-- ============================================================================
--  I CONTI CHE QUESTA MIGRAZIONE DEVE FARE TORNARE
-- ============================================================================
--
-- Nessuno: non tocca una riga di dato e non crea niente. **E va detto**, perche una
-- migrazione senza conti e normalmente un sospetto — qui l'unica cosa che cambia e
-- **cosa leggera chi apre lo schema**, e quella si verifica leggendola.
--
--   select col_description('persona'::regclass::oid, ordinal_position) ...
--
-- L'unico controllo che ha senso e che i due commenti **si nominino a vicenda**: se
-- un giorno uno dei due si riscrive senza l'altro, il numero grande torna a stare in
-- un posto solo — che e esattamente la condizione da cui questa migrazione esce.
