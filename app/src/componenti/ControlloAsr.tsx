import type { EsitoControllo, RigaControllo } from '../tipi'

const SEGNO: Record<EsitoControllo, string> = {
  conforme: '✓',
  da_verificare: '?',
  non_conforme: '✕',
  non_applicabile: '–',
}

const PAROLA: Record<EsitoControllo, string> = {
  conforme: 'conforme',
  da_verificare: 'da guardare',
  non_conforme: 'non conforme',
  non_applicabile: 'non si applica',
}

/**
 * Il controllo di congruenza con l'ASR 2025 (0030). Le regole le applica il database:
 * qui si leggono, con la fonte accanto, perche chi registra possa decidere.
 */
export default function ControlloAsr({ righe, caricando }: { righe: RigaControllo[]; caricando: boolean }) {
  if (caricando && righe.length === 0) return <p className="nota">Controllo in corso…</p>
  if (righe.length === 0) return null

  const quante = (e: EsitoControllo) => righe.filter((r) => r.esito === e).length
  const nonConformi = quante('non_conforme')
  const daGuardare = quante('da_verificare')

  return (
    <div className={`controllo ${nonConformi ? 'non_conforme' : daGuardare ? 'da_verificare' : 'conforme'}`}>
      <p className="riassunto">
        <strong>Controllo ASR 2025:</strong>{' '}
        {nonConformi > 0
          ? `${nonConformi} ${nonConformi === 1 ? 'regola non rispettata' : 'regole non rispettate'}`
          : daGuardare > 0
            ? `nessuna regola violata, ${daGuardare} da guardare`
            : 'tutte le regole rispettate'}
        {daGuardare > 0 && nonConformi > 0 && `, ${daGuardare} da guardare`}.
      </p>
      <ul className="regole">
        {righe.map((r) => (
          <li key={r.regola} className={r.esito}>
            <span className="segno" aria-hidden>{SEGNO[r.esito]}</span>
            <span className="corpo">
              <strong>{r.titolo}</strong>
              <span className="valore"> · {PAROLA[r.esito]}</span>
              <span className="messaggio">{r.messaggio}</span>
              <span className="fonte">{r.riferimento}</span>
            </span>
          </li>
        ))}
      </ul>
    </div>
  )
}
