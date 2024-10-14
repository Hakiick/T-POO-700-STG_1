import { defineStore } from "pinia";
import { ref } from "vue";

export interface Clocks {
  Clocks: Clock[];
}

export interface Clock {
  id: number;
  time: string;
  status: boolean;
}

const clocks = ref<Clocks | null>(null);
const clock = ref<Clock | null>(null);
const lastClock = ref<Clock | null>(null);

export const useClockStore = defineStore("clock", () => {
  // console.log(user);

  const setClock = (clocks_info: Clocks) => {
    clocks.value = clocks_info;
    // console.log("clocks_info", clocks.value);
    lastClock.value = clocks_info[0];
  };

  const setLastClock = (clocks_info: Clock) => {
    lastClock.value = clocks_info;
  };

  const clearClock = () => {
    clock.value = null;
  };

  return { clocks, lastClock, clock, setClock, setLastClock, clearClock };
});
