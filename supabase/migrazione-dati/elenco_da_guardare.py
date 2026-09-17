# -*- coding: utf-8 -*-
"""AppOverall — migrazione dati: le persone da guardare, in un foglio da compilare.

    python elenco_da_guardare.py <cartella dell'estrazione>

Sono le persone che il passo 02b fa entrare **cessate** pur essendo **attive per
AppFormazione**: la sua anagrafica (6 agosto 2026) le ha, quella di AppSopralluoghi
(9 settembre) no, e vince la piu' recente. Il 17 settembre 2026 sui dati veri erano 34.
Se qualcuna lavora ancora, e' l'anagrafica che va completata — e finche' non lo e', le
sue scadenze non le segue nessuno.

Legge dalla cartella dell'estrazione gli stessi file della prova generale:

    persona.csv                l'anagrafe di AppSopralluoghi
    persona_storica.csv        le persone di AppFormazione, con rapporti e clienti
    formazione.csv             gli attestati
    formazione_frazionata.csv  le sessioni
    visita.csv                 le visite (da estrai_visite.py)

e scrive `da_guardare.xlsx` **nella stessa cartella**: una riga per persona, con
l'azienda, l'ultimo corso, l'ultima visita e due colonne vuote da compilare. Stampa
soltanto il conteggio. I criteri sono quelli del passo 02b, alla lettera: codice
fiscale valido **con il carattere di controllo** (`codice_fiscale_valido`, 0016), una
storia, nessuna scheda, e `attiva` per AppFormazione.
"""

import csv
import os
import re
import subprocess
import sys
from collections import defaultdict

import openpyxl
from openpyxl.styles import Font, PatternFill

DISPARI = [1, 0, 5, 7, 9, 13, 15, 17, 19, 21, 2, 4, 18, 20, 11, 3, 6, 8, 12, 14, 16, 10, 22, 25, 24, 23]
FORMA = re.compile(r"^[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]$")
NULLI = {"", "null"}


def ferma(msg):
    print("FERMATO: " + msg)
    sys.exit(1)


def pulito(cella):
    return re.sub(r"\s", "", cella or "").upper()


def valido(cella):
    """Il port di codice_fiscale_valido (0016)."""
    c = pulito(cella)
    if len(c) != 16 or not FORMA.match(c):
        return None
    s = 0
    for i, ch in enumerate(c[:15], start=1):
        k = ord(ch) - 48 if ch.isdigit() else ord(ch) - 65
        s += DISPARI[k] if i % 2 == 1 else k
    return c if chr(65 + s % 26) == c[15] else None


def v(x):
    """Un valore dell'SQL Editor: la parola «null» e il vuoto sono la stessa assenza."""
    return None if x is None or x.strip() in NULLI else x.strip()


def righe(cartella, nome):
    percorso = os.path.join(cartella, nome)
    if not os.path.isfile(percorso):
        ferma("manca " + nome)
    with open(percorso, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def main():
    if len(sys.argv) != 2:
        ferma("uso: python elenco_da_guardare.py <cartella dell'estrazione>")
    cartella = sys.argv[1]
    dentro = subprocess.run(["git", "-C", cartella, "rev-parse", "--is-inside-work-tree"],
                            capture_output=True, text=True)
    if dentro.returncode == 0:
        ferma("la cartella e dentro un repository git: i dati veri non entrano in nessun repo")

    anagrafe = {valido(r["codice_fiscale"]) for r in righe(cartella, "persona.csv")} - {None}

    # la storia: l'ultimo corso e l'ultima visita per persona
    ultimo_corso = {}
    for r in righe(cartella, "formazione.csv"):
        cf, data = valido(r["codice_fiscale"]), v(r["data_completamento"])
        if cf and data and (cf not in ultimo_corso or data > ultimo_corso[cf][0]):
            ultimo_corso[cf] = (data, v(r["corso_titolo"]) or "")
    for r in righe(cartella, "formazione_frazionata.csv"):
        cf, data = valido(r["codice_fiscale"]), v(r["data_sessione"])
        if cf and data and (cf not in ultimo_corso or data > ultimo_corso[cf][0]):
            ultimo_corso[cf] = (data, (v(r["corso_titolo"]) or "") + " (sessione)")
    ultima_visita = {}
    for r in righe(cartella, "visita.csv"):
        cf, data = valido(r["codice_fiscale"]), v(r["data_esecuzione"])
        if cf and data and (cf not in ultima_visita or data > ultima_visita[cf][0]):
            ultima_visita[cf] = (data, v(r["tipo"]) or "")

    # le persone attive per AppFormazione, con i loro rapporti
    persone = {}
    rapporti = defaultdict(list)
    for r in righe(cartella, "persona_storica.csv"):
        cf = valido(r["codice_fiscale"])
        if not cf or (v(r["attiva"]) or "").lower() not in ("true", "t"):
            continue
        persone[cf] = (v(r["cognome"]) or "", v(r["nome"]) or "", v(r["data_nascita"]) or "")
        if v(r["rapporto_id"]):
            rapporti[cf].append((v(r["ragione_sociale"]) or "", v(r["partita_iva"]) or "",
                                 v(r["mansione"]) or "", v(r["data_assunzione"]) or ""))

    da_guardare = sorted(
        cf for cf in persone
        if cf not in anagrafe and (cf in ultimo_corso or cf in ultima_visita)
    )

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Da guardare"
    intest = ["Codice fiscale", "Cognome", "Nome", "Data di nascita",
              "Azienda", "P.IVA", "Mansione", "Assunto il",
              "Ultimo corso", "Data ultimo corso", "Ultima visita", "Data ultima visita",
              "Attivita dal 2025", "LAVORA ANCORA? (si/no)", "DATA DI USCITA", "Note"]
    ws.append(intest)
    for c in ws[1]:
        c.font = Font(bold=True)
    giallo = PatternFill("solid", fgColor="FFF2CC")
    for cf in sorted(da_guardare, key=lambda x: (not max(ultimo_corso.get(x, ("",))[0],
                                                       ultima_visita.get(x, ("",))[0]) >= "2025-01-01",
                                                 persone[x][0], persone[x][1])):
        cognome, nome, nascita = persone[cf]
        corso = ultimo_corso.get(cf, ("", ""))
        visita = ultima_visita.get(cf, ("", ""))
        recente = "si" if max(corso[0], visita[0]) >= "2025-01-01" else "no"
        for az in (rapporti[cf] or [("", "", "", "")]):
            ws.append([cf, cognome, nome, nascita, az[0], az[1], az[2], az[3],
                       corso[1], corso[0], visita[1], visita[0], recente, "", "", ""])
            for col in (14, 15):
                ws.cell(row=ws.max_row, column=col).fill = giallo
    ws.freeze_panes = "B2"
    ws.auto_filter.ref = ws.dimensions
    for col, larghezza in zip("ABCDEFGHIJKLMNOP", [18, 18, 16, 12, 34, 13, 20, 11, 40, 12, 26, 12, 10, 16, 14, 30]):
        ws.column_dimensions[col].width = larghezza

    uscita = os.path.join(cartella, "da_guardare.xlsx")
    wb.save(uscita)
    recenti = sum(1 for cf in da_guardare
                  if max(ultimo_corso.get(cf, ("",))[0], ultima_visita.get(cf, ("",))[0]) >= "2025-01-01")
    print("persone da guardare: %d (con attivita dal 2025: %d), righe nel foglio: %d"
          % (len(da_guardare), recenti, ws.max_row - 1))
    print("scritto: da_guardare.xlsx, nella cartella dell'estrazione")


if __name__ == "__main__":
    main()
