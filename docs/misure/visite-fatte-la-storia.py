# -*- coding: utf-8 -*-
"""Visite Fatte: la storia c'e' o no. SOLA LETTURA."""
import sys, os, openpyxl, collections, datetime, re
sys.stdout.reconfigure(encoding='utf-8')
D = os.path.join('C:', os.sep, 'Users', 'Francesco', 'Downloads')

def leggi(nome):
    wb = openpyxl.load_workbook(os.path.join(D, nome), read_only=True, data_only=True)
    ws = wb[wb.sheetnames[0]]; ws.reset_dimensions()
    R = [r for r in ws.iter_rows(values_only=True)]
    wb.close()
    return R

for f in ['ExportExcel (6).xlsx', 'ExportExcel (7).xlsx']:
    R = leggi(f)
    print('==', f, '| righe lette:', len(R))
    for i in (0, 2, 3):
        print(f'   riga {i+1}:', [str(v)[:22] for v in R[i][:12] if v is not None][:12])
    print('   ultime due:', [str(R[-2][0])[:44], str(R[-1][0])[:44]])
    print()

R6 = leggi('ExportExcel (6).xlsx')
intest = [str(v).strip() if v else '' for v in R6[2]]
print('colonne del (6):', [(i, c) for i, c in enumerate(intest) if c])
def idx(nome):
    for i, c in enumerate(intest):
        if c.lower() == nome.lower(): return i
    return None
iCF, iTipo, iData, iGen, iSoc = idx('Codice Fiscale'), idx('Tipo'), idx('Data'), idx('Genere'), idx('Societa')
if iSoc is None: iSoc = idx('Società')
print('indici: cf', iCF, 'tipo', iTipo, 'data', iData, 'genere', iGen, 'societa', iSoc)
PIE = re.compile(r'^(https?://|Dati aggiornati al|Report aggiornato al)', re.I)
dati = [r for r in R6[3:] if r and r[0] is not None and not PIE.match(str(r[0]).strip())]
dati = [r for r in dati if any(v not in (None, '') for v in r)]
print()
print('righe dati:', len(dati))
gen = collections.Counter(str(r[iGen]).strip() for r in dati if iGen is not None and r[iGen])
print('genere:', dict(gen))
tipi = collections.Counter(str(r[iTipo]).strip() for r in dati if r[iTipo])
print('tipi distinti:', len(tipi))
for t, n in tipi.most_common(): print(f'     {t:<36} {n:>5}')
soc = {str(r[iSoc]).strip() for r in dati if r[iSoc]}
cf = {str(r[iCF]).strip().upper() for r in dati if r[iCF]}
print('societa distinte:', len(soc), '| C.F. distinti:', len(cf))
date = [r[iData] for r in dati if isinstance(r[iData], (datetime.date, datetime.datetime))]
print('date: da', min(date).date() if date else '-', 'a', max(date).date() if date else '-')

print()
print('== LA STORIA: coppie (C.F., tipo) con piu di una data')
coppie = collections.defaultdict(set)
for r in dati:
    if r[iCF] and r[iTipo] and isinstance(r[iData], (datetime.date, datetime.datetime)):
        d = r[iData].date() if isinstance(r[iData], datetime.datetime) else r[iData]
        coppie[(str(r[iCF]).strip().upper(), str(r[iTipo]).strip())].add(d)
print('coppie distinte:', len(coppie))
dist = collections.Counter(len(v) for v in coppie.values())
piu = sum(n for k, n in dist.items() if k > 1)
print('con PIU DI UNA data:', piu)
for k in sorted(dist): print(f'     {k} date: {dist[k]:>5} coppie')
