import { apiClient } from "./api";

// Example: Fetch users from the API
export const getUser = async (user_id: number) => {
  try {
    const response = await apiClient.get(`/users/${user_id}`);
    return response.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
};

// Example: Create a new user
export const createUser = async (userData: { name: string; email: string }) => {
  try {
    const response = await apiClient.post("/users", userData);
    return response.data;
  } catch (error) {
    console.error("Error creating user:", error);
    throw error;
  }
};

// You can add other API functions in a similar fashion.
