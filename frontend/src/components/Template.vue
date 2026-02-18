<script setup lang="ts">
// ============================
// Définition des options de composant
// ============================
defineOptions({
  name: "HomePage",
  displayName: "Home Page",
});
import MainNav from './MainNav.vue';
import UserNav from './UserNav.vue';
import ChartRange from './ChartRange.vue';
import SkeletonLoader from './SkeletonLoader.vue';
import { computed, onMounted, onUnmounted, ref, watch } from 'vue';
import { useClockStore } from './store/clockStore';
import { Sun, Moon, Check, Loader2 } from 'lucide-vue-next';

import moment, { Moment } from 'moment'
import 'moment/locale/fr';
moment.locale('fr');

// ============================
// Imports des API
// ============================
import { createClock, getClockFromUser, getClocksFromUser } from '../api/apiClock';

// ============================
// Import du store
// ============================
import { useUserStore } from './store/userStore';

// ============================
// Variables liées à l'utilisateur et aux données de pointage
// ============================
const userStore = useUserStore();
const user = computed(() => userStore.user);
const clockStore = useClockStore()

const workedHoursToday = ref<string | null>(null);
const workedHoursThisWeek = ref<string | null>(null);
const workedHoursThisMonth = ref<string | null>(null);
const arrivalTime = ref<string | null>(null);
const workTime = ref<string | null>(null);
const clocks = computed(() => clockStore.clocks);
const last_clock_value = computed(() => clockStore.lastClock?.status);
const clock_disable = ref(false);
const current_time = ref("");
const isLoading = ref(true);

// ============================
// Clock WOW effect state
// ============================
const isClocking = ref(false);
const showRipple = ref(false);
const rippleStyle = ref({ top: '0px', left: '0px', width: '0px', height: '0px' });
const showSuccess = ref(false);
const showShake = ref(false);
const iconAnimClass = ref('');
const liveTimer = ref<string | null>(null);
const currentMoment = ref(moment());
let timerInterval: ReturnType<typeof setInterval> | null = null;
let dateTimeInterval: ReturnType<typeof setInterval> | null = null;

const clockingText = computed(() => {
  return last_clock_value.value ? 'Clocking out...' : 'Clocking in...';
});

const formattedDate = computed(() => {
  return currentMoment.value.format('dddd D MMMM');
});

const formattedTime = computed(() => {
  return currentMoment.value.format('HH[h] mm[m]');
});

// ============================
// Real-time timer functions
// ============================
function startLiveTimer() {
  stopLiveTimer();
  updateLiveTimer();
  timerInterval = setInterval(updateLiveTimer, 1000);
}

function stopLiveTimer() {
  if (timerInterval) {
    clearInterval(timerInterval);
    timerInterval = null;
  }
  liveTimer.value = null;
}

function updateLiveTimer() {
  if (!arrivalTime.value) {
    liveTimer.value = null;
    return;
  }
  const arrivalMoment = moment(arrivalTime.value, 'HH:mm');
  const duration = moment.duration(moment().diff(arrivalMoment));
  const h = Math.floor(duration.asHours());
  const m = duration.minutes();
  const s = duration.seconds();
  liveTimer.value = `${h}h ${m}m ${s}s`;
}

// ============================
// Watch clock state to start/stop timer
// ============================
watch(last_clock_value, (newVal) => {
  if (newVal === true && arrivalTime.value) {
    startLiveTimer();
  } else {
    stopLiveTimer();
  }
});

