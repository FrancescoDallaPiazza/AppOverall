# 5 · Le divisioni 30, 86 e 87: alto rischio, o silenzio?

**Non blocca una fase.** Ma finche resta aperta, **32 codici ATECO non hanno una
classe di rischio**.

## Il fatto

L'Allegato IV dell'ASR 2025 non classifica tre divisioni:

| divisione | sezione | titolo |
| --- | --- | --- |
| **30** | C | Fabbricazione di altri mezzi di trasporto |
| **86** | Q | Assistenza sanitaria |
| **87** | Q | Servizi di assistenza sociale residenziale |

Bloccano 32 dei 1.290 codici ATECO 2025 foglia — 14 di altri mezzi di trasporto, 14
di assistenza sanitaria, 4 di assistenza sociale residenziale — piu altri 13 che a
una classe ci arrivano, ma passando anche per una divisione non classificata.

## Dove tace la fonte, esattamente

La lista del rischio ALTO si chiude con «Q - SANITA E ASSISTENZA SOCIALE» e sotto
**non riporta nessun codice**: e l'ultima riga di **pagina 136**. La divisione 88 e
classificata media altrove; la 86 non e classificata.

Per la 30, il titolo «Fabbricazione di altri mezzi di trasporto» compare accostato
al codice 33, quindi e *probabile* che l'intenzione fosse il rischio alto — ma
probabile non e scritto.

Il buco e confermato su tre rese indipendenti dell'accordo — le due di `fonti/` e il
`.txt` di Organigramma-sicurezza: non e un artefatto di scansione.

## L'indizio

La libreria normativa `formazione-81-utils-src` le classifica **tutte e tre `ALTO`**.
Ma **senza citare**: il commento accanto e un raggruppamento («Sezione Q — Sanita»),
e la sua tabella e dichiaratamente ricostruita da fonti incrociate. Vale come
indizio, non come fonte.

## Le fonti, cercate il 9 settembre 2026 — e l'esito e diviso

**Le tre divisioni non sono lo stesso caso, e non vanno decise insieme.** La prima
stesura di questa sezione le trattava come una cosa sola e sbagliava su una delle
tre; la correzione e arrivata dalla corsia AppFormazione e l'ho verificata di
persona sul testo coordinato del D.Lgs. 81/2008 (Amato-Di Fiore, edizione gennaio
2026), che riporta per intero gli accordi del 2011 **con il loro Allegato 2**.

### 86 e 87 — confermate, e su tre rese indipendenti

Nell'**Allegato 2 dell'Accordo Stato-Regioni 21/12/2011, Rep. Atti 221/CSR** stanno
sotto `Rischio ALTO`:

    Q - SANITÀ E ASSISTENZA SOCIALE
    86 - ASSISTENZA SANITARIA
    87 - SERVIZI DI ASSISTENZA SOCIALE RESIDENZIALE

e la `88` sta sotto `Rischio MEDIO`, dov'e anche nel 2025. Verificato su **tre rese**:
la ripubblicazione della Regione Abruzzo, e **due blocchi distinti** del testo
coordinato — l'accordo lavoratori e quello datori di lavoro portano entrambi la
tabella.

**E qui il 2025 le ha perse di stampa.** Nel 2011 la lista ALTO si chiude con
`Q - SANITA' E ASSISTENZA SOCIALE` e sotto le sue due righe. Nel 2025 si chiude con la
stessa intestazione **e non ha nulla sotto**, ed e l'ultima riga di pagina 136, cioe
dell'intero accordo. L'intestazione e rimasta esattamente dov'era; le due righe che le
stavano sotto no.

E **un'intestazione sopravvissuta al proprio contenuto**: la stessa forma di difetto
di R5 nella [scheda 7](7-base-normativa.md), un insieme incompleto che si presenta
come completo. Qui l'intestazione fa da falsa conferma — c'e un titolo, quindi sembra
che qualcuno abbia deciso, mentre e solo il contenitore di cio che si e perso.

