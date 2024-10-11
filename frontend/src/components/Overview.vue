<template>
  <div id="chartContainer" style="height: 370px; width: 100%;"></div>
</template>

<script setup lang="ts">
// Import du composant onMounted
import { onMounted } from 'vue';

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

// Fonction pour formater la date en 'dd/MM'
function formatDate(dateString: string) {
  const date = new Date(dateString);
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  return `${day}/${month}`;
}

// Données fictives pour les 10 derniers jours avec formatage de la date
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

// Transforme les données pour le graphique
const data = rawData.map(entry => {
  const { durationNumeric, durationFormatted } = calculateDuration(entry.start, entry.end);
  return {
    name: formatDate(entry.name),
    duration: durationNumeric,
    durationFormatted
  };
});

// Utilisation de CanvasJS pour créer le graphique une fois le composant monté
onMounted(() => {
  var chart = new CanvasJS.Chart("chartContainer", {
    animationEnabled: true,
    title: {
      text: "Durée de travail par jour (en heures)"
    },
    axisY: {
      title: "Durée (heures)",
      includeZero: true
    },
    data: [{
      type: "column", // Type de graphique
      dataPoints: data.map(d => ({
        label: d.name,
        y: d.duration
      }))
    }]
  });

  chart.render();
});
</script>
