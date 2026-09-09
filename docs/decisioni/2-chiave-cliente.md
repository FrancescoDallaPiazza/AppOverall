# 2 · Qual e la chiave di un cliente?

**Blocca la Fase 3.** La direzione e obbligata, ma una direzione obbligata che
nessuno ha scritto non e una decisione.

## Cosa e in gioco

Le due app identificano lo stesso cliente in modi incompatibili:

| | AppSopralluoghi | AppFormazione |
| --- | --- | --- |
| chiave | **P.IVA + sede** | **ragione sociale normalizzata** |
| file di partenza | `ElencoSedi`, 618 attive | rifiuta `ElencoSedi`: non e fra le entita riconosciute |
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

*(da scrivere)*
