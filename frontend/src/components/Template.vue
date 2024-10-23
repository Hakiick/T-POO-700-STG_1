<script setup lang="ts">
// ============================
// Définition des options de composant
// ============================
defineOptions({
  name: "HomePage",
  displayName: "Home Page",
});
import MainNav from './MainNav.vue'
import UserNav from './UserNav.vue'
import ChartRange from './ChartRange.vue';
import { Tabs, TabsContent } from './ui/tabs'
import { Card, CardContent, CardHeader, CardTitle } from './ui/card'
import { onMounted, ref, computed} from 'vue'

import moment from 'moment'
import 'moment/locale/fr';
moment.locale('fr');

import { AxiosResponse } from 'axios';

// ============================
// Imports des API
// ============================
import { getUser } from '../api/apiUser';
import { createClock, getClockFromUser, getClocksFromUser } from '../api/apiClock';

// ============================
// Import du store
// ============================
import { useUserStore } from './store/userStore';

// ============================
// Types
// ============================
type response_clock = AxiosResponse;

// ============================
// Variables liées à l'utilisateur et aux données de pointage
// ============================
const userStore = useUserStore();
const user = computed(() => userStore.user);

const clocks = ref(null);
const last_clock = ref(null);
const last_clock_value = ref(false);
const clock_diable = ref(false);
const workedHoursToday = ref<string | null>(null);
const workedHoursThisWeek = ref<string | null>(null);
const workedHoursThisMonth = ref<string | null>(null);
const arrivalTime = ref<string | null>(null);
const workTime = ref<string | null>(null);

const isDesktop = ref(false);

const checkIsDesktop = () => {
  isDesktop.value = window.innerWidth >= 1024;
};

const formattedDate = computed(() => {
  return moment().format('dddd D MMMM');
});

const formattedTime = computed(() => {
  return moment().format('HH[h] mm[m]');
});

// ============================
// onMounted: Initialisation des données au montage du composant
// ============================
onMounted(async () => {
  if (!user.value) {
    const response = await getUser(1);
    // console.log("response", response);
    userStore.setUser(response);
  }

  checkIsDesktop();
  window.addEventListener('resize', checkIsDesktop);

  // ============================
  // Fonction DayCard: Recuperation du temps journalier travaille (clock)
  // ============================
  const { startOfDay, endOfDay } = getCurrentDay();
  const hoursToday = await calculateWorkedHours(user.value.id, startOfDay, endOfDay);
  workedHoursToday.value = formatHours(hoursToday);

  // Pour la semaine en cours
  const { startOfWeek, endOfWeek } = getCurrentWeek();
  const hoursThisWeek = await calculateWorkedHours(user.value.id, startOfWeek, endOfWeek);
  workedHoursThisWeek.value = formatHours(hoursThisWeek);

  // Pour le mois en cours
  const { startOfMonth, endOfMonth } = getCurrentMonth();
  const hoursThisMonth = await calculateWorkedHours(user.value.id, startOfMonth, endOfMonth);
  workedHoursThisMonth.value = formatHours(hoursThisMonth);

  // Récupérer les horodatages de l'utilisateur
  const response_clock = await getClockFromUser(user.value.id);

  if (response_clock.status === 200) {
    clocks.value = response_clock.data;
    last_clock.value = clocks.value.data[0];
    last_clock_value.value = last_clock.value.status;

    // Récupérer l'heure d'arrivée (plus récent statut `true`)
    const lastTrueClock = clocks.value.data.find((entry) => entry.status === true);
    if (lastTrueClock) {
      arrivalTime.value = moment(lastTrueClock.time).format('YYYY-MM-DD HH:mm');
    } else {
      arrivalTime.value = null;
    }
  }

  if (arrivalTime.value) {
    const arrivalMoment = moment(arrivalTime.value, 'YYYY-MM-DD HH:mm');
    const duration = moment.duration(moment().diff(arrivalMoment));
    workTime.value = formatHours(duration.asHours());
  } else {
    workTime.value = '...';
  }
});
  
const formattedArrivalTime = computed(() => {
      return arrivalTime.value ? moment(arrivalTime.value).format('HH[h] mm[m]') : '...';
    });


const formatHours = (hours) => {
  const h = Math.floor(hours);
  const m = Math.round((hours - h) * 60);
  return `${h}h ${m}m`;
};

function getCurrentDay() {
  const startOfDay = moment().startOf('day').toISOString();
  const endOfDay = moment().endOf('day').toISOString();
  return { startOfDay, endOfDay };
}

