<script setup lang="ts">
import {
    Dialog,
    DialogTrigger,
    DialogClose,
    DialogContent,
    DialogHeader,
    DialogFooter

} from "../ui/dialog"

import { Button } from "../ui/button";
import { User } from "../store/userStore.ts";
import { onMounted, ref } from "vue";
import { TimerIcon } from "@radix-icons/vue";
import { getWorkingTimes } from "@/api/apiWorkingTime.ts";

const props = defineProps<{
    user: User
}>()

interface workingTime {
    start: Date,
    end: Date,
    user_id: Number
}

async function fetchWorkingTime() {
    const res = await getWorkingTimes(props.user);
    console.log(res);
}

onMounted(fetchWorkingTime);

const workingTime = ref([]);
</script>
<template>
<Dialog>
    <DialogTrigger as-child>
      <Button variant="outline">
        <TimerIcon/>
      </Button>
    </DialogTrigger>
    <DialogContent class="sm:max-w-[425px] grid-rows-[auto_minmax(0,1fr)_auto] p-0 max-h-[90dvh]">
      <DialogHeader class="p-6 pb-0">
        <DialogTitle>Working time of {{ props.user?.username ?? '' }}</DialogTitle>
        <DialogDescription></DialogDescription>
      </DialogHeader>
      <div class="grid gap-4 py-4 overflow-y-auto px-6">
        <div class="flex flex-col justify-between h-[300dvh]">
          <p>
            This is some placeholder content to show the scrolling behavior for modals. We use repeated line breaks to demonstrate how content can exceed minimum inner height, thereby showing inner scrolling. When content becomes longer than the predefined max-height of modal, content will be cropped and scrollable within the modal.
          </p>

          <p>This content should appear at the bottom after you scroll.</p>
        </div>
      </div>
      <DialogFooter class="p-6 pt-0">
        <Button type="submit">
          Save changes
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>