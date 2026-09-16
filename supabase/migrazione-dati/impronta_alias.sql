-- AppOverall - l'impronta del dizionario alias, per confrontarlo con il vivo.
--
-- Il seed dei 268 alias e' **dedotto dagli script** di AppSopralluoghi, non
-- esportato dalla loro produzione: lo dichiara il file stesso in testa. Se
-- qualcuno ha cambiato un giudizio dall'interfaccia dopo l'esecuzione degli
-- script, quella decisione nel seed non c'e', e non c'e' modo di accorgersene
-- guardando il seed - che e' coerente con se' stesso.
--
-- Questa query riduce le 268 righe a **una stringa**. Si lancia due volte, sui
-- due database, e si confrontano le stringhe:
--
--   qui   dopo aver caricato il seed (lo fa la prova generale)
--   la'   nell'SQL Editor di AppSopralluoghi, sulla loro `corso_alias`
--
-- **Ma non e' la stessa query, e la differenza non e' un refuso.** Il testo del
-- gestionale la' si chiama `testo_gestionale` e la loro tabella ha un `id` proprio
-- (`055`); qui il testo **e'** la chiave primaria e si chiama `testo`, perche' la
-- scheda 9 dice che l'identita' e' cio' che si riceve. Gli altri cinque giudizi
-- hanno lo stesso nome nei due repo (`057`, `059`, `060`), quindi le due impronte
-- si confrontano. La versione da lanciare di la' e' in fondo a questo file.
--
-- Trovato il 16 settembre 2026 lanciando la prima versione sulla loro produzione:
-- «column "testo" does not exist». **Una query scritta per uno schema e lanciata
-- sull'altro non e' un confronto**: qui almeno si e' fermata subito.
--
-- Uguali: il seed e' l'export, e la riga «resta da confermare» si chiude.
-- Diverse: in produzione c'e' almeno un giudizio che il seed non ha, e va
-- trovato prima che il repo unico lo perda. **Non dice quale**, e va bene cosi':
-- la domanda di oggi e' se cercarlo, non quale sia.
--
-- Cosa entra nell'impronta: i sette campi che sono **decisioni**, piu' la nota.
-- Restano fuori `testo_origine` e `riga_foglio`, che esistono solo qui (`0008`),
-- e qualunque id: si confrontano due tabelle di due repo diversi, non due copie.
--
-- **L'impronta del seed, calcolata qui il 16 settembre 2026:**
--
--   righe     268
--   impronta  77e35ffc81466d34f6dbc5188120e57295b9fc3c622f6191f4223eaa6bb2138e
--
-- Calcolata su un cluster usa e getta con tutte le migrazioni applicate e i due
-- seed caricati.
--
-- **CONFRONTATA CON LA PRODUZIONE DI AppSopralluoghi IL 16 SETTEMBRE 2026: UGUALE.**
-- 268 righe e la stessa impronta. Il seed **e'** l'export: i 268 testi coincidono
-- carattere per carattere e i sette giudizi con le note pure. La riga «resta da
-- confermare contro il database vivo», aperta il 10 settembre, e chiusa — e quello
-- che resta da fare e' rifarla quando il dizionario cambia, non fidarsi di questa.
--
-- ~~L'ordinamento e' per `testo`: nessuna collation puo' cambiarlo fra i due lati,
-- perche' i testi sono distinti e l'ordine e' totale.~~ **Falso, e costato due giri
-- il 16 settembre 2026.** Un ordine totale su un insieme distinto e' comunque
-- **l'ordine che decide la collation**: un cluster creato con `--no-locale` ordina
-- per byte, la produzione ordina secondo la sua, e le stesse identiche 268 righe
-- concatenate in ordine diverso danno impronte diverse. Le prime due impronte
-- confrontate non misuravano i dati: misuravano la collation.
--
-- Per questo l'ordinamento e' **`order by ... collate "C"`** da tutte e due le
-- parti. Non e' una precauzione teorica: e' il motivo per cui questo confronto
-- adesso funziona.
--
-- E l'avvertimento era gia scritto, in fondo al file accanto
-- (`seed/corso_alias_origine.sql`): «l'impronta va ricontrollata ordinando per
-- `riga_foglio` e **mai per testo**. Un'impronta che non torna per una ragione
-- procedurale segnala un problema che non c'e, e la prossima volta nessuno ci
-- crede piu». Quel file la SUA impronta la ordina per `riga_foglio`, che e' un
-- intero e non ha collation. Chi ha scritto questa query non ha letto quella riga.

select
  count(*) as righe,
  encode(sha256(convert_to(string_agg(
    testo || '|' ||
    coalesce(corso_codice, '') || '|' ||
    ignorato || pregressa || is_aggiornamento || parziale || evidenza_incompleta || '|' ||
    coalesce(note, ''),
    chr(10) order by testo collate "C"), 'UTF8')), 'hex') as impronta
from corso_alias;

-- ============================================================================
--  LA STESSA IMPRONTA, DAL LATO DI AppSopralluoghi
-- ============================================================================
--
-- Si incolla nel loro SQL Editor. Legge e non scrive.
--
--   select
--     count(*) as righe,
--     encode(sha256(convert_to(string_agg(
--       testo_gestionale || '|' ||
--       coalesce(corso_codice, '') || '|' ||
--       ignorato || pregressa || is_aggiornamento || parziale || evidenza_incompleta || '|' ||
--       coalesce(note, ''),
--       chr(10) order by testo_gestionale collate "C"), 'UTF8')), 'hex') as impronta
--   from corso_alias;
