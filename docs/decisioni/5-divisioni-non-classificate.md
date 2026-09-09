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
al codice 33.

Il buco si presenta identico su piu rese dell'accordo del 2025 — le due di `fonti/` e
il `.txt` di Organigramma-sicurezza. **Ma quelle rese non sono indipendenti**: e la
prima cosa che questa scheda ha sbagliato, e la sezione qui sotto la corregge.
Discendono tutte dallo stesso testo, e ripetere la stessa fonte non e confermarla.

## L'indizio

La libreria normativa `formazione-81-utils-src` le classifica **tutte e tre `ALTO`**.
Ma **senza citare**: il commento accanto e un raggruppamento («Sezione Q — Sanita»),
e la sua tabella e dichiaratamente ricostruita da fonti incrociate. Vale come
indizio, non come fonte.

## La fonte primaria: la Gazzetta, e dice 30

Questa sezione e stata riscritta tre volte in un pomeriggio, e le prime due erano
sbagliate. Vale la pena tenerne conto quando si legge la terza: quello che segue e
l'unico stato che poggia su una fonte **primaria** invece che su una copia.

**GU Serie generale n. 8 dell'11 gennaio 2012, pagina 48, atto 12A00059** — Allegato
II del 221/CSR, elenco `Rischio ALTO`. Letto a video sull'immagine della pagina:

    DM  Autoveicoli    29 - FABBRICAZIONE DI AUTOVEICOLI, RIMORCHI E SEMIRIMORCHI
                       30 - FABBRICAZIONE DI ALTRI MEZZI DI TRASPORTO
    DN  Mobili         31 - FABBRICAZIONE DI MOBILI
                       32- ALTRE INDUSTRIE MANIFATTURIERE
    N   Sanità         Q - SANITA' E ASSISTENZA SOCIALE
                       86 - ASSISTENZA SANITARIA
                       87 - SERVIZI DI ASSISTENZA SOCIALE RESIDENZIALE

**`30`, non `33`.** E «FABBRICAZIONE DI MOBILI» e «ALTRE INDUSTRIE MANIFATTURIERE»
**senza refusi**. Tutte e tre le divisioni erano ALTO, ed e **un caso solo**, non due.

**Perche nessuno l'aveva trovata prima:** in Gazzetta quella tabella e una scansione
**ruotata di novanta gradi**. Nessuna estrazione di testo la vede — ne `pdftotext`,
ne la modalita grezza, ne PyMuPDF — e nessuna di esse *fallisce*: restituiscono
silenzio. Si legge solo rendendo la pagina in immagine. E il terzo esito di R4 —
**non verificabile** — comparso su una fonte invece che su un controllo: l'estrazione
vuota si presentava come «la tabella non c'e».

### Il confronto, adesso che c'e un originale

| | GU 2012 (primaria) | Regione Abruzzo | coordinato Amato-Di Fiore | ASR 2025 (Conferenza) |
| --- | --- | --- | --- | --- |
| la divisione | `30` | `30` | `33` | `33` |
| i mobili | `DI MOBILI` | `DI MOBILI` | `Dì MOBILI` | `Dl MOBILI` |
| le manifatturiere | `ALTRE INDUSTRIE` | `ALTRE INDUSTRIE` | `ALTRI INDUSTRIE` | `ALTRI INDUSTRIE` |
| 86 e 87 | presenti | presenti | presenti | **assenti** |

Si legge in una riga: **la Gazzetta e pulita, e la corruzione entra dopo.** Il
coordinato e l'ASR 2025 condividono la stessa discendenza sporca — gli stessi refusi
nelle stesse righe — e il 2025 in piu perde le due righe della sanita. La resa della
Regione Abruzzo, che avevo scartato, **coincide con la Gazzetta**.

### I miei due errori, e il secondo e piu istruttivo del primo

**Il primo:** avevo concluso che il 2025 avesse perso il `30`. Giusto nel merito, ma
poggiato su una sola resa non primaria.

**Il secondo:** mi sono «corretto» sul testo coordinato — che **non e la fonte** — e
ci ho costruito sopra una regola: *«una copia piu pulita non e una copia migliore»*.
**E falsa**, e questo caso e il suo controesempio: la resa piu pulita era la piu
vicina alla Gazzetta, e l'ho scartata proprio perche era pulita.

L'errore sotto l'errore, che e quello da ricordare: **ho contato due blocchi dello
stesso volume come due rese indipendenti.** Il coordinato riporta la stessa tabella
due volte — accordo lavoratori e accordo datori — e ho letto la ripetizione come
conferma. Due estrazioni dalla stessa urna non sono due prove. E la forma campionaria
del difetto di R5: **un campione non indipendente che si presenta come indipendente.**

**La regola che regge**, e viene dalla corsia AppFormazione: *fra rese discordi non
decide la pulizia, decide la **distanza dalla fonte** — e la distanza si stabilisce
risalendo alla fonte, non giudicando le copie.*

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

## Cosa c'e da decidere adesso

Una domanda sola, e su tutte e tre le divisioni insieme — perche in Gazzetta erano
tutte e tre `ALTO` e si sono perse nella stessa catena di riedizioni.

1. **Si adotta `ALTO` per 30, 86 e 87**, citando l'Allegato II del 221/CSR **in
   Gazzetta Ufficiale n. 8 dell'11/01/2012, pagina 48, atto 12A00059**, e
   **marcando le righe come derivate** e non lette.