// ============================
// onMounted: Initialisation des données au montage du composant
// ============================
onMounted(async () => {
  // Update currentMoment every minute for reactive date/time display
  dateTimeInterval = setInterval(() => {
    currentMoment.value = moment();
  }, 60000);

  const response_clock = await getClockFromUser(user.value.id);
  if (response_clock.status === 200) {
    clockStore.setClock(response_clock.data.data);
    current_time.value = moment().format('HH[h] mm[m]');
    const lastTrueClock = clocks.value.find((entry) => entry.status === true);

    if (lastTrueClock) {
      arrivalTime.value = moment(lastTrueClock.time).format('HH:mm');
    } else {
      arrivalTime.value = null;
    }

    if (arrivalTime.value) {
      const arrivalMoment = moment(arrivalTime.value, 'HH:mm');
      const duration = moment.duration(moment().diff(arrivalMoment));
      workTime.value = formatHours(duration.asHours());
    } else {
      workTime.value = '...';
    }

    // Start live timer if already clocked in
    if (last_clock_value.value === true && arrivalTime.value) {
      startLiveTimer();
    }

    // ============================
    // Fonction DayCard: Recuperation du temps journalier travaille (clock)
    // ============================
    const { startOfDay, endOfDay } = getCurrentDay();
    const hoursToday = await calculateWorkedHours(user.value.id, startOfDay, endOfDay);
    workedHoursToday.value = formatHours(hoursToday);

    // Pour la semaine en cours
    const { startOfWeek, endOfWeek } = getCurrentWeek();
    const hoursThisWeek = await calculateWorkedHours(user.value.id, startOfWeek, endOfWeek);
    workedHoursThisWeek.value = formatHours(hoursThisWeek);

    // Pour le mois en cours
    const { startOfMonth, endOfMonth } = getCurrentMonth();
    const hoursThisMonth = await calculateWorkedHours(user.value.id, startOfMonth, endOfMonth);
    workedHoursThisMonth.value = formatHours(hoursThisMonth);
  }

  isLoading.value = false;
});

onUnmounted(() => {
  stopLiveTimer();
  if (dateTimeInterval) clearInterval(dateTimeInterval);
});

const formattedArrivalTime = computed(() => {
  return arrivalTime.value ? moment(arrivalTime.value, 'HH:mm').format('HH[h] mm[m]') : '...';
});


const formatHours = (hours: number): string => {
  const h = Math.floor(hours);
  const m = Math.round((hours - h) * 60);
  return `${h}h ${m}m`;
};

function getCurrentDay() {
  const startOfDay = moment().startOf('day').toISOString();
  const endOfDay = moment().endOf('day').toISOString();
  return { startOfDay, endOfDay };
}

function getCurrentWeek() {
  const startOfWeek = moment().startOf('isoWeek').toISOString();
  const endOfWeek = moment().endOf('isoWeek').toISOString();
  return { startOfWeek, endOfWeek };
}

function getCurrentMonth() {
  const startOfMonth = moment().startOf('month').toISOString();
  const endOfMonth = moment().endOf('month').toISOString();
  return { startOfMonth, endOfMonth };
}

// ============================
// Fonction calculateWorkedHours: Recuperation du temps de travail. (clock)
// ============================
async function calculateWorkedHours(userId: number, startDate: string, endDate: string) {
  const utcStartDate = moment.utc(startDate).toISOString();
  const utcEndDate = moment.utc(endDate).toISOString();

  const cardDay = await getClocksFromUser(userId, utcStartDate, utcEndDate);

  if (cardDay.status === 404) {
    return 0;
  } else {
    const clockEntries = cardDay.data.data;
    let totalWorkedHours = 0;
    let clockInTime: Moment | null = null;

    if (Array.isArray(clockEntries)) {
      clockEntries.forEach(entry => {
        if (entry.status) {
          // Clock-in
          clockInTime = moment(entry.time);
        } else if (clockInTime) {
          // Clock-out
          const clockOutTime = moment(entry.time);
          const duration = moment.duration(clockOutTime.diff(clockInTime));
          totalWorkedHours += duration.asHours();
          clockInTime = null; // Reset clock-in time
        }
      });
    }

    // L'heure actuelle pour calculer la durée.
    if (clockInTime) {
      const currentTime = moment.utc();
      const duration = moment.duration(currentTime.diff(clockInTime));
      totalWorkedHours += duration.asHours();
    }

    return totalWorkedHours;
  }
}

// ============================
// Ripple effect handler
// ============================
function triggerRipple(event: MouseEvent) {
  const target = event.currentTarget as HTMLElement;
  const rect = target.getBoundingClientRect();
  const size = Math.max(rect.width, rect.height);
  const x = event.clientX - rect.left - size / 2;
  const y = event.clientY - rect.top - size / 2;

  rippleStyle.value = {
    top: `${y}px`,
    left: `${x}px`,
    width: `${size}px`,
    height: `${size}px`,
  };

  showRipple.value = false;
  requestAnimationFrame(() => {
    showRipple.value = true;
  });

  setTimeout(() => {
    showRipple.value = false;
  }, 600);
}

