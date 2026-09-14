#!/usr/bin/env bash
# Prova del passo 01 su un database USA E GETTA con le migrazioni 0001-0016 gia
# caricate e le tabelle di dominio vuote. Mai su un database vero: carica dati
# finti e li riscrive.
#
#   PSQL="psql -p 5461 -U postgres -d prova" bash prova_01_persone.sh
#
# `psql` va cercato nel PATH: un percorso con uno spazio dentro PSQL si spezza.
#
# Ogni rifiuto e provato nei due versi: la riga guasta fa fallire il passo 01 e
# non lascia niente scritto, e la stessa origine senza il guasto passa. Un
# controllo che non si e mai visto fallire non prova niente (A12).
#
# E un rifiuto conta solo se a rifiutare e stato PostgreSQL: la prima esecuzione
# di questo script, con psql non trovato, dava «ok, rifiutato» a tre controlli su
# un database mai raggiunto — un comando che non parte fallisce, e fallire era
# proprio l'esito atteso. Adesso serve un errore SQL nel testo, e un conteggio
# letto davvero.

set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
PSQL="${PSQL:-psql}"
ERRORE="$(mktemp)"
trap 'rm -f "$ERRORE"' EXIT
FALLITI=0

q()     { $PSQL -v ON_ERROR_STOP=1 -q -At "$@"; }
passo() { $PSQL -v ON_ERROR_STOP=1 -q -f "$DIR/01_persone.sql" "$@" >/dev/null 2>"$ERRORE"; }
conta() { q -c "select (select count(*) from persona) || ' persone, ' || (select count(*) from rapporto_lavoro) || ' rapporti'"; }
ok()    { if [ -n "$1" ] && [ "$1" = "$2" ]; then echo "  ok   $3"; else echo "  NO   $3 — atteso «$2», avuto «$1»"; FALLITI=$((FALLITI+1)); fi; }

rifiuta() { # descrizione, guasto, riparazione, argomenti del passo
  local cosa="$1" guasto="$2" ripara="$3"; shift 3
  [ -n "$guasto" ] && q -c "$guasto"
  prima="$(conta)"   # dopo il guasto: se il guasto scrive una riga, il rifiuto non deve toglierla ne aggiungerne
  if passo "$@"; then
    echo "  NO   $cosa — il passo 01 e passato"; FALLITI=$((FALLITI+1))
  elif ! grep -qE '(ERRORE|ERROR):' "$ERRORE"; then
    echo "  NO   $cosa — fallito senza un errore di PostgreSQL: $(head -c 120 "$ERRORE")"; FALLITI=$((FALLITI+1))
  else
    ok "$(conta)" "$prima" "$cosa: rifiutato ($(grep -m1 -oE '(ERRORE|ERROR): .{0,70}' "$ERRORE"))"
  fi
  [ -n "$ripara" ] && q -c "$ripara"
}

echo "== preparazione"
q -f "$DIR/00_origine.sql"
q -f "$DIR/prova_01_persone_dati.sql"
ok "$(conta)" "0 persone, 0 rapporti" "destinazione vuota"

A=00000000-0000-0000-0000-00000000000a
C=00000000-0000-0000-0000-00000000000c
R1=00000000-0000-0000-0000-000000000001

echo "== i rifiuti, ognuno su una riga guasta"
rifiuta "senza righe_attese"            "" ""
rifiuta "(a) righe_attese sbagliate"    "" "" -v righe_attese=9
rifiuta "(b) import_key vuota"          "update origine.persona set import_key = null where id = '$R1'" \
                                        "update origine.persona set import_key = 'anag:$A:JQIOBW08B92B915V' where id = '$R1'" -v righe_attese=10
rifiuta "(c) cliente che qui non c'e"   "update origine.persona set cliente_id = gen_random_uuid() where id = '$R1'" \
                                        "update origine.persona set cliente_id = '$A' where id = '$R1'" -v righe_attese=10
rifiuta "(c) sede di un altro cliente"  "update origine.persona set sede_id = '00000000-0000-0000-0000-0000000000c1' where id = '$R1'" \
                                        "update origine.persona set sede_id = '00000000-0000-0000-0000-0000000000a1' where id = '$R1'" -v righe_attese=10
rifiuta "(d) cognome null"              "update origine.persona set cognome = null where id = '$R1'" \
                                        "update origine.persona set cognome = 'ROSSI' where id = '$R1'" -v righe_attese=10
rifiuta "(e) cessato senza data"        "update origine.persona set attivo = false where id = '$R1'" \
                                        "update origine.persona set attivo = true where id = '$R1'" -v righe_attese=10
