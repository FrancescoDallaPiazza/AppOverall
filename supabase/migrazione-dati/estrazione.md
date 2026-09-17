# L'estrazione per la prova generale

Pagina per Francesco. Dice cosa lanciare nell'SQL Editor di **AppSopralluoghi**, come salvare i risultati e cosa
farne dopo.

**Non si fa finché Francesco non ha detto sì.** I nove file contengono nomi e codici fiscali di tutte le
persone e finiscono su questo disco: è una sua decisione, non un passo tecnico.

Tutto quello che segue **legge e non scrive**.

## Prima di cominciare

- Una cartella **fuori da qualunque repository**, per esempio
  `C:\Users\Francesco\Documents\migrazione-privata\2026-09-16`. Non sotto `GitHub`: lo script controlla e si
  rifiuta.
- **PostgreSQL installato su questo PC** (punto 5). Senza, la prova generale non parte e i nove file restano sul
  disco senza uso: prima PostgreSQL, poi l'estrazione. **Su `OVERALL-PC07` c'e** — PostgreSQL 16.10, misurato il
  16 settembre 2026, e la prova generale ci e passata intera sui dati finti. Su quel PC questo punto e chiuso.
- Un momento in cui **nessuno sta usando AppSopralluoghi**. Le quattro letture devono vedere lo stesso archivio, e
  il punto 4 lo verifica solo in parte (vedi in fondo).

## 1. La fotografia, prima

L'SQL Editor mostra il risultato di una query per volta, quindi le quattro estrazioni non sono lo stesso istante.
Si rende verificabile così: questa query si lancia **prima** e **dopo**, e se le due righe coincidono nessuno ha
scritto in mezzo.

```sql
select
  (select count(*) from public.cliente)                     as clienti,
  (select count(*) from public.sede)                        as sedi,
  (select count(*) from public.persona)                     as persone,
  (select count(*) from public.nomina)                      as nomine,
  (select count(*) from public.nomina where not attiva)     as nomine_non_attive,
  (select count(*) from public.nomina where da_confermare)  as nomine_da_confermare,
  (select pg_get_constraintdef(oid) from pg_constraint
    where conrelid = 'public.nomina'::regclass
      and conname = 'nomina_origine_nota')                  as livello_origine,
  (select max(created_at) from public.cliente)              as cliente_ultimo_creato,
  (select max(created_at) from public.sede)                 as sede_ultima_creata,
  (select max(updated_at) from public.persona)              as persona_ultima_modifica,
  (select max(updated_at) from public.nomina)               as nomina_ultima_modifica,
  now()                                                     as letto_il;
```

Copiare la riga che esce. Serve a tre cose:

- **`clienti`, `sedi`, `persone`, `nomine`** sono quattro dei nove conteggi attesi della prova generale (punto 5); tre stanno nell'altro database, qui sotto, e due li stampa lo script delle visite;
- **`livello_origine`** deve contenere `qualifica`: vuol dire che la loro `070` è applicata. Si legge dal vincolo e
  non da `schema_migrations`, dove le migrazioni date dall'SQL Editor non risultano. Se la colonna esce vuota manca
  la `068`, e la select delle nomine al punto 2 fallirà;
- **`nomine_non_attive` e `nomine_da_confermare`** non li ha mai misurati nessuno. Se non sono **0**, il passo 03 si
  fermerà (rifiuti d ed e). Meglio saperlo adesso: in quel caso ci si ferma qui e i due numeri si portano ad
  AppOverall, che decide cosa farne prima della prova.

## 2. Le quattro estrazioni, una per volta

Una query, poi il salvataggio del suo risultato (punto 3), poi la successiva. **Le colonne vanno lasciate come sono
scritte, in quell'ordine**: lo script confronta l'intestazione e si ferma se non coincide.

`cliente.csv`
```sql
select id, werp_id, ragione_sociale, partita_iva, codice_fiscale, attivo,
       numero_lavoratori, codice_ateco, livello_rischio, livello_antincendio,
       gruppo_primo_soccorso, created_at,
       ateco_origine, livello_rischio_definito_mediante,
       antincendio_definito_mediante, primo_soccorso_definito_mediante
  from cliente order by id;
```

