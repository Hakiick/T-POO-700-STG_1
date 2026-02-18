<script setup lang="ts">
import { ref, computed } from 'vue'
import { useBreakpoint } from '@/composables/useBreakpoint'
import { type Team } from '@/api/apiTeams'
import Button from '@/components/ui/button/Button.vue'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  Pencil,
  Trash2,
  Users,
  ChevronDown,
  ChevronUp,
  ArrowLeft,
  ArrowRight,
} from 'lucide-vue-next'

interface Props {
  teams: Team[]
}

const props = defineProps<Props>()

const emit = defineEmits<{
  edit: [team: Team]
  delete: [team: Team]
  'manage-users': [team: Team]
}>()

const { isDesktop } = useBreakpoint()

const currentPage = ref(1)
const pageSize = 10
const expandedTeamId = ref<number | null>(null)

const totalPages = computed(() => Math.max(1, Math.ceil(props.teams.length / pageSize)))

const paginatedTeams = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return props.teams.slice(start, start + pageSize)
})

function toggleExpand(teamId: number) {
  expandedTeamId.value = expandedTeamId.value === teamId ? null : teamId
}

function goToPage(page: number) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    expandedTeamId.value = null
  }
}
</script>

<template>
  <div>
    <!-- Desktop table view -->
    <div v-if="isDesktop" class="rounded-xl border bg-card shadow-card overflow-hidden">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Name</TableHead>
            <TableHead>Description</TableHead>
            <TableHead class="text-right">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow
            v-for="team in paginatedTeams"
            :key="team.id"
          >
            <TableCell class="font-medium">{{ team.name }}</TableCell>
            <TableCell class="text-muted-foreground">
              {{ team.description || 'No description' }}
            </TableCell>
            <TableCell class="text-right">
              <div class="flex items-center justify-end gap-1">
                <Button
                  variant="ghost"
                  size="icon-sm"
                  :aria-label="`Manage members of ${team.name}`"
                  @click="emit('manage-users', team)"
                >
                  <Users class="h-4 w-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon-sm"
                  :aria-label="`Edit ${team.name}`"
                  @click="emit('edit', team)"
                >
                  <Pencil class="h-4 w-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon-sm"
                  class="text-destructive hover:text-destructive"
                  :aria-label="`Delete ${team.name}`"
                  @click="emit('delete', team)"
                >
                  <Trash2 class="h-4 w-4" />
                </Button>
              </div>
            </TableCell>
          </TableRow>
          <TableRow v-if="paginatedTeams.length === 0">
            <TableCell :colspan="3" class="text-center py-8 text-muted-foreground">
              No teams found
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>

    <!-- Mobile card view -->
    <div v-else class="space-y-3">
      <article
        v-for="(team, index) in paginatedTeams"
        :key="team.id"
        class="rounded-xl bg-card shadow-card border p-4 animate-fade-in-up"
        :style="{ animationDelay: `${index * 50}ms` }"
      >
        <button
          class="flex items-center justify-between w-full min-h-touch text-left"
          :aria-expanded="expandedTeamId === team.id"
          :aria-label="`${team.name}. Tap to ${expandedTeamId === team.id ? 'collapse' : 'expand'} details`"
          @click="toggleExpand(team.id)"
        >
          <div class="flex items-center gap-3 min-w-0">
            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary">
              <Users class="h-5 w-5" />
            </div>
            <div class="min-w-0">
              <p class="font-medium truncate">{{ team.name }}</p>
              <p class="text-sm text-muted-foreground truncate">
                {{ team.description || 'No description' }}
              </p>
            </div>
          </div>
          <div class="shrink-0 ml-2">
            <ChevronUp v-if="expandedTeamId === team.id" class="h-4 w-4 text-muted-foreground" />
            <ChevronDown v-else class="h-4 w-4 text-muted-foreground" />
          </div>
        </button>

        <!-- Expanded actions -->
        <Transition name="expand">
          <div
            v-if="expandedTeamId === team.id"
            class="mt-3 pt-3 border-t"
          >
            <div class="grid grid-cols-3 gap-2">
              <Button
                variant="outline"
                size="sm"
                class="min-h-touch"
                @click="emit('manage-users', team)"
              >
                <Users class="h-4 w-4 mr-1" />
                Members
              </Button>
              <Button
                variant="outline"
                size="sm"
                class="min-h-touch"
                @click="emit('edit', team)"
              >
                <Pencil class="h-4 w-4 mr-1" />
                Edit
              </Button>
              <Button
                variant="destructive"
                size="sm"
                class="min-h-touch"
                @click="emit('delete', team)"
              >
                <Trash2 class="h-4 w-4 mr-1" />
                Delete
              </Button>
            </div>
          </div>
        </Transition>
      </article>

      <p
        v-if="paginatedTeams.length === 0"
        class="text-center py-8 text-muted-foreground"
      >
        No teams found
      </p>
    </div>

    <!-- Pagination -->
    <nav
      v-if="totalPages > 1"
      class="flex items-center justify-between pt-4"
      aria-label="Pagination"
    >
      <Button
        variant="outline"
        size="sm"
        class="min-h-touch"
        :disabled="currentPage <= 1"
        aria-label="Previous page"
        @click="goToPage(currentPage - 1)"
      >
        <ArrowLeft class="h-4 w-4 mr-1" />
        Previous
      </Button>
      <span class="text-sm text-muted-foreground">
        Page {{ currentPage }} of {{ totalPages }}
      </span>
      <Button
        variant="outline"
        size="sm"
        class="min-h-touch"
        :disabled="currentPage >= totalPages"
        aria-label="Next page"
        @click="goToPage(currentPage + 1)"
      >
        Next
        <ArrowRight class="h-4 w-4 ml-1" />
      </Button>
    </nav>
  </div>
</template>

<style scoped>
.expand-enter-active {
  transition: all 200ms ease-out;
  overflow: hidden;
}

.expand-leave-active {
  transition: all 150ms ease-in;
  overflow: hidden;
}

.expand-enter-from,
.expand-leave-to {
  opacity: 0;
  transform: translateY(-0.5rem);
}
</style>
