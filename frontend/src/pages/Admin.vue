<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { type User, useUserStore } from '@/components/store/userStore'
import { useTeamStore } from '@/components/store/teamStore'
import { type Team, getAllTeam, createTeam, updateTeam, deleteTeam, clockForTeam } from '@/api/apiTeams'
import { getAllUser, createUserAdmin, updateUser, deleteUser, updateRoleToManager, updateRoleToUser } from '@/api/apiUser'

import AdminUserTable from '@/components/admin/AdminUserTable.vue'
import AdminTeamTable from '@/components/admin/AdminTeamTable.vue'
import UserFormModal from '@/components/admin/UserFormModal.vue'
import TeamFormModal from '@/components/admin/TeamFormModal.vue'
import ManageTeamUsersModal from '@/components/admin/ManageTeamUsersModal.vue'
import AdminFilters from '@/components/admin/AdminFilters.vue'

import Button from '@/components/ui/button/Button.vue'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import { Plus, Clock, Users, Settings } from 'lucide-vue-next'

const router = useRouter()
const userStore = useUserStore()
const teamStore = useTeamStore()
const activeTab = ref('users')
const users = ref<User[]>([])
const teams = ref<Team[]>([])
const loading = ref(false)

// Modal states
const userModalOpen = ref(false)
const teamModalOpen = ref(false)
const manageUsersModalOpen = ref(false)
const editingUser = ref<User | null>(null)
const editingTeam = ref<Team | null>(null)
const managingTeam = ref<Team | null>(null)

const currentUser = computed(() => userStore.user)
const isGeneralManager = computed(() => currentUser.value?.role === 'general_manager')
const canManageRoles = computed(() => isGeneralManager.value)

const currentFilterTeam = computed(() => teamStore.currentTeam)
const accessibleTeams = computed(() => teamStore.accessibleTeams)

// Data loading
async function loadUsers() {
  loading.value = true
  try {
    const data = await getAllUser()
    users.value = data ?? []
  } catch {
    users.value = []
  } finally {
    loading.value = false
  }
}

async function loadTeams() {
  loading.value = true
  try {
    const data = await getAllTeam()
    teams.value = data ?? []
  } catch {
    teams.value = []
  } finally {
    loading.value = false
  }
}

async function loadAllData() {
  await Promise.all([loadUsers(), loadTeams()])
}

// User CRUD
function openCreateUser() {
  editingUser.value = null
  userModalOpen.value = true
}

function openEditUser(user: User) {
  editingUser.value = user
  userModalOpen.value = true
}

async function handleSaveUser(data: { username: string; email: string }) {
  try {
    if (editingUser.value) {
      const updatedUser: User = {
        ...editingUser.value,
        username: data.username,
        email: data.email,
      }
      await updateUser(updatedUser)
    } else {
      await createUserAdmin({
        username: data.username,
        email: data.email,
      } as User)
    }
    userModalOpen.value = false
    await loadUsers()
  } catch {
    // Error handled by API functions
  }
}

async function handleDeleteUser(user: User) {
  const confirmed = window.confirm(`Are you sure you want to delete ${user.username}?`)
  if (!confirmed) return

  try {
    await deleteUser(user)
    await loadUsers()
  } catch {
    // Error handled by API functions
  }
}

async function handleRoleChange(user: User, newRole: string) {
  try {
    if (newRole === 'manager') {
      await updateRoleToManager(user.id)
    } else if (newRole === 'user') {
      await updateRoleToUser(user.id)
    }
    await loadUsers()
  } catch {
    // Error handled by API functions
  }
}

function handleManageWorkingTime(user: User) {
  router.push(`/dashboard?user_id=${user.id}`)
}

function handleViewDashboard(user: User) {
  router.push(`/dashboard?user_id=${user.id}`)
}

// Team CRUD
function openCreateTeam() {
  editingTeam.value = null
  teamModalOpen.value = true
}

function openEditTeam(team: Team) {
  editingTeam.value = team
  teamModalOpen.value = true
}

async function handleSaveTeam(data: { name: string; description: string }) {
  try {
    if (editingTeam.value) {
      const updatedTeam: Team = {
        ...editingTeam.value,
        name: data.name,
        description: data.description,
      }
      await updateTeam(updatedTeam)
    } else {
      await createTeam({
        name: data.name,
        description: data.description,
      } as Team)
    }
    teamModalOpen.value = false
    await loadTeams()
    await teamStore.populateTeamStore()
  } catch {
    // Error handled by API functions
  }
}

async function handleDeleteTeam(team: Team) {
  const confirmed = window.confirm(`Are you sure you want to delete team "${team.name}"?`)
  if (!confirmed) return

  try {
    await deleteTeam(team)
    await loadTeams()
    await teamStore.populateTeamStore()
  } catch {
    // Error handled by API functions
  }
}

