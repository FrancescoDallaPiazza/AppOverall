# -*- coding: utf-8 -*-
u"""Genera le tabelle di stato delle decisioni leggendo le schede.

La scheda e l'unica fonte. Chi decide tocca un file solo, e questo script
riporta lo stato dove serve. Prima di lui lo stesso fatto stava in quattro
posti e ne invecchiava tre.

    python docs/decisioni/genera.py            riscrive i blocchi
    python docs/decisioni/genera.py --check    esce 1 se sono da riscrivere

Cosa legge, per ogni scheda:

  # N - titolo
  > **Blocca:** cosa tiene fermo, anche se la risposta e "niente"
  > **In una riga:** la sintesi, e c'e solo se la decisione e presa
  ## Decisione
  vuota, o che si apre con *(da scrivere ...  ->  la scheda e APERTA

Un disaccordo fra i due segnali e un errore, non un caso da indovinare: una
scheda decisa senza sintesi, o una sintesi su una scheda ancora aperta,
fermano la generazione con un messaggio che dice quale file guardare.
"""
import io, os, re, sys

QUI = os.path.dirname(os.path.abspath(__file__))
DOCS = os.path.dirname(QUI)

INIZIO = u'<!-- decisioni:inizio (generato da docs/decisioni/genera.py) -->'
FINE = u'<!-- decisioni:fine -->'


def leggi_schede():
    schede = []
    for f in sorted(os.listdir(QUI)):
        m = re.match(r'^(\d+)-(.*)\.md$', f)
        if not m:
            continue
        s = io.open(os.path.join(QUI, f), encoding='utf-8').read()
        titolo = re.match(r'^# (.*)', s).group(1).strip()

        def campo(nome):
            c = re.search(r'^> \*\*' + nome + r':\*\* (.*)$', s, re.M)
            return c.group(1).strip() if c else None

        corpo = re.search(r'^## Decisione\s*\n(.*?)(?=\n## |\Z)', s, re.M | re.S)
        corpo = corpo.group(1).strip() if corpo else u''
        aperta = (not corpo) or corpo.startswith(u'*(da scrivere')

        data = None
        if not aperta:
            d = re.search(r'il (\d{1,2} \w+ \d{4})', corpo)
            data = d.group(1) if d else None

        schede.append(dict(n=int(m.group(1)), file=f, titolo=titolo, aperta=aperta,
                           blocca=campo(u'Blocca'), riga=campo(u'In una riga'),
                           data=data))
    # Per numero e non per nome: alla decima scheda l'ordine alfabetico
    # metterebbe la 10 fra la 1 e la 2, e la tabella comincerebbe a mentire
    # sull'ordine in cui le decisioni sono state poste.
    schede.sort(key=lambda s: s['n'])
    return schede


def controlla(schede):
    errori = []
    for s in schede:
        if s['blocca'] is None:
            errori.append(u'%s manca la riga "> **Blocca:**"' % s['file'])
        if s['aperta'] and s['riga']:
            errori.append(u'%s ha una sintesi ma "## Decisione" e ancora vuota: '
                          u'o si scrive la decisione, o si toglie la sintesi' % s['file'])
        if not s['aperta'] and not s['riga']:
            errori.append(u'%s e decisa e non ha la riga "> **In una riga:**"' % s['file'])
    return errori


def tabella(schede, prefisso):
    chiuse = [s for s in schede if not s['aperta']]
    out = [INIZIO, u'']
    out.append(u'**%d schede su %d sono chiuse.** Stato generato dalle schede: '
               u'il paragrafo `## Decisione` di ognuna e la fonte, questa tabella '
               u'e la resa.' % (len(chiuse), len(schede)))
    out += [u'', u'| scheda | blocca | stato |', u'| --- | --- | --- |']
    for s in schede:
        if s['aperta']:
            stato = u'**aperta**'
        elif s['data']:
            stato = u'**decisa il %s** — %s' % (s['data'], s['riga'])
        else:
            stato = u'**decisa** — %s' % s['riga']
        out.append(u'| [%s](%s%s) | %s | %s |' % (s['titolo'], prefisso, s['file'],
                                                  s['blocca'], stato))
    out += [u'', FINE]
    return u'\n'.join(out)


def scrivi(percorso, blocco, check):
    s = io.open(percorso, encoding='utf-8').read()
    if INIZIO not in s or FINE not in s:
        print(u'%s: mancano i marcatori %s ... %s' % (percorso, INIZIO, FINE))
        return False
    prima = s[:s.index(INIZIO)]
    dopo = s[s.index(FINE) + len(FINE):]
    nuovo = prima + blocco + dopo
    if nuovo == s:
        return True
    if check:
        print(u'da rigenerare: %s' % os.path.relpath(percorso, DOCS))
        return False
    io.open(percorso, 'w', encoding='utf-8', newline='').write(nuovo)
    print(u'riscritto: %s' % os.path.relpath(percorso, DOCS))
    return True


def main():
    check = '--check' in sys.argv
    schede = leggi_schede()
    # Il vincolo non e «quante sono» — le schede si aggiungono quando una
    # verifica isola un bivio nuovo — ma che siano numerate senza buchi: un buco
    # e una scheda cancellata o mai scritta, e in entrambi i casi va vista.
    numeri = [s['n'] for s in schede]
    if numeri != list(range(1, len(numeri) + 1)):
        print(u'le schede non sono numerate consecutivamente da 1: %s'
              % u', '.join(str(n) for n in numeri))
        return 1
    errori = controlla(schede)
    if errori:
        for e in errori:
            print(u'errore: ' + e)
        return 1
    ok = True
    ok &= scrivi(os.path.join(QUI, 'README.md'), tabella(schede, u''), check)
    ok &= scrivi(os.path.join(DOCS, 'PROGRAMMA.md'), tabella(schede, u'decisioni/'), check)
    if check and ok:
        print(u'le tabelle sono allineate alle schede')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
