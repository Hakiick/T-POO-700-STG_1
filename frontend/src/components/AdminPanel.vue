<script lang="ts">
import { getAllUser } from '../api/apiUser.ts'

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
import { Cross1Icon, Pencil2Icon, PlusIcon, TimerIcon } from '@radix-icons/vue'

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

export default defineComponent({
  data(): Data{
    return {
      users: []
    }

  },
  methods: {
    async fetchAllUser() {
      const res = await getAllUser();

      console.log(res);

    },
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
              id: this.users?.length ?? 0,
              username: document.querySelector('#username').value,
              email: document.querySelector('#email').value,
              workingTimes: []
            });
    }
  },
  computed: {
    
    columns() {
      const columnHelper = createColumnHelper<User>();

      return [
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
            h(Dialog, { 'variant':'outline'}, [
              h(DialogTrigger, {asChild: true}, h(Button, { 'variant': 'outline' }, TimerIcon)),
              h(DialogContent, {}, [
                h(DialogHeader, {}, [
                  h(DialogTitle, {}, "Working times"),
                  h(DialogDescription, {}, "")
                ]),
                h('div', { class: 'grid gap-4 py-4 overflow-y-auto px-6'}, [
                  h('div', {}, [

                  ])
                ]),
                h(DialogFooter, {}, h(DialogClose, { asChild: true}, h(Button, {}, 'Save changes')))
              ])
            ]),
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
    },
    table() {
      return useVueTable({
        data: this.users,
        columns: this.columns,
        getCoreRowModel: getCoreRowModel(),
        getPaginationRowModel: getPaginationRowModel(),
      })
    },
  },
  mounted() {
    this.fetchAllUser()
  }
})



export interface User {
  id: number
  username: string
  email: string
  workingTimes: WorkingTime[]
}

export interface Data {
  users: User[],
}


export interface WorkingTime {
  start: Date,
  end: Date
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
      <div class="m-5">
        <div class="flex justify-between text-center align-center">
          <h1 class="text-3xl bold uppercase">Admin panel</h1>
          
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