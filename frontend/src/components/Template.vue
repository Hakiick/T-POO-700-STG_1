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
  <!-- <div class="hidden flex-col md:flex"> -->
  <div class=" flex-col flex">
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

    <Div class="hidden flex-col md:flex">
      <!-- Ici chantier du pointage -->
    </Div>

    <!-- Dashboard -->
    <div class="flex-1 space-y-0 p-8 pt-6">
      <div class="flex items-center flex-wrap  space-y-2">
        <h2 class="text-3xl font-bold tracking-tight">
          Tableau de bord
        </h2>

        <Card class="h-28 ml-auto xl:ml-32 min-w-52">
          <CardHeader class="flex flex-row items-center space-y-0 pb-1 ml-auto px-6 pt-3">
            <CardTitle v-if="!clock_value" class="text-xl font-bold">Clock in</CardTitle>
            <p v-else class="text-xs text-muted-foreground">Clock in</p>
          </CardHeader>
          <CardContent>
            <div class="text-2xl font-bold text-primary flex">
              {{ current_time || "..." }}
              <Switch vsl class="mt-2 ml-auto" :disabled="clock_diable" :checked="clock_value"
                @update:checked="handleChangeClock" />
            </div>
            <CardTitle v-if="clock_value" class="text-xl font-bold pt-1">Clock out</CardTitle>
            <p v-else class="text-xs text-muted-foreground pt-1">Clock out</p>
          </CardContent>
        </Card>
        <div class="flex flex-row flex-wrap items-end space-x-2 ml-auto">
          <DateRangePicker />
          <Button class="sm:mt-3">Appliquer</Button>
        </div>
      </div>

      <!-- <p class="text-xl tracking-tight"> -->
      <!--   Vous trouverez ici vos informations de pointage -->
      <!-- </p> -->
      <Tabs default-value="overview" class="space-y-4">
        <TabsList>
          <TabsTrigger value="today">
            Today
          </TabsTrigger>
          <TabsTrigger value="overview">
            Overview
          </TabsTrigger>
        </TabsList>

        <TabsContent value="overview" class="space-y-4">
          <!-- Première partie : les trois Cards en haut à gauche, occupant 70% de l'écran -->
          <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-10">
            <!-- Colonne principale (70%) -->
            <div class="col-span-7 space-y-4">
              <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <Card>
                  <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle class="text-sm font-medium">Heures Travaillées Aujourd'hui</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div class="text-2xl font-bold text-primary">8h 30m</div>
                    <p class="text-xs text-muted-foreground">Heures travaillées aujourd'hui</p>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle class="text-sm font-medium">Heures Travaillées Cette Semaine</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div class="text-2xl font-bold">40h 15m</div>
                    <p class="text-xs text-muted-foreground">Heures travaillées cette semaine</p>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle class="text-sm font-medium">Heures Travaillées Ce Mois</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div class="text-2xl font-bold">160h 45m</div>
                    <p class="text-xs text-muted-foreground">Heures travaillées ce mois</p>
                  </CardContent>
                </Card>
              </div>

              <!-- Bloc Overview, en dessous des trois Cards -->
              <Card class="mt-4">
                <CardHeader>
                  <CardTitle>Overview</CardTitle>
                </CardHeader>
                <CardContent class="pl-2">
                  <Overview />
                </CardContent>
              </Card>
            </div>

            <!-- Colonne droite (30%) avec WorkingTime -->
            <div class="col-span-3">
              <Card>
                <CardHeader>
                  <CardTitle>Temps des pointages</CardTitle>
                  <CardDescription>Temps travaillés les X derniers jours.</CardDescription>
                </CardHeader>
                <CardContent class="bottom-p-0">
                  <WorkingTime />
                </CardContent>
              </Card>
            </div>
          </div>
        </TabsContent>

      </Tabs>
    </div>
  </div>
</template>
