# 1 · Il fatto appartiene alla sede o all'azienda?

**Blocca la Fase 3.** Determina colonne dello schema.

## Cosa e in gioco

Quattro attributi: **livello di rischio, codice ATECO, livello antincendio, gruppo
di primo soccorso**. Sono dell'azienda, o della singola sede?

## Cosa dice gia il codice

AppSopralluoghi ha **gia deciso, e ha deciso «aziendali»**, con un commento
esplicito in `formazione.ts:1301`: gli attributi che guidano l'organigramma sono
AZIENDALI. Il motore legge sempre il cliente, anche nel percorso «per sede».

Le colonne duplicate su `sede` esistono — migrazione `054`, **sei** colonne, non
quattro — ma sono **in sola scrittura**: nessuna interfaccia le rende modificabili
per sede, e nessun motore le legge. Non sono una doppia verita attiva: sono colonne
morte.

## Cosa cambia secondo la risposta

- **Restano aziendali** — si cancellano sei colonne morte e si va avanti. E la
  strada che il codice ha gia imboccato.
- **Diventano della sede** — non e completare una direzione, e **invertirla**: il
  motore va riscritto, e va deciso cosa succede quando un cliente ha sedi con
  livelli di rischio diversi.

Da sapere prima di scegliere: una divergenza e gia possibile oggi.
`Formazione.tsx:258` aggiorna `cliente.rls_territoriale` senza scriverlo anche
sulla sede, e la copia resta stantia.

## Decisione

**Presa da Francesco il 9 settembre 2026: appartengono alla SEDE.** Ma non tutti
per la stessa ragione, e la differenza conta perche' determina da dove si legge
il dato, non solo dove si scrive.

**Livello di rischio.** Discende dall'ATECO, e l'ATECO si prende dalla **visura
camerale**. La visura riporta l'attivita' della sede legale *e quella di ciascuna
unita' locale*: se le unita' locali hanno ATECO diversi, il livello di rischio e'
**della sede**; se hanno lo stesso, il valore aziendale e' semplicemente il caso
in cui tutte le sedi coincidono. Quindi non e' un attributo aziendale con
eccezioni: e' un attributo di sede che spesso ha lo stesso valore ovunque.

**Livello antincendio.** Dipende dalle **attivita' svolte nella sede**. Sempre
della sede, senza il caso degenere di cui sopra: due capannoni della stessa
azienda possono avere livelli diversi perche' ci si fanno cose diverse.

**Gruppo di primo soccorso.** Dipende dal **codice di tariffa INAIL** e da come
quel codice si distribuisce fra le sedi. Della sede quando la tariffa cambia da
una sede all'altra; aziendale quando e' una sola.

### Cosa comporta

E' **l'inversione** prevista nella sezione precedente, non il suo completamento.
Il motore oggi legge sempre il cliente (`formazione.ts:1298-1312`) e va riscritto
per leggere la sede, con il valore del cliente che diventa **un derivato della
sede principale** e non piu' la fonte.

Tre conseguenze che la decisione porta con se' e che vanno raccolte adesso:

1. **La campagna sull'ATECO mancante va fatta per SEDE, non per cliente.** Manca
   sul 57% delle aziende attive e si riempie dalla visura: se si scrive un ATECO
   solo sul cliente, si perde per costruzione l'informazione che la decisione
   dichiara rilevante. E' anche il punto in cui serve il raccordo 2025 -> 2007,
   perche' una visura di oggi porta codici 2025.

2. **Il codice di tariffa INAIL non e' un campo, e ora deve diventarlo.** Oggi il
   wizard DM 388/2003 lo usa per proporre il gruppo e ne conserva solo la
   *motivazione* come stringa (`Anagrafiche.tsx:1060-1070`). Se il primo soccorso
   dipende dalla tariffa e dalla sua distribuzione fra le sedi, la tariffa va
   memorizzata **per sede**, altrimenti la regola non e' verificabile ne'
   ricalcolabile.

3. **Le sei colonne su `sede` non si cancellano piu'.** Erano candidate alla
   rimozione come colonne morte: diventano la fonte. Cambia il verso del
   write-through di `salvaCliente`, che oggi copia dal cliente alla sede.

### Cosa resta da decidere, ma non blocca

Quando un cliente ha sedi con livelli diversi, **cosa mostra la scheda azienda**:
il valore della sede principale, il piu' alto fra le sedi, o nessuno. Si decide
quando si disegna la schermata, non prima dello schema.
