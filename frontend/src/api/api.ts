import axios, { AxiosInstance } from "axios";

// Create an Axios instance
export const apiClient: AxiosInstance = axios.create({
  baseURL: "/api", // Base URL for your API
  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  },
});
