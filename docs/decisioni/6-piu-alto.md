# 6 · Il cliente con piu codici ATECO: si prende il piu alto?

**Non blocca niente** finche le sedi non sono entita di prima classe. Poi diventa
una domanda quotidiana, non un caso limite.

## Il fatto

La regola «si prende la classe piu alta» e scritta in **due posti indipendenti**:

- `formazione-81-utils-src`, funzione `classificaClienteMultiSede(codici)`: aggrega
  piu ATECO prendendo il piu alto, **citando** «ai sensi del DM 388/2003 (e prassi
  consolidata)»;
- `Organigramma-sicurezza`, `ateco-rischio.md`: «in caso di dubbio tra due classi,
  applicare il principio di precauzione (scegliere la piu alta)», senza citare nulla.

Il rilievo esatto non e che la fonte manchi in entrambi, ma che **quella citata parla
d'altro**: il DM 388/2003 disciplina i gruppi di primo soccorso — dove il criterio
del piu alto e effettivamente previsto — non le classi di rischio della formazione
lavoratori dell'Allegato IV. E un'applicazione per analogia, e va dichiarata tale o
sostituita con una fonte propria.

## Perche non e ovvia

L'**Interpello MLPS 1/2025** del 18 settembre 2025 ha stabilito che la classe ATECO
e **un default che la valutazione dei rischi puo spostare nei due versi**: verso il
basso per chi non frequenta i reparti produttivi (ASR 2025, Parte II punto 2.1.1),
verso l'alto quando emergono rischi particolari in un'azienda classificata bassa
(accordo 153/CSR, allegato A punto 4). E l'interpello 11/2013 aggiunge che «la durata
del corso puo prescindere dal codice ATECO di appartenenza dell'azienda».

Se la classe si sposta per mansione, «il piu alto fra i codici dell'azienda» non e
automaticamente la risposta giusta per **ogni persona** di quell'azienda: potrebbe
essere sistematicamente eccessiva per chi svolge attivita d'ufficio in una sede a
basso rischio.

## Le fonti, cercate il 9 settembre 2026

L'esito e asimmetrico, e va detto subito: **una delle due meta ha una fonte esatta,
l'altra non ne ha nessuna — e l'assenza e stata cercata, non supposta.**

### Meta con fonte: per il primo soccorso non e analogia, e la lettera

Il DM 388/2003 dice il «piu alto» **testualmente**, all'**art. 1 comma 2, ultimo
periodo**:

> «Se l'azienda o unita produttiva svolge attivita lavorative comprese in gruppi
> diversi, il datore di lavoro deve riferirsi all'attivita con indice piu elevato.»

Quindi per il **gruppo di primo soccorso** la libreria non sta applicando un
principio per analogia: sta citando la norma che lo prevede, e la citazione e
corretta. Il difetto non e nella regola, e nel suo **perimetro**: e stata estesa a
una materia che quel decreto non tocca.

Due dettagli di quel comma che valgono oltre questa scheda:

- dice **«azienda o unita produttiva»**, non «azienda». Il piu alto si prende dentro
  l'unita produttiva — cioe **per sede**, esattamente come ha deciso la
  [scheda 1](1-sede-o-azienda.md) per il gruppo di primo soccorso.
- dice **«indice piu elevato»**, e l'indice sono le statistiche INAIL di inabilita
  permanente, triennali e pubblicate in Gazzetta. Non e un giudizio: e un numero — che
  pero **non e ancora in `fonti/`** (vedi le sentinelle in
  [`registro-normativa.md`](../registro-normativa.md)).

### Meta senza fonte: per la classe di formazione non esiste, e l'ho cercata

Nessuna delle fonti disponibili dice come aggregare piu codici ATECO per determinare
la classe di rischio della formazione. Verificato, non supposto:

| dove ho guardato | esito |
| --- | --- |
| **Allegato IV dell'ASR 2025** | non ha ne premessa ne istruzioni d'uso: dal titolo passa direttamente a «Rischio BASSO». Nessuna regola di aggregazione |
| **FAQ interregionali 31/07/2025** (63 quesiti) | nessun quesito sui codici multipli |
| **FAQ interregionali 27/03/2026** (44 quesiti) | nessun quesito sui codici multipli |
| **FAQ Regione Veneto** | nessun quesito sui codici multipli |
| **ASR 2025, testo integrale** | le parole «multiservizi», «rischio maggiore», «prevalente» (in senso di attivita) non compaiono |

