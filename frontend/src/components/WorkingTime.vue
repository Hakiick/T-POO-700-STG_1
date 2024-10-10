<template>
  <div class="space-y-4">
    <h2 class="text-lg font-semibold">Derniers Jours de Pointage</h2>
    <div v-for="(day, index) in workDays" :key="index" class="flex items-center justify-between">
      <div class="flex flex-col">
        <span class="text-sm font-medium">{{ day.start }}</span>
        <span class="text-xs text-muted-foreground">{{ day.date }}</span>
      </div>
      <div class="mx-4 font-medium">
        {{ day.durationFormatted }} 
      </div>
      <div class="flex flex-col">
        <span class="text-sm font-medium">{{ day.end }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

// Importer les données et la logique d'Overview.vue
const rawData = [
  { name: '2024-10-07', start: '2024-10-07T09:00:00Z', end: '2024-10-07T16:00:00Z' },
  { name: '2024-10-06', start: '2024-10-06T09:00:00Z', end: '2024-10-06T15:00:00Z' },
  { name: '2024-10-05', start: '2024-10-05T09:00:00Z', end: '2024-10-05T18:00:00Z' },
  { name: '2024-10-04', start: '2024-10-04T09:00:00Z', end: '2024-10-04T17:00:00Z' },
  { name: '2024-10-03', start: '2024-10-03T09:00:00Z', end: '2024-10-03T17:30:00Z' },
  { name: '2024-10-02', start: '2024-10-02T09:00:00Z', end: '2024-10-02T17:00:00Z' },
  { name: '2024-10-01', start: '2024-10-01T09:00:00Z', end: '2024-10-01T17:50:00Z' },
  { name: '2024-09-30', start: '2024-09-30T09:00:00Z', end: '2024-09-30T17:00:00Z' },
  { name: '2024-09-29', start: '2024-09-29T09:00:00Z', end: '2024-09-29T15:55:00Z' },
  { name: '2024-09-28', start: '2024-09-28T09:00:00Z', end: '2024-09-28T17:00:00Z' },
];

// Fonction pour calculer la durée en heures et minutes entre deux dates
function calculateDuration(start: string, end: string) {
  const startDate = new Date(start);
  const endDate = new Date(end);
  const durationInMilliseconds = endDate.getTime() - startDate.getTime();
  const durationInMinutes = Math.round(durationInMilliseconds / (1000 * 60));

  const hours = Math.floor(durationInMinutes / 60);
  const minutes = durationInMinutes % 60;

  return {
    durationNumeric: durationInMinutes / 60,
    durationFormatted: `${hours}h ${minutes}m`,
  };
}

// Transforme les données pour afficher les horaires
const workDays = ref(rawData.map(entry => {
  const { durationFormatted } = calculateDuration(entry.start, entry.end);
  return {
    date: entry.name,
    start: entry.start.split('T')[1].slice(0, 5), // Heure de début (HH:MM)
    end: entry.end.split('T')[1].slice(0, 5), // Heure de fin (HH:MM)
    durationFormatted,
  };
}));
</script>

<style scoped>
/* Ajoutez votre style ici si nécessaire */
</style>
