# 11 · Il livello antincendio e il gruppo di primo soccorso: chi li confronta?

> **Blocca:** il **motore**, non lo schema · finché era aperta, un livello 1 valeva quanto un livello 3
> **In una riga:** **tre stati** — livello definito e attestato pari o superiore: conforme; definito e inferiore: non conforme; **non definito: si segnala e non si blocca l'import**

**Nata da due misure indipendenti**, l'11 settembre 2026, una per corsia — e le due
corsie hanno lo stesso difetto in due forme opposte.

## Il fatto

Un addetto antincendio si forma su un **livello** (1, 2 o 3, secondo il rischio del
luogo di lavoro) e un addetto al primo soccorso su un **gruppo** (A, B o C). Il
livello richiesto dipende dall'azienda; quello posseduto sta nell'attestato.

**Nessuno dei due sistemi confronta le due cose.**

| | AppSopralluoghi | AppFormazione |
| --- | --- | --- |
| dove sta il livello richiesto | `cliente` **e** `sede` (migrazioni 041/050 e 054) | `clienti.livello_rischio_incendio`, `clienti.gruppo_primo_soccorso` |
| quante righe lo dichiarano | **0 su 619**, in tutti e quattro i posti | raccolto nella scheda di ingresso |
| dove sta il livello posseduto | nel codice del corso — `AI_LIV1/2/3`, `PS_GRA/PS_GRBC` | **nel testo del titolo**, su 6 degli 11 titoli antincendio |
| chi li confronta | **nessuno** | **nessuno**: tutti gli 11 titoli puntano allo stesso obbligo |

## Il meccanismo, enumerato e non cercato

In AppSopralluoghi la funzione `corsoEmergenzaRichiesto` (`formazione.ts:332`)
**conosce** il livello e restituisce il corso preciso. I suoi **sette** chiamanti
sono stati enumerati: quattro in `OrganigrammaView.tsx`, uno in
`organigramma-revisioni.ts`, e uno in `proponiCoseDaFare` — tutti per **mostrare**
cosa serve, o per figure **scoperte**, dove non c'è nessun attestato da confrontare.

**Il motore di valutazione non la chiama mai.** `scegliFormazione`
(`formazione.ts:582`) fa:

```
if (f.corso_codice === req.corso_codice) return true;
if (req.per_categoria && categoria(f) === req.categoria) return true;
```

e le tre righe `per_categoria` sono esattamente antincendio, primo soccorso e
attrezzature. Quindi **`AI_LIV1` vale quanto `AI_LIV3`**.

**E non è una svista.** `formazione.ts:845` lo dichiara: «per questi **non** si
assume un livello». La decisione di non inventare un livello quando non lo si sa è
**giusta**, ed è la stessa disciplina di A7. L'effetto collaterale non era nel
mirino: quando il livello **lo si sa** e l'attestato è inferiore, nessuno se ne
accorge.

## Perché lo zero di oggi non è una buona notizia

Le persone scoperte oggi sono **zero**, e quel numero non dice niente: zero nomine,
zero attestati di emergenza, zero livelli definiti — **tre assenze indipendenti**,
tutte «mancanza di dati». È la terza volta che questi repo incontrano **un'assenza
che si presenta come un insieme completo**.

Il difetto è **latente**, e diventa reale al primo import che porta dentro attestati
di emergenza. In quel momento non produce errori visibili: produce **conformità
apparenti**. Un errore lo vedi; una conformità falsa no.

**E c'è un ordine che conta.** Oggi, coi livelli vuoti, `corsoEmergenzaRichiesto`
risponde `{definito: false}` su tutti i clienti, cioè l'app chiede di definire il
livello prima di dire qualunque cosa. **È una protezione accidentale**, e sparisce
appena qualcuno compila quel campo. Se gli attestati entrano **prima** che i livelli
siano definiti, nell'intervallo il sistema dice «in regola» a chi non lo è.

## I due difetti sono speculari, e servono entrambe le correzioni

- **AppSopralluoghi inventa non conformità**: i codici per livello esistono, e una
  regola scritta come coppia — `addetto_antincendio` → `AI_LIV2` — dichiarerebbe
  scoperti i livelli 1 e 3. È la trappola `per_categoria`, chiusa nella `0004` dando
  a `corso_assolve` la forma «questo corso **oppure** qualsiasi corso di questa
  categoria».
