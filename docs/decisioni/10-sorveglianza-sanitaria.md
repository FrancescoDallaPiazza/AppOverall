# 10 · La sorveglianza sanitaria entra nel perimetro?

> **Blocca:** niente subito · ma decide se 818 scadenze già raccolte hanno un posto, e allarga il perimetro del 26 agosto per la seconda volta
> **In una riga:** **entra, come dominio proprio** — accanto alla formazione e non dentro, perché l'art. 41 non è l'art. 37

**Nata da una misura, non da un'idea.** Il 10 settembre 2026 la corsia
AppSopralluoghi ha enumerato i quattro fogli di `ExportExcel (4).xlsx` — un
workbook che **nessun import apre** — e nel foglio «Visite» ha trovato la
sorveglianza sanitaria già raccolta.

## Cosa c'è dentro, contato

| accertamento | righe |
| --- | ---: |
| visita medica annuale | 671 |
| visita medica biennale | 107 |
| visita medica quinquennale | 24 |
| visita medica trimestrale | 3 |
| visita medica quadriennale | 3 |
| audiometria | 3 |
| spirometria | 2 |
| elettrocardiogramma | 2 |
| oculistica | 2 + 1 |
| **totale** | **818** |

Ogni accertamento è una **coppia di colonne**: quella intestata porta la data, la
colonna senza nome accanto porta la **scadenza**. Non è dedotto dal nome — è
verificato sui valori, `21.11.2025` con accanto `21.11.2026` per l'annuale.

## Perché non è formazione, e perché conta

È l'**art. 41 del D.Lgs. 81/2008**, non l'art. 37. Due articoli, due obblighi, due
soggetti che li assolvono: la formazione la erogano i formatori, la sorveglianza il
**medico competente** — che nella `0002` esiste già come figura (`medico_competente`,
art. 38) proprio con la nota «si registra la nomina, non un percorso».

La differenza non è formale. Una scadenza formativa si assolve con un corso, che sta
a catalogo; una visita si assolve con un accertamento, che non ha ore, non ha
prerequisiti e non ha aggiornamento — ha una periodicità decisa dal protocollo
sanitario, che varia per mansione e per rischio. Ficcarla nel catalogo dei corsi
avrebbe prodotto **818 adempimenti finti**, ed è per questo che gli undici titoli
di sorveglianza fra i 268 alias sono marcati `ignorato` invece di essere mappati.

## Cosa dice già il codice

**Il posto era previsto e non è mai stato riempito.** `formazioneImport.ts:13` di
AppSopralluoghi scarta le visite dicendo dove andrebbero: «il loro posto è
adempimento categoria sorveglianza». La tabella `adempimento` esiste in quel repo,
ed è stata **misurata vuota** il 10 settembre — zero righe.

Quindi non è una funzione che manca: è una funzione **dichiarata, mai costruita**, e
il dato per costruirla è in un foglio che nessuno apre da mesi.

## Cosa comporta, e va detto prima di cominciare

- **Allarga il perimetro**, ed è la seconda volta dopo la decisione 3. L'assunzione
  **A6** del programma — «il perimetro non si allarga durante il riavvio» — va
  annotata di nuovo. Due allargamenti dichiarati non sono una deriva; due
  allargamenti taciuti lo sarebbero.
- **Non è un ERP sanitario.** Entra la scadenza, non la cartella: il repo deve
  sapere *che* una visita è dovuta e *quando*, non l'esito clinico. Il giudizio di
  idoneità e i dati sanitari restano del medico competente — e su quelli si applica
  l'art. 25 c. 1 lett. c) e il GDPR, quindi il default è **non tenerli**.
- **Il modello somiglia allo scadenzario, non al catalogo.** Un accertamento, un
  protocollo che dice ogni quanto, una data fatta e una scadenza calcolata: è la
  forma di `adempimento`, non quella di `corso`.
- **Le 818 righe sono già lì.** Non è una raccolta da avviare: è un import da
  scrivere, sullo stesso workbook che porta anche i ruoli e i fattori di rischio.

## Decisione

**Presa da Francesco il 10 settembre 2026: entra, come dominio proprio.**

Accanto alla formazione e non dentro: la scadenza sanitaria è un'entità sua, con la
sua periodicità e il suo soggetto: il medico competente. Il catalogo dei corsi —
`corso`, `corso_alias`, `corso_assolve` della `0004` — non si tocca e non la ospita.

Il confine è già scritto nella `0004`, in fondo, come rinuncia dichiarata: quella
migrazione dice che non porta la sorveglianza e perché. Con questa decisione quella
riga cambia di significato — non è più «fuori perimetro», è «prossima migrazione».

### Cosa resta da decidere, ma non blocca

Quanto del protocollo sanitario deve stare nel sistema. Le periodicità che si vedono
nel foglio (annuale, biennale, quinquennale, trimestrale, quadriennale) sono un
**esito**, non una regola: chi le decide è il medico nel protocollo, per mansione e
per rischio. Tenere solo le scadenze rende il sistema un registro; tenere anche il
protocollo lo rende capace di dire che una visita **manca**, che è la domanda utile.
Si decide quando si disegna la scheda della persona, e va decisa con il medico
competente — non fra noi.
