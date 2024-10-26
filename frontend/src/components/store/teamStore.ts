import { defineStore } from "pinia";
import { getAllTeam, Team } from "../../api/apiTeams.ts"
import { getAllTeamsFromUser } from "../../api/apiManage";
import { ref } from "vue";
import { useUserStore } from "./userStore.ts";

const accessibleTeams = ref<Team[]>([]);
const currentTeam = ref<Team>();

export const useTeamStore = defineStore("team", () => {
    const populateTeamStore = async() => {
        const user = useUserStore().user;

        switch(user.role) {
            case "manager":
                accessibleTeams.value = await getAllTeamsFromUser(user);
                break;
            case "general":
                accessibleTeams.value = await getAllTeam();
                break;
            default: 

                // REMOVE IS ONLY FOR TEST
                accessibleTeams.value = await getAllTeam();
                break;
        }

    }

    return { accessibleTeams, currentTeam, populateTeamStore }
})
