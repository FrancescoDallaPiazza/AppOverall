# 2 · Qual e la chiave di un cliente?

> **Blocca:** la **Fase 3** · determina colonne dello schema
> **In una riga:** la chiave è **P.IVA + sede**: un cliente, N sedi, un organigramma per sede

**Blocca la Fase 3.** La direzione e obbligata, ma una direzione obbligata che
nessuno ha scritto non e una decisione.

## Cosa e in gioco

Le due app identificano lo stesso cliente in modi incompatibili:

| | AppSopralluoghi | AppFormazione |
| --- | --- | --- |
| chiave | **P.IVA + sede** | **ragione sociale normalizzata** |
| file di partenza | `ElencoSedi`, 619 attive | rifiuta `ElencoSedi`: non e fra le entita riconosciute |
| sedi | entita di prima classe | la tabella esiste ma non viene popolata |
| clienti conosciuti | 607 | 480, sottoinsieme stretto, zero orfani |
| ruoli | `tecnico / admin / interno` | `formazione / amministrazione / lettore` |

## Perche la direzione e obbligata

Da **P.IVA + sede** si arriva alla ragione sociale; **al contrario no**. Una ragione
sociale normalizzata non sa distinguere due sedi della stessa azienda, e
AppFormazione non sa cosa sia una sede.

La collisione reale sui dati di oggi e **un cliente solo** (Ecodent). Il divario vero
e il gap fra 480 e 607, che e additivo e recuperabile.

## Cosa resta da scrivere

Che la chiave del repo unico e P.IVA + sede, e che AppFormazione va riportata su
quella **prima** di riceverne una riga. E cosa si fa dei clienti senza P.IVA valida:
nell'import ne risultano **95 su 3.416** scartate come chiave.

## Decisione

**Presa da Francesco il 9 settembre 2026: la chiave e' P.IVA + sede.** Detta nei
suoi termini, che sono piu' netti di quelli tecnici:

> «Un'azienda con due sedi chiama per forza due organigrammi.»

Quindi due unita' locali non sono mai un'anagrafica sola. AppFormazione va
riportata su questa chiave **prima** di ricevere una riga, e la ragione sociale
normalizzata resta al massimo un ripiego quando la P.IVA non c'e'.

### La precisazione che la decisione 1 impone

«Due sedi, due organigrammi» dice dove sta l'**organigramma**, non quanti
**clienti** ci sono. Sono due cose diverse, e oggi coincidono solo per un limite:
AppSopralluoghi tiene l'organigramma appeso al *cliente* — «un cliente = un
organigramma» — quindi l'unico modo di averne due e' avere due clienti. E' la
ragione dichiarata di `anagraficheImport.ts:30-33`: *una riga = un cliente, anche
a parita' di P.IVA*, e il caso Ecodent.

Con la decisione 1 — rischio, ATECO, antincendio e primo soccorso appartengono
alla **sede** — quel limite non serve piu'. Il modello naturale del repo unico
diventa:

**un cliente (la P.IVA) · N sedi · un organigramma per sede.**

Che dice la stessa cosa di Francesco senza pagarla con anagrafiche doppie: due
sedi continuano a chiamare due organigrammi, ma l'azienda resta una e i suoi dati
identificativi non si duplicano. Il «due clienti» di oggi era la forma che quella
regola prendeva in uno schema dove l'organigramma non poteva stare sulla sede.

**Da riportare nello schema:** l'organigramma (e le nomine) si agganciano alla
`sede`, non al `cliente`. E' il pezzo che rende coerenti la decisione 1 e la 2,
ed e' anche cio' che oggi manca perche' `persona.sede_id` esiste ma il motore
lavora per cliente.

### Cosa si fa delle P.IVA non usabili

Restano **chiave assente**, come gia' fa l'import da oggi: 11 cifre e non tutte
uguali, altrimenti non aggancia e non si scrive. Misurate sui file veri: **95 su
3.416** nell'export dipendenti, **58 su 615** fra le aziende attive di
`ElencoSedi` — fra cui `XXXX`, `00000000000` e due partite IVA di dieci cifre.
Per quelle il cliente si identifica per ragione sociale + sede, e la P.IVA resta
vuota invece di essere riempita con un segnaposto che avvelena gli import
successivi.

Da ripulire: le P.IVA segnaposto **gia' scritte** in anagrafica da import
precedenti, per esempio `AB SERVICE SRL` a `00000000000`.
