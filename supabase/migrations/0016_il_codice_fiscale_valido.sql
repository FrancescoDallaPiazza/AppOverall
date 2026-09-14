-- AppOverall — 0016
-- Il codice fiscale valido, calcolato dove si decide l'identita.
--
-- ============================================================================
--  PERCHE STA NEL DATABASE
-- ============================================================================
--
-- La `0008` ha deciso che un codice fiscale diventa un'identita **solo se passa
-- il carattere di controllo**, e che ogni fallimento vale come assente, con la
-- cella conservata in `persona.codice_fiscale_origine`. Quella regola fin qui
-- stava scritta in un commento e in nessun codice di questo repo: la «funzione di
-- produzione» che la sa calcolare e `valido()` di AppSopralluoghi
-- (`src/formazione/codiceFiscale.ts`), in TypeScript.
--
-- La migrazione delle persone raggruppa per codice fiscale valido, e i conti che
-- deve far tornare — 3.160 righe valide, 3.156 codici distinti, N = 3.415 schede,
-- misurati il 13 settembre con `conti-migrazione.mjs` — sono stati calcolati
-- **con quella funzione**. Una query che filtrasse per forma darebbe un altro
-- numero e lo chiamerebbe con lo stesso nome: e lo scivolamento che lo script
-- stampa apposta, «di FORMA valida» contro «VALIDI».
--
-- ============================================================================
--  PORT FEDELE, E PROVATO CONTRO L'ORIGINALE
-- ============================================================================
--
-- Stesse tre operazioni, nello stesso ordine:
--
--   1. `pulisci`: maiuscolo, via tutto cio che non e lettera o cifra;
--   2. sedici caratteri e la forma con l'omocodia (cifre sostituite da L..V);
--   3. il carattere di controllo sui primi quindici.
--
-- **Non si fida della lettura**: la funzione e confrontata con `valido()` su
-- vettori generati eseguendo il codice di produzione — validi, omocodici, con il
-- controllo sbagliato, minuscoli, con spazi e punteggiatura, P.IVA, stringhe a
-- caso. L'esito del confronto sta nel commit che la introduce.
--
-- Una differenza nota e dichiarata: `toUpperCase` di JavaScript trasforma `ß` in
-- `SS`, `upper` di PostgreSQL no. In un codice fiscale non ce n'e ragione, e se
-- una cella la contenesse le due funzioni direbbero comunque «non valido» per la
-- forma, salvo il caso di una stringa costruita apposta.

create function codice_fiscale_pulito(cella text) returns text
language sql immutable parallel safe
as $$ select regexp_replace(upper(coalesce(cella, '')), '[^A-Z0-9]', '', 'g') $$;

comment on function codice_fiscale_pulito(text) is
  'Il `pulisci` di AppSopralluoghi: maiuscolo, via tutto cio che non e lettera o cifra. **Ripulisce e basta**: una stringa pulita non e per questo un codice fiscale, e il controllo e `codice_fiscale_valido`.';

create function codice_fiscale_valido(cella text) returns boolean
language plpgsql immutable parallel safe
as $$
declare
  c text := codice_fiscale_pulito(cella);
  -- valori delle posizioni dispari per A..Z; le cifre 0..9 valgono come A..J
  dispari constant int[] := array[1,0,5,7,9,13,15,17,19,21,2,4,18,20,11,3,6,8,12,14,16,10,22,25,24,23];
  s int := 0;
  ch text;
  k int;
begin
  if length(c) <> 16
     or c !~ '^[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]$' then
    return false;
  end if;
  for i in 1..15 loop
    ch := substr(c, i, 1);
    k := case when ch between '0' and '9' then ascii(ch) - 48 else ascii(ch) - 65 end;
    s := s + case when i % 2 = 1 then dispari[k + 1] else k end;
  end loop;
  return chr(65 + s % 26) = substr(c, 16, 1);
end
$$;

comment on function codice_fiscale_valido(text) is
  'Vero solo se la cella, ripulita, e un codice fiscale con forma e carattere di controllo giusti, omocodia compresa. Port di `valido()` di AppSopralluoghi, provato contro l''originale: e la funzione con cui sono stati misurati i conti della migrazione, e un controllo di sola forma darebbe un altro numero con lo stesso nome.';
