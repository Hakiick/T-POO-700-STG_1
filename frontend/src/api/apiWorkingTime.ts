import { User } from "../components/store/userStore";
import { apiClient } from "./api";

export interface WorkingTime {
  id: number;
  start: string;
  end: string;
}

// Example: Fetch users from the API
export const getWorkingTimes = async (user: User) => {
  try {
    const response = await apiClient.get(`/workingtime/${user.id}`);
    return response.data.data;
  } catch (error) {
    console.error("Error fetching getWorkingTimes:", error);
    throw error;
  }
};

// Example: Create a new working_time
// example of createWorkingTime
// const response_test = await createWorkingTime(user.value, { start: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'), end: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]') });
export const createWorkingTime = async (
  user: User,
  working_time: { start: string; end: string },
) => {
  try {
    const response = await apiClient.post(`/workingtime/${user.id}`, {
      working_time: { ...working_time },
    });
    if (response.status !== 201) {
      throw new Error("Error creating working_time");
    }
    return response.data;
  } catch (error) {
    console.error("Error creating working_time:", error);
    // throw error;
    return error;
  }
};

// Example: Update a working_time
// const response_test = await updateWorkingTime({ id: 1, start: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]'), end: moment.utc().format('YYYY-MM-DDTHH:mm:ss[Z]') });

export const updateWorkingTime = async (working_time: WorkingTime) => {
  try {
    const response = await apiClient.put(`/workingtime/${working_time.id}`, {
      working_time: { ...working_time },
    });
    return response.data;
  } catch (error) {
    console.error("Error updating working_time:", error);
    // throw error;
    return error;
  }
};

// Example: Delete a working_time
export const deleteWorkingTime = async (working_time: WorkingTime) => {
  try {
    const response = await apiClient.delete(`/workingtime/${working_time.id}`);
    return response.data;
  } catch (error) {
    console.error("Error deleting working_time:", error);
    // throw error;
    return error;
  }
};
