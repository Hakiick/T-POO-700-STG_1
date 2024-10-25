import { createRouter, createWebHistory } from "vue-router";
import HomePage from "./components/Template.vue";
import LoginPage from "./components/LoginPage.vue";
import ChartRange from "./components/ChartRange.vue";
import UserAdminManagementPage from "./components/UserAdminPanel.vue";
import TeamsAdminPage from "./components/TeamAdminPanel.vue";
import DashBoardAdmin from "./components/DashBoardAdmin.vue";
import { useUserStore } from "./components/store/userStore";
import { computed } from "vue";

const routes = [
  {
    path: "/",
    name: "home",
    component: HomePage,
    meta: { requiresAuth: true },
    // props: true,
  },
  {
    path: "/login",
    name: "login",
    component: LoginPage,
  },
  {
    path: "/dashboard",
    name: "ChartRange",
    component: ChartRange,
    meta: { requiresAuth: true },
  },
  {
    path: "/admin/users",
    name: "UserAdminManagement",
    component: UserAdminManagementPage,
    meta: { requiresAuth: true },
  },
  {
    path: "/admin/teams",
    name: "GestionTeams",
    component: TeamsAdminPage,
    meta: { requiresAuth: true },
  },
  {
    path: "/admin/dashboard",
    name: "DashBoardAdmin",
    component: DashBoardAdmin,
    meta: { requiresAuth: true },
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach(async (to, _from, next) => {
  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth);
  // const groups = to.matched[0].meta.groups;
  const userStore = useUserStore();

  if (to.name === "NotFound") {
    next();
  }

  if (!requiresAuth) {
    next();
    return;
  }

  if (to.name === "Login" && sessionStorage.getItem("refresh_token")) {
    next({ name: "home" });
    return;
  }

  if (!sessionStorage.getItem("refresh_token")) {
    next({ name: "login" });
    return;
  }

  if (!userStore.user) {
    userStore.login();
  }

  next();
  // const user = computed(userStore.user);

  // let groupCheck = false;

  // if (!groups) {
  //   groupCheck = true;
  // } else if (
  //   Array.isArray(groups) &&
  //   groups.every((group) => typeof group === "string") &&
  //   user !== false
  // ) {
  //   groupCheck = groups.some((group) => {
  //     return user.groups.map((g) => g.name).includes(group);
  //   });
  // }

  // if (!groupCheck && to.name !== "Login") {
  //   next({ name: "Login" });
  // } else {
  //   next();
  // }
});

export default router;
