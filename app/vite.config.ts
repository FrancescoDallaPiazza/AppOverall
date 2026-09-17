import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  return {
    plugins: [react()],
    // Esplicito su IPv4: il default si lega a ::1 e il browser risolve localhost su
    // 127.0.0.1, che trova la porta chiusa (lezione di AppFormazione).
    server: {
      host: '127.0.0.1',
      port: 5173,
      // Solo nel banco di prova (app/prova/avvia.sh): PostgREST risponde alla radice,
      // Supabase sotto /rest/v1. Il proxy fa da Supabase per le chiamate dell'app.
      proxy: env.VITE_PROVA_REST
        ? { '/rest/v1': { target: env.VITE_PROVA_REST, rewrite: (p) => p.replace(/^\/rest\/v1/, '') } }
        : undefined,
    },
  }
})