2. **Si resta a `null`**, accettando che ospedali, case di cura, RSA e i costruttori
   di mezzi di trasporto non abbiano classe.

La 1 e coerente con A7 **a condizione che la marcatura arrivi davvero fino ai dati**:
senza, e la 2 travestita da 1.

E vale la conseguenza gia annotata piu sotto: **aspettare un chiarimento significa
aspettare qualcosa che nessuno ha ancora chiesto** — nessuna delle tre raccolte di FAQ
solleva la questione.

## Decisione

*(da scrivere. E ora una riga sola: la fonte primaria esiste, e la scelta e fra
adottare `ALTO` con la citazione della Gazzetta e la marcatura di deduzione, oppure
restare a `null`.)*

---

## Verificato sul testo della Conferenza, non su una riedizione (9 settembre 2026)

Restava un dubbio che cambiava la natura della decisione: le tre divisioni mancano
**nell'originale**, o e' un difetto introdotto dalla riedizione di *PiuSicurezza srl*
(«Rev 1 del 06/06/2025», col suo sito nel pie' di pagina) che sta in
`AppFormazione/reference/fonti/`?

Sciolto scaricando il testo **dal sito della Conferenza Stato-Regioni**:
`statoregioni.it`, Repertorio Atto n. 59/CSR, allegato
`p-9-csr-atto-rep-n-59-17apr2025.pdf` (6,0 MB, PDF 1.6, 138 pagine contro le 136
della riedizione). Estratto con `pdftotext -layout`.

**Il difetto e' nell'originale.** Coda dell'Allegato IV, pagina 138 di 138:

    29 - FABBRICAZIONE DI AUTOVEICOLI, RIMORCHI E SEMIRIMORCHI
    33 - FABBRICAZIONE DI ALTRI MEZZI DI TRASPORTO
    31 - FABBRICAZIONE Dl MOBILI
    32- ALTRI INDUSTRIE MANIFATTURIERE
    ...
    22 - FABBRICA7IONIE DI ARTICOLI IN GOMMA E MATERIE PLASTICHE
    Q - SANITA E ASSISTENZA SOCIALE

    Pag. 138 a 138

Due difetti distinti, non uno:

- la **30 non e' persa, e' numerata male**. La sequenza e' 29, **33**, 31, 32:
  crescente ovunque tranne li'. E il titolo «altri mezzi di trasporto» appartiene
  alla 30 — la 33 vera e' «riparazione e manutenzione di macchine». Nella tabella
  riassuntiva il guaio si consolida, perche' l'intervallo e' scritto `31-33` e il 33
  fasullo viene assorbito senza lasciare un buco visibile;
- la **86 e la 87 cadono sotto un'intestazione vuota**: «Q - SANITA E ASSISTENZA
  SOCIALE» e' stampata, sotto non c'e' niente, e li' finisce il documento.

**Quella pagina e' passata per un OCR che ha sbagliato in almeno cinque punti
visibili in trenta righe** — `FABBRICA7IONIE` col 7 al posto della Z, `Dl MOBILI` e
`Dl COKE` con la elle minuscola, `DELPETROLIO` attaccato, `ALTRI INDUSTRIE` invece
di *altre*. Un `0` letto come `3` e' esattamente cio' che quella macchina sbaglia.
**Gli stessi refusi ci sono nel testo della Conferenza e nella riedizione**, il che
dimostra che la seconda ristampa fedelmente il primo e non introduce niente.

Non e' quindi «il legislatore ha tolto tre divisioni»: e' che l'ultima pagina del
testo vigente e' tipograficamente rotta, e i tre buchi stanno dentro quel guasto
insieme a refusi che nessuno contesterebbe.

**E nessuno l'ha ancora sollevata.** Cercato in tutte e tre le raccolte di FAQ: le
uniche occorrenze di «ATECO» riguardano il passaggio 2007 -> 2025 con le tavole
ISTAT, il fatto che il codice non e' obbligatorio sull'attestato, e le aule
multi-ATECO. Nessun quesito su una divisione mancante o su un numero sbagliato.

Conseguenza per la decisione: **aspettare un chiarimento significa aspettare
qualcosa che nessuno ha ancora chiesto.**

---

*Fonti cercate il 9 settembre 2026, e la sezione riscritta tre volte in un pomeriggio.
**Primaria**: Allegato II del 221/CSR in Gazzetta Ufficiale n. 8 dell'11/01/2012,
p. 48, atto 12A00059, letto a video perche la scansione e ruotata di 90 gradi
(`GU-8-11012012-Accordo-221-CSR.pdf` e i due ritagli, in `AppFormazione/reference/fonti/`).
**Secondarie, e tutte discordi dalla primaria in almeno un punto**: testo coordinato
Amato-Di Fiore gennaio 2026, ripubblicazione Regione Abruzzo, ASR 2025 dal sito della
Conferenza, riedizione PiuSicurezza, `.txt` di Organigramma-sicurezza,
`allegato_iv_asr2025.js`. **Cercate e mute**: le tre raccolte di FAQ.
Si rimisura rileggendo a video la pagina 48 della Gazzetta — non estraendone il testo,
che restituisce silenzio.*
