# Il catalogo contro ciò che Overall vende davvero

**Riscontro dell'11 settembre 2026**, chiesto da Francesco: leggere le undici pagine
di corso su `overallgroup.info/corsi-sicurezza/` e confrontarle con i 40 codici che
la `0004` ha ricostruito.

**Perché conta.** Fino a oggi i 40 codici avevano due riscontri: le migrazioni del
campo (da cui vengono) e il database di produzione (`aa42ced`, una divergenza su 360
campi). Entrambi interni allo stesso sistema. Il sito è la **prima fonte esterna**:
dice cosa l'azienda vende e su quale norma, e non è stato scritto da chi ha scritto
il catalogo. È l'unico riscontro che poteva smentirlo, non solo confermarlo (A9).

## Ciò che combacia — nove famiglie su undici

| corso | sito | catalogo | |
| --- | --- | --- | :-: |
| lavoratori, generale | 4 h, «non scade mai», credito permanente | `LAV_GEN` 4 h, nessun aggiornamento | ✓ |
| lavoratori, specifica | 4 / 8 / 12 h per rischio basso/medio/alto; agg. 6 h / 5 anni | `LAV_SPEC` ore **variabili**, 60 mesi, 6 h | ✓ |
| preposto | 12 h; agg. 6 h / **2 anni**; propedeutico il corso lavoratore | `PREPOSTO` 12, 24 mesi, 6, prereq. `LAV_SPEC` | ✓ |
| datore di lavoro | 16 h; agg. 6 h / 5 anni; +6 h cantieri | `DATORE_LAVORO` 16, 60, 6 · `CANTIERI` 6 | ✓ |
| datore-RSPP | comune 8 h + settore 12/16; agg. 8 h / 5 anni | `DL_RSPP_COMUNE` 8, 60, 8 · `DL_RSPP_SETTORE` variabile | ✓ |
| antincendio | 4 / 8 / 16 h; agg. 2 / 5 / 8 h ogni 5 anni | `AI_LIV1/2/3` esatti | ✓ |
| primo soccorso, gruppo A | 16 h; agg. 6 h / **3 anni** | `PS_GRA` 16, 36, 6 | ✓ |
| primo soccorso, gruppi B e C | 12 h; agg. 4 h / 3 anni | `PS_GRBC` 12, 36, 4 | ✓ |
| ponteggi | allegato XXI: 28 h | `PONTEGGI` 28, 48 mesi, 4 | ✓ |

Nove su undici **esatte al numero**, aggiornamenti e periodicità compresi — incluse
le due che più facilmente si sbagliano: il preposto a **due** anni invece di cinque, e
il primo soccorso a **tre**. La ricostruzione dalle migrazioni regge contro una fonte
che non la conosceva.

## I quattro buchi, in ordine di conseguenza

### 1. `RLS`: l'aggiornamento dipende dalla dimensione, e il catalogo tiene un numero solo

