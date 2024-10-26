<script setup lang="ts">
import { useUserStore } from './store/userStore';
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from './ui/navigation-menu'

const userStore = useUserStore();
</script>

<template>
  <NavigationMenu>
    <NavigationMenuList>

      <NavigationMenuItem>
        <NavigationMenuLink href="/admin/dashboard" :class="navigationMenuTriggerStyle()">
          Dashboard
        </NavigationMenuLink>
      </NavigationMenuItem>
      <NavigationMenuItem>
        <NavigationMenuLink href="/admin/users" :class="navigationMenuTriggerStyle()">
          Users
        </NavigationMenuLink>
      </NavigationMenuItem>
      <NavigationMenuItem>
        <NavigationMenuLink href="/admin/teams" :class="navigationMenuTriggerStyle()" v-if="userStore.user.role == 'general_manager'">
          Teams
        </NavigationMenuLink>
      </NavigationMenuItem>
      
    </NavigationMenuList>
  </NavigationMenu>
</template>