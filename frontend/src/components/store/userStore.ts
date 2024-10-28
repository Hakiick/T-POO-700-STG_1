// stores/useUserStore.js
import { getCurrentUser } from "@/api/apiUser";
import router from "@/router";
import { defineStore } from "pinia";
import { ref } from "vue";

export interface User {
  id: number;
  username: string;
  role: string;
  email: string;
}

const accessToken = ref<string | null>(null);
const refreshToken = ref<string | null>(null);

const user = ref<User>(null);

export const useUserStore = defineStore("user", () => {
  // console.log(user);

  const login = async () => {
    const resp = await getCurrentUser();
    // console.log("o max", response);
    if (resp.status === 200) {
      user.value = resp.data.data;
      // console.log("user", user.value);
      return true;
    }
  };

  const logout = () => {
    user.value = null;
    accessToken.value = null;
    refreshToken.value = null;
    sessionStorage.removeItem("access_token");
    sessionStorage.removeItem("refresh_token");
    router.push("/login");
  };

  return { user, accessToken, refreshToken, login, logout };
});
