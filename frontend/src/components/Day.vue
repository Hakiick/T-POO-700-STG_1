<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { defineProps } from 'vue';
import { useUserStore } from './store/userStore';
import { getUser } from '../api/apiUser';
import { getChartComponent, currentChartType, chartTypes } from '../manager/chartManager';

// Définir la prop pour recevoir la valeur
const props = defineProps<{
  oneDateValue: Object | null;
  workingtime: Object | null,
  clockData: Object | null
}>();

console.log(props.workingtime, props.clockData);

const userStore = useUserStore();
const user = ref(userStore.user);

const workDays = ref<any[]>([]);
const data = ref<any[]>([]);

onMounted(async () => {

  if (!user.value) {
    user.value = await getUser(1);
  }

  // Transformation et fusion des données de working time et clock
  const workingDays = aggregateWorkingTime(workingtime.value.data.data);
  const clockDays = calculateWork(clockData.value.data.data);

  // Fusion des jours travaillés avec les données des heures planifiées et réelles
  workDays.value = workingDays.map(workDay => {
    const clockDay = clockDays.find(day => day.name === workDay.name);
    const realTime = clockDay ? clockDay.real : 0;

    return {
      name: workDay.name,
      planned: workDay.planned,
      real: realTime,
    };
  });

  // Préparation des données pour les graphiques
  data.value = workDays.value.map(day => ({
    name: day.name,
    planned: day.planned,
    real: day.real,
  }));
});

// Fonction pour agréger les données de working time par date
function aggregateWorkingTime(workingTimeEntries: any[], targetDate: string) {
  const aggregated: Record<string, { planned: number }> = {};

  workingTimeEntries.forEach(entry => {
    const formattedDate = formatDate(entry.start);
    
    // Filtrer pour la date cible
    if (formattedDate === targetDate) {
      const { durationNumeric } = calculateDuration(entry.start, entry.end);

      if (!aggregated[formattedDate]) {
        aggregated[formattedDate] = { planned: 0 };
      }
      aggregated[formattedDate].planned += durationNumeric;
    }
  });

  // Convertir le Record en tableau
  return Object.keys(aggregated).map(name => ({
    name,
    planned: aggregated[name].planned,
  }));
}

// Fonction pour calculer le temps travaillé entre un statut true et false pour chaque journée
function calculateWork(clockEntries: any[], targetDate: string) {
  const workByDate: Record<string, { real: number }> = {};
  let startTime: string | null = null;

  clockEntries.forEach(entry => {
    const formattedDate = formatDate(entry.time);

    // Filtrer pour la date cible
    if (formattedDate === targetDate) {
      // Si c'est une entrée 'true', on enregistre le début
      if (entry.status) {
        startTime = entry.time;
      } 
      // Si c'est une entrée 'false', on calcule la durée entre start et end
      else if (startTime) {
        const { durationNumeric } = calculateDuration(startTime, entry.time);
        
        // Ajout de la durée à la date correspondante
        if (!workByDate[formattedDate]) {
          workByDate[formattedDate] = { real: 0 };
        }

        workByDate[formattedDate].real += durationNumeric;
        startTime = null; // Réinitialiser pour le prochain cycle
      }
    }
  });

  // Convertir le Record en tableau
  return Object.keys(workByDate).map(date => ({
    name: date,
    real: workByDate[date].real,
  }));
}

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

// Fonction pour formater une date au format dd/MM
function formatDate(dateString: string) {
  const date = new Date(dateString);
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');

  return `${day}/${month}`;
}
</script>

<template>
  <div>
    <h2>Graphique du {{ oneDateValue }}</h2>
    <!--<h2>Heures de travail pour le {{ targetDate }}</h2>-->
    <div>
      <p>Heures planifiées: {{ data[0]?.planned }} heures</p>
      <p>Heures réelles: {{ data[0]?.real }} heures</p>
    </div>

    <component
      :is="getChartComponent(currentChartType, data, 'name', ['planned', 'real'], ['#3498db', '#2ecc71']).component"
      v-bind="getChartComponent(currentChartType, data, 'name', ['planned', 'real'], ['#3498db', '#2ecc71']).props"
    />
  </div>
</template>