function getCurrentWeek() {
  const startOfWeek = moment().startOf('isoWeek').toISOString();
  const endOfWeek = moment().endOf('isoWeek').toISOString();
  return { startOfWeek, endOfWeek };
}

function getCurrentMonth() {
  const startOfMonth = moment().startOf('month').toISOString();
  const endOfMonth = moment().endOf('month').toISOString();
  return { startOfMonth, endOfMonth };
}

// ============================
// Fonction calculateWorkedHours: Recuperation du temps de travail. (clock)
// ============================
async function calculateWorkedHours(userId, startDate, endDate) {
  const utcStartDate = moment.utc(startDate).toISOString();
  const utcEndDate = moment.utc(endDate).toISOString();
  // console.log(utcStartDate, utcEndDate);

  const cardDay = await getClocksFromUser(userId, utcStartDate, utcEndDate);
  //console.log(cardDay);

  if (cardDay.status === 404) {
    return 0;
  } else {
    const clockEntries = cardDay.data.data;
    let totalWorkedHours = 0;
    let clockInTime = null;

    if (Array.isArray(clockEntries)) {
      clockEntries.forEach(entry => {
        if (entry.status) {
          // Clock-in
          clockInTime = moment(entry.time);
        } else if (clockInTime) {
          // Clock-out
          const clockOutTime = moment(entry.time);
          const duration = moment.duration(clockOutTime.diff(clockInTime));
          totalWorkedHours += duration.asHours();
          clockInTime = null; // Reset clock-in time
        }
      });
    }

    // L'heure actuelle pour calculer la durée.
    if (clockInTime) {
      const currentTime = moment.utc();
      const duration = moment.duration(currentTime.diff(clockInTime));
      totalWorkedHours += duration.asHours();
    }

    return totalWorkedHours;
  }
}

// ============================
// Fonction handleChangeClock: Gestion du changement de pointage (clock)
// ============================
const handleChangeClock = async (checked: boolean) => {
  last_clock_value.value = checked;
  //console.log(last_clock_value.value);
  clock_diable.value = true;
  const response = await createClock(
    { time: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'), status: last_clock_value.value }, user.value.id
  );
}
</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-10 min-h-screen">
    <!-- NavBar -->
    <div class="col-span-1 lg:col-span-1/10 border-r-4 relative">
      <h1 class="font-bold mt-5 flex justify-center">
        Time Manager
      </h1>
      <div v-if="user" class="flex items-center justify-center py-8 border-b-4">
        <UserNav :user="user" />
      </div>
      <!-- MainNav for Desktop -->
      <div class="flex items-center justify-center py-2 border-b-4 hidden lg:block">
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
      <div class="text-center items-center justify-center p-4">
        <div class="mb-2">
          <p>Quotidien</p>
          <p class="text-2xl font-bold text-primary">{{ workedHoursToday !== null ? workedHoursToday : '0h' }}</p>
        </div>
        <hr class="my-2">
        <div class="mb-2">
          <p>Hebdomadaire</p>
          <p class="text-2xl font-bold text-primary">{{ workedHoursThisWeek !== null ? workedHoursThisWeek : '0h' }}</p>
        </div>
        <hr class="my-2">
        <div class="mb-2">
          <p>Mensuel</p>
          <p class="text-2xl font-bold text-primary">{{ workedHoursThisMonth !== null ? workedHoursThisMonth : '0h' }}</p>
        </div>
        <hr class="my-2">
        <div class="mb-2">
          <p>Temps travaillé</p>
          <p class="text-2xl font-bold text-success">{{ "" + workTime || "..." }}</p>
        </div>
        <hr class="my-2">
        <div class="mb-2">
          <p>Arrivé</p>
          <p class="text-2xl font-bold text-danger">{{ formattedArrivalTime || '...' }}</p>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="col-span-1 lg:col-span-9 flex flex-col justify-between p-8">
      <Card
        class="box-content p-9 border-4 cursor-pointer m-0 mb-8"
        :class="last_clock_value ? 'bg-red-500' : 'bg-green-500'"
        @click="handleChangeClock"
      >
        <CardHeader class="flex flex-col items-center justify-center space-y-0 pb-1 px-6 pt-3">
          <div class="text-4xl text-white">
            <template v-if="last_clock_value">
              🌙
            </template>
            <template v-else>
              ☀️
            </template>
          </div>
          <CardTitle class="text-xl font-bold text-white mt-2">
            {{ last_clock_value ? 'Clock Out' : 'Clock In' }}
          </CardTitle>
        </CardHeader>
      </Card>

      <!-- ChartRange for Desktop -->
      <div v-if="isDesktop" class="mt-8">
        <ChartRange :user="user" />
      </div>
    </div>
  </div>
</template>