### 30 — la ricostruzione non regge, e l'errore ha quindici anni

**Nel 2011 c'era gia scritto `33`.** Il testo coordinato riporta, sotto `Rischio ALTO`
dell'Allegato 2 del 2011:

    29 - FABBRICAZIONE DI AUTOVEICOLI, RIMORCHI E SEMIRIMORCHI
    33 - FABBRICAZIONE DI ALTRI MEZZI DI TRASPORTO
    31 - FABBRICAZIONE Dì MOBILI
    32- ALTRI INDUSTRIE MANIFATTURIERE

**Gli stessi refusi che questa scheda attribuiva al 2025 sono nel 2011**, «Dì MOBILI»
compreso. Il 2025 non ha perso il `30`: ha ricopiato fedelmente il `33` che aveva
davanti. L'argomento della sequenza resta valido — stessa posizione, stesso titolo —
ma la conclusione si rovescia, perche il numero era gia sbagliato nella fonte da cui
il 2025 copia.

**Nessuna fonte che possediamo scrive `30` in quella posizione.**

### Perche mi ero convinto del contrario, che e la parte da tenere

La resa su cui avevo verificato — Regione Abruzzo, SPSAL — scrive `30`, `31 -
FABBRICAZIONE DI MOBILI` e `32- ALTRE INDUSTRIE MANIFATTURIERE`: **pulita**. Ma non e
la Gazzetta: e la stampa di una pagina di CMS, e lo dichiara in testa a ogni pagina —
*«Mercoledì 04 Gennaio 2012 14:33 - Ultimo aggiornamento Giovedì 12 Gennaio 2012
16:55»*. E datata **una settimana prima** della pubblicazione in Gazzetta dell'11
gennaio 2012: e una ritrascrizione d'ufficio, e chi la batteva ha normalizzato gli
errori evidenti. Chi corregge «Dì MOBILI» corregge anche un `33` che non torna.

La lezione, e non e quella di R5: **una copia piu pulita non e una copia migliore.**
La pulizia di una resa e un indizio di ritrascrizione, cioe di distanza dalla fonte —
e va letta come un allarme, non come una conferma di accuratezza. Avevo scambiato
l'assenza di refusi per fedelta.

### Cosa fa oggi la libreria, e non e una copia di niente

`allegato_iv_asr2025.js` classifica **`ALTO` sia la 30 sia la 33**, e alla `33` da la
sua descrizione vera («Riparazione, manutenzione ed installazione di macchine ed
apparecchiature»), che nell'accordo non compare. Cioe ha **sciolto in due righe
un'ambiguita che nella fonte e una riga sola**, prendendo il numero *e* il titolo e
dando alto a entrambi. E la lettura massimamente prudente, e non e dichiarata: sotto
R2 nessuna delle due righe puo citare.

### Un riscontro dentro l'accordo del 2025 stesso

L'ASR 2025 **non ignora** la 86 e la 87: le usa altrove. Nella tabella dei moduli di
specializzazione RSPP, il modulo **B-SP4** e definito su `Q - Sanità e assistenza
sociale (86.1 - Servizi ospedalieri e ... 87 - Servizi di assistenza sociale
residenziale)`. Un accordo che avesse voluto togliere la sanita dalla classificazione
del rischio non le avrebbe intestato un modulo di specializzazione.

### Che valore ha questa fonte, detto con precisione

**L'Accordo 221/2011 e abrogato** dall'ASR 2025, e va detto invece di lasciarlo
implicito: non e una fonte che dica cosa vale *oggi*. Sotto la gerarchia della scheda
7 e rango 2, ma abrogato — quindi **non si applica**.

Serve a una cosa diversa e piu stretta: **stabilire cosa il testo vigente stia
tentando di dire nel punto in cui la sua resa e difettosa.** Non e applicare la norma
del 2011, e ricostruire la lettera di quella del 2025. La differenza conta, perche
regge l'una e non l'altra:

