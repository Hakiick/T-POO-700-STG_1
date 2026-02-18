<script setup lang="ts">
import { ref, watch } from "vue";
import { Team } from "../../api/apiTeams.ts";
import { User } from "../store/userStore.ts";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogHeader,
  DialogFooter,
  DialogDescription,
  DialogTitle,
} from "../ui/dialog";
import Button from "../ui/button/Button.vue";
import { getAllUser } from "../../api/apiUser.ts";
import {
  addUserInTeam,
  deleteUserInTeam,
  getAllUsersFromTeam,
} from "../../api/apiManage.ts";
import { ScrollArea } from "../ui/scroll-area";
import { ThickArrowLeftIcon, ThickArrowRightIcon, ThickArrowUpIcon, ThickArrowDownIcon } from "@radix-icons/vue";

const props = defineProps<{
  team: Team;
  open: boolean;
}>();

const users = ref<User[]>([]);
const usersInTeam = ref<User[]>([]);
const selectedUsers = ref<number[]>([]);

const emit = defineEmits(["close"]);

function getRoleBadgeClasses(role: string): string {
  switch (role) {
    case "general_manager":
      return "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200";
    case "manager":
      return "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200";
    default:
      return "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200";
  }
}

function formatRoleLabel(role: string): string {
  switch (role) {
    case "general_manager":
      return "GM";
    case "manager":
      return "Mgr";
    default:
      return "User";
  }
}

function toggleUserSelection(userId: number) {
  const index = selectedUsers.value.indexOf(userId);
  if (index === -1) {
    selectedUsers.value = [...selectedUsers.value, userId];
  } else {
    selectedUsers.value = selectedUsers.value.filter((id) => id !== userId);
  }
}

function isSelected(userId: number): boolean {
  return selectedUsers.value.includes(userId);
}

async function fetchAllData() {
  const [allUsers, teamUsers] = await Promise.all([
    getAllUser(),
    getAllUsersFromTeam(props.team),
  ]);
  usersInTeam.value = teamUsers ?? [];
  const teamUserIds = new Set(usersInTeam.value.map((u) => u.id));
  users.value = (allUsers ?? []).filter((u) => !teamUserIds.has(u.id));
  selectedUsers.value = [];
}

async function addUsersToTeam() {
  const usersToAdd = users.value.filter((u) =>
    selectedUsers.value.includes(u.id)
  );
  if (usersToAdd.length === 0) return;

  const results = await Promise.all(
    usersToAdd.map((u) => addUserInTeam(u, props.team))
  );

  const hasSuccess = results.some((result) => result);
  if (hasSuccess) {
    const addedIds = new Set(usersToAdd.map((u) => u.id));
    users.value = users.value.filter((u) => !addedIds.has(u.id));
    usersInTeam.value = [...usersInTeam.value, ...usersToAdd];
    selectedUsers.value = [];
  }
}

async function removeUsersFromTeam() {
  const usersToRemove = usersInTeam.value.filter((u) =>
    selectedUsers.value.includes(u.id)
  );
  if (usersToRemove.length === 0) return;

  const results = await Promise.all(
    usersToRemove.map((u) => deleteUserInTeam(u, props.team))
  );

  const hasSuccess = results.some((result) => result);
  if (hasSuccess) {
    const removedIds = new Set(usersToRemove.map((u) => u.id));
    usersInTeam.value = usersInTeam.value.filter((u) => !removedIds.has(u.id));
    users.value = [...users.value, ...usersToRemove];
    selectedUsers.value = [];
  }
}

watch(() => props.team?.id ?? -1, fetchAllData);
</script>

