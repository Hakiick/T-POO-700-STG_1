<script setup lang="ts">
import { ref, computed } from 'vue'
import { Button } from './ui/button'
import { Input } from './ui/input'
import { Label } from './ui/label'
import { Tabs, TabsList, TabsTrigger, TabsContent } from './ui/tabs'
import { createUser, loginUser } from '../api/apiUser'
import router from '@/router'

const activeTab = ref<string>('signin')

// Sign In form state
const isLoadingSignIn = ref(false)
const isCheckedSignIn = ref(false)
const errorMessageSignIn = ref('')
const emailSignIn = ref('')
const passwordSignIn = ref('')

// Sign Up form state
const isLoadingSignUp = ref(false)
const isCheckedSignUp = ref(false)
const errorMessageSignUp = ref('')
const emailSignup = ref('')
const passwordSignup = ref('')

const signUpSuccess = ref(false)

const isSignInDisabled = computed(() => isLoadingSignIn.value)
const isSignUpDisabled = computed(() => isLoadingSignUp.value)

async function onSubmitSignIn() {
  errorMessageSignIn.value = ''

  if (!isCheckedSignIn.value) {
    errorMessageSignIn.value = "You haven't accepted our Terms of Service and Privacy Policy."
    return
  }

  isLoadingSignIn.value = true

  try {
    const response = await loginUser(emailSignIn.value, passwordSignIn.value)
    if (response.status === 200) {
      sessionStorage.setItem('access_token', response.data.access_token)
      sessionStorage.setItem('refresh_token', response.data.refresh_token)
      router.push({ name: 'home' })
      return
    }
    if (response.data?.errors) {
      errorMessageSignIn.value = typeof response.data.errors === 'string'
        ? response.data.errors
        : 'Invalid email or password.'
      return
    }
    errorMessageSignIn.value = 'An unexpected error occurred.'
  } catch {
    errorMessageSignIn.value = 'Unable to connect. Please try again.'
  } finally {
    isLoadingSignIn.value = false
  }
}

async function onSubmitSignUp() {
  errorMessageSignUp.value = ''

  if (!isCheckedSignUp.value) {
    errorMessageSignUp.value = "You haven't accepted our Terms of Service and Privacy Policy."
    return
  }

  isLoadingSignUp.value = true

  try {
    const response = await createUser(emailSignup.value, emailSignup.value, passwordSignup.value)
    if (response.status === 201) {
      signUpSuccess.value = true
      return
    }
    if (response.data?.errors) {
      const errors = response.data.errors
      if (typeof errors === 'string') {
        errorMessageSignUp.value = errors
      } else if (typeof errors === 'object') {
        const messages: string[] = []
        for (const key in errors) {
          const val = errors[key]
          if (Array.isArray(val)) {
            messages.push(...val)
          } else if (typeof val === 'string') {
            messages.push(val)
          }
        }
        errorMessageSignUp.value = messages.join(' ')
      }
      return
    }
    errorMessageSignUp.value = 'An unexpected error occurred.'
  } catch {
    errorMessageSignUp.value = 'Unable to connect. Please try again.'
  } finally {
    isLoadingSignUp.value = false
  }
}
</script>

