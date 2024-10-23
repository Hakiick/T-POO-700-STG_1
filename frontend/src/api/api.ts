import axios, { AxiosInstance } from "axios";
// import { useUserStore } from "../components/store/userStore";

// const userStore = useUserStore();

// Create an Axios instance
export const apiClient: AxiosInstance = axios.create({
  baseURL: "/api", // Base URL for your API
  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  },
});

export const apiClientProtected: AxiosInstance = axios.create({
  baseURL: "/api", // Base URL for your API
  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    Authorization: `Bearer ${sessionStorage.getItem("access_token")}`,
    "Cache-Control": "max-age=60",
  },
});

// // Request interceptor to attach access token
// axios.interceptors.request.use(
//   (config) => {
//     const accessToken = sessionStorage.getItem("access_token");
//     if (accessToken) {
//       config.headers["Authorization"] = `Bearer ${accessToken}`;
//     }
//     return config;
//   },
//   (error) => {
//     return Promise.reject(error);
//   },
// );
//
// Response interceptor to handle token expiration and refresh token logic
// apiClient.interceptors.response.use(
//   (response) => {
//     return response;
//   },
//   async (error) => {
//     const originalRequest = error.config;
//
//     if (
//       error.response &&
//       error.response.status === 401 &&
//       !originalRequest._retry
//     ) {
//       originalRequest._retry = true;
//       try {
//         // Try refreshing the access token
//         const newAccessToken = await AuthService.refreshToken();
//         axios.defaults.headers.common["Authorization"] =
//           `Bearer ${newAccessToken}`;
//         originalRequest.headers["Authorization"] = `Bearer ${newAccessToken}`;
//         return axios(originalRequest);
//       } catch (err) {
//         // Logout and redirect to login if refresh token fails
//         userStore.logout();
//         window.location.href = "/login";
//         return Promise.reject(err);
//       }
//     }
//
//     return Promise.reject(error);
//   },
// );
