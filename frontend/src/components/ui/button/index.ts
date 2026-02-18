import { type VariantProps, cva } from 'class-variance-authority'

export { default as Button } from './Button.vue'

export const buttonVariants = cva(
  'inline-flex items-center justify-center whitespace-nowrap rounded-lg font-medium transition-all duration-base focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 active:scale-[0.97] select-none',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground shadow-soft-sm hover:bg-primary/90 active:bg-primary/80',
        destructive:
          'bg-destructive text-destructive-foreground shadow-soft-sm hover:bg-destructive/90 active:bg-destructive/80',
        outline:
          'border border-input bg-background shadow-soft-sm hover:bg-accent hover:text-accent-foreground active:bg-accent/80',
        secondary:
          'bg-secondary text-secondary-foreground shadow-soft-sm hover:bg-secondary/80 active:bg-secondary/70',
        ghost: 'hover:bg-accent hover:text-accent-foreground active:bg-accent/80',
        link: 'text-primary underline-offset-4 hover:underline',
        success: 'bg-success text-success-foreground shadow-soft-sm hover:bg-success/90 active:bg-success/80',
        warning: 'bg-warning text-warning-foreground shadow-soft-sm hover:bg-warning/90 active:bg-warning/80',
      },
      size: {
        default: 'h-11 px-5 py-2.5 text-sm min-w-touch',
        xs: 'h-8 rounded-md px-2.5 text-xs',
        sm: 'h-9 rounded-md px-3.5 text-sm',
        lg: 'h-12 rounded-lg px-8 text-base min-w-touch',
        xl: 'h-14 rounded-xl px-10 text-lg min-w-touch-comfortable',
        icon: 'h-11 w-11 min-w-touch min-h-touch',
        'icon-sm': 'h-9 w-9',
        'icon-lg': 'h-14 w-14 min-w-touch-comfortable min-h-touch-comfortable',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  },
)

export type ButtonVariants = VariantProps<typeof buttonVariants>