<template>
  <main
    class="flex min-h-dvh w-full items-center justify-center bg-gray-900 px-4 py-8 pb-[env(safe-area-inset-bottom)]"
  >
    <div class="w-full max-w-md">
      <Tabs v-model="activeTab" class="w-full">
        <TabsList class="grid w-full grid-cols-2 bg-gray-800">
          <TabsTrigger
            value="signin"
            class="min-h-[2.75rem] text-gray-300 data-[state=active]:bg-gray-700 data-[state=active]:text-white"
          >
            Sign In
          </TabsTrigger>
          <TabsTrigger
            value="signup"
            class="min-h-[2.75rem] text-gray-300 data-[state=active]:bg-gray-700 data-[state=active]:text-white"
          >
            Sign Up
          </TabsTrigger>
        </TabsList>

        <!-- Sign In Tab -->
        <TabsContent value="signin" class="mt-6">
          <div class="space-y-6 text-white">
            <div class="text-center">
              <h2 class="text-2xl font-bold md:text-3xl">Sign In</h2>
              <p class="mt-2 text-sm text-gray-400 md:text-base">
                Enter your email below to sign in
              </p>
            </div>

            <form @submit.prevent="onSubmitSignIn" class="space-y-5">
              <div class="space-y-4">
                <div>
                  <Label for="email-signin" class="mb-1 block text-sm text-gray-300">
                    Email
                  </Label>
                  <Input
                    v-model="emailSignIn"
                    id="email-signin"
                    placeholder="name@example.com"
                    type="email"
                    autocapitalize="none"
                    autocomplete="email"
                    autocorrect="off"
                    required
                    :disabled="isSignInDisabled"
                    class="w-full rounded-md border border-gray-700 bg-gray-800 px-4 py-3 text-white placeholder:text-gray-500 focus-visible:ring-2 focus-visible:ring-blue-500"
                  />
                </div>
                <div>
                  <Label for="password-signin" class="mb-1 block text-sm text-gray-300">
                    Password
                  </Label>
                  <Input
                    v-model="passwordSignIn"
                    id="password-signin"
                    placeholder="Enter your password"
                    type="password"
                    autocapitalize="none"
                    autocomplete="current-password"
                    autocorrect="off"
                    required
                    :disabled="isSignInDisabled"
                    class="w-full rounded-md border border-gray-700 bg-gray-800 px-4 py-3 text-white placeholder:text-gray-500 focus-visible:ring-2 focus-visible:ring-blue-500"
                  />
                </div>
              </div>

              <Button
                type="submit"
                class="w-full min-h-[2.75rem] bg-blue-600 hover:bg-blue-700 rounded-md font-medium"
                :disabled="isSignInDisabled"
              >
                <svg
                  v-if="isLoadingSignIn"
                  class="mr-2 h-4 w-4 animate-spin"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                </svg>
                {{ isLoadingSignIn ? 'Signing in...' : 'Sign In with Email' }}
              </Button>

              <!-- Separator -->
              <div class="relative">
                <div class="absolute inset-0 flex items-center">
                  <span class="w-full border-t border-gray-600" />
                </div>
                <div class="relative flex justify-center text-xs uppercase">
                  <span class="bg-gray-900 px-2 text-gray-400">Or continue with</span>
                </div>
              </div>
            </form>

            <!-- Terms checkbox -->
            <label
              for="agree-signin"
              class="flex min-h-[2.75rem] cursor-pointer items-center gap-3 text-xs text-gray-500"
            >
              <input
                type="checkbox"
                id="agree-signin"
                v-model="isCheckedSignIn"
                class="h-5 w-5 shrink-0 rounded border-gray-600 bg-gray-800 text-blue-600 focus:ring-2 focus:ring-blue-500"
                :disabled="isSignInDisabled"
              />
              <span>
                By clicking continue, you agree to our
                <a href="#" class="underline hover:text-gray-300">Terms of Service</a> and
                <a href="#" class="underline hover:text-gray-300">Privacy Policy</a>.
              </span>
            </label>

            <!-- Error message -->
            <p
              v-if="errorMessageSignIn"
              class="rounded-md bg-red-900/30 p-3 text-center text-sm text-red-400"
              role="alert"
            >
              {{ errorMessageSignIn }}
            </p>
          </div>
        </TabsContent>

        <!-- Sign Up Tab -->
        <TabsContent value="signup" class="mt-6">
          <div class="space-y-6 text-white">
            <!-- Success message -->
            <div v-if="signUpSuccess" class="space-y-4 text-center">
              <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-green-900/50">
                <svg class="h-6 w-6 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <h3 class="text-lg font-semibold text-green-400">Account created!</h3>
              <p class="text-sm text-gray-400">
                Please check your email to confirm your account.
              </p>
              <Button
                class="min-h-[2.75rem] w-full bg-blue-600 hover:bg-blue-700 rounded-md"
                @click="activeTab = 'signin'; signUpSuccess = false"
              >
                Go to Sign In
              </Button>
            </div>

            <!-- Sign Up form -->
            <template v-if="!signUpSuccess">
              <div class="text-center">
                <h2 class="text-2xl font-bold md:text-3xl">Create an account</h2>
                <p class="mt-2 text-sm text-gray-400 md:text-base">
                  Enter your email below to create your account
                </p>
              </div>

              <form @submit.prevent="onSubmitSignUp" class="space-y-5">
                <div class="space-y-4">
                  <div>
                    <Label for="email-signup" class="mb-1 block text-sm text-gray-300">
                      Email
                    </Label>
                    <Input
                      v-model="emailSignup"
                      id="email-signup"
                      placeholder="name@example.com"
                      type="email"
                      autocapitalize="none"
                      autocomplete="email"
                      autocorrect="off"
                      required
                      :disabled="isSignUpDisabled"
                      class="w-full rounded-md border border-gray-700 bg-gray-800 px-4 py-3 text-white placeholder:text-gray-500 focus-visible:ring-2 focus-visible:ring-blue-500"
                    />
                  </div>
                  <div>
                    <Label for="password-signup" class="mb-1 block text-sm text-gray-300">
                      Password
                    </Label>
                    <Input
                      v-model="passwordSignup"
                      id="password-signup"
                      placeholder="Enter your password"
                      type="password"
                      autocapitalize="none"
                      autocomplete="new-password"
                      autocorrect="off"
                      required
                      :disabled="isSignUpDisabled"
                      class="w-full rounded-md border border-gray-700 bg-gray-800 px-4 py-3 text-white placeholder:text-gray-500 focus-visible:ring-2 focus-visible:ring-blue-500"
                    />
                  </div>
                </div>

                <Button
                  type="submit"
                  class="w-full min-h-[2.75rem] bg-blue-600 hover:bg-blue-700 rounded-md font-medium"
                  :disabled="isSignUpDisabled"
                >
                  <svg
                    v-if="isLoadingSignUp"
                    class="mr-2 h-4 w-4 animate-spin"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    aria-hidden="true"
                  >
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                  {{ isLoadingSignUp ? 'Creating account...' : 'Sign Up' }}
                </Button>

                <!-- Separator -->
                <div class="relative">
                  <div class="absolute inset-0 flex items-center">
                    <span class="w-full border-t border-gray-600" />
                  </div>
                  <div class="relative flex justify-center text-xs uppercase">
                    <span class="bg-gray-900 px-2 text-gray-400">Or continue with</span>
                  </div>
                </div>
              </form>

              <!-- Terms checkbox -->
              <label
                for="agree-signup"
                class="flex min-h-[2.75rem] cursor-pointer items-center gap-3 text-xs text-gray-500"
              >
                <input
                  type="checkbox"
                  id="agree-signup"
                  v-model="isCheckedSignUp"
                  class="h-5 w-5 shrink-0 rounded border-gray-600 bg-gray-800 text-blue-600 focus:ring-2 focus:ring-blue-500"
                  :disabled="isSignUpDisabled"
                />
                <span>
                  By clicking continue, you agree to our
                  <a href="#" class="underline hover:text-gray-300">Terms of Service</a> and
                  <a href="#" class="underline hover:text-gray-300">Privacy Policy</a>.
                </span>
              </label>

              <!-- Error message -->
              <p
                v-if="errorMessageSignUp"
                class="rounded-md bg-red-900/30 p-3 text-center text-sm text-red-400"
                role="alert"
              >
                {{ errorMessageSignUp }}
              </p>
            </template>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  </main>
</template>
