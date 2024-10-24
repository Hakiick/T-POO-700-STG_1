<script setup lang="ts">
import { Ref, ref, watch } from "vue";
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
import { ThickArrowLeftIcon, ThickArrowRightIcon } from "@radix-icons/vue";

const props = defineProps<{
  team: Team;
  open: boolean;
}>();

const users: Ref<User[], User[]> = ref([]);
const usersInTeam: Ref<User[], User[]> = ref([]);
const selectedUsers: Ref<Number[], Number[]> = ref([]);

async function fetchAllData() {
  let usersArray = await Promise.all([ getAllUser(), getAllUsersFromTeam(props.team)]);
  usersInTeam.value = usersArray[1];
  users.value = usersArray[0].filter((user) => {
    return usersInTeam.value.filter((user1) => user.id == user1.id).length == 0;
  });
  selectedUsers.value = [];
}

async function addUsersInTeam() {
  let usersToAdd = users.value.filter((user) =>
    selectedUsers.value.includes(user.id)
  );

  let updateAll: Promise<boolean>[] = [];
  usersToAdd.forEach((user) => {
    updateAll.push(addUserInTeam(user, props.team));
  });
  let values = await Promise.all(updateAll);

  if (values.reduce((oldValue, newValue) => oldValue || newValue)) {
    users.value = users.value.filter(
      (user) => !selectedUsers.value.includes(user.id)
    );
    usersInTeam.value.forEach((user) => usersToAdd.push(user));
    usersInTeam.value = usersToAdd;

    selectedUsers.value = [];
  }
}

async function removeUsersInTeam() {
  let usersToRemove = usersInTeam.value.filter((user) =>
    selectedUsers.value.includes(user.id)
  );

  let updateAll: Promise<boolean>[] = [];
  usersToRemove.forEach((user) => {
    updateAll.push(deleteUserInTeam(user, props.team));
  });
  let values = await Promise.all(updateAll);

  if (values.reduce((oldValue, newValue) => oldValue || newValue)) {
    usersInTeam.value = usersInTeam.value.filter(
      (user) => !selectedUsers.value.includes(user.id)
    );
    users.value.forEach((user) => usersToRemove.push(user));
    users.value = usersToRemove;
    selectedUsers.value = [];
  }
}

const emit = defineEmits(["close"]);
watch(() => props.team?.id ?? -1, fetchAllData);
</script>

<template>
  <Dialog
    :open="props.open"
    @update:open="
      (val) => {
        if (!val) emit('close');
      }
    "
  >
    <DialogContent class="max-w-[50vw]">
      <DialogHeader class="p-6 pb-0">
        <DialogTitle
          >Users in the team {{ props.team?.name ?? "" }}</DialogTitle
        >
        <DialogDescription>You can change users in team here</DialogDescription>
      </DialogHeader>
      <div class="grid gap-4 py-4 overflow-y-auto px-6">
        <div class="flex">
          <ScrollArea class="h-96 w-1/2 rounded-md border">
            <div class="p-4">
              <h4 class="mb-4 text-sm font-medium leading-none">Not in team</h4>
            </div>

            <div
              v-for="user in users"
              :key="user.id"
              class="sm-text border p-2 m-2"
              :class="{ 'bg-blue-300': selectedUsers.includes(user.id) }"
              :onclick="
                () => {
                  let tempArray = [];
                  selectedUsers.forEach((iSelected) => {
                    if (iSelected != user.id) tempArray.push(iSelected);
                  });
                  if (!selectedUsers.includes(user.id)) tempArray.push(user.id);
                  selectedUsers = tempArray;
                }
              "
            >
              {{ user.username }}
            </div>
          </ScrollArea>
          <div class="place-content-center text-center">
            <Button class="mb-5" :onclick="removeUsersInTeam">
              <ThickArrowLeftIcon />
            </Button>
            <Button :onclick="addUsersInTeam">
              <ThickArrowRightIcon />
            </Button>
          </div>

          <ScrollArea class="h-96 w-1/2 rounded-md border">
            <div class="p-4">
              <h4 class="mb-4 text-sm font-medium leading-none">In team</h4>
            </div>

            <div
              v-for="user in usersInTeam"
              :key="user.id"
              class="sm-text border p-2 m-2"
              :class="{ 'bg-blue-300': selectedUsers.includes(user.id) }"
              :onclick="
                () => {
                  let tempArray = [];
                  selectedUsers.forEach((iSelected) => {
                    if (iSelected != user.id) tempArray.push(iSelected);
                  });
                  if (!selectedUsers.includes(user.id)) tempArray.push(user.id);
                  selectedUsers = tempArray;
                }
              "
            >
              {{ user.username }}
            </div>
          </ScrollArea>
        </div>
      </div>
      <DialogFooter class="p-6 pt-0">
        <DialogClose>
          <Button>Close</Button>
        </DialogClose>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
