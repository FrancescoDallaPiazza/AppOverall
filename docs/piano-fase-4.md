# La Fase 4: lo scadenzario che Sicurweb lascia

> Scritto il 17 settembre 2026, a Fase 3 chiusa sui dati veri. **E un piano:** dice cosa
> serve, in che ordine, e come si misura che e finito. Lo stato si scrive nella sezione 8
> del programma, non qui.

## Il criterio, e come si misura

Dal programma: **«Sicurweb si puo spegnere sullo scadenzario senza che nessuno tenga due
finestre aperte.»** Sotto la decisione 3 lo scadenzario **si ferma alla scadenza**: dice chi
e scaduto e cosa serve, non apre commesse.

«Si puo spegnere» non e un'impressione: e un **riscontro**. Il gestionale esporta il suo
scadenzario — `ExportExcelCorsiScadenze` (4.899 righe il 6 agosto) e
`ExportExcelVisiteScadenze` (812) — e il motore nuovo deve dire, per ogni persona e
obbligo, **la stessa scadenza o una diversa con una ragione scritta**. Il criterio d'uscita
diventa un numero: le righe che non tornano e non hanno una ragione sono zero.

## Cosa c'e gia, e cosa manca

**C'e** (Fase 3, provato sui dati veri): le persone con i rapporti — e da oggi i cessati
distinti (`0025`) —, le nomine, 12.637 attestati e 752 sessioni con la chiusura dei percorsi
(`0021`, `0022`), 1.344 visite con le scadenze dichiarate (`0005`, `0024`), le sedi con
l'ATECO e l'annata, il catalogo: `corso`, `corso_assolve` (ruolo -> corsi che lo
assolvono), `credito_formativo` (53 righe), `corso_regime_precedente`,
`corso_durata_per_dimensione`.

**Manca**, in ordine di quanto blocca:

1. **il motore**: nessuna vista dice ancora «questa persona, questo obbligo, questa
   scadenza, questo stato». Le viste di oggi sono per attestato (`v_evento_formativo`), per
   percorso (`v_percorso_formativo`) e per visita (`v_sorveglianza`);
2. **la classe di rischio della sede nel database**: l'ATECO c'e, la tabella
   divisione -> classe no. Si genera dalla libreria (decisione 7), come `allegato_iv.sql`
   della migrazione ma come tabella vera;
3. **il riscontro con Sicurweb**: lo scadenzario del gestionale non e ancora un'origine;
4. **un'interfaccia**: AppOverall non ha un'app. Le quattro pagine di AppFormazione
   (`Solleciti`, `Cliente`, `Clienti`, `Scheda`) leggono viste con la stessa forma, e sono
   l'innesto previsto dal programma.

## Il motore: cosa riusa, cosa cambia

AppFormazione ha un motore provato — due viste, `scadenze` e `formazione_dovuta` — e il
suo impianto si riusa: **obbligo per persona, ultimo attestato che assolve, scadenza =
completamento + periodicita, stati in ordine di precedenza, preavviso per obbligo.**

Cambia dove il repo unico sa di piu:

| | AppFormazione | qui |
|---|---|---|
| chi e tenuto | ruoli dichiarati + `lavoratore` dedotto | nomine + `lavoratore` per ogni rapporto **non cessato** (`0025`) |
| quando e completo | la data dell'evento | **il completamento del percorso** (`0021`): una sessione aperta non chiude |
| date nel futuro | contano | **non avvenute** (passo 04, regola 5) |
| RSPP esterno | non distinto | **non si chiede formazione** (`0010`, `cambia_l_esito`) |
| classe di rischio | sul cliente | **sulla sede** (decisione 1), default ATECO + override (decisione 8) |
| scadenza dichiarata | — | **accanto** alla calcolata, mai nascosta (`0005`, `0021`) |

**Gli stati**, con la precedenza di AppFormazione piu due: `esonerato`, `non_scade`,
`senza_regola` (il ruolo non ha corsi che lo assolvono), `mancante`, `in_corso` (percorso
frazionato aperto), `scaduto`, `in_scadenza`, `valido`. Il preavviso e 180 giorni, 90 per
l'aggiornamento dell'RLS (che e formazione, ma annuale), come la loro; 60 per le visite,
confermato da Francesco il 17 settembre 2026.

