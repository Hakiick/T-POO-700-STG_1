import { User } from "../components/store/userStore";
import { apiClient } from "./api";

async function hashPassword(password: string) {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return bufferToHex(hash);
}

function bufferToHex(buffer: ArrayBuffer) {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

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
export const createUser = async (
  username: string,
  email: string,
  password: string,
) => {
  try {
    const hashedpassword = await hashPassword(password);
    const response = await apiClient.post("/users/register", {
      user: {
        username,
        email,
        password: hashedpassword,
      },
    });
    // if (response.status !== 201) {
    //   return response.data.errors;
    // }
    return response;
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
