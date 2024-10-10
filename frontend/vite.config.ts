import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import Icons from "unplugin-icons/vite";
import { fileURLToPath, URL } from "url";

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    proxy: {
      // Proxy API requests to the backend container
      "/api": {
        target: "http://backend:4000", // The backend service in Docker
        changeOrigin: true, // Needed for virtual hosted sites
        // rewrite: (path) => path.replace(/^\/api/, ""), // Remove `/api` prefix from the request path
      },
    },
  },

  plugins: [
    vue(),
    Icons({
      autoInstall: true, // Automatically installs icon packages when needed
    }),
  ],
  resolve: {
    alias: [
      {
        find: "@",
        replacement: fileURLToPath(new URL("src", import.meta.url)),
      },
    ],
  },
});
