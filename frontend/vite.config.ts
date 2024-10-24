import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import Icons from "unplugin-icons/vite";
// import { fileURLToPath, URL } from "url";
import { resolve } from "path";
import { VitePWA } from "vite-plugin-pwa";

// https://vitejs.dev/config/
export default defineConfig({
  define: {
    "process.env.NODE_ENV": JSON.stringify("production"),
  },
  build: {
    outDir: "dist",
    sourcemap: false,
    minify: "esbuild",
  },
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
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: ["favicon.ico", "robots.txt", "apple-touch-icon.png"],
      filename: "sw.js",
      manifest: {
        name: "Time manager",
        short_name: "TM",
        start_url: "/",
        display: "standalone",
        background_color: "#ffffff",
        theme_color: "#3f51b5",
        icons: [
          {
            src: "icons/icon-192x192.png",
            sizes: "192x192",
            type: "image/png",
          },
          {
            src: "icons/icon-512x512.png",
            sizes: "512x512",
            type: "image/png",
          },
        ],
      },
    }),
  ],
  resolve: {
    alias: {
      "@": resolve(__dirname, "./src"),
    },
  },
});
