/** I tipi delle viste che l'app legge (migrazioni 0026-0030). */

export type Operatore = {
  id: string
  cognome: string
  nome: string
  email: string | null
  ruolo: 'lettore' | 'tecnico' | 'formazione' | 'amministrazione'
  attivo: boolean
  livello: number
}

export type Stato =
  | 'valido'
  | 'in_scadenza'
  | 'scaduto'
  | 'mancante'
  | 'incompleto'
  | 'in_corso'
  | 'non_scade'
  | 'senza_regola'

export type EsitoLivello = 'livello_non_definito' | 'conforme' | 'non_conforme'

/** v_scadenzario */
export type Scadenza = {
  tipo: 'formazione' | 'sorveglianza'
  persona_id: string
  cognome: string
  nome: string
  codice_fiscale: string | null
  cliente_id: string
  ragione_sociale: string
  sede_id: string | null
  sede: string | null
  obbligo: string | null
  obbligo_nome: string | null
  obbligo_da: string
  corso: string | null
  corso_nome: string | null
  completato_il: string | null
  scadenza: string | null
  scadenza_dichiarata: string | null
  anticipata: boolean | null
  giorni_residui: number | null
  stato: Stato
  ruolo_da_confermare: boolean
  esito_livello: EsitoLivello | null
  livello_richiesto: string | null
  priorita: number
}

/** v_scadenzario_cliente */
export type SintesiCliente = {
  cliente_id: string
  ragione_sociale: string
  partita_iva: string | null
  attivo: boolean
  persone: number
  formazione_mancanti: number
  formazione_scadute: number
  formazione_in_scadenza: number
  formazione_da_completare: number
  visite_scadute: number
  visite_in_scadenza: number
  promemoria: number
  prima_scadenza: string | null
}

export type GenerePromemoria = 'ruolo_da_confermare' | 'livello_emergenza' | 'corso_non_definito' | 'da_riportare'

/** v_promemoria */
export type Promemoria = {
  cliente_id: string
  ragione_sociale: string
  persona_id: string
  cognome: string
  nome: string
  genere: GenerePromemoria
  esito: EsitoLivello | null
  ruolo: string | null
  ruolo_nome: string | null
  corso: string | null
  corso_nome: string | null
  completato_il: string | null
  scadenza: string | null
  livello_richiesto: string | null
  codice_fiscale: string | null
}

/** v_persona_in_forza */
export type PersonaInForza = {
  persona_id: string
  cognome: string
  nome: string
  codice_fiscale: string | null
  data_nascita: string | null
  cliente_id: string
  ragione_sociale: string
  rapporti: number
  mansione: string | null
}

/** v_evento_registrato */
export type EventoRegistrato = {
  id: string
  tipo: 'formazione' | 'sorveglianza'
  persona_id: string
  cognome: string
  nome: string
  codice: string
  descrizione: string
  data: string
  ente_formatore: string | null
  nota: string | null
  inserito_da: string
  inserito_il: string
  controllo_esito: EsitoControllo | null
}

export type EsitoControllo = 'conforme' | 'da_verificare' | 'non_conforme' | 'non_applicabile'

/** Una riga di controlla_attestato(): una regola dell'ASR 2025, con esito e fonte (0030). */
export type RigaControllo = {
  regola: string
  titolo: string
  esito: EsitoControllo
  messaggio: string
  riferimento: string
}

/** soggetto_formatore_tipo */
export type TipoFormatore = {
  codice: string
  nome: string
  da_guardare: string | null
  fonte: string
}
