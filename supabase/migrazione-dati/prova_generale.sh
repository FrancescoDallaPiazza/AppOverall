#!/usr/bin/env bash
# AppOverall — migrazione dati, la prova generale.
#
# Esegue la migrazione dati DA CAPO A FONDO su un cluster PostgreSQL usa e getta:
# crea il cluster con Supabase simulato, applica tutte le migrazioni in ordine, poi il
# passo 00, carica i quattro CSV, esegue 01, 02 e 03 con i conteggi attesi, stampa gli
# avvisi dei passi e i conteggi finali, e **ferma e cancella il cluster** — anche
# quando si ferma, e anche con Ctrl+C.
#
#   bash prova_generale.sh <cartella dei CSV> \
#        clienti_attesi=N sedi_attese=N righe_attese=N nomine_attese=N
#
# La cartella contiene cliente.csv, sede.csv, persona.csv e nomina.csv e **deve stare
# fuori da qualunque repository**: lo script lo controlla e si rifiuta. Come si
# producono i file, e da dove vengono i quattro numeri: `estrazione.md`, accanto.
#
# ---------- cosa dice quando finisce ----------
#
# L'ultima riga e sempre una delle due:
#
#   ARRIVATA IN FONDO
#   FERMATA in: <fase>      preceduta dal messaggio di chi ha rifiutato
#
# Le fasi, in ordine: controlli iniziali, avvio del cluster, Supabase simulato,
# migrazione <file>, passo 00, caricamento di <tabella>.csv, passo 01, passo 02,
# passo 03, conteggi finali. Un passo che si ferma non ha scritto niente: ognuno sta
# in una transazione. Ma il cluster si cancella comunque, quindi per ripartire si
# rilancia tutto: e voluto, perche il giro intero e la prova.
#
# ---------- e cosa NON stampa ----------
#
# Con i dati veri, cio che questo script stampa finisce in un terminale, e un
# terminale finisce nei log di una sessione. Quindi stampa **numeri e i messaggi dei
# controlli**, che non contengono dati. Degli errori di PostgreSQL stampa la prima
# riga con i valori fra virgolette omessi, e del `\copy` il numero di riga del CSV:
# **non il DETAIL**, che per un vincolo violato riporta la riga intera, e non il
# valore nel CONTEXT. Di un'intestazione sbagliata stampa i nomi solo se sono nomi di
# colonna. La riga si cerca nel file, che sta sul disco di chi l'ha estratto.

set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
MIGRAZIONI="$(cd "$DIR/../migrations" && pwd)"
. "$DIR/prova_generale_comune.sh"

FASE="controlli iniziali"

ferma() {
  echo
  [ $# -gt 0 ] && printf '  %s\n' "$@"
  cluster_ferma
  echo "FERMATA in: $FASE"
  exit 1
}
trap 'cluster_ferma' EXIT
trap 'echo; cluster_ferma; echo "FERMATA in: $FASE (interrotta a mano)"; exit 130' INT TERM

esegui() { # [--zitto] argomenti di psql, sul database della prova
  local zitto=""
  if [ "${1:-}" = "--zitto" ]; then zitto=1; shift; fi
  local err="$CLUSTER_DIR/stderr" rc
  "${PSQL[@]}" -d generale "$@" >/dev/null 2>"$err"; rc=$?
  if [ -z "$zitto" ]; then
    grep -E '(NOTICE|AVVISO):' "$err" | sed -E 's/^.*(NOTICE|AVVISO): +/    | /'
  fi
  if [ $rc -ne 0 ]; then
    grep -E '(ERROR|ERRORE|FATAL|FATALE):|psql: (error|errore)' "$err" \
      | sed -E -e 's/^.*(ERROR|ERRORE|FATAL|FATALE|psql: error|psql: errore): *//' -e 's/"[^"]*"/«valore omesso»/g' -e 's/^/    ! /'
    grep -oE '(CONTEXT|CONTESTO): +COPY [a-z_]+, (line|riga) [0-9]+' "$err" | sed 's/^/    ! /'
  fi
  rm -f "$err"
  return $rc
}

# ============================================================================
#  controlli iniziali — prima di creare qualunque cosa
# ============================================================================

[ $# -ge 1 ] || ferma "uso: bash prova_generale.sh <cartella dei CSV> clienti_attesi=N sedi_attese=N righe_attese=N nomine_attese=N"
CSV="$1"; shift

clienti_attesi=""; sedi_attese=""; righe_attese=""; nomine_attese=""
for a in "$@"; do
  case "$a" in
    clienti_attesi=*|sedi_attese=*|righe_attese=*|nomine_attese=*)
      [[ "${a#*=}" =~ ^[0-9]+$ ]] || ferma "$a: il conteggio non e un numero"
      printf -v "${a%%=*}" '%s' "${a#*=}" ;;
    *) ferma "parametro sconosciuto: $a" ;;
  esac
