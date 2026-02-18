<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowLeft } from 'lucide-vue-next'
import { useUserStore } from '@/components/store/userStore'

withDefaults(defineProps<{
  title?: string
  showBack?: boolean
}>(), {
  title: '',
  showBack: false,
})

const emit = defineEmits<{
  'avatar-click': []
}>()

const router = useRouter()
const userStore = useUserStore()

const userInitial = computed(() => {
  const name = userStore.user?.username || userStore.user?.email || '?'
  return name.charAt(0).toUpperCase()
})

function handleBack(): void {
  router.back()
}

function handleAvatarClick(): void {
  emit('avatar-click')
}
</script>

<template>
  <header
    class="sticky-header"
    role="banner"
  >
    <div class="sticky-header__inner">
      <div class="sticky-header__left">
        <button
          v-if="showBack"
          class="sticky-header__back touch-target"
          aria-label="Go back"
          @click="handleBack"
        >
          <ArrowLeft :size="20" />
        </button>
        <h1 class="sticky-header__title">{{ title }}</h1>
      </div>

      <div class="sticky-header__right">
        <button
          class="sticky-header__avatar"
          aria-label="User menu"
          @click="handleAvatarClick"
        >
          <span class="sticky-header__avatar-text">{{ userInitial }}</span>
          <span class="sticky-header__status-dot" aria-hidden="true" />
        </button>
      </div>
    </div>
  </header>
</template>

<style scoped>
.sticky-header {
  position: sticky;
  top: 0;
  z-index: var(--z-sticky);
  background: hsl(var(--background) / 0.8);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-bottom: 1px solid hsl(var(--border));
  padding-top: var(--safe-area-top);
}

.sticky-header__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: var(--header-height);
  padding: 0 var(--space-4);
  max-width: var(--content-max-width);
  margin: 0 auto;
}

.sticky-header__left {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  min-width: 0;
}

.sticky-header__back {
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: var(--touch-target-min);
  min-height: var(--touch-target-min);
  border-radius: var(--radius-md);
  color: hsl(var(--foreground));
  background: transparent;
  border: none;
  cursor: pointer;
  transition: background-color var(--transition-fast);
  -webkit-tap-highlight-color: transparent;
}

.sticky-header__back:hover {
  background: hsl(var(--accent));
}

.sticky-header__back:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: 2px;
}

.sticky-header__title {
  font-size: var(--text-lg);
  font-weight: var(--font-weight-semibold);
  color: hsl(var(--foreground));
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin: 0;
}

.sticky-header__right {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.sticky-header__avatar {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  border-radius: var(--radius-full);
  background: hsl(var(--primary));
  color: hsl(var(--primary-foreground));
  border: none;
  cursor: pointer;
  transition: transform var(--transition-fast), box-shadow var(--transition-fast);
  -webkit-tap-highlight-color: transparent;
}

.sticky-header__avatar:hover {
  transform: scale(1.05);
  box-shadow: 0 0 0 2px hsl(var(--background)), 0 0 0 4px hsl(var(--primary));
}

.sticky-header__avatar:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: 2px;
}

.sticky-header__avatar-text {
  font-size: var(--text-sm);
  font-weight: var(--font-weight-semibold);
  line-height: 1;
}

.sticky-header__status-dot {
  position: absolute;
  bottom: -1px;
  right: -1px;
  width: 0.625rem;
  height: 0.625rem;
  border-radius: var(--radius-full);
  background: hsl(var(--color-success));
  border: 2px solid hsl(var(--background));
}
</style>