`sede.csv`
```sql
select id, cliente_id, nome, indirizzo, localita, provincia, principale,
       attivo, created_at
  from sede order by id;
```

`persona.csv`
```sql
select id, cliente_id, sede_id, nome, cognome, codice_fiscale, mansione,
       data_assunzione, attivo, data_cessazione, import_key, updated_at
  from persona order by id;
```

`nomina.csv`
```sql
select id, persona_id, figura_codice, data_nomina, attiva, note,
       estremi_procura, da_confermare, origine, origine_testo,
       created_at, updated_at
  from nomina order by id;
```

### `formazione.csv` — **e questo si estrae dall'SQL Editor di AppFormazione, non di AppSopralluoghi**

Il 16 settembre 2026 abbiamo misurato che la tabella `formazione` di AppSopralluoghi
e' **vuota**: l'import degli attestati esiste nel loro codice e non e' mai stato
eseguito. Gli attestati stanno in AppFormazione, in `eventi_formativi`.

Quindi questa estrazione ha **due database e due fotografie**, e le due vanno prese
vicine: sono due momenti, e niente garantisce che siano lo stesso.

**Prima la fotografia di la'**, e il numero che esce e' `righe_formazione_attese`:

```sql
select count(*) as attestati,
       count(*) filter (where data_completamento is null) as senza_data,
       min(data_completamento) as il_piu_vecchio,
       max(data_completamento) as il_piu_recente,
       now() as letto_il
  from eventi_formativi;
```

`senza_data` deve essere **0**: il passo 04 si ferma se non lo e', perche' la validita'
si conta da una data e dedurla sarebbe inventarla.

**Poi l'estrazione**, sempre nell'SQL Editor di AppFormazione:

```sql
select e.id, p.codice_fiscale, c.titolo as corso_titolo, c.codice as corso_codice_origine,
       e.data_completamento, e.ore, e.ente_erogatore, e.esito, e.fonte
  from eventi_formativi e
  join persone p on p.id = e.persona_id
  join corsi   c on c.id = e.corso_id
 order by e.id;
```

Le due `join` sono a uno, quindi le righe restano quelle di `eventi_formativi`: se ne
escono di piu', qualcosa nel loro schema e' cambiato e **si guarda prima di
proseguire**. Salvare come `formazione.csv` nella stessa cartella degli altri quattro.

### `formazione_frazionata.csv` — **anche questo dall'SQL Editor di AppFormazione**

Le sessioni dei percorsi frazionati. **Non sono in `eventi_formativi`**: AppFormazione ha caricato i due export
`FormFraz` nel suo `staging` e li ha lasciati li', per non contare due volte lo stesso corso. Si leggono da li'.

**Prima la fotografia**, subito dopo quella degli attestati:

```sql
select entita,
       count(distinct esecuzione_id) as caricamenti,
       count(*) as righe,
       count(*) filter (where dati->>'Data' is not null
                           or dati->>'Tipo' is not null
                           or dati->>'Codice Fiscale' is not null) as sessioni,
       now() as letto_il
  from staging.righe_import
 where entita in ('fraz_completata', 'fraz_in_corso')
 group by entita
 order by entita;
```

- **`caricamenti` deve essere 1 su tutte e due le righe.** Se e' di piu', nello staging ci sono due estrazioni dello
  stesso file e le loro sessioni si sommerebbero: ci si ferma qui, e il numero si porta ad AppOverall. Il passo 05 lo
  ricontrolla e si ferma comunque (rifiuto c);
- **la somma delle due `sessioni` e' `righe_frazionata_attese`.** Le `righe` sono due di piu' per file: sono il piede
  del foglio — l'indirizzo del gestionale e «Dati aggiornati al ...» — che lo staging tiene come righe;
- sull'estrazione del 6 agosto 2026, misurata sui file in Download il 17 settembre, ci si aspetta **513** e **407**,
  quindi **920**. Se escono altri numeri non e' un errore: e' un'altra estrazione, e vale quella.

**Poi l'estrazione:**

