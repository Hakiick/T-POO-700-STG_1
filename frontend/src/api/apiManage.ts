import { User } from "@/components/store/userStore";
import { apiClient } from "./api";
import { Team } from "./apiTeams";

export const getAllUsersFromTeam = async(team: Team): Promise<User[]> => {
    try {
        const response = await apiClient.get(`/teams/${team.id}/users`);
        return response.data.data;
    } catch (error) {
        console.error(error);
        
    }
}

export const getAllTeamsFromUser = async(user: User): Promise<Team[]> => {
    try {
        const response = await apiClient.get(`/users/${user.id}/teams`);
        return response.data.data;
    } catch(error) {
        console.error(error);
        
    }
}

export const addUserInTeam = async (user:User, team: Team): Promise<boolean> => {
    try {
        const response = await apiClient.post("/manage", {
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
        const response = await apiClient.delete(`/manage/${user.id}/${team.id}`)
        return response.status == 204;
    } catch(error) {
        console.error(error);
        
    }

    return false;
}