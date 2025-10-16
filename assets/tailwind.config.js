// Tailwind CSS v4 Configuration
// For advanced usage see: https://tailwindcss.com/docs/configuration

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/rumbl_web.ex",
    "../lib/rumbl_web/**/*.ex",
    "../lib/rumbl_web/**/*.heex",
  ],
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00",
        primary: {
          50: "#fef2f2",
          100: "#fee2e2",
          500: "#ef4444",
          600: "#dc2626",
          700: "#b91c1c",
          900: "#7f1d1d",
        },
        wood: {
          50: "#fdf8f6",
          100: "#f2e8e5",
          200: "#eaddd7",
          300: "#e0cfc7",
          400: "#d2bab0",
          500: "#bfa094",
          600: "#a18072",
          700: "#977669",
          800: "#846358",
          900: "#43302b",
        },
      },
      fontFamily: {
        sans: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "ui-monospace", "monospace"],
      },
    },
  },
  plugins: [],
};
