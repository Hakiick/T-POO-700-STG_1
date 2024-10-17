<script setup lang="ts">
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogHeader,
  DialogFooter,
} from "../ui/dialog";

import { Button } from "../ui/button";
import { User } from "../store/userStore.ts";
import { ref, watch, Ref, computed } from "vue";
import {
  createWorkingTime,
  deleteWorkingTime,
  getWorkingTimes,
  updateWorkingTime,
  WorkingTime,
} from "@/api/apiWorkingTime.ts";

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
    res = res.filter((i: WorkingTime) => new Date(i.end) - Date.now() > 0);
    workingTimes.value = res;
  } catch (error) {
    // ignored
  }
}

const formattedDates = computed(() => {
  return workingTimes.value.map((e: WorkingTime) => {
    return {
      id: e.id,
      formattedDate: {
        set: async function (val) {
          let startDate = new Date(e.start);
          let endDate = new Date(e.end);
          let dates = val.split("-");

          startDate.setFullYear(dates[0]);
          startDate.setMonth(dates[1] - 1);
          startDate.setDate(dates[2]);
          endDate.setFullYear(dates[0]);
          endDate.setMonth(dates[1] - 1);
          endDate.setDate(dates[2]);

          e.start = startDate.toISOString();
          e.end = endDate.toISOString();
          await updateWorkingTime(e);
        },
        get: function () {
          return formatDate(e.start);
        },
      },
      formattedStartTime: {
        set: async function (val) {
          let date = new Date(e.start);
          let times = val.split(":");
          date.setHours(times[0]);
          date.setMinutes(times[1]);
          e.start = date.toISOString();
          await updateWorkingTime(e);
        },
        get: function () {
          return getFormatTime(e.start);
        },
      },
      formattedEndTime: {
        set: async function (val) {
          let date = new Date(e.end);
          let times = val.split(":");
          date.setHours(times[0]);
          date.setMinutes(times[1]);
          e.end = date.toISOString();
          await updateWorkingTime(e);
        },
        get: function () {
          return getFormatTime(e.end);
        },
      },
    };
  });
});

function formatDate(dateString) {
  let date = new Date(dateString);
  return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
}

function getFormatTime(dateString) {
  let date = new Date(dateString);
  return `${date.getHours().toString().padStart(2, "0")}:${date
    .getMinutes()
    .toString()
    .padStart(2, "0")}`;
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
            <div class="flex border p-2">
              <div class="grow">
                <div class="flex justify-between w-5/6">
                  <label>Date </label>
                  <Input
                    type="date"
                    :value="formattedDate.formattedDate.get()"
                    @input="
                      formattedDate.formattedDate.set($event.target.value)
                    "
                    :min="formatDate(Date.now())"
                  />
                </div>

                <div class="flex justify-between w-5/6">
                  <label>Start time </label>
                  <Input
                    type="time"
                    :value="formattedDate.formattedStartTime.get()"
                    @input="
                      formattedDate.formattedStartTime.set($event.target.value)
                    "
                  ></Input>
                </div>

                <div class="flex justify-between w-5/6">
                  <label>End time</label>
                  <Input
                    type="time"
                    :value="formattedDate.formattedEndTime.get()"
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
