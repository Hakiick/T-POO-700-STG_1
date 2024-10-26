// @ts-nocheck
// @ts-ignore

<script setup lang="ts">
import { onMounted, ref } from 'vue'

import { cn } from '../lib/utils'
import {
  Avatar,
  AvatarFallback,
  AvatarImage,
} from './ui/avatar'
import { Button } from './ui/button'

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from './ui/dialog'
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList, CommandSeparator } from './ui/command'
import { Input } from './ui/input'
import { Label } from './ui/label'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from './ui/popover'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './ui/select'
import { Team } from '../api/apiTeams'
import { useTeamStore } from './store/teamStore'

const teams = ref<Team[]>([]);

const open = ref(false)
const showNewTeamDialog = ref(false)
const selectedTeam = ref<Team>();

onMounted(() => {
  const teamStore = useTeamStore();
  teams.value = teamStore.accessibleTeams;
  selectedTeam.value = teamStore.currentTeam;
  console.log(teamStore.currentTeam);
  console.log(teams.value, selectedTeam.value)
})
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
                selectedTeam = team
                open = false
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
