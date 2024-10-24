import { AxiosResponse } from "axios";
import { apiClientProtected } from "./api";

// Example: Fetch users from the API
export const getClockFromUser = async (
  user_id: number,
): Promise<AxiosResponse> => {
  try {
    const response = await apiClientProtected.get(`/clock/${user_id}`);
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

export const getClocksFromUser = async (
  user_id: number,
  start: string,
  end: string,
): Promise<AxiosResponse> => {
  try {
    const response = await apiClientProtected.get(`/clocks/${user_id}`);
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
export const createClock = async (status: boolean, user_id: number) => {
  try {
    const response = await apiClientProtected.post(`/clocks/${user_id}`, {
      clock_status: status,
    });
    return response.data;
  } catch (error) {
    console.error("Error creating clock:", error);
    throw error;
  }
};

// You can add other API functions in a similar fashion.
