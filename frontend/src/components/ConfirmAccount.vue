<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { Button } from './ui/button'
import router from '@/router'
import { confirmMail } from '../api/apiUser'

const route = useRoute()
const confirmToken = route.query.token

const isLoading = ref(true)
const isSuccess = ref(false)
const errorMessage = ref('')

onMounted(async () => {
  if (!confirmToken) {
    isLoading.value = false
    errorMessage.value = 'Invalid or missing confirmation token.'
    return
  }

  try {
    const resp = await confirmMail(confirmToken)
    if (resp.status === 200) {
      isLoading.value = false
      isSuccess.value = true
      setTimeout(() => {
        router.push({ name: 'login' })
      }, 3000)
    } else {
      isLoading.value = false
      errorMessage.value = 'Invalid or expired token. Please request a new confirmation email.'
    }
  } catch {
    isLoading.value = false
    errorMessage.value = 'An error occurred while confirming your account. Please try again.'
  }
})

function goToLogin() {
  router.push({ name: 'login' })
}
</script>

<template>
  <main
    class="flex min-h-dvh w-full items-center justify-center bg-gray-900 px-4 py-8 pb-[env(safe-area-inset-bottom)]"
  >
    <div class="w-full max-w-sm text-center">
      <!-- Loading state -->
      <div v-if="isLoading" class="space-y-4">
        <svg
          class="mx-auto h-10 w-10 animate-spin text-blue-500"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
        </svg>
        <h2 class="text-lg font-semibold text-white">Confirming your account...</h2>
        <p class="text-sm text-gray-400">Please wait while we verify your email.</p>
      </div>

      <!-- Success state -->
      <div v-if="isSuccess && !isLoading" class="space-y-4">
        <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-green-900/50">
          <svg class="h-7 w-7 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 class="text-xl font-bold text-green-400">Account confirmed!</h2>
        <p class="text-sm text-gray-400">
          Your email has been verified. Redirecting to login...
        </p>
        <Button
          class="min-h-[2.75rem] w-full bg-blue-600 hover:bg-blue-700 rounded-md"
          @click="goToLogin"
        >
          Go to Login
        </Button>
      </div>

      <!-- Error state -->
      <div v-if="errorMessage && !isLoading" class="space-y-4">
        <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-red-900/50">
          <svg class="h-7 w-7 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </div>
        <h2 class="text-xl font-bold text-red-400">Confirmation failed</h2>
        <p class="rounded-md bg-red-900/30 p-3 text-sm text-red-400" role="alert">
          {{ errorMessage }}
        </p>
        <Button
          class="min-h-[2.75rem] w-full bg-blue-600 hover:bg-blue-700 rounded-md"
          @click="goToLogin"
        >
          Back to Login
        </Button>
      </div>
    </div>
  </main>
</template>
