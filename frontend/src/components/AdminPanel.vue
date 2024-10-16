<script setup lang="ts">
import { createUser, deleteUser, getAllUser, updateUser } from '../api/apiUser.ts'

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
import { User } from './store/userStore.ts'
import WorkingTimeModal from './AdminPanelComponents/WorkingTimeModal.vue'
</script>
<script lang="ts">
export default defineComponent({
  data() {
    return {
      users: [],
      newUser: { id: -1, username: '', email:''}
    }

  },
  methods: {
    async fetchAllUser() {
      const res = await getAllUser();
      console.log(res);
      this.users = res;

    },
    async deleteElement(id: number) {
      let user: User = this.users.filter((e:User) => e.id == id)[0];
      if (await deleteUser(user)) {
        this.users = this.users.filter((e: User) => e.id != id);
      }
    },
    getElement(id: number) {
      return this.users.filter(e => e.id == id)[0];
    },
    async replaceElement(user: User) {
      const res = await updateUser(user);
      console.log(res);


      let users : User[] = [];
      let index = this.users.findIndex(e => e.id == user.id);
      this.users.slice(0, index).forEach(e => users.push(e));
      users.push(user);
      this.users.slice(index+1).forEach(e => users.push(e));
      this.users = users;
      
    },
    async createElement() {
      try {
        const res = await createUser(this.newUser.username, this.newUser.email);
        console.log(res.data);
        let users : User[] = [];
        users.push(res.data);
        this.users.forEach((e: User) => users.push(e));
        this.users = users;

      } catch(error) {
        console.log("Error when creating element in front", error);
      }
    }
  },
  computed: {
    user() {
      return false;
    },
    
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
            h(WorkingTimeModal, { user: { id:row.getValue('id'), username: row.getValue('username'), email: row.getValue('email')} }),
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
         <Input id="username" class="col-span-3" v-model="newUser.username"  />
       </div>
       <div class="grid grid-cols-4 items-center gap-4">
         <Label for="email" class="text-right">
           Email
         </Label>
         <Input id="email"  class="col-span-3" type="email" v-model="newUser.email" />
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