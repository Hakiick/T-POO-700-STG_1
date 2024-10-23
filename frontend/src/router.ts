import { createRouter, createWebHistory } from "vue-router";
import HomePage from "./components/Template.vue";
import LoginPage from "./components/LoginPage.vue";
import UserAdminManagementPage from "./components/UserAdminPanel.vue";
import TeamsAdminPage from "./components/TeamAdminPanel.vue";

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
      component: UserAdminManagementPage
    },
    {
      path: "/admin/teams",
      name: "GestionTeams",
      component: TeamsAdminPage
    }
  ],
});
