import { apiClient } from "./api";

// Example: Fetch users from the API
export const getWorkingTime = async (user_id: number) => {
  try {
    const response = await apiClient.get(`/workingtime/${user_id}`);
    return response.data;
  } catch (error) {
    console.error("Error fetching workingtime:", error);
    throw error;
  }
};
