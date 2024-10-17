<script setup lang="ts">
import { ref } from 'vue'
import { Button } from './ui/button'
import { Input } from './ui/input'
import { Label } from './ui/label'
import { createUser } from '../api/apiUser';
import router from '../router';
import { useUserStore } from './store/userStore';
import { useRouter } from 'vue-router';
import { loginUser } from '../api/apiUser';


const email = ref('');
const password = ref('');
const router2 = useRouter();

const handleLogin = async () => {
  isLoadingSignIn.value = true;
  try {
    const isSuccess = await loginUser(email.value, password.value);
    if (isSuccess) {
      router2.push('/');
    } else {
      alert('Login failed. Please check your credentials.');
    }
  } catch (error) {
    console.error(error);
    alert('An error occurred. Please try again later.');
  } finally {
    isLoadingSignIn.value = false;
  }
};

// Variables pour le formulaire de connexion
const isLoadingSignIn = ref(false)
const isCheckedSignIn = ref(false)
const errorMessageSignIn = ref('')

// Variables pour le formulaire de création de compte
const isLoadingSignUp = ref(false)
const isCheckedSignUp = ref(false)
const errorMessageSignUp = ref('')
const emailSignup = ref('')
const passwordSignup = ref('')
const usernameSignup = ref('')

const userStore = useUserStore()

// Variable pour suivre quelle div est actuellement active
const activeDiv = ref<'signin' | 'signup' | null>(null)



async function onSubmitSignIn(event: Event) {
  event.preventDefault()
  isLoadingSignIn.value = true

  // Simuler un chargement
  setTimeout(() => {
    isLoadingSignIn.value = false
  }, 3000)

  if (!isCheckedSignIn.value) {
    errorMessageSignIn.value = "You haven't accepted our Terms of Service and Privacy Policy."
    return
  }

  // Si la checkbox est cochée, soumettre le formulaire
  isLoadingSignIn.value = true
  errorMessageSignIn.value = ''  // Réinitialiser le message d'erreur
}

async function onSubmitSignUp(event: Event) {
  event.preventDefault()
  isLoadingSignUp.value = true

  // Simuler un chargement
  setTimeout(() => {
    isLoadingSignUp.value = false
  }, 300)

  if (!isCheckedSignUp.value) {
    errorMessageSignUp.value = "You haven't accepted our Terms of Service and Privacy Policy."
    return
  }

  // Si la checkbox est cochée, soumettre le formulaire
  isLoadingSignUp.value = true

  // console.log({ email: emailSignup.value, username: passwordSignup.value })
  const response = await createUser(passwordSignup.value, emailSignup.value, usernameSignup.value)
  console.log(response.data)
  if (response.data.id) {
    //navitage to home page 
    console.log("created")
    userStore.setUser(response.data)
    router.push({ name: 'home' })
  }
  //catch error 
  if (response.status === 400) {
    errorMessageSignUp.value = "error has occured"
    return
  }

  errorMessageSignUp.value = ''  // Réinitialiser le message d'erreur
}
</script>

<template>
  <div class="flex flex-col md:flex-row min-h-screen">
    <!-- Première div (Sign In) -->
    <div
      class="flex-1 flex items-center justify-center bg-gray-900 text-white p-4 md:p-8"
      @mouseenter="activeDiv = 'signin'"
      @mouseleave="activeDiv = null"
    >
      <div v-if="activeDiv === 'signup'">
        <!-- Image de Batman pour l'autre div -->
        <img src="./ui/images/batman.jpg" alt="Batman coding" class="w-full max-w-xs md:max-w-md" />
      </div>
      <div class="w-full max-w-sm md:max-w-md space-y-8" v-if="activeDiv === 'signin' || activeDiv === null">
        <!-- Titre -->
        <div class="text-center">
          <h2 class="text-2xl md:text-3xl font-bold">Sign In</h2>
          <p class="mt-2 text-sm md:text-base text-gray-400">Enter your email below to sign in</p>
        </div>

        <!-- Formulaire -->
        <form @submit.prevent="handleLogin" class="space-y-6">
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

          <!-- Séparateur -->
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <span class="w-full border-t border-gray-600"></span>
            </div>
            <div class="relative flex justify-center text-xs uppercase">
              <span class="px-2 bg-gray-900 text-gray-400">Or continue with</span>
            </div>
          </div>
        </form>

        <!-- Conditions générales -->
        <p class="text-xs text-center text-gray-500">
          <input type="checkbox" id="agree-signin" v-model="isCheckedSignIn"
            class="form-checkbox h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            :disabled="isLoadingSignIn"
          />
          By clicking continue, you agree to our
          <a href="#" class="underline">Terms of Service</a> and
          <a href="#" class="underline">Privacy Policy</a>.
        </p>

        <!-- Message d'erreur -->
        <p v-if="errorMessageSignIn" class="text-red-500 text-sm text-center">
          {{ errorMessageSignIn }}
        </p>
      </div>
    </div>

    <!-- Deuxième div (Create an account) -->
    <div
      class="flex-1 flex items-center justify-center bg-gray-900 text-white p-4 md:p-8"
      @mouseenter="activeDiv = 'signup'"
      @mouseleave="activeDiv = null"
    >
      <div v-if="activeDiv === 'signin'">
        <!-- Image pour l'autre div -->
        <img src="./ui/images/batman.jpg" alt="Batman coding" class="w-full max-w-xs md:max-w-md" />
      </div>
      <div class="w-full max-w-sm md:max-w-md space-y-8" v-if="activeDiv === 'signup' || activeDiv === null">
        <!-- Titre -->
        <div class="text-center">
          <h2 class="text-2xl md:text-3xl font-bold">Create an account</h2>
          <p class="mt-2 text-sm md:text-base text-gray-400">Enter your email below to create your account</p>
        </div>

        <!-- Formulaire -->
        <form @submit="onSubmitSignUp" class="space-y-6">
          <div class="space-y-4">
            <div>
              <Label class="sr-only" for="email-signup">Email</Label>
              <Input v-model="emailSignup" id="email-signup" placeholder="name@example.com" type="email"
                auto-capitalize="none" auto-complete="email" auto-correct="off" :disabled="isLoadingSignUp"
                class="w-full px-4 py-2 rounded-md border border-gray-700 bg-gray-800"
              />
            </div>
            <div>
              <Label class="sr-only" for="username-signup">Username</Label>
              <Input v-model="usernameSignup" id="username-signup" placeholder="Enter your username" type="text"
                auto-capitalize="none" auto-complete="username" auto-correct="off" :disabled="isLoadingSignUp"
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

          <!-- Séparateur -->
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <span class="w-full border-t border-gray-600"></span>
            </div>
            <div class="relative flex justify-center text-xs uppercase">
              <span class="px-2 bg-gray-900 text-gray-400">Or continue with</span>
            </div>
          </div>
        </form>

        <!-- Conditions générales -->
        <p class="text-xs text-center text-gray-500">
          <input type="checkbox" id="agree-signup" v-model="isCheckedSignUp"
            class="form-checkbox h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            :disabled="isLoadingSignUp"
          />
          By clicking continue, you agree to our
          <a href="#" class="underline">Terms of Service</a> and
          <a href="#" class="underline">Privacy Policy</a>.
        </p>

        <!-- Message d'erreur -->
        <p v-if="errorMessageSignUp" class="text-red-500 text-sm text-center">
          {{ errorMessageSignUp }}
        </p>
      </div>
    </div>
  </div>
</template>

