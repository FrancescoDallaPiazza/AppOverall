#!/usr/bin/env bash
# Prova del passo 03 su un database USA E GETTA con le migrazioni 0001-0020 gia
# caricate e le tabelle di dominio vuote. Mai su un database vero: carica dati
# finti e li riscrive.
#
#   PSQL="psql -p 5461 -U postgres -d prova" bash prova_03_nomine.sh
#
# `psql` va cercato nel PATH: un percorso con uno spazio dentro PSQL si spezza.
#
# **Clienti e persone non si scrivono a mano**: li portano i passi 01 e 02 veri,
# sulla stessa origine finta, perche la nomina si aggancia a cio che quei due passi
# scrivono — `cliente_origine` con una fusione per P.IVA, il rapporto con l'id della
# persona d'origine.
#
# Stesse regole di prova_02_persone.sh: ogni rifiuto e provato nei due versi, e
# conta solo se a rifiutare e PostgreSQL. **In piu, qui, conta solo se a rifiutare e
# il controllo giusto**: il messaggio deve contenere il frammento atteso. Con dieci
# controlli in fila, un guasto che fa scattare quello prima prova il controllo
# sbagliato, e lo script di prima avrebbe detto «ok» lo stesso.

set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
PSQL="${PSQL:-psql}"
ERRORE="$(mktemp)"
trap 'rm -f "$ERRORE"' EXIT
FALLITI=0

q()     { $PSQL -v ON_ERROR_STOP=1 -q -At "$@"; }
passo() { local f="$1"; shift; $PSQL -v ON_ERROR_STOP=1 -q -f "$DIR/$f" "$@" >/dev/null 2>"$ERRORE"; }
conta() { q -c "select count(*) || ' nomine' from nomina"; }
ok()    { if [ -n "$1" ] && [ "$1" = "$2" ]; then echo "  ok   $3"; else echo "  NO   $3 — atteso «$2», avuto «$1»"; FALLITI=$((FALLITI+1)); fi; }

rifiuta() { # descrizione, frammento atteso nel messaggio, guasto, riparazione, argomenti del passo 03
  local cosa="$1" atteso="$2" guasto="$3" ripara="$4"; shift 4
  [ -n "$guasto" ] && q -c "$guasto"
  prima="$(conta)"   # dopo il guasto: se il guasto scrive una nomina, il rifiuto non deve toglierla ne aggiungerne
  if passo 03_nomine.sql "$@"; then
    echo "  NO   $cosa — il passo 03 e passato"; FALLITI=$((FALLITI+1))
  elif ! grep -qE '(ERRORE|ERROR):' "$ERRORE"; then
    echo "  NO   $cosa — fallito senza un errore di PostgreSQL: $(head -c 120 "$ERRORE")"; FALLITI=$((FALLITI+1))
  elif ! grep -qE "$atteso" "$ERRORE"; then
    echo "  NO   $cosa — rifiutato da un altro controllo: $(grep -m1 -oE '(ERRORE|ERROR): .{0,90}' "$ERRORE")"; FALLITI=$((FALLITI+1))
  else
    ok "$(conta)" "$prima" "$cosa: rifiutato ($(grep -m1 -oE '(ERRORE|ERROR): .{0,70}' "$ERRORE"))"
  fi
  [ -n "$ripara" ] && q -c "$ripara"
}

vincolo() { # descrizione, insert che la 0020 deve rifiutare, nome del vincolo
  if q -c "$2" >/dev/null 2>"$ERRORE"; then
    echo "  NO   $1 — accettato"; FALLITI=$((FALLITI+1))
  elif grep -q "$3" "$ERRORE"; then
    echo "  ok   $1: rifiutato da $3"
  else
    echo "  NO   $1 — $(head -c 160 "$ERRORE")"; FALLITI=$((FALLITI+1))
  fi
}

U=00000000-0000-0000-0000-00000000000     # le unita d'origine: ${U}a, ${U}b, ${U}c
S=00000000-0000-0000-0000-0000000000      # le loro sedi: ${S}a1, ${S}b1, ${S}c1
P=00000000-0000-0000-0000-00000000000     # le righe persona: ${P}1 ... ${P}5
N=00000000-0000-0000-0000-0000000000e     # le nomine: ${N}1 ... ${N}9
A9="-v nomine_attese=9"

