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
import { onMounted, ref, watch } from 'vue'

const user = ref(null); // user starts as null

onMounted(async () => {
  user.value = await getUser(1);
  console.log(user.value.data);
  console.log('test');
});

</script>

<template>
  <!-- NavBar + Team recherche -->
  <div class="hidden flex-col md:flex">
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
    <div class="flex-1 space-y-4 p-8 pt-6">
      <div class="flex items-center justify-between space-y-2">
        <h2 class="text-3xl font-bold tracking-tight">
          Tableau de bord
        </h2>
        <div class="flex items-center space-x-2">
          <DateRangePicker />
          <Button>Appliquer</Button>
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
              <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                <Card>
                  <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle class="text-sm font-medium">Heures Travaillées Aujourd'hui</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div class="text-2xl font-bold text-green-500">8h 30m</div>
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
