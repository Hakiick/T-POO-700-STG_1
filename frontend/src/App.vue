<script setup lang="ts">
import { computed, type Component } from 'vue'
import { useRoute } from 'vue-router'
import { useBreakpoint } from '@/composables/useBreakpoint'
import MobileLayout from '@/layouts/MobileLayout.vue'
import DesktopLayout from '@/layouts/DesktopLayout.vue'
import AuthLayout from '@/layouts/AuthLayout.vue'

const route = useRoute()
const { isMobile } = useBreakpoint()

const currentLayout = computed<Component>(() => {
  const layout = route.meta.layout

  if (layout === 'auth') {
    return AuthLayout
  }

  if (isMobile.value) {
    return MobileLayout
  }

  return DesktopLayout
})

const transitionName = computed(() => {
  if (route.meta.layout === 'auth') {
    return 'fade'
  }
  return isMobile.value ? 'slide' : 'fade'
})
</script>

<template>
  <component :is="currentLayout">
    <RouterView v-slot="{ Component: PageComponent }">
      <Transition :name="transitionName" mode="out-in">
        <component :is="PageComponent" :key="route.path" />
      </Transition>
    </RouterView>
  </component>
</template>

<style>
/* Page transition: fade (desktop + auth) */
.fade-enter-active,
.fade-leave-active {
  transition: opacity var(--transition-base);
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Page transition: slide (mobile) */
.slide-enter-active {
  animation: slide-in-right var(--transition-slow) ease-out;
}

.slide-leave-active {
  animation: slide-out-left var(--transition-slow) ease-out;
}
</style>