echo "== preparazione: i passi 00, 01 e 02 veri, sull'origine finta"
q -f "$DIR/00_origine.sql"
q -f "$DIR/prova_03_nomine_dati.sql"
if ! passo 01_clienti.sql -v clienti_attesi=3 -v sedi_attese=3; then echo "  NO   passo 01 fallito:"; cat "$ERRORE"; exit 1; fi
if ! passo 02_persone.sql -v righe_attese=5; then echo "  NO   passo 02 fallito:"; cat "$ERRORE"; exit 1; fi
ok "$(q -c "select (select count(*) from cliente) || ' clienti, ' || (select count(*) from sede) || ' sedi, ' || (select count(*) from persona) || ' persone, ' || (select count(*) from rapporto_lavoro) || ' rapporti'")" \
   "2 clienti, 3 sedi, 4 persone, 5 rapporti" "la destinazione dei passi 01 e 02: UB fusa in UA, ROSSI una persona con due rapporti"
ok "$(q -c "select cliente_id || ' ' || sede_id || ' ' || assorbito from cliente_origine where origine_id = '${U}b'")" "${U}a ${S}b1 true" "UB e assorbita in UA, con la sua sede"
ok "$(conta)" "0 nomine" "nessuna nomina prima del passo 03"

echo "== la 0002 conosce tutte le figure di AppSopralluoghi"
ok "$(q -c "select count(*) from unnest(array['datore_lavoro','dl_rspp','rspp','aspp','dirigente','preposto','lavoratore','rls','addetto_antincendio','addetto_primo_soccorso','operatore_attrezzatura','medico_competente','datore_lavoro_art16']) c where exists (select 1 from ruolo_sicurezza_alias a where a.sistema = 'sopralluoghi' and a.codice_esterno = c)")" \
   "13" "i 13 codici di figura_sicurezza (015, 018, 024, 053) hanno ognuno la sua riga"
ok "$(q -c "select count(*) from ruolo_sicurezza_alias where sistema = 'sopralluoghi'")" "13" "e la 0002 non ne ha altri"
ok "$(q -c "select count(*) from ruolo_testo where chiave <> upper(regexp_replace(testo, '[^A-Za-z0-9]', '', 'g'))")" "0" "la chiave del passo 03 e quella con cui il dizionario e costruito"

echo "== i rifiuti, ognuno su un guasto"
rifiuta "senza nomine_attese"               "syntax|sintassi|manca -v" "" ""
rifiuta "(a) nomine_attese sbagliate"       "\(a\) origine.nomina ha 9" "" "" -v nomine_attese=8
rifiuta "(b) figura sconosciuta"            "non conosce per sopralluoghi" \
  "update origine.nomina set figura_codice = 'addetto_evacuazione' where id = '${N}7'" \
  "update origine.nomina set figura_codice = 'lavoratore' where id = '${N}7'" $A9
rifiuta "(b) figura senza destinazione"     "senza destinazione" \
  "update origine.nomina set figura_codice = 'operatore_attrezzatura' where id = '${N}7'" \
  "update origine.nomina set figura_codice = 'lavoratore' where id = '${N}7'" $A9
rifiuta "(c) persona non estratta"          "non e in origine.persona" \
  "update origine.nomina set persona_id = gen_random_uuid() where id = '${N}7'" \
  "update origine.nomina set persona_id = '${P}5' where id = '${N}7'" $A9
rifiuta "(c) persona estratta senza rapporto" "non ha il suo rapporto" \
  "insert into origine.persona (id, cliente_id, nome, cognome, attivo, import_key, updated_at) values ('${P}6', '${U}c', 'ELENA', 'VERDI', true, 'anag:${U}c:n:VERDI|ELENA', now()); update origine.nomina set persona_id = '${P}6' where id = '${N}7'" \
  "update origine.nomina set persona_id = '${P}5' where id = '${N}7'; delete from origine.persona where id = '${P}6'" $A9
rifiuta "(d) nomina non attiva"             "non attive" \
  "update origine.nomina set attiva = false where id = '${N}7'" \
  "update origine.nomina set attiva = true where id = '${N}7'" $A9
rifiuta "(e) nomina da confermare"          "da confermare" \
  "update origine.nomina set da_confermare = true where id = '${N}7'" \
  "update origine.nomina set da_confermare = false where id = '${N}7'" $A9
rifiuta "(f) origine sconosciuta"           "origine.{1,3}che la 0020 non conosce" \
  "update origine.nomina set origine = 'foglio' where id = '${N}7'" \
  "update origine.nomina set origine = null where id = '${N}7'" $A9
rifiuta "(f) dedotta senza testo"           "non torna con l.origine" \
  "update origine.nomina set origine_testo = '' where id = '${N}3'" \
  "update origine.nomina set origine_testo = 'ADD. ANTINCENDIO' where id = '${N}3'" $A9
rifiuta "(f) testo accanto alla colonna"    "non torna con l.origine" \
  "update origine.nomina set origine_testo = 'RSPP' where id = '${N}1'" \
  "update origine.nomina set origine_testo = null where id = '${N}1'" $A9
