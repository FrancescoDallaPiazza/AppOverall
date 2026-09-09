# 7 · Chi possiede la base normativa, e chi puo modificarla

**Decisa il 9 settembre 2026.** E l'unica decisione di governo fra le sette: non
dice cosa costruire, dice chi ha l'ultima parola su cosa e vero.

## Il problema

La base normativa sta in quattro posti con quattro regole diverse:

| dove | cosa | regola |
| --- | --- | --- |
| `AppFormazione/reference/` | 17 PDF di fonti, 11 trascrizioni **con parte, punto, pagina** | dichiarata nel CLAUDE.md, rigorosa |
| `AppFormazione/supabase/migrations/` | le tabelle applicative | A7: entra solo cio che e citato |
| `Organigramma-sicurezza/.../references/` | 6 `.txt` trascritti, 6 accordi RAW, `ateco-rischio.md` | nessuna, e contiene un errore |
| `formazione-81-utils-src` | `allegato_iv_asr2025.js`, `raccordo_ateco.js` | ricostruita da fonti incrociate |

Il difetto di governo in una riga: **c'e una sorgente autorevole e tre valli che non
ne dipendono.** Una correzione a monte non arriva mai a valle.

E l'asimmetria peggiore: **la libreria e a monte dell'app da campo ma a valle di
niente.** Genera senza derivare. E per questo che le e mancato il raccordo ISTAT per
quattro mesi senza che nessuno se ne accorgesse — e che `ateco.ts`, in campo,
classifica ancora un codice ATECO 2025 sbagliando su 62 codici.

## Decisione

**La libreria `formazione-81-utils-src` resta il generatore unico, e `reference/` la
alimenta.**

Non viene dismessa con la Fase 5: diventa **la base normativa** di tutto il gruppo —
a monte di AppOverall, di AppSopralluoghi finche vive, e delle skill. Le tabelle
applicative del repo unico si generano da li, non si trascrivono a mano una seconda
volta.

Il motivo per cui questa strada e stata scelta contro l'alternativa (il repo unico
come sorgente, e la libreria dismessa): la conoscenza normativa deve restare
**riusabile fuori da questo progetto**, e una libreria e il posto giusto per quello;
un modello SQL dentro un'applicazione non lo e.

## Cosa la decisione adesso richiede

La libreria non ha oggi la disciplina che questo ruolo comporta. Tre regole, e sono
il prezzo della scelta.

**R1 · Le fonti stanno accanto al generatore.** I PDF e le trascrizioni citate
alimentano la libreria: vanno dove lei le puo leggere. I `.txt` di
Organigramma-sicurezza si assorbono nella stessa raccolta — sono in formato
*migliore* dei nostri PDF, perche gia trascritti.

**R2 · Ogni riga generata deve poter dire da dove viene.** Oggi la libreria dichiara
le fonti in un commento d'intestazione, per l'intera tabella. Non basta: serve la
citazione **per riga**, parte-punto-pagina, come nelle nostre migrazioni. Le
divisioni 30, 86 e 87 sono il controesempio — le riempie con `ALTO` senza poterlo
dire, e sotto R2 quella modifica non entrerebbe. E A7 applicata a un repo che oggi
non la segue.

**R3 · Chi consuma dichiara la versione.** `ateco.ts` gia dice in intestazione da
dove e generato. Va aggiunto **quando** e **da quale commit**, cosi un difetto a
monte si rintraccia a valle invece di restare invisibile per quattro mesi.

Sotto queste regole, consegnare il raccordo ISTAT non e copiare un file: e portarlo
**con la provenienza dentro** — la tavola ISTAT, la data, il commit che lo genera.

## Cosa resta da sciogliere

- **Le fonti traslocano dentro la libreria, o restano in un repo e lei le vendora?**
  Sono repo separati: un generatore JS non legge i file di un altro repo a tempo di
  build senza copiarli. La strada pulita e che `reference/` diventi parte della
  libreria; ma va detto, perche sposta 17 PDF e 11 trascrizioni.
- **Il nome.** `formazione-81-utils-src` si annuncia come una raccolta di utilita.
  Se diventa la base normativa del gruppo, il nome dice la cosa sbagliata a chiunque
  ci arrivi senza contesto.
- **Chi puo modificarla.** Sotto R2 la risposta e implicita — chi puo citare — ma non
  e scritta da nessuna parte, e la libreria oggi non ha ne CLAUDE.md ne una regola.
