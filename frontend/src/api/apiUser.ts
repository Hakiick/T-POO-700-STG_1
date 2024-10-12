import { apiClient } from "./api";

// Example: Fetch users from the API
export const getUser = async (user_id: number) => {
  try {
    const response = await apiClient.get(`/users/${user_id}`);
    return response.data.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
};

// Example: Create a new user
export const createUser = async (username: string, email: string) => {
  try {
    const response = await apiClient.post("/users", { username, email });
    if (response.status !== 201) {
      throw new Error("Error creating user");
    }
    return response.data;
  } catch (error) {
    console.error("Error creating user:", error);
    // throw error;
    return error;
  }
};

// Example: Update a user
export const updateUser = async (
  user_id: number,
  userData: { username: string; email: string },
) => {
  try {
    const response = await apiClient.put(`/users/${user_id}`, userData);
    return response.data;
  } catch (error) {
    console.error("Error updating user:", error);
    throw error;
  }
};

// Example: Delete a user
export const deleteUser = async (user_id: number) => {
  try {
    const response = await apiClient.delete(`/users/${user_id}`);
    return response.data;
  } catch (error) {
    console.error("Error deleting user:", error);
    throw error;
  }
};
