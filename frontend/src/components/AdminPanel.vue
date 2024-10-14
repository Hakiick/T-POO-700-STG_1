<script setup lang="ts">
import {
  FlexRender,
  createColumnHelper,
  getCoreRowModel,
  getExpandedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useVueTable,
} from '@tanstack/vue-table'

import { defineComponent, h } from 'vue'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from './ui/table'
import MainNav from './MainNav.vue'
import Search from './Search.vue'
import TeamSwitcher from './TeamSwitcher.vue'
import UserNav from './UserNav.vue'
import Button from './ui/button/Button.vue'
import { Cross1Icon, Pencil2Icon, PlusIcon } from '@radix-icons/vue'

import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from './ui/dialog'
import { Input } from './ui/input'
import { Label } from './ui/label'
</script>

<script lang="ts">

export default defineComponent({
  data(): Data{
    return {
      users: [
    { id: 1, username: 'blablou1', email: 'blablou1@gmail.com' },
    { id: 2, username: 'blablou2', email: 'blablou2@gmail.com' },
    { id: 3, username: 'blablou3', email: 'blablou3@gmail.com' },
    { id: 4, username: 'blablou4', email: 'blablou4@gmail.com' },
    { id: 5, username: 'blablou5', email: 'blablou5@gmail.com' },
    { id: 6, username: 'blablou6', email: 'blablou6@gmail.com' },
    { id: 7, username: 'blablou7', email: 'blablou7@gmail.com' },
    { id: 8, username: 'blablou8', email: 'blablou8@gmail.com' },
    { id: 9, username: 'blablou9', email: 'blablou9@gmail.com' },
    { id: 10, username: 'blablou10', email: 'blablou10@gmail.com' },
    { id: 11, username: 'blablou11', email: 'blablou11@gmail.com' },
    { id: 12, username: 'blablou12', email: 'blablou12@gmail.com' },
    { id: 13, username: 'blablou13', email: 'blablou13@gmail.com' },
    { id: 14, username: 'blablou14', email: 'blablou14@gmail.com' },
    { id: 15, username: 'blablou15', email: 'blablou15@gmail.com' },
    { id: 16, username: 'blablou16', email: 'blablou16@gmail.com' },
    { id: 17, username: 'blablou17', email: 'blablou17@gmail.com' },
    { id: 18, username: 'blablou18', email: 'blablou18@gmail.com' },
    { id: 19, username: 'blablou19', email: 'blablou19@gmail.com' },
    { id: 20, username: 'blablou20', email: 'blablou20@gmail.com' },
    { id: 21, username: 'blablou21', email: 'blablou21@gmail.com' },
    { id: 22, username: 'blablou22', email: 'blablou22@gmail.com' },
    { id: 23, username: 'blablou23', email: 'blablou23@gmail.com' },
    { id: 24, username: 'blablou24', email: 'blablou24@gmail.com' },
    { id: 25, username: 'blablou25', email: 'blablou25@gmail.com' },
    { id: 26, username: 'blablou26', email: 'blablou26@gmail.com' },
    { id: 27, username: 'blablou27', email: 'blablou27@gmail.com' },
    { id: 28, username: 'blablou28', email: 'blablou28@gmail.com' },
    { id: 29, username: 'blablou29', email: 'blablou29@gmail.com' },
    { id: 30, username: 'blablou30', email: 'blablou30@gmail.com' },
    { id: 31, username: 'blablou31', email: 'blablou31@gmail.com' },
    { id: 32, username: 'blablou32', email: 'blablou32@gmail.com' },
    { id: 33, username: 'blablou33', email: 'blablou33@gmail.com' },
    { id: 34, username: 'blablou34', email: 'blablou34@gmail.com' },
    { id: 35, username: 'blablou35', email: 'blablou35@gmail.com' },
    { id: 36, username: 'blablou36', email: 'blablou36@gmail.com' },
    { id: 37, username: 'blablou37', email: 'blablou37@gmail.com' },
    { id: 38, username: 'blablou38', email: 'blablou38@gmail.com' },
    { id: 39, username: 'blablou39', email: 'blablou39@gmail.com' },
    { id: 40, username: 'blablou40', email: 'blablou40@gmail.com' },
    { id: 41, username: 'blablou41', email: 'blablou41@gmail.com' },
    { id: 42, username: 'blablou42', email: 'blablou42@gmail.com' },
    { id: 43, username: 'blablou43', email: 'blablou43@gmail.com' },
    { id: 44, username: 'blablou44', email: 'blablou44@gmail.com' },
    { id: 45, username: 'blablou45', email: 'blablou45@gmail.com' },
    { id: 46, username: 'blablou46', email: 'blablou46@gmail.com' },
    { id: 47, username: 'blablou47', email: 'blablou47@gmail.com' },
    { id: 48, username: 'blablou48', email: 'blablou48@gmail.com' },
    { id: 49, username: 'blablou49', email: 'blablou49@gmail.com' },
    { id: 50, username: 'blablou50', email: 'blablou50@gmail.com' },
    { id: 51, username: 'blablou51', email: 'blablou51@gmail.com' },
    { id: 52, username: 'blablou52', email: 'blablou52@gmail.com' },
    { id: 53, username: 'blablou53', email: 'blablou53@gmail.com' },
    { id: 54, username: 'blablou54', email: 'blablou54@gmail.com' },
    { id: 55, username: 'blablou55', email: 'blablou55@gmail.com' },
    { id: 56, username: 'blablou56', email: 'blablou56@gmail.com' },
    { id: 57, username: 'blablou57', email: 'blablou57@gmail.com' },
    { id: 58, username: 'blablou58', email: 'blablou58@gmail.com' },
    { id: 59, username: 'blablou59', email: 'blablou59@gmail.com' },
    { id: 60, username: 'blablou60', email: 'blablou60@gmail.com' },
    { id: 61, username: 'blablou61', email: 'blablou61@gmail.com' },
    { id: 62, username: 'blablou62', email: 'blablou62@gmail.com' },
    { id: 63, username: 'blablou63', email: 'blablou63@gmail.com' },
    { id: 64, username: 'blablou64', email: 'blablou64@gmail.com' },
    { id: 65, username: 'blablou65', email: 'blablou65@gmail.com' },
    { id: 66, username: 'blablou66', email: 'blablou66@gmail.com' },
    { id: 67, username: 'blablou67', email: 'blablou67@gmail.com' },
    { id: 68, username: 'blablou68', email: 'blablou68@gmail.com' },
    { id: 69, username: 'blablou69', email: 'blablou69@gmail.com' },
    { id: 70, username: 'blablou70', email: 'blablou70@gmail.com' },
    { id: 71, username: 'blablou71', email: 'blablou71@gmail.com' },
    { id: 72, username: 'blablou72', email: 'blablou72@gmail.com' },
    { id: 73, username: 'blablou73', email: 'blablou73@gmail.com' },
    { id: 74, username: 'blablou74', email: 'blablou74@gmail.com' },
    { id: 75, username: 'blablou75', email: 'blablou75@gmail.com' },
    { id: 76, username: 'blablou76', email: 'blablou76@gmail.com' },
    { id: 77, username: 'blablou77', email: 'blablou77@gmail.com' },
    { id: 78, username: 'blablou78', email: 'blablou78@gmail.com' },
    { id: 79, username: 'blablou79', email: 'blablou79@gmail.com' },
    { id: 80, username: 'blablou80', email: 'blablou80@gmail.com' },
    { id: 81, username: 'blablou81', email: 'blablou81@gmail.com' },
    { id: 82, username: 'blablou82', email: 'blablou82@gmail.com' },
    { id: 83, username: 'blablou83', email: 'blablou83@gmail.com' },
    { id: 84, username: 'blablou84', email: 'blablou84@gmail.com' },
    { id: 85, username: 'blablou85', email: 'blablou85@gmail.com' },
    { id: 86, username: 'blablou86', email: 'blablou86@gmail.com' },
    { id: 87, username: 'blablou87', email: 'blablou87@gmail.com' },
    { id: 88, username: 'blablou88', email: 'blablou88@gmail.com' },
    { id: 89, username: 'blablou89', email: 'blablou89@gmail.com' },
    { id: 90, username: 'blablou90', email: 'blablou90@gmail.com' },
    { id: 91, username: 'blablou91', email: 'blablou91@gmail.com' },
    { id: 92, username: 'blablou92', email: 'blablou92@gmail.com' },
    { id: 93, username: 'blablou93', email: 'blablou93@gmail.com' },
    { id: 94, username: 'blablou94', email: 'blablou94@gmail.com' },
    { id: 95, username: 'blablou95', email: 'blablou95@gmail.com' },
    { id: 96, username: 'blablou96', email: 'blablou96@gmail.com' },
    { id: 97, username: 'blablou97', email: 'blablou97@gmail.com' },
    { id: 98, username: 'blablou98', email: 'blablou98@gmail.com' },
    { id: 99, username: 'blablou99', email: 'blablou99@gmail.com' },
    { id: 100, username: 'blablou100', email: 'blablou100@gmail.com' }
    ],
    }

  },
  methods: {
    deleteElement(id: number) {
      this.$data.users = this.$data.users.filter(e => e.id != id);
    },
    getElement(id: number) {
      return this.$data.users.filter(e => e.id == id)[0];
    },
    addElement(user: User) {
      let users:  User[] = [];
      users.push(user);
      this.users.forEach(e => users.push(e));
      this.users = users;
    },
    replaceElement(user: User) {
      let users : User[] = [];
      let index = this.users.findIndex(e => e.id == user.id);
      this.users.slice(0, index).forEach(e => users.push(e));
      users.push(user);
      this.users.slice(index+1).forEach(e => users.push(e));
      this.users = users;
      
    },
    createElement() {
      this.addElement({
              id: this.users.length,
              username: document.querySelector('#username').value,
              email: document.querySelector('#email').value
            });
    }
  },
  computed: {
    user() {
      return false;
    },
    table() {
      const columnHelper = createColumnHelper<User>();

      const columns = [
        columnHelper.accessor('username', {
          header: 'Username',
          cell: ({ row }) => h('div', { class: 'capitalize usernames', 'data-id': row.getValue('id')}, row.getValue('username'))
        }),
        columnHelper.accessor('email', {
          header: 'Email',
          cell: ({ row }) => h('div', { class: 'lowercase emails', 'data-id': row.getValue('id')}, row.getValue('email')),
        }),
        columnHelper.accessor('id', {
          header: () => h('div', {class: 'text-right'}, 'Actions'),
          cell: ({ row }) => h('div', { class: 'text-right'}, [
            h(Dialog, { 'variant': 'outline' }, [ 
              h(DialogTrigger, { asChild:true}, h(Button, {}, Pencil2Icon)),
              h(DialogContent, {} , [
                h(DialogHeader, {}, [
                  h(DialogTitle, {}, 'Edit profile'),
                  h(DialogDescription, {}, 'Modifier les informations du client ici')
                ]),
                h('div', { class: 'grid gap-4 py-4'}, [
                  h('div', { class: 'grid grid-cols-4 items-center gap-4'}, [
                    h(Label, {class: 'text-right'}, 'Email'),
                    h(Input, { type:"email", placehorder:'Email', class:'input-email col-span-3','data-id': row.getValue('id') ,  modelValue:this.getElement(row.getValue('id')).email,  }),
                  ]),
                  h('div', { class: 'grid grid-cols-4 items-center gap-4'}, [
                    h(Label, {class: 'text-right'}, 'Username'),
                    h(Input, {type:'text', placeholder:'Username', class:'input-name col-span-3','data-id': row.getValue('id') , modelValue:this.getElement(row.getValue('id')).username})
                  ])
                ]),
                h(DialogFooter, {}, h(DialogClose, { asChild:true}, h(Button, { onClick: () => {
                  this.replaceElement({
                    id: row.getValue('id'), 
                    username: document.querySelector(`.input-name[data-id='${row.getValue('id')}']`).value, 
                    email: document.querySelector(`.input-email[data-id='${row.getValue('id')}']`).value
                  })
                }}, 'Save changes')))
              ])
            ]),
            h(Button, { 'variant': 'destructive', onClick: () => this.deleteElement(row.getValue('id'))}, Cross1Icon)
          ])
        })
      ]

      return useVueTable({
        data: this.users,
        columns,
        getCoreRowModel: getCoreRowModel(),
        getPaginationRowModel: getPaginationRowModel(),
      })
    }
  }
})



