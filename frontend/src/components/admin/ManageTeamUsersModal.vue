<script setup lang="ts">
import { ref, watch } from 'vue'
import { useBreakpoint } from '@/composables/useBreakpoint'
import { type User } from '@/components/store/userStore'
import { type Team } from '@/api/apiTeams'
import { getAllUser } from '@/api/apiUser'
import { getAllUsersFromTeam, addUserInTeam, deleteUserInTeam } from '@/api/apiManage'
import ResponsiveModal from '@/components/ui/modal/ResponsiveModal.vue'
import Button from '@/components/ui/button/Button.vue'
import { UserPlus, UserMinus } from 'lucide-vue-next'

interface Props {
  open: boolean
  team: Team
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:open': [value: boolean]
}>()

const { isDesktop } = useBreakpoint()

const allUsers = ref<User[]>([])
const teamUsers = ref<User[]>([])
const loading = ref(false)

const selectedAvailable = ref<Set<number>>(new Set())
const selectedInTeam = ref<Set<number>>(new Set())

watch(
  () => [props.open, props.team?.id],
  async ([isOpen]) => {
    if (isOpen && props.team) {
      await loadData()
    }
  },
)

async function loadData() {
  loading.value = true
  selectedAvailable.value = new Set()
  selectedInTeam.value = new Set()

  try {
    const [users, members] = await Promise.all([
      getAllUser(),
      getAllUsersFromTeam(props.team),
    ])

    allUsers.value = users ?? []
    teamUsers.value = members ?? []
  } catch {
    allUsers.value = []
    teamUsers.value = []
  } finally {
    loading.value = false
  }
}

function availableUsers(): User[] {
  const teamUserIds = new Set(teamUsers.value.map((u) => u.id))
  return allUsers.value.filter((u) => !teamUserIds.has(u.id))
}

function toggleAvailable(userId: number) {
  const newSet = new Set(selectedAvailable.value)
  if (newSet.has(userId)) {
    newSet.delete(userId)
  } else {
    newSet.add(userId)
  }
  selectedAvailable.value = newSet
}

function toggleInTeam(userId: number) {
  const newSet = new Set(selectedInTeam.value)
  if (newSet.has(userId)) {
    newSet.delete(userId)
  } else {
    newSet.add(userId)
  }
  selectedInTeam.value = newSet
}

async function addSelected() {
  if (selectedAvailable.value.size === 0) return

  loading.value = true
  try {
    const usersToAdd = allUsers.value.filter((u) => selectedAvailable.value.has(u.id))
    await Promise.all(usersToAdd.map((user) => addUserInTeam(user, props.team)))
    selectedAvailable.value = new Set()
    await loadData()
  } catch {
    // Error handled silently - API functions already log errors
  } finally {
    loading.value = false
  }
}

