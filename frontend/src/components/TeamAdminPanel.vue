<script setup lang="ts">
import {
  createTeam,
  deleteTeam,
  getAllTeam,
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

import { computed, h, onMounted, Ref, ref } from "vue";
import NavAdmin from "./NavAdmin.vue";

const teams: Ref<Team[], Team[]> = ref([]);
const actionTeam: Ref<Team, Team> = ref({ id: -1, name: "", description: "" });
const open: Ref<boolean, boolean> = ref(false);
const openManageModal: Ref<boolean, boolean> = ref(false);

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
              }
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

onMounted(fetchAllUser);

async function fetchAllUser() {
  const response = await getAllTeam();
  teams.value = response;
}

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
  <div class="h-screen">
    <div class="border-b">
      <div class="flex h-16 items-center px-4">
        <NavAdmin class="mx-6" />
      </div>
    </div>
    <div class="rounded-md border">
      <div class="m-5">
        <div class="flex justify-between text-center align-center">
          <div class="text-3xl bold uppsercase">Gestions des teams</div>
          <Dialog
            :open="open"
            @update:open="
              (val : boolean) => {
                open = val;
              }
            "
          >
            <DialogTrigger as-child>
              <Button variant="outline" :onclick="resetActionTeam"
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
        <ManageUserModal :open="openManageModal" :team="actionTeam" @close="() => openManageModal = false"/>
        <Table>
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
      </div>
    </div>
    <div class="flex items-center m-5 justify-end space-x-2 py-4">
      <div class="space-x-2">
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
        >
          Next
        </Button>
      </div>
    </div>
  </div>
</template>
