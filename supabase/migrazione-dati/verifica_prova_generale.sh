#!/usr/bin/env bash
# Prova di prova_generale.sh, sui dati FINTI di prova_01 e prova_03 esportati in CSV.
# Nessun dato vero, e nessun database esterno: crea i suoi cluster e li cancella.
#
#   bash verifica_prova_generale.sh
#
# ---------- da dove vengono i CSV ----------
#
# I dati finti sono scritti come insert su `origine.*`, quindi si caricano su un
# cluster usa e getta e si esportano con le colonne di `prova_generale_comune.sh`:
# gli stessi quattro file che l'estrazione produrra, con dati di fantasia. Due
# ritocchi, fatti prima di esportare e scritti qui perche non sembrino dati:
#
#   * **BAR SPORT diventa BAR CENTRALE sull'unita UC di prova_03.** I due insiemi
#     finti hanno ciascuno un BAR SPORT senza P.IVA usabile, e il passo 01 li
#     fermerebbe — giustamente, rifiuto (f). Qui serve un giro che arrivi in fondo;
#   * **BIANCHI prende una lettera accentata** (chr(204)), perche la codifica si prova
#     solo con un carattere che non e ASCII.
#
# prova_02 non entra: le sue righe persona hanno gli stessi id di quelle di prova_03,
# e i suoi clienti sono scritti direttamente nella destinazione invece che in
# `origine`. I casi che prova sono gia provati da prova_02 stessa.
#
# Insieme, i due insiemi finti fondono **quattro** unita sulla P.IVA 01234567897 (K1 e
# K2 di prova_01, UA e UB di prova_03): 11 unita diventano 8 clienti.
#
# ---------- cosa prova ----------
#
# Che arrivi in fondo con i conteggi giusti, e che **si fermi davvero** — con
# l'ultima riga che dice dove — su un conteggio sbagliato per ognuno dei tre passi, su
# un dato che il passo 03 rifiuta, su un conteggio mancante, su una cartella dentro un
# repo, su un'intestazione in un altro ordine, su un file senza intestazione, e su un
# file che non e UTF-8. E che in nessun caso stampi un dato: il codice fiscale di un
# file senza intestazione non deve comparire nell'uscita.

set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/prova_generale_comune.sh"
LAVORO="$(mktemp -d)"
trap 'cluster_ferma >/dev/null; rm -rf "$LAVORO"' EXIT
FALLITI=0
USCITA="$LAVORO/uscita"

ok() { if [ -n "$1" ] && [ "$1" = "$2" ]; then echo "  ok   $3"; else echo "  NO   $3 — atteso «$2», avuto «$1»"; FALLITI=$((FALLITI+1)); fi; }
generale() { bash "$DIR/prova_generale.sh" "$@" >"$USCITA" 2>&1; }
ultima() { tail -n 1 "$USCITA"; }

fermata() { # descrizione, fase attesa, frammento atteso, argomenti della prova generale
  local cosa="$1" fase="$2" atteso="$3"; shift 3
  if generale "$@"; then
    echo "  NO   $cosa — e arrivata in fondo"; FALLITI=$((FALLITI+1))
  elif [ "$(ultima)" != "FERMATA in: $fase" ]; then
    echo "  NO   $cosa — l'ultima riga e «$(ultima)»"; FALLITI=$((FALLITI+1))
  elif ! grep -qE "$atteso" "$USCITA"; then
    echo "  NO   $cosa — fermata in $fase, ma senza «$atteso»:"; sed 's/^/       /' "$USCITA"; FALLITI=$((FALLITI+1))
  elif grep -q "ATTENZIONE" "$USCITA"; then
    echo "  NO   $cosa — il cluster non e stato cancellato"; FALLITI=$((FALLITI+1))
  else
    echo "  ok   $cosa: FERMATA in: $fase ($(grep -m1 -oE "$atteso.{0,50}" "$USCITA"))"
  fi
}

copia() { rm -rf "$LAVORO/$1"; cp -r "$CSV" "$LAVORO/$1"; echo "$LAVORO/$1"; }

echo "== i CSV finti, esportati da un cluster usa e getta"
cluster_avvia >/dev/null || { echo "  NO   il cluster per l'esportazione non parte"; exit 1; }
X=("${PSQL[@]}" -d postgres)
"${X[@]}" -f "$DIR/00_origine.sql" \
  && "${X[@]}" -f "$DIR/prova_01_clienti_dati.sql" \
  && "${X[@]}" -f "$DIR/prova_03_nomine_dati.sql" \
  && "${X[@]}" -f "$DIR/prova_04_formazione_dati.sql" \
  && "${X[@]}" -c "update origine.cliente set ragione_sociale = 'BAR CENTRALE' where id = '00000000-0000-0000-0000-00000000000c'" \
  && "${X[@]}" -c "update origine.persona set cognome = 'BIANCH' || chr(204) where id = '00000000-0000-0000-0000-000000000004'" \
  || { echo "  NO   dati finti non caricati"; exit 1; }
