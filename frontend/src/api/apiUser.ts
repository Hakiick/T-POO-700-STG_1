import { User } from "../components/store/userStore";
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

export const getAllUser = async () => {
  try {
    const response = await apiClient.get(`/users/all`);
    return response.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
}

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
export const updateUser = async (user: User) => {
  try {
    const response = await apiClient.put(`/users/${user.id}`, user);
    return response.data;
  } catch (error) {
    console.error("Error updating user:", error);
    // throw error;
    return error;
  }
};

// Example: Delete a user
export const deleteUser = async (user: User) => {
  try {
    const response = await apiClient.delete(`/users/${user.id}`);
    return response.data;
  } catch (error) {
    console.error("Error deleting user:", error);
    // throw error;
    return error;
  }
};
