# L'estrazione per la prova generale

Pagina per Francesco. Dice cosa lanciare nell'SQL Editor di **AppSopralluoghi**, come salvare i risultati e cosa
farne dopo.

**Non si fa finché Francesco non ha detto sì.** I quattro file contengono nomi e codici fiscali di tutte le
persone e finiscono su questo disco: è una sua decisione, non un passo tecnico.

Tutto quello che segue **legge e non scrive**.

## Prima di cominciare

- Una cartella **fuori da qualunque repository**, per esempio
  `C:\Users\Francesco\Documents\migrazione-privata\2026-09-16`. Non sotto `GitHub`: lo script controlla e si
  rifiuta.
- **PostgreSQL installato su questo PC** (punto 5). Senza, la prova generale non parte e i quattro file restano sul
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

- **`clienti`, `sedi`, `persone`, `nomine`** sono i quattro conteggi attesi della prova generale (punto 5);
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
       gruppo_primo_soccorso, created_at
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

Sono le select di `00_origine.sql`, e se una delle due cambia va cambiata anche l'altra.

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
| **NULL** | niente fra due virgole | `...,true,,2026-09-09...` |
| **codifica** | UTF-8: le lettere accentate si leggono giuste | `NICOLÒ`, non `NICOLÃ’` |
| **date e vero/falso** | come le scrive il database: `2026-09-09`, `true`/`false` (o `t`/`f`) | |

Nel Blocco note, «Salva con nome» mostra la codifica in basso a destra: deve dire UTF-8. Non salvare, solo guardare.

**Mai aprire e salvare un file con Excel.** Lo riscrive in un'altra codifica, toglie lo zero iniziale alle partite
IVA e ai codici, e cambia il formato delle date. Se è stato aperto e salvato per sbaglio, si riesporta.

## 4. La fotografia, dopo

Rilanciare la query del punto 1. Deve dare **la stessa riga**, tranne `letto_il`. Se cambia anche un solo numero o
una sola data, qualcuno ha scritto fra le estrazioni: si ricomincia dal punto 1.

## 5. La prova generale

Da Git Bash, nella cartella del repository AppOverall:

```bash
bash supabase/migrazione-dati/prova_generale.sh "C:/Users/Francesco/Documents/migrazione-privata/2026-09-16" \
     clienti_attesi=<clienti> sedi_attese=<sedi> righe_attese=<persone> nomine_attese=<nomine>
```

con i numeri della fotografia: `clienti_attesi` = `clienti`, `sedi_attese` = `sedi`, `righe_attese` = `persone`,
`nomine_attese` = `nomine`.

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