```sql
select r.id, r.esecuzione_id, r.entita as file,
       r.dati->>'Codice Fiscale'      as codice_fiscale,
       r.dati->>'Tipo'                as corso_titolo,
       (r.dati->>'Data')::date        as data_sessione,
       r.dati->>'Dettagli/Ore'        as dettagli_ore,
       r.dati->>'Durata Formazione'   as durata,
       (select min(kv.value)
          from staging.righe_import f, jsonb_each_text(f.dati) kv
         where f.esecuzione_id = r.esecuzione_id
           and kv.value like 'Dati aggiornati al %') as dichiarazione
  from staging.righe_import r
 where r.entita in ('fraz_completata', 'fraz_in_corso')
   and (r.dati->>'Data' is not null
        or r.dati->>'Tipo' is not null
        or r.dati->>'Codice Fiscale' is not null)
 order by r.id;
```

Le righe devono essere quante la somma delle `sessioni`. **La colonna `file` e' il dato**, non un'etichetta: dice se
il percorso di quella sessione e' completato o in corso, e nel gestionale non sta scritto da nessun'altra parte.
`dichiarazione` deve essere piena su tutte le righe: se e' vuota, il piede del foglio non e' stato caricato e il passo
05 si ferma (rifiuto d). Salvare come `formazione_frazionata.csv` nella stessa cartella.

Sono le select di `00_origine.sql`, e se una delle due cambia va cambiata anche l'altra.

### `persona_storica.csv` — **anche questo dall'SQL Editor di AppFormazione**

Le persone di AppFormazione con i loro rapporti e i loro clienti. Servono al passo 02b: chi ha attestati o visite
e non e nell'anagrafe di AppSopralluoghi entra **con il suo rapporto**, segnato cessato (decisione di Francesco del
17 settembre 2026). Si estraggono **tutte**: quali entrano lo decide il passo, non la query.

**Prima la fotografia**, e la prima colonna e `righe_persone_storiche_attese`:

```sql
select (select count(*)
          from persone p
          left join rapporti_lavoro r on r.persona_id = p.id
         where p.codice_fiscale is not null)            as righe,
       (select count(*) from persone
         where codice_fiscale is not null)              as persone,
       (select count(*) from persone
         where codice_fiscale is not null and not attiva) as non_attive,
       now()                                            as letto_il;
```

**Poi l'estrazione:**

```sql
select p.id as persona_id, p.codice_fiscale, p.cognome, p.nome, p.data_nascita, p.attiva,
       r.id as rapporto_id, r.mansione, r.data_assunzione, r.data_cessazione,
       c.id as cliente_id, c.ragione_sociale, c.partita_iva
  from persone p
  left join rapporti_lavoro r on r.persona_id = p.id
  left join clienti c on c.id = r.cliente_id
 where p.codice_fiscale is not null
 order by p.id, r.id;
```

Le righe devono essere quante `righe` della fotografia. Salvare come `persona_storica.csv`.

### `visita.csv` e `visita_scadenza.csv` — **non da un SQL Editor: da due file del gestionale**

Le visite non stanno in nessun database. Stanno in due export del gestionale, che sono gia su questo PC in
`Download`:

- `ExportExcelVisiteFatte.xlsx` — **la storia**: una riga per visita fatta (1.383 righe, «Dati aggiornati al
  11/09/2026 15:23»);
- `ExportExcelVisiteScadenze.xlsx` — lo scadenzario: una riga per persona e tipo («Dati aggiornati al
  06/08/2026 07:56»).

Non il foglio «Visite» di `ExportExcel (4).xlsx`: porta solo l'ultima visita per persona e tipo, e la storia lo
contiene tutto.

I due CSV li scrive uno script, **nella stessa cartella degli altri**, da Git Bash nella cartella del repository:

```bash
python supabase/migrazione-dati/estrai_visite.py \
       "C:/Users/Francesco/Downloads/ExportExcelVisiteFatte.xlsx" \
       "C:/Users/Francesco/Downloads/ExportExcelVisiteScadenze.xlsx" \
       "C:/Users/Francesco/Documents/migrazione-privata/<cartella>"
```

