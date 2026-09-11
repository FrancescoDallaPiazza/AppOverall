# 11 · Il livello antincendio e il gruppo di primo soccorso: chi li confronta?

> **Blocca:** il **motore**, non lo schema · e va decisa **prima del primo import di attestati di emergenza**, perché nell'intervallo produce conformità apparenti

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

**2. Quale livello assolve quale, e questa è norma.** «Un livello superiore assolve
l'inferiore» **sembra** ovvio e non si deduce qui: le fonti sono il **DM 02/09/2021**
per l'antincendio e il **DM 388/2003** per il primo soccorso, e nessuno dei due è
stato letto su questo punto. Per i gruppi di primo soccorso **non è nemmeno un
ordinamento nello stesso verso**: non è che il gruppo C assolve il gruppo A. È la
stessa forma del caso RSPP — una classificazione che sembra chiara e che solo chi
risponde dell'adempimento può confermare.

Sotto **A7**: finché quella regola non porta parte, punto e pagina, non entra nelle
tabelle. Ma **non guardare il livello affatto** non è la posizione prudente: è la
posizione che produce conformità apparenti.

## Decisione

*(da scrivere. Sono due righe, e la prima non aspetta la norma: se il motore deve
confrontare il livello — sì o no — e dove sta il livello richiesto. La seconda, quale
livello assolve quale, aspetta la lettura del DM 02/09/2021 e del DM 388/2003, e
intanto la forma prudente è **corrispondenza esatta**: `AI_LIV3` richiesto, `AI_LIV3`
accettato, e tutto il resto scoperto. Sbaglia per difetto, che è il verso in cui un
errore si vede.)*

---

*Misure dell'11 settembre 2026. AppSopralluoghi: `505e880`,
`docs/c1a/livelli-emergenza-non-confrontati.md` — i quattro campi vuoti su 619 righe
ciascuno, i sette chiamanti enumerati, `scegliFormazione` e la dichiarazione di
`formazione.ts:845`. AppFormazione: `75d10ee`, `docs/08-le-regole-obbligo-corso.md`
— gli 11 titoli antincendio sullo stesso obbligo, il livello su `clienti`, e i 6
titoli che lo portano nel testo.*
