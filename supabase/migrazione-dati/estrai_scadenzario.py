# -*- coding: utf-8 -*-
"""AppOverall — il riscontro della Fase 4: lo scadenzario dei corsi di Sicurweb in un CSV.

    python estrai_scadenzario.py <ExportExcelCorsiScadenze.xlsx> <cartella>

Il criterio d'uscita della Fase 4 e' un riscontro: il motore deve dire, per ogni persona
e corso, la stessa scadenza di Sicurweb o una diversa con una ragione (`docs/piano-fase-4.md`).
Lo scadenzario dei corsi sta in un export del gestionale, con lo stesso tracciato di
quello delle visite (35 colonne, `Data` e' la scadenza). Questo script lo porta in
`corso_scadenza.csv`, nella cartella dell'estrazione, con le regole di `estrai_visite.py`:
colonne cercate per nome, cartella fuori dai repository, stampa solo numeri.
"""

import csv
import os
import subprocess
import sys

from estrai_visite import data_iso, ferma, leggi, testo


def main():
    if len(sys.argv) != 3:
        ferma("uso: python estrai_scadenzario.py <ExportExcelCorsiScadenze.xlsx> <cartella>")
    sorgente, cartella = sys.argv[1:]
    if not os.path.isdir(cartella):
        ferma("la cartella non esiste: " + cartella)
    dentro = subprocess.run(["git", "-C", cartella, "rev-parse", "--is-inside-work-tree"],
                            capture_output=True, text=True)
    if dentro.returncode == 0:
        ferma("la cartella e dentro un repository git: i dati veri non entrano in nessun repo")

    righe, dich = leggi(sorgente, ["Codice Fiscale", "Stato", "Tipo", "Data"])
    if any(r["Data"] in (None, "") for r in righe):
        ferma("righe dello scadenzario senza data")
    with open(os.path.join(cartella, "corso_scadenza.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["riga", "codice_fiscale", "tipo", "data_scadenza", "stato", "dichiarazione"])
        for r in righe:
            w.writerow([r["riga"], testo(r["Codice Fiscale"]), testo(r["Tipo"]), data_iso(r["Data"]),
                        testo(r["Stato"]), dich])
    print("corso_scadenza.csv: %d righe  (\"%s\")" % (len(righe), dich))
    print("per la prova generale: righe_scadenzario_attese=%d" % len(righe))


if __name__ == "__main__":
    main()
