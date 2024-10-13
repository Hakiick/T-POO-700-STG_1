import { createRouter, createWebHistory } from "vue-router";
import HomePage from "./components/Template.vue";
import LoginPage from "./components/LoginPage.vue";

export default createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      name: "home",
      component: () => HomePage,
      // props: true,
    },
    {
      path: "/login",
      name: "login",
      component: () => LoginPage,
    },
  ],
});
