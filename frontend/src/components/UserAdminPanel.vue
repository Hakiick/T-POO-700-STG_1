<script setup lang="ts">
import {
  ref,
  onMounted,
  h,
} from "vue";
import {
  createUser,
  deleteUser,
  getAllUser,
  updateUser,
} from "../api/apiUser.ts";

import {
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

import MainNav from "./MainNav.vue";
import Search from "./Search.vue";
import TeamSwitcher from "./TeamSwitcher.vue";
import UserNav from "./UserNav.vue";
import Button from "./ui/button/Button.vue";
import {
  TrashIcon,
  Pencil2Icon,
  PlusIcon,
  TimerIcon
} from "@radix-icons/vue";

import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "./ui/dialog";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import WorkingTimeModal from "./AdminPanelComponents/WorkingTimeModal.vue";
import { User } from "./store/userStore.ts";

const users = ref<User[]>([]);
const newUser = ref({ id: -1, username: "", email: "", password: "" });
const actionUser = ref({ id: -1, username: "", email: "" });
const open = ref(false);

const fetchAllUsers = async () => {
  users.value = await getAllUser();
};

const deleteUserById = async (id: number) => {
  const user = users.value.find((u) => u.id === id);
  if (user && (await deleteUser(user))) {
    users.value = users.value.filter((u) => u.id !== id);
  }
};

const createElement = async () => {
  try {
    const res = await createUser(newUser.value.username, newUser.value.email, newUser.value.password);
    users.value.unshift(res.data);
    newUser.value = { id: -1, username: "", email: "", password: "" };
  } catch (error) {
    console.error("Error creating element:", error);
  }
};

const replaceElement = async (user: User) => {
  const res = await updateUser(user);
  if (res) {
    const index = users.value.findIndex((u) => u.id === user.id);
    if (index !== -1) users.value.splice(index, 1, user);
  }
};

onMounted(() => {
  fetchAllUsers();
});

const columnHelper = createColumnHelper<User>();

const columns = [
  columnHelper.accessor("username", {
    header: "Username",
    cell: ({ row }) =>
      h("div", { class: "capitalize usernames" }, row.getValue("username")),
  }),
  columnHelper.accessor("email", {
    header: "Email",
    cell: ({ row }) =>
      h("div", { class: "lowercase emails" }, row.getValue("email")),
  }),
  columnHelper.accessor("id", {
    header: () => h("div", { class: "text-right" }, "Actions"),
    cell: ({ row }) =>
      h("div", { class: "text-right" }, [
        h(Button, TimerIcon, {
          variant: "outline",
          onClick: () => {
            open.value = true;
            actionUser.value = {
              id: row.getValue("id"),
              username: row.getValue("username"),
              email: row.getValue("email"),
            };
          },
        }),
        h(Dialog, {}, [
          h(DialogTrigger, { asChild: true }, h(Button, Pencil2Icon)),
          h(DialogContent, {}, [
            h(DialogHeader, {}, [
              h(DialogTitle, {}, "Edit profile"),
              h(DialogDescription, {}, "Modifier les informations du client ici"),
            ]),
            h("div", { class: "grid gap-4 py-4" }, [
              h("div", { class: "grid grid-cols-4 items-center gap-4" }, [
                h(Label, {}, "Email"),
                h(Input, {
                  type: "email",
                  class: "col-span-3",
                  modelValue: actionUser.value.email,
                  onInput: (e: Event) => {
                    const target = e.target as HTMLInputElement;
                    actionUser.value.email = target.value;
                  },
                }),
              ]),
              h("div", { class: "grid grid-cols-4 items-center gap-4" }, [
                h(Label, {}, "Username"),
                h(Input, {
                  type: "text",
                  class: "col-span-3",
                  modelValue: actionUser.value.username,
                  onInput: (e: Event) => {
                    const target = e.target as HTMLInputElement;
                    actionUser.value.username = target.value;
                  },
                }),
              ]),
            ]),
            h(DialogFooter, {}, [
              h(DialogClose, { asChild: true }, [
                h(Button, {
                  onClick: () => replaceElement(actionUser.value),
                }, "Save changes"),
              ]),
            ]),
          ]),
        ]),
        h(Button, TrashIcon, {
          variant: "destructive",
          onClick: () => deleteUserById(row.getValue("id")),
        }),
      ]),
  }),
];

const table = useVueTable({
  data: users.value,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
});
</script>

<template>
  <WorkingTimeModal :open="open" :user="actionUser" @close="() => (open = false)" />

  <div class="h-full w-full">
    <div class="border-b">
      <div class="flex h-16 items-center px-4">
        <TeamSwitcher />
        <MainNav class="mx-6" />
        <div v-if="users.length" class="ml-auto flex items-center space-x-4">
          <Search />
          <UserNav :user="users[0]" />
        </div>
      </div>
    </div>
    <div class="rounded-md border">
      <div class="m-5">
        <div class="flex justify-between text-center align-center">
          <h1 class="text-3xl bold uppercase">Admin panel</h1>

          <Dialog>
            <DialogTrigger as-child>
              <Button variant="outline">
                <PlusIcon />
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[425px]">
              <DialogHeader>
                <DialogTitle>Add profile</DialogTitle>
              </DialogHeader>
              <div class="grid gap-4 py-4">
                <div class="grid grid-cols-4 items-center gap-4">
                  <Label for="username" class="text-right"> Username </Label>
                  <Input id="username" class="col-span-3" v-model="newUser.username" />
                </div>
                <div class="grid grid-cols-4 items-center gap-4">
                  <Label for="email" class="text-right"> Email </Label>
                  <Input id="email" class="col-span-3" type="email" v-model="newUser.email" />
                </div>
              </div>
              <DialogFooter>
                <DialogClose>
                  <Button @click="createElement"> Save changes </Button>
                </DialogClose>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>

        <Table>
          <TableHeader>
            <TableRow v-for="headerGroup in table.getHeaderGroups()" :key="headerGroup.id">
              <TableHead v-for="header in headerGroup.headers" :key="header.id">
                <FlexRender :render="header.column.columnDef.header" :props="header.getContext()" />
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <template v-if="table.getRowModel().rows.length">
              <template v-for="row in table.getRowModel().rows" :key="row.id">
                <TableRow>
                  <TableCell v-for="cell in row.getVisibleCells()" :key="cell.id">
                    <FlexRender :render="cell.column.columnDef.cell" :props="cell.getContext()" />
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
