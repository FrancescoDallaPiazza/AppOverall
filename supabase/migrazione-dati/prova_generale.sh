#!/usr/bin/env bash
# AppOverall — migrazione dati, la prova generale.
#
# Esegue la migrazione dati DA CAPO A FONDO su un cluster PostgreSQL usa e getta:
# crea il cluster con Supabase simulato, applica tutte le migrazioni in ordine, poi il
# passo 00, carica i sei CSV, esegue i passi da 01 a 05 con i conteggi attesi, stampa gli
# avvisi dei passi e i conteggi finali, e **ferma e cancella il cluster** — anche
# quando si ferma, e anche con Ctrl+C.
#
#   bash prova_generale.sh <cartella dei CSV> \
#        clienti_attesi=N sedi_attese=N righe_attese=N nomine_attese=N \
#        righe_formazione_attese=N righe_frazionata_attese=N [null_scritto=null]
#
# ---------- null_scritto, e perche esiste ----------
#
# L'SQL Editor di Supabase scrive i valori nulli come la **parola** `null`, non come
# campo vuoto. Su una colonna di testo quella parola entrerebbe **come testo**, senza
# che niente protesti; su una colonna non di testo il caricamento si ferma subito, ed
# e cosi che se ne accorge chi non lo sa (16 settembre 2026: `cliente.csv`, riga 5,
# `numero_lavoratori`). Con `null_scritto=null` entrano come NULL i campi che valgono
# **esattamente** quella parola.
#
# Cio che l'opzione non puo sapere: **un valore vero uguale a «null»** entrerebbe come
# NULL anche lui. In CSV, PostgreSQL non applica la parola nulla ai valori fra
# virgolette — ma l'editor le mette solo quando servono, quindi un «null» vero e uno
# finto si scrivono uguali. Si verifica **alla fonte**, con una query, e la query sta
# in `estrazione.md`: qui non si puo.
#
# La cartella contiene cliente.csv, sede.csv, persona.csv, nomina.csv, formazione.csv
# e formazione_frazionata.csv, e **deve stare
# fuori da qualunque repository**: lo script lo controlla e si rifiuta. Come si
# producono i file, e da dove vengono i conteggi: `estrazione.md`, accanto.
#
# ---------- cosa dice quando finisce ----------
#
# L'ultima riga e sempre una delle due:
#
#   ARRIVATA IN FONDO
#   FERMATA in: <fase>      preceduta dal messaggio di chi ha rifiutato
#
# Le fasi, in ordine: controlli iniziali, avvio del cluster, Supabase simulato,
# migrazione <file>, seed degli alias, passo 00, caricamento di <tabella>.csv, passo 01,
# passo 02, passo 03, passo 04, passo 05, conteggi finali. Un passo che si ferma non ha scritto niente: ognuno sta
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
# I due seed del dizionario alias. Si puo indicare un'altra cartella con SEED=,
# e serve a una cosa sola: provare che questo passo si ferma davvero quando i
# conti non tornano (verifica_prova_generale.sh).
SEED="$(cd "${SEED:-$DIR/../seed}" && pwd)"
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
righe_formazione_attese=""; righe_frazionata_attese=""; null_scritto=""
for a in "$@"; do
  case "$a" in
    clienti_attesi=*|sedi_attese=*|righe_attese=*|nomine_attese=*|righe_formazione_attese=*|righe_frazionata_attese=*)
      [[ "${a#*=}" =~ ^[0-9]+$ ]] || ferma "$a: il conteggio non e un numero"
      printf -v "${a%%=*}" '%s' "${a#*=}" ;;
    null_scritto=*)
      null_scritto="${a#*=}"
      [[ "$null_scritto" =~ ^[A-Za-z0-9_]+$ ]] \
        || ferma "null_scritto: solo lettere, cifre e _ (con l'SQL Editor di Supabase: null_scritto=null)" ;;
    *) ferma "parametro sconosciuto: $a" ;;
  esac
done
for k in clienti_attesi sedi_attese righe_attese nomine_attese righe_formazione_attese righe_frazionata_attese; do
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
echo "attesi:   clienti $clienti_attesi, sedi $sedi_attese, righe persona $righe_attese, nomine $nomine_attese, attestati $righe_formazione_attese, sessioni frazionate $righe_frazionata_attese"

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

