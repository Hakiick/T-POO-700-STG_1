<script setup lang="ts">
import Overview from './Overview.vue'
import DateRangePicker from './DateRangePicker.vue'
import MainNav from './MainNav.vue'
import Search from './Search.vue'
import TeamSwitcher from './TeamSwitcher.vue'
import UserNav from './UserNav.vue'
import { getUser } from '../api/apiUser'
import WorkingTime from './WorkingTime.vue'

import { Button } from './ui/button'
import { Switch } from './ui/switch'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from './ui/card'
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from './ui/tabs'
import { onMounted, ref } from 'vue'
import { createClock, getClockFromUser } from '../api/apiClock'
import moment from 'moment'

const user = ref(null); // user starts as null
const clock = ref(null); // user starts as null
const last_clock = ref(null); // user starts as null

const clock_value = ref(false);
const clock_diable = ref(false);

const current_time = ref(null);

onMounted(async () => {
  user.value = await getUser(1);
  clock.value = await getClockFromUser(1);
  // console.log(clock.value.data[0]);
  last_clock.value = clock.value.data[0];
  clock_value.value = last_clock.value.status
  // console.log(last_clock.value);
  // console.log(user.value.data);
  // console.log('test');
  current_time.value = moment().format('HH[h] mm[m]');
  // console.log(moment().format('HH:mm:ss'));
  // console.log(moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'));
});

const handleChangeClock = (checked: boolean) => {
  clock_value.value = checked;
  console.log(clock_value.value);
  clock_diable.value = true;

  const response = createClock(
    { time: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'), status: clock_value.value }, 1
  );
}

</script>

<template>
  <!-- NavBar + Team recherche -->
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

    <div class="flex-1 space-y-0 p-8 pt-6 flex justify-center items-center flex-col">
      <!-- Conteneur de carte en colonne avec largeur maximale -->
      <div class="w-full max-w-screen-2xl"> <!-- Changé à max-w-screen-2xl -->
        <!-- Première carte Clock In/Out -->
        <Card class="h-28 flex flex-col items-center justify-center text-center w-full">
          <CardHeader class="flex flex-col items-center">
            <CardTitle v-if="!clock_value" class="text-xl font-bold">Clock in</CardTitle>
            <p v-else class="text-xs text-muted-foreground">Clock in</p>
          </CardHeader>
          <CardContent class="flex flex-col items-center justify-center text-center">
            <div class="text-2xl font-bold text-primary flex items-center justify-center">
              {{ current_time || "..." }}
              <Switch vsl class="mt-2 ml-2" :disabled="clock_diable" :checked="clock_value"
                @update:checked="handleChangeClock" />
            </div>
            <CardTitle v-if="clock_value" class="text-xl font-bold pt-1">Clock out</CardTitle>
          </CardContent>
        </Card>

        <h1 class="text-5xl font-bold tracking-tight mt-5 flex justify-center">
          Tableau de bord
        </h1>

        <!-- Cartes alignées en ligne, responsive sur différents écrans -->
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 mb-6 w-full mt-7">
          <!-- Carte Heures Travaillées Aujourd'hui -->
          <Card class="flex flex-col items-center justify-center text-center w-full">
            <CardHeader>
              <CardTitle class="text-xl font-medium">Heures Travaillées Aujourd'hui</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold text-primary">8h 30m</div>
            </CardContent>
          </Card>

          <!-- Carte Heures Travaillées Cette Semaine -->
          <Card class="flex flex-col items-center justify-center text-center w-full">
            <CardHeader>
              <CardTitle class="text-xl font-medium">Heures Travaillées Cette Semaine</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="text-2xl font-bold">40h 15m</div>
            </CardContent>
          </Card>

          <!-- Carte Heures Travaillées Ce Mois -->
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

      <Tabs default-value="overview" class="space-y-4 h-full w-full">
        <TabsContent value="overview" class="space-y-4 h-full w-full">
          <div class="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-10 h-full w-full mt-7">            
            <!-- Colonne principale (70%) -->
            <div class="col-span-1 lg:col-span-7 space-y-4 h-full w-full">

              <TabsList class="flex items-center justify-center text-center">
                <TabsTrigger value="today">
                  Today
                </TabsTrigger>
                <TabsTrigger value="overview">
                  Overview
                </TabsTrigger>
              </TabsList>

              <!-- Bloc Overview -->
              <Card class="h-full w-full">
                <CardHeader>
                  <CardTitle>Overview</CardTitle>
                </CardHeader>
                <CardContent class="pl-2 h-full">
                  <Overview />
                </CardContent>
              </Card>
            </div>

            <!-- Colonne droite (30%) avec WorkingTime -->
            <div class="col-span-1 lg:col-span-3 h-full w-full">
              <div class="flex items-center justify-center text-center">
                <DateRangePicker />
                <Button>Appliquer</Button>
              </div>
              <Card class="h-full w-full mt-3">
                <CardHeader>
                  <CardTitle>Temps des pointages</CardTitle>
                  <CardDescription>Temps travaillés les X derniers jours.</CardDescription>
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