rifiuta "(g) chiave del dizionario diversa" "non ricalcola" \
  "update ruolo_testo set chiave = 'ADDANTINCENDI0' where testo = 'ADD. ANTINCENDIO'" \
  "update ruolo_testo set chiave = 'ADDANTINCENDIO' where testo = 'ADD. ANTINCENDIO'" $A9
rifiuta "(g) testo che il dizionario non ha" "non conosce, o conosce con due posizioni" \
  "update origine.nomina set origine_testo = 'ADDETTO FUOCHI' where id = '${N}3'" \
  "update origine.nomina set origine_testo = 'ADD. ANTINCENDIO' where id = '${N}3'" $A9
rifiuta "(h) fuori dal dizionario senza nota" "senza nota" \
  "update origine.nomina set note = '  ' where id = '${N}5'" \
  "update origine.nomina set note = 'Datore di lavoro che fa da RSPP in proprio (art. 34): decisione finta della prova.' where id = '${N}5'" $A9
rifiuta "(h) testo di un ruolo, nomina di un altro" "senza nota" \
  "update origine.nomina set figura_codice = 'preposto' where id = '${N}3'" \
  "update origine.nomina set figura_codice = 'addetto_antincendio' where id = '${N}3'" $A9
rifiuta "(i) unita fuse senza sede"         "cadono sulla stessa persona, cliente, sede e ruolo" \
  "update cliente_origine set sede_id = null where origine_id in ('${U}a', '${U}b')" \
  "update cliente_origine set sede_id = case origine_id when '${U}a' then '${S}a1'::uuid else '${S}b1'::uuid end where origine_id in ('${U}a', '${U}b')" $A9
rifiuta "(i) una nomina gia scritta qui"    "gia con un altro id" \
  "insert into nomina (id, persona_id, cliente_id, sede_id, ruolo) values ('00000000-0000-0000-0000-0000000000ff', (select persona_id from rapporto_lavoro where id = '${P}5'), '${U}a', '${S}a1', 'lavoratore')" \
  "delete from nomina where id = '00000000-0000-0000-0000-0000000000ff'" $A9
rifiuta "(j) procura su un altro ruolo"     "procura" \
  "update origine.nomina set estremi_procura = 'Rep. 1' where id = '${N}7'" \
  "update origine.nomina set estremi_procura = null where id = '${N}7'" $A9

echo "== la stessa origine, senza guasti"
if passo 03_nomine.sql $A9; then echo "  ok   passo 03 eseguito"; else echo "  NO   passo 03 fallito:"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
AVVISI="$(cat "$ERRORE")"
echo "$AVVISI" | grep -E '(NOTICE|AVVISO):' | sed -E 's/^.*(NOTICE|AVVISO): +/       | /'
ok "$(conta)" "9 nomine" "regola 1: una nomina per nomina d'origine"
ok "$(q -c "select count(*) from nomina q join origine.nomina o on o.id = q.id")" "9" "regola 1: con lo stesso id"
ok "$(q -c "select string_agg(ruolo, ' ' order by id) from nomina")" \
   "datore_lavoro_rspp datore_lavoro_rspp addetto_antincendio rspp datore_lavoro_rspp datore_lavoro_art16 lavoratore preposto rls" \
   "regola 2: il ruolo dall'alias, dl_rspp su datore_lavoro_rspp"
ok "$(q -c "select string_agg(right(coalesce(sede_id::text, 'null'), 2), ' ' order by id) from nomina")" \
   "a1 b1 c1 c1 c1 a1 a1 c1 b1" "regola 3: la sede dell'unita d'origine, non quella del rapporto"
ok "$(q -c "select count(distinct persona_id) || ' ' || count(distinct cliente_id) from nomina where id in ('${N}1', '${N}2', '${N}9')")" \
   "1 1" "regola 3: ROSSI e una persona e un cliente anche dall'unita assorbita"
ok "$(q -c "select count(distinct persona_id) from nomina")" "4" "4 persone con nomine"
ok "$(echo "$AVVISI" | grep -oE 'unita fuse\): [0-9]+')" "unita fuse): 1" "regola 4: la stessa persona e ruolo su due sedi e contata, non fusa"
ok "$(q -c "select string_agg(coalesce(data_nomina::text, 'null'), ' ' order by id) from nomina where ruolo = 'datore_lavoro_rspp'")" \
   "2020-09-10 2020-09-10 null" "regola 5: la data com'e, e senza data resta senza"
ok "$(q -c "select string_agg(coalesce(origine, 'null'), ' ' order by id) from nomina")" \
   "colonna colonna mansione mansione qualifica null null qualifica qualifica" "regola 5: l'origine alla lettera, null compreso"
