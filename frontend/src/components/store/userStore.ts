// stores/useUserStore.js
import { defineStore } from "pinia";
import { ref } from "vue";

const user = ref(null);

export const useUserStore = defineStore("user", () => {
  // console.log(user);

  const setUser = (userInfo) => {
    user.value = userInfo;
  };

  const clearUser = () => {
    user.value = null;
  };

  return { user, setUser, clearUser };
});
