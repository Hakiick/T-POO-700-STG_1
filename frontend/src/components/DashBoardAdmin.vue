<script setup lang="ts">
import MainNav from './MainNav.vue';
import UserNav from './UserNav.vue';
import TeamSwitcher from './TeamSwitcher.vue';
import moment from 'moment';

import { onMounted, ref, computed } from 'vue';
import { useUserStore } from './store/userStore';
import { useTeamStore } from "./store/teamStore.ts";
import { getAllUser } from '../api/apiUser';
import { getAllUsersFromTeam } from "../api/apiManage.ts";
import { getWorkingTimeByDate } from '../api/apiWorkingTime';
import { getClocksFromUser } from '../api/apiClock';
import { Popover, PopoverContent, PopoverTrigger } from './ui/popover';
import { CalendarDate, DateFormatter, type DateValue, getLocalTimeZone } from '@internationalized/date';
import { getMonday, getSunday } from '../manager/DateUtils';
import { CalendarIcon } from '@radix-icons/vue';
import { Button } from './ui/button';
import { RangeCalendar } from './ui/range-calendar';
import { Calendar } from './ui/calendar';
import { cn } from '../lib/utils';

// ============================
// Initialisation et variables globales
// ============================

const teamStore = useTeamStore();
const userStore = useUserStore();
const user = computed(() => userStore.user);
const workingDataTable = ref<any[]>([]);
const isDesktop = ref(false);
const usersList = ref<any[]>([]);

const checkIsDesktop = () => {
  isDesktop.value = window.innerWidth >= 1024;
};

const df = new DateFormatter('en-US', {
  dateStyle: 'long',
});

const formattedDate = computed(() => {
  return moment().format('dddd D MMMM');
});
const formattedTime = computed(() => {
  return moment().format('HH[h] mm[m]');
});

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

onMounted(() => {
  checkIsDesktop();
  window.addEventListener('resize', checkIsDesktop);

  fetchAllUsers();
});


// ============================
// Fonction pour Apply la nouvelle plage de dates
// ============================

async function applyDate() {
  await fetchData();
}

// ============================
// Fonction pour récupérer les données
// ============================

async function fetchData() {
  if (!value.value) {
    console.error("Aucune date sélectionnée");
    return;
  }

  if (!user.value || !user.value.id) {
    console.error("Erreur : utilisateur introuvable ou ID manquant");
    return;
  }

  const startDate = new Date(
    value.value.start.year,
    value.value.start.month - 1,
    value.value.start.day
  );
  
  const endDate = new Date(
    value.value.end.year,
    value.value.end.month - 1,
    value.value.end.day + 1
  );

  try {
    // Fetch all users
    usersList.value = await fetchAllUsers();

    // Initialise le tableau avant de le remplir
    workingDataTable.value = [];
    console.log(startDate, endDate)
    for (const user of usersList.value) {
      const workingTimeResponse = await getWorkingTimeByDate(user.id, startDate.toISOString(), endDate.toISOString());
      const clockDataResponse = await getClocksFromUser(user.id, startDate.toISOString(), endDate.toISOString());

      const workingTimeData = workingTimeResponse?.data?.data ?? [];
      const clockDataEntries = clockDataResponse?.data?.data ?? [];

      // Ajouter les données au tableau
      workingDataTable.value.push(...createDataTable(workingTimeData, clockDataEntries, user));
    }
  } catch (error) {
    console.error("Erreur lors de la récupération des données : ", error);
  }
}

// Fonction pour récupérer tous les utilisateurs
async function fetchAllUsers() {
  const team = teamStore.currentTeam;
  if (team?.id === -1) {
    return await getAllUser();
  } else {
    return await getAllUsersFromTeam(teamStore.currentTeam);
  }
}

// ============================
// Fonction pour créer un tableau de données
// ============================