<template>
  <Dialog
    :open="props.open"
    @update:open="(val: boolean) => { if (!val) emit('close'); }"
  >
    <DialogContent
      class="w-[calc(100vw-1rem)] h-[calc(100vh-2rem)] md:w-auto md:h-auto md:max-w-[50vw] md:min-w-[37.5rem] md:max-h-[85vh]"
    >
      <DialogHeader class="p-4 pb-0 md:p-6 md:pb-0">
        <DialogTitle>
          Users in team {{ props.team?.name ?? "" }}
        </DialogTitle>
        <DialogDescription>
          Add or remove users from this team
        </DialogDescription>
      </DialogHeader>

      <div class="flex-1 overflow-hidden px-4 py-2 md:px-6 md:py-4">
        <!-- Mobile: Stacked vertical layout -->
        <div class="flex flex-col gap-3 h-full md:hidden">
          <!-- Not in team panel -->
          <section class="flex-1 min-h-0" aria-label="Users not in team">
            <h4 class="mb-2 text-sm font-medium leading-none">Not in team</h4>
            <ScrollArea class="h-40 rounded-md border">
              <div class="p-2">
                <button
                  v-for="userItem in users"
                  :key="userItem.id"
                  type="button"
                  class="flex w-full items-center justify-between rounded-md border p-3 mb-2 min-h-[2.75rem] text-left transition-colors last:mb-0"
                  :class="isSelected(userItem.id) ? 'bg-primary/20 border-primary' : 'hover:bg-muted'"
                  :aria-label="`Select ${userItem.username}`"
                  :aria-pressed="isSelected(userItem.id)"
                  @click="toggleUserSelection(userItem.id)"
                >
                  <span class="text-sm font-medium">{{ userItem.username }}</span>
                  <span
                    class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium"
                    :class="getRoleBadgeClasses(userItem.role)"
                  >
                    {{ formatRoleLabel(userItem.role) }}
                  </span>
                </button>
                <p
                  v-if="users.length === 0"
                  class="text-center text-sm text-muted-foreground py-4"
                >
                  No available users
                </p>
              </div>
            </ScrollArea>
          </section>

          <!-- Transfer buttons (horizontal, centered) -->
          <div class="flex items-center justify-center gap-4">
            <Button
              variant="outline"
              class="min-h-[2.75rem] min-w-[2.75rem]"
              aria-label="Move selected users out of team"
              @click="removeUsersFromTeam"
            >
              <ThickArrowUpIcon class="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              class="min-h-[2.75rem] min-w-[2.75rem]"
              aria-label="Move selected users into team"
              @click="addUsersToTeam"
            >
              <ThickArrowDownIcon class="h-4 w-4" />
            </Button>
          </div>

          <!-- In team panel -->
          <section class="flex-1 min-h-0" aria-label="Users in team">
            <h4 class="mb-2 text-sm font-medium leading-none">In team</h4>
            <ScrollArea class="h-40 rounded-md border">
              <div class="p-2">
                <button
                  v-for="userItem in usersInTeam"
                  :key="userItem.id"
                  type="button"
                  class="flex w-full items-center justify-between rounded-md border p-3 mb-2 min-h-[2.75rem] text-left transition-colors last:mb-0"
                  :class="isSelected(userItem.id) ? 'bg-primary/20 border-primary' : 'hover:bg-muted'"
                  :aria-label="`Select ${userItem.username}`"
                  :aria-pressed="isSelected(userItem.id)"
                  @click="toggleUserSelection(userItem.id)"
                >
                  <span class="text-sm font-medium">{{ userItem.username }}</span>
                  <span
                    class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium"
                    :class="getRoleBadgeClasses(userItem.role)"
                  >
                    {{ formatRoleLabel(userItem.role) }}
                  </span>
                </button>
                <p
                  v-if="usersInTeam.length === 0"
                  class="text-center text-sm text-muted-foreground py-4"
                >
                  No users in team
                </p>
              </div>
            </ScrollArea>
          </section>
        </div>

        <!-- Desktop: Side-by-side layout -->
        <div class="hidden md:flex md:gap-2 md:h-full">
          <!-- Not in team panel -->
          <section class="flex-1" aria-label="Users not in team">
            <ScrollArea class="h-96 rounded-md border">
              <div class="p-4">
                <h4 class="mb-4 text-sm font-medium leading-none">Not in team</h4>
              </div>
              <div class="px-2 pb-2">
                <button
                  v-for="userItem in users"
                  :key="userItem.id"
                  type="button"
                  class="flex w-full items-center justify-between rounded-md border p-3 mb-2 min-h-[2.75rem] text-left transition-colors last:mb-0"
                  :class="isSelected(userItem.id) ? 'bg-primary/20 border-primary' : 'hover:bg-muted'"
                  :aria-label="`Select ${userItem.username}`"
                  :aria-pressed="isSelected(userItem.id)"
                  @click="toggleUserSelection(userItem.id)"
                >
                  <span class="text-sm font-medium">{{ userItem.username }}</span>
                  <span
                    class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium"
                    :class="getRoleBadgeClasses(userItem.role)"
                  >
                    {{ formatRoleLabel(userItem.role) }}
                  </span>
                </button>
                <p
                  v-if="users.length === 0"
                  class="text-center text-sm text-muted-foreground py-4"
                >
                  No available users
                </p>
              </div>
            </ScrollArea>
          </section>

          <!-- Transfer buttons (vertical, centered) -->
          <div class="flex flex-col items-center justify-center gap-4">
            <Button
              variant="outline"
              class="min-h-[2.75rem] min-w-[2.75rem]"
              aria-label="Move selected users out of team"
              @click="removeUsersFromTeam"
            >
              <ThickArrowLeftIcon class="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              class="min-h-[2.75rem] min-w-[2.75rem]"
              aria-label="Move selected users into team"
              @click="addUsersToTeam"
            >
              <ThickArrowRightIcon class="h-4 w-4" />
            </Button>
          </div>

          <!-- In team panel -->
          <section class="flex-1" aria-label="Users in team">
            <ScrollArea class="h-96 rounded-md border">
              <div class="p-4">
                <h4 class="mb-4 text-sm font-medium leading-none">In team</h4>
              </div>
              <div class="px-2 pb-2">
                <button
                  v-for="userItem in usersInTeam"
                  :key="userItem.id"
                  type="button"
                  class="flex w-full items-center justify-between rounded-md border p-3 mb-2 min-h-[2.75rem] text-left transition-colors last:mb-0"
                  :class="isSelected(userItem.id) ? 'bg-primary/20 border-primary' : 'hover:bg-muted'"
                  :aria-label="`Select ${userItem.username}`"
                  :aria-pressed="isSelected(userItem.id)"
                  @click="toggleUserSelection(userItem.id)"
                >
                  <span class="text-sm font-medium">{{ userItem.username }}</span>
                  <span
                    class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium"
                    :class="getRoleBadgeClasses(userItem.role)"
                  >
                    {{ formatRoleLabel(userItem.role) }}
                  </span>
                </button>
                <p
                  v-if="usersInTeam.length === 0"
                  class="text-center text-sm text-muted-foreground py-4"
                >
                  No users in team
                </p>
              </div>
            </ScrollArea>
          </section>
        </div>
      </div>

      <DialogFooter class="p-4 pt-0 md:p-6 md:pt-0">
        <DialogClose as-child>
          <Button aria-label="Close dialog">Close</Button>
        </DialogClose>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
