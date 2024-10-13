<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getWorkingTimes } from '../api/apiWorkingTime';
import { useUserStore } from './store/userStore';

const workingtime = ref<any>(null);
const workDays = ref<any[]>([]);

const userStore = useUserStore();

onMounted(async () => {
  workingtime.value = await getWorkingTimes(userStore.user);
  // console.log(workingtime.value);

  workDays.value = workingtime.value.map(entry => {
    const { durationFormatted } = calculateDuration(entry.start, entry.end);
    return {
      date: entry.name,
      start: entry.start.split('T')[1].slice(0, 5), // Heure de début (HH:MM)
      end: entry.end.split('T')[1].slice(0, 5), // Heure de fin (HH:MM)
      durationFormatted,
    };
  });
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
    durationNumeric: durationInMinutes / 60,
    durationFormatted: `${hours}h ${minutes}m`,
  };
}
</script>

<template>
  <div class="space-y-4">
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
