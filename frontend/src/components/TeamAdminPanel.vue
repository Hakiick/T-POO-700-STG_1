<script setup lang="ts">
import {
  createTeam,
  deleteTeam,
  Team,
  updateTeam,
} from "../api/apiTeams.ts";
import { getAllUsersFromTeam } from "../api/apiManage.ts";

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

import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardFooter,
} from "./ui/card";

import Button from "./ui/button/Button.vue";
import Input from "./ui/input/Input.vue";
import Label from "./ui/label/Label.vue";
import { TrashIcon, Pencil2Icon, PlusIcon, PersonIcon } from "@radix-icons/vue";
import ManageUserModal from "./AdminPanelComponents/ManageUserModal.vue";

import { computed, h, onMounted, ref } from "vue";
import MainNav from "./MainNav.vue";
import UserNav from "./UserNav.vue";
import { useTeamStore } from "./store/teamStore.ts";
import { useUserStore } from "./store/userStore.ts";

const user = computed(() => useUserStore().user);
const teams = ref<Team[]>([]);
const actionTeam = ref<Team>({ id: -1, name: "", description: "" });
const open = ref<boolean>(false);
const openManageModal = ref<boolean>(false);
const memberCounts = ref<Map<number, number>>(new Map());

const columnHelper = createColumnHelper<Team>();

const columns = [
  columnHelper.accessor("name", {
    header: "Name",
    cell: ({ row }) => h("div", { class: "font-medium" }, row.getValue("name")),
  }),
  columnHelper.accessor("description", {
    header: "Description",
    cell: ({ row }) =>
      h(
        "div",
        { class: "text-muted-foreground" },
        row.getValue("description") || "-"
      ),
  }),
  columnHelper.display({
    id: "members",
    header: "Members",
    cell: ({ row }) => {
      const count = memberCounts.value.get(row.original.id);
      return h(
        "span",
        {
          class:
            "inline-flex items-center rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary",
        },
        count !== undefined ? `${count} member${count !== 1 ? "s" : ""}` : "..."
      );
    },
  }),
  columnHelper.accessor("id", {
    header: () => h("div", { class: "text-right" }, "Actions"),
    cell: ({ row }) =>
      h("div", { class: "flex justify-end gap-2" }, [
        h(
          Button,
          {
            variant: "outline",
            size: "icon",
            class: "min-h-[2.75rem] min-w-[2.75rem]",
            "aria-label": `Manage users in ${row.original.name}`,
            onClick() {
              openManageModal.value = true;
              actionTeam.value = row.original;
            },
          },
          () => h(PersonIcon)
        ),
        h(
          Button,
          {
            variant: "outline",
            size: "icon",
            class: "min-h-[2.75rem] min-w-[2.75rem]",
            "aria-label": `Edit ${row.original.name}`,
            onClick() {
              open.value = true;
              actionTeam.value = row.original;
            },
          },
          () => h(Pencil2Icon)
        ),
        h(
          Button,
          {
            variant: "destructive",
            size: "icon",
            class: "min-h-[2.75rem] min-w-[2.75rem]",
            "aria-label": `Delete ${row.original.name}`,
            onClick() {
              deleteElement(row.getValue("id"));
            },
          },
          () => h(TrashIcon)
        ),
      ]),
  }),
];

