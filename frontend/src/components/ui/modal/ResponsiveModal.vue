<script setup lang="ts">
import { computed, watch } from 'vue'
import { useBreakpoint } from '@/composables/useBreakpoint'
import { cn } from '@/lib/utils'

interface Props {
  open: boolean
  title?: string
  class?: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:open': [value: boolean]
}>()

const { isMobile } = useBreakpoint()

const close = () => emit('update:open', false)

watch(() => props.open, (isOpen) => {
  if (isOpen) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
  }
})
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-backdrop">
      <div
        v-if="open"
        class="fixed inset-0 bg-black/50 backdrop-blur-sm"
        :style="{ zIndex: 'var(--z-modal-backdrop)' }"
        @click="close"
        aria-hidden="true"
      />
    </Transition>

    <Transition :name="isMobile ? 'modal-slide' : 'modal-scale'">
      <div
        v-if="open"
        :class="cn(
          'fixed overflow-y-auto bg-background',
          isMobile
            ? 'inset-x-0 bottom-0 max-h-[90dvh] rounded-t-2xl pb-safe-bottom'
            : 'left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-lg max-h-[85dvh] rounded-2xl shadow-soft-xl',
          props.class
        )"
        :style="{ zIndex: 'var(--z-modal)' }"
        role="dialog"
        aria-modal="true"
        :aria-label="title"
      >
        <!-- Mobile drag handle -->
        <div v-if="isMobile" class="flex justify-center pt-3 pb-1">
          <div class="h-1 w-10 rounded-full bg-muted-foreground/30" />
        </div>

        <!-- Header -->
        <div v-if="title" class="flex items-center justify-between px-5 py-3 border-b">
          <h2 class="text-fluid-lg font-semibold">{{ title }}</h2>
          <button
            @click="close"
            class="flex items-center justify-center w-9 h-9 rounded-full hover:bg-muted transition-colors touch-target"
            aria-label="Close modal"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
          </button>
        </div>

        <!-- Content -->
        <div class="p-5">
          <slot />
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
/* Backdrop transitions */
.modal-backdrop-enter-active { transition: opacity 200ms ease-out; }
.modal-backdrop-leave-active { transition: opacity 150ms ease-in; }
.modal-backdrop-enter-from,
.modal-backdrop-leave-to { opacity: 0; }

/* Mobile: slide up from bottom */
.modal-slide-enter-active { transition: transform 300ms cubic-bezier(0.32, 0.72, 0, 1); }
.modal-slide-leave-active { transition: transform 200ms ease-in; }
.modal-slide-enter-from { transform: translateY(100%); }
.modal-slide-leave-to { transform: translateY(100%); }

/* Desktop: scale and fade */
.modal-scale-enter-active { transition: all 200ms ease-out; }
.modal-scale-leave-active { transition: all 150ms ease-in; }
.modal-scale-enter-from { opacity: 0; transform: translate(-50%, -50%) scale(0.95); }
.modal-scale-leave-to { opacity: 0; transform: translate(-50%, -50%) scale(0.95); }
</style>