function openManageTeamUsers(team: Team) {
  managingTeam.value = team
  manageUsersModalOpen.value = true
}

// Team clock
async function handleClockInTeam() {
  const team = currentFilterTeam.value
  if (!team || team.id === -1) return

  try {
    await clockForTeam(team, true)
  } catch {
    // Error handled by API functions
  }
}

async function handleClockOutTeam() {
  const team = currentFilterTeam.value
  if (!team || team.id === -1) return

  try {
    await clockForTeam(team, false)
  } catch {
    // Error handled by API functions
  }
}

function handleTeamFilterChange(team: Team | undefined) {
  if (team) {
    teamStore.setCurrentTeam(team)
  }
}

function handleCreate() {
  if (activeTab.value === 'users') {
    openCreateUser()
  } else {
    openCreateTeam()
  }
}

onMounted(loadAllData)
</script>

<template>
  <main class="min-h-screen-dvh bg-background">
    <div class="container mx-auto px-4 py-6 lg:py-8 max-w-7xl">
      <!-- Header -->
      <header class="mb-6">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h1 class="text-fluid-2xl font-bold">Administration</h1>
            <p class="text-sm text-muted-foreground mt-1">
              Manage users, teams, and roles
            </p>
          </div>
          <Button
            size="sm"
            class="min-h-touch gap-2"
            @click="handleCreate"
          >
            <Plus class="h-4 w-4" />
            <span class="hidden sm:inline">
              {{ activeTab === 'users' ? 'New User' : 'New Team' }}
            </span>
          </Button>
        </div>

        <!-- Filters row -->
        <div class="flex items-center justify-between gap-3 flex-wrap">
          <AdminFilters
            v-if="accessibleTeams.length > 0"
            :teams="accessibleTeams"
            :current-team="currentFilterTeam"
            @team-change="handleTeamFilterChange"
          />

          <!-- Team clock actions -->
          <div
            v-if="currentFilterTeam && currentFilterTeam.id !== -1"
            class="flex items-center gap-2"
          >
            <Button
              variant="success"
              size="sm"
              class="min-h-touch gap-2"
              @click="handleClockInTeam"
            >
              <Clock class="h-4 w-4" />
              <span class="hidden sm:inline">Clock In Team</span>
              <span class="sm:hidden">In</span>
            </Button>
            <Button
              variant="warning"
              size="sm"
              class="min-h-touch gap-2"
              @click="handleClockOutTeam"
            >
              <Clock class="h-4 w-4" />
              <span class="hidden sm:inline">Clock Out Team</span>
              <span class="sm:hidden">Out</span>
            </Button>
          </div>
        </div>
      </header>

      <!-- Tabs -->
      <Tabs v-model="activeTab" class="w-full">
        <TabsList class="w-full sm:w-auto mb-4">
          <TabsTrigger value="users" class="flex-1 sm:flex-none min-h-touch gap-2">
            <Users class="h-4 w-4" />
            Users
          </TabsTrigger>
          <TabsTrigger value="teams" class="flex-1 sm:flex-none min-h-touch gap-2">
            <Settings class="h-4 w-4" />
            Teams
          </TabsTrigger>
        </TabsList>

        <!-- Loading state -->
        <div v-if="loading" class="flex items-center justify-center py-16">
          <div class="h-10 w-10 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>

        <template v-else>
          <TabsContent value="users">
            <AdminUserTable
              :users="users"
              :current-user-role="currentUser?.role ?? 'user'"
              :can-manage-roles="canManageRoles"
              @edit="openEditUser"
              @delete="handleDeleteUser"
              @manage-working-time="handleManageWorkingTime"
              @view-dashboard="handleViewDashboard"
              @role-change="handleRoleChange"
            />
          </TabsContent>

          <TabsContent value="teams">
            <AdminTeamTable
              :teams="teams"
              @edit="openEditTeam"
              @delete="handleDeleteTeam"
              @manage-users="openManageTeamUsers"
            />
          </TabsContent>
        </template>
      </Tabs>
    </div>

    <!-- Modals -->
    <UserFormModal
      :open="userModalOpen"
      :user="editingUser"
      @update:open="userModalOpen = $event"
      @save="handleSaveUser"
    />

    <TeamFormModal
      :open="teamModalOpen"
      :team="editingTeam"
      @update:open="teamModalOpen = $event"
      @save="handleSaveTeam"
    />

    <ManageTeamUsersModal
      v-if="managingTeam"
      :open="manageUsersModalOpen"
      :team="managingTeam"
      @update:open="manageUsersModalOpen = $event"
    />
  </main>
</template>
