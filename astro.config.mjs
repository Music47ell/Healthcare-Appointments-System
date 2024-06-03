import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";

// https://astro.build/config
export default defineConfig({
  site: "https://ksu-gp-has.news47ell.com",
  base: "/",
  trailingSlash: "never",
  output: "static",
  integrations: [tailwind()],
});
