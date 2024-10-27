<script setup lang="ts">
import { ref } from 'vue';
import { Button } from './ui/button'
import { Input } from './ui/input'
import { useRoute } from 'vue-router';
import { resetPassword } from '../api/apiUser'
import router from '@/router';

const route = useRoute();
const params = route.query;
const reset_token = params.token;

const newPassword = ref<string>('')
const error = ref<string>('')

async function hashPassword(password: string) {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return bufferToHex(hash);
}

function bufferToHex(buffer: ArrayBuffer) {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

const handleNewPassword = async () => {
  console.log(newPassword.value)
  if (newPassword.value.length < 12) {
    error.value = 'Password must be at least 12 characters'
    return
  }

  const response = await resetPassword(await hashPassword(newPassword.value), reset_token)
  if (response.status === 200) {
    router.push({ name: 'login' })
  } else {
    error.value = "an error occured"
  }
}

</script>
<template>
  <div class="flex w-screen h-screen items-center gap-8 justify-center flex-col">
    <h2 class="text-2xl font-bold">New Password</h2>
    <Input v-model="newPassword" id="password" type="text" placeholder="12 char 1 maj 1 min 1 num 1 spec"
      class="max-w-sm" />
    <Button @click="handleNewPassword" type="submit">
      Validate
    </Button>
    <h2 if="error" class="text-red-500">{{ error }}</h2>
  </div>
</template>
