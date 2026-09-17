# -*- coding: utf-8 -*-
"""AppOverall — migrazione dati: le visite, dai due export del gestionale ai due CSV.

    python estrai_visite.py <ExportExcelVisiteFatte.xlsx> <ExportExcelVisiteScadenze.xlsx> <cartella>

Le visite non stanno in nessun database: AppFormazione le lascia fuori per perimetro,
AppSopralluoghi non le ha mai importate. Stanno in due export del gestionale, e questo
script fa per loro cio' che l'SQL Editor fa per le altre tabelle — scrive un CSV con le
colonne della select del passo 00, nella cartella dell'estrazione:

    visita.csv            la STORIA delle visite (ExportExcelVisiteFatte): una riga per
                          esecuzione. Non il foglio «Visite» del 09/09, che porta solo
                          l'ultima esecuzione per persona e tipo: la storia lo contiene
                          tutto (800 coppie su 800) e ne ha 250 in piu'.
    visita_scadenza.csv   lo scadenzario (ExportExcelVisiteScadenze): una riga per
                          persona e tipo, con la scadenza. Serve solo dove dissente.

SOLA LETTURA sugli xlsx. Scrive due file e stampa soltanto numeri: i due conteggi da
passare alla prova generale e la data che ogni file dichiara. Nessun nome, nessun
codice fiscale.

Le colonne si trovano per NOME d'intestazione, non per posizione: i due export hanno
tracciati diversi (34 e 35 colonne, `Data` in due posti), e un indice fisso
leggerebbe la colonna sbagliata del secondo senza protestare.
"""

import csv
import datetime
import os
import subprocess
import sys
import warnings

import openpyxl

warnings.filterwarnings("ignore")

RIGA_INTESTAZIONI = 3


def ferma(msg):
    print("FERMATO: " + msg)
    sys.exit(1)


def leggi(percorso, colonne):
    """(righe, dichiarazione). Una riga e' un dict con le colonne chieste e `riga`."""
    wb = openpyxl.load_workbook(percorso)
    ws = wb.worksheets[0]
    tutte = list(ws.iter_rows(values_only=True))
    intest = [str(c).strip() if c is not None else "" for c in tutte[RIGA_INTESTAZIONI - 1]]
    mancano = [c for c in colonne if c not in intest]
    if mancano:
        ferma("%s: mancano le colonne %s" % (os.path.basename(percorso), ", ".join(mancano)))
    doppie = [c for c in colonne if intest.count(c) > 1]
    if doppie:
        ferma("%s: colonne ripetute %s" % (os.path.basename(percorso), ", ".join(doppie)))
    idx = {c: intest.index(c) for c in colonne}

    righe, dichiarazioni = [], []
    for n, r in enumerate(tutte[RIGA_INTESTAZIONI:], start=RIGA_INTESTAZIONI + 1):
        r = list(r) + [None] * (len(intest) - len(r))
        primo = r[0] if isinstance(r[0], str) else ""
        if primo.startswith("Dati aggiornati al ") or primo.startswith("Report aggiornato al "):
            dichiarazioni.append(primo.strip())
            continue
        valori = {c: r[i] for c, i in idx.items()}
        # Il piede ha solo la prima colonna piena (l'indirizzo del gestionale, la
        # data): una riga senza nessuna delle colonne chieste non e' una visita.
        if all(v in (None, "") for v in valori.values()):
            continue
        valori["riga"] = n
        righe.append(valori)
    if len(dichiarazioni) != 1:
        ferma("%s: %d righe \"Dati aggiornati al\", ne serve una" % (os.path.basename(percorso), len(dichiarazioni)))
    return righe, dichiarazioni[0]


def data_iso(v):
    if v in (None, ""):
        return ""
    if isinstance(v, datetime.datetime):
        if v.time() != datetime.time(0, 0):
            ferma("una data con l'ora (%s): il tracciato e cambiato" % v.isoformat())
        return v.date().isoformat()
    if isinstance(v, datetime.date):
        return v.isoformat()
    ferma("una data che non e una data: il tracciato e cambiato")


def testo(v):
    return "" if v is None else str(v).strip()


def main():
    if len(sys.argv) != 4:
        ferma("uso: python estrai_visite.py <VisiteFatte.xlsx> <VisiteScadenze.xlsx> <cartella>")
    fatte, scadenze, cartella = sys.argv[1:]
    if not os.path.isdir(cartella):
        ferma("la cartella non esiste: " + cartella)
    dentro = subprocess.run(["git", "-C", cartella, "rev-parse", "--is-inside-work-tree"],
                            capture_output=True, text=True)
    if dentro.returncode == 0:
        ferma("la cartella e dentro un repository git: i dati veri non entrano in nessun repo")

    righe_f, dich_f = leggi(fatte, ["Codice Fiscale", "Genere", "Tipo", "Data"])
    # Una data vuota nel CSV, letto con null_scritto=null, arriverebbe come stringa
    # vuota e il caricamento si fermerebbe su un errore di tipo che non dice quale
    # riga ne quale file: meglio fermarsi qui, dove lo si sa dire.
    if any(r["Data"] in (None, "") for r in righe_f):
        ferma("visite fatte senza data: la data e il fatto, non si deduce")
    generi = {testo(r["Genere"]) for r in righe_f}
    if generi != {"Visita"}:
        ferma("il file delle visite fatte contiene righe che non sono visite: Genere = %s" % sorted(generi))
    with open(os.path.join(cartella, "visita.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["riga", "codice_fiscale", "tipo", "data_esecuzione", "dichiarazione"])
        for r in righe_f:
            w.writerow([r["riga"], testo(r["Codice Fiscale"]), testo(r["Tipo"]), data_iso(r["Data"]), dich_f])

    righe_s, dich_s = leggi(scadenze, ["Codice Fiscale", "Stato", "Tipo", "Data"])
    if any(r["Data"] in (None, "") for r in righe_s):
        ferma("righe dello scadenzario senza data")
    with open(os.path.join(cartella, "visita_scadenza.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["riga", "codice_fiscale", "tipo", "data_scadenza", "stato", "dichiarazione"])
        for r in righe_s:
            w.writerow([r["riga"], testo(r["Codice Fiscale"]), testo(r["Tipo"]), data_iso(r["Data"]),
                        testo(r["Stato"]), dich_s])

    print("visita.csv:          %d righe  (\"%s\")" % (len(righe_f), dich_f))
    print("visita_scadenza.csv: %d righe  (\"%s\")" % (len(righe_s), dich_s))
    print("per la prova generale: righe_visite_attese=%d righe_scadenze_attese=%d" % (len(righe_f), len(righe_s)))


if __name__ == "__main__":
    main()
