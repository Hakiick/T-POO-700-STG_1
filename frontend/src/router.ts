import { createRouter, createWebHistory } from "vue-router";

export default createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      component: () => import("./components/Template.vue"),
    },
    {
      path: "/login",
      component: () => import("./components/LoginPage.vue"),
    },
  ],
});

