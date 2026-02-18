<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import {
  Timer,
  LayoutDashboard,
  Users,
  Shield,
  Settings,
  ChevronLeft,
  ChevronRight,
} from 'lucide-vue-next'
import { useUserStore } from '@/components/store/userStore'
import type { Component } from 'vue'

interface NavItem {
  name: string
  path: string
  icon: Component
  label: string
  requiresRole?: string[]
}

const props = defineProps<{
  userRole: string
}>()

const emit = defineEmits<{
  'collapse-change': [collapsed: boolean]
}>()

const route = useRoute()
const userStore = useUserStore()

const isCollapsed = ref(false)

const allNavItems: NavItem[] = [
  { name: 'clock', path: '/', icon: Timer, label: 'Clock' },
  { name: 'dashboard', path: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { name: 'team', path: '/team', icon: Users, label: 'Team' },
  { name: 'admin', path: '/admin', icon: Shield, label: 'Admin', requiresRole: ['manager', 'general_manager'] },
  { name: 'settings', path: '/settings', icon: Settings, label: 'Settings' },
]

const visibleNavItems = computed(() =>
  allNavItems.filter((item) => {
    if (!item.requiresRole) return true
    return item.requiresRole.includes(props.userRole)
  })
)

const userInitial = computed(() => {
  const name = userStore.user?.username || userStore.user?.email || '?'
  return name.charAt(0).toUpperCase()
})

const userName = computed(() => {
  return userStore.user?.username || userStore.user?.email || 'User'
})

function isActive(itemPath: string): boolean {
  return route.path === itemPath
}

function toggleCollapse(): void {
  isCollapsed.value = !isCollapsed.value
  emit('collapse-change', isCollapsed.value)
}
</script>

<template>
  <aside
    class="desktop-sidebar"
    :class="{ 'desktop-sidebar--collapsed': isCollapsed }"
    role="navigation"
    aria-label="Main navigation"
  >
    <div class="desktop-sidebar__header">
      <div class="desktop-sidebar__logo">
        <div class="desktop-sidebar__logo-icon">
          <Timer :size="24" />
        </div>
        <Transition name="sidebar-fade">
          <span v-if="!isCollapsed" class="desktop-sidebar__logo-text">
            TimeManager
          </span>
        </Transition>
      </div>
    </div>

    <nav class="desktop-sidebar__nav">
      <router-link
        v-for="item in visibleNavItems"
        :key="item.name"
        :to="item.path"
        class="desktop-sidebar__item"
        :class="{ 'desktop-sidebar__item--active': isActive(item.path) }"
        :aria-label="isCollapsed ? item.label : undefined"
        :aria-current="isActive(item.path) ? 'page' : undefined"
        :title="isCollapsed ? item.label : undefined"
      >
        <span class="desktop-sidebar__item-icon">
          <component :is="item.icon" :size="20" />
        </span>
        <Transition name="sidebar-fade">
          <span v-if="!isCollapsed" class="desktop-sidebar__item-label">
            {{ item.label }}
          </span>
        </Transition>
      </router-link>
    </nav>

    <div class="desktop-sidebar__footer">
      <div class="desktop-sidebar__user">
        <div class="desktop-sidebar__user-avatar">
          <span class="desktop-sidebar__user-initial">{{ userInitial }}</span>
        </div>
        <Transition name="sidebar-fade">
          <span v-if="!isCollapsed" class="desktop-sidebar__user-name">
            {{ userName }}
          </span>
        </Transition>
      </div>

      <button
        class="desktop-sidebar__toggle touch-target"
        :aria-label="isCollapsed ? 'Expand sidebar' : 'Collapse sidebar'"
        @click="toggleCollapse"
      >
        <component :is="isCollapsed ? ChevronRight : ChevronLeft" :size="20" />
      </button>
    </div>
  </aside>
</template>

<style scoped>
.desktop-sidebar {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: var(--sidebar-width);
  background: hsl(var(--card));
  border-right: 1px solid hsl(var(--border));
  display: flex;
  flex-direction: column;
  z-index: var(--z-sticky);
  transition: width var(--transition-slow);
  overflow: hidden;
}

.desktop-sidebar--collapsed {
  width: var(--sidebar-collapsed);
}

.desktop-sidebar__header {
  padding: var(--space-4);
  border-bottom: 1px solid hsl(var(--border));
  flex-shrink: 0;
}

.desktop-sidebar__logo {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  overflow: hidden;
}

.desktop-sidebar__logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: 2rem;
  height: 2rem;
  color: hsl(var(--primary));
}

.desktop-sidebar__logo-text {
  font-size: var(--text-lg);
  font-weight: var(--font-weight-bold);
  color: hsl(var(--foreground));
  white-space: nowrap;
}

.desktop-sidebar__nav {
  flex: 1;
  padding: var(--space-2);
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
  overflow-y: auto;
}

.desktop-sidebar__item {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-md);
  color: hsl(var(--muted-foreground));
  text-decoration: none;
  transition: color var(--transition-fast), background-color var(--transition-fast);
  min-height: var(--touch-target-min);
  overflow: hidden;
  border-left: 3px solid transparent;
}

.desktop-sidebar__item:hover {
  color: hsl(var(--foreground));
  background: hsl(var(--accent));
}

.desktop-sidebar__item:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: -2px;
}

.desktop-sidebar__item--active {
  color: hsl(var(--primary));
  background: hsl(var(--primary) / 0.1);
  border-left-color: hsl(var(--primary));
}

.desktop-sidebar__item-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: 1.25rem;
  height: 1.25rem;
}

.desktop-sidebar__item-label {
  font-size: var(--text-sm);
  font-weight: var(--font-weight-medium);
  white-space: nowrap;
}

.desktop-sidebar__item--active .desktop-sidebar__item-label {
  font-weight: var(--font-weight-semibold);
}

.desktop-sidebar__footer {
  padding: var(--space-3);
  border-top: 1px solid hsl(var(--border));
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  flex-shrink: 0;
}

.desktop-sidebar__user {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  overflow: hidden;
}

.desktop-sidebar__user-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: 2rem;
  height: 2rem;
  border-radius: var(--radius-full);
  background: hsl(var(--primary));
  color: hsl(var(--primary-foreground));
}

.desktop-sidebar__user-initial {
  font-size: var(--text-sm);
  font-weight: var(--font-weight-semibold);
  line-height: 1;
}

.desktop-sidebar__user-name {
  font-size: var(--text-sm);
  font-weight: var(--font-weight-medium);
  color: hsl(var(--foreground));
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.desktop-sidebar__toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: var(--touch-target-min);
  min-height: var(--touch-target-min);
  border-radius: var(--radius-md);
  background: transparent;
  border: none;
  color: hsl(var(--muted-foreground));
  cursor: pointer;
  transition: color var(--transition-fast), background-color var(--transition-fast);
  -webkit-tap-highlight-color: transparent;
}

.desktop-sidebar__toggle:hover {
  color: hsl(var(--foreground));
  background: hsl(var(--accent));
}

.desktop-sidebar__toggle:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: 2px;
}

/* Transition for sidebar content fade */
.sidebar-fade-enter-active {
  transition: opacity var(--transition-fast);
}

.sidebar-fade-leave-active {
  transition: opacity 50ms ease;
}

.sidebar-fade-enter-from,
.sidebar-fade-leave-to {
  opacity: 0;
}
</style>
