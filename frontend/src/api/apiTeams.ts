import { AxiosResponse } from "axios";
import { apiClient } from "./api";

export const getAllTeams = async () => {
    try {
        const response = await apiClient.get("/teams")
        return response.data;
    } catch(error) {
        console.error(error);
    }
}