<script setup lang="ts">
// ============================
// Définition des options de composant
// ============================
defineOptions({
  name: "HomePage",
  displayName: "Home Page",
});
import MainNav from './MainNav.vue'
import Search from './Search.vue'
import TeamSwitcher from './TeamSwitcher.vue'
import UserNav from './UserNav.vue'
import ChartRange from './ChartRange.vue';

import { Switch } from './ui/switch'
import { Card, CardContent, CardHeader, CardTitle } from './ui/card'
import { Tabs, TabsContent } from './ui/tabs'
import { computed, onMounted, ref, watch } from 'vue'
import { createClock, getClockFromUser, getClocksFromUser } from '../api/apiClock';
import moment from 'moment'
import { useUserStore } from './store/userStore';
import { useClockStore } from './store/clockStore';

const userStore = useUserStore()
const clockStore = useClockStore()

// ============================
// Variables liées à l'utilisateur et aux données de pointage
// ============================
const user = computed(() => userStore.user);

const clocks = computed(() => clockStore.clocks);
// const last_clock = computed(() => clockStore.lastClock);
const last_clock_value = computed(() => clockStore.lastClock?.status);
const clock_disable = ref(false);
const current_time = ref("");

// const clockDataWeek = ref<any>(null);
// const clockDataMonth = ref<any>(null);
const workedHoursToday = ref<string | null>(null);
const workedHoursThisWeek = ref<string | null>(null);
const workedHoursThisMonth = ref<string | null>(null);
const arrivalTime = ref<string | null>(null);
const workTime = ref<string | null>(null);

// const df = (date: Date) => moment(date).format('DD-MM-YYYY');

// ============================
// onMounted: Initialisation des données au montage du composant
// ============================
onMounted(async () => {
  await userStore.login()
  console.log("usertest", user.value);
  // console.log(moment().format('HH:mm:ss'));
  // console.log(moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'));
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
  //console.log(last_clock_value.value);
  clock_disable.value = true;
  const response = await createClock(
    checked, user.value.id
  );
  console.log(response);
}

watch(() => user.value, async (newUser) => {
  if (newUser) {

    // ============================
    // fetch clock avec le nouvel utilisateur
    // ============================
    console.log("newUser", newUser);
    const response_clock = await getClockFromUser(newUser.id);
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

  }
});
</script>

<template>
  <div class="flex-col flex">
    <div class="border-b">
      <div class="flex h-16 items-center px-4">
        <TeamSwitcher />
        <MainNav class="mx-6" />
        <div v-if="user" class="ml-auto flex items-center space-x-4">
          <Search />
          <UserNav :user="user" />
        </div>
      </div>
    </div>

    <div class="flex-1 space-y-0 p-8 pt-6">
      <div class="flex items-center justify-between flex-wrap">

        <Card class="h-29 w-full md:w-auto sm:min-w-72">
          <CardHeader class="flex flex-row items-center justify-center space-y-0 pb-1 px-6 pt-3">
            <CardTitle :class="last_clock_value ? 'text-red-500' : 'text-green-500'" class="text-xl font-bold">
              {{ last_clock_value ? 'Fin de journée' : 'Début de journée' }}
            </CardTitle>
          </CardHeader>

          <CardContent class="flex flex-col items-center justify-center text-center">
            <div class="flex items-center justify-between w-full px-6">
              <div class="flex flex-col items-center font-bold">
                <p class="text-xs text-muted-foreground">Arrivée</p>
                <div class="text-sm text-muted-foreground">
                  {{ arrivalTime || '...' }}
                </div>
              </div>
              <Switch class="mt-2" :disabled="clock_disable" :checked="last_clock_value"
                @update:checked="handleChangeClock" />
              <div class="flex flex-col items-center font-bold">
                <p class="text-xs text-muted-foreground">Heure actuelle</p>
                <div class="text-sm text-muted-foreground">
                  {{ current_time || '...' }}
                </div>
              </div>
            </div>
            <div class="text-2xl font-bold text-primary mt-2">
              {{ "Vous avez pointé il y a : " + workTime || "..." }}
            </div>
          </CardContent>
        </Card>


        <h1 class="text-5xl font-bold tracking-tight mt-5 flex justify-center flex-1">
          Tableau de bord
        </h1>
      </div>

      <div class="flex flex-col items-center justify-center w-full">
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 mb-6 w-full mt-7">
          <Card class="flex flex-col items-center justify-center text-center w-full">
            <CardHeader>
              <CardTitle class="text-xl font-medium">Heures Travaillées Aujourd'hui</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-primary">{{ workedHoursToday !== null ? workedHoursToday : '0h' }}
              </div>
            </CardContent>
          </Card>

          <Card class="flex flex-col items-center justify-center text-center w-full">
            <CardHeader>
              <CardTitle class="text-xl font-medium">Heures Travaillées Cette Semaine</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-primary">{{ workedHoursThisWeek !== null ? workedHoursThisWeek : '0h'
                }}</div>
            </CardContent>
          </Card>

          <Card class="flex flex-col items-center justify-center text-center w-full">
            <CardHeader>
              <CardTitle class="text-xl font-medium">Heures Travaillées Ce Mois</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-primary">{{ workedHoursThisMonth !== null ? workedHoursThisMonth :
                '0h' }}</div>
            </CardContent>
          </Card>
        </div>
      </div>

      <hr>

      <Tabs default-value="monthly" class="space-y-4 h-full w-full">
        <TabsContent value="monthly" class="space-y-4 h-full w-full">
          <CardContent class="bottom-p-0 h-full" v-if="user">
            <ChartRange :user="user" />
          </CardContent>
        </TabsContent>
      </Tabs>
    </div>
  </div>
</template>
