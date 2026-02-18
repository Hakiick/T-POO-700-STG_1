<script setup lang="ts">
import { ref } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { createUser } from '@/api/apiUser'
import router from '@/router'

const isLoading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const email = ref('')
const password = ref('')
const isChecked = ref(false)

async function onSubmit(event: Event): Promise<void> {
  event.preventDefault()
  errorMessage.value = ''
  successMessage.value = ''

  if (!isChecked.value) {
    errorMessage.value = "You haven't accepted our Terms of Service and Privacy Policy."
    return
  }

  isLoading.value = true

  try {
    const response = await createUser(email.value, email.value, password.value)
    if (response.status === 201) {
      successMessage.value = 'Account created! Please check your email to confirm your account.'
      setTimeout(() => {
        router.push({ name: 'login' })
      }, 3000)
      return
    }
    if (response.data?.errors) {
      errorMessage.value = response.data.errors
      return
    }
    errorMessage.value = 'An error occurred during registration.'
  } catch {
    errorMessage.value = 'An error occurred during registration.'
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="register-page">
    <div class="register-page__header">
      <h2 class="register-page__title">Create an account</h2>
      <p class="register-page__description">Enter your email below to create your account</p>
    </div>

    <form class="register-page__form" @submit="onSubmit">
      <div class="register-page__fields">
        <div class="register-page__field">
          <Label class="sr-only" for="register-email">Email</Label>
          <Input
            id="register-email"
            v-model="email"
            placeholder="name@example.com"
            type="email"
            auto-capitalize="none"
            auto-complete="email"
            auto-correct="off"
            :disabled="isLoading"
            class="w-full"
          />
        </div>
        <div class="register-page__field">
          <Label class="sr-only" for="register-password">Password</Label>
          <Input
            id="register-password"
            v-model="password"
            placeholder="Enter your password"
            type="password"
            auto-capitalize="none"
            auto-complete="new-password"
            auto-correct="off"
            :disabled="isLoading"
            class="w-full"
          />
        </div>
        <Button class="w-full" :disabled="isLoading" type="submit">
          {{ isLoading ? 'Creating account...' : 'Sign Up' }}
        </Button>
      </div>
    </form>

    <div class="register-page__terms">
      <label class="register-page__checkbox-label" for="agree-register">
        <input
          id="agree-register"
          v-model="isChecked"
          type="checkbox"
          class="register-page__checkbox"
          :disabled="isLoading"
        />
        <span>
          By clicking continue, you agree to our
          <a href="#" class="register-page__link">Terms of Service</a> and
          <a href="#" class="register-page__link">Privacy Policy</a>.
        </span>
      </label>
    </div>

    <p v-if="errorMessage" class="register-page__error" role="alert">
      {{ errorMessage }}
    </p>

    <p v-if="successMessage" class="register-page__success" role="status">
      {{ successMessage }}
    </p>

    <div class="register-page__footer">
      <p class="register-page__footer-text">
        Already have an account?
        <router-link to="/login" class="register-page__link">Sign In</router-link>
      </p>
    </div>
  </div>
</template>

<style scoped>
.register-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.register-page__header {
  text-align: center;
}

.register-page__title {
  font-size: var(--text-xl);
  font-weight: var(--font-weight-semibold);
  color: hsl(var(--foreground));
  margin: 0 0 var(--space-1) 0;
}

.register-page__description {
  font-size: var(--text-sm);
  color: hsl(var(--muted-foreground));
  margin: 0;
}

.register-page__form {
  display: flex;
  flex-direction: column;
}

.register-page__fields {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.register-page__field {
  width: 100%;
}

.register-page__terms {
  text-align: center;
}

.register-page__checkbox-label {
  display: inline-flex;
  align-items: flex-start;
  gap: var(--space-2);
  font-size: var(--text-xs);
  color: hsl(var(--muted-foreground));
  cursor: pointer;
}

.register-page__checkbox {
  margin-top: 2px;
  flex-shrink: 0;
  accent-color: hsl(var(--primary));
}

.register-page__link {
  color: hsl(var(--primary));
  text-decoration: underline;
}

.register-page__link:hover {
  text-decoration: none;
}

.register-page__error {
  font-size: var(--text-sm);
  color: hsl(var(--color-danger));
  text-align: center;
  margin: 0;
  padding: var(--space-2) var(--space-3);
  background: hsl(var(--color-danger-light));
  border-radius: var(--radius-md);
}

.register-page__success {
  font-size: var(--text-sm);
  color: hsl(var(--color-success));
  text-align: center;
  margin: 0;
  padding: var(--space-2) var(--space-3);
  background: hsl(var(--color-success-light));
  border-radius: var(--radius-md);
}

.register-page__footer {
  text-align: center;
}

.register-page__footer-text {
  font-size: var(--text-sm);
  color: hsl(var(--muted-foreground));
  margin: 0;
}
</style>