## L'ordine, e perche questo

1. **Motore v1** — la classe della sede, gli obblighi per persona, la scadenza per obbligo,
   le visite per persona e tipo. Senza crediti, regimi precedenti e livelli di
   emergenza: la v1 li **conta** come «da giudicare» invece di sbagliarli. Provato sui
   dati finti e sulla prova generale, che stampa la distribuzione degli stati.
2. **Il riscontro con Sicurweb** — lo scadenzario del gestionale diventa un'origine, e un
   passo lo confronta col motore: uguali, diverse con ragione, diverse senza. **E il
   numero che dice quanto manca.**
3. **Motore v2, guidato dal riscontro** — le regole che il riscontro dimostra necessarie,
   nell'ordine in cui spiegano piu righe: con ogni probabilita la regola transitoria del
   preposto (scadenza 19/05/2026 per gli attestati fino al 18/05/2023), i crediti
   dell'Allegato III, i regimi precedenti, i livelli di emergenza (decisione 11).
4. **L'interfaccia** — le pagine di AppFormazione sulle viste di qui.
5. **Il giro vero** — il progetto Supabase (deciso: uno dei due esistenti, svuotato), la
   migrazione dati, e il riscontro sui dati del giorno.

Il motore viene prima del riscontro perche il riscontro confronta **il motore**; il
riscontro viene prima della v2 perche e lui a dire quali regole servono, invece di
scriverle tutte e sperare.

## Il calendario: un mese

**Deciso da Francesco il 17 settembre 2026: Sicurweb si spegne entro un mese, cioe intorno
al 17 ottobre 2026.** L'ordine sopra resta; diventa un calendario, e due cose che il piano
metteva «dopo» vanno decise adesso, perche un mese non lascia spazio per scoprirle alla fine.

| settimana | entro | cosa |
|---|---|---|
| 1 | 24/09 | **il riscontro sui dati veri**; le regole della v2 ordinate per quante righe spiegano; **le decisioni qui sotto** |
| 2 | 01/10 | la **v2** fino a zero «diverse senza ragione»; l'interfaccia di sola lettura: scadenzario per cliente e solleciti |
| 3 | 08/10 | il **database vero**: migrazioni e migrazione dati sul progetto scelto; il flusso dei dati nuovi |
| 4 | 15/10 | **due settimane non ci sono: una**. Il riscontro rifatto sui dati del giorno, ogni due giorni, finche resta a zero; poi lo spegnimento |

**Il rischio vero non e il motore: e il giorno dopo.** Spento Sicurweb, i corsi e le visite
nuove devono finire da qualche parte, altrimenti lo scadenzario del 18 ottobre e giusto e
quello del 18 novembre e vecchio di un mese senza che nessuno se ne accorga.

## Cosa serve da Francesco

~~Niente per cominciare.~~ Con un mese, queste servono **nella prima settimana**:

1. ~~**Entro quando va spento Sicurweb?**~~ **Un mese** (17 settembre 2026).
2. ~~**Il database vero.**~~ **Il progetto Supabase di AppFormazione** (17 settembre): il
   repo unico ne prende il posto, e AppFormazione si archivia per prima.
3. ~~**Dove entrano i corsi e le visite nuovi.**~~ **In AppOverall** (17 settembre): serve
   una schermata di inserimento entro il mese.
4. **Chi usa lo scadenzario, e dove.** L'innesto previsto sono le pagine di AppFormazione.

E due decisioni sulla forma del motore, prese sul primo riscontro vero (17 settembre):
**le scadenze seguono anche i corsi fatti senza nomina**, con una segnalazione per
aggiornare l'organigramma; **antincendio e primo soccorso hanno scadenza e avviso sul
livello**. Sono nella `0027`, e il riscontro e passato da 1.935 a 4.554 coppie uguali
su 4.575.
