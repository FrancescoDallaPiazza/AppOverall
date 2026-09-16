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
-- seed caricati. Se la produzione di AppSopralluoghi da' la stessa stringa, il
-- seed **e'** l'export e la riga «resta da confermare» si chiude.
--
-- L'ordinamento e' per `testo`, che e' la chiave primaria: nessuna collation puo'
-- cambiarlo fra i due lati, perche' i testi sono distinti e l'ordine e' totale.
-- (L'ordine per `testo` e' l'unico usato qui: `corso_alias_origine.sql` usa
-- `riga_foglio` per la SUA impronta, e le due non si confrontano fra loro.)

select
  count(*) as righe,
  encode(sha256(convert_to(string_agg(
    testo || '|' ||
    coalesce(corso_codice, '') || '|' ||
    ignorato || pregressa || is_aggiornamento || parziale || evidenza_incompleta || '|' ||
    coalesce(note, ''),
    chr(10) order by testo), 'UTF8')), 'hex') as impronta
from corso_alias;
