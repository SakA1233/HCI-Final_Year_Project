import type { Config } from "tailwindcss";

export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        lightBg: "#ffffff", // Default background
        darkBg: "#0a0a36", // Dark mode background (deep blue)
        lightText: "#171717", // Default text
        darkText: "#ffffff", // Text in dark mode
        darkNav: "#082567", // Deep navy for navbar and footer
      },
    },
  },
  plugins: [],
} satisfies Config;