async function removeSelected() {
  if (selectedInTeam.value.size === 0) return

  loading.value = true
  try {
    const usersToRemove = teamUsers.value.filter((u) => selectedInTeam.value.has(u.id))
    await Promise.all(usersToRemove.map((user) => deleteUserInTeam(user, props.team)))
    selectedInTeam.value = new Set()
    await loadData()
  } catch {
    // Error handled silently - API functions already log errors
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <ResponsiveModal
    :open="open"
    :title="`Manage Members — ${team?.name ?? ''}`"
    @update:open="emit('update:open', $event)"
  >
    <div v-if="loading" class="flex items-center justify-center py-12">
      <div class="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
    </div>

    <div v-else>
      <!-- Desktop: two columns side by side -->
      <div v-if="isDesktop" class="flex gap-4">
        <!-- Available users -->
        <div class="flex-1">
          <h3 class="text-sm font-medium text-muted-foreground mb-2">
            Not in team ({{ availableUsers().length }})
          </h3>
          <div class="border rounded-lg max-h-64 overflow-y-auto">
            <button
              v-for="user in availableUsers()"
              :key="user.id"
              class="flex items-center gap-3 w-full px-3 py-2 text-left text-sm transition-colors hover:bg-accent min-h-[2.75rem]"
              :class="{ 'bg-primary/10 text-primary': selectedAvailable.has(user.id) }"
              :aria-label="`Select ${user.username}`"
              :aria-pressed="selectedAvailable.has(user.id)"
              @click="toggleAvailable(user.id)"
            >
              <div class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-muted text-xs font-medium">
                {{ user.username.charAt(0).toUpperCase() }}
              </div>
              <span class="truncate">{{ user.username }}</span>
            </button>
            <p v-if="availableUsers().length === 0" class="px-3 py-4 text-sm text-muted-foreground text-center">
              No available users
            </p>
          </div>
        </div>

        <!-- Arrow buttons -->
        <div class="flex flex-col items-center justify-center gap-2 py-4">
          <Button
            variant="outline"
            size="icon-sm"
            :disabled="selectedAvailable.size === 0"
            aria-label="Add selected users to team"
            @click="addSelected"
          >
            <UserPlus class="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon-sm"
            :disabled="selectedInTeam.size === 0"
            aria-label="Remove selected users from team"
            @click="removeSelected"
          >
            <UserMinus class="h-4 w-4" />
          </Button>
        </div>

        <!-- Team members -->
        <div class="flex-1">
          <h3 class="text-sm font-medium text-muted-foreground mb-2">
            In team ({{ teamUsers.length }})
          </h3>
          <div class="border rounded-lg max-h-64 overflow-y-auto">
            <button
              v-for="user in teamUsers"
              :key="user.id"
              class="flex items-center gap-3 w-full px-3 py-2 text-left text-sm transition-colors hover:bg-accent min-h-[2.75rem]"
              :class="{ 'bg-destructive/10 text-destructive': selectedInTeam.has(user.id) }"
              :aria-label="`Select ${user.username}`"
              :aria-pressed="selectedInTeam.has(user.id)"
              @click="toggleInTeam(user.id)"
            >
              <div class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary text-xs font-medium">
                {{ user.username.charAt(0).toUpperCase() }}
              </div>
              <span class="truncate">{{ user.username }}</span>
            </button>
            <p v-if="teamUsers.length === 0" class="px-3 py-4 text-sm text-muted-foreground text-center">
              No members yet
            </p>
          </div>
        </div>
      </div>

      <!-- Mobile: stacked sections -->
      <div v-else class="space-y-4">
        <!-- Team members -->
        <section>
          <div class="flex items-center justify-between mb-2">
            <h3 class="text-sm font-medium text-muted-foreground">
              In team ({{ teamUsers.length }})
            </h3>
            <Button
              v-if="selectedInTeam.size > 0"
              variant="destructive"
              size="sm"
              class="min-h-touch"
              @click="removeSelected"
            >
              <UserMinus class="h-4 w-4 mr-1" />
              Remove ({{ selectedInTeam.size }})
            </Button>
          </div>
          <div class="border rounded-xl max-h-48 overflow-y-auto">
            <button
              v-for="user in teamUsers"
              :key="user.id"
              class="flex items-center gap-3 w-full px-3 py-2.5 text-left text-sm transition-colors min-h-touch border-b last:border-b-0"
              :class="{ 'bg-destructive/10': selectedInTeam.has(user.id) }"
              :aria-label="`Select ${user.username}`"
              :aria-pressed="selectedInTeam.has(user.id)"
              @click="toggleInTeam(user.id)"
            >
              <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary text-xs font-medium">
                {{ user.username.charAt(0).toUpperCase() }}
              </div>
              <div class="min-w-0">
                <p class="truncate font-medium">{{ user.username }}</p>
                <p class="text-xs text-muted-foreground truncate">{{ user.email }}</p>
              </div>
            </button>
            <p v-if="teamUsers.length === 0" class="px-3 py-6 text-sm text-muted-foreground text-center">
              No members yet
            </p>
          </div>
        </section>

        <!-- Available users -->
        <section>
          <div class="flex items-center justify-between mb-2">
            <h3 class="text-sm font-medium text-muted-foreground">
              Not in team ({{ availableUsers().length }})
            </h3>
            <Button
              v-if="selectedAvailable.size > 0"
              variant="default"
              size="sm"
              class="min-h-touch"
              @click="addSelected"
            >
              <UserPlus class="h-4 w-4 mr-1" />
              Add ({{ selectedAvailable.size }})
            </Button>
          </div>
          <div class="border rounded-xl max-h-48 overflow-y-auto">
            <button
              v-for="user in availableUsers()"
              :key="user.id"
              class="flex items-center gap-3 w-full px-3 py-2.5 text-left text-sm transition-colors min-h-touch border-b last:border-b-0"
              :class="{ 'bg-primary/10': selectedAvailable.has(user.id) }"
              :aria-label="`Select ${user.username}`"
              :aria-pressed="selectedAvailable.has(user.id)"
              @click="toggleAvailable(user.id)"
            >
              <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-muted text-xs font-medium">
                {{ user.username.charAt(0).toUpperCase() }}
              </div>
              <div class="min-w-0">
                <p class="truncate font-medium">{{ user.username }}</p>
                <p class="text-xs text-muted-foreground truncate">{{ user.email }}</p>
              </div>
            </button>
            <p v-if="availableUsers().length === 0" class="px-3 py-6 text-sm text-muted-foreground text-center">
              No available users
            </p>
          </div>
        </section>
      </div>
    </div>
  </ResponsiveModal>
</template>