ok "$(q -c "select origine_testo from nomina where id = '${N}8'")" "LAVORATORE E PREPOSTO" "regola 5: il testo verbatim, in maiuscolo come all'origine"
ok "$(q -c "select string_agg(coalesce(posizione, '-'), ' ' order by id) from nomina")" \
   "- - non_dichiarato esterno socio - - non_dichiarato non_dichiarato" "regola 5: la posizione dal dizionario, e solo dove c'era un testo"
ok "$(q -c "select count(*) from nomina where posizione = 'esterno'")" "1" "il conto della 0010 non e piu zero"
ok "$(q -c "select note from nomina where id = '${N}5'")" "Datore di lavoro che fa da RSPP in proprio (art. 34): decisione finta della prova." "la nota attraversa"
ok "$(echo "$AVVISI" | grep -oE 'ragione in nota: [0-9]+')" "ragione in nota: 1" "(h): la RSPP-SOCIO passa con la nota, ed e contata"
ok "$(q -c "select estremi_procura from nomina where id = '${N}6'")" "Rep. 1234 del 2 gennaio 2024, notaio FINTO" "gli estremi della procura attraversano"
ok "$(q -c "select origine || ' ' || origine_testo || ' ' || posizione_nome from v_organigramma where id = '${N}4'")" \
   "mansione RSPP ESTERNO Esterno all'azienda" "la vista le mostra (PILASTRO 01)"

echo "== rieseguito sulla stessa origine"
if passo 03_nomine.sql $A9; then echo "  ok   passo 03 rieseguito"; else echo "  NO   rieseguito fallito:"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
ok "$(conta)" "9 nomine" "idempotente: niente di nuovo"

echo "== una nomina nuova all'origine"
q -c "insert into origine.nomina (id, persona_id, figura_codice, data_nomina, attiva, da_confermare, origine, created_at, updated_at) values ('${N}a', '${P}3', 'addetto_primo_soccorso', '2023-06-27', true, false, 'colonna', now(), now())"
if passo 03_nomine.sql -v nomine_attese=10; then echo "  ok   passo 03 con la nomina nuova"; else echo "  NO   fallito:"; cat "$ERRORE"; FALLITI=$((FALLITI+1)); fi
ok "$(conta)" "10 nomine" "entra solo quella"
ok "$(q -c "select ruolo || ' ' || right(sede_id::text, 2) || ' ' || data_nomina from nomina where id = '${N}a'")" "addetto_primo_soccorso c1 2023-06-27" "sulla sede della sua unita, con la sua data"

echo "== i controlli finali, fatti scattare apposta"
A10="-v nomine_attese=10"
rifiuta "una nomina con un altro ruolo"     "non stanno dove le regole 2 e 3" \
  "update nomina set ruolo = 'dirigente' where id = '${N}7'" \
  "update nomina set ruolo = 'lavoratore' where id = '${N}7'" $A10
rifiuta "una nota cambiata"                 "provenienza diversa" \
  "update nomina set note = 'altro' where id = '${N}1'" \
  "update nomina set note = 'Colonna RSPP letta come datore di lavoro RSPP (art. 34): nota finta della prova.' where id = '${N}1'" $A10
rifiuta "una data inventata"                "provenienza diversa" \
  "update nomina set data_nomina = '2026-09-15' where id = '${N}5'" \
  "update nomina set data_nomina = null where id = '${N}5'" $A10
rifiuta "una posizione senza testo"         "posizione dove non c.era un testo" \
  "update nomina set posizione = 'datore' where id = '${N}6'" \
  "update nomina set posizione = null where id = '${N}6'" $A10

echo "== i vincoli della 0020, senza il passo 03 davanti"
R5="(select persona_id from rapporto_lavoro where id = '${P}5')"
vincolo "un'origine inventata"      "insert into nomina (persona_id, cliente_id, ruolo, origine) values ($R5, '${U}a', 'dirigente', 'foglio')" "nomina_origine_nota"
vincolo "dedotta senza testo"       "insert into nomina (persona_id, cliente_id, ruolo, origine) values ($R5, '${U}a', 'dirigente', 'mansione')" "nomina_testo_solo_se_dedotta"
vincolo "un testo su una colonna"   "insert into nomina (persona_id, cliente_id, ruolo, origine, origine_testo) values ($R5, '${U}a', 'dirigente', 'colonna', 'DIRIGENTE')" "nomina_testo_solo_se_dedotta"
vincolo "un testo senza origine"    "insert into nomina (persona_id, cliente_id, ruolo, origine_testo) values ($R5, '${U}a', 'dirigente', 'DIRIGENTE')" "nomina_testo_solo_se_dedotta"
ok "$(conta)" "10 nomine" "e nessuna e entrata"

echo
if [ "$FALLITI" -eq 0 ]; then echo "tutte le prove passate"; else echo "$FALLITI prove fallite"; exit 1; fi
