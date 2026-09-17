/** I tipi delle viste che l'app legge (migrazioni 0026-0028). */

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
}

/** v_scadenzario_cliente */
export type SintesiCliente = {
  cliente_id: string
  ragione_sociale: string
  partita_iva: string | null
  attivo: boolean
  persone: number
  scadute: number
  in_scadenza: number
  mancanti: number
  incomplete: number
  ruoli_da_confermare: number
  livello_non_definito: number
  livello_non_conforme: number
  prima_scadenza: string | null
}

/** v_ruolo_da_confermare */
export type RuoloDaConfermare = {
  cliente_id: string
  sede_id: string | null
  persona_id: string
  cognome: string
  nome: string
  corso: string
  corso_nome: string
  ruolo_proposto: string | null
  ruolo_proposto_nome: string | null
  completato_il: string
  scadenza: string | null
  stato: Stato
  ragione_sociale: string
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
}