L'unica regola vicina sta nell'**Accordo 221/2011**, ed e **abrogata** — nel 2025 non
ha equivalente:

> «Qualora il lavoratore, all'interno di una stessa azienda multiservizi, vada a
> svolgere mansioni riconducibili ad un settore a rischio maggiore, secondo quanto
> indicato in Allegato II, costituisce credito formativo sia la frequenza alla
> Formazione Generale, che alla Formazione Specifica di settore gia effettuata; tale
> Formazione Specifica dovra essere completata con un modulo integrativo.»

**E dice il contrario di «si prende il piu alto».** Non alza la classe dell'azienda:
segue la **mansione** della persona, e quando la mansione sale integra la formazione
di quel singolo lavoratore. Il piu alto non viene mai applicato a tutti.

### Tre fonti concordi: la classe segue la mansione, non l'azienda

Le **FAQ interregionali del 31/07/2025, quesito 57**, lo dicono per esteso e citano
la propria genealogia:

> «Il principio che il livello di rischio della formazione specifica si poteva
> svincolare dal codice Ateco, avendo riguardo anche alle mansioni concretamente
> svolte in azienda dal lavoratore purche l'inquadramento fosse coerente con la
> Valutazione dei rischi (es. le mansioni di ufficio erano considerate a rischio
> basso, se non frequentavano i reparti produttivi), era gia stato espresso nelle
> linee applicative del 25/7/2012 degli Accordi 2011 e nell'Interpello n. 11 del
> 24.10.2013.»

E l'esempio che portano e la direzione **verso l'alto**, non verso il basso: un
lavoratore della riparazione veicoli, ATECO G45 classificato **basso**, «in
considerazione dei rischi riferiti alle mansioni e ai possibili danni cui e esposto,
potra prevedere una formazione a rischio medio o alto, sulla base di quanto riportato
nella valutazione dei rischi».

Con l'Interpello 1/2025 e l'11/2013 gia in scheda, sono **tre fonti concordi** su un
punto solo: la classe e della **mansione verificata contro il DVR**, e l'ATECO e il
default da cui si parte.

## Cosa questo cambia nella domanda

La domanda «si prende il piu alto?» **e mal posta a livello di azienda**, e nessuna
fonte la risolvera mai, perche nessuna fonte classifica le aziende: classificano le
attivita, e le persone lavorano in una di esse.

La costruzione che le fonti reggono e questa, in tre pezzi:

1. **Default per sede.** La classe di partenza e quella dell'ATECO della sede — che
   e gia la decisione della scheda 1. Se una sede ha piu ATECO, li si prende il piu
   alto **come prassi dichiarata**, non come lettura: rango 6 della gerarchia della
   [scheda 7](7-base-normativa.md), marcata come tale.
2. **Il default si sposta per mansione**, nei due versi, e lo sposta il DVR. Serve un
   campo che porti motivazione e fonte, non un ricalcolo silenzioso.
3. **Per il gruppo di primo soccorso il piu alto resta la lettera del DM 388**, art. 1
   c. 2, dentro l'unita produttiva. Quella riga si cita, non si dichiara.

Il punto 1 e l'unico che resta senza fonte, ed e molto piu piccolo di quello che la
scheda si chiedeva all'inizio: non «come si classifica un'azienda», ma «cosa si
scrive come default quando una sola sede ha due ATECO di classe diversa».

## Cosa resta da scrivere

- Se la regola vale, **con quale fonte** — per il primo soccorso c'e ed e esatta; per
  la formazione non c'e, e la scelta e fra prassi dichiarata e niente;
- se vale a livello di **azienda**, di **sede** o di **persona** — che dipende anche
  dalla scheda [1](1-sede-o-azienda.md), e che le fonti trovate spingono verso
  **sede per il default, persona per il valore applicato**.

## Decisione

**Presa da Francesco il 9 settembre 2026: dipende dalla mansione.**

E' la piu' esigente delle tre strade possibili — non la prevalente, non la piu'
alta d'ufficio — ed e' quella che l'Interpello 1/2025 consente esplicitamente.

### La meta' che era gia' costruita

Il meccanismo **esiste gia' e funziona**, e nessuno lo usa.