- **Non regge**: «l'Accordo 221/2011 dice che la 86 e alta, quindi e alta». Falso, e
  abrogato.
- **Regge**: «l'Allegato IV del 2025 riprende la tabella del 2011; in tre punti la sua
  stampa e difettosa in modi dimostrabili; la fonte da cui deriva dice cosa c'era».

Sotto **A7** resta quindi una **deduzione, non una lettura** — ma una deduzione con
base documentale citabile, che e un'altra cosa dall'`ALTO` non citato della libreria.
E sotto **R2** della scheda 7 e una riga che *puo* dire da dove viene.

## Perche non le riempiamo da soli

La regola costituzionale del progetto, assunzione **A7** del programma: *si applica
cio che si legge, con parte, punto e pagina; cio che si deduce aspetta, dichiarato.*
Copiare quell'`ALTO` e chiamarlo fonte sarebbe il primo strappo.

Decidere il contrario e legittimo — ma va deciso qui, sapendo che e uno strappo, e
non lasciato all'inerzia. E l'unica delle sei decisioni che, se risolta in un certo
modo, **cambia la natura del progetto invece che il calendario**.

## Cosa c'e da decidere adesso: due domande, non una

La ricerca ha spaccato la scheda in due, e le due meta hanno bisogno di risposte
diverse.

### Per 86 e 87 — una scelta fra due, con una base documentale

1. **Si adotta `ALTO`** citando l'Allegato 2 del 221/2011 su tre rese e la
   dimostrazione dell'intestazione rimasta senza contenuto, **marcando le righe come
   derivate** e non lette. Sotto A7 e una deduzione dichiarata, che e esattamente cio
   che A7 prevede.
2. **Si resta a `null`**, accettando che ospedali, case di cura e RSA non abbiano
   classe.

La 1 e coerente con A7 **a condizione che la marcatura arrivi davvero fino ai dati**:
senza, e la 2 travestita da 1.

### Per la 30 — una domanda diversa, e forse senza risposta

Non manca una riga: c'e una riga sola, in cui **il numero e il titolo non
corrispondono**, e sono discordi da quindici anni su ogni resa che possediamo. Quindi:

- **se fa fede il numero**, e `ALTO` la **33** (riparazione e manutenzione di
  macchine) e la **30** resta senza classe;
- **se fa fede il titolo**, e `ALTO` la **30** e resta senza classe la **33**;
- **se si tengono entrambe** — cio che la libreria fa oggi in silenzio — si sceglie la
  lettura piu prudente, e va detto che e una scelta e non una lettura.

Nessuna fonte scioglie il nodo, e non e detto che una fonte lo sciolga mai: **questo
non e un buco di trascrizione, e un difetto del testo.** L'unica strada che lo
chiuderebbe davvero e' esterna a noi — un interpello, o una FAQ che rilevi il refuso.

## Decisione

*(da scrivere, e sono due righe, non una: una per 86 e 87 — dove c'e una fonte da
citare con il suo limite dichiarato — e una per la 30, dove non c'e e la scelta e fra
il numero, il titolo, o entrambi dichiarando la prudenza.)*

---

*Fonti cercate il 9 settembre 2026. Verificate: le tre raccolte di FAQ in `fonti/`
(nessuna tratta i codici non classificati), l'Allegato IV dell'ASR 2025 su tre rese,
l'Allegato 2 del 221/2011 su tre rese — Regione Abruzzo piu due blocchi distinti del
testo coordinato Amato-Di Fiore gennaio 2026 — e `allegato_iv_asr2025.js`. Non
consultata: la Gazzetta Ufficiale n. 8 dell'11/01/2012, che e la sola resa primaria e
l'unica che chiuderebbe la questione della 30. Si rimisura confrontando le liste ALTO
del 221/2011 e del 59/2025 su rese dichiarate, non su ritrascrizioni.*
