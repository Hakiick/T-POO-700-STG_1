<script setup lang="ts">
// ============================
// Définition des options de composant
// ============================
defineOptions({
  name: 'HomePage',
  displayName: 'Home Page',
});

// ============================
// Imports des composants locaux et utilitaires
// ============================
import Day from './Day.vue';
import ChartRange from './ChartRange.vue';
import MainNav from './MainNav.vue';
import Search from './Search.vue';
import TeamSwitcher from './TeamSwitcher.vue';
import UserNav from './UserNav.vue';
import WorkingTime from './WorkingTime.vue';

// ============================
// Imports des composants UI
// ============================
import { Calendar } from './ui/calendar';
import { Button } from './ui/button';
import { Popover, PopoverContent, PopoverTrigger } from './ui/popover';
import { Switch } from './ui/switch';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { CalendarIcon } from '@radix-icons/vue';

// ============================
// Imports des bibliothèques utilitaires
// ============================
import { cn } from '../lib/utils';
import { CalendarDate, DateFormatter, DateValue, getLocalTimeZone } from '@internationalized/date';
import moment from 'moment';
import { onMounted, ref, watch } from 'vue';
import { AxiosResponse } from 'axios';

// ============================
// Imports des API
// ============================
import { getUser } from '../api/apiUser';
import { getWorkingTime } from '../api/apiWorkingTime';
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
const user = ref(userStore.user);
const clocks = ref(null);
const last_clock = ref(null);
const last_clock_value = ref(false);
const clock_diable = ref(false);
const current_time = ref("");
const workingtime = ref<any>(null);
const clockDataDay = ref<any>(null);
const clockDataWeek = ref<any>(null);
const clockDataMonth = ref<any>(null);
const workedHoursToday = ref<string | null>(null);
const workedHoursThisWeek = ref<string | null>(null);
const workedHoursThisMonth = ref<string | null>(null);
const arrivalTime = ref<string | null>(null);
const departureTime = ref<string | null>(null);
// ============================
// Variables liées à la date sélectionnée
// ============================
const oneDateValue = ref(null);
const oneDayChart = ref<any>(null);

const df = (date: Date) => moment(date).format('DD-MM-YYYY');

