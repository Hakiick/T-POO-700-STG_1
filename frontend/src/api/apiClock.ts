import { AxiosResponse } from "axios";
import { apiClient } from "./api";

// Example: Fetch users from the API
export const getClockFromUser = async (
  user_id: number,
): Promise<AxiosResponse> => {
  try {
    const response = await apiClient.get(`/clocks/${user_id}`);
    return response;
  } catch (error: any) {
    if (error.response.status !== 404) {
      console.error("Error fetching clocks:", error);
    }
    // console.log("Error fetching clocks:", error);
    return error;
    // throw error;
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
