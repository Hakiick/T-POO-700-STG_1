import { createRouter, createWebHistory } from "vue-router";
import HomePage from "./components/Template.vue";
import LoginPage from "./components/LoginPage.vue";
import ChartRange from "./components/ChartRange.vue";
import UserAdminManagementPage from "./components/UserAdminPanel.vue";
import TeamsAdminPage from "./components/TeamAdminPanel.vue";
import DashBoardAdmin from "./components/DashBoardAdmin.vue";
import NewPassword from "./components/NewPassword.vue";
import ConfirmAccount from "./components/ConfirmAccount.vue";
import { useUserStore } from "./components/store/userStore";

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
    path: "/users/reset_password",
    name: "passwordReset",
    component: NewPassword,
  },
  {
    path: "/users/confirm",
    name: "confirmAccount",
    component: ConfirmAccount,
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

  // Redirect to home if trying to access the login page while already logged in
  if (to.name === "login" && sessionStorage.getItem("refresh_token")) {
    return next({ name: "home" });
  }

  // If route doesn't require auth, proceed
  if (!requiresAuth) {
    return next();
  }

  // If auth is required, check if refresh_token exists
  if (!sessionStorage.getItem("refresh_token")) {
    return next({ name: "login" });
  }

  // Attempt to log in with stored token
  await userStore.login();

  // If user is not logged in after attempting login, redirect to login
  if (!userStore.user) {
    return next({ name: "login" });
  }

  // If all checks pass, allow route navigation
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