- **AppFormazione perde non conformità**: il molti-a-uno *è* già il meccanismo di
  categoria, quindi la trappola non può esistere — ma il livello scritto nel testo di
  6 titoli su 11 viene **buttato via** dalla classificazione, e un livello 1 in
  un'azienda di livello 3 risulta in regola.

La `0004` ha risolto il primo. **Il secondo non è risolto da nessuna parte**, e la
forma di `corso_assolve` scritta oggi — «qualsiasi corso della categoria» — lo
**riproduce**: è esattamente la regola che accetta `AI_LIV1` dove serve `AI_LIV3`.

## Cosa è in gioco, e cosa non decidiamo noi

Due cose distinte, e solo la prima è una decisione di costruzione.

**1. Che il motore guardi il livello.** Oggi non lo guarda, e questo è il punto che
decide la forma: anche la regola normativa più ben citata non serve a niente finché
`scegliFormazione` accetta qualunque corso della categoria. Nel repo nuovo il livello
richiesto sta sulla **sede** (decisione 1) e in **un posto solo** — non in due come
oggi — e `corso_assolve` ha bisogno di un modo per dire «della categoria, **ma non
sotto il livello richiesto**».

**2. Quale livello assolve quale — e la norma è stata letta.** Le due fonti erano nel
corpus, ora a monte in `formazione-81-utils-src/reference/`, e sono state lette l'11
settembre 2026 con parte, punto e pagina come pretende R2.

**Antincendio — DM 02/09/2021, allegato III.** Punti 3.2.1, 3.2.2 e 3.2.3 a
**pagina 21**, punto 3.2.4 a **pagina 22**. Il comma 2 è ripetuto identico nei tre
punti, e cambia solo il tipo:

> 3.2.2 c. 2 (livello 3, p. 21): «I corsi di formazione e i corsi di aggiornamento
> per gli addetti operanti nelle sopra riportate attività devono essere basati sui
> contenuti e la durata riportati nei punti 3.2.5 e 3.2.6 **per i corsi di tipo 3**
> (FOR o AGG).»

— e lo stesso per il tipo 2 (3.2.3 c. 2, p. 21) e il tipo 1 (3.2.4 c. 2, p. 22). Il
3.2.1 c. 1 lega il corso al livello: i corsi «devono essere **correlati al livello di
rischio dell'attività**». Durate al 3.2.5 (4, 8, 16 ore), aggiornamenti al 3.2.6 (2,
5, 8).

**Cercata e non trovata** l'equivalenza fra livelli: le disposizioni transitorie
(art. 7 c. 1-3) riguardano solo i corsi già programmati sotto il DM 10/03/1998 e la
scadenza del primo aggiornamento, e l'unica deroga del decreto è soggettiva e
riguarda il Ministero della difesa.

**Primo soccorso — DM 388/2003.** Art. 1 c. 1 (**p. 1**): il gruppo A è un **elenco
di tipi di attività**; il gruppo B è «tre o più lavoratori che non rientrano nel
gruppo A»; il gruppo C «meno di tre lavoratori che non rientrano nel gruppo A».
**Due criteri diversi** — tipo di attività e numero di lavoratori — non una scala di
gravità: «assolve» non è la domanda giusta. Art. 3 (**p. 7**): il c. 3 manda il
gruppo A all'allegato 3, il c. 4 manda **i gruppi B e C allo stesso allegato 4**.
Quindi i corsi sono **due e non tre**, e i codici del campo `PS_GRA` / `PS_GRBC` sono
già la forma giusta: la domanda è **binaria**.

**Una riga del comma 3 che nessuno ha discusso**, e che sposta il problema: il corso
di gruppo A deve trattare «**anche la trattazione dei rischi specifici dell'attività
svolta**». Quel corso è quindi legato all'attività in cui la persona opera, non solo
al gruppo — ed è un argomento contro la portabilità automatica di un attestato di
gruppo A **anche fra due aziende entrambe di gruppo A**.

**Quindi il mio «piano B» era più timido del necessario, e va detto.** Questa scheda
diceva che, non trovando la norma, si sarebbe chiusa su «corrispondenza esatta»
dichiarata come **deduzione prudente**. Non serve dichiararla: la corrispondenza
esatta **è la lettera dei due decreti**. Ciò che sarebbe una deduzione è il
**contrario** — ammettere la sostituzione verso il basso, o verso l'alto. Il testo
non la vieta e non la concede: **non la tratta**.

