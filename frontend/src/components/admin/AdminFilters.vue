<script setup lang="ts">
import { ref } from 'vue'
import { useBreakpoint } from '@/composables/useBreakpoint'
import { type Team } from '@/api/apiTeams'
import Button from '@/components/ui/button/Button.vue'
import ResponsiveModal from '@/components/ui/modal/ResponsiveModal.vue'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Filter, ChevronDown } from 'lucide-vue-next'

interface Props {
  teams: Team[]
  currentTeam: Team | undefined
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'team-change': [team: Team | undefined]
}>()

const { isDesktop } = useBreakpoint()
const filterSheetOpen = ref(false)

function handleTeamChange(teamId: string) {
  if (teamId === 'all') {
    const allTeam = props.teams.find((t) => t.id === -1)
    emit('team-change', allTeam)
  } else {
    const team = props.teams.find((t) => t.id === Number(teamId))
    emit('team-change', team)
  }
  filterSheetOpen.value = false
}

function getSelectedTeamValue(): string {
  if (!props.currentTeam) return 'all'
  if (props.currentTeam.id === -1) return 'all'
  return String(props.currentTeam.id)
}
</script>

<template>
  <div>
    <!-- Desktop: inline filter bar -->
    <div v-if="isDesktop" class="flex items-center gap-3">
      <Filter class="h-4 w-4 text-muted-foreground" />
      <span class="text-sm text-muted-foreground">Team:</span>
      <Select
        :model-value="getSelectedTeamValue()"
        @update:model-value="handleTeamChange"
      >
        <SelectTrigger class="w-[12rem]" aria-label="Filter by team">
          <SelectValue :placeholder="currentTeam?.name ?? 'All Teams'" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">All Teams</SelectItem>
          <SelectItem
            v-for="team in teams.filter(t => t.id !== -1)"
            :key="team.id"
            :value="String(team.id)"
          >
            {{ team.name }}
          </SelectItem>
        </SelectContent>
      </Select>
    </div>

    <!-- Mobile: compact button -->
    <div v-else>
      <Button
        variant="outline"
        size="sm"
        class="min-h-touch gap-2"
        aria-label="Filter by team"
        @click="filterSheetOpen = true"
      >
        <Filter class="h-4 w-4" />
        <span class="truncate max-w-[8rem]">{{ currentTeam?.name ?? 'All Teams' }}</span>
        <ChevronDown class="h-3 w-3 text-muted-foreground" />
      </Button>

      <!-- Bottom sheet for mobile team filter -->
      <ResponsiveModal
        :open="filterSheetOpen"
        title="Select Team"
        @update:open="filterSheetOpen = $event"
      >
        <div class="space-y-1">
          <button
            class="flex items-center w-full px-3 py-3 rounded-lg text-left transition-colors min-h-touch"
            :class="{
              'bg-primary/10 text-primary font-medium': !currentTeam || currentTeam.id === -1,
              'hover:bg-accent': currentTeam && currentTeam.id !== -1,
            }"
            @click="handleTeamChange('all')"
          >
            All Teams
          </button>
          <button
            v-for="team in teams.filter(t => t.id !== -1)"
            :key="team.id"
            class="flex items-center w-full px-3 py-3 rounded-lg text-left transition-colors min-h-touch"
            :class="{
              'bg-primary/10 text-primary font-medium': currentTeam?.id === team.id,
              'hover:bg-accent': currentTeam?.id !== team.id,
            }"
            @click="handleTeamChange(String(team.id))"
          >
            {{ team.name }}
          </button>
        </div>
      </ResponsiveModal>
    </div>
  </div>
</template>