// ============================
// Centered ripple for keyboard activation
// ============================
function triggerCenteredRipple(target: HTMLElement) {
  const prefersMotion = window.matchMedia('(prefers-reduced-motion: no-preference)').matches;
  if (!prefersMotion) return;

  const rect = target.getBoundingClientRect();
  const size = Math.max(rect.width, rect.height);
  rippleStyle.value = {
    top: `${rect.height / 2 - size / 2}px`,
    left: `${rect.width / 2 - size / 2}px`,
    width: `${size}px`,
    height: `${size}px`,
  };
  showRipple.value = false;
  requestAnimationFrame(() => { showRipple.value = true; });
  setTimeout(() => { showRipple.value = false; }, 600);
}

// ============================
// Fonction handleClockClick: Gestion du changement de pointage avec WOW effect
// ============================
async function handleClockClick(event: MouseEvent | KeyboardEvent) {
  if (isClocking.value || clock_disable.value) return;

  if (event instanceof MouseEvent) {
    triggerRipple(event);
  } else {
    triggerCenteredRipple(event.currentTarget as HTMLElement);
  }
  isClocking.value = true;
  iconAnimClass.value = '';

  try {
    const newStatus = !last_clock_value.value;
    const response = await createClock(newStatus, user.value.id);

    if (response.data) {
      clockStore.setLastClock(response.data);

      // Update arrival time on clock-in
      if (newStatus) {
        arrivalTime.value = moment().format('HH:mm');
        const arrivalMoment = moment(arrivalTime.value, 'HH:mm');
        const duration = moment.duration(moment().diff(arrivalMoment));
        workTime.value = formatHours(duration.asHours());
      } else {
        // On clock-out, update workTime with final value
        if (arrivalTime.value) {
          const arrivalMoment = moment(arrivalTime.value, 'HH:mm');
          const duration = moment.duration(moment().diff(arrivalMoment));
          workTime.value = formatHours(duration.asHours());
        }
      }

      // Trigger icon animation (respect prefers-reduced-motion)
      const prefersMotion = window.matchMedia('(prefers-reduced-motion: no-preference)').matches;
      iconAnimClass.value = prefersMotion ? 'animate-icon-enter' : '';

      // Haptic feedback
      if (navigator.vibrate) {
        navigator.vibrate(200);
      }

      // Success feedback
      showSuccess.value = true;
      setTimeout(() => {
        showSuccess.value = false;
      }, 1500);
    } else {
      // Error feedback: shake animation
      showShake.value = true;
      setTimeout(() => {
        showShake.value = false;
      }, 500);
    }
  } catch {
    // Error feedback: shake animation
    showShake.value = true;
    if (navigator.vibrate) {
      navigator.vibrate([100, 50, 100]);
    }
    setTimeout(() => {
      showShake.value = false;
    }, 500);
  } finally {
    isClocking.value = false;
    clock_disable.value = false;
  }
}

