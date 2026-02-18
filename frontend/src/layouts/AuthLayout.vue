<script setup lang="ts">
import { Timer } from 'lucide-vue-next'
</script>

<template>
  <div class="auth-layout">
    <div class="auth-layout__card">
      <div class="auth-layout__logo">
        <div class="auth-layout__logo-icon">
          <Timer :size="32" />
        </div>
        <h1 class="auth-layout__logo-text">TimeManager</h1>
      </div>
      <slot />
    </div>
  </div>
</template>

<style scoped>
.auth-layout {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100dvh;
  padding: var(--space-4);
  background: linear-gradient(
    135deg,
    hsl(var(--primary) / 0.05) 0%,
    hsl(var(--background)) 50%,
    hsl(var(--primary) / 0.08) 100%
  );
}

.auth-layout__card {
  width: 100%;
  background: hsl(var(--card));
  border-radius: var(--radius-xl);
  padding: var(--space-6);
  box-shadow: var(--shadow-lg);
  border: 1px solid hsl(var(--border));
}

@media (min-width: 640px) {
  .auth-layout__card {
    max-width: 28rem;
    padding: var(--space-8);
  }
}

.auth-layout__logo {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-6);
}

.auth-layout__logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 3.5rem;
  height: 3.5rem;
  border-radius: var(--radius-xl);
  background: hsl(var(--primary) / 0.1);
  color: hsl(var(--primary));
}

.auth-layout__logo-text {
  font-size: var(--text-2xl);
  font-weight: var(--font-weight-bold);
  color: hsl(var(--foreground));
  margin: 0;
}
</style>