rifiuta "(f) CF valido due volte nello stesso cliente" \
  "insert into origine.persona (id, cliente_id, nome, cognome, codice_fiscale, attivo, import_key, updated_at) values ('00000000-0000-0000-0000-000000000099', '$A', 'X', 'Y', 'ZSGCRSQ3HV1S5Q8P', true, 'doppio', now())" \
  "delete from origine.persona where id = '00000000-0000-0000-0000-000000000099'" -v righe_attese=11

echo "== la stessa origine, senza guasti"
if passo -v righe_attese=10; then echo "  ok   passo 01 eseguito"; else echo "  NO   passo 01 fallito:"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
ok "$(conta)" "9 persone, 10 rapporti" "4 codici validi distinti + 5 senza codice valido"
ok "$(q -c "select count(*) from rapporto_lavoro r join persona p on p.id = r.persona_id where p.codice_fiscale = 'JQIOBW08B92B915V'")" "2" "regola 2: un CF su due clienti, due rapporti"
ok "$(q -c "select nome from persona where codice_fiscale = 'JQIOBW08B92B915V'")" "MARIA" "regola 4: vince la riga aggiornata per ultima"
ok "$(q -c "select count(*) from persona where codice_fiscale = 'ZSGCRSQ3HV1S5Q8P'")" "1" "omocodia: valido"
ok "$(q -c "select codice_fiscale || ' / ' || codice_fiscale_origine from persona where cognome = 'GIALLI'")" "OJPKDD62T79U607Y / ojpkdd 62t79u607y" "CF pulito come identita, cella come origine"
ok "$(q -c "select coalesce(codice_fiscale, 'null') || ' / ' || codice_fiscale_origine from persona where cognome = 'BLU'")" "null / KWRUYJ45T73F788G" "controllo sbagliato: niente identita, cella conservata"
ok "$(q -c "select coalesce(codice_fiscale, 'null') || ' / ' || codice_fiscale_origine from persona where cognome = 'VIOLA'")" "null / 01234567890" "P.IVA: idem"
ok "$(q -c "select count(*) from persona where cognome = 'BIANCHI' and nome = 'LUCA'")" "2" "regola 3: stesso nome senza CF su due clienti, due persone"
ok "$(q -c "select count(*) from persona where cognome = 'BIANCHI' and codice_fiscale_origine is null")" "2" "stringa vuota e null restano assenti, tutte e due"
ok "$(q -c "select count(*) from rapporto_lavoro r join origine.persona o on o.id = r.id and o.import_key = r.import_key")" "10" "regola 1: id e import_key conservati"
ok "$(q -c "select data_cessazione from rapporto_lavoro where import_key like '%VERDI|ANNA'")" "2025-12-31" "la cessazione attraversa"
ok "$(q -c "select coalesce(sede_id::text, 'null') from rapporto_lavoro where import_key like '%HOZUNW31P60Q756F'")" "null" "sede assente resta assente"

echo "== rieseguito sulla stessa origine"
if passo -v righe_attese=10; then echo "  ok   passo 01 rieseguito"; else echo "  NO   rieseguito fallito"; FALLITI=$((FALLITI+1)); fi
ok "$(conta)" "9 persone, 10 rapporti" "idempotente: niente di nuovo"

echo "== una riga nuova con un CF gia presente"
q -c "insert into origine.persona (id, cliente_id, sede_id, nome, cognome, codice_fiscale, attivo, import_key, updated_at) values ('00000000-0000-0000-0000-000000000011', '$C', null, 'GIULIA', 'NERI', 'ZSGCRSQ3HV1S5Q8P', true, 'anag:$C:ZSGCRSQ3HV1S5Q8P', now())"
if passo -v righe_attese=11; then echo "  ok   passo 01 con la riga nuova"; else echo "  NO   fallito:"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
ok "$(conta)" "9 persone, 11 rapporti" "si aggancia alla persona che c'e"

echo "== i controlli finali, fatti scattare apposta"
B7=$(q -c "select id from persona where cognome = 'BIANCHI' order by id limit 1")
rifiuta "persona senza CF con due rapporti" \
  "insert into rapporto_lavoro (persona_id, cliente_id, import_key) values ('$B7', '$C', 'manuale:1')" \
  "delete from rapporto_lavoro where import_key = 'manuale:1'" -v righe_attese=11
rifiuta "import_key che nomina un altro cliente" \
  "insert into rapporto_lavoro (persona_id, cliente_id, import_key) values ((select id from persona where codice_fiscale = 'HOZUNW31P60Q756F'), '$A', 'anag:$C:altro')" \
  "delete from rapporto_lavoro where import_key = 'anag:$C:altro'" -v righe_attese=11
rifiuta "persona senza rapporti" \
  "insert into persona (cognome, nome) values ('ORFANA', 'X')" \
  "delete from persona where cognome = 'ORFANA'" -v righe_attese=11

echo
if [ "$FALLITI" -eq 0 ]; then echo "tutte le prove passate"; else echo "$FALLITI prove fallite"; exit 1; fi
