<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import {
  Timer,
  LayoutDashboard,
  Users,
  Shield,
  Settings,
} from 'lucide-vue-next'
import type { Component } from 'vue'

interface TabItem {
  name: string
  path: string
  icon: Component
  label: string
  requiresRole?: string[]
}

const props = defineProps<{
  userRole: string
}>()

const route = useRoute()

const allTabs: TabItem[] = [
  { name: 'clock', path: '/', icon: Timer, label: 'Clock' },
  { name: 'dashboard', path: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { name: 'team', path: '/team', icon: Users, label: 'Team' },
  { name: 'admin', path: '/admin', icon: Shield, label: 'Admin', requiresRole: ['manager', 'general_manager'] },
  { name: 'settings', path: '/settings', icon: Settings, label: 'Settings' },
]

const visibleTabs = computed(() =>
  allTabs.filter((tab) => {
    if (!tab.requiresRole) return true
    return tab.requiresRole.includes(props.userRole)
  })
)

function isActive(tabPath: string): boolean {
  return route.path === tabPath
}
</script>

<template>
  <nav
    class="bottom-tab-bar"
    role="navigation"
    aria-label="Main navigation"
  >
    <div class="bottom-tab-bar__inner">
      <router-link
        v-for="tab in visibleTabs"
        :key="tab.name"
        :to="tab.path"
        class="bottom-tab-bar__item"
        :class="{ 'bottom-tab-bar__item--active': isActive(tab.path) }"
        :aria-label="tab.label"
        :aria-current="isActive(tab.path) ? 'page' : undefined"
      >
        <span class="bottom-tab-bar__icon">
          <component :is="tab.icon" :size="24" :stroke-width="isActive(tab.path) ? 2.5 : 2" />
        </span>
        <span class="bottom-tab-bar__label">{{ tab.label }}</span>
      </router-link>
    </div>
  </nav>
</template>

<style scoped>
.bottom-tab-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: var(--z-sticky);
  background: hsl(var(--background) / 0.8);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-top: 1px solid hsl(var(--border));
  padding-bottom: var(--safe-area-bottom);
}

.bottom-tab-bar__inner {
  display: flex;
  align-items: center;
  justify-content: space-around;
  height: var(--bottom-bar-height);
  max-width: var(--content-max-width);
  margin: 0 auto;
  padding: 0 var(--space-2);
}

.bottom-tab-bar__item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-1);
  min-width: var(--touch-target-min);
  min-height: var(--touch-target-min);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-lg);
  color: hsl(var(--muted-foreground));
  text-decoration: none;
  transition: color var(--transition-fast), transform var(--transition-fast);
  -webkit-tap-highlight-color: transparent;
  user-select: none;
}

.bottom-tab-bar__item--active {
  color: hsl(var(--primary));
}

.bottom-tab-bar__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--transition-fast);
}

.bottom-tab-bar__item--active .bottom-tab-bar__icon {
  transform: scale(1.1);
}

.bottom-tab-bar__label {
  font-size: var(--text-xs);
  font-weight: var(--font-weight-medium);
  line-height: 1;
  transition: opacity var(--transition-fast);
}

.bottom-tab-bar__item--active .bottom-tab-bar__label {
  font-weight: var(--font-weight-semibold);
}
</style>
