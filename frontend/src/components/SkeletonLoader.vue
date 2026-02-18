<script setup lang="ts">
/**
 * SkeletonLoader — Reusable skeleton loading placeholder.
 * Displays pulsing blocks while content is loading.
 */
defineOptions({
  name: 'SkeletonLoader',
});

interface Props {
  /** Number of text lines to render */
  lines?: number;
  /** Show a circular avatar placeholder */
  avatar?: boolean;
  /** Show a large chart placeholder */
  chart?: boolean;
}

withDefaults(defineProps<Props>(), {
  lines: 3,
  avatar: false,
  chart: false,
});
</script>

<template>
  <div class="space-y-3" role="status" aria-label="Loading content">
    <!-- Avatar skeleton -->
    <div
      v-if="avatar"
      class="w-12 h-12 rounded-full bg-muted animate-pulse"
    />

    <!-- Text line skeletons -->
    <div
      v-for="i in lines"
      :key="i"
      class="h-4 rounded-md bg-muted animate-pulse"
      :class="i === lines ? 'w-3/4' : 'w-full'"
    />

    <!-- Chart skeleton -->
    <div
      v-if="chart"
      class="h-40 w-full rounded-lg bg-muted animate-pulse mt-4"
    />
  </div>
</template>
