<script setup lang="ts">
import { ref } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { loginUser } from '@/api/apiUser'
import router from '@/router'

const isLoading = ref(false)
const errorMessage = ref('')
const email = ref('')
const password = ref('')
const isChecked = ref(false)

async function onSubmit(event: Event): Promise<void> {
  event.preventDefault()
  errorMessage.value = ''

  if (!isChecked.value) {
    errorMessage.value = "You haven't accepted our Terms of Service and Privacy Policy."
    return
  }

  isLoading.value = true

  try {
    const response = await loginUser(email.value, password.value)
    if (response.status === 200) {
      sessionStorage.setItem('access_token', response.data.access_token)
      sessionStorage.setItem('refresh_token', response.data.refresh_token)
      router.push({ name: 'clock' })
      return
    }
    if (response.data?.errors) {
      errorMessage.value = response.data.errors
      return
    }
    errorMessage.value = 'An error occurred during sign in.'
  } catch {
    errorMessage.value = 'An error occurred during sign in.'
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-page__header">
      <h2 class="login-page__title">Sign In</h2>
      <p class="login-page__description">Enter your email below to sign in</p>
    </div>

    <form class="login-page__form" @submit="onSubmit">
      <div class="login-page__fields">
        <div class="login-page__field">
          <Label class="sr-only" for="login-email">Email</Label>
          <Input
            id="login-email"
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
        <div class="login-page__field">
          <Label class="sr-only" for="login-password">Password</Label>
          <Input
            id="login-password"
            v-model="password"
            placeholder="Enter your password"
            type="password"
            auto-capitalize="none"
            auto-complete="current-password"
            auto-correct="off"
            :disabled="isLoading"
            class="w-full"
          />
        </div>
        <Button class="w-full" :disabled="isLoading" type="submit">
          {{ isLoading ? 'Signing in...' : 'Sign In' }}
        </Button>
      </div>
    </form>

    <div class="login-page__terms">
      <label class="login-page__checkbox-label" for="agree-login">
        <input
          id="agree-login"
          v-model="isChecked"
          type="checkbox"
          class="login-page__checkbox"
          :disabled="isLoading"
        />
        <span>
          By clicking continue, you agree to our
          <a href="#" class="login-page__link">Terms of Service</a> and
          <a href="#" class="login-page__link">Privacy Policy</a>.
        </span>
      </label>
    </div>

    <p v-if="errorMessage" class="login-page__error" role="alert">
      {{ errorMessage }}
    </p>

    <div class="login-page__footer">
      <p class="login-page__footer-text">
        Don't have an account?
        <router-link to="/register" class="login-page__link">Sign Up</router-link>
      </p>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.login-page__header {
  text-align: center;
}

.login-page__title {
  font-size: var(--text-xl);
  font-weight: var(--font-weight-semibold);
  color: hsl(var(--foreground));
  margin: 0 0 var(--space-1) 0;
}

.login-page__description {
  font-size: var(--text-sm);
  color: hsl(var(--muted-foreground));
  margin: 0;
}

.login-page__form {
  display: flex;
  flex-direction: column;
}

.login-page__fields {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.login-page__field {
  width: 100%;
}

.login-page__terms {
  text-align: center;
}

.login-page__checkbox-label {
  display: inline-flex;
  align-items: flex-start;
  gap: var(--space-2);
  font-size: var(--text-xs);
  color: hsl(var(--muted-foreground));
  cursor: pointer;
}

.login-page__checkbox {
  margin-top: 2px;
  flex-shrink: 0;
  accent-color: hsl(var(--primary));
}

.login-page__link {
  color: hsl(var(--primary));
  text-decoration: underline;
}

.login-page__link:hover {
  text-decoration: none;
}

.login-page__error {
  font-size: var(--text-sm);
  color: hsl(var(--color-danger));
  text-align: center;
  margin: 0;
  padding: var(--space-2) var(--space-3);
  background: hsl(var(--color-danger-light));
  border-radius: var(--radius-md);
}

.login-page__footer {
  text-align: center;
}

.login-page__footer-text {
  font-size: var(--text-sm);
  color: hsl(var(--muted-foreground));
  margin: 0;
}
</style>
