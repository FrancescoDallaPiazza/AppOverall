/**
 * Il testo di un attestato, letto nel browser: il file non esce dal PC. Un PDF con il
 * testo si legge com'e; una pagina senza testo (una scansione) e una foto passano
 * dall'OCR in italiano. Le librerie si caricano solo quando serve.
 *
 * ponytail: il modello italiano dell'OCR (~15 MB) Tesseract lo scarica da jsdelivr al
 * primo uso — scarica il modello, non manda il file. Da servire in locale se il PC non
 * esce su internet.
 */
export async function leggiAttestato(file: File, avanzamento: (t: string) => void): Promise<string> {
  const { createWorker } = await import('tesseract.js')
  let ocr: Awaited<ReturnType<typeof createWorker>> | null = null
  const riconosci = async (immagine: HTMLCanvasElement | File) => {
    if (!ocr) { avanzamento('preparo la lettura delle scansioni…'); ocr = await createWorker('ita') }
    return (await ocr.recognize(immagine)).data.text
  }

  try {
    if (!file.type.includes('pdf')) { avanzamento('leggo la foto…'); return await riconosci(file) }

    const pdfjs = await import('pdfjs-dist')
    pdfjs.GlobalWorkerOptions.workerSrc = (await import('pdfjs-dist/build/pdf.worker.min.mjs?url')).default
    const pdf = await pdfjs.getDocument({ data: await file.arrayBuffer() }).promise
    const pagine: string[] = []
    for (let n = 1; n <= pdf.numPages; n++) {
      avanzamento(`leggo la pagina ${n} di ${pdf.numPages}…`)
      const pagina = await pdf.getPage(n)
      const testo = (await pagina.getTextContent()).items.map((i) => ('str' in i ? i.str : '')).join(' ')
      // Meno di 30 lettere: e una scansione, o un PDF fatto di immagini.
      if (testo.replace(/\s/g, '').length >= 30) { pagine.push(testo); continue }
      avanzamento(`pagina ${n} di ${pdf.numPages} e una scansione: la leggo con l'OCR…`)
      const vista = pagina.getViewport({ scale: 2.5 })
      const tela = document.createElement('canvas')
      tela.width = vista.width; tela.height = vista.height
      await pagina.render({ canvas: tela, canvasContext: tela.getContext('2d')!, viewport: vista }).promise
      pagine.push(await riconosci(tela))
    }
    return pagine.join('\n')
  } finally {
    await (ocr as { terminate: () => Promise<unknown> } | null)?.terminate()
  }
}
