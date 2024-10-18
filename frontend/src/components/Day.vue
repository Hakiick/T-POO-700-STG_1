<script setup lang="ts">
import { defineProps } from 'vue';
import { getChartComponent, currentChartType, chartTypes } from '../manager/chartManager';

const props = defineProps<{
  oneDayChart: Object | null;
}>();

console.log(props.oneDayChart);

</script>

<template>
  <div>
    <h2>Graphique du {{ oneDayChart }}</h2>
    <!--<h2>Heures de travail pour le {{ targetDate }}</h2>-->
    <div>

    </div>

    <component
      :is="getChartComponent(currentChartType, oneDayChart, 'name', ['planned', 'real'], ['#3498db', '#2ecc71']).component"
      v-bind="getChartComponent(currentChartType, oneDayChart, 'name', ['planned', 'real'], ['#3498db', '#2ecc71']).props"
    />
  </div>
</template>

