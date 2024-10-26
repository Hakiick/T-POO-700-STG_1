<script setup lang="ts">
import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
  navigationMenuTriggerStyle,
} from './ui/navigation-menu'

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
        <NavigationMenuLink href="/admin/teams" :class="navigationMenuTriggerStyle()">
          Teams
        </NavigationMenuLink>
      </NavigationMenuItem>
      
    </NavigationMenuList>
  </NavigationMenu>
</template>