# 8 · Dove si annota che il livello di rischio non viene dall'ATECO

**Blocca la Fase 3.** Determina colonne dello schema, e vanno messe insieme alle
altre della decisione 1: aggiungerle dopo significa riscrivere le righe gia' scritte.

## Cosa e in gioco

La classe di rischio che l'Allegato IV assegna a una divisione ATECO **non e' un
verdetto: e' un default**. L'Interpello MLPS 1/2025 lo dice citando l'accordo
153/CSR, allegato A punto 4: dove la valutazione dei rischi di un'azienda
classificata *bassa* evidenzia rischi particolari, servono corsi «di contenuto
corrispondente al rischio medio o alto». E l'interpello 11/2013 aggiunge che la
durata del corso «puo' prescindere dal codice ATECO di appartenenza dell'azienda».

Si sposta **nei due versi**, non solo verso l'alto.

Quindi per ogni sede esistono due cose diverse che oggi occupano una casella sola:
la classe che **la tabella dice**, e la classe che **si applica**. Quando non
coincidono, il perche' non e' scritto da nessuna parte — e non e' scritto in nessuno
dei tre repo.

## Cosa dice gia il codice

Il meccanismo esiste, a meta', e per gli altri due attributi.

`antincendio_definito_mediante` (migrazione `050`) e
`primo_soccorso_definito_mediante` (`051`) esistono: il wizard DM 388/2003 propone
il gruppo **e scrive nella stessa patch come ci e' arrivato**
(`Anagrafiche.tsx:543-547`, motivazione composta a `:1060-1070`). La UI segnala
l'incoerenza quando la motivazione manca (`:536`). E' esattamente la forma giusta —
un verdetto che si porta dietro la propria giustificazione.

**`livello_rischio` non ce l'ha.** Il motore lo propone dall'ATECO
(`ateco.ts:122-128`), l'operatore lo accetta o lo cambia a mano
(`Anagrafiche.tsx:940`), l'import lo scrive solo se nullo
(`anagraficheImport.ts:357-359`) — e di quella scelta non resta traccia.

## Perche serve, e non e la tracciabilita

Poter mostrare a un ispettore da cosa discende una classe e' una conseguenza utile,
ma non e' l'argomento che decide. L'argomento e' questo:

**senza `definito_mediante` la tabella non si puo' aggiornare senza fare danni.**

Il raccordo ATECO 2025 -> 2007 e' misurato: **62 codici su 2.166 cambiano classe**
fra le due annate. Il giorno che entra, la domanda operativa e' *quali sedi hanno un
livello che veniva dalla tabella e adesso cambierebbe?*

- Con il campo: e' una query, e si toccano solo quelle.
- Senza: o si risovrascrive tutto — cancellando le decisioni prese leggendo un DVR —
  oppure non si tocca niente e si tengono classi sbagliate senza sapere quali.

E' lo stesso principio di `persona.import_key`: **un dato scritto per essere riletto
trasforma un errore silenzioso in una domanda che si puo' fare.** La prova e' del
9 settembre: l'indice unique su quella colonna ha fermato un import che, senza,
avrebbe creato migliaia di doppioni in silenzio.

## Cosa comporterebbe

Cinque campi accanto al livello, **per sede** (decisione 1), non uno:

| campo | a cosa serve |
| --- | --- |
| `codice_ateco` **+ annata** | il fatto. Senza l'annata il default non e' ricalcolabile, ed e' anche il difetto M4 del dossier |
| `livello_rischio` | il verdetto applicato |
| `livello_rischio_definito_mediante` | **come**: `tabella_ateco` / `valutazione_rischi` / `interpello` / `manuale` |
| `livello_rischio_motivazione` | obbligatoria quando non e' `tabella_ateco` |
| `livello_rischio_fonte` | quale documento: «DVR rev. 3 del 12/04/2026», o l'interpello |

Piu' la data e chi ha deciso.

Da valutare insieme: se conservare anche il **proposto** (la classe che la tabella
darebbe oggi) o ricalcolarlo ogni volta. Conservarlo rende immediata la domanda
«questo verdetto e' ancora allineato alla tabella?»; ricalcolarlo evita una colonna
che invecchia. Non blocca lo schema: blocca solo se si sceglie di conservarlo.

## Due cose che non vanno fatte

**Non nella libreria normativa.** Li' stanno le tabelle deterministiche: stessa
chiave, stesso valore, per chiunque. Questo e' un giudizio su una singola sede con
un documento dietro. Coincide con quanto la scheda 7 chiama «materia (b)»: *sposta
un dato caso per caso -> un campo dell'applicazione, mai nella libreria*.

**Non nello schema attuale di AppSopralluoghi.** La decisione 1 sposta quegli
attributi sulla sede e il motore oggi legge sempre il cliente
(`formazione.ts:1298-1312`): metterlo nel vecchio schema significa scriverlo due
volte. E' materiale della **prima migrazione del repo unico**.

## Decisione

*(da scrivere)*