function createDataTable(workingTimeEntries, clockEntries, user) {
  let dataTable = [];

  // Grouper par date pour simplifier l'affichage
  const groupedEntries = {};

  workingTimeEntries.forEach((entry) => {
    const date = new Date(entry.start).toLocaleDateString('fr-FR');
    if (!groupedEntries[date]) {
      groupedEntries[date] = { workingTime: [], clockData: [] };
    }
    groupedEntries[date].workingTime.push(entry);
  });

  clockEntries.forEach((entry) => {
    const date = new Date(entry.time).toLocaleDateString('fr-FR');
    if (!groupedEntries[date]) {
      groupedEntries[date] = { workingTime: [], clockData: [] };
    }
    groupedEntries[date].clockData.push(entry);
  });

  // Construire le tableau de données pour chaque date
  Object.keys(groupedEntries).forEach((date) => {
    const workingTimeForDate = groupedEntries[date].workingTime.slice(0, 2);
    const clockDataForDate = groupedEntries[date].clockData;

    const clockStartEntries = clockDataForDate.filter(entry => entry.status === true).slice(0, 2);
    const clockEndEntries = clockDataForDate.filter(entry => entry.status === false).slice(0, 2);

    workingTimeForDate.forEach((workingTime, index) => {
      dataTable.push({
        username: user.username || 'N/A',
        date,
        startTime: workingTime.start ? new Date(workingTime.start).toLocaleTimeString('fr-FR', { hour: "2-digit", minute: "2-digit", timeZone: 'UTC' }) : 'N/A',
        endTime: workingTime.end ? new Date(workingTime.end).toLocaleTimeString('fr-FR', { hour: "2-digit", minute: "2-digit", timeZone: 'UTC' }) : 'N/A',
        clockStart: clockStartEntries[index] ? new Date(clockStartEntries[index].time).toLocaleTimeString('fr-FR', { hour: "2-digit", minute: "2-digit", timeZone: 'UTC' }) : 'N/A',
        clockEnd: clockEndEntries[index] ? new Date(clockEndEntries[index].time).toLocaleTimeString('fr-FR', { hour: "2-digit", minute: "2-digit", timeZone: 'UTC' }) : 'N/A'
      });
    });
  });

  if (!dataTable.length) {
    dataTable.push({
      username: 'Aucune donnée',
      date: 'N/A',
      startTime: 'N/A',
      endTime: 'N/A',
      clockStart: 'N/A',
      clockEnd: 'N/A',
    });
  }

  return dataTable;
}

</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-10 lg:min-h-screen">
    <!-- NavBar -->
    <div class="col-span-1 lg:col-span-1/10 border-r-4 relative">
      <!-- UserNav for Mobile -->
      <div class="pt-4 pl-4" v-show="!isDesktop">
        <UserNav :user="user" />
      </div>
      <h1 class="font-bold flex justify-center -mt-8 lg:mt-3">
        Time Manager
      </h1>
      <!-- UserNav for Desktop -->
      <div v-show="isDesktop" class="flex items-center justify-center py-8 border-b-4">
        <UserNav :user="user" />
      </div>
      <!-- MainNav for Desktop -->
      <div class="flex items-center justify-center pb-4 border-b-4 hidden lg:block">
        <MainNav class="mx-4" />
      </div>
      <!-- MainNav for Mobile -->
      <div class="absolute top-4 right-4 lg:hidden">
        <MainNav class="mx-4" />
      </div>
      <div class="text-center items-center justify-center p-8 border-b-4">
        <p>{{ formattedDate }}</p>
        <p class="text-xl font-bold">{{ formattedTime }}</p>
      </div>
    </div>

    <div class="col-span-1 lg:col-span-9 h-full w-full space-y-4 pt-5">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="flex justify-center">
          <TeamSwitcher @teamChange="fetchAllUsers" class="w-full text-center"/>
        </div>
        <div>
          <!-- Calendrier avec bouton d'application -->
          <div class="text-center flex justify-center mb-3">
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
          <div class="text-center mb-3">
            <Button @click="applyDate" class="bg-green-500 hover:bg-green-600 text-white">
              Apply
            </Button>
          </div>
        </div>
      </div>
      
      <!-- Emploi du temps -->
      <div class="text-center mb-3 overflow-x-auto">
        <table class="w-full table-auto border-collapse">
          <thead>
            <tr>
              <th class="px-4 py-2 text-left">Username</th>
              <th class="px-4 py-2 text-left">Date</th>
              <th class="px-4 py-2 text-left">Work In</th>
              <th class="px-4 py-2 text-left">Work Out</th>
              <th class="px-4 py-2 text-left">Clock In</th>
              <th class="px-4 py-2 text-left">Clock Out</th>
            </tr>
          </thead>
          <tbody>
            <template v-for="(row, index) in workingDataTable" :key="index">
              <tr>
                <!-- Affiche le nom de l'utilisateur seulement si c'est la première ligne pour cet utilisateur -->
                <td v-if="index === 0 || row.username !== workingDataTable[index - 1].username" 
                    :rowspan="workingDataTable.filter(data => data.username === row.username).length"
                    class="border px-4 py-2 font-bold">{{ row.username }}</td>
                <td class="border px-4 py-2">{{ row.date }}</td>
                <td class="border px-4 py-2">{{ row.startTime }}</td>
                <td class="border px-4 py-2">{{ row.endTime }}</td>
                <td class="border px-4 py-2">{{ row.clockStart }}</td>
                <td class="border px-4 py-2">{{ row.clockEnd }}</td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>