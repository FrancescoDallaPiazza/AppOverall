#!/usr/bin/env bash
# Prova del passo 01, e del passo 02 sopra di esso, su un database USA E GETTA con
# le migrazioni 0001-0017 gia caricate e le tabelle di dominio vuote. Mai su un
# database vero: carica dati finti e li riscrive.
#
#   PSQL="psql -p 5461 -U postgres -d prova" bash prova_01_clienti.sh
#
# `psql` va cercato nel PATH. Stesse regole di prova_02_persone.sh: ogni rifiuto e
# provato nei due versi, e conta solo se a rifiutare e PostgreSQL.

set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
PSQL="${PSQL:-psql}"
ERRORE="$(mktemp)"
trap 'rm -f "$ERRORE"' EXIT
FALLITI=0

q()     { $PSQL -v ON_ERROR_STOP=1 -q -At "$@"; }
passo() { local f="$1"; shift; $PSQL -v ON_ERROR_STOP=1 -q -f "$DIR/$f" "$@" >/dev/null 2>"$ERRORE"; }
conta() { q -c "select (select count(*) from cliente) || ' clienti, ' || (select count(*) from sede) || ' sedi, ' || (select count(*) from cliente_origine) || ' corrispondenze'"; }
ok()    { if [ -n "$1" ] && [ "$1" = "$2" ]; then echo "  ok   $3"; else echo "  NO   $3 — atteso «$2», avuto «$1»"; FALLITI=$((FALLITI+1)); fi; }

rifiuta() { # descrizione, guasto, riparazione, argomenti del passo 01
  local cosa="$1" guasto="$2" ripara="$3"; shift 3
  [ -n "$guasto" ] && q -c "$guasto"
  prima="$(conta)"
  if passo 01_clienti.sql "$@"; then
    echo "  NO   $cosa — il passo 01 e passato"; FALLITI=$((FALLITI+1))
  elif ! grep -qE '(ERRORE|ERROR):' "$ERRORE"; then
    echo "  NO   $cosa — fallito senza un errore di PostgreSQL: $(head -c 120 "$ERRORE")"; FALLITI=$((FALLITI+1))
  else
    ok "$(conta)" "$prima" "$cosa: rifiutato ($(grep -m1 -oE '(ERRORE|ERROR): .{0,70}' "$ERRORE"))"
  fi
  [ -n "$ripara" ] && q -c "$ripara"
}

K=00000000-0000-0000-0000-0000000000c
S=00000000-0000-0000-0000-0000000005c
ATTESI="-v clienti_attesi=8 -v sedi_attese=7"

echo "== preparazione"
q -f "$DIR/00_origine.sql"
q -f "$DIR/prova_01_clienti_dati.sql"
ok "$(conta)" "0 clienti, 0 sedi, 0 corrispondenze" "destinazione vuota"

echo "== la funzione della 0017 contro la guardia d'origine"
ok "$(q -c "select string_agg(x || '=' || partita_iva_usabile(x), ' ' order by x) from unnest(array['00000000000','11111111111','XXXX','0123456789','01234567890',' 012 345 678 97']) x")" \
   " 012 345 678 97=true 00000000000=false 0123456789=false 01234567890=true 11111111111=false XXXX=false" \
   "segnaposto e forme sbagliate fuori, spazi tollerati"
ok "$(q -c "select count(*) from generate_series(0, 9) d where partita_iva_usabile(repeat(d::text, 11))")" "0" \
   "le dieci stringhe a cifre tutte uguali: tutte non usabili (la guardia d'origine le accetta tutte)"

echo "== i rifiuti, ognuno su un guasto"
rifiuta "senza i conteggi attesi"        "" ""
rifiuta "(a) clienti attesi sbagliati"   "" "" -v clienti_attesi=7 -v sedi_attese=7
rifiuta "(b) ragione sociale vuota"      "update origine.cliente set ragione_sociale = '  ' where id = '${K}5'" \
                                         "update origine.cliente set ragione_sociale = 'OFFICINA NERI' where id = '${K}5'" $ATTESI
