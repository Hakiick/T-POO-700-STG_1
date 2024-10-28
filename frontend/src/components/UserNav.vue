<script setup lang="ts">
import {
  Avatar,
  AvatarFallback,
  AvatarImage,
} from './ui/avatar'
import { Button } from './ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from './ui/dropdown-menu'
import { useUserStore } from './store/userStore';
import { computed } from 'vue'

const userStore = useUserStore();
const user = computed(() => userStore.user);

const userInitial = computed(() => {
  return user.value.username ? user.value.username.charAt(0).toUpperCase() : '';
});
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger as-child>
      <Button variant="ghost" class="relative h-12 w-12 rounded-full">
        <Avatar class="h-12 w-12">
          <AvatarImage src="/avatars/01.png" alt="@shadcn" />
          <AvatarFallback>{{ userInitial }}</AvatarFallback>
        </Avatar>
      </Button>
    </DropdownMenuTrigger>
    <DropdownMenuContent class="w-56" align="end">
      <DropdownMenuLabel class="font-normal flex">
        <div class="flex flex-col space-y-1">
          <p class="text-sm font-medium leading-none">
            {{ user.username || "Loading" }}
          </p>
          <p class="text-xs leading-none text-muted-foreground">
            {{ user.email }}
          </p>
        </div>
      </DropdownMenuLabel>
      <DropdownMenuSeparator />
      <DropdownMenuItem>
        <Button class="w-full" @click="userStore.logout"> Log out
        </Button>
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
</template>
