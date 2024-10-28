// @ts-nocheck
// @ts-ignore

<script setup lang="ts">
import { onMounted, ref } from 'vue'

import { cn } from '../lib/utils'
import { Button } from './ui/button'

import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from './ui/command'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from './ui/popover'
import { Team } from '../api/apiTeams'
import { useTeamStore } from './store/teamStore'

const teams = ref<Team[]>([]);

const open = ref(false)
const selectedTeam = ref<Team>();
const teamStore = useTeamStore();
onMounted(() => {
  
  teams.value = teamStore.accessibleTeams;
  selectedTeam.value = teamStore.currentTeam;
})

const emit = defineEmits(['teamChange'])

</script>

<template>
    <Popover v-model:open="open">
      <PopoverTrigger as-child>
        <Button variant="outline" role="combobox" aria-expanded="open" aria-label="Select a team"
          :class="cn('w-[200px] justify-between', $attrs.class ?? '')">
          {{ selectedTeam?.name }}
          <!-- <CaretSortIcon class="ml-auto h-4 w-4 shrink-0 opacity-50" /> -->
        </Button>
      </PopoverTrigger>
      <PopoverContent class="w-[200px] p-0">
        <!-- @vue-ignore -->
        <Command :filter-function="(list, term) => list.filter(i => i.name?.toLowerCase()?.includes(term))">
          <CommandList>
            <CommandInput placeholder="Search team..." />
            <CommandEmpty>No team found.</CommandEmpty>
            <CommandGroup>
              <CommandItem v-for="team in teams" :key="team.id" :value="team" class="text-sm" @select="() => {
                if(teamStore.setCurrentTeam(team)) 
                {
                  selectedTeam = teamStore.currentTeam;
                  emit('teamChange');
                }
                
                open = false;
              }">
                {{ team.name }}
                <!-- <CheckIcon :class="cn('ml-auto h-4 w-4', -->
                <!--   selectedTeam.value === team.value -->
                <!--     ? 'opacity-100' -->
                <!--     : 'opacity-0', -->
                <!-- )" /> -->
              </CommandItem>
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
</template>
