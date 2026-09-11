# -*- coding: utf-8 -*-
"""Verifica dei numeri di AppSopralluoghi contro il VINCOLO della nostra 0001.
SOLA LETTURA."""
import sys, openpyxl, collections, re
sys.stdout.reconfigure(encoding='utf-8')

F = r"C:\Users\Francesco\Downloads\ExportExcel (4).xlsx"
wb = openpyxl.load_workbook(F, read_only=True, data_only=True)
ws = wb['Visite']; ws.reset_dimensions()
R = [r for r in ws.iter_rows(values_only=True)]
wb.close()
dati = R[2:]
def g(r, j): return r[j] if j < len(r) else None
SOC, COG, NOM, CF = 0, 2, 3, 4

print('== la riga di pie di pagina')
sospette = [(i+3, g(r,SOC), g(r,COG), g(r,NOM)) for i, r in enumerate(dati)
            if g(r,SOC) and not g(r,COG) and not g(r,NOM)]
for x in sospette: print('   riga', x[0], '| societa:', repr(x[1]), '| cognome/nome vuoti')
vere = [r for r in dati if g(r,COG) or g(r,NOM)]
print('   righe con societa:', sum(1 for r in dati if g(r,SOC)), '| righe PERSONA vere:', len(vere))

print()
print('== i C.F. contro il check della 0001:  ^[A-Z0-9]{16}$')
ok = re.compile(r'^[A-Z0-9]{16}$')
buoni, rotti, vuoti = [], [], 0
for r in vere:
    v = g(r, CF)
    if v is None or str(v).strip() == '': vuoti += 1; continue
    t = str(v).strip().upper()
    (buoni if ok.match(t) else rotti).append((t, g(r,SOC), g(r,COG), g(r,NOM)))
print('   passano il check :', len(buoni))
print('   RIFIUTATI        :', len(rotti))
print('   cella vuota      :', vuoti)
for t, s, c, n in rotti:
    print(f'      {t!r:24} len={len(t):>2}  {str(c)} {str(n)} — {str(s)[:30]}')

print()
print('== i C.F. ripetuti: stessa societa o societa diverse?')
per_cf = collections.defaultdict(list)
for t, s, c, n in buoni: per_cf[t].append((str(s).strip(), c, n))
rip = {k: v for k, v in per_cf.items() if len(v) > 1}
print('   C.F. validi distinti:', len(per_cf), '| ripetuti:', len(rip))
for k, v in rip.items():
    soc = {x[0] for x in v}
    tipo = 'CLIENTI DIVERSI' if len(soc) > 1 else 'STESSO CLIENTE'
    print(f'      {k}  {v[0][1]} {v[0][2]:<14} {tipo}: ' + ' / '.join(sorted(soc))[:60])

print()
print('== omonimi senza C.F. dentro lo stesso cliente')
senza = [(str(g(r,SOC)).strip(), str(g(r,COG) or "").strip().upper(), str(g(r,NOM) or "").strip().upper())
         for r in vere if not g(r, CF) or not ok.match(str(g(r,CF)).strip().upper())]
c2 = collections.Counter(senza)
amb = {k: n for k, n in c2.items() if n > 1}
print('   righe senza C.F. valido:', len(senza), '| gruppi (cliente,cognome,nome) ambigui:', len(amb))
for k, n in amb.items(): print('      ', k, 'x', n)

print()
print('== e gli omonimi senza C.F. fra CLIENTI DIVERSI — il rischio del NOSTRO modello')
per_nome = collections.defaultdict(set)
for s, c, n in senza: per_nome[(c, n)].add(s)
cross = {k: v for k, v in per_nome.items() if len(v) > 1}
print('   stesso cognome+nome senza C.F. su piu clienti:', len(cross))
for k, v in list(cross.items())[:10]: print('      ', k, '->', len(v), 'clienti')
