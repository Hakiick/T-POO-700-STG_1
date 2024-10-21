// stores/useUserStore.js
import { defineStore } from "pinia";
import { ref } from "vue";

export interface User {
  id: number;
  username: string;
  email: string;
}

const accessToken = ref<string | null>(null);
const refreshToken = ref<string | null>(null);

const user = ref<User | null>(null);

export const useUserStore = defineStore("user", () => {
  // console.log(user);

  const setUser = (userInfo: User) => {
    user.value = userInfo;
  };

  const logout = () => {
    user.value = null;
    accessToken.value = null;
    refreshToken.value = null;
    sessionStorage.removeItem("access_token");
    sessionStorage.removeItem("refresh_token");
  };

  return { user, accessToken, refreshToken, setUser, logout };
});
