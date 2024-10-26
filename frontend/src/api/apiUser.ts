import { User } from "../components/store/userStore";
import { apiClient, apiClientProtected } from "./api";

async function hashPassword(password: string) {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return bufferToHex(hash);
}

// Fonction pour valider l'email avec une expression régulière
function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Fonction pour valider le mot de passe (longueur, caractère spéciaux, etc.)
function isValidPassword(password: string): boolean {
  // Vérifie si le mot de passe fait au moins 8 caractères et contient un nombre et une lettre
  const passwordRegex =
    // /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&-+=()!? "]).{8,128}$/;
    /^(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&-+=()!? "]).{8,128}$/;
  return passwordRegex.test(password);
}

// Vérification pour les noms d'utilisateur (pas de caractères spéciaux)
// function isValidUsername(username: string): boolean {
//   // Autorise uniquement les lettres, les chiffres, les underscores
//   const usernameRegex = /^[A-Za-z0-9_]+$/;
//   return usernameRegex.test(username);
// }

function bufferToHex(buffer: ArrayBuffer) {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

// Example: Fetch users from the API
export const getUser = async (user_id: number) => {
  try {
    const response = await apiClientProtected.get(`/users/${user_id}`);
    return response.data.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
};

// Example: Create a new user
export const getAllUser = async (): Promise<User[]> => {
  try {
    const response = await apiClientProtected.get(`/admin/gestion/users/all`);
    return response.data.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
};

// Example: Create a new user
export const getCurrentUser = async () => {
  try {
    const response = await apiClientProtected.get(`/user`);
    console.log(response);
    return response;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
};

// Fonction de création d'un utilisateur
export const createUser = async (
  username: string,
  email: string,
  password: string,
) => {
  if (!isValidEmail(email)) {
    return { data: { errors: { email: ["Invalid email"] } } };
  }

  if (!isValidPassword(password)) {
    return {
      data: {
        errors: {
          password: [
            "Password must be at least 8 characters long, contain at least one letter and one number",
          ],
        },
      },
    };
  }

  // if (!isValidUsername(username)) {
  //   return {
  //     data: {
  //       errors: {
  //         username: [
  //           "Username can only contain letters, numbers, and underscores",
  //         ],
  //       },
  //     },
  //   };
  // }

  try {
    const hashedPassword = await hashPassword(password);
    const response = await apiClient.post("/users/register", {
      user: {
        username,
        email,
        password: hashedPassword,
      },
    });

    return response;
  } catch (error) {
    console.error("Error creating user:", error);
    return error;
  }
};

export const loginUser = async (email: string, password: string) => {
  try {
    const hashedPassword = await hashPassword(password);
    const response = await apiClient.post("/users/login", {
      user: {
        email,
        password: hashedPassword,
      },
    });

    return response;
  } catch (error) {
    console.error("Error logging in user:", error);
    return error;
  }
};

// Example: Update a user
export const updateUser = async (user: User) : Promise<boolean> =>  {
  try {
    await apiClientProtected.put(`/admin/users/${user.id}`, { user });
    return true;
  } catch (error) {
    console.error("Error updating user:", error);
    // throw error;
    return false;
  }
};

// Example: Delete a user
export const deleteUser = async (user: User): Promise<Boolean> => {
  try {
    const response = await apiClientProtected.delete(`/admin/users/${user.id}`);
    return response.status == 204;
  } catch (error) {
    console.error("Error deleting user:", error);
    // throw error;
    return false;
  }
};

export const createUserAdmin = async (user: User): Promise<User> => {
  try {
    const response = await apiClientProtected.post(`/admin/users`, {user});
    return response.data;
  } catch(error) {
    console.error(error);
  }
}