`persona.livello_rischio` e' nello schema dalla migrazione `015`, con il suo check.
E il motore lo legge **con la precedenza giusta**, `formazione.ts:796`:

    const rischio = d.persona.livello_rischio ?? rischioCliente;

Cioe': se la persona ha un livello suo, quello vince; altrimenti eredita. E'
esattamente la semantica della decisione, scritta nel codice da prima che la
decisione fosse presa. Manca solo che qualcuno lo popoli: l'import scrive il
livello **sul cliente** e mai sulla persona, quindi oggi tutte e 3.420 le persone
ereditano.

### Cosa cambia, con le decisioni 1 e 8

- **Il ripiego non e' piu' il cliente, e' la sede** (decisione 1). La catena
  diventa `persona.livello_rischio ?? sede.livello_rischio`.
- **Lo scostamento della persona vuole la stessa nota dello scostamento della
  sede** (decisione 8): motivazione, fonte, quando e chi. Non due meccanismi:
  **lo stesso, a due livelli.** Una persona classificata sotto la sua sede senza
  una riga che dica perche' e' la cosa che in un'ispezione non si difende.

### E la regola «si prende il piu alto» non sparisce: si ridimensiona

Resta necessaria in un caso solo — **una sede con piu' codici ATECO e nessuna
determinazione per mansione** — e li' vale come **default prudenziale**, non come
lettura della norma.

Con la distinzione che il corpo di questa scheda ha stabilito e che va tenuta
ferma, perche' le due meta' hanno statuti diversi:

- **per il gruppo di primo soccorso la citazione al DM 388/2003 e' giusta e va
  tenuta**: l'art. 1 c. 2 ultimo periodo dice il «piu alto» testualmente, e dice
  anche **dentro quale perimetro** — «azienda o unita' produttiva». Cioe' **per
  sede**. Non e' piu' solo cio' che ha deciso la scheda 1: e' la lettera del
  decreto, e la decisione 1 ne risulta confermata dall'esterno;
- **per la classe di rischio della formazione la stessa citazione non regge**,
  perche' quel decreto disciplina il primo soccorso. Li' il criterio puo' restare,
  ma come **precauzione dichiarata da noi** — rango 6 della gerarchia — e senza
  appoggiarsi al DM 388.

La correzione da fare a valle e' quindi piu' stretta di «togliere la citazione»:
va **separato l'uso**, non cancellato il riferimento.

### Quanto lavoro e', misurato

Sui dati veri appena importati:

| | |
| --- | ---: |
| persone con una mansione dichiarata | 2.890 su 3.502 |
| mansioni distinte | 619 |
| coppie **(sede, mansione)** distinte | **1.184** |

Le piu' frequenti sono poche e grosse: OPERAIO 497, ADDETTO PULIZIE 205, IMPIEGATO
127, IMPIEGATA 108, ADDETTA PULIZIE 71, TITOLARE 52.

**Il numero che conta e' 1.184, non 3.420**: la classificazione si fa per **coppia
(sede, mansione)** e si applica a tutte le persone che ci ricadono, non persona per
persona. E le prime dieci mansioni coprono una quota larga del totale, quindi il
lavoro utile e' molto meno di 1.184.

Da notare, perche' e' lavoro che si crea da solo: OPERAIO/IMPIEGATO/IMPIEGATA e
ADDETTO/ADDETTA PULIZIE sono **la stessa mansione scritta in due modi**. Le 619
mansioni distinte sono in buona parte grafie, non ruoli: normalizzarle prima
riduce il lavoro e non e' un abbellimento.

### Cosa resta da decidere, ma non blocca

Se una persona **senza** mansione dichiarata (612 su 3.502) erediti dalla sede in
silenzio o vada segnalata come da classificare. Si decide quando si disegna la
schermata.

---

*Fonti cercate il 9 settembre 2026 su: ASR 59/2025 testo integrale, Accordo 221/2011
testo integrale, DM 388/2003, le tre raccolte di FAQ in `fonti/`, Interpello 1/2025.
Non consultati perche privi di livello di testo: Accordo 153/CSR del 25/07/2012 e
Accordo RSPP 128/CSR del 2016, entrambi scansioni — l'Interpello 11/2013 e citato
per il tramite delle FAQ, non letto in originale. Si rimisura ripetendo la ricerca
sui quesiti delle FAQ e sul testo dell'accordo vigente.*
