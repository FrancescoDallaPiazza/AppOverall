# -*- coding: utf-8 -*-
"""Misura delle due fonti della sorveglianza. SOLA LETTURA."""
import sys, openpyxl, collections, datetime
sys.stdout.reconfigure(encoding='utf-8')

F4 = r"C:\Users\Francesco\Downloads\ExportExcel (4).xlsx"
FS = r"C:\Users\Francesco\Downloads\ExportExcelVisiteScadenze.xlsx"

def foglio(path, nome):
    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    ws = wb[nome] if nome in wb.sheetnames else wb[wb.sheetnames[0]]
    ws.reset_dimensions()
    righe = [r for r in ws.iter_rows(values_only=True)]
    wb.close()
    return ws.title, righe

def g(r, j):
    return r[j] if j < len(r) else None

def d(v):
    if v is None or v == '': return None
    if isinstance(v, datetime.datetime): return v.date()
    if isinstance(v, datetime.date): return v
    return ('NON_DATA', v)

titolo, R = foglio(F4, 'Visite')
print('== foglio', titolo, '| righe totali:', len(R))
intest0, intest1 = R[0], R[1]
dati = R[2:]
print('   righe di dati:', len(dati))

# le coppie (nome accertamento, colonna esecuzione, colonna scadenza, periodicita dichiarata)
import re
coppie = []
for j, v in enumerate(intest0):
    if j >= 38 and v:
        per = intest1[j+1] or ''
        m = re.search(r'\((\d+)\s*ann', str(per))
        mesi = int(m.group(1)) * 12 if m else None
        if 'trimestr' in str(intest0[j]).lower() and mesi is None: mesi = 3
        coppie.append((v, j, j+1, mesi, per))
print('   accertamenti trovati:', len(coppie))
for n, ce, cs, mesi, per in coppie:
    print(f'     [{ce:>2}/{cs:>2}] {n:<34} {str(mesi):>4} mesi   sotto-intestazione: {per!r}')

print()
print('== le persone')
CF, COG, NOM, SOC, NAS = 4, 2, 3, 0, 7
con_cf = sum(1 for r in dati if g(r,CF))
cf_distinti = len({str(g(r,CF)).strip().upper() for r in dati if g(r,CF)})
print('   righe persona:', len(dati), '| con C.F.:', con_cf, '| senza:', len(dati) - con_cf)
print('   C.F. distinti:', cf_distinti)
chiavi = {(str(g(r,SOC) or '').strip(), str(g(r,COG) or '').strip().upper(), str(g(r,NOM) or '').strip().upper()) for r in dati}
print('   (societa, cognome, nome) distinti:', len(chiavi))
soc = {str(g(r,SOC) or '').strip() for r in dati}
print('   societa distinte:', len(soc))

print()
print('== le esecuzioni')
tot = 0
per_acc = collections.Counter()
righe_con_almeno_una = 0
non_date = []
for r in dati:
    n_qui = 0
    for n, ce, cs, mesi, per in coppie:
        v = d(g(r,ce))
        if isinstance(v, tuple): non_date.append((n, v[1])); continue
        if v: per_acc[n] += 1; tot += 1; n_qui += 1
    if n_qui: righe_con_almeno_una += 1
print('   ESECUZIONI TOTALI:', tot)
print('   persone con almeno una:', righe_con_almeno_una)
for n, c in per_acc.most_common(): print(f'     {n:<34} {c:>4}')
if non_date: print('   valori non-data:', non_date[:5])

print()
print('== chi sono i 787, e la scadenza del foglio e derivata o dichiarata?')

def piu_mesi(dt, mesi):
    a, m = dt.year, dt.month + mesi
    a += (m - 1) // 12; m = (m - 1) % 12 + 1
    import calendar
    g = min(dt.day, calendar.monthrange(a, m)[1])
    return datetime.date(a, m, g)

con_esec_senza_cf = 0
persone_con_esec = set()
uguale = diversa = mancante = 0
anticipate = posticipate = []
diff = []
for r in dati:
    ha = False
    for n, ce, cs, mesi, per in coppie:
        e = d(g(r, ce)); s = d(g(r, cs))
        if isinstance(e, tuple) or not e: continue
        ha = True
        if not s or isinstance(s, tuple): mancante += 1; continue
        att = piu_mesi(e, mesi)
        if s == att: uguale += 1
        else:
            diversa += 1
            diff.append((str(g(r,SOC))[:22], n, e, s, att, (s - att).days))
    if ha:
        persone_con_esec.add(id(r))
        if not g(r, CF): con_esec_senza_cf += 1
print('   persone con almeno una esecuzione:', len(persone_con_esec))
print('   di queste, SENZA codice fiscale:', con_esec_senza_cf)
print()
print('   scadenza del foglio contro esecuzione + periodicita:')
print('     identica :', uguale)
print('     diversa  :', diversa)
print('     mancante :', mancante)
for x in diff[:12]: print('       ', x)
