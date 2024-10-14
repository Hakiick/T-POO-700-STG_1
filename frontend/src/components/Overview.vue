<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getWorkingTime } from '../api/apiWorkingTime';
import { getClockFromUser } from '../api/apiClock';
import { BarChart } from '../components/ui/chart-bar';

const props = defineProps({
  user: {
    type: Object,
    required: true,
  },
});

const workingtime = ref<any>(null);
const clockData = ref<any>(null);
const workDays = ref<any[]>([]);
const data = ref<any[]>([]);

onMounted(async () => {
  // Récupération des données de working time et clock
  workingtime.value = await getWorkingTime(1);
  clockData.value = await getClockFromUser(1);
  
  // Vérification si clockData contient un tableau
  const clockEntries = clockData.value.data;
  if (!Array.isArray(clockEntries)) {
    console.error(clockEntries);
    return;
  }
  
  console.log("Clock Data:", clockEntries);

  // Grouper les données de Clock par jour et calculer la durée réelle
  const groupedClockData = groupClockDataByDay(clockEntries);
  
  // Récupérer les données réelles et plannifiées
  workDays.value = workingtime.value.data.map((entry) => {
    const plannedHours = calculateDuration(entry.start, entry.end).durationNumeric;
    const formattedDate = formatDate(entry.start);
    const realHours = groupedClockData[formattedDate] || 0; 
    
    return {
      name: formattedDate,
      planned: plannedHours,
      real: realHours,
    };
  });

  // Assignation des données pour le graphique
  data.value = workDays.value;
});

// Fonction pour grouper les données de Clock par jour et calculer la durée travaillée
function groupClockDataByDay(clockEntries: any[]) {
  const groupedData: { [key: string]: number } = {};
  
  let startTime: Date | null = null;

  clockEntries.forEach((entry) => {
    const date = formatDate(entry.time); // Extraire le jour (dd/MM)
    
    if (!groupedData[date]) {
      groupedData[date] = 0; // Initialiser la durée à 0
    }

    if (entry.status) {
      startTime = new Date(entry.time); // Marquer l'heure de début
    } else if (startTime) {
      const endTime = new Date(entry.time);
      const duration = calculateDurationBetweenTimes(startTime, endTime);
      groupedData[date] += duration; // Ajouter la durée à la journée
      startTime = null; // Réinitialiser l'heure de début
    }
  });

  return groupedData;
}

// Fonction pour formater les dates au format dd/MM
function formatDate(dateString: string) {
  const date = new Date(dateString);
  return date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' });
}

// Fonction pour calculer la durée en heures entre deux dates
function calculateDurationBetweenTimes(start: Date, end: Date) {
  const durationInMilliseconds = end.getTime() - start.getTime();
  const durationInMinutes = Math.round(durationInMilliseconds / (1000 * 60));
  return durationInMinutes / 60;
}

// Fonction pour calculer la durée entre deux dates de WorkingTime
function calculateDuration(start: string, end: string) {
  const startDate = new Date(start);
  const endDate = new Date(end);
  const durationInMilliseconds = endDate.getTime() - startDate.getTime();
  const durationInMinutes = Math.round(durationInMilliseconds / (1000 * 60));

  return {
    durationNumeric: durationInMinutes / 60,
  };
}
</script>

<template>
  <BarChart
    :data="data"
    index="name"
    :categories="['planned', 'real']"
    :colors="['#3498db', '#2ecc71']" 
    :y-formatter="(tick) => `${tick}h`" 
    showGridLine
  />
</template>
