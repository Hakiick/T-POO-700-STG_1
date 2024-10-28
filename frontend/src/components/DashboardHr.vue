<script setup lang="ts">
import MainNav from './MainNav.vue';
import UserNav from './UserNav.vue';
import TeamSwitcher from './TeamSwitcher.vue';
import moment from 'moment'

import { onMounted, ref, computed } from 'vue';
import { useUserStore } from './store/userStore';
import { getAllUser } from '../api/apiUser';
import { getWorkingTimeByDate } from '../api/apiWorkingTime';
import { getClocksFromUser } from '../api/apiClock';
import { Popover, PopoverContent, PopoverTrigger } from './ui/popover';
import { DateFormatter, type DateValue, getLocalTimeZone } from '@internationalized/date';
import { CalendarIcon } from '@radix-icons/vue';
import { Button } from './ui/button';
import { Calendar } from './ui/calendar'

// ============================
// Initialisation et variables globales
// ============================

const userStore = useUserStore();
const user = computed(() => userStore.user);
const hrDataTable = ref<any[]>([]);
const usersList = ref<any[]>([]);

const df = new DateFormatter('en-US', {
  dateStyle: 'long',
})

const value = ref<DateValue>()

const formattedDate = computed(() => {
  return moment().format('dddd D MMMM');
});
const formattedTime = computed(() => {
  return moment().format('HH[h] mm[m]');
});

// ============================
// Fonction exécutée au montage
// ============================

onMounted(async () => {
  await userStore.login()
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

  const selectedDate = new Date(
    value.value.year,
    value.value.month - 1,
    value.value.day
  );
  const startDate = new Date(selectedDate.setHours(0, 0, 0, 0));
  const endDate = new Date(selectedDate.setHours(23, 59, 59, 999));

  try {
    usersList.value = await getAllUser();

    // Initialise le tableau avant de le remplir
    hrDataTable.value = [];
    usersList.value.forEach(async (user) => {
      const workingTimeResponse = await getWorkingTimeByDate(user.id, startDate.toISOString(), endDate.toISOString());
      const clockDataResponse = await getClocksFromUser(user.id, startDate.toISOString(), endDate.toISOString());

      const workingTimeData = workingTimeResponse?.data?.data ?? [];
      const clockDataEntries = clockDataResponse?.data?.data ?? [];

      // Ajouter les données au tableau au lieu de les écraser
      hrDataTable.value.push(...createDataTable(workingTimeData, clockDataEntries, user));
    });
  } catch (error) {
    console.error("Erreur lors de la récupération des données : ", error);
  }
}


// ============================
// Fonction pour générer un matricule et un salaire aléatoires
// ============================
function generateSalaryAndMatricule() {
  const matricule = Math.floor(Math.random() * 9000000000) + 1000000000; // Génère un matricule de 10 chiffres
  const salary = (Math.random() * (30 - 10) + 10).toFixed(2); // Génère un salaire entre 10 et 30
  return { matricule, salary: parseFloat(salary) };
}

// ============================
// Fonction pour créer un tableau de données
// ============================

function createDataTable(workingTimeEntries, clockEntries, user) {
  let dataTable = [];

  // Génère un matricule et un salaire pour chaque utilisateur
  const { matricule, salary } = generateSalaryAndMatricule();

  // Filtrer les entrées d'horloge pour obtenir les deux premières avec status true et false
  const clockStartEntries = clockEntries.filter(entry => entry.status === true).slice(0, 2);
  const clockEndEntries = clockEntries.filter(entry => entry.status === false).slice(0, 2);

  // Parcourir les deux premières entrées de temps de travail
  workingTimeEntries.slice(0, 2).forEach((workingTime, index) => {
    dataTable.push({
      username: user.username || 'N/A',
      matricule, // Ajoute le matricule généré
      salary,    // Ajoute le salaire généré
      startTime: workingTime.start ? new Date(workingTime.start).toLocaleTimeString('fr-FR', { hour: "2-digit", minute: "2-digit", timeZone: 'UTC' }) : 'N/A',
      endTime: workingTime.end ? new Date(workingTime.end).toLocaleTimeString('fr-FR', { hour: "2-digit", minute: "2-digit", timeZone: 'UTC' }) : 'N/A',
      clockStart: clockStartEntries[index] ? new Date(clockStartEntries[index].time).toLocaleTimeString('fr-FR', { hour: "2-digit", minute: "2-digit", timeZone: 'UTC' }) : 'N/A',
      clockEnd: clockEndEntries[index] ? new Date(clockEndEntries[index].time).toLocaleTimeString('fr-FR', { hour: "2-digit", minute: "2-digit", timeZone: 'UTC' }) : 'N/A'
    });
  });

  // Si aucune donnée n'est présente
  if (!dataTable.length) {
    dataTable.push({
      username: 'Aucune donnée',
      matricule: 'N/A',
      salary: 'N/A',
      workingTime: 'N/A',
      nightTime: 'N/A',
    });
  }

  return dataTable;
}

</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-10 lg:min-h-screen">
    <!-- NavBar -->
    <div class="col-span-1 lg:col-span-2/ lg:border-r-4 relative w-full lg:w-auto">
      <h1 class="font-bold mt-5 flex justify-center lg:justify-center">
        Time Manager
      </h1>
      <div v-if="user" class="flex items-center justify-center py-4 lg:py-8 border-b-4">
        <NavAdmin :user="user" />
      </div>
      <!-- MainNav for Desktop -->
      <div class="flex items-center justify-center pb-4 border-b-4 hidden lg:block">
        <MainNav class="mx-4" />
      </div>
      <!-- MainNav for Mobile -->
      <div class="absolute top-4 right-4 lg:hidden">
        <MainNav class="mx-4" />
      </div>
      <div class="text-center items-center justify-center p-4 lg:p-8 border-b-4">
        <p>{{ formattedDate }}</p>
        <p class="text-xl font-bold">{{ formattedTime }}</p>
      </div>
    </div>

    <div class="col-span-1 lg:col-span-8 h-full w-full space-y-4 pt-5">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="flex justify-center">
          <TeamSwitcher class="w-full text-center" />
        </div>
        <div>
          <!-- Calendrier avec bouton d'application -->
          <div class="text-center flex justify-center mb-3">
            <Popover>
              <PopoverTrigger as-child>
                <Button
                  variant="outline"
                  :class="[
                    'w-full justify-start text-left font-normal',
                    !value && 'text-muted-foreground',
                  ]"
                >
                  <CalendarIcon class="mr-2 h-4 w-4" />
                  {{ value ? df.format(value.toDate(getLocalTimeZone())) : "Pick a date" }}
                </Button>
              </PopoverTrigger>
              <PopoverContent class="w-auto p-0">
                <Calendar
                  v-model="value"
                  initial-focus
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
      <div class="text-center mb-3">
        <table class="w-full">
          <thead>
            <tr>
              <th class="px-4 py-2 text-left">Username</th>
              <th class="px-4 py-2 text-left">Matricule</th>
              <th class="px-4 py-2 text-left">Salary/H</th>
              <th class="px-4 py-2 text-left">Working Time</th>
              <th class="px-4 py-2 text-left">Night TIme</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, index) in hrDataTable" :key="index">
              <td class="border px-4 py-2">{{ row.username }}</td>
              <td class="border px-4 py-2">{{ row.matricule }}</td>
              <td class="border px-4 py-2">{{ row.salary }}</td>
              <td class="border px-4 py-2">{{ row.workingTime }}</td>
              <td class="border px-4 py-2">{{ row.nightTime }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>