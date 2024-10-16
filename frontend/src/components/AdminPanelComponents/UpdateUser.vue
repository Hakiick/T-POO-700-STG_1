<script lang="ts">
import { defineComponent } from 'vue';


export default defineComponent({
    props: {
        id: Number,
        email: String,
        username: String,
    } 
})

</script>


<template>
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
          <Input id="username" class="col-span-3" v-model="username"  />
        </div>
        <div class="grid grid-cols-4 items-center gap-4">
          <Label for="email" class="text-right">
            Email
          </Label>
          <Input id="email"  class="col-span-3" type="email" v-model="email"/>
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
</template>