// ============================
// onMounted: Initialisation des données au montage du composant
// ============================
onMounted(async () => {
  if (!user.value) {
    user.value = await getUser(1);
  }
  // console.log(user.value);

  // ============================
  // Fonction DayCard: Recuperation du temps journalier travaille (clock) oneDateValue
  // ============================
  // Pour le jour en cours
  const { startOfDay, endOfDay } = getCurrentDay();
  const hoursToday = await calculateWorkedHours(user.value.id, startOfDay, endOfDay);
  workedHoursToday.value = formatHours(hoursToday);

  // Pour la semaine en cours
  const { startOfWeek, endOfWeek } = getCurrentWeek();
  const hoursThisWeek = await calculateWorkedHours(user.value.id, startOfWeek, endOfWeek);
  workedHoursThisWeek.value = formatHours(hoursThisWeek);
  //
  clockDataWeek.value = hoursThisWeek;

  // Pour le mois en cours
  const { startOfMonth, endOfMonth } = getCurrentMonth();
  const hoursThisMonth = await calculateWorkedHours(user.value.id, startOfMonth, endOfMonth);
  workedHoursThisMonth.value = formatHours(hoursThisMonth);
  //
  clockDataMonth.value = hoursThisMonth;

  // Récupération des pointages de l'utilisateur
  const response_clock: response_clock = await getClockFromUser(user.value.id);
  // console.log(response_clock);
  if (response_clock.status === 200) {
    clocks.value = response_clock.data;
    last_clock.value = clocks.value.data[0];
    last_clock_value.value = last_clock.value.status
  }

  // Mise à jour de l'heure actuelle
  current_time.value = moment().format('HH[h] mm[m]');
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
  last_clock_value.value = checked;
  //console.log(last_clock_value.value);
  clock_diable.value = true;
  const response = await createClock(
    { time: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'), status: last_clock_value.value }, user.value.id
  );
}




watch(oneDateValue, (newValue) => {
  if (newValue) {
    // Extraire les détails de la date
    const year = newValue.year;
    const month = String(newValue.month).padStart(2, '0');
    const day = String(newValue.day).padStart(2, '0');

    const userData = user.value.id;

    // Formater la date pour obtenir un format spécifique
    const formattedDate = `${year}-${month}-${day}`;
    console.log('Formatted Date:', formattedDate);

    // Exemple: Supposons que vous avez une fonction qui récupère les heures
    // oneDayChart.value =  getHoursForDate(formattedDate, userData);
    getHoursForDate(formattedDate, userData).then((data) => {
      oneDayChart.value = data;
      // console.log("asdf", oneDayChart.value[0]);
      // console.log("asdf", data);
    });

    // Formater les heures et mettre à jour oneDayChart
  }
});

async function getHoursForDate(date, userData) {

  const startOfDay = moment(date).startOf('day').toISOString();
  const endOfDay = moment(date).endOf('day').toISOString();

  const workDay = await getClocksFromUser(userData, startOfDay, endOfDay);
  console.log(workDay.data);
  return workDay.data.data;
}


// ============================
// Jeu d'essai: Calcul des heures travaillées pour des dates en août
// ============================
async function testCalculateWorkedHours() {
  const userId = 1; // ID de l'utilisateur pour le test

  // Test pour une journée en août
  const startDateDay = moment('2024-09-14').startOf('day').toISOString();
  const endDateDay = moment('2024-09-14').endOf('day').toISOString();
  const workedHoursDay = await calculateWorkedHours(userId, startDateDay, endDateDay);
  //console.log(`Worked hours on 2024-09-15: ${workedHoursDay}`);

  // Test pour une semaine en août
  const startDateWeek = moment('2024-09-12').startOf('isoWeek').toISOString();
  const endDateWeek = moment('2024-09-18').endOf('isoWeek').toISOString();
  const workedHoursWeek = await calculateWorkedHours(userId, startDateWeek, endDateWeek);
  //console.log(`Worked hours from 2024-09-12 to 2024-09-18: ${workedHoursWeek}`);

  // Test pour le mois d'août
  const startDateMonth = moment('2024-09-01').startOf('month').toISOString();
  const endDateMonth = moment('2024-09-30').endOf('month').toISOString();
  const workedHoursMonth = await calculateWorkedHours(userId, startDateMonth, endDateMonth);
  //console.log(`Worked hours in September 2024: ${workedHoursMonth}`);
}

// Décommenter pour exécuter le jeu d'essai
// testCalculateWorkedHours();





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

        <Card class="h-29 min-w-72"> <!-- Agrandir la carte en largeur -->
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
                  {{ arrivalTime || '08:00' }}
                </div>
              </div>
              <Switch class="mt-2" :disabled="clock_diable" :checked="last_clock_value"
                @update:checked="handleChangeClock" />
              <div class="flex flex-col items-center font-bold">
                <p class="text-xs text-muted-foreground">Départ</p>
                <div class="text-sm text-muted-foreground">
                  {{ departureTime || '17:00' }}
                </div>
              </div>
            </div>
            <div class="text-2xl font-bold text-primary mt-2">
              {{ "Il est " + current_time || "..." }}
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

      <Tabs default-value="day" class="space-y-4 h-full w-full">

        <TabsList class="flex items-center justify-center text-center lg:w-[66vw]">
          <TabsTrigger value="day">
            Jour
          </TabsTrigger>
          <TabsTrigger value="weekly">
            Semaine
          </TabsTrigger>
          <TabsTrigger value="monthly">
            Mois
          </TabsTrigger>
        </TabsList>

        <!-- Day -->
        <TabsContent value="day" class="space-y-4 h-full w-full">
          <div class="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-10 h-full w-full mt-7">
            <!-- Graphique par jour -->
            <div class="col-span-1 lg:col-span-7 space-y-4 h-full w-full">
              <Card class="h-full w-full">
                <CardContent class="bottom-p-0 h-full">
                  <!-- Passer la date sélectionnée à Day -->
                  <Day :oneDayChart="oneDayChart" />
                </CardContent>
              </Card>
            </div>

            <!-- Sélecteur de date et emploi du temps -->
            <div class="col-span-1 lg:col-span-3 h-full w-full lg:top-[-64px] lg:relative">
              <div class="flex items-center justify-center text-center">
                <Popover>
                  <PopoverTrigger as-child>
                    <Button variant="outline" :class="cn(
                      'w-[280px] justify-start text-left font-normal lg:mb-4',
                      !oneDateValue && 'text-muted-foreground',
                    )">
                      <CalendarIcon class="mr-2 h-4 w-4" />
                      {{ oneDateValue ? df(oneDateValue.toDate(getLocalTimeZone())) : "Choisir une date" }}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent class="w-auto p-0">
                    <!-- Utiliser v-model pour récupérer la date sélectionnée -->
                    <Calendar v-model="oneDateValue" />
                  </PopoverContent>
                  <p>{{ oneDateValue ? df(oneDateValue.toDate(getLocalTimeZone())) : '' }}</p>
                </Popover>
              </div>

              <!-- Emploi du temps avec la date sélectionnée -->
              <Card class="h-full w-full mt-3">
                <CardHeader>
                  <CardTitle>Emploi du temps</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full">
                  <!-- Passer la date sélectionnée à WorkingTime -->

                </CardContent>
              </Card>
            </div>
          </div>
        </TabsContent>

        <!-- Week -->
        <TabsContent value="weekly" class="space-y-4 h-full w-full">
          <div class="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-10 h-full w-full mt-7">
            <div class="col-span-1 lg:col-span-7 space-y-4 h-full w-full">
              <Card class="h-full w-full">
                <CardHeader>
                  <CardTitle>Graphique en semaine</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full" v-if="user">
                  <ChartRange :user="user" />
                </CardContent>
              </Card>
            </div>
            <div class="col-span-1 lg:col-span-3 h-full w-full">
              <div class="flex items-center justify-center text-center">

              </div>
              <Card class="h-full w-full mt-3">
                <CardHeader>
                  <CardTitle>Emploi du temps</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full" v-if="user">
                  <WorkingTime :user="user" />
                </CardContent>
              </Card>
            </div>
          </div>
        </TabsContent>

        <!-- Monthly -->
        <TabsContent value="monthly" class="space-y-4 h-full w-full">
          <div class="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-10 h-full w-full mt-7">
            <div class="col-span-1 lg:col-span-7 space-y-4 h-full w-full">
              <Card class="h-full w-full">
                <CardHeader>
                  <CardTitle>Graphique en mois</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full" v-if="user">
                  <ChartRange :user="user" />
                </CardContent>
              </Card>
            </div>
            <div class="col-span-1 lg:col-span-3 h-full w-full">
              <div class="flex items-center justify-center text-center">

              </div>
              <Card class="h-full w-full mt-3">
                <CardHeader>
                  <CardTitle>Emploi du temps</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full" v-if="user">
                  <WorkingTime :user="user" />
                </CardContent>
              </Card>
            </div>
          </div>
        </TabsContent>

      </Tabs>
    </div>
  </div>
</template>
