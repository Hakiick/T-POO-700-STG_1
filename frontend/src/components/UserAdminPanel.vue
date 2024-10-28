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

import MainNav from './MainNav.vue';
import UserNav from './UserNav.vue';
import TeamSwitcher from './TeamSwitcher.vue';
import { TrashIcon, PlusIcon, TimerIcon, Pencil2Icon } from "@radix-icons/vue";

import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
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
const isDesktop = ref(false);

const checkIsDesktop = () => {
  isDesktop.value = window.innerWidth >= 1024;
};

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

onMounted(() => {
  checkIsDesktop();
  window.addEventListener('resize', checkIsDesktop);

  fetchAllUsers();
});

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
  <div class="grid grid-cols-1 lg:grid-cols-10 lg:min-h-screen">
    <!-- NavBar -->
    <div class="col-span-1 lg:col-span-1/10 border-r-4 relative border-b-4 pb-8">
      <!-- UserNav for Mobile -->
      <div class="pt-4 pl-4" v-show="!isDesktop">
        <UserNav :user="user" />
      </div>
      <h1 class="font-bold flex justify-center -mt-8 lg:mt-3">
        Time Manager
      </h1>
      <!-- UserNav for Desktop -->
      <div v-show="isDesktop" class="flex items-center justify-center py-8 border-b-4">
        <UserNav :user="user" />
      </div>
      <!-- MainNav for Desktop -->
      <div class="flex items-center justify-center pb-4 border-b-4 hidden lg:block">
        <MainNav class="mx-4" />
      </div>
      <!-- MainNav for Mobile -->
      <div class="absolute top-4 right-4 lg:hidden">
        <MainNav class="mx-4" />
      </div>
    </div>

    <div class="col-span-1 lg:col-span-9 h-full w-full space-y-4 pt-5">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
        <h1 class="text-2xl lg:text-3xl bold uppercase mb-5">Gestion des utilisateurs</h1>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 w-full">
          <div class="flex justify-center">
            <TeamSwitcher @teamChange="fetchAllUsers" class="w-full text-center" />
          </div>
          <div class="flex justify-between items-c-=0-nter">
            <Dialog :open="openActionUserModal" @update:open="(val) => (openActionUserModal = val)">
              <DialogTrigger as-child>
                <Button variant="outline" @click="resetActionUser">
                  <PlusIcon />
                </Button>
              </DialogTrigger>
              <DialogContent class="sm:max-w-[425px]">
                <DialogHeader>
                  <DialogTitle>
                    <template v-if="updateUserDialog"> Mettre à jour l'utilisateur </template>
                    <template v-else> Créer un utilisateur </template>
                  </DialogTitle>
                  <DialogDescription>
                    <template v-if="updateUserDialog">
                      Modifier l'utilisateur {{ actionUser.username }}
                    </template>
                    <template v-else>
                      Créer l'utilisateur {{ actionUser.username }}
                    </template>
                  </DialogDescription>
                </DialogHeader>
                <div class="grid gap-4 py-4">
                  <div class="grid grid-cols-4 items-center gap-4">
                    <Label for="username" class="text-right"> Nom d'utilisateur </Label>
                    <Input id="username" class="col-span-3" v-model="actionUser.username" />
                  </div>
                  <div class="grid grid-cols-4 items-center gap-4">
                    <Label for="email" class="text-right"> Email </Label>
                    <Input id="email" class="col-span-3" type="email" v-model="actionUser.email" />
                  </div>
                </div>
                <DialogFooter>
                  <DialogClose>
                    <Button @click="createOrUpdateElement"> Enregistrer les modifications </Button>
                  </DialogClose>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </div>
      </div>

      <WorkingTimeModal :open="openWorkingTimeModal" :user="actionUser"
        @close="() => (openWorkingTimeModal = false)" />

      <table class="w-full table-auto border-collapse">
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
              Aucun résultat.
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>

      <div class="flex items-center justify-end m-5 space-x-2 py-4">
        <Button variant="outline" size="sm" @click="table.previousPage()" :disabled="!table.getCanPreviousPage()">
          Précédent
        </Button>
        <Button variant="outline" size="sm" @click="table.nextPage()" :disabled="!table.getCanNextPage()">
          Suivant
        </Button>
      </div>
    </div>
  </div>
</template>
