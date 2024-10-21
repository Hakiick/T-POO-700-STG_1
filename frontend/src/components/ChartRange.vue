<script setup lang="ts">
import { type Ref, onMounted, ref, computed } from 'vue';
import { useUserStore } from './store/userStore';
import { getUser } from '../api/apiUser';
import { getWorkingTimeByDate } from '../api/apiWorkingTime';
import { getClocksFromUser } from '../api/apiClock';
import { getChartComponent, currentChartType, chartTypes } from '../manager/chartManager';
import { Popover, PopoverContent, PopoverTrigger } from './ui/popover';
import { RangeCalendar } from './ui/range-calendar';
import { cn } from '../lib/utils';
import { CalendarDate, DateFormatter, getLocalTimeZone } from '@internationalized/date';
import { CalendarIcon } from '@radix-icons/vue';
import { Tabs, TabsContent } from './ui/tabs';
import { getMonday, getSunday } from '../manager/DateUtils';
import type { DateRange } from 'radix-vue';
import { Button } from './ui/button';

// ============================
// Initialisation et variables globales
// ============================

const df = new DateFormatter('fr-FR', {
  dateStyle: 'medium',
});

const userStore = useUserStore();
const user = computed(() => userStore.user);
const workingtime = ref<any>(null);
const clockData = ref<any>(null);
const workDays = ref<any[]>([]);
const data = ref<any[]>([]);
const workingDataTable = ref<any[]>([]);

const value = ref({
  start: new CalendarDate(
    getMonday(new Date()).getFullYear(),
    getMonday(new Date()).getMonth() + 1,
    getMonday(new Date()).getDate()
  ),
  end: new CalendarDate(
    getSunday(new Date()).getFullYear(),
    getSunday(new Date()).getMonth() + 1,
    getSunday(new Date()).getDate()
  ),
}) as Ref<DateRange>;

// ============================
// Fonction exécutée au montage
// ============================

onMounted(async () => {
  if (!user.value) {
    user.value = await getUser(1);
  }
  
  // Récupérer les données au chargement initial
  await fetchData();
});

// ============================
// Fonction pour appliquer la nouvelle plage de dates
// ============================

async function applyDateRange() {
  await fetchData();
}

// ============================
// Fonction pour récupérer les données
// ============================

async function fetchData() {
  const startDate = new Date(
    value.value.start.year,
    value.value.start.month - 1,
    value.value.start.day
  );
  
  const endDate = new Date(
    value.value.end.year,
    value.value.end.month - 1,
    value.value.end.day + 1  // Ajout d'un jour ici
  );

  try {
    const workingTimeResponse = await getWorkingTimeByDate(user.value.id, startDate.toISOString(), endDate.toISOString());
    const clockDataResponse = await getClocksFromUser(user.value.id, startDate.toISOString(), endDate.toISOString());

    // Vérification des données récupérées, si absentes, définir des valeurs par défaut
    const workingTimeData = workingTimeResponse?.data?.data ?? [];
    const clockDataEntries = clockDataResponse?.data?.data ?? [];

    workingtime.value = workingTimeData;
    clockData.value = clockDataEntries;

    // Si aucune donnée n'est présente, afficher des valeurs par défaut
    const workingDays = workingTimeData.length ? aggregateWorkingTime(workingTimeData) : [{ name: 'Aucune donnée', planned: 0 }];
    const clockDays = clockDataEntries.length ? calculateWork(clockDataEntries) : [{ name: 'Aucune donnée', real: 0 }];

    workDays.value = workingDays.map(workDay => {
      const clockDay = clockDays.find(day => day.name === workDay.name);
      const realTime = clockDay ? clockDay.real : 0;

      return {
        name: workDay.name,
        planned: workDay.planned,
        real: realTime,
      };
    });

    data.value = workDays.value.length ? workDays.value : [{ name: 'Aucune donnée', planned: 0, real: 0 }];
    workingDataTable.value = createDataTable(workingTimeData, clockDataEntries);
  } catch (error) {
    console.error("Erreur lors de la récupération des données : ", error);
  }
}

// ============================
// Fonction pour créer un tableau de données
// ============================

function createDataTable(workingTimeEntries: any[], clockEntries: any[]) {

  let dataTable = [];

  workingTimeEntries.forEach((workingTime) => {
    const clockStart = clockEntries.find((clock) => clock.status === true && new Date(clock.time).toDateString() === new Date(workingTime.start).toDateString());
    const clockEnd = clockEntries.find((clock) => clock.status === false && new Date(clock.time).toDateString() === new Date(workingTime.end).toDateString());

    dataTable.push({
      date: new Date(workingTime.start).toLocaleDateString(),
      startTime: new Date(workingTime.start).toLocaleTimeString(),
      endTime: new Date(workingTime.end).toLocaleTimeString(),
      clockStart: clockStart ? new Date(clockStart.time).toLocaleTimeString() : 'N/A',  // Valeur par défaut N/A
      clockEnd: clockEnd ? new Date(clockEnd.time).toLocaleTimeString() : 'N/A'        // Valeur par défaut N/A
    });
  });

  // Si aucune donnée n'est présente
  if (!dataTable.length) {
    dataTable.push({
      date: 'Aucune donnée',
      startTime: 'N/A',
      endTime: 'N/A',
      clockStart: 'N/A',
      clockEnd: 'N/A',
    });
  }

  return dataTable;
}

