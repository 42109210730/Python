import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import path from "path";
import ElementPlus from 'unplugin-element-plus/vite'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue(),
  ElementPlus({
    useSource: true,
  }),],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "src"),
    },
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        // rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  },
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: `@use"@/styles/element/index.scss" as *;`,
      },
    },
  },
});
