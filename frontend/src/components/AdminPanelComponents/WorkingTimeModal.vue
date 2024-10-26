<script setup lang="ts">
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogHeader,
  DialogFooter,
  DialogTitle,
  DialogDescription
} from "../ui/dialog";

import Button from "../ui/button/Button.vue";
import Input from "../ui/input/Input.vue";
import Label from "../ui/label/Label.vue";
import { User } from "../store/userStore.ts";
import { ref, watch, Ref, computed } from "vue";
import {
  createWorkingTime,
  deleteWorkingTime,
  getWorkingTimes,
  updateWorkingTime,
  WorkingTime,
} from "../../api/apiWorkingTime.ts";

import { PlusIcon, TrashIcon } from "@radix-icons/vue";

const props = defineProps<{
  user: User;
  open: boolean;
}>();

const emit = defineEmits(["close"]);

const workingTimes: Ref<WorkingTime[], WorkingTime[]> = ref([]);

async function fetchWorkingTime() {
  workingTimes.value = [];
  try {
    let res: WorkingTime[] = await getWorkingTimes(props.user);
    res = res.filter((i: WorkingTime) => new Date(i.end).getTime() - new Date().getTime() > 0);
    workingTimes.value = res;
  } catch (error) {
    // ignored
  }
}

const formattedDates = computed(() => {
  return workingTimes.value.map((e: WorkingTime) => {
    return {
      id: e.id,
      formattedStartTime: {
        set: async function (val) {
          e.start = new Date(val).toISOString();
          await updateWorkingTime(e);
        },
        get: function () {
          return formatDate(e.start);
        },
      },
      formattedEndTime: {
        set: async function (val) {
          e.end = new Date(val).toISOString();
          await updateWorkingTime(e);
        },
        get: function () {
          return formatDate(e.end);
        },
      },
    };
  });
});

function formatDate(dateString) {
  let date = new Date(dateString);
  return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}T${date
    .getHours()
    .toString()
    .padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`;
}

async function newWorkingTime() {
  try {
    let res = await createWorkingTime(props.user, {
      start: "2024-10-17T09:34:41.304Z",
      end: "2024-10-17T09:34:41.304Z",
    });

    workingTimes.value.push(res.data);
  } catch (error) {
    console.error(error);
  }
}

async function removeWorkingTime(id: Number) {
  try {
    let workingTimeToDelete = workingTimes.value.filter(
      (e: WorkingTime) => e.id == id
    )[0];
    await deleteWorkingTime(workingTimeToDelete);
    workingTimes.value = workingTimes.value.filter(
      (e: WorkingTime) => e.id != id
    );
  } catch (error) {
    console.error("front remove working time:", error);
  }
}

watch(() => props.user?.id ?? -1, fetchWorkingTime);
</script>
<template>
  <Dialog
    :open="props.open"
    @update:open="
      (val) => {
        if (!val) emit('close');
      }
    "
  >
    <DialogContent
      class="sm:max-w-[425px] grid-rows-[auto_minmax(0,4fr)_auto] p-0 max-h-[90dvh]"
    >
      <DialogHeader class="p-6 pb-0">
        <DialogTitle
          >Working time of {{ props.user?.username ?? "" }}</DialogTitle
        >
        <DialogDescription> </DialogDescription>
        <Button @click="newWorkingTime"><PlusIcon /></Button>
      </DialogHeader>
      <div class="grid gap-4 py-4 overflow-y-auto px-6">
        <div class="flex flex-col">
          <template
            v-if="workingTimes.length != 0"
            v-for="formattedDate in formattedDates"
          >
            <div class="flex border p-2 mb-2">
              <div class="grow">
                <div class="flex justify-between w-5/6">
                  <Label>Start time </label>
                  <Input
                    type="datetime-local"
                    :value="formattedDate.formattedStartTime.get()"
                    :min="formatDate(Date.now())"
                    @input="
                      formattedDate.formattedStartTime.set($event.target.value)
                    "
                  ></Input>
                </div>

                <div class="flex justify-between w-5/6">
                  <label>End time</label>
                  <Input
                    type="datetime-local"
                    :value="formattedDate.formattedEndTime.get()"
                    :min="formatDate(Date.now())"
                    @input="
                      formattedDate.formattedEndTime.set($event.target.value)
                    "
                  ></Input>
                </div>
              </div>
              <div>
                <Button
                  variant="destructive"
                  @click="removeWorkingTime(formattedDate.id)"
                  ><TrashIcon
                /></Button>
              </div>
            </div>
          </template>
          <div v-else>No working times registered for next days</div>
        </div>
      </div>
      <DialogFooter class="p-6 pt-0">
        <DialogClose>
          <Button> Close </Button>
        </DialogClose>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
