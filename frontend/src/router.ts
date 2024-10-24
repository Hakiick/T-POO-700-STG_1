import { createRouter, createWebHistory } from "vue-router";
import HomePage from "./components/Template.vue";
import LoginPage from "./components/LoginPage.vue";
import UserAdminManagementPage from "./components/AdminPanel.vue";
import ChartRange from "./components/ChartRange.vue";

export default createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      name: "home",
      component: HomePage,
      // props: true,
    },
    {
      path: "/login",
      name: "login",
      component: LoginPage,
    },
    {
      path: "/admin/users",
      name: "UserAdminManagement",
      component: UserAdminManagementPage,
    },
    {
      path: "/dashboard",
      name: "ChartRange",
      component: ChartRange,
    }
  ],
});