CSV="$LAVORO/csv"; mkdir -p "$CSV"
CSVNULL="$LAVORO/csvnull"; mkdir -p "$CSVNULL"
for t in $TABELLE; do
  ok "$("${X[@]}" -At -c "select string_agg(column_name, ',' order by ordinal_position) from information_schema.columns where table_schema = 'origine' and table_name = '$t'")" \
     "${COLONNE[$t]}" "le colonne attese per $t.csv sono quelle di origine.$t nel passo 00"
  "${X[@]}" -c "\\copy (select ${COLONNE[$t]} from origine.$t order by id) to '$(percorso_per_psql "$CSV/$t.csv")' with (format csv, header true, encoding 'UTF8')" \
    || { echo "  NO   $t non esportato"; exit 1; }
  "${X[@]}" -c "\\copy (select ${COLONNE[$t]} from origine.$t order by id) to '$(percorso_per_psql "$CSVNULL/$t.csv")' with (format csv, header true, encoding 'UTF8', null 'null')" \
    || { echo "  NO   $t non esportato con i nulli come parola"; exit 1; }
done
# Un valore di testo che vale «null»: PostgreSQL lo esporta fra virgolette, e in CSV
# non applica la parola nulla a cio che sta fra virgolette. Vale per i file che
# escono da psql; l'SQL Editor le virgolette le mette solo quando servono, e li la
# distinzione non c'e — sta scritto in prova_generale.sh e si verifica alla fonte.
"${X[@]}" -c "create table prova_null (t text)" -c "insert into prova_null values ('null'), (null)" -c "\\copy prova_null to '$(percorso_per_psql "$LAVORO/null.csv")' with (format csv, null 'null')" >/dev/null
ok "$(tr -d '\r' < "$LAVORO/null.csv" | paste -sd'|')" '"null"|null' "psql scrive il testo «null» fra virgolette, e il nullo nudo"
"${X[@]}" -c "truncate prova_null" -c "\\copy prova_null from '$(percorso_per_psql "$LAVORO/null.csv")' with (format csv, null 'null')" >/dev/null
ok "$("${X[@]}" -At -c "select count(*) from prova_null where t = 'null'")" "1" "e rileggendolo il testo resta testo"
ok "$("${X[@]}" -At -c "select count(*) from prova_null where t is null")" "1" "e il nullo resta nullo"
cluster_ferma >/dev/null
ok "$(for t in $TABELLE; do echo $(( $(wc -l < "$CSV/$t.csv") - 1 )); done | paste -sd' ')" "11 10 5 9 10" "righe esportate: 11 unita, 10 sedi, 5 persone, 9 nomine, 10 attestati"
ok "$(grep -c $'\xc3\x8c' "$CSV/persona.csv")" "1" "persona.csv e UTF-8, con una lettera accentata"
ATTESI="clienti_attesi=11 sedi_attese=10 righe_attese=5 nomine_attese=9 righe_formazione_attese=10"