Il sito: 32 ore iniziali, e l'aggiornamento è **annuale** e differenziato —
**4 ore** per aziende da 15 a 50 lavoratori, **8 ore** oltre 50, e sotto 15
lavoratori la norma non fissa una durata minima (art. 37 c. 10-12, art. 47, art. 50;
l'art. 37 rinvia alla contrattazione collettiva).

Il catalogo ha **una riga**: `RLS` 32 / 12 mesi / **4 ore**. Non può esprimere una
durata che dipende dalla dimensione dell'azienda, quindi **dice 4 a tutti**.

**Conseguenza:** in un'azienda con più di 50 lavoratori il sistema dichiarerebbe
assolto l'aggiornamento dell'RLS con 4 ore, quando ne servono 8. È una **conformità
apparente**, la stessa forma del difetto della scheda 11 — e qui il dato che manca
(il numero di lavoratori) nell'anagrafe **c'è**: `N° DIPENDENTI`, letto su 481 delle
619 attive.

### 2. I corsi combinati non hanno un codice

Il sito vende varianti che il catalogo non distingue:

| | varianti singole | variante combinata |
| --- | --- | --- |
| carrello | 12 h semovente · 12 h braccio telescopico | **16 h entrambi** |
| PLE | 8 h con stabilizzatori · 8 h senza | **10 h entrambi** |
| carroponte | 10 h | **11 h** con cabina e radiocomando |

Il catalogo ha una riga per attrezzatura, con le ore della variante **combinata**:
`ATTR_CARRELLO` 12, `ATTR_PLE` **10**, `ATTR_CARROPONTE` **10**.

**Conseguenza doppia.** Un attestato PLE da **8 ore** è completo per una variante, ma
il catalogo ne aspetta 10 e lo vedrebbe come sotto-durata; e un attestato carrello da
**16 ore** vale per due tipi, e il catalogo non ha dove dirlo. Il controllo delle
durate ordinato al campo produrrà quindi divergenze che **non sono errori**: sono
varianti. Va saputo prima di leggere quei numeri.

### 3. `ATTR_LAV_QUOTA`: la periodicità è prassi, non norma

Il sito è esplicito: per i lavori in quota con DPI anticaduta **«la norma non fissa
scadenze specifiche»**, e i cinque anni sono **prassi consolidata** allineata
all'aggiornamento dei lavoratori. L'addestramento va invece ripetuto quando cambiano
i dispositivi, il luogo, la mansione, o dopo un quasi infortunio (art. 77 c. 5, art.
37 c. 5, artt. 107 e 111; registro dell'addestramento per il D.L. 146/2021).

Il catalogo scrive `ATTR_LAV_QUOTA` 8 / **60 mesi** / 4 come qualunque altra riga:
una **prassi presentata come dato**. Sotto A7 va marcata come derivata — è la stessa
disciplina delle tre divisioni ATECO.

### 4. Manca l'accesso con funi, e due fonti lo dicono insieme

L'allegato XXI, citato dalla pagina dei lavori in quota, prevede **ponteggi 28 ore** e
**accesso con funi 32 ore**. Il catalogo ha `PONTEGGI` e **non ha** le funi.

E combacia con una misura arrivata da AppFormazione per un'altra strada: fra i sei
obblighi che nessun corso assolve ci sono **`lavori_funi`** e **`sorveglianza_funi`**.
Due fonti che non si sono parlate dicono la stessa cosa dai due lati: l'obbligo
esiste, il corso a catalogo no. **Overall non eroga quel corso** — ed è un'informazione
commerciale, non un difetto del catalogo.

## Una riga che riguarda la scheda 11

La pagina dell'antincendio dice una cosa che nessuna delle due corsie aveva trovato:
**«la corrispondenza con le vecchie categorie non è automatica al contrario»** —
cioè fra basso/medio/alto del DM 10/03/1998 e i livelli 1/2/3 del DM 02/09/2021. Non
risponde alla domanda della scheda 11 (se un livello superiore assolva l'inferiore),
ma dice che **le equivalenze in quel dominio sono già state pensate e negate una
volta**, in un'altra direzione. Rafforza la scelta di marcare «pari o superiore» come
**derivata** e non come lettura.

## Cosa non è verificabile da questa fonte, e va detto

Il sito vende **undici famiglie**; il catalogo ha **40 codici**. Restano fuori dal
riscontro: i tre moduli RSPP professionali (`RSPP_MOD_A/B/B_SETTORE/C`), i due BLSD
(`PS_BLSD_LAICO`, `PS_BLSD_SANITARIO`), e undici attrezzature che il sito non ha come
pagina propria — gru (autocarro, mobili, torre), trattori (ruote, cingoli, misto),
escavatori, CMM, raccoglifrutta, pompe per calcestruzzo, autoribaltabili. Per quelle
il catalogo resta con i due riscontri interni che aveva, e **non con tre**.

Non è un buco del riscontro: è il suo perimetro, e conoscerlo vale più che avere un
numero in più.

---

# La terza gamba: cosa è stato erogato davvero

Il sito dice cosa **prevede** l'accordo, il catalogo cosa ci **aspettiamo**, l'export
cosa è **stato erogato**. La terza misura è arrivata l'11 settembre 2026 dalla corsia
AppSopralluoghi (`eddbb44`), confrontando le durate attese delle 40 righe con la
**distribuzione** delle durate reali su 13.348 righe.

**Un risultato che vale da solo: zero titoli dell'export sono fuori dal dizionario.**
I 268 alias coprono tutte le righe — esclusi i 7 parziali e le 461 con alias senza
codice. La curatela del campo non ha buchi di copertura.

## Le quattro righe che il sito aveva messo in dubbio

| | atteso | reale | esito |
| --- | --- | --- | --- |
| `RLS` aggiornamento | 4 h | **4 h ×128 e 8 h ×31** | **confermato sotto-specificato** |
| `PS_GRA` / `PS_GRBC` | 16/6 e 12/4, 36 mesi | 16 ×269 · 6 ×290 · 12 ×390 · 4 ×525 | **nessun difetto**, 4 su 4 al 100% |
| antincendio 1/2/3 | 4/2 · 8/5 · 16/8, 60 mesi | 105/80 · 630/508 · 12/6 | **pulito**, 6 su 6 al 100% |
| `ATTR_CARRELLO` | 12 h | 12 ×298 e **16 ×30** | le 30 sono il **combinato** |

**Il mio timore sul primo soccorso era infondato nei fatti**, e va detto: la
triennalità c'era già, `aggiornamento_mesi` è 36 su entrambi i codici. Le 31 righe
dell'RLS a 8 ore invece non sono un errore del gestionale: **sono le aziende oltre i
cinquanta lavoratori**, cioè il numero che il sito prevede e che il catalogo non sa
scrivere.

## La distinzione che un conteggio secco avrebbe nascosto

Fra una **seconda durata legittima** e un'**attesa sbagliata**: le prime chiedono un
codice in più, le seconde chiedono di cambiare un numero. Con «quante divergono»
sarebbero finite nello stesso mucchio.

- **seconda durata legittima** — `ATTR_CARRELLO` 16 h ×30, `ATTR_ESCAVATORI` 16 h ×32
  contro 10 ×13 (il combinato con pale e terne, che la nota del catalogo **già
  cita**), `ATTR_GRU_TORRE` 14 h ×22 contro 12 ×12;
- **attesa sbagliata** — `PS_BLSD_SANITARIO`, che a catalogo non ha aggiornamento e
  nei dati ne ha 20 righe.

## Tre cose più grosse, che nessuna delle due fonti precedenti aveva visto

### `DL_RSPP_BASE` raccoglie quattro regimi, su un codice deprecato

    aggiornamento (atteso 6):  6 h ×76 · 14 h ×36 · 8 h ×26 · 10 h ×23
    iniziale      (atteso 16): 16 h ×103 · 48 h ×33 · 32 h ×23 · 8 h ×4 · 24 h ×3

Sono gli aggiornamenti dell'art. 34 **per classe di rischio** — 6 basso, 10 medio, 14
alto — più l'8 generico: esattamente i numeri che hanno rovesciato la regola delle
ore. E quel codice ha `attivo = false` dalla `049`: **161 aggiornamenti e 166 iniziali
mappano su un corso deprecato**. Fa quello per cui la deprecazione lo aveva
conservato — reggere gli attestati storici — ma non ha un successore per le varianti
di rischio.

### `DIRIGENTE`: non è un'attesa sbagliata, è il regime vecchio

Atteso 12 ore, reale **16 h ×12**, zero su dodici. La corsia l'ha classificata come
«attesa sbagliata», e **la prova che non lo è sta in una nota di questo stesso
catalogo**: «ASR 17/04/2025: 12h (**erano 16h con accordo 2011**)». Le dodici righe a
16 ore sono attestati del regime precedente — la stessa forma del `PREPOSTO`, che ha
**8 h ×276 e 12 h ×38**: il regime pre-accordo e quello nuovo sotto un codice solo,
separati **nel tempo e non nello spazio**.

Il test che distingue le due letture è **la data**: se le dodici righe a 16 ore
precedono il 17 aprile 2025, è il regime vecchio e il catalogo ha ragione.

## Il limite dichiarato, e non è del metodo

Il dizionario, in questa misura, è **simulato dai file** del repo e non letto dal
database: l'SQL Editor di Supabase ha smesso di accettare input a metà lavoro — i
tasti finiscono nelle scorciatoie e la pagina salta altrove, quattro volte. La
simulazione riproduce i **tre aggregati** letti dal database (237 mappati, 98
aggiornamenti, 7 parziali) e su quelli coincide, ma non è una verifica riga per riga.
Sotto **A10** vale «i file dicono».