const table = computed(() => {
  return useVueTable({
    data: teams.value,
    columns,
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
  return actionTeam.value.id !== -1;
});

function openManageUsers(team: Team) {
  openManageModal.value = true;
  actionTeam.value = team;
}

function openEditDialog(team: Team) {
  open.value = true;
  actionTeam.value = team;
}

async function fetchMemberCounts() {
  const counts = new Map<number, number>();
  const promises = teams.value.map(async (team) => {
    try {
      const users = await getAllUsersFromTeam(team);
      counts.set(team.id, users?.length ?? 0);
    } catch {
      counts.set(team.id, 0);
    }
  });
  await Promise.all(promises);
  memberCounts.value = counts;
}

onMounted(async () => {
  teams.value = useTeamStore().accessibleTeams.filter(
    (iTeam) => iTeam.id !== -1
  );
  await fetchMemberCounts();
});

async function deleteElement(id: number) {
  if (id <= 0) return;
  const team = teams.value.find((iTeam) => iTeam.id === id);
  if (!team) return;

  if (await deleteTeam(team)) {
    teams.value = teams.value.filter((iTeam) => iTeam.id !== id);
    memberCounts.value.delete(id);
  }
}

async function createOrUpdateElement() {
  if (actionTeam.value.id > 0) {
    await updateTeam(actionTeam.value);
    teams.value = teams.value.map((iTeam) =>
      iTeam.id === actionTeam.value.id ? { ...actionTeam.value } : iTeam
    );
  } else {
    const newTeam = await createTeam(actionTeam.value);
    if (newTeam) {
      teams.value = [...teams.value, newTeam];
      memberCounts.value.set(newTeam.id, 0);
    }
  }
}

function getMemberCount(teamId: number): number | undefined {
  return memberCounts.value.get(teamId);
}
</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-10 lg:min-h-screen">
    <!-- NavBar Sidebar -->
    <div class="col-span-1 lg:col-span-1/10 border-r-4 relative border-b-4 pb-8">
      <!-- UserNav for Mobile -->
      <div class="pt-4 pl-4 lg:hidden">
        <UserNav :user="user" />
      </div>
      <h1 class="font-bold flex justify-center -mt-8 lg:mt-3">
        Time Manager
      </h1>
      <!-- UserNav for Desktop -->
      <div class="hidden lg:flex items-center justify-center py-8 border-b-4">
        <UserNav :user="user" />
      </div>
      <!-- MainNav for Desktop -->
      <div class="items-center justify-center pb-4 border-b-4 hidden lg:flex">
        <MainNav class="mx-4" />
      </div>
      <!-- MainNav for Mobile (hamburger) -->
      <div class="absolute top-4 right-4 lg:hidden">
        <MainNav class="mx-4" />
      </div>
    </div>

    <!-- Main Content -->
    <div class="col-span-1 lg:col-span-9 flex flex-col p-4 lg:p-8">
      <!-- Header with title and create button -->
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-xl lg:text-3xl font-bold uppercase">
          Team management
        </h1>
        <Dialog
          :open="open"
          @update:open="(val: boolean) => { open = val; }"
        >
          <DialogTrigger as-child>
            <Button
              variant="outline"
              class="min-h-[2.75rem] min-w-[2.75rem] lg:min-h-0 lg:min-w-0"
              aria-label="Create new team"
              @click="resetActionTeam"
            >
              <PlusIcon class="h-5 w-5" />
              <span class="ml-2 hidden md:inline">New team</span>
            </Button>
          </DialogTrigger>
          <DialogContent class="w-[calc(100vw-2rem)] sm:max-w-[425px]">
            <DialogHeader>
              <DialogTitle>
                <template v-if="updateTeamDialog">Update team</template>
                <template v-else>Create team</template>
              </DialogTitle>
              <DialogDescription>
                <template v-if="updateTeamDialog">
                  Update the team {{ actionTeam.name }}
                </template>
                <template v-else>
                  Fill in the details to create a new team
                </template>
              </DialogDescription>
            </DialogHeader>
            <div class="grid gap-4 py-4">
              <div class="grid grid-cols-4 items-center gap-4">
                <Label for="name" class="text-right">Name</Label>
                <Input
                  id="name"
                  class="col-span-3"
                  v-model="actionTeam.name"
                  placeholder="Team name"
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
                  placeholder="Team description"
                />
              </div>
            </div>
            <DialogFooter>
              <DialogClose as-child>
                <Button @click="createOrUpdateElement">
                  Save changes
                </Button>
              </DialogClose>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      <!-- ManageUserModal -->
      <ManageUserModal
        :open="openManageModal"
        :team="actionTeam"
        @close="() => (openManageModal = false)"
      />

      <!-- Mobile: Card-based layout -->
      <div class="flex flex-col gap-4 lg:hidden">
        <template v-if="teams.length > 0">
          <Card
            v-for="team in teams"
            :key="team.id"
          >
            <CardHeader class="pb-2">
              <div class="flex items-center justify-between">
                <CardTitle class="text-base">{{ team.name }}</CardTitle>
                <span
                  class="inline-flex items-center rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary"
                >
                  {{ getMemberCount(team.id) !== undefined ? `${getMemberCount(team.id)} member${getMemberCount(team.id) !== 1 ? 's' : ''}` : '...' }}
                </span>
              </div>
              <CardDescription v-if="team.description">
                {{ team.description }}
              </CardDescription>
            </CardHeader>
            <CardFooter class="flex justify-end gap-2 pt-2">
              <Button
                variant="outline"
                size="icon"
                class="min-h-[2.75rem] min-w-[2.75rem]"
                aria-label="Manage users"
                @click="openManageUsers(team)"
              >
                <PersonIcon />
              </Button>
              <Button
                variant="outline"
                size="icon"
                class="min-h-[2.75rem] min-w-[2.75rem]"
                aria-label="Edit team"
                @click="openEditDialog(team)"
              >
                <Pencil2Icon />
              </Button>
              <Button
                variant="destructive"
                size="icon"
                class="min-h-[2.75rem] min-w-[2.75rem]"
                aria-label="Delete team"
                @click="deleteElement(team.id)"
              >
                <TrashIcon />
              </Button>
            </CardFooter>
          </Card>
        </template>
        <div
          v-else
          class="flex items-center justify-center py-12 text-muted-foreground"
        >
          No teams found.
        </div>
      </div>

      <!-- Desktop: Table layout -->
      <div class="hidden lg:block">
        <Table>
          <TableHeader>
            <TableRow
              v-for="headerGroup in table.getHeaderGroups()"
              :key="headerGroup.id"
            >
              <TableHead
                v-for="header in headerGroup.headers"
                :key="header.id"
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
              <TableRow
                v-for="row in table.getRowModel().rows"
                :key="row.id"
                :data-state="row.getIsSelected() && 'selected'"
              >
                <TableCell
                  v-for="cell in row.getVisibleCells()"
                  :key="cell.id"
                >
                  <FlexRender
                    :render="cell.column.columnDef.cell"
                    :props="cell.getContext()"
                  />
                </TableCell>
              </TableRow>
            </template>
            <TableRow v-else>
              <TableCell :colspan="columns.length" class="h-24 text-center">
                No teams found.
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
        <!-- Pagination -->
        <div class="flex justify-end mt-4 gap-2">
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
  </div>
</template>
