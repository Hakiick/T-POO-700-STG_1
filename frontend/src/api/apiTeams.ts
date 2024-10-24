import { apiClient } from "./api";


export interface Team {
    id: number,
    name: string,
    description: string | null
}

export const getAllTeam = async () : Promise<Team[]> => {
    try {
        const response = await apiClient.get("/teams")
        return response.data.data;
    } catch(error) {
        console.error(error);
    }
}

export const createTeam = async(team: Team) : Promise<Team> => {
    try {
        const response = await apiClient.post("/teams", {teams: team})
    
        console.log(response.data);
        return response.data.data
    } catch(error) {
        console.error(error);
    }
}

export const deleteTeam = async(team: Team) : Promise<boolean> => {
    try {
        const response = await apiClient.delete(`/teams/${team.id}`);
        return response.status == 204;
    } catch(error) {
        console.error(error);
    }

    return false;
}


export const updateTeam = async(team: Team) : Promise<boolean> => {
    try {
        const response = await apiClient.put(`/teams/${team.id}`, {teams: team});
        console.log(response.status)
        return true;
    } catch (error) {
        console.error(error);
    }
    return false;
}