// ============================
// Fonctions utilitaires pour l'agrégation des temps de travail et les calculs
// ============================

function aggregateWorkingTime(workingTimeEntries: any[]) {
  const aggregated: Record<string, { planned: number }> = {};

  workingTimeEntries.forEach(entry => {
    const formattedDate = formatDate(entry.start);
    const { durationNumeric } = calculateDuration(entry.start, entry.end);

    if (!aggregated[formattedDate]) {
      aggregated[formattedDate] = { planned: 0 };
    }
    aggregated[formattedDate].planned += durationNumeric;
  });

  return Object.keys(aggregated).map(name => ({
    name,
    planned: aggregated[name].planned,
  }));
}

function calculateWork(clockEntries: any[]) {
  if (!Array.isArray(clockEntries)) return [];

  const workByDate: Record<string, { real: number }> = {};
  let startTime: string | null = null;

  clockEntries.forEach(entry => {
    const formattedDate = formatDate(entry.time);

    if (entry.status) {
      startTime = entry.time;
    } else if (startTime) {
      const { durationNumeric } = calculateDuration(startTime, entry.time);

      if (!workByDate[formattedDate]) {
        workByDate[formattedDate] = { real: 0 };
      }

      workByDate[formattedDate].real += durationNumeric;
      startTime = null;
    }
  });

  return Object.keys(workByDate).map(date => ({
    name: date,
    real: workByDate[date].real,
  }));
}

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

function formatDate(dateString: string) {
  const date = new Date(dateString);
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');

  return `${day}/${month}`;
}

function formatHours(hours: number) {
  const h = Math.floor(hours);
  const m = Math.round((hours - h) * 60);
  return `${h}h ${m}m`;
}
</script>

<template>
  <Tabs default-value="monthly" class="space-y-4 h-full w-full">
    <TabsContent value="monthly" class="space-y-4 h-full w-full">
      <div class="grid gap-4 grid-cols-1 lg:grid-cols-10 h-full w-full mt-7">
        
        <!-- Section graphique - 70% largeur à gauche -->
        <div class="col-span-1 lg:col-span-6 space-y-4 h-full w-full">
          <div class="h-full w-full">
            <div class="flex items-center justify-center space-x-4 mb-10">
              <button
                v-for="type in chartTypes"
                :key="type"
                @click="currentChartType = type"
                class="px-4 py-2 text-white bg-blue-500 rounded hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-400"
              >
                {{ type }}
              </button>
            </div>

            <!-- Composant graphique dynamique -->
            <component
              :is="getChartComponent(currentChartType, data, 'name', ['planned', 'real'], ['#3498db', '#2ecc71']).component"
              v-bind="getChartComponent(currentChartType, data, 'name', ['planned', 'real'], ['#3498db', '#2ecc71']).props"
            />
          </div>
        </div>

        <!-- Section emploi du temps - 30% largeur à droite -->
        <div class="col-span-1 lg:col-span-4 h-full w-full space-y-4">
          <!-- Calendrier avec bouton d'application -->
          <div class="text-center mb-3">
            <Popover>
              <PopoverTrigger as-child>
                <Button
                  variant="outline"
                  :class="cn(
                    'w-full justify-start text-left font-normal',
                    !value && 'text-muted-foreground',
                  )"
                >
                  <CalendarIcon class="mr-2 h-4 w-4" />
                  <template v-if="value.start">
                    <template v-if="value.end">
                      {{ df.format(value.start.toDate(getLocalTimeZone())) }} - {{ df.format(value.end.toDate(getLocalTimeZone())) }}
                    </template>
                    <template v-else>
                      {{ df.format(value.start.toDate(getLocalTimeZone())) }}
                    </template>
                  </template>
                  <template v-else>
                    Pick a date
                  </template>
                </Button>
              </PopoverTrigger>
              <PopoverContent class="w-auto p-0">
                <RangeCalendar
                  v-model="value"
                  initial-focus
                  :number-of-months="2"
                  @update:start-value="(startDate) => value.start = startDate"
                />
              </PopoverContent>
            </Popover>
          </div>

          <!-- Bouton pour appliquer la plage de dates -->
          <div class="text-center mb-3">
            <Button @click="applyDateRange" class="bg-green-500 hover:bg-green-600 text-white">
              Appliquer
            </Button>
          </div>

          <!-- Emploi du temps -->
          <div class="text-center mb-3">
            <table class="w-full">
              <thead>
                <tr>
                  <th class="px-4 py-2 text-left">Date</th>
                  <th class="px-4 py-2 text-left">Heure de début</th>
                  <th class="px-4 py-2 text-left">Heure de fin</th>
                  <th class="px-4 py-2 text-left">Pointage de début</th>
                  <th class="px-4 py-2 text-left">Pointage de fin</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in workingDataTable" :key="index">
                  <td class="border px-4 py-2">{{ row.date }}</td>
                  <td class="border px-4 py-2">{{ row.startTime }}</td>
                  <td class="border px-4 py-2">{{ row.endTime }}</td>
                  <td class="border px-4 py-2">{{ row.clockStart }}</td>
                  <td class="border px-4 py-2">{{ row.clockEnd }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </TabsContent>
  </Tabs>
</template>
