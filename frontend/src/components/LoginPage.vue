<script setup lang="ts">
import { ref } from 'vue'
import { Button } from './ui/button'
import { Input } from './ui/input'
import { Label } from './ui/label'

import { cn } from '@/lib/utils'
import LucideSpinner from '~icons/lucide/loader-2'
import GitHubLogo from '~icons/radix-icons/github-logo'

const isLoading = ref(false)
async function onSubmit(event: Event) {
  event.preventDefault()
  isLoading.value = true

  setTimeout(() => {
    isLoading.value = false
  }, 3000)
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-900 text-white">
    <div class="w-full max-w-md space-y-8">
      <!-- Title -->
      <div class="text-center">
        <h2 class="text-3xl font-bold">Create an account</h2>
        <p class="mt-2 text-sm text-gray-400">Enter your email below to create your account</p>
      </div>

      <!-- Form -->
      <form @submit="onSubmit" class="space-y-6">
        <div class="space-y-4">
          <div>
            <Label class="sr-only" for="email">Email</Label>
            <Input
              id="email"
              placeholder="name@example.com"
              type="email"
              auto-capitalize="none"
              auto-complete="email"
              auto-correct="off"
              :disabled="isLoading"
              class="w-full px-4 py-2 rounded-md border border-gray-700 bg-gray-800"
            />
          </div>
          <Button class="w-full bg-blue-600 hover:bg-blue-700 py-2 rounded-md" :disabled="isLoading">
            <LucideSpinner v-if="isLoading" class="mr-2 h-4 w-4 animate-spin" />
            Sign In with Email
          </Button>
        </div>

        <!-- Divider -->
        <div class="relative">
          <div class="absolute inset-0 flex items-center">
            <span class="w-full border-t border-gray-600"></span>
          </div>
          <div class="relative flex justify-center text-xs uppercase">
            <span class="px-2 bg-gray-900 text-gray-400">Or continue with</span>
          </div>
        </div>

        <!-- GitHub button -->
        <Button variant="outline" class="w-full border-gray-600 py-2 rounded-md flex items-center justify-center" :disabled="isLoading">
          <LucideSpinner v-if="isLoading" class="mr-2 h-4 w-4 animate-spin" />
          <GitHubLogo v-else class="mr-2 h-4 w-4" />
          GitHub
        </Button>
      </form>

      <!-- Terms & Conditions -->
      <p class="text-xs text-center text-gray-500">
        By clicking continue, you agree to our <a href="#" class="underline">Terms of Service</a> and <a href="#" class="underline">Privacy Policy</a>.
      </p>
    </div>
  </div>
</template>
