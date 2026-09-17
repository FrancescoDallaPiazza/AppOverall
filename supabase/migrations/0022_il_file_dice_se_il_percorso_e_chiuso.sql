-- AppOverall — 0022
-- Una sessione di un percorso frazionato dice anche IN QUALE FILE sta, e quel file
-- dice se il percorso e' chiuso.
--
-- ============================================================================
--  PERCHE ESISTE
-- ============================================================================
--
-- La `0021` ha deciso che «completato» e «in corso» **non sono un campo: sono quale
-- file stai leggendo** — `ExportExcelFormFrazCompletata` o `ExportExcelFormFrazInCorso`
-- — e ha affidato quella differenza a `estrazione`. Il 17 settembre 2026, scrivendo
-- il passo 05 che quei due file li porta, e' venuto fuori che `estrazione` da sola
-- non basta a leggerla:
--
--   * `estrazione` e' un **codice di file con una data** (`fraz_completata_20260806`).
--     Per sapere se una sessione appartiene a un percorso chiuso il motore dovrebbe
--     riconoscere il codice dal suo prefisso — cioe' leggere un significato dentro
--     un'etichetta, la forma di A15;
--   * e `v_percorso_formativo` contava come `sessioni_aperte` **ogni** riga che non
--     completa il percorso. Una sessione del file «Completata» non chiude niente da
--     sola — la chiusura e' l'attestato — ma non e' nemmeno aperta: appartiene a un
--     percorso che il gestionale dichiara finito. Con la `0021` com'era, le **350**
--     sessioni da scrivere sarebbero state contate come percorsi in sospeso.
--
-- Quindi la cosa che il nome del file dice si scrive **sulla riga**, con il nome
-- della cosa: `percorso_dichiarato`. `estrazione` resta, e dice da dove viene.
--
-- ============================================================================
--  COSA MISURA IL PASSO 05, PERCHE LA FORMA NE DIPENDE
-- ============================================================================
--
-- Sui due export del 6 agosto 2026 (513 e 403 sessioni con data e codice fiscale),
-- confrontati con i 13.350 `corsi_fatti` dello stesso istante:
--
--   * **tutti i 154 percorsi completati** (persona e corso) **hanno un attestato
--     dello stesso corso** fra i `corsi_fatti`, e **163 sessioni su 513** cadono
--     esattamente su un attestato della stessa persona, dello stesso corso e dello
--     stesso giorno. Il gestionale registra la chiusura come un attestato: il passo
--     04 l'ha gia' portata, con `completa_il_percorso = true`. **Nessuna chiusura va
--     calcolata**, e tanto meno dalle ore — la decisione 2 della `0021` regge senza
--     eccezioni;
--   * **nessuno dei 293 percorsi in corso** raggiunge le ore previste sommando le
--     sue sessioni: il file e le ore non si contraddicono mai in quel verso;
--   * i titoli sono **undici**, tutti nel dizionario dei 268 alias, tutti
--     aggiornamenti. Nessuno e' fra i sette alias `parziale`: le righe che il passo
--     04 lascia aperte (`AGGIORNAMENTO PARZIALE PER ...`) **non sono in questi due
--     file**, e il passo 05 non le chiude.
--
-- ============================================================================
--  LA COLONNA
-- ============================================================================

alter table evento_formativo
  -- Cosa dichiara la fonte del percorso a cui la riga appartiene. null = nessuna
  -- fonte lo dice, ed e' il caso di ogni attestato normale e dei sette spezzoni del
  -- passo 04: per loro decide `completa_il_percorso`, come prima.
  add column percorso_dichiarato text,
  add constraint percorso_dichiarato_valori
    check (percorso_dichiarato in ('completato', 'in_corso')),
  -- Un percorso dichiarato e' per forza frazionato: la riga documenta un pezzo.
  add constraint percorso_dichiarato_e_parziale
    check (percorso_dichiarato is null or parziale),
  -- Una riga di un percorso che la fonte dice ancora in corso non puo' chiuderlo.
  add constraint in_corso_non_completa
    check (percorso_dichiarato is distinct from 'in_corso' or not completa_il_percorso);