Legge e non scrive sugli xlsx, rifiuta una cartella dentro un repository, e stampa soltanto i due conteggi —
`righe_visite_attese` e `righe_scadenze_attese` — e la data che ogni file dichiara.

**Le due date sono diverse, e va bene cosi.** Il passo 07 confronta ogni scadenza con l'ultima visita **fino al
giorno dello scadenzario**, non con l'ultima in assoluto: e l'errore che aveva prodotto le «nove scadenze
anticipate», di cui vere ne restano due (`0024`). Se si riscaricano, meglio **tutti e due lo stesso giorno**.

## 3. Come si salva ogni risultato

- Dal risultato della query, l'**esportazione in CSV** dell'editor, con il **nome esatto** scritto sopra ogni query,
  nella cartella scelta.
- Se l'editor mostra un **limite di righe**, va tolto prima di esportare. Un file troncato lo script lo scopre
  comunque, perché le righe non tornano con il conteggio, ma si perde un giro.

Il file deve essere così. Si controlla aprendolo con il **Blocco note**, non con Excel:

| | com'è | come si vede |
|---|---|---|
| **intestazione** | la prima riga, con i nomi delle colonne | `id,werp_id,ragione_sociale,...` |
| **separatore** | la virgola; un testo che contiene una virgola sta fra virgolette doppie | `"ROSSI, MARIO"` |
| **NULL** | **la parola `null`**, che e come la scrive l'SQL Editor (~~niente fra due virgole~~) | `...,true,null,2026-09-09...` |
| **codifica** | UTF-8: le lettere accentate si leggono giuste | `NICOLÒ`, non `NICOLÃ’` |
| **date e vero/falso** | come le scrive il database: `2026-09-09`, `true`/`false` (o `t`/`f`) | |

Nel Blocco note, «Salva con nome» mostra la codifica in basso a destra: deve dire UTF-8. Non salvare, solo guardare.

**I nulli sono la parola «null», e non e un dettaglio di forma.** Misurato il 16 settembre 2026 sui quattro file
veri: **11.912 campi** scritti cosi — 2.798 in `cliente.csv`, 760 in `sede.csv`, 7.009 in `persona.csv`, 1.345 in
`nomina.csv`. Su una colonna non di testo il caricamento **si ferma subito** e lo si vede (la prima volta: riga 5 di
`cliente.csv`, `numero_lavoratori`); su una colonna di testo quella parola entrerebbe **come testo**, e non
protesterebbe nessuno. Per questo la prova generale si lancia con `null_scritto=null` (punto 5), che li fa entrare
come NULL: **i file non si riscrivono**, si leggono diversamente.