</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-10 lg:min-h-screen">
    <!-- Sidebar -->
    <div class="col-span-1 lg:col-span-2 lg:border-r-4 relative">
      <!-- UserNav for Mobile -->
      <div class="pt-4 pl-4 block lg:hidden">
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
      <div class="hidden lg:flex items-center justify-center pb-4 border-b-4">
        <MainNav class="mx-4" />
      </div>
      <!-- MainNav for Mobile -->
      <div class="absolute top-4 right-4 lg:hidden">
        <MainNav class="mx-4" />
      </div>
      <div class="text-center items-center justify-center p-4 lg:p-8 border-b-4">
        <p>{{ formattedDate }}</p>
        <p class="text-xl font-bold">{{ formattedTime }}</p>
      </div>
      <!-- Stats: compact grid on mobile, vertical list on desktop -->
      <div v-if="isLoading" class="p-4">
        <SkeletonLoader :lines="5" />
      </div>
      <div v-else class="grid grid-cols-3 gap-2 p-4 text-center lg:grid-cols-1 lg:gap-0">
        <div class="mb-0 lg:mb-2 rounded-lg p-2 hover:shadow-lg hover:-translate-y-0.5 transition-all duration-200">
          <p class="text-sm lg:text-base">Day</p>
          <p class="text-lg lg:text-2xl font-bold text-primary">{{ workedHoursToday !== null ? workedHoursToday : '0h' }}</p>
        </div>
        <hr class="hidden lg:block my-2">
        <div class="mb-0 lg:mb-2 rounded-lg p-2 hover:shadow-lg hover:-translate-y-0.5 transition-all duration-200">
          <p class="text-sm lg:text-base">Week</p>
          <p class="text-lg lg:text-2xl font-bold text-primary">{{ workedHoursThisWeek !== null ? workedHoursThisWeek : '0h' }}</p>
        </div>
        <hr class="hidden lg:block my-2">
        <div class="mb-0 lg:mb-2 rounded-lg p-2 hover:shadow-lg hover:-translate-y-0.5 transition-all duration-200">
          <p class="text-sm lg:text-base">Month</p>
          <p class="text-lg lg:text-2xl font-bold text-primary">{{ workedHoursThisMonth !== null ? workedHoursThisMonth : '0h' }}</p>
        </div>
        <hr class="hidden lg:block my-2">
        <div class="mb-0 lg:mb-2 rounded-lg p-2 hover:shadow-lg hover:-translate-y-0.5 transition-all duration-200">
          <p class="text-sm lg:text-base">Time worked</p>
          <p class="text-lg lg:text-2xl font-bold text-success">{{ workTime || "..." }}</p>
        </div>
        <hr class="hidden lg:block my-2">
        <div class="mb-0 lg:mb-2 rounded-lg p-2 hover:shadow-lg hover:-translate-y-0.5 transition-all duration-200">
          <p class="text-sm lg:text-base">Check In</p>
          <p class="text-lg lg:text-2xl font-bold text-danger">{{ formattedArrivalTime || '...' }}</p>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <main class="col-span-1 lg:col-span-8 flex flex-col justify-between p-4 lg:p-8">
      <!-- Clock In/Out WOW Button -->
      <div
        class="relative overflow-hidden rounded-2xl cursor-pointer min-h-[2.75rem]
               transition-all duration-500 ease-in-out active:scale-[0.98]
               border-4 m-0 mb-8 select-none"
        :class="[
          last_clock_value
            ? 'bg-gradient-to-br from-red-400 to-red-600 border-red-700'
            : 'bg-gradient-to-br from-green-400 to-green-600 border-green-700',
          showShake ? 'motion-safe:animate-clock-shake' : '',
          last_clock_value === false && !isClocking ? 'motion-safe:animate-clock-pulse' : '',
          isClocking ? 'opacity-70 pointer-events-none' : '',
        ]"
        role="button"
        :aria-label="last_clock_value ? 'Clock out' : 'Clock in'"
        tabindex="0"
        @click="handleClockClick"
        @keydown.enter="handleClockClick"
        @keydown.space.prevent="handleClockClick"
      >
        <!-- Ripple effect -->
        <span
          v-if="showRipple"
          class="absolute rounded-full bg-white/30 motion-safe:animate-clock-ripple pointer-events-none"
          :style="rippleStyle"
        />

        <!-- Loading overlay -->
        <div
          v-if="isClocking"
          class="absolute inset-0 bg-black/20 flex items-center justify-center z-10"
        >
          <Loader2 class="w-8 h-8 text-white animate-spin" />
        </div>

        <!-- Main content -->
        <div class="flex flex-col items-center justify-center py-8 lg:py-12 relative">
          <!-- Animated icon -->
          <div class="text-white" :class="iconAnimClass">
            <Sun v-if="!last_clock_value" class="w-12 h-12 lg:w-16 lg:h-16 drop-shadow-lg" />
            <Moon v-else class="w-12 h-12 lg:w-16 lg:h-16 drop-shadow-lg" />
          </div>

          <!-- Success checkmark overlay -->
          <div
            v-if="showSuccess"
            class="absolute inset-0 flex items-center justify-center"
          >
            <Check class="w-16 h-16 text-white motion-safe:animate-clock-success drop-shadow-lg" />
          </div>

          <!-- Label -->
          <p class="text-xl lg:text-2xl font-bold text-white mt-3 drop-shadow-sm">
            {{ isClocking ? clockingText : (last_clock_value ? 'Clock Out' : 'Clock In') }}
          </p>

          <!-- Real-time timer when clocked in -->
          <p
            v-if="last_clock_value && liveTimer"
            class="text-sm text-white/80 mt-1 font-mono"
          >
            {{ liveTimer }}
          </p>
        </div>
      </div>

      <!-- ChartRange visible on all viewports -->
      <div class="mt-4 lg:mt-8">
        <template v-if="isLoading">
          <SkeletonLoader :lines="2" :chart="true" />
        </template>
        <template v-else>
          <ChartRange :user="user" />
        </template>
      </div>
    </main>
  </div>
</template>
