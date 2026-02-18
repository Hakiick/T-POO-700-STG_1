<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import StickyHeader from '@/components/layout/StickyHeader.vue'
import DesktopSidebar from '@/components/layout/DesktopSidebar.vue'
import { useUserStore } from '@/components/store/userStore'

const route = useRoute()
const userStore = useUserStore()
const isSidebarCollapsed = ref(false)

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

function handleCollapseChange(collapsed: boolean): void {
  isSidebarCollapsed.value = collapsed
}
</script>

<template>
  <div class="desktop-layout">
    <DesktopSidebar
      :user-role="userRole"
      @collapse-change="handleCollapseChange"
    />
    <div
      class="desktop-layout__main"
      :class="{ 'desktop-layout__main--collapsed': isSidebarCollapsed }"
    >
      <StickyHeader :title="pageTitle" />
      <main class="desktop-layout__content">
        <slot />
      </main>
    </div>
  </div>
</template>

<style scoped>
.desktop-layout {
  min-height: 100dvh;
}

.desktop-layout__main {
  margin-left: var(--sidebar-width);
  min-height: 100dvh;
  display: flex;
  flex-direction: column;
  transition: margin-left var(--transition-slow);
}

.desktop-layout__main--collapsed {
  margin-left: var(--sidebar-collapsed);
}

.desktop-layout__content {
  flex: 1;
  padding: var(--space-6);
  max-width: var(--content-max-width);
  margin: 0 auto;
  width: 100%;
}
</style>
