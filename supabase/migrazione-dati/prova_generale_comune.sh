# AppOverall — migrazione dati: cio che prova_generale.sh e verifica_prova_generale.sh
# condividono. Si include con `source`, non si lancia.

# ---------- le colonne dei sei CSV ----------
#
# Nell'ordine delle quattro select di 00_origine.sql, che e l'ordine delle tabelle
# `origine.*`. `\copy ... header` salta la prima riga **senza leggerla**: un file con
# le colonne in un altro ordine entrerebbe scambiando i valori fra colonne dello
# stesso tipo, e nessun vincolo protesterebbe. Per questo la prova generale confronta
# l'intestazione prima di caricare, e la verifica confronta questa lista con le
# tabelle del 00.

TABELLE="cliente sede persona nomina formazione formazione_frazionata"

declare -A COLONNE=(
  [cliente]="id,werp_id,ragione_sociale,partita_iva,codice_fiscale,attivo,numero_lavoratori,codice_ateco,livello_rischio,livello_antincendio,gruppo_primo_soccorso,created_at,ateco_origine,livello_rischio_definito_mediante,antincendio_definito_mediante,primo_soccorso_definito_mediante"
  [sede]="id,cliente_id,nome,indirizzo,localita,provincia,principale,attivo,created_at"
  [persona]="id,cliente_id,sede_id,nome,cognome,codice_fiscale,mansione,data_assunzione,attivo,data_cessazione,import_key,updated_at"
  [nomina]="id,persona_id,figura_codice,data_nomina,attiva,note,estremi_procura,da_confermare,origine,origine_testo,created_at,updated_at"
  [formazione]="id,codice_fiscale,corso_titolo,corso_codice_origine,data_completamento,ore,ente_erogatore,esito,fonte"
  [formazione_frazionata]="id,esecuzione_id,file,codice_fiscale,corso_titolo,data_sessione,dettagli_ore,durata,dichiarazione"
)

# ---------- il cluster usa e getta ----------
#
# In una cartella temporanea del sistema, fuori da ogni repository, con
# autenticazione trust e in ascolto solo su localhost. `cluster_ferma` lo ferma e lo
# cancella, e dice se la cancellazione e riuscita: con i dati veri, un cluster
# rimasto sul disco e una copia dell'archivio che nessuno sa di avere.

CLUSTER_DIR=""

pg_nel_path() {
  if [ -n "${PGBIN:-}" ]; then PATH="$PGBIN:$PATH"; fi
  if ! command -v initdb >/dev/null 2>&1; then
    local d ultimo=""
    for d in "/c/Program Files/PostgreSQL/"*/bin; do
      [ -x "$d/initdb.exe" ] && ultimo="$d"
    done
    [ -n "$ultimo" ] && PATH="$ultimo:$PATH"
  fi
  command -v initdb >/dev/null 2>&1 && command -v pg_ctl >/dev/null 2>&1 && command -v psql >/dev/null 2>&1
}

porta_libera() {
  local p
  for p in $(seq 5487 5520); do
    if ! netstat -an 2>/dev/null | grep -qE "[:.]$p[[:space:]]"; then echo "$p"; return 0; fi
  done
  return 1
}

cluster_avvia() {
  pg_nel_path || { echo "  initdb, pg_ctl o psql non trovati: indicare PGBIN=<cartella bin di PostgreSQL>"; return 1; }
  PORTA="$(porta_libera)" || { echo "  nessuna porta libera fra 5487 e 5520"; return 1; }
  CLUSTER_DIR="$(mktemp -d)" || return 1
  if ! initdb -D "$CLUSTER_DIR/dati" -U postgres -A trust -E UTF8 --no-locale >"$CLUSTER_DIR/initdb.log" 2>&1; then
    echo "  initdb non riuscito:"; tail -n 5 "$CLUSTER_DIR/initdb.log"; return 1
  fi
  if ! pg_ctl -D "$CLUSTER_DIR/dati" -o "-p $PORTA -c listen_addresses=localhost" \
         -l "$CLUSTER_DIR/server.log" -w start >/dev/null 2>&1; then
    echo "  il server non parte"; return 1
  fi
  # Il client parla UTF8 perche' glielo si dice, non perche' lo indovina. Su
  # Windows psql prende la codifica dalla console: il 16 settembre 2026 lo stesso
  # seed e' passato in un terminale e si e' fermato in un altro con «character with
  # byte sequence 0x9d in encoding "WIN1252" has no equivalent in encoding "UTF8"»,
  # sull'apostrofo tipografico dei titoli del gestionale. I CSV non lo vedevano
  # perche' `\copy` porta `encoding 'UTF8'` scritto nella riga; i file .sql no.
  # Un caricamento che dipende da quale finestra lo lancia e' peggio di uno che
  # fallisce sempre.
  export PGCLIENTENCODING=UTF8
  PSQL=(psql -h localhost -p "$PORTA" -U postgres -X -q -v ON_ERROR_STOP=1)
}

cluster_ferma() {
  [ -n "$CLUSTER_DIR" ] || return 0
  pg_ctl -D "$CLUSTER_DIR/dati" -m fast -w stop >/dev/null 2>&1
  rm -rf "$CLUSTER_DIR"
  if [ -e "$CLUSTER_DIR" ]; then
    echo "ATTENZIONE: il cluster in $CLUSTER_DIR NON e stato cancellato, e va cancellato a mano"
  else
    echo "cluster fermato e cancellato"
  fi
  CLUSTER_DIR=""
}

# Supabase quanto basta alle migrazioni: lo schema auth con le tre funzioni che le
# policy chiamano, a null, e i tre ruoli a cui le migrazioni danno i grant.
supabase_simulato_sql() {
  cat <<'SQL'
create schema auth;
create function auth.uid() returns uuid language sql stable as $$ select null::uuid $$;
create function auth.role() returns text language sql stable as $$ select null::text $$;
create function auth.jwt() returns jsonb language sql stable as $$ select null::jsonb $$;
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
SQL
}

# `psql.exe` su Windows non capisce /c/Users/...: dentro una stringa SQL la
# conversione automatica di Git Bash non avviene.
percorso_per_psql() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi
}
