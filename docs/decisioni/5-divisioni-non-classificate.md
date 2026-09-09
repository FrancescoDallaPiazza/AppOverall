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

## La fonte, cercata e trovata il 9 settembre 2026

**Le tre divisioni erano classificate, e tutte e tre ALTO.** Stanno nell'**Allegato 2
dell'Accordo Stato-Regioni 21/12/2011, Rep. Atti 221/CSR** — «Individuazione delle
macrocategorie di rischio e corrispondenze ATECO 2002-2007» — che e la tabella che
l'Allegato IV del 2025 riprende. Verificato sul testo integrale pubblicato dalla
Regione Abruzzo (SPSAL), 23 pagine:

| dove | riga, alla lettera | classe |
| --- | --- | --- |
| C - ATTIVITA MANIFATTURIERE | `30 - FABBRICAZIONE DI ALTRI MEZZI DI TRASPORTO` | **ALTO** |
| Q - SANITA' E ASSISTENZA SOCIALE | `86 - ASSISTENZA SANITARIA` | **ALTO** |
| Q - SANITA' E ASSISTENZA SOCIALE | `87 - SERVIZI DI ASSISTENZA SOCIALE RESIDENZIALE` | **ALTO** |
| Q - SANITA' E ASSISTENZA SOCIALE | `88 - ASSISTENZA SOCIALE NON RESIDENZIALE` | MEDIO |

### E il 2025 non le ha declassificate: le ha perse di stampa

Non e una congettura, e un confronto riga per riga fra le due tabelle. Il difetto ha
due forme diverse e ciascuna si dimostra da sola.

**La 30 — un numero sbagliato su un titolo giusto.** Le due liste ALTO hanno la
stessa sequenza nello stesso ordine:

| 2011 (Allegato 2) | 2025 (Allegato IV) |
| --- | --- |
| `29 - FABBRICAZIONE DI AUTOVEICOLI, RIMORCHI E SEMIRIMORCHI` | `29 - FABBRICAZIONE DI AUTOVEICOLI, RIMORCHI E SEMIRIMORCHI` |
| `30 - FABBRICAZIONE DI ALTRI MEZZI DI TRASPORTO` | **`33`** ` - FABBRICAZIONE DI ALTRI MEZZI DI TRASPORTO` |
| `31 - FABBRICAZIONE DI MOBILI` | `31 - FABBRICAZIONE Dì MOBILI` |
| `32 - ALTRE INDUSTRIE MANIFATTURIERE` | `32- ALTRI INDUSTRIE MANIFATTURIERE` |

Stessa posizione, stesso titolo parola per parola, solo il numero cambiato. E la
stessa pagina che scrive «Dì MOBILI» e «ALTRI INDUSTRIE». In ATECO 2007 la 33 e
*Riparazione, manutenzione e installazione di macchine e apparecchiature*: il titolo
stampato accanto al 33 non e il suo.

**La 86 e la 87 — un'intestazione sopravvissuta al suo contenuto.** Nel 2011 la lista
ALTO si chiude con `Q - SANITA' E ASSISTENZA SOCIALE` e sotto le sue due righe. Nel
2025 la lista ALTO si chiude con `Q - SANITÀ E ASSISTENZA SOCIALE` **e non ha nulla
sotto**, ed e l'ultima riga di pagina 136, cioe dell'intero accordo. L'intestazione e
rimasta esattamente dov'era; le due righe che le stavano sotto no.

E la sesta comparsa in un giorno della stessa forma di difetto (vedi R5 nella
[scheda 7](7-base-normativa.md)): **un insieme incompleto che si presenta come
completo.** Qui l'intestazione fa da falsa conferma — c'e un titolo, quindi sembra
che qualcuno abbia deciso, mentre e solo il contenitore di cio che si e perso.

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

La ricerca ha cambiato la domanda. Non e piu «alto, o silenzio?» — nessuno deve piu
inventare un `ALTO`. E:

1. **Si adotta `ALTO` per 30, 86 e 87** con la citazione dell'Allegato 2 del 221/2011
   e la dimostrazione del difetto di stampa, **marcando le righe come derivate** e non
   lette. Sotto A7 e una deduzione dichiarata, che e esattamente cio che A7 prevede.
2. **Si resta a `null`** finche una fonte vigente non le classifichi, accettando che
   32 codici — fra cui ospedali, case di cura e RSA — non abbiano classe.

La 1 e coerente con A7 **a condizione che la marcatura ci sia davvero nei dati**:
senza, e la 2 travestita da 1.

## Decisione

*(da scrivere. Se «alto», va detto **con quale fonte** — e ora ce n'e una da citare,
con il suo limite dichiarato — oppure dichiarato esplicitamente come deduzione e
marcato tale nei dati.)*

---

*Fonti cercate il 9 settembre 2026. Verificate: le tre raccolte di FAQ in `fonti/`
(nessuna tratta i codici non classificati), l'Allegato IV nelle tre rese disponibili,
il testo integrale dell'Accordo 221/2011 (Regione Abruzzo, SPSAL, 23 pagine),
l'ASR 2025 RAW. Si rimisura rileggendo l'Allegato 2 del 221/2011 e l'Allegato IV
del 59/2025 e confrontando le due liste ALTO.*