rifiuta "(c) sede di un cliente assente" "insert into origine.sede values ('00000000-0000-0000-0000-000000000999', gen_random_uuid(), 'X', null, null, null, false, true, now())" \
                                         "delete from origine.sede where id = '00000000-0000-0000-0000-000000000999'" -v clienti_attesi=8 -v sedi_attese=8
rifiuta "(d) due sedi principali"        "update origine.sede set principale = true where id = '00000000-0000-0000-0000-0000000006c6'" \
                                         "update origine.sede set principale = false where id = '00000000-0000-0000-0000-0000000006c6'" $ATTESI
rifiuta "(e) dipendenti senza sede legale" "update origine.cliente set numero_lavoratori = 4 where id = '${K}8'" \
                                         "update origine.cliente set numero_lavoratori = null where id = '${K}8'" $ATTESI
rifiuta "(f) stessa ragione sociale senza P.IVA" "update origine.cliente set ragione_sociale = 'BAR SPORT' where id = '${K}5'" \
                                         "update origine.cliente set ragione_sociale = 'OFFICINA NERI' where id = '${K}5'" $ATTESI
rifiuta "(g) due werp_id per una P.IVA"  "update origine.cliente set werp_id = 'W2' where id = '${K}2'" \
                                         "update origine.cliente set werp_id = null where id = '${K}2'" $ATTESI

echo "== la stessa origine, senza guasti"
if passo 01_clienti.sql $ATTESI; then echo "  ok   passo 01 eseguito"; else echo "  NO   passo 01 fallito:"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
grep -E '(NOTICE|AVVISO):' "$ERRORE" | sed -E 's/^.*(NOTICE|AVVISO): +/       | /'
ok "$(q -c "select count(*) from sede where import_key not like '%:legale'")" "2" "il conto della 0013 non e piu zero, e dice perche: la sede di K2 e il magazzino di K6"
ok "$(conta)" "7 clienti, 7 sedi, 8 corrispondenze" "3 P.IVA usabili + 4 senza; ogni sede e ogni cliente d'origine"
ok "$(q -c "select id || ' ' || ragione_sociale || ' ' || werp_id || ' ' || attivo from cliente where partita_iva = '01234567897'")" "${K}1 ECO SRL W1 true" "regola 1: il superstite e K1, creato prima"
ok "$(q -c "select cliente_id || ' ' || assorbito from cliente_origine where origine_id = '${K}2'")" "${K}1 true" "K2 assorbito in K1"
ok "$(q -c "select principale || ' ' || import_key || ' ' || n_dipendenti_gestionale from sede where id = '${S}2'")" "false sedi:piva:01234567897:sede:${S}2 12" "regola 4 e 5: la sede di K2 non e principale e porta i suoi 12"
ok "$(q -c "select principale || ' ' || import_key || ' ' || n_dipendenti_gestionale from sede where id = '${S}1'")" "true sedi:piva:01234567897:legale 30" "la sede legale del superstite"
ok "$(q -c "select coalesce(partita_iva, 'null') || ' ' || partita_iva_origine || ' ' || import_key from cliente where id = '${K}3'")" "null 00000000000 sedi:cf:01234567890" "regola 3: segnaposto assente, cella conservata, chiave dal CF"
ok "$(q -c "select coalesce(partita_iva, 'null') || ' ' || import_key from cliente where id = '${K}4'")" "null sedi:den:BAR SPORT" "stesso segnaposto, nessuna collisione; ragione sociale normalizzata come all'origine"
ok "$(q -c "select coalesce(partita_iva, 'null') || ' ' || partita_iva_origine from cliente where id = '${K}7'")" "null 11111111111" "il segnaposto che la guardia d'origine lascia passare"
ok "$(q -c "select string_agg(principale || '/' || attiva, ' ' order by principale desc) from sede where cliente_id = '${K}6'")" "true/false false/false" "cliente non attivo: le sue sedi non attive"
ok "$(q -c "select coalesce(indirizzo, 'null') || ' ' || comune from sede where id = '${S}4'")" "null Legnago" "stringa vuota resta assente"
ok "$(q -c "select count(*) from sede where cliente_id = '${K}8'")" "0" "un cliente senza sedi resta senza sedi"
ok "$(q -c "select sum(n_dipendenti_gestionale) from sede")" "55" "i dipendenti non si sommano e non si perdono"

