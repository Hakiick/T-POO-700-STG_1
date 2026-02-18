<script setup lang="ts">
import { ref, computed } from 'vue'
import { Button } from './ui/button'
import { Input } from './ui/input'
import { Label } from './ui/label'
import { useRoute } from 'vue-router'
import { resetPassword } from '../api/apiUser'
import router from '@/router'

const route = useRoute()
const resetToken = route.query.token

const newPassword = ref('')
const errorMessage = ref('')
const isLoading = ref(false)
const isSuccess = ref(false)
const showPassword = ref(false)

const passwordFieldType = computed(() => (showPassword.value ? 'text' : 'password'))

async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(password)
  const hash = await crypto.subtle.digest('SHA-256', data)
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

/** Password strength: 0 = empty, 1 = weak, 2 = fair, 3 = good, 4 = strong */
const passwordStrength = computed((): number => {
  const pw = newPassword.value
  if (pw.length === 0) return 0
  let score = 0
  if (pw.length >= 8) score += 1
  if (pw.length >= 12) score += 1
  if (/[A-Z]/.test(pw) && /[a-z]/.test(pw)) score += 1
  if (/\d/.test(pw) && /[^A-Za-z0-9]/.test(pw)) score += 1
  return score
})

const strengthLabel = computed((): string => {
  const labels = ['', 'Weak', 'Fair', 'Good', 'Strong']
  return labels[passwordStrength.value]
})

const strengthColor = computed((): string => {
  const colors = ['bg-gray-700', 'bg-red-500', 'bg-orange-500', 'bg-yellow-500', 'bg-green-500']
  return colors[passwordStrength.value]
})

const strengthTextColor = computed((): string => {
  const colors = ['text-gray-500', 'text-red-400', 'text-orange-400', 'text-yellow-400', 'text-green-400']
  return colors[passwordStrength.value]
})

async function handleNewPassword() {
  errorMessage.value = ''

  if (newPassword.value.length < 12) {
    errorMessage.value = 'Password must be at least 12 characters.'
    return
  }

  isLoading.value = true

  try {
    const hashed = await hashPassword(newPassword.value)
    const response = await resetPassword(hashed, resetToken)
    if (response.status === 200) {
      isSuccess.value = true
      setTimeout(() => {
        router.push({ name: 'login' })
      }, 3000)
    } else {
      errorMessage.value = 'An error occurred. Please request a new reset link.'
    }
  } catch {
    errorMessage.value = 'Unable to connect. Please try again.'
  } finally {
    isLoading.value = false
  }
}

function goToLogin() {
  router.push({ name: 'login' })
}
</script>

<template>
  <main
    class="flex min-h-dvh w-full items-center justify-center bg-gray-900 px-4 py-8 pb-[env(safe-area-inset-bottom)]"
  >
    <div class="w-full max-w-sm">
      <!-- Success state -->
      <div v-if="isSuccess" class="space-y-4 text-center">
        <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-green-900/50">
          <svg class="h-7 w-7 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 class="text-xl font-bold text-green-400">Password updated!</h2>
        <p class="text-sm text-gray-400">
          Your password has been changed. Redirecting to login...
        </p>
        <Button
          class="min-h-[2.75rem] w-full bg-blue-600 hover:bg-blue-700 rounded-md"
          @click="goToLogin"
        >
          Go to Login
        </Button>
      </div>

      <!-- Reset form -->
      <div v-if="!isSuccess" class="space-y-6 text-white">
        <div class="text-center">
          <h2 class="text-2xl font-bold md:text-3xl">New Password</h2>
          <p class="mt-2 text-sm text-gray-400 md:text-base">
            Enter a new password for your account
          </p>
        </div>

        <form @submit.prevent="handleNewPassword" class="space-y-5">
          <div>
            <Label for="new-password" class="mb-1 block text-sm text-gray-300">
              New password
            </Label>
            <div class="relative">
              <Input
                v-model="newPassword"
                id="new-password"
                :type="passwordFieldType"
                placeholder="Min. 12 chars, 1 uppercase, 1 number, 1 special"
                autocomplete="new-password"
                required
                :disabled="isLoading"
                class="w-full rounded-md border border-gray-700 bg-gray-800 px-4 py-3 pr-12 text-white placeholder:text-gray-500 focus-visible:ring-2 focus-visible:ring-blue-500"
              />
              <button
                type="button"
                class="absolute right-3 top-1/2 -translate-y-1/2 min-h-[2.75rem] min-w-[2.75rem] flex items-center justify-center text-gray-400 hover:text-gray-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:rounded"
                :aria-label="showPassword ? 'Hide password' : 'Show password'"
                @click="showPassword = !showPassword"
              >
                <!-- Eye open icon (show) -->
                <svg
                  v-if="!showPassword"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
                <!-- Eye off icon (hide) -->
                <svg
                  v-if="showPassword"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                </svg>
              </button>
            </div>

            <!-- Password strength indicator -->
            <div v-if="newPassword.length > 0" class="mt-3 space-y-1">
              <div class="flex gap-1" role="meter" :aria-valuenow="passwordStrength" aria-valuemin="0" aria-valuemax="4" :aria-label="`Password strength: ${strengthLabel}`">
                <div
                  v-for="i in 4"
                  :key="i"
                  class="h-1.5 flex-1 rounded-full transition-colors duration-200"
                  :class="i <= passwordStrength ? strengthColor : 'bg-gray-700'"
                />
              </div>
              <p class="text-xs" :class="strengthTextColor">
                {{ strengthLabel }}
              </p>
            </div>
          </div>

          <Button
            type="submit"
            class="w-full min-h-[2.75rem] bg-blue-600 hover:bg-blue-700 rounded-md font-medium"
            :disabled="isLoading"
          >
            <svg
              v-if="isLoading"
              class="mr-2 h-4 w-4 animate-spin"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
            </svg>
            {{ isLoading ? 'Updating...' : 'Update Password' }}
          </Button>
        </form>

        <!-- Error message -->
        <p
          v-if="errorMessage"
          class="rounded-md bg-red-900/30 p-3 text-center text-sm text-red-400"
          role="alert"
        >
          {{ errorMessage }}
        </p>

        <!-- Back to login link -->
        <div class="text-center">
          <button
            type="button"
            class="min-h-[2.75rem] text-sm text-gray-400 underline hover:text-gray-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:rounded"
            @click="goToLogin"
          >
            Back to Login
          </button>
        </div>
      </div>
    </div>
  </main>
</template>
