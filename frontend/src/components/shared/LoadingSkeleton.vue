<script setup lang="ts">
import { cn } from '@/lib/utils'

interface Props {
  class?: string
  variant?: 'text' | 'circle' | 'card' | 'rect'
  width?: string
  height?: string
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'rect',
})
</script>

<template>
  <div
    :class="cn(
      'animate-pulse bg-muted rounded',
      variant === 'text' && 'h-4 rounded',
      variant === 'circle' && 'rounded-full aspect-square',
      variant === 'card' && 'rounded-xl h-32',
      variant === 'rect' && 'rounded-lg',
      props.class
    )"
    :style="{
      width: width || undefined,
      height: height || undefined,
    }"
    role="status"
    aria-label="Loading..."
  >
    <span class="sr-only">Loading...</span>
  </div>
</template>