**E la cosa che i file non possono dire, la dice il database.** `null_scritto=null` fa entrare come NULL i campi che
valgono **esattamente** quella parola — quindi un valore vero uguale a «null» diventerebbe NULL anche lui, e nel CSV
i due casi si scrivono uguali (l'editor mette le virgolette solo quando servono). Alla fonte si distinguono, con una
query che guarda tutte le colonne delle quattro tabelle. **Deve dare quattro zeri:**

```sql
select 'cliente' as tabella, count(*) from cliente  c where exists (select 1 from jsonb_each_text(to_jsonb(c)) kv where kv.value = 'null')
union all
select 'sede',    count(*) from sede    s where exists (select 1 from jsonb_each_text(to_jsonb(s)) kv where kv.value = 'null')
union all
select 'persona', count(*) from persona p where exists (select 1 from jsonb_each_text(to_jsonb(p)) kv where kv.value = 'null')
union all
select 'nomina',  count(*) from nomina  n where exists (select 1 from jsonb_each_text(to_jsonb(n)) kv where kv.value = 'null');
```

Se un conteggio non e zero, **ci si ferma**: quella riga perderebbe un valore vero, e cosa farne si decide prima.

**Lanciata il 16 settembre 2026 sull'estrazione di quel giorno: quattro zeri.** Il controllo pero misura **i dati**,
non lo script: **ogni estrazione nuova lo rifa**, perche fra una e l'altra qualcuno puo aver scritto «null» in un
campo di testo.

**Mai aprire e salvare un file con Excel.** Lo riscrive in un'altra codifica, toglie lo zero iniziale alle partite
IVA e ai codici, e cambia il formato delle date. Se è stato aperto e salvato per sbaglio, si riesporta.

## 4. La fotografia, dopo

Rilanciare la query del punto 1. Deve dare **la stessa riga**, tranne `letto_il`. Se cambia anche un solo numero o
una sola data, qualcuno ha scritto fra le estrazioni: si ricomincia dal punto 1.

## 5. La prova generale

Da Git Bash, nella cartella del repository AppOverall:

```bash
bash supabase/migrazione-dati/prova_generale.sh "C:/Users/Francesco/Documents/migrazione-privata/2026-09-16" \
     clienti_attesi=<clienti> sedi_attese=<sedi> righe_attese=<persone> nomine_attese=<nomine> \
     righe_formazione_attese=<attestati> righe_frazionata_attese=<sessioni> \
     righe_visite_attese=<visite> righe_scadenze_attese=<scadenze> \
     righe_persone_storiche_attese=<righe> null_scritto=null
```

con i numeri della fotografia: `clienti_attesi` = `clienti`, `sedi_attese` = `sedi`, `righe_attese` = `persone`,
`nomine_attese` = `nomine`, `righe_formazione_attese` = `attestati`, `righe_frazionata_attese` = la somma delle due `sessioni`. `righe_visite_attese` e `righe_scadenze_attese` li stampa `estrai_visite.py`. `righe_persone_storiche_attese` = `righe` della fotografia di `persona_storica.csv`. L'ultimo parametro serve perche i file vengono dall'SQL Editor (punto 3): senza, lo
script si ferma al caricamento e lo dice.

Serve PostgreSQL installato, e nient'altro da configurare. **Su `OVERALL-PC07` c'e**: PostgreSQL **16.10** in
`C:\Program Files\PostgreSQL\16`, trovato dallo script senza indicazioni, e il 16 settembre 2026
`verifica_prova_generale.sh` e arrivata in fondo con tutte le prove passate. ~~Il 15 settembre 2026 sul PC di
Francesco non c'e~~ — quella misura vale, ma **e un altro PC** (li niente PostgreSQL, Docker Desktop e WSL; qui
PostgreSQL dal 4 maggio 2026 e WSL non installato). **Francesco ha deciso il 16 settembre di estrarre qui**, quindi
non si installa niente; se un giorno si estrae sull'altro PC, li il punto torna aperto. Lo script lo
cerca in `C:\Program Files\PostgreSQL\<versione>\bin`, o nella cartella indicata con `PGBIN=`. Lo script crea un
database usa e getta, esegue la migrazione dati da capo a fondo, stampa gli avvisi dei passi e i conteggi finali, e
**cancella il database alla fine**, anche quando si ferma. L'ultima riga dice com'è andata:

- `ARRIVATA IN FONDO`
- `FERMATA in: <fase>`, con sopra il messaggio del controllo che ha rifiutato.

Stampa numeri e messaggi dei controlli, non dati: una riga che non passa si cerca nel file, con il numero di riga
che lo script indica.

## 6. Dopo

**Cancellare la cartella dei CSV.** La prova generale non tiene copie: il suo database è già cancellato.

## Cosa questa pagina non garantisce

- **La fotografia vede le righe nuove e cancellate di tutte e quattro le tabelle, e le modifiche solo su persone e
  nomine.** Di clienti e sedi ha soltanto la data dell'ultima creazione, perché nella select del passo 00 non c'è
  un `updated_at`: un cliente esistente modificato fra un'estrazione e l'altra non si vede. Per questo serve il
  momento senza utenti.
- **Il formato esatto dell'esportazione CSV dell'editor non è stato provato da qui**, perché da questa corsia la
  produzione non si legge. Lo script è stato provato su CSV prodotti da PostgreSQL con dati finti
  (`verifica_prova_generale.sh`): accetta intestazione con o senza virgolette, un BOM iniziale, righe che finiscono
  con CRLF, `true/false` e `t/f`, date ISO. Su tutto il resto si ferma, e dice in quale fase.