done
for k in clienti_attesi sedi_attese righe_attese nomine_attese; do
  [ -n "${!k}" ] || ferma "manca $k=<numero>: il count fatto nello stesso momento dell'estrazione (estrazione.md)"
done

[ -d "$CSV" ] || ferma "la cartella dei CSV non esiste: $CSV"
CSV="$(cd "$CSV" && pwd)"
if git -C "$CSV" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ferma "la cartella dei CSV e dentro un repository git: $(git -C "$CSV" rev-parse --show-toplevel)" \
        "i dati veri non entrano in nessun repo, nemmeno per una prova"
fi

for t in $TABELLE; do
  f="$CSV/$t.csv"
  [ -f "$f" ] || ferma "manca $t.csv in $CSV"
  h="$(head -n 1 "$f" | sed -e 's/^\xEF\xBB\xBF//' -e 's/\r$//' -e 's/"//g' -e 's/[[:space:]]//g')"
  if [ "$h" != "${COLONNE[$t]}" ]; then
    if [[ "$h" =~ ^[a-z_,]+$ ]]; then trovate="$h"; else trovate="(la prima riga non e un'intestazione: non si stampa)"; fi
    ferma "$t.csv: le colonne non sono quelle della select del passo 00, o non sono nello stesso ordine" \
          "attese:  ${COLONNE[$t]}" "trovate: $trovate"
  fi
  case "$(percorso_per_psql "$f")" in
    *"'"*) ferma "il percorso di $t.csv contiene un apostrofo, che \\copy non accetta: spostare la cartella" ;;
  esac
done

echo "cartella: $CSV"
echo "attesi:   clienti $clienti_attesi, sedi $sedi_attese, righe persona $righe_attese, nomine $nomine_attese"

# ============================================================================
#  il cluster, Supabase simulato, le migrazioni
# ============================================================================

FASE="avvio del cluster"
echo; echo "== $FASE"
cluster_avvia || ferma
echo "  porta $PORTA, in $CLUSTER_DIR"
"${PSQL[@]}" -d postgres -c "create database generale" >/dev/null 2>&1 || ferma "create database non riuscito"

FASE="Supabase simulato"
supabase_simulato_sql | esegui --zitto -f - || ferma

n=0; ultima=""
for f in "$MIGRAZIONI"/[0-9][0-9][0-9][0-9]_*.sql; do
  FASE="migrazione $(basename "$f")"
  esegui --zitto -f "$f" || ferma
  n=$((n+1)); ultima="$(basename "$f")"
done
echo "  $n migrazioni applicate in ordine, l'ultima e $ultima"

FASE="passo 00"
esegui --zitto -f "$DIR/00_origine.sql" || ferma

# ============================================================================
#  i quattro CSV
# ============================================================================

echo; echo "== caricamento"
for t in $TABELLE; do
  FASE="caricamento di $t.csv"
  esegui -c "\\copy origine.$t from '$(percorso_per_psql "$CSV/$t.csv")' with (format csv, header true, encoding 'UTF8')" || ferma
  echo "  $t.csv: $("${PSQL[@]}" -d generale -At -c "select count(*) from origine.$t") righe"
done

# ============================================================================
#  i passi
# ============================================================================

FASE="passo 01"
echo; echo "== $FASE, i clienti e le sedi"
esegui -v clienti_attesi="$clienti_attesi" -v sedi_attese="$sedi_attese" -f "$DIR/01_clienti.sql" || ferma

FASE="passo 02"
echo; echo "== $FASE, le persone"
esegui -v righe_attese="$righe_attese" -f "$DIR/02_persone.sql" || ferma

FASE="passo 03"
echo; echo "== $FASE, le nomine"
esegui -v nomine_attese="$nomine_attese" -f "$DIR/03_nomine.sql" || ferma

# ============================================================================
#  i conteggi finali
# ============================================================================

FASE="conteggi finali"
echo; echo "== $FASE"
"${PSQL[@]}" -d generale -At -c "
  select '  clienti ' || (select count(*) from cliente)
      || ', sedi ' || (select count(*) from sede)
      || ', unita d''origine ' || (select count(*) from cliente_origine)
      || ' (' || (select count(*) from cliente_origine where assorbito) || ' assorbite)'
      || ', persone ' || (select count(*) from persona)
      || ', rapporti ' || (select count(*) from rapporto_lavoro)
      || ', nomine ' || (select count(*) from nomina)" || ferma "conteggi non letti"
"${PSQL[@]}" -d generale -At -c "
  select '  nomine per ruolo: ' || coalesce(string_agg(ruolo || ' ' || n, ', ' order by n desc, ruolo), 'nessuna')
    from (select ruolo, count(*) n from nomina group by ruolo) s" || ferma "conteggi non letti"

echo
cluster_ferma
echo "ARRIVATA IN FONDO"
exit 0
