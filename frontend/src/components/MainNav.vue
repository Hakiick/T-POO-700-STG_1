<script setup lang="ts">
import { ref } from 'vue';
import { cn } from '../lib/utils';
import { useUserStore } from './store/userStore';
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from './ui/navigation-menu';

const isMenuOpen = ref(false);
const userStore = useUserStore();

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value;
};
</script>

<template>
  <NavigationMenu>
    <button
      @click="toggleMenu"
      aria-label="Menu de navigation"
      class="lg:hidden min-h-[2.75rem] min-w-[2.75rem] p-2 rounded-md focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary"
    >
      <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
      </svg>
    </button>
    <NavigationMenuList :class="cn('lg:flex lg:flex-col lg:items-center', { 'block': isMenuOpen, 'hidden': !isMenuOpen })">
      <NavigationMenuItem>
        <NavigationMenuLink href="/" :class="navigationMenuTriggerStyle()">
          Home
        </NavigationMenuLink>
      </NavigationMenuItem>
      <NavigationMenuItem>
        <NavigationMenuLink href="/dashboard" :class="navigationMenuTriggerStyle()">
          Dashboard
        </NavigationMenuLink>
      </NavigationMenuItem>
      <NavigationMenuItem v-if="userStore.user.role === 'manager' || userStore.user.role === 'general_manager'">
        <NavigationMenuLink href="/admin/dashboard" :class="navigationMenuTriggerStyle()">
          Admin Dashboard
        </NavigationMenuLink>
      </NavigationMenuItem>
      <NavigationMenuItem v-if="userStore.user.role === 'manager' || userStore.user.role === 'general_manager'">
        <NavigationMenuLink href="/admin/users" :class="navigationMenuTriggerStyle()">
          Users
        </NavigationMenuLink>
      </NavigationMenuItem>
      <NavigationMenuItem v-if="userStore.user.role === 'general_manager'">
        <NavigationMenuLink href="/admin/teams" :class="navigationMenuTriggerStyle()">
          Teams
        </NavigationMenuLink>
      </NavigationMenuItem>
    </NavigationMenuList>
  </NavigationMenu>
</template>