echo "== rieseguito sulla stessa origine"
if passo 01_clienti.sql $ATTESI; then echo "  ok   passo 01 rieseguito"; else echo "  NO   rieseguito fallito"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
ok "$(conta)" "7 clienti, 7 sedi, 8 corrispondenze" "idempotente"

echo "== le persone sopra i clienti: il passo 02 attraverso la corrispondenza"
q -c "insert into origine.persona (id, cliente_id, sede_id, nome, cognome, codice_fiscale, attivo, import_key, updated_at) values
  ('00000000-0000-0000-0000-0000000000f1', '${K}1', '${S}1', 'MARIO', 'ROSSI', 'JQIOBW08B92B915V', true, 'anag:${K}1:JQIOBW08B92B915V', now()),
  ('00000000-0000-0000-0000-0000000000f2', '${K}2', '${S}2', 'MARIO', 'ROSSI', 'JQIOBW08B92B915V', true, 'anag:${K}2:JQIOBW08B92B915V', now())"
if passo 02_persone.sql -v righe_attese=2; then echo "  ok   passo 02 eseguito"; else echo "  NO   passo 02 fallito:"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
ok "$(q -c "select count(*) || ' ' || count(distinct persona_id) from rapporto_lavoro")" "2 1" "stessa persona in due unita della stessa azienda: una persona, due rapporti"
ok "$(q -c "select cliente_id || ' ' || sede_id from rapporto_lavoro where id = '00000000-0000-0000-0000-0000000000f2'")" "${K}1 ${S}2" "il rapporto dell'unita assorbita va sul superstite, nella sua sede"

echo "== un'unita nuova con una P.IVA gia presente"
q -c "insert into origine.cliente (id, ragione_sociale, partita_iva, attivo, numero_lavoratori, created_at) values ('${K}9', 'LAVANDERIA BLU', '98765432109', true, 3, now())"
q -c "insert into origine.sede values ('${S}9', '${K}9', 'Sede legale', null, 'Cerea', 'VR', true, true, now())"
if passo 01_clienti.sql -v clienti_attesi=9 -v sedi_attese=8; then echo "  ok   passo 01 con l'unita nuova"; else echo "  NO   fallito:"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
ok "$(conta)" "7 clienti, 8 sedi, 9 corrispondenze" "confluisce nel cliente che c'e"
ok "$(q -c "select attivo::text from cliente where id = '${K}6'")" "true" "un'unita attiva riaccende il cliente"
ok "$(q -c "select principale || ' ' || n_dipendenti_gestionale from sede where id = '${S}9'")" "false 3" "e la sua sede non diventa principale"

echo "== i controlli finali, fatti scattare apposta"
AT9="-v clienti_attesi=9 -v sedi_attese=8"
rifiuta "cliente portato senza import_key" \
  "update cliente set import_key = null where id = '${K}5'" \
  "update cliente set import_key = 'sedi:den:OFFICINA NERI' where id = '${K}5'" $AT9
rifiuta "P.IVA non usabile scritta come chiave" \
  "update cliente set partita_iva = '22222222222' where id = '${K}8'" \
  "update cliente set partita_iva = '12345678903' where id = '${K}8'" $AT9
rifiuta "dipendenti inventati su una sede" \
  "update sede set n_dipendenti_gestionale = 31 where id = '${S}1'" \
  "update sede set n_dipendenti_gestionale = 30 where id = '${S}1'" $AT9

echo
if [ "$FALLITI" -eq 0 ]; then echo "tutte le prove passate"; else echo "$FALLITI prove fallite"; exit 1; fi
