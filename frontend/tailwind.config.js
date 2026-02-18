const animate = require("tailwindcss-animate")

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  safelist: ["dark"],
  prefix: "",

  content: [
    './pages/**/*.{ts,tsx,vue}',
    './components/**/*.{ts,tsx,vue}',
    './app/**/*.{ts,tsx,vue}',
    './src/**/*.{ts,tsx,vue}',
  ],

  theme: {
    container: {
      center: true,
      padding: {
        DEFAULT: "1rem",
        sm: "1.5rem",
        lg: "2rem",
      },
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
        success: {
          DEFAULT: "hsl(var(--color-success))",
          foreground: "hsl(var(--color-success-foreground))",
          light: "hsl(var(--color-success-light))",
        },
        warning: {
          DEFAULT: "hsl(var(--color-warning))",
          foreground: "hsl(var(--color-warning-foreground))",
          light: "hsl(var(--color-warning-light))",
        },
        danger: {
          DEFAULT: "hsl(var(--color-danger))",
          foreground: "hsl(var(--color-danger-foreground))",
          light: "hsl(var(--color-danger-light))",
        },
        info: {
          DEFAULT: "hsl(var(--color-info))",
          foreground: "hsl(var(--color-info-foreground))",
        },
      },
      borderRadius: {
        "2xl": "calc(var(--radius) + 8px)",
        xl: "calc(var(--radius) + 4px)",
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      fontSize: {
        "fluid-xs": "var(--text-xs)",
        "fluid-sm": "var(--text-sm)",
        "fluid-base": "var(--text-base)",
        "fluid-lg": "var(--text-lg)",
        "fluid-xl": "var(--text-xl)",
        "fluid-2xl": "var(--text-2xl)",
        "fluid-3xl": "var(--text-3xl)",
        "fluid-4xl": "var(--text-4xl)",
        "fluid-5xl": "var(--text-5xl)",
      },
      spacing: {
        "safe-top": "var(--safe-area-top)",
        "safe-bottom": "var(--safe-area-bottom)",
        "safe-left": "var(--safe-area-left)",
        "safe-right": "var(--safe-area-right)",
        "header": "var(--header-height)",
        "bottom-bar": "var(--bottom-bar-height)",
        "touch": "var(--touch-target-min)",
        "touch-comfortable": "var(--touch-target-comfortable)",
      },
      minHeight: {
        "touch": "var(--touch-target-min)",
        "touch-comfortable": "var(--touch-target-comfortable)",
        "screen-dvh": "100dvh",
      },
      minWidth: {
        "touch": "var(--touch-target-min)",
        "touch-comfortable": "var(--touch-target-comfortable)",
      },
      height: {
        "screen-dvh": "100dvh",
        "header": "var(--header-height)",
        "bottom-bar": "var(--bottom-bar-height)",
      },
      boxShadow: {
        "card": "var(--shadow-card)",
        "card-hover": "var(--shadow-card-hover)",
        "soft-sm": "var(--shadow-sm)",
        "soft-md": "var(--shadow-md)",
        "soft-lg": "var(--shadow-lg)",
        "soft-xl": "var(--shadow-xl)",
      },
      transitionDuration: {
        "fast": "150ms",
        "base": "200ms",
        "slow": "300ms",
      },
      transitionTimingFunction: {
        "spring": "cubic-bezier(0.34, 1.56, 0.64, 1)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: 0 },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: 0 },
        },
        "collapsible-down": {
          from: { height: 0 },
          to: { height: 'var(--radix-collapsible-content-height)' },
        },
        "collapsible-up": {
          from: { height: 'var(--radix-collapsible-content-height)' },
          to: { height: 0 },
        },
        "fade-in": {
          from: { opacity: 0 },
          to: { opacity: 1 },
        },
        "fade-in-up": {
          from: { opacity: 0, transform: "translateY(0.5rem)" },
          to: { opacity: 1, transform: "translateY(0)" },
        },
        "slide-up": {
          from: { transform: "translateY(100%)" },
          to: { transform: "translateY(0)" },
        },
        "slide-down": {
          from: { transform: "translateY(0)" },
          to: { transform: "translateY(100%)" },
        },
        "scale-in": {
          from: { transform: "scale(0.95)", opacity: 0 },
          to: { transform: "scale(1)", opacity: 1 },
        },
        "ripple": {
          from: { transform: "scale(0)", opacity: 0.4 },
          to: { transform: "scale(4)", opacity: 0 },
        },
        "pulse-soft": {
          "0%, 100%": { opacity: 1 },
          "50%": { opacity: 0.5 },
        },
        "count-up": {
          from: { opacity: 0, transform: "translateY(0.25rem)" },
          to: { opacity: 1, transform: "translateY(0)" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
        "collapsible-down": "collapsible-down 0.2s ease-in-out",
        "collapsible-up": "collapsible-up 0.2s ease-in-out",
        "fade-in": "fade-in 200ms ease-out",
        "fade-in-up": "fade-in-up 300ms ease-out",
        "slide-up": "slide-up 300ms cubic-bezier(0.32, 0.72, 0, 1)",
        "slide-down": "slide-down 300ms cubic-bezier(0.32, 0.72, 0, 1)",
        "scale-in": "scale-in 200ms ease-out",
        "ripple": "ripple 600ms linear forwards",
        "pulse-soft": "pulse-soft 2s ease-in-out infinite",
        "count-up": "count-up 300ms ease-out",
      },
    },
  },
  plugins: [animate],
}
