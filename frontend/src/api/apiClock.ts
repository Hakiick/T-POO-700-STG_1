import { apiClient } from "./api";

// Example: Fetch users from the API
export const getClockFromUser = async (user_id: number) => {
  try {
    const response = await apiClient.get(`/clocks/${user_id}`);
    return response.data;
  } catch (error) {
    console.error("Error fetching clocks:", error);
    throw error;
  }
};

// Example: Create a new user
export const createClock = async (
  clockData: {
    time: String;
    status: boolean;
  },
  user_id: number,
) => {
  try {
    const response = await apiClient.post(`/clocks/${user_id}`, {
      clock: { time: clockData.time, status: clockData.status },
    });
    return response.data;
  } catch (error) {
    console.error("Error creating clock:", error);
    throw error;
  }
};

// You can add other API functions in a similar fashion.
