<script setup lang="ts">
import { ref, onMounted, h, computed } from "vue";
import { createUserAdmin, deleteUser, getAllUser, updateRoleToManager, updateRoleToUser, updateUser } from "../api/apiUser.ts";

import {
  FlexRender,
  Row,
  createColumnHelper,
  getCoreRowModel,
  getPaginationRowModel,
  useVueTable,
} from "@tanstack/vue-table";

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "./ui/table";

import TeamSwitcher from "./TeamSwitcher.vue";
import { TrashIcon, PlusIcon, TimerIcon, Pencil2Icon } from "@radix-icons/vue";

import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogDescription
} from "./ui/dialog";
import Input from "./ui/input/Input.vue";
import Label from "./ui/label/Label.vue";
import Button from "./ui/button/Button.vue";
import WorkingTimeModal from "./AdminPanelComponents/WorkingTimeModal.vue";
import { User, useUserStore } from "./store/userStore.ts";
import NavAdmin from "./NavAdmin.vue";
import { getAllUsersFromTeam } from "../api/apiManage.ts";
import { useTeamStore } from "./store/teamStore.ts";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './ui/select'

const user = useUserStore().user;
const users = ref<User[]>([]);
const actionUser = ref<User>({ id: -1, username: "", role: "", email: "" });
const openWorkingTimeModal = ref<boolean>(false);
const openActionUserModal = ref<boolean>(false);
const teamStore = useTeamStore();
const roles = ["manager", "user"];

const fetchAllUsers = async () => {
  const team = teamStore.currentTeam;
  if (team?.id == -1) {
    users.value = await getAllUser();
  }
  else {
    users.value = await getAllUsersFromTeam(teamStore.currentTeam)

  }

};

const deleteUserById = async (id: number) => {
  const user = users.value.find((u) => u.id === id);
  if (user && (await deleteUser(user))) {
    users.value = users.value.filter((u) => u.id !== id);
  }
};

const createOrUpdateElement = async () => {
  let tempUsers: User[] = [];
  if (actionUser.value.id > 0) {
    await updateUser(actionUser.value);
  } else {
    let newUser = await createUserAdmin(actionUser.value);
    console.log(newUser);
    tempUsers.push(newUser);
  }

  let userIndex = users.value.findIndex(
    iUser => iUser.id == actionUser.value.id
  );

  users.value.forEach((value, index) => {
    if (index != userIndex) tempUsers.push(value);
    else tempUsers.push(actionUser.value);
  });

  users.value = tempUsers;
}

const handleRoleChange = async (role: string, row: Row<User>) => {
  // console.log(role, row.getValue("id"));
  if (role === "manager") {
    const resp = await updateRoleToManager(row.getValue("id"));

    if (resp.status !== 200) {
      alert("Error occured");
      window.location.reload();
    }

  } else if (role === "user") {
    const resp = await updateRoleToUser(row.getValue("id"));

    if (resp.status !== 200) {
      alert("Error occured");
      window.location.reload();
    }
  }


  // updateUser(row.original);
};

const resetActionUser = () => {
  actionUser.value = {
    id: -1,
    username: "",
    role: "",
    email: "",
  };
};

onMounted(fetchAllUsers);

const columns = computed(() => {
  const columnHelper = createColumnHelper<User>();
  return [
    columnHelper.accessor("username", {
      header: "Username",
      cell: ({ row }) => h("div", {}, row.getValue("username")),
    }),
    columnHelper.accessor("email", {
      header: "Email",
      cell: ({ row }) => h("div", {}, row.getValue("email")),
    }),
    columnHelper.accessor("role", {
      header: "Role",
      // cell: ({ row }) => h("div", {}, [h(Button, {}, row.getValue("role"))]),
      cell: ({ row }) => h(
        "div",
        {},
        user.role === "general_manager" && row.getValue("role") !== "general_manager" ? [
          h(
            Select,
            {
              value: row.getValue("role"),
              "onUpdate:modelValue": (newValue: string) => handleRoleChange(newValue, row),
              defaultValue: row.getValue("role"),
            },
            [
              h(SelectTrigger, { class: "w-[180px]" }, [
                h(SelectValue, { placeholder: "Select a role" }),
              ]),
              h(SelectContent, {}, [
                h(SelectGroup, {}, [
                  ...roles.map((role) =>
                    h(
                      SelectItem,
                      { value: role },
                      role.charAt(0).toUpperCase() + role.slice(1)
                    )
                  ),
                ]),
              ]),
            ]
          )
        ] : row.getValue("role")
      ),
    }),
    columnHelper.accessor("id", {
      header: () => h("div", { class: "text-right" }, "Actions"),
      cell: ({ row }) =>
        h("div", { class: "text-right" }, [
          h(
            Button,
            {
              variant: "outline",
              onClick: () => {
                openWorkingTimeModal.value = true;
                actionUser.value = row.original;
              },
            },
            h(TimerIcon)
          ),
          h(
            Button,
            {
              onClick() {
                openActionUserModal.value = true;
                actionUser.value = row.original;
              }
            },
            h(Pencil2Icon)
          ),
          h(
            Button,
            {
              variant: "destructive",
              onClick: () => deleteUserById(row.getValue("id")),
            },
            h(TrashIcon)
          ),
        ]),
    }),
  ];
});

