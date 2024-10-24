<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { cn } from '../lib/utils';

const isMenuOpen = ref(false);

const isDesktop = ref(false);
const checkIsDesktop = () => {
  isDesktop.value = window.innerWidth >= 1024;
};
onMounted(async () => {
  checkIsDesktop();
  window.addEventListener('resize', checkIsDesktop);
});

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value;
};
</script>

<template>
  <nav :class="cn('flex flex-col items-center space-y-4 lg:space-y-6', $attrs.class ?? '')">
    <button @click="toggleMenu" class="lg:hidden p-2 rounded-md focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary">
      <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
      </svg>
    </button>
    <div :class="cn('lg:flex lg:flex-col lg:items-center lg:space-y-4', { 'block': isMenuOpen, 'hidden': !isMenuOpen })">
      <a href="/" class="block text-sm font-medium transition-colors hover:text-primary py-2 lg:py-0">
        Home
      </a>
      <a href="/login" class="block text-sm font-medium text-muted-foreground transition-colors hover:text-primary py-2 lg:py-0">
        Login
      </a>
      <a v-if="!isDesktop" href="/dashboard" class="block text-sm font-medium text-muted-foreground transition-colors hover:text-primary py-2 lg:py-0">
        Dashboard
      </a>
      <a href="/admin/dashboard" class="text-sm font-medium text-muted-foreground transition-colors hover:text-primary">
      Admin Dashboard
    </a>
      <!-- <a href="/login" class="block text-sm font-medium text-muted-foreground transition-colors hover:text-primary py-2 lg:py-0"> -->
      <!--   Products -->
      <!-- </a> -->
      <!-- <a href="/login" class="block text-sm font-medium text-muted-foreground transition-colors hover:text-primary py-2 lg:py-0"> -->
      <!--   Settings -->
      <!-- </a> -->
    </div>
  </nav>
</template>