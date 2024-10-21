import { apiClient } from "./api";
import { AxiosResponse, AxiosError } from "axios";

export const getWorkingTime = async (
  user_id: number,
  start: string,
  end: string,
): Promise<AxiosResponse | null> => {
  try {
    const response = await apiClient.get(
      `/workingtime/${user_id}?start=${start}&end=${end}`,
    );
    return response;
  } catch (error: AxiosError | any) {
    if (error.response?.status !== 404) {
      console.error("Error fetching working time:", error);
    } else {
      console.warn("No working time found for this user within the date range.");
    }
    return null;
  }
};
