<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getWorkingTime } from '../api/apiWorkingTime';

const props = defineProps({
  user: {
    type: Object,
    required: true,
  },
});

// Données fictives pour les heures prévues (générées aléatoirement)
const generateFictiveData = () => {
  return Array.from({ length: 10 }, (_, i) => ({
    name: `Jour ${i + 1}`, // Placeholder pour les jours
    planned: Math.floor(Math.random() * 4) + 6, // Heures prévues entre 6 et 10
  }));
};

const workingtime = ref<any>(null);
const workDays = ref<any[]>([]);
const data = ref<any[]>([]);

onMounted(async () => {
  workingtime.value = await getWorkingTime(1);
  console.log(workingtime.value);

  // Récupérer les données réelles et formater pour le graphique
  workDays.value = workingtime.value.data.map((entry, i) => {
    const { durationNumeric } = calculateDuration(entry.start, entry.end);
    console.log(`Jour ${i + 1}: ${durationNumeric}`);
    return {
      name: `Jour ${i + 1}`,
      real: durationNumeric,
    };
  });

  // Générer les données combinées pour le graphique
  const fictiveData = generateFictiveData();
  data.value = workDays.value.map((day, i) => ({
    name: day.name,
    planned: fictiveData[i]?.planned ?? 0, 
    real: day.real,
  }));
});

// Fonction pour calculer la durée en heures et minutes entre deux dates
function calculateDuration(start: string, end: string) {
  const startDate = new Date(start);
  const endDate = new Date(end);
  const durationInMilliseconds = endDate.getTime() - startDate.getTime();
  const durationInMinutes = Math.round(durationInMilliseconds / (1000 * 60));

  const hours = Math.floor(durationInMinutes / 60);
  const minutes = durationInMinutes % 60;

  return {
    durationNumeric: durationInMinutes / 60, // Durée en heures numériques
    durationFormatted: `${hours}h ${minutes}m`, // Formatée en texte
  };
}
</script>

<template>
  <BarChart
  :data="[
      { name: 'Jour 1', planned: 8, real: 7 },
      { name: 'Jour 2', planned: 9, real: 8 },
      { name: 'Jour 3', planned: 6, real: 5 },
    ]"
    index="name"
    :categories="['planned', 'real']"
    :y-formatter="(tick: number) => `${tick}h`"
  />
</template>
