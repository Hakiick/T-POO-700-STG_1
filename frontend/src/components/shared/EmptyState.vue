<script setup lang="ts">
interface Props {
  title: string
  description?: string
  icon?: string
}

defineProps<Props>()
</script>

<template>
  <div class="flex flex-col items-center justify-center py-12 px-4 text-center animate-fade-in">
    <div
      v-if="icon"
      class="flex items-center justify-center w-16 h-16 rounded-full bg-muted mb-4"
    >
      <span class="text-2xl text-muted-foreground">{{ icon }}</span>
    </div>
    <h3 class="text-fluid-lg font-semibold text-foreground mb-1">{{ title }}</h3>
    <p v-if="description" class="text-fluid-sm text-muted-foreground max-w-sm">
      {{ description }}
    </p>
    <div v-if="$slots.action" class="mt-4">
      <slot name="action" />
    </div>
  </div>
</template>