# ============================================================================
#  il seed del dizionario alias
# ============================================================================
#
# 268 giudizi presi a mano su altrettanti testi del gestionale. Non sono dati
# personali e stanno nel repo, ma entrano qui e non nelle migrazioni: una
# migrazione dice com'e fatta la tabella, questo dice cosa c'e dentro, e le due
# cose si aggiornano per ragioni diverse. Se si perdessero, `corso_alias` ci
# sarebbe lo stesso, vuota, e nessun vincolo protesterebbe: per questo il passo
# conta le righe invece di limitarsi a caricarle.

FASE="seed degli alias"
echo; echo "== $FASE"
esegui --zitto -f "$SEED/corso_alias.sql" || ferma
esegui --zitto -f "$SEED/corso_alias_origine.sql" || ferma
conti="$("${PSQL[@]}" -d generale -At -F' ' -c "select count(*), count(corso_codice), count(*) filter (where ignorato), count(*) filter (where is_aggiornamento), count(*) filter (where parziale), count(*) filter (where pregressa), count(distinct corso_codice) from corso_alias")"
ATTESI_ALIAS="268 237 31 98 7 2 39"
if [ "$conti" != "$ATTESI_ALIAS" ]; then
  ferma "il dizionario alias non e quello atteso"         "attesi:  $ATTESI_ALIAS" "trovati: $conti"         "(totale, mappati, ignorati, aggiornamenti, parziali, pregresse, codici distinti usati)"
fi
echo "  268 alias: 237 mappati su 39 codici, 31 ignorati, 98 aggiornamenti, 7 parziali, 2 pregresse"
orfani="$("${PSQL[@]}" -d generale -At -c "select count(*) from corso c where not exists (select 1 from corso_alias a where a.corso_codice = c.codice)")"
echo "  codici a catalogo che nessun alias nomina: $orfani (ATTR_GENERICO e noto)"

FASE="passo 00"
esegui --zitto -f "$DIR/00_origine.sql" || ferma

# ============================================================================
#  i sei CSV
# ============================================================================

echo; echo "== caricamento"
COPIA_NULL=""
if [ -n "$null_scritto" ]; then
  COPIA_NULL=", null '$null_scritto'"
  echo "  i valori nulli sono scritti «$null_scritto»: un campo che vale esattamente quella parola entra come NULL"
fi
for t in $TABELLE; do
  FASE="caricamento di $t.csv"
  if ! esegui -c "\\copy origine.$t from '$(percorso_per_psql "$CSV/$t.csv")' with (format csv, header true, encoding 'UTF8'$COPIA_NULL)"; then
    [ -n "$null_scritto" ] || ferma "se i CSV vengono dall'SQL Editor, i valori nulli sono la parola «null»: rilanciare con null_scritto=null"
    ferma
  fi
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

FASE="passo 04"
echo; echo "== $FASE, gli attestati"
esegui -v righe_formazione_attese="$righe_formazione_attese" -f "$DIR/04_formazione.sql" || ferma

FASE="passo 05"
echo; echo "== $FASE, le sessioni dei percorsi frazionati"
esegui -v righe_frazionata_attese="$righe_frazionata_attese" -f "$DIR/05_frazionata.sql" || ferma

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
# Il percorso si legge dalla vista, perche' e' li' che il motore lo leggera': se la
# 0022 non fosse applicata, le sessioni dei percorsi chiusi risulterebbero aperte.
"${PSQL[@]}" -d generale -At -c "
  select '  attestati e sessioni ' || (select count(*) from evento_formativo)
      || ', percorsi ' || count(*)
      || ' (' || count(*) filter (where completo) || ' completi, '
      || count(*) filter (where sessioni_aperte > 0) || ' con sessioni aperte, '
      || count(*) filter (where not completo and sessioni_aperte = 0) || ' non completi e senza sessioni aperte)'
    from v_percorso_formativo" || ferma "conteggi non letti"
"${PSQL[@]}" -d generale -At -c "
  select '  nomine per ruolo: ' || coalesce(string_agg(ruolo || ' ' || n, ', ' order by n desc, ruolo), 'nessuna')
    from (select ruolo, count(*) n from nomina group by ruolo) s" || ferma "conteggi non letti"

echo
cluster_ferma
echo "ARRIVATA IN FONDO"
exit 0
