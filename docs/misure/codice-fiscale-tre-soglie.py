# -*- coding: utf-8 -*-
"""Le tre soglie sul codice fiscale, calcolate qui. SOLA LETTURA.
Il carattere di controllo e' l'algoritmo del DM 23/12/1976, implementato qui
invece che preso da una libreria: se sbaglia, sbaglia in modo ispezionabile."""
import sys, openpyxl, collections, re
sys.stdout.reconfigure(encoding='utf-8')

DISPARI = {'0':1,'1':0,'2':5,'3':7,'4':9,'5':13,'6':15,'7':17,'8':19,'9':21,
           'A':1,'B':0,'C':5,'D':7,'E':9,'F':13,'G':15,'H':17,'I':19,'J':21,
           'K':2,'L':4,'M':18,'N':20,'O':11,'P':3,'Q':6,'R':8,'S':12,'T':14,
           'U':16,'V':10,'W':22,'X':25,'Y':24,'Z':23}
PARI = {c: i for i, c in enumerate('0123456789')}
PARI.update({c: i for i, c in enumerate('ABCDEFGHIJKLMNOPQRSTUVWXYZ')})
# omocodia: cifre sostituite da lettere in certe posizioni
OMO = {'L':'0','M':'1','N':'2','P':'3','Q':'4','R':'5','S':'6','T':'7','U':'8','V':'9'}
POS_CIFRA = [6,7,9,10,12,13,14]  # 0-based: le sette posizioni numeriche

def controllo(cf15):
    s = 0
    for i, c in enumerate(cf15):          # i 0-based: posizione 1 = i 0 = DISPARI
        s += DISPARI[c] if i % 2 == 0 else PARI[c]
    return chr(ord('A') + s % 26)

def forma_ok(cf):
    if not re.fullmatch(r'[A-Z]{6}[0-9LMNPQRSTUV]{2}[A-EHLMPRST][0-9LMNPQRSTUV]{2}'
                        r'[A-Z][0-9LMNPQRSTUV]{3}[A-Z]', cf): return False
    return True

def normalizza(v):
    return re.sub(r'[^A-Z0-9]', '', str(v).strip().upper())

F = r"C:\Users\Francesco\Downloads\ExportExcel (4).xlsx"
wb = openpyxl.load_workbook(F, read_only=True, data_only=True)
ws = wb['Visite']; ws.reset_dimensions()
R = [r for r in ws.iter_rows(values_only=True)]
wb.close()
def g(r, j): return r[j] if j < len(r) else None
SOC, COG, NOM, CF = 0, 2, 3, 4
vere = [r for r in R[2:] if g(r, COG) or g(r, NOM)]
print('righe persona:', len(vere))

piene = [(str(g(r,CF)).strip(), r) for r in vere if g(r,CF) not in (None, '')]
print('celle C.F. piene:', len(piene))

A = [x for x in piene if re.fullmatch(r'[A-Z0-9]{16}', x[0].upper())]
B = [x for x in piene if re.fullmatch(r'[A-Z0-9]{16}', normalizza(x[0]))]
C, scarti_C = [], []
for t, r in B:
    n = normalizza(t)
    if forma_ok(n) and controllo(n[:15]) == n[15]: C.append((n, r))
    else: scarti_C.append((n, r))
print()
print('  A  16 alfanumerici sul GREZZO ....................', len(A), f'(ne scarta {len(piene)-len(A)})')
print('  B  16 alfanumerici DOPO la pulizia ...............', len(B), f'(ne scarta {len(piene)-len(B)})')
print('  C  pulizia + forma + CARATTERE DI CONTROLLO ......', len(C), f'(ne scarta {len(piene)-len(C)})')
print()
print('  fra B e C:', len(B) - len(C), 'righe sono 16 alfanumerici e NON sono codici fiscali')
print()
segna = [x for x in scarti_C if x[0].startswith('XXXYYY')]
altri = [x for x in scarti_C if not x[0].startswith('XXXYYY')]
print('  SEGNAPOSTO XXXYYY...:', len(segna), '| valori distinti:', len({x[0] for x in segna}))
for n, r in sorted(segna): print(f'     {n}   {str(g(r,COG))} {str(g(r,NOM))} — {str(g(r,SOC))[:34]}')
print()
print('  altri scarti:', len(altri))
for n, r in sorted(altri)[:22]:
    att = controllo(n[:15]) if forma_ok(n) else '?'
    causa = f'controllo {n[15]} invece di {att}' if att != '?' else 'forma non valida'
    print(f'     {n}   {causa:<28} {str(g(r,COG))} {str(g(r,NOM))}')
print()
print('  C.F. VALIDI distinti:', len({n for n, _ in C}), 'su', len(C), 'righe')
rip = {k: v for k, v in collections.Counter(n for n, _ in C).items() if v > 1}
print('  ripetuti fra i validi:', len(rip))
