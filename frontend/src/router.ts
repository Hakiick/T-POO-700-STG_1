import { createRouter, createWebHistory } from "vue-router"
import type { RouteRecordRaw } from "vue-router"
import { useUserStore } from "./components/store/userStore"
import { useTeamStore } from "./components/store/teamStore"

declare module "vue-router" {
  interface RouteMeta {
    requiresAuth?: boolean
    layout?: "main" | "auth"
  }
}

const routes: RouteRecordRaw[] = [
  {
    path: "/",
    name: "clock",
    component: () => import("./pages/Clock.vue"),
    meta: { requiresAuth: true, layout: "main" },
  },
  {
    path: "/dashboard",
    name: "dashboard",
    component: () => import("./pages/Dashboard.vue"),
    meta: { requiresAuth: true, layout: "main" },
  },
  {
    path: "/team",
    name: "team",
    component: () => import("./pages/Team.vue"),
    meta: { requiresAuth: true, layout: "main" },
  },
  {
    path: "/admin",
    name: "admin",
    component: () => import("./pages/Admin.vue"),
    meta: { requiresAuth: true, layout: "main" },
  },
  {
    path: "/settings",
    name: "settings",
    component: () => import("./pages/Settings.vue"),
    meta: { requiresAuth: true, layout: "main" },
  },
  {
    path: "/login",
    name: "login",
    component: () => import("./pages/Login.vue"),
    meta: { layout: "auth" },
  },
  {
    path: "/register",
    name: "register",
    component: () => import("./pages/Register.vue"),
    meta: { layout: "auth" },
  },
  {
    path: "/users/reset_password",
    name: "passwordReset",
    component: () => import("./components/NewPassword.vue"),
    meta: { layout: "auth" },
  },
  {
    path: "/users/confirm",
    name: "confirmAccount",
    component: () => import("./components/ConfirmAccount.vue"),
    meta: { layout: "auth" },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to, _from, next) => {
  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth)
  const userStore = useUserStore()
  const teamStore = useTeamStore()

  // Redirect to home if trying to access the login page while already logged in
  if (to.name === "login" && sessionStorage.getItem("refresh_token")) {
    return next({ name: "clock" })
  }

  // If route doesn't require auth, proceed
  if (!requiresAuth) {
    return next()
  }

  // If auth is required, check if refresh_token exists
  if (!sessionStorage.getItem("refresh_token")) {
    return next({ name: "login" })
  }

  // Attempt to log in with stored token
  await userStore.login()

  // populate the team store
  await teamStore.populateTeamStore()

  // If user is not logged in after attempting login, redirect to login
  if (!userStore.user) {
    return next({ name: "login" })
  }

  // If all checks pass, allow route navigation
  next()
})

export default router
