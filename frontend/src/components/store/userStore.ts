// stores/useUserStore.js
import { getCurrentUser } from "@/api/apiUser";
import router from "@/router";
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

  const login = async () => {
    getCurrentUser().then((response) => {
      // console.log("o max", response);
      if (response.status === 200) {
        user.value = response.data.data;
        // console.log("user", user.value);
      }
    });
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
