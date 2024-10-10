import { createRouter, createWebHistory } from "vue-router";

export default createRouter({
    history: createWebHistory(),
    routes: [
        {
            path: '/',
            component: () => import('./components/HelloWorld.vue')
        },
        {
            path: '/me',
            component: () => import('./components/Me.vue')
        }
    ]
})