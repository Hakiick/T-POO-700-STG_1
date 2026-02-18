<script setup lang="ts">
import StickyHeader from '@/components/layout/StickyHeader.vue'
import BottomTabBar from '@/components/layout/BottomTabBar.vue'
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '@/components/store/userStore'

const route = useRoute()
const userStore = useUserStore()

const pageTitle = computed(() => {
  const name = route.name as string | undefined
  const titleMap: Record<string, string> = {
    clock: 'Clock',
    dashboard: 'Dashboard',
    team: 'Team',
    admin: 'Admin',
    settings: 'Settings',
  }
  return name ? (titleMap[name] || '') : ''
})

const userRole = computed(() => userStore.user?.role || 'employee')
</script>

<template>
  <div class="mobile-layout">
    <StickyHeader :title="pageTitle" />
    <main class="mobile-layout__content">
      <slot />
    </main>
    <BottomTabBar :user-role="userRole" />
  </div>
</template>

<style scoped>
.mobile-layout {
  display: flex;
  flex-direction: column;
  min-height: 100dvh;
}

.mobile-layout__content {
  flex: 1;
  overflow-y: auto;
  padding-bottom: calc(var(--bottom-bar-height) + var(--safe-area-bottom));
  -webkit-overflow-scrolling: touch;
}
</style>
