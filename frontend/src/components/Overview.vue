<script setup lang="ts">

import { onMounted, ref } from 'vue';
import { getWorkingTimes } from '../api/apiWorkingTime';
import { BarChart } from '../components/ui/chart-bar';
import { useUserStore } from './store/userStore';

const userStore = useUserStore();

const workingtime = ref<any>(null);
const workDays = ref<any[]>([]);
const data = ref<any[]>([]);

onMounted(async () => {
  // console.log(userStore.user);
  workingtime.value = await getWorkingTimes(userStore.user);
  // console.log("working time list", workingtime.value);

  // Récupérer les données réelles et formater pour le graphique
  workDays.value = workingtime.value.map((entry) => {
    const { durationNumeric } = calculateDuration(entry.start, entry.end);
    const formattedDate = formatDate(entry.start); // Formater la date en dd/MM

    return {
      name: formattedDate,
      real: durationNumeric,
    };
  });

  // Générer les données fictives
  const fictiveData = generateFictiveData();

  // Combiner les données réelles et plannifiées
  data.value = workDays.value.map((day, i) => ({
    name: day.name,
    planned: fictiveData[i]?.planned ?? 0,
    real: day.real,
  }));
});

// Fonction pour formater les dates au format dd/MM
function formatDate(dateString: string) {
  const date = new Date(dateString);
  return date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' });
}

// Fonction pour calculer la durée entre deux dates
function calculateDuration(start: string, end: string) {
  const startDate = new Date(start);
  const endDate = new Date(end);
  const durationInMilliseconds = endDate.getTime() - startDate.getTime();
  const durationInMinutes = Math.round(durationInMilliseconds / (1000 * 60));

  return {
    durationNumeric: durationInMinutes / 60, // Durée en heures numériques
  };
}

// Données fictives pour les heures prévues
function generateFictiveData() {
  return Array.from({ length: 10 }, (_, i) => ({
    name: `Jour ${i + 1}`,
    planned: Math.floor(Math.random() * 4) + 6, // Heures prévues entre 6 et 10
  }));
}
</script>

<template>
  <BarChart :data="data" index="name" :categories="['planned', 'real']" :colors="['#3498db', '#2ecc71']"
    :y-formatter="(tick) => `${tick}h`" showGridLine />
</template>
