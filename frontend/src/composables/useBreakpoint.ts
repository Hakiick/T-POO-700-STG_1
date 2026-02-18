import { computed } from 'vue'
import { useMediaQuery } from './useMediaQuery'

const BREAKPOINTS = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  '2xl': 1536,
} as const

export type BreakpointKey = keyof typeof BREAKPOINTS

export function useBreakpoint() {
  const sm = useMediaQuery(`(min-width: ${BREAKPOINTS.sm}px)`)
  const md = useMediaQuery(`(min-width: ${BREAKPOINTS.md}px)`)
  const lg = useMediaQuery(`(min-width: ${BREAKPOINTS.lg}px)`)
  const xl = useMediaQuery(`(min-width: ${BREAKPOINTS.xl}px)`)
  const xxl = useMediaQuery(`(min-width: ${BREAKPOINTS['2xl']}px)`)

  const isMobile = computed(() => !md.value)
  const isTablet = computed(() => md.value && !lg.value)
  const isDesktop = computed(() => lg.value)

  const current = computed<BreakpointKey>(() => {
    if (xxl.value) return '2xl'
    if (xl.value) return 'xl'
    if (lg.value) return 'lg'
    if (md.value) return 'md'
    if (sm.value) return 'sm'
    return 'sm'
  })

  return {
    sm,
    md,
    lg,
    xl,
    xxl,
    isMobile,
    isTablet,
    isDesktop,
    current,
    breakpoints: BREAKPOINTS,
  }
}
