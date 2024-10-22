<script setup lang="ts">
import { ref } from 'vue'
import { Button } from './ui/button'
import { Input } from './ui/input'
import { Label } from './ui/label'
import { createUser } from '../api/apiUser';
import router from '../router';
import { useUserStore } from './store/userStore';

const isLoadingSignIn = ref(false)
const isCheckedSignIn = ref(false)
const errorMessageSignIn = ref('')

const isLoadingSignUp = ref(false)
const isCheckedSignUp = ref(false)
const errorMessageSignUp = ref('')
const emailSignup = ref('')
const passwordSignup = ref('')

const userStore = useUserStore()

const activeDiv = ref<'signin' | 'signup' | 'gotham'>('gotham')

async function onSubmitSignIn(event: Event) {
  event.preventDefault()
  isLoadingSignIn.value = true
  setTimeout(() => {
    isLoadingSignIn.value = false
  }, 3000)

  if (!isCheckedSignIn.value) {
    errorMessageSignIn.value = "You haven't accepted our Terms of Service and Privacy Policy."
    return
  }

  isLoadingSignIn.value = true
  errorMessageSignIn.value = '' 
}

async function onSubmitSignUp(event: Event) {
  event.preventDefault()
  isLoadingSignUp.value = true

  setTimeout(() => {
    isLoadingSignUp.value = false
  }, 300)

  if (!isCheckedSignUp.value) {
    errorMessageSignUp.value = "You haven't accepted our Terms of Service and Privacy Policy."
    return
  }

  isLoadingSignUp.value = true

  const response = await createUser(passwordSignup, emailSignup.value)
  if (response.data.id) {
    userStore.setUser(response.data)
    router.push({ name: 'home' })
  }

  if (response.status === 400) {
    errorMessageSignUp.value = "error has occured"
    return
  }

  errorMessageSignUp.value = '' 
}
</script>

<template>
  <div class="flex flex-col min-h-screen bg-gray-900 text-white">
    <!-- Gradient Background with reduced margin -->
      
      <!-- Main content -->
      <div class="flex flex-col items-center justify-center p-6 bg-gray-900 rounded-lg shadow-lg w-full max-w-lg">
        <!-- gotham Image -->
        <div v-if="activeDiv === 'gotham'">
          <img src="./ui/images/gotham.jpg" alt="gotham coding" class="w-full max-w-xs md:max-w-md" />
        </div>

        <!-- Sign In Form -->
        <div class="w-full space-y-8" v-if="activeDiv === 'signin'">
          <div class="text-center">
            <h2 class="text-2xl md:text-3xl font-bold">Sign In</h2>
            <p class="mt-2 text-sm md:text-base text-gray-400">Enter your email below to sign in</p>
          </div>
          <form @submit="onSubmitSignIn" class="space-y-6">
            <div class="space-y-4">
              <div>
                <Label class="sr-only" for="email">Email</Label>
                <Input id="email" placeholder="name@example.com" type="email"
                  auto-capitalize="none" auto-complete="email" auto-correct="off" :disabled="isLoadingSignIn"
                  class="w-full px-4 py-2 rounded-md border border-gray-700 bg-gray-800"
                />
              </div>
              <Input id="password" placeholder="Enter your password" type="password" auto-capitalize="none"
                auto-complete="password" auto-correct="off" :disabled="isLoadingSignIn"
                class="w-full px-4 py-2 rounded-md border border-gray-700 bg-gray-800"
              />
              <Button class="w-full bg-blue-600 hover:bg-blue-700 py-2 rounded-md" :disabled="isLoadingSignIn">
                Sign In with Email
              </Button>
            </div>
          </form>
          <p class="text-xs text-center text-gray-500">
            <input type="checkbox" id="agree-signin" v-model="isCheckedSignIn"
              class="form-checkbox h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              :disabled="isLoadingSignIn"
            />
            By clicking continue, you agree to our
            <a href="#" class="underline">Terms of Service</a> and
            <a href="#" class="underline">Privacy Policy</a>.
          </p>
          <p v-if="errorMessageSignIn" class="text-red-500 text-sm text-center">
            {{ errorMessageSignIn }}
          </p>
        </div>

        <!-- Sign Up Form -->
        <div class="w-full space-y-8" v-if="activeDiv === 'signup'">
          <div class="text-center">
            <h2 class="text-2xl md:text-3xl font-bold">Create an account</h2>
            <p class="mt-2 text-sm md:text-base text-gray-400">Enter your email below to create your account</p>
          </div>
          <form @submit="onSubmitSignUp" class="space-y-6">
            <div class="space-y-4">
              <div>
                <Label class="sr-only" for="email-signup">Email</Label>
                <Input v-model="emailSignup" id="email-signup" placeholder="name@example.com" type="email"
                  auto-capitalize="none" auto-complete="email" auto-correct="off" :disabled="isLoadingSignUp"
                  class="w-full px-4 py-2 rounded-md border border-gray-700 bg-gray-800"
                />
              </div>
              <Input v-model="passwordSignup" id="password-signup" placeholder="Enter your password" type="password"
                auto-capitalize="none" auto-complete="password" auto-correct="off" :disabled="isLoadingSignUp"
                class="w-full px-4 py-2 rounded-md border border-gray-700 bg-gray-800"
              />
              <Button class="w-full bg-blue-600 hover:bg-blue-700 py-2 rounded-md" :disabled="isLoadingSignUp">
                Sign Up
              </Button>
            </div>
          </form>
          <p class="text-xs text-center text-gray-500">
            <input type="checkbox" id="agree-signup" v-model="isCheckedSignUp"
              class="form-checkbox h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              :disabled="isLoadingSignUp"
            />
            By clicking continue, you agree to our
            <a href="#" class="underline">Terms of Service</a> and
            <a href="#" class="underline">Privacy Policy</a>.
          </p>
          <p v-if="errorMessageSignUp" class="text-red-500 text-sm text-center">
            {{ errorMessageSignUp }}
          </p>
        </div>

        <!-- Buttons below the forms -->
        <div class="flex justify-center space-x-4 p-4">
            <Button v-if="activeDiv !== 'signup'" @click="activeDiv = 'signup'" class="bg-blue-600 hover:bg-blue-700 py-2 px-4 rounded-md">
    Create
  </Button>
            <Button v-if="activeDiv !== 'signin'" @click="activeDiv = 'signin'" class="bg-blue-600 hover:bg-blue-700 py-2 px-4 rounded-md">
    Login
  </Button>
        </div>
      </div>
    </div>
  </div>
</template>