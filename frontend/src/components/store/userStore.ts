// stores/useUserStore.js
import { defineStore } from "pinia";
import { ref } from "vue";

interface User {
  id: number;
  username: string;
  email: string;
}

const user = ref<User | null>(null);

export const useUserStore = defineStore("user", () => {
  // console.log(user);

  const setUser = (userInfo: User) => {
    user.value = userInfo;
  };

  const clearUser = () => {
    user.value = null;
  };

  return { user, setUser, clearUser };
});
