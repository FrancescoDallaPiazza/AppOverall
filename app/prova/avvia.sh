#!/usr/bin/env bash
# AppOverall — il banco di prova dell'app: un database con i dati FINTI, e PostgREST
# davanti, come Supabase. Resta acceso finche non si preme Ctrl+C, poi cancella tutto.
#
#   POSTGREST=<percorso di postgrest.exe> bash app/prova/avvia.sh
#
# Perche esiste: AppOverall non ha ancora un progetto Supabase (sara quello di
# AppFormazione, decisione del 17 settembre 2026), e su questo PC non c'e Docker per
# Supabase locale. Ma Supabase, per quello che l'app usa, e PostgreSQL + PostgREST: le
# migrazioni vere, le RLS vere, `auth.uid()` letto dal token come fa Supabase. Il login
# no: il banco da all'app un token gia firmato, e l'app entra senza password.
#
# Scrive `app/.env.prova.local` (ignorato da git) e poi si lancia l'app con
#
#   cd app && npm run prova
#
# Utenti del banco:
#   amministrazione  11111111-1111-1111-1111-111111111111  livello 4, scrive tutto
#   tecnico          22222222-2222-2222-2222-222222222222  livello 2, registra attestati e visite
#   lettore          33333333-3333-3333-3333-333333333333  livello 1, legge e basta
#   non abilitato    44444444-4444-4444-4444-444444444444  nessuna riga in operatore: non vede niente
# Si sceglie con UTENTE=amministrazione|tecnico|lettore|nessuno (default amministrazione).

set -u
QUI="$(cd "$(dirname "$0")" && pwd)"
APP="$(cd "$QUI/.." && pwd)"
DATI="$(cd "$APP/../supabase/migrazione-dati" && pwd)"
MIGRAZIONI="$(cd "$APP/../supabase/migrations" && pwd)"
SEED="$(cd "$APP/../supabase/seed" && pwd)"
. "$DATI/prova_generale_comune.sh"

POSTGREST="${POSTGREST:-postgrest}"
command -v "$POSTGREST" >/dev/null 2>&1 || [ -x "$POSTGREST" ] || {
  echo "postgrest non trovato: indicare POSTGREST=<percorso di postgrest.exe>"
  echo "(si scarica da https://github.com/PostgREST/postgrest/releases)"
  exit 1
}
UTENTE="${UTENTE:-amministrazione}"
PORTA_REST="${PORTA_REST:-3001}"
SEGRETO="banco-di-prova-appoverall-segreto-lungo-almeno-32"
PID_REST=""

fine() {
  [ -n "$PID_REST" ] && kill "$PID_REST" 2>/dev/null
  rm -f "$APP/.env.prova.local"
  cluster_ferma
}
trap fine EXIT
trap 'exit 130' INT TERM

echo "== database"
cluster_avvia || exit 1
P=("${PSQL[@]}" -d postgres)

# Supabase quanto basta all'app: auth.uid() dal token, i ruoli di PostgREST, e i
# privilegi che Supabase da per default alle tabelle nuove (le policy fanno il resto).
"${P[@]}" >/dev/null <<SQL || { echo "  Supabase simulato non riuscito"; exit 1; }
create schema auth;
create function auth.jwt() returns jsonb language sql stable as
  \$\$ select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb \$\$;
create function auth.uid() returns uuid language sql stable as
  \$\$ select nullif(auth.jwt() ->> 'sub', '')::uuid \$\$;
create function auth.role() returns text language sql stable as
  \$\$ select auth.jwt() ->> 'role' \$\$;
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
create role authenticator login noinherit password 'banco';
grant anon, authenticated, service_role to authenticator;
grant usage on schema public, auth to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant execute on functions to anon, authenticated, service_role;
SQL

for f in "$MIGRAZIONI"/[0-9][0-9][0-9][0-9]_*.sql; do
  "${P[@]}" -f "$f" >/dev/null 2>"$CLUSTER_DIR/err" || { echo "  migrazione $(basename "$f"):"; head -3 "$CLUSTER_DIR/err"; exit 1; }
done
"${P[@]}" -f "$SEED/corso_alias.sql" -f "$SEED/corso_alias_origine.sql" >/dev/null 2>&1

# I dati finti, attraverso i passi veri della migrazione dati.
for f in 00_origine prova_01_clienti_dati prova_03_nomine_dati prova_04_formazione_dati \
         prova_05_frazionata_dati prova_06_valutazioni_dati prova_07_sorveglianza_dati \
         prova_02b_persone_storiche_dati prova_08_riscontro_dati; do
  "${P[@]}" -f "$DATI/$f.sql" >/dev/null 2>&1 || { echo "  dati finti $f non caricati"; exit 1; }