comment on column evento_formativo.percorso_dichiarato is
  'Se la fonte dichiara CHIUSO o ANCORA IN CORSO il percorso frazionato a cui la riga appartiene. Viene dal nome del file del gestionale (FormFrazCompletata / FormFrazInCorso), che e l''unico posto in cui la differenza esiste (0021, decisione 2). null = nessuna fonte lo dice. Non e un calcolo: nessuna ora viene sommata per ottenerlo (0022).';

-- ============================================================================
--  LE VISTE
-- ============================================================================
--
-- `v_evento_formativo` porta la colonna in coda. `v_percorso_formativo` cambia una
-- sola espressione: una sessione di un percorso dichiarato chiuso **non e' aperta**.
-- Tutto il resto e' identico alla `0021`, e `ore_origine` continua a non esserci.

create or replace view v_evento_formativo with (security_invoker = on) as
  select e.id,
         e.persona_id,
         e.corso_codice,
         c.nome as corso_nome,
         e.data,
         e.completa_il_percorso,
         e.is_aggiornamento,
         e.pregressa,
         e.parziale,
         e.evidenza_incompleta,
         e.ente_formatore,
         e.nota,
         e.titolo_origine,
         e.scadenza_dichiarata,
         e.scadenza_fonte,
         e.estrazione,
         e.creato_il,
         e.updated_at,
         e.percorso_dichiarato
    from evento_formativo e
    join corso c on c.codice = e.corso_codice;

create or replace view v_percorso_formativo with (security_invoker = on) as
  select e.persona_id,
         e.corso_codice,
         c.nome as corso_nome,
         max(e.data) filter (where e.completa_il_percorso) as completato_il,
         (max(e.data) filter (where e.completa_il_percorso)) is not null as completo,
         count(*) as righe,
         count(*) filter (where not e.completa_il_percorso
                            and e.percorso_dichiarato is distinct from 'completato') as sessioni_aperte,
         bool_or(e.evidenza_incompleta) as evidenza_incompleta,
         bool_or(e.pregressa) as pregressa,
         min(e.scadenza_dichiarata) as scadenza_dichiarata,
         case when c.aggiornamento_mesi is not null
              then ((max(e.data) filter (where e.completa_il_percorso))
                    + (c.aggiornamento_mesi || ' months')::interval)::date
         end as aggiornamento_dovuto_il,
         c.aggiornamento_mesi
    from evento_formativo e
    join corso c on c.codice = e.corso_codice
   group by e.persona_id, e.corso_codice, c.nome, c.aggiornamento_mesi;

comment on view v_percorso_formativo is
  'Il percorso di una persona su un corso: quando e stato completato, quante sessioni restano aperte, e quando scadrebbe col catalogo di OGGI. Non e lo scadenzario e non giudica: se il programma vigente alla data fosse sufficiente lo dice corso_regime_precedente (0014), e a metterli insieme e il motore della Fase 4. completato_il null = percorso aperto, che non e «scaduto» ma «non ancora assolto». sessioni_aperte non conta le sessioni di un percorso che la fonte dichiara completato (0022): quelle sono parti di un percorso chiuso, e la chiusura e il suo attestato.';

-- ============================================================================
--  COSA QUESTA MIGRAZIONE NON FA
-- ============================================================================
--
-- **Non dice a quale percorso appartiene una sessione.** Il gestionale non ha un
-- identificativo di percorso (AppFormazione, `docs/05`), e ricostruirlo vorrebbe
-- dire sommare le ore — che e' proprio cio' che la `0021` esclude. Quando una
-- persona ha un percorso chiuso e uno in corso sullo stesso corso, le sessioni si
-- distinguono per `percorso_dichiarato` e per data, non per un id.
--
-- **Non dice quante ore mancano a un percorso in corso.** Le ore stanno in
-- `ore_origine`, fuori dalla vista, per la decisione 3. Se il motore della Fase 4
-- vorra' la nota «fatte 2 ore su 6» che AppFormazione mette nel sollecito (loro
-- `0045`), la chiedera' con una sua superficie e una sua ragione.
