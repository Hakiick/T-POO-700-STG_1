import { defineStore } from "pinia";
import { getAllTeam, Team } from "../../api/apiTeams.ts"
import { getAllTeamsFromUser } from "../../api/apiManage";
import { ref } from "vue";
import { useUserStore } from "./userStore.ts";

const accessibleTeams = ref<Team[]>([]);
const currentTeam = ref<Team>();

export const useTeamStore = defineStore("team", () => {
    
    

    const populateTeamStore = async() => {

        accessibleTeams.value = [];
        currentTeam.value = undefined;
        const user = useUserStore().user;
        console.log(user.role)
        switch(user.role) {
            case "manager":
                accessibleTeams.value = await getAllTeamsFromUser(user);
                break;
            case "general_manager":
                accessibleTeams.value = await getAllTeam();

                const customTeam = {
                    id: -1,
                    name: "All",
                    description: ""
                };
                accessibleTeams.value.unshift(customTeam);
                break;
            default: 
                break;
        }
        if (accessibleTeams.value.length > 0 && currentTeam.value == undefined) {
                currentTeam.value = accessibleTeams.value[0]
            }

    }



    return { accessibleTeams, currentTeam, populateTeamStore }
})