echo "== la prova generale arriva in fondo"
if generale "$CSV" $ATTESI; then echo "  ok   uscita 0"; else echo "  NO   uscita non zero"; FALLITI=$((FALLITI+1)); fi
sed 's/^/       | /' "$USCITA"
ok "$(ultima)" "ARRIVATA IN FONDO" "l'ultima riga lo dice"
ok "$(grep -oE 'unita fuse\): [0-9]+' "$USCITA")" "unita fuse): 1" "gli avvisi del passo 03 sono stampati"
ok "$(grep -oE 'unita assorbite' "$USCITA" | head -1)" "unita assorbite" "e quelli del passo 01"
ok "$(grep -oE 'attestati d.origine 10  ->  eventi scritti [0-9]+, su [0-9]+ persone' "$USCITA")" "attestati d'origine 10  ->  eventi scritti 7, su 2 persone" "il passo 04 scrive 7 attestati su 10, e dice su quante persone"
ok "$(grep -oE 'NON entrati: [0-9]+ con un titolo ignorato a mano, [0-9]+ senza codice fiscale valido, [0-9]+ con un codice fiscale che l.anagrafe non ha' "$USCITA")" "NON entrati: 1 con un titolo ignorato a mano, 1 senza codice fiscale valido, 1 con un codice fiscale che l'anagrafe non ha" "le tre ragioni per restare fuori si contano separate"
ok "$(grep -oE 'percorsi frazionati entrati APERTI: [0-9]+' "$USCITA")" "percorsi frazionati entrati APERTI: 2" "i due spezzoni entrano aperti"
ok "$(grep -oE 'su cui cadono due o piu attestati: [0-9]+' "$USCITA")" "su cui cadono due o piu attestati: 1" "la collisione si segnala e non si fonde"
ok "$(grep -oE 'date fuori squadra, entrate e da guardare: [0-9]+ nel futuro' "$USCITA")" "date fuori squadra, entrate e da guardare: 1 nel futuro" "una data nel futuro entra e si conta"
ok "$(grep -oE 'nel futuro \(il motore le tratti come non avvenute\), [0-9]+ anteriori' "$USCITA")" "nel futuro (il motore le tratti come non avvenute), 1 anteriori" "e una anteriore al 2008 pure"
ok "$(grep -oE 'NON portati: [0-9]+ con un esito, [0-9]+ dichiarati di fonte esterna' "$USCITA")" "NON portati: 2 con un esito, 2 dichiarati di fonte esterna" "esito e fonte esterna si contano e non entrano"
ok "$(grep -E '^  clienti ' "$USCITA")" "  clienti 8, sedi 10, unita d'origine 11 (3 assorbite), persone 4, rapporti 5, nomine 9" "i conteggi finali: quattro unita su una P.IVA"
ok "$(grep -c 'cluster fermato e cancellato' "$USCITA")" "1" "e il cluster e cancellato"
ok "$(grep -oE '^  268 alias.*' "$USCITA")" "  268 alias: 237 mappati su 39 codici, 31 ignorati, 98 aggiornamenti, 7 parziali, 2 pregresse" "il seed degli alias e caricato e contato"

echo "== e ci arriva anche con i file come potrebbe salvarli un editor"
C="$(copia editor)"
# Con printf e non con sed sulla riga: il sed di Git Bash legge in modo testo e toglie
# il \r, e il file che ne esce ha l'intestazione in LF e i dati in CRLF — che
# PostgreSQL rifiuta («unquoted carriage return»), ed e un altro caso: un file misto.
for t in $TABELLE; do
  { if [ "$t" = cliente ]; then
      printf '\xEF\xBB\xBF%s\r\n' "$(head -n 1 "$CSV/$t.csv" | tr -d '\r' | sed -E 's/([a-z_]+)/"\1"/g')"
    else
      printf '%s\r\n' "$(head -n 1 "$CSV/$t.csv" | tr -d '\r')"
    fi
    tail -n +2 "$CSV/$t.csv" | tr -d '\r' | while IFS= read -r riga; do printf '%s\r\n' "$riga"; done
  } > "$C/$t.csv"
done
ok "$(head -c 3 "$C/cliente.csv" | od -An -tx1 | tr -d ' ')" "efbbbf" "cliente.csv comincia con il BOM, e l'intestazione e fra virgolette"
ok "$(for t in $TABELLE; do [ "$(tr -cd '\r' < "$C/$t.csv" | wc -c)" = "$(tr -cd '\n' < "$C/$t.csv" | wc -c)" ] && printf s || printf n; done)" "sssss" "ogni file ha tanti CR quanti LF: tutte le righe in CRLF"
if generale "$C" $ATTESI; then echo "  ok   uscita 0"; else echo "  NO   uscita non zero"; sed 's/^/       | /' "$USCITA"; FALLITI=$((FALLITI+1)); fi
ok "$(ultima)" "ARRIVATA IN FONDO" "BOM, virgolette e CRLF non la fermano"
ok "$(grep -E '^  clienti ' "$USCITA")" "  clienti 8, sedi 10, unita d'origine 11 (3 assorbite), persone 4, rapporti 5, nomine 9" "e i conteggi sono gli stessi"

echo "== e i nulli come li scrive l'SQL Editor"
ok "$(grep -c '^00000000-0000-0000-0000-0000000000c3,null,' "$CSVNULL/cliente.csv")" "1" "nel file i nulli sono la parola «null»"
fermata "senza null_scritto si ferma e dice cosa fare" "caricamento di cliente.csv" "rilanciare con null_scritto=null" "$CSVNULL" $ATTESI
if generale "$CSVNULL" $ATTESI null_scritto=null; then echo "  ok   uscita 0"; else echo "  NO   uscita non zero"; sed 's/^/       | /' "$USCITA"; FALLITI=$((FALLITI+1)); fi
ok "$(ultima)" "ARRIVATA IN FONDO" "con null_scritto=null arriva in fondo"
ok "$(grep -E '^  clienti ' "$USCITA")" "  clienti 8, sedi 10, unita d'origine 11 (3 assorbite), persone 4, rapporti 5, nomine 9" "e i conteggi sono gli stessi"
fermata "una parola che non e una parola" "controlli iniziali" "solo lettere, cifre e _" "$CSVNULL" $ATTESI "null_scritto=nu ll"

