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
l'RLS, come la loro.

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

## Cosa serve da Francesco

Niente per cominciare. Due domande che servono **dopo**, e non bloccano i primi due passi:

1. **Entro quando va spento Sicurweb?** L'assunzione A2 dice che il calendario lo detta
   lui, e che se la data slitta la Fase 4 puo scambiarsi con la 5. Una data decide quanto
   della v2 serve prima dell'interfaccia.
2. **Chi usera lo scadenzario, e dove?** L'innesto previsto sono le pagine di
   AppFormazione. Se lo leggono anche i tecnici in campo, l'interfaccia cambia.
