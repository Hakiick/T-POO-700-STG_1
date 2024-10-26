import { User } from "@/components/store/userStore";
import { apiClientProtected } from "./api";
import { Team } from "./apiTeams";

export const getAllUsersFromTeam = async(team: Team | undefined): Promise<User[]> => {
    if (team == undefined) return;

    try {
        const response = await apiClientProtected.get(`/admin/teams/${team.id}/users`);
        return response.data.data;
    } catch (error) {
        console.error(error);
        
    }
}

export const getAllTeamsFromUser = async(): Promise<Team[]> => {
    try {
        const response = await apiClientProtected.get(`/admin/users/teams`);
        return response.data.data;
    } catch(error) {
        console.error(error);
        
    }
}

export const addUserInTeam = async (user:User, team: Team): Promise<boolean> => {
    try {
        const response = await apiClientProtected.post("/admin/manage", {
            "userId": user.id,
            "teamId": team.id
        });
        return response.data
    } catch(error) {
        console.error(error);
    }
}

export const deleteUserInTeam = async (user:User, team: Team): Promise<boolean> => {
    try {
        const response = await apiClientProtected.delete(`/admin/manage/${user.id}/${team.id}`)
        return response.status == 204;
    } catch(error) {
        console.error(error);
        
    }

    return false;
}