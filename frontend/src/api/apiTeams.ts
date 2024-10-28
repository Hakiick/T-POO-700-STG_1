import { apiClientProtected } from "./api";


export interface Team {
    id: number,
    name: string,
    description: string | undefined
}

export const getAllTeam = async () : Promise<Team[]> => {
    try {
        const response = await apiClientProtected.get("/admin/gestion/teams")
        return response.data.data;
    } catch(error) {
        console.error(error);
    }
}

export const createTeam = async(team: Team) : Promise<Team> => {
    try {
        const response = await apiClientProtected.post("/admin/gestion/teams", {teams: team})
    
        console.log(response.data);
        return response.data.data
    } catch(error) {
        console.error(error);
    }
}

export const deleteTeam = async(team: Team) : Promise<boolean> => {
    try {
        const response = await apiClientProtected.delete(`/admin/gestion/teams/${team.id}`);
        return response.status == 204;
    } catch(error) {
        console.error(error);
    }

    return false;
}


export const updateTeam = async(team: Team) : Promise<boolean> => {
    try {
        const response = await apiClientProtected.put(`/admin/gestion/teams/${team.id}`, {teams: team});
        console.log(response.status)
        return true;
    } catch (error) {
        console.error(error);
    }
    return false;
}

export const clockForTeam = async(team: Team, clockIn: boolean): Promise<void> => {
    try {
        let url = `/admin/teams/${team.id}/${clockIn ? "clock_id" : "clock_out"}`;
        const response = await apiClientProtected.get(url);

    } catch(error) {
        console.error(error);
        
    }
}