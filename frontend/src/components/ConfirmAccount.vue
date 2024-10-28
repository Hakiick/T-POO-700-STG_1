<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { useRoute } from 'vue-router';
import router from '@/router';
import { confirmMail } from '../api/apiUser';

const route = useRoute();
const params = route.query;
const confirm_token = params.token;

const error = ref<string>('')

onMounted(async () => {
  if (confirm_token) {
    const resp = await confirmMail(confirm_token)
    if (resp.status === 200) {
      router.push({ name: 'login' })
    } else {
      error.value = 'Invalid token'
    }
  } else {
    error.value = 'Invalid token'
  }
})

</script>
<template>
  <div class="flex w-screen h-screen items-center gap-8 justify-center flex-col">
    <h2 if="error" class="text-red-500">{{ error }}</h2>
  </div>
</template>