echo "== e si ferma davvero, dicendo dove"
fermata "nomine attese sbagliate"   "passo 03" "\(a\) origine.nomina ha 9 righe" \
  "$CSV" clienti_attesi=11 sedi_attese=10 righe_attese=5 nomine_attese=8 righe_formazione_attese=8
fermata "persone attese sbagliate"  "passo 02" "\(a\) origine.persona ha 5 righe" \
  "$CSV" clienti_attesi=11 sedi_attese=10 righe_attese=6 nomine_attese=9 righe_formazione_attese=8
fermata "clienti attesi sbagliati"  "passo 01" "\(a\) origine.cliente ha 11 righe" \
  "$CSV" clienti_attesi=12 sedi_attese=10 righe_attese=5 nomine_attese=9 righe_formazione_attese=8
fermata "attestati attesi sbagliati" "passo 04" "\\(a\\) origine.formazione ha 10 righe" \
  "$CSV" clienti_attesi=11 sedi_attese=10 righe_attese=5 nomine_attese=9 righe_formazione_attese=9

C="$(copia attiva)"
sed -i -E '/^00000000-0000-0000-0000-0000000000e7,/ s/,t,/,f,/' "$C/nomina.csv"
fermata "una nomina non attiva"     "passo 03" "\(d\) 1 nomine non attive" "$C" $ATTESI

fermata "un conteggio mancante"     "controlli iniziali" "manca nomine_attese" \
  "$CSV" clienti_attesi=11 sedi_attese=10 righe_attese=5 righe_formazione_attese=8
fermata "la cartella dentro un repo" "controlli iniziali" "dentro un repository git" "$DIR" $ATTESI

C="$(copia ordine)"
sed -i '1s/origine,origine_testo/origine_testo,origine/' "$C/nomina.csv"
fermata "colonne in un altro ordine" "controlli iniziali" "le colonne non sono quelle" "$C" $ATTESI

C="$(copia senza_intestazione)"
sed -i '1d' "$C/persona.csv"
fermata "un file senza intestazione" "controlli iniziali" "non e un'intestazione" "$C" $ATTESI
ok "$(grep -c 'HOZUNW31P60Q756F' "$USCITA")" "0" "e la prima riga, che e un dato, non e stampata"

# Un seed con UN GIUDIZIO cambiato, non con righe in meno: le righe restano 268, il
# file `corso_alias_origine.sql` e i suoi controlli passano lisci, e a protestare deve
# essere il conteggio dei giudizi. E la forma vera del rischio — 268 righe che ci sono
# tutte e una che dice una cosa diversa da quella decisa a mano.
SEED_ALTERATO="$LAVORO/seed"
mkdir -p "$SEED_ALTERATO"
cp "$DIR/../seed/corso_alias_origine.sql" "$SEED_ALTERATO/"
sed "s/^  ('ADDETTO A LAVORI IN SPAZI CONFINATI E SOSPETTI DI INQUINAMENTO', 'ATTR_AMB_CONFINATI', null, false,/  ('ADDETTO A LAVORI IN SPAZI CONFINATI E SOSPETTI DI INQUINAMENTO', 'ATTR_AMB_CONFINATI', null, true,/"   "$DIR/../seed/corso_alias.sql" > "$SEED_ALTERATO/corso_alias.sql"
ok "$(( $(grep -c "', null, true," "$SEED_ALTERATO/corso_alias.sql") - $(grep -c "', null, true," "$DIR/../seed/corso_alias.sql") ))" "1" "il seed di prova ha un giudizio cambiato, e le righe sono sempre 268"
export SEED="$SEED_ALTERATO"
fermata "un giudizio del dizionario cambiato" "seed degli alias" "il dizionario alias non e quello atteso" "$CSV" $ATTESI
unset SEED
ok "$(grep -c "trovati: 268 237 32" "$USCITA")" "1" "e dice quale conto non torna"

C="$(copia latin1)"
iconv -f UTF-8 -t ISO-8859-1 "$CSV/persona.csv" > "$C/persona.csv"
fermata "persona.csv non in UTF-8"  "caricamento di persona.csv" "invalid byte sequence|sequenza di byte non valida" "$C" $ATTESI

echo
if [ "$FALLITI" -eq 0 ]; then echo "tutte le prove passate"; else echo "$FALLITI prove fallite"; exit 1; fi
