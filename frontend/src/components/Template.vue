<script setup lang="ts">
// ============================
// Définition des options de composant
// ============================
defineOptions({
  name: "HomePage",
  displayName: "Home Page",
});
import MainNav from './MainNav.vue';
import UserNav from './UserNav.vue';
import ChartRange from './ChartRange.vue';
import { Card, CardHeader, CardTitle } from './ui/card';
import { computed, onMounted, ref } from 'vue';
import { useClockStore } from './store/clockStore';

import moment, { Moment } from 'moment'
import 'moment/locale/fr';
moment.locale('fr');

// ============================
// Imports des API
// ============================
import { createClock, getClockFromUser, getClocksFromUser } from '../api/apiClock';

// ============================
// Import du store
// ============================
import { useUserStore } from './store/userStore';

// ============================
// Variables liées à l'utilisateur et aux données de pointage
// ============================
const userStore = useUserStore();
const user = computed(() => userStore.user);
const clockStore = useClockStore()

const workedHoursToday = ref<string | null>(null);
const workedHoursThisWeek = ref<string | null>(null);
const workedHoursThisMonth = ref<string | null>(null);
const arrivalTime = ref<string | null>(null);
const workTime = ref<string | null>(null);
const isDesktop = ref(false);
const clocks = computed(() => clockStore.clocks);
// const last_clock = computed(() => clockStore.lastClock);
const last_clock_value = computed(() => clockStore.lastClock?.status);
const clock_disable = ref(false);
const current_time = ref("");

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
  const response_clock = await getClockFromUser(user.value.id);
  if (response_clock.status === 200) {
    clockStore.setClock(response_clock.data.data);
    current_time.value = moment().format('HH[h] mm[m]');
    // console.log("clock", clocks.value);
    const lastTrueClock = clocks.value.find((entry) => entry.status === true);

    if (lastTrueClock) {
      arrivalTime.value = moment(lastTrueClock.time).format('HH:mm');
    } else {
      arrivalTime.value = null; // Pas d'heure de pointage trouvée
    }

    if (arrivalTime.value) {
      const arrivalMoment = moment(arrivalTime.value, 'HH:mm');
      const duration = moment.duration(moment().diff(arrivalMoment));
      workTime.value = formatHours(duration.asHours());
    } else {
      workTime.value = '...'; // Pas d'heure d'arrivée, donc on affiche "..."
    }

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
  }

  checkIsDesktop();
  window.addEventListener('resize', checkIsDesktop);
});

const formattedArrivalTime = computed(() => {
  return arrivalTime.value ? moment(arrivalTime.value, 'HH:mm').format('HH[h] mm[m]') : '...';
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
    let clockInTime: Moment | null = null;

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
  //console.log(last_clock_value.value);
  clock_disable.value = true;
  const response = await createClock(
    checked, user.value.id
  );
  if (response.data) {
    clockStore.setLastClock(response.data);
  }
  else {
    clock_disable.value = false;
  }
  // console.log(response);
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
      <div class="text-center items-center justify-center p-4">
        <div class="mb-2">
          <p>Day</p>
          <p class="text-2xl font-bold text-primary">{{ workedHoursToday !== null ? workedHoursToday : '0h' }}</p>
        </div>
        <hr class="my-2">
        <div class="mb-2">
          <p>Week</p>
          <p class="text-2xl font-bold text-primary">{{ workedHoursThisWeek !== null ? workedHoursThisWeek : '0h' }}</p>
        </div>
        <hr class="my-2">
        <div class="mb-2">
          <p>Month</p>
          <p class="text-2xl font-bold text-primary">{{ workedHoursThisMonth !== null ? workedHoursThisMonth : '0h' }}
          </p>
        </div>
        <hr class="my-2">
        <div class="mb-2">
          <p>Time worked</p>
          <p class="text-2xl font-bold text-success">{{ workTime || "..." }}</p>
        </div>
        <hr class="my-2">
        <div class="mb-2">
          <p>Check In</p>
          <p class="text-2xl font-bold text-danger">{{ formattedArrivalTime || '...' }}</p>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="col-span-1 lg:col-span-9 flex flex-col justify-between p-8">
      <Card class="box-content p-9 border-4 cursor-pointer m-0 mb-8"
        :class="last_clock_value ? 'bg-red-500' : 'bg-green-500'" @click="handleChangeClock(!last_clock_value)">
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