done
"${P[@]}" -c "update origine.cliente set ragione_sociale = 'BAR CENTRALE' where id = '00000000-0000-0000-0000-00000000000c'" >/dev/null
passo() { local f="$1"; shift; "${P[@]}" "$@" -f "$DATI/$f.sql" >/dev/null 2>"$CLUSTER_DIR/err" || { echo "  passo $f:"; head -3 "$CLUSTER_DIR/err"; exit 1; }; }
passo 01_clienti -v clienti_attesi=11 -v sedi_attese=10
passo 02_persone -v righe_attese=5
passo 02b_persone_fuori_anagrafe -v righe_persone_storiche_attese=5
passo 03_nomine -v nomine_attese=9
passo 04_formazione -v righe_formazione_attese=15
passo 05_frazionata -v righe_frazionata_attese=10
passo 06_valutazioni
passo 07_sorveglianza -v righe_visite_attese=10 -v righe_scadenze_attese=6

"${P[@]}" >/dev/null <<'SQL'
insert into operatore (utente_id, cognome, nome, email, ruolo) values
  ('11111111-1111-1111-1111-111111111111', 'Prova', 'Amministrazione', 'amministrazione@prova.invalid', 'amministrazione'),
  ('22222222-2222-2222-2222-222222222222', 'Prova', 'Tecnico',         'tecnico@prova.invalid',         'tecnico'),
  ('33333333-3333-3333-3333-333333333333', 'Prova', 'Lettore',         'lettore@prova.invalid',         'lettore');
SQL
echo "  $("${P[@]}" -At -c "select count(*) from v_scadenzario") righe di scadenzario, $("${P[@]}" -At -c "select count(*) from cliente") clienti, porta $PORTA"

# ---------- i token ----------
token() { # sub (vuoto = anon), ruolo
  python - "$SEGRETO" "$1" "$2" <<'PY'
import base64, hashlib, hmac, json, sys, time
segreto, sub, ruolo = sys.argv[1], sys.argv[2], sys.argv[3]
b64 = lambda b: base64.urlsafe_b64encode(b).rstrip(b"=").decode()
testa = b64(json.dumps({"alg": "HS256", "typ": "JWT"}).encode())
dati = {"role": ruolo, "aud": "authenticated", "iat": int(time.time()), "exp": int(time.time()) + 30 * 86400}
if sub:
    dati["sub"] = sub
corpo = b64(json.dumps(dati).encode())
firma = b64(hmac.new(segreto.encode(), f"{testa}.{corpo}".encode(), hashlib.sha256).digest())
print(f"{testa}.{corpo}.{firma}")
PY
}
case "$UTENTE" in
  amministrazione) SUB=11111111-1111-1111-1111-111111111111 ;;
  tecnico)         SUB=22222222-2222-2222-2222-222222222222 ;;
  lettore)         SUB=33333333-3333-3333-3333-333333333333 ;;
  nessuno)         SUB=44444444-4444-4444-4444-444444444444 ;;
  *) echo "UTENTE sconosciuto: $UTENTE"; exit 1 ;;
esac
ANON="$(token "" anon)"
UTENTE_TOKEN="$(token "$SUB" authenticated)"
cat > "$APP/.env.prova.local" <<ENV
# Scritto da app/prova/avvia.sh: vale finche il banco e acceso, e si cancella con lui.
VITE_SUPABASE_URL=http://127.0.0.1:5173
VITE_SUPABASE_ANON_KEY=$ANON
VITE_PROVA_TOKEN=$UTENTE_TOKEN
VITE_PROVA_UTENTE=$SUB
VITE_PROVA_REST=http://127.0.0.1:$PORTA_REST
ENV

# ---------- PostgREST ----------
cat > "$CLUSTER_DIR/postgrest.conf" <<CONF
db-uri = "postgres://authenticator:banco@localhost:$PORTA/postgres"
db-schemas = "public"
db-anon-role = "anon"
jwt-secret = "$SEGRETO"
jwt-aud = "authenticated"
server-host = "127.0.0.1"
server-port = $PORTA_REST
db-max-rows = 1000
CONF
echo "== PostgREST sulla porta $PORTA_REST, utente $UTENTE"
"$POSTGREST" "$(percorso_per_psql "$CLUSTER_DIR/postgrest.conf")" >"$CLUSTER_DIR/postgrest.log" 2>&1 &
PID_REST=$!
# L'attesa in Python e non con sleep: in alcune shell sleep non attende, e il ciclo
# rinunciava in zero secondi con PostgREST ancora in avvio (17 settembre 2026).
for _ in $(seq 1 30); do
  curl -s -o /dev/null "http://127.0.0.1:$PORTA_REST/" && break
  python -c "import time; time.sleep(1)"
done
if ! curl -s -o /dev/null "http://127.0.0.1:$PORTA_REST/"; then
  echo "  PostgREST non risponde:"; tail -5 "$CLUSTER_DIR/postgrest.log"; exit 1
fi
echo "  pronto. Adesso: cd app && npm run prova   (Ctrl+C qui per spegnere e cancellare)"
wait "$PID_REST"
