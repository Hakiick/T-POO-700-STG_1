<script setup lang="ts">
import { Settings as SettingsIcon } from 'lucide-vue-next'
</script>

<template>
  <div class="page-stub">
    <div class="page-stub__icon">
      <SettingsIcon :size="48" />
    </div>
    <h2 class="page-stub__title">Settings</h2>
    <p class="page-stub__subtitle">Coming soon in next sprint</p>
  </div>
</template>

<style scoped>
.page-stub {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60dvh;
  padding: var(--space-8);
  text-align: center;
  animation: fade-in-up var(--transition-slow) ease-out;
}

.page-stub__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 5rem;
  height: 5rem;
  border-radius: var(--radius-2xl);
  background: hsl(var(--primary) / 0.1);
  color: hsl(var(--primary));
  margin-bottom: var(--space-4);
}

.page-stub__title {
  font-size: var(--text-2xl);
  font-weight: var(--font-weight-bold);
  color: hsl(var(--foreground));
  margin: 0 0 var(--space-2) 0;
}

.page-stub__subtitle {
  font-size: var(--text-base);
  color: hsl(var(--muted-foreground));
  margin: 0;
}
</style>