Sotto **A7** resta vero il principio, e cambia il verso in cui si applica: non
guardare il livello affatto non è la posizione prudente — è la posizione che produce
conformità apparenti, e oggi `scegliFormazione` la tiene senza che nessuno l'abbia
decisa. **Accettare qualunque corso della categoria è già una risposta**, ed è la più
permissiva delle tre.

## Decisione

**Presa da Francesco l'11 settembre 2026**, e la sua prima mossa è stata rifiutare la
domanda come era posta:

> «Ma se il livello di rischio dell'azienda non è ancora stato chiesto, come si fa?»

La domanda presupponeva un livello noto, e oggi è **vuoto su tutte e 619 le righe**,
in quattro posti. Nelle sue parole:

> «La ratio è che se il livello è stato già scelto, il corso di formazione dovrebbe
> essere pari o di livello superiore. Se il livello non è stato scelto, si può
> segnalarlo ma non bloccare l'importazione.»

**Tre stati, non due.** È questo il punto che la scheda non aveva visto: la risposta
non è una soglia, è una macchina a tre stati.

| livello della sede | attestato | esito |
| --- | --- | --- |
| **definito** | pari o superiore | **conforme** |
| **definito** | inferiore | **non conforme** |
| **non definito** | qualunque | **segnalazione**, e l'import non si blocca |

**Cosa cambia rispetto a oggi, in concreto:**

- `scegliFormazione` non può più accettare qualunque corso della categoria. Il
  confronto col livello **entra nel motore**, ed è la prima delle due righe che
  questa scheda aspettava;
- il terzo stato **non è un ripiego**: è la decisione che tiene insieme il fatto che
  i livelli non sono ancora stati raccolti e il fatto che gli attestati arrivano
  comunque. Senza di esso l'import si sarebbe fermato su 619 clienti, oppure avrebbe
  dichiarato conformi tutti;
- e sostituisce la **protezione accidentale** con una esplicita: prima era
  `{definito: false}` a fermare tutto per caso, adesso è una segnalazione dichiarata
  che dice *perché* non si può giudicare.

**«Pari o superiore» è una decisione, non una lettura, e va marcata come tale.** I
decreti non la contengono: il DM 02/09/2021 assegna a ciascun livello il proprio tipo
di corso e **tace** sulla sostituzione verso l'alto. Quindi nello schema quella regola
porta la stessa marcatura delle tre divisioni ATECO della scheda 5 — **derivata, con
chi l'ha decisa e quando** — e non si presenta come norma citata. Se un chiarimento
ufficiale dirà altro, si cambia una riga e non un impianto.

**E per il primo soccorso «superiore» non esiste**, che è una conseguenza della sua
regola e non una nuova domanda. Il DM 388/2003 art. 1 c. 1 costruisce i gruppi su
**due criteri diversi** — tipo di attività per A, numero di lavoratori per B e C —
quindi non c'è una scala su cui essere «superiori». I corsi sono due (art. 3 c. 3 e
c. 4, allegati 3 e 4), e la regola applicabile è la **corrispondenza**: gruppo A
vuole il corso dell'allegato 3, gruppi B e C quello dell'allegato 4. I codici del
campo `PS_GRA` / `PS_GRBC` sono già questa forma.

### Cosa resta da decidere, ma non blocca

Se un attestato di **gruppo A** sia portabile fra due aziende entrambe di gruppo A.
L'art. 3 c. 3 vuole che quel corso tratti «anche la trattazione dei **rischi
specifici dell'attività svolta**», quindi è legato all'attività e non solo al gruppo.
Nessuno dei due sistemi oggi si pone la domanda, e non la pone nemmeno questa scheda:
si decide quando un cliente nuovo porterà l'attestato di gruppo A di un'altra azienda
— che è il progetto degli attestati del cliente nuovo, non questo.

---

*Misure dell'11 settembre 2026. AppSopralluoghi: `505e880` (i quattro campi vuoti, i
sette chiamanti enumerati, `scegliFormazione`) e `1fb4eb2` (le citazioni dei due
decreti, lette a video sul PDF). AppFormazione: `75d10ee` (gli 11 titoli antincendio
sullo stesso obbligo, il livello su `clienti`, i 6 titoli che lo portano nel testo).
Le fonti stanno in `formazione-81-utils-src/reference/fonti/`: `D.M. 02_09_2021.pdf`
e `Decreto Min. Salute n. 388_2003.pdf`.*
