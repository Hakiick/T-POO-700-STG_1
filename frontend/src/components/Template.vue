<script setup lang="ts">
defineOptions({
  name: 'HomePage',
  displayName: 'Home Page',
});

import Day from './Day.vue';
import Weekly from './Weekly.vue';
import Monthly from './Monthly.vue';
import { Button } from '@/components/ui/button'
import { Calendar } from './ui/calendar'
import { Popover, PopoverContent, PopoverTrigger } from './ui/popover'
import { cn } from '@/utils'
import { DateFormatter, type DateValue, getLocalTimeZone,} from '@internationalized/date'
import { CalendarIcon } from '@radix-icons/vue'
import MainNav from './MainNav.vue';
import Search from './Search.vue';
import TeamSwitcher from './TeamSwitcher.vue';
import UserNav from './UserNav.vue';
import { getUser } from '../api/apiUser';
import WorkingTime from './WorkingTime.vue';
import { Switch } from './ui/switch';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { onMounted, ref } from 'vue';
import { createClock, getClockFromUser } from '../api/apiClock';
import moment from 'moment';
import { useUserStore } from './store/userStore';
import { AxiosResponse } from 'axios';

type response_clock = AxiosResponse;

const userStore = useUserStore();
const user = ref(userStore.user);
const clocks = ref(null);
const last_clock = ref(null);
const last_clock_value = ref(false);
const clock_diable = ref(false);
const current_time = ref("");
const selectedDateRange = ref(null);

const df = new DateFormatter('fr-FR', {
  dateStyle: 'long',
})
const value = ref<DateValue>()

onMounted(async () => {
  if (!user.value) {
    user.value = await getUser(1);
  }

  const response_clock: response_clock = await getClockFromUser(user.value.id);
  if (response_clock.status === 200) {
    clocks.value = response_clock.data;
    last_clock.value = clocks.value.data;
    last_clock_value.value = last_clock.value.status;
  }

  current_time.value = moment().format('HH[h] mm[m]');
});

const handleChangeClock = async (checked: boolean) => {
  last_clock_value.value = checked;
  clock_diable.value = true;

  await createClock(
    { time: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'), status: last_clock_value.value }, user.value.id
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
            <div class="col-span-1 lg:col-span-7 space-y-4 h-full w-full">
              <Card class="h-full w-full">
                <CardHeader>
                  <CardTitle>Graphique par jour</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full" v-if="user">
                  <Day :user="user" />
                </CardContent>
              </Card>
            </div>
            <div class="col-span-1 lg:col-span-3 h-full w-full">
              <div class="flex items-center justify-center text-center">
                <Popover>
                  <PopoverTrigger as-child>
                    <Button variant="outline" :class="cn(
                      'w-[280px] justify-start text-left font-normal',
                      !value && 'text-muted-foreground',
                    )">
                      <CalendarIcon class="mr-2 h-4 w-4" />
                      {{ value ? df.format(value.toDate(getLocalTimeZone())) : "Pick a date" }}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent class="w-auto p-0">
                    <Calendar v-model="value" initial-focus />
                  </PopoverContent>
                </Popover>
              </div>
              <Card class="h-full w-full mt-3">
                <CardHeader>
                  <CardTitle>Emploi du temps</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full" v-if="user">
                  <WorkingTime :user="user" :selectedDateRange="selectedDateRange" />
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
                  <Weekly :user="user" />
                </CardContent>
              </Card>
            </div>
            <div class="col-span-1 lg:col-span-3 h-full w-full">
              <div class="flex items-center justify-center text-center">
                <DateRangePicker />
              </div>
              <Card class="h-full w-full mt-3">
                <CardHeader>
                  <CardTitle>Emploi du temps</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full" v-if="user">
                  <WorkingTime :user="user" :selectedDateRange="selectedDateRange" />
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
                  <Monthly :user="user" />
                </CardContent>
              </Card>
            </div>
            <div class="col-span-1 lg:col-span-3 h-full w-full">
              <div class="flex items-center justify-center text-center">
                <DateRangePicker />
              </div>
              <Card class="h-full w-full mt-3">
                <CardHeader>
                  <CardTitle>Emploi du temps</CardTitle>
                </CardHeader>
                <CardContent class="bottom-p-0 h-full" v-if="user">
                  <WorkingTime :user="user" :selectedDateRange="selectedDateRange" />
                </CardContent>
              </Card>
            </div>
          </div>
        </TabsContent>

      </Tabs>
    </div>
  </div>
</template>