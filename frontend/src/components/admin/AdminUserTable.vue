<script setup lang="ts">
import { ref, computed } from 'vue'
import { useBreakpoint } from '@/composables/useBreakpoint'
import { type User } from '@/components/store/userStore'
import { Badge } from '@/components/ui/badge'
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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Pencil,
  Trash2,
  Clock,
  BarChart3,
  ChevronDown,
  ChevronUp,
  ArrowLeft,
  ArrowRight,
} from 'lucide-vue-next'

interface Props {
  users: User[]
  currentUserRole: string
  canManageRoles: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  edit: [user: User]
  delete: [user: User]
  'manage-working-time': [user: User]
  'view-dashboard': [user: User]
  'role-change': [user: User, newRole: string]
}>()

const { isDesktop } = useBreakpoint()

const currentPage = ref(1)
const pageSize = 10
const expandedUserId = ref<number | null>(null)

const totalPages = computed(() => Math.max(1, Math.ceil(props.users.length / pageSize)))

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return props.users.slice(start, start + pageSize)
})

function toggleExpand(userId: number) {
  expandedUserId.value = expandedUserId.value === userId ? null : userId
}

function goToPage(page: number) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    expandedUserId.value = null
  }
}

function handleRoleChange(user: User, newRole: string) {
  if (newRole !== user.role) {
    emit('role-change', user, newRole)
  }
}

function getRoleBadgeVariant(role: string): 'default' | 'secondary' | 'warning' | 'success' {
  switch (role) {
    case 'general_manager':
      return 'default'
    case 'manager':
      return 'warning'
    default:
      return 'secondary'
  }
}

function getRoleLabel(role: string): string {
  switch (role) {
    case 'general_manager':
      return 'General Manager'
    case 'manager':
      return 'Manager'
    default:
      return 'User'
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
            <TableHead>Username</TableHead>
            <TableHead>Email</TableHead>
            <TableHead>Role</TableHead>
            <TableHead class="text-right">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow
            v-for="user in paginatedUsers"
            :key="user.id"
          >
            <TableCell class="font-medium">{{ user.username }}</TableCell>
            <TableCell class="text-muted-foreground">{{ user.email }}</TableCell>
            <TableCell>
              <Select
                v-if="canManageRoles"
                :model-value="user.role"
                @update:model-value="(val: string) => handleRoleChange(user, val)"
              >
                <SelectTrigger class="w-[10rem]" :aria-label="`Change role for ${user.username}`">
                  <SelectValue :placeholder="getRoleLabel(user.role)" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="user">User</SelectItem>
                  <SelectItem value="manager">Manager</SelectItem>
                  <SelectItem value="general_manager">General Manager</SelectItem>
                </SelectContent>
              </Select>
              <Badge v-else :variant="getRoleBadgeVariant(user.role)">
                {{ getRoleLabel(user.role) }}
              </Badge>
            </TableCell>
            <TableCell class="text-right">
              <div class="flex items-center justify-end gap-1">
                <Button
                  variant="ghost"
                  size="icon-sm"
                  :aria-label="`Edit ${user.username}`"
                  @click="emit('edit', user)"
                >
                  <Pencil class="h-4 w-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon-sm"
                  :aria-label="`Working time for ${user.username}`"
                  @click="emit('manage-working-time', user)"
                >
                  <Clock class="h-4 w-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon-sm"
                  :aria-label="`Dashboard for ${user.username}`"
                  @click="emit('view-dashboard', user)"
                >
                  <BarChart3 class="h-4 w-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon-sm"
                  class="text-destructive hover:text-destructive"
                  :aria-label="`Delete ${user.username}`"
                  @click="emit('delete', user)"
                >
                  <Trash2 class="h-4 w-4" />
                </Button>
              </div>
            </TableCell>
          </TableRow>
          <TableRow v-if="paginatedUsers.length === 0">
            <TableCell :colspan="4" class="text-center py-8 text-muted-foreground">
              No users found
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>

    <!-- Mobile card view -->
    <div v-else class="space-y-3">
      <article
        v-for="(user, index) in paginatedUsers"
        :key="user.id"
        class="rounded-xl bg-card shadow-card border p-4 animate-fade-in-up"
        :style="{ animationDelay: `${index * 50}ms` }"
      >
        <button
          class="flex items-center justify-between w-full min-h-touch text-left"
          :aria-expanded="expandedUserId === user.id"
          :aria-label="`${user.username}, ${getRoleLabel(user.role)}. Tap to ${expandedUserId === user.id ? 'collapse' : 'expand'} details`"
          @click="toggleExpand(user.id)"
        >
          <div class="flex items-center gap-3 min-w-0">
            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary font-semibold text-sm">
              {{ user.username.charAt(0).toUpperCase() }}
            </div>
            <div class="min-w-0">
              <p class="font-medium truncate">{{ user.username }}</p>
              <p class="text-sm text-muted-foreground truncate">{{ user.email }}</p>
            </div>
          </div>
          <div class="flex items-center gap-2 shrink-0 ml-2">
            <Badge :variant="getRoleBadgeVariant(user.role)" size="sm">
              {{ getRoleLabel(user.role) }}
            </Badge>
            <ChevronUp v-if="expandedUserId === user.id" class="h-4 w-4 text-muted-foreground" />
            <ChevronDown v-else class="h-4 w-4 text-muted-foreground" />
          </div>
        </button>

        <!-- Expanded actions -->
        <Transition name="expand">
          <div
            v-if="expandedUserId === user.id"
            class="mt-3 pt-3 border-t space-y-3"
          >
            <!-- Role management -->
            <div v-if="canManageRoles" class="flex items-center justify-between">
              <span class="text-sm text-muted-foreground">Role</span>
              <Select
                :model-value="user.role"
                @update:model-value="(val: string) => handleRoleChange(user, val)"
              >
                <SelectTrigger class="w-[10rem]" :aria-label="`Change role for ${user.username}`">
                  <SelectValue :placeholder="getRoleLabel(user.role)" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="user">User</SelectItem>
                  <SelectItem value="manager">Manager</SelectItem>
                  <SelectItem value="general_manager">General Manager</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <!-- Action buttons -->
            <div class="grid grid-cols-2 gap-2">
              <Button
                variant="outline"
                size="sm"
                class="min-h-touch"
                @click="emit('edit', user)"
              >
                <Pencil class="h-4 w-4 mr-2" />
                Edit
              </Button>
              <Button
                variant="outline"
                size="sm"
                class="min-h-touch"
                @click="emit('manage-working-time', user)"
              >
                <Clock class="h-4 w-4 mr-2" />
                Hours
              </Button>
              <Button
                variant="outline"
                size="sm"
                class="min-h-touch"
                @click="emit('view-dashboard', user)"
              >
                <BarChart3 class="h-4 w-4 mr-2" />
                Dashboard
              </Button>
              <Button
                variant="destructive"
                size="sm"
                class="min-h-touch"
                @click="emit('delete', user)"
              >
                <Trash2 class="h-4 w-4 mr-2" />
                Delete
              </Button>
            </div>
          </div>
        </Transition>
      </article>

      <p
        v-if="paginatedUsers.length === 0"
        class="text-center py-8 text-muted-foreground"
      >
        No users found
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
