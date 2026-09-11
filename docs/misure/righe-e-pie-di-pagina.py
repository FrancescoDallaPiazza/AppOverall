# -*- coding: utf-8 -*-
"""Le righe di pie di pagina e i conti veri, su sei file. SOLA LETTURA."""
import sys, os, openpyxl, re
sys.stdout.reconfigure(encoding='utf-8')
D = os.path.join('C:', os.sep, 'Users', 'Francesco', 'Downloads')
FILE = ['ExportExcelCorsiFatti.xlsx', 'ExportExcelCorsiScadenze.xlsx',
        'ExportExcelVisiteScadenze.xlsx', 'elencoAnagraficaFormazioni.xlsx',
        'ElencoSedi.xlsx', 'ExportExcel (4).xlsx']
PIE = re.compile(r'^(https?://|Dati aggiornati al|Report aggiornato al)', re.I)
for f in FILE:
    p = os.path.join(D, f)
    try:
        wb = openpyxl.load_workbook(p, read_only=True, data_only=True)
    except Exception as e:
        print(f'{f:<40} ERRORE {e}')
        continue
    for nome in wb.sheetnames:
        ws = wb[nome]
        ws.reset_dimensions()
        R = [r for r in ws.iter_rows(values_only=True)]
        pied = [(i + 1, str(r[0])[:46]) for i, r in enumerate(R)
                if r and r[0] and PIE.match(str(r[0]).strip())]
        eti = (f + ' :: ' + nome) if len(wb.sheetnames) > 1 else f
        print(f'{eti:<46} lette={len(R):>6}   PIE={len(pied)}   dati={len(R)-len(pied)}')
        for n, t in pied:
            print(f'        riga {n}: {t!r}')
    wb.close()
