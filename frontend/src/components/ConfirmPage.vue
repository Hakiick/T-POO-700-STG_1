<script lang="ts">
import router from '../router';
import { confirmUser } from './apiUser';
import { defineComponent, ref, onMounted } from 'vue';

const isConfirmed = ref<boolean | null>(null);

const token = route.params.token as string;

onMounted(async () => {
  const result = await confirmUser(token);
  isConfirmed.value = result;
});

const redirectToLogin = () => {
  router.push('/login');
};

</script>

<template>
  <div>
    <div v-if="isConfirmed === null">
      <h1>Confirmation en cours...</h1>
    </div>
    <div  v-if="isConfirmed">
      <h1>Confirmation réussie !</h1>
      <button @click="redirectToLogin">Aller à la page de connexion</button>
    </div>
    <div v-else>
      <h1>Erreur de confirmation. Veuillez réessayer.</h1>
    </div>
  </div>
</template>