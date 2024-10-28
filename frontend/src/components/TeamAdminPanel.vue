<script setup lang="ts">
import {
  createTeam,
  deleteTeam,
  Team,
  updateTeam,
} from "../api/apiTeams.ts";

import {
  FlexRender,
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

import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogTrigger,
} from "./ui/dialog";

import Button from "./ui/button/Button.vue";
import Input from "./ui/input/Input.vue";
import Label from "./ui/label/Label.vue";
import { TrashIcon, Pencil2Icon, PlusIcon, PersonIcon } from "@radix-icons/vue";
import ManageUserModal from "./AdminPanelComponents/ManageUserModal.vue";

import { computed, h, onMounted, ref } from "vue";
import MainNav from './MainNav.vue';
import UserNav from './UserNav.vue';
import { useTeamStore } from "./store/teamStore.ts";

const teams = ref<Team[]>([]);
const actionTeam = ref<Team>({ id: -1, name: "", description: "" });
const open = ref<boolean>(false);
const openManageModal = ref<boolean>(false);
const isDesktop = ref(false);

const checkIsDesktop = () => {
  isDesktop.value = window.innerWidth >= 1024;
};

const columns = computed(() => {
  const columnHelper = createColumnHelper<Team>();

  return [
    columnHelper.accessor("name", {
      header: "Name",
      cell: ({ row }) => h("div", {}, row.getValue("name")),
    }),
    columnHelper.accessor("description", {
      header: "Description",
      cell: ({ row }) => h("div", {}, row.getValue("description")),
    }),
    columnHelper.accessor("id", {
      header: () => h("div", { class: "text-right" }, "Actions"),
      cell: ({ row }) =>
        h("div", { class: "text-right" }, [
          h(
            Button,
            {
              variant: "outline",
              onClick() {
                openManageModal.value = true;
                actionTeam.value = row.original;
              },
            },
            h(PersonIcon)
          ),
          h(
            Button,
            {
              onClick() {
                open.value = true;
                actionTeam.value = row.original;
              },
            },
            h(Pencil2Icon)
          ),
          h(
            Button,
            {
              variant: "destructive",
              onClick() {
                deleteElement(row.getValue("id"));
              },
            },
            h(TrashIcon)
          ),
        ]),
    }),
  ];
});

const table = computed(() => {
  return useVueTable({
    data: teams,
    columns: columns.value,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });
});

function resetActionTeam() {
  actionTeam.value = {
    id: -1,
    name: "",
    description: "",
  };
}

const updateTeamDialog = computed(() => {
  return actionTeam.value.id != -1;
});

onMounted(() => {
  teams.value = useTeamStore().accessibleTeams.filter(iTeam => iTeam.id != -1);

  checkIsDesktop();
  window.addEventListener('resize', checkIsDesktop);
});


async function deleteElement(id: number) {
  if (id <= 0) return;
  const team = teams.value.filter((iTeam) => iTeam.id == id);
  if (team.length != 1) return;

  if (await deleteTeam(team[0])) {
    teams.value = teams.value.filter((iTeam) => iTeam.id != id);
  }
}

async function createOrUpdateElement() {
  let tempTeams: Team[] = [];
  if (actionTeam.value.id > 0) {
    await updateTeam(actionTeam.value);
  } else {
    let newTeam = await createTeam(actionTeam.value);
    tempTeams.push(newTeam);
  }

  let teamIndex = teams.value.findIndex(
    (iTeam) => iTeam.id == actionTeam.value.id
  );

  teams.value.forEach((value, index) => {
    if (index != teamIndex) tempTeams.push(value);
    else tempTeams.push(actionTeam.value);
  });

  teams.value = tempTeams;
}
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

    <div class="col-span-1 lg:col-span-9 flex flex-col justify-between p-8">
      <div class="flex justify-between text-center align-center">
        <h1 class="text-2xl lg:text-3xl bold uppercase mb-5">Gestions des teams</h1>
        <Dialog
          :open="open"
          @update:open="
            (val : boolean) => {
              open = val;
            }
          "
        >
          <DialogTrigger as-child>
            <Button variant="outline" @click="resetActionTeam"
              ><PlusIcon
            /></Button>
          </DialogTrigger>
          <DialogContent class="sm:max-w-[425px]">
            <DialogHeader>
              <DialogTitle>
                <template v-if="updateTeamDialog"> Update team </template>
                <template v-else> Create team </template>
              </DialogTitle>
              <DialogDescription>
                <template v-if="updateTeamDialog">
                  Update the team {{ actionTeam.name }}
                </template>
                <template v-else>
                  Create the team {{ actionTeam.name }}
                </template>
              </DialogDescription>
            </DialogHeader>
            <div class="grid gap-4 py-4">
              <div class="grid grid-cols-4 items-center gap-4">
                <Label for="name" class="text-right"> Name </Label>
                <Input
                  id="name"
                  class="col-span-3"
                  v-model="actionTeam.name"
                />
              </div>
              <div class="grid grid-cols-4 items-center gap-4">
                <Label for="description" class="text-right">
                  Description
                </Label>
                <Input
                  id="description"
                  class="col-span-3"
                  v-model="actionTeam.description"
                />
              </div>
            </div>
            <DialogFooter>
              <DialogClose>
                <Button :onclick="createOrUpdateElement">
                  Save changes
                </Button>
              </DialogClose>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
      <ManageUserModal
        :open="openManageModal"
        :team="actionTeam"
        @close="() => (openManageModal = false)"
      />
      <table class="w-full table-auto border-collapse">
        <TableHeader>
          <TableRow
            v-for="headerGroup in table.getHeaderGroups()"
            :key="headerGroup.id"
          >
            <TableHead
              v-for="header in headerGroup.headers"
              :key="header.id"
              :data-pinned="header.column.getIsPinned()"
            >
              <FlexRender
                v-if="!header.isPlaceholder"
                :render="header.column.columnDef.header"
                :props="header.getContext()"
              />
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <template v-if="table.getRowModel().rows?.length">
            <template v-for="row in table.getRowModel().rows" :key="row.id">
              <TableRow :data-state="row.getIsSelected() && 'selected'">
                <TableCell
                  v-for="cell in row.getVisibleCells()"
                  :key="cell.id"
                  :data-pinned="cell.column.getIsPinned()"
                >
                  <FlexRender
                    :render="cell.column.columnDef.cell"
                    :props="cell.getContext()"
                  />
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
      <!-- Boutons de pagination en bas à droite -->
      <div class="flex justify-end mt-4">
        <Button
          variant="outline"
          size="sm"
          :disabled="!table.getCanPreviousPage()"
          @click="table.previousPage()"
        >
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          :disabled="!table.getCanNextPage()"
          @click="table.nextPage()"
          class="ml-2"
        >
          Next
        </Button>
      </div>
    </div>
  </div>
</template>
