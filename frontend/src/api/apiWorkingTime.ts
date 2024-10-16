import { apiClient } from "./api";
import { AxiosResponse } from "axios";

// Example: Fetch users from the API
export const getWorkingTime = async (
  user_id: number
): Promise<AxiosResponse> => {
  try {
    const response = await apiClient.get(`/workingtime/${user_id}`);
    return response;
  } catch (error : any) {
    if (error.response.status !== 404) {
      console.error("Error fetching workingtime:", error);
    }
    return error;
  }
};
