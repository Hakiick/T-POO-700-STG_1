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
import { onMounted, ref } from 'vue';
import { AxiosResponse } from 'axios';

// ============================
// Imports des API
// ============================
import { getUser } from '../api/apiUser';
import { getWorkingTime } from '../api/apiWorkingTime';
import { createClock, getClockFromUser } from '../api/apiClock';

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
const clockData = ref<any>(null);

// ============================
// Variables liées à la date sélectionnée
// ============================
const oneDateValue = ref<DateValue>();

const df = (date: Date) => moment(date).format('DD-MM-YYYY');

// ============================
// onMounted: Initialisation des données au montage du composant
// ============================
onMounted(async () => {
  // Récupération de l'utilisateur s'il n'est pas déjà présent
  if (!user.value) {
    user.value = await getUser(1);
  }

  // Récupération des heures de travail et des pointages
  workingtime.value = await getWorkingTime(user.value.id);
  clockData.value = await getClockFromUser(user.value.id);

  console.log(workingtime.value.data.data, clockData.value.data.data);

  // Récupération des pointages de l'utilisateur
  const response_clock: response_clock = await getClockFromUser(user.value.id);
  if (response_clock.status === 200) {
    clocks.value = response_clock.data; // Stocke les données des pointages
    last_clock.value = clocks.value.data; // Dernier pointage
    last_clock_value.value = last_clock.value.status; // Statut du dernier pointage
  }

  // Mise à jour de l'heure actuelle
  current_time.value = moment().format('HH[h] mm[m]');
});

// ============================
// Fonction handleChangeClock: Gestion du changement de pointage (clock)
// ============================
const handleChangeClock = async (checked: boolean) => {
  last_clock_value.value = checked; // Met à jour le statut du dernier pointage
  clock_diable.value = true; // Désactive les boutons pendant l'opération

  // Création d'un nouveau pointage
  await createClock(
    {
      time: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'), // Format UTC
      status: last_clock_value.value, // Statut du pointage
    },
    user.value.id
  );
};
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
        <Card class="h-28 min-w-52">
          <CardHeader class="flex flex-row items-center space-y-0 pb-1 px-6 pt-3">
            <CardTitle v-if="!last_clock_value" class="text-xl font-bold">Clock in</CardTitle>
            <p v-else class="text-xs text-muted-foreground">Clock in</p>
          </CardHeader>
          <CardContent class="flex flex-col items-center justify-center text-center">
            <div class="text-2xl font-bold text-primary flex items-center justify-center">
              {{ current_time || "..." }}
              <Switch class="mt-2 ml-auto" :disabled="clock_diable" :checked="last_clock_value"
                @update:checked="handleChangeClock" />
            </div>
            <CardTitle v-if="last_clock_value" class="text-xl font-bold pt-1">Clock out</CardTitle>
            <p v-else class="text-xs text-muted-foreground pt-1">Clock out</p>
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
              <div class="text-2xl font-bold text-primary">8h 30m</div>
            </CardContent>
          </Card>

          <Card class="flex flex-col items-center justify-center text-center w-full">
            <CardHeader>
              <CardTitle class="text-xl font-medium">Heures Travaillées Cette Semaine</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold">40h 15m</div>
            </CardContent>
          </Card>

          <Card class="flex flex-col items-center justify-center text-center w-full">
            <CardHeader>
              <CardTitle class="text-xl font-medium">Heures Travaillées Ce Mois</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold">160h 45m</div>
            </CardContent>
          </Card>
        </div>
      </div>

      <Tabs default-value="day" class="space-y-4 h-full w-full">

        <TabsList class="flex items-center justify-center text-center">
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
                  <Day :oneDateValue="oneDateValue" :workingtime="workingtime" :clockData="clockData"/>
                </CardContent>
                </Card>
                </div>

                <!-- Sélecteur de date et emploi du temps -->
                <div class="col-span-1 lg:col-span-3 h-full w-full">
                  <div class="flex items-center justify-center text-center">
                    <Popover>
                      <PopoverTrigger as-child>
                        <Button variant="outline" :class="cn(
                          'w-[280px] justify-start text-left font-normal',
                          !oneDateValue && 'text-muted-foreground',
                        )">
                          <CalendarIcon class="mr-2 h-4 w-4" />
                          {{ oneDateValue ? df.format(oneDateValue.toDate(getLocalTimeZone())) : "Pick a date" }}
                        </Button>
                      </PopoverTrigger>
                      <PopoverContent class="w-auto p-0">
                        <!-- Utiliser v-model pour récupérer la date sélectionnée -->
                        <Calendar v-model="oneDateValue"/>
                      </PopoverContent>
                      <p>{{ oneDateValue }}</p>
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