const table = computed(() => {
  return useVueTable({
    data: users,
    columns: columns.value,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });
});

const updateUserDialog = computed(() => {
  return actionUser.value.id != -1;
});
</script>

<template>
  <div class="h-screen">
    <div class="border-b">
      <div class="flex h-16 items-center px-4">
        <TeamSwitcher @teamChange="fetchAllUsers" />
        <NavAdmin class="mx-6" />
      </div>
    </div>
    <div class="rounded-md border">
      <div class="m-5">
        <div class="flex justify-between text-center align-center">
          <h1 class="text-3xl bold uppercase">Gestions des users</h1>

          <Dialog :open="openActionUserModal" @update:open="(val) => (openActionUserModal = val)">
            <DialogTrigger as-child>
              <Button variant="outline" @click="resetActionUser">
                <PlusIcon />
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[425px]">
              <DialogHeader>
                <DialogTitle>
                  <template v-if="updateUserDialog"> Update user </template>
                  <template v-else> Create user </template>
                </DialogTitle>
                <DialogDescription>
                  <template v-if="updateUserDialog">
                    Update the user {{ actionUser.username }}
                  </template>
                  <template v-else>
                    Create the user {{ actionUser.username }}
                  </template>
                </DialogDescription>
              </DialogHeader>
              <div class="grid gap-4 py-4">
                <div class="grid grid-cols-4 items-center gap-4">
                  <Label for="username" class="text-right"> Username </Label>
                  <Input id="username" class="col-span-3" v-model="actionUser.username" />
                </div>
                <div class="grid grid-cols-4 items-center gap-4">
                  <Label for="email" class="text-right"> Email </Label>
                  <Input id="email" class="col-span-3" type="email" v-model="actionUser.email" />
                </div>
              </div>
              <DialogFooter>
                <DialogClose>
                  <Button @click="createOrUpdateElement"> Save changes </Button>
                </DialogClose>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>
        <WorkingTimeModal :open="openWorkingTimeModal" :user="actionUser"
          @close="() => (openWorkingTimeModal = false)" />

        <Table>
          <TableHeader>
            <TableRow v-for="headerGroup in table.getHeaderGroups()" :key="headerGroup.id">
              <TableHead v-for="header in headerGroup.headers" :key="header.id"
                :data-pinned="header.column.getIsPinned()">
                <FlexRender v-if="!header.isPlaceholder" :render="header.column.columnDef.header"
                  :props="header.getContext()" />
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <template v-if="table.getRowModel().rows?.length">
              <template v-for="row in table.getRowModel().rows" :key="row.id">
                <TableRow :data-state="row.getIsSelected() && 'selected'">
                  <TableCell v-for="cell in row.getVisibleCells()" :key="cell.id"
                    :data-pinned="cell.column.getIsPinned()">
                    <FlexRender :render="cell.column.columnDef.cell" :props="cell.getContext()" />
                  </TableCell>
                </TableRow>
                <TableRow v-if="row.getIsExpanded()">
                  <TableCell :colspan="row.getAllCells().length">
                    {{ row.original }}
                  </TableCell>
                </TableRow>
              </template>
            </template>

            <TableRow v-else>
              <TableCell :colspan="columns.length" class="h-24 text-center">
                No results.
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </div>

    <div class="flex items-center m-5 justify-end space-x-2 py-4">
      <Button variant="outline" size="sm" @click="table.previousPage()" :disabled="!table.getCanPreviousPage()">
        Previous
      </Button>
      <Button variant="outline" size="sm" @click="table.nextPage()" :disabled="!table.getCanNextPage()">
        Next
      </Button>
    </div>
  </div>
</template>