export interface User {
  id: number
  username: string
  email: string
}

export interface Data {
  users: User[],
}



</script>

<template>


  <div class="h-full w-full">
    <div class="border-b">
      <div class="flex h-16 items-center px-4">
        <TeamSwitcher />
        <MainNav class="mx-6" />
        <div v-if="user" class="ml-auto flex items-center space-x-4">
          <Search />
          <UserNav :user="user" />
        </div>
      </div>
    </div>
    <div class="rounded-md border">
      <div>
        <div class="flex justify-between m-2 text-center align-center">
          <h1 class="text-3xl bold uppercase">Admin panel</h1>
          <Dialog>
    <DialogTrigger as-child>
      <Button variant="outline"><PlusIcon/></Button>
    </DialogTrigger>
    <DialogContent class="sm:max-w-[425px]">
      <DialogHeader>
        <DialogTitle>Add profile</DialogTitle>
      </DialogHeader>
      <div class="grid gap-4 py-4">
        <div class="grid grid-cols-4 items-center gap-4">
          <Label for="username" class="text-right">
            Username
          </Label>
          <Input id="username" class="col-span-3"  />
        </div>
        <div class="grid grid-cols-4 items-center gap-4">
          <Label for="email" class="text-right">
            Email
          </Label>
          <Input id="email"  class="col-span-3" type="email" />
        </div>
      </div>
      <DialogFooter>
        <DialogClose>

          <Button :onClick="createElement">
            Save changes
          </Button>
        </DialogClose>
      </DialogFooter>
    </DialogContent>
  </Dialog>
        </div>

        <Table>
        <TableHeader>
          <TableRow v-for="headerGroup in table.getHeaderGroups()" :key="headerGroup.id">
            <TableHead
              v-for="header in headerGroup.headers" :key="header.id" :data-pinned="header.column.getIsPinned()"
            >
              <FlexRender v-if="!header.isPlaceholder" :render="header.column.columnDef.header" :props="header.getContext()" />
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <template v-if="table.getRowModel().rows?.length">
            <template v-for="row in table.getRowModel().rows" :key="row.id">
              <TableRow :data-state="row.getIsSelected() && 'selected'">
                <TableCell
                  v-for="cell in row.getVisibleCells()" :key="cell.id" :data-pinned="cell.column.getIsPinned()"
                >
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
            <TableCell
              :colspan="columns.length"
              class="h-24 text-center"
            >
              No results.
            </TableCell>
          </TableRow>
        </TableBody>
        </Table>
      </div>
    </div>

    <div class="flex items-center justify-end space-x-2 py-4">
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