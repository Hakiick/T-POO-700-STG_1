// utils/dateUtils.ts

/**
 * Function to get Monday of the current week
 * @param {Date} d - The current date
 * @returns {Date} - The date corresponding to the Monday of the week
 */
export function getMonday(d: Date): Date {
    const date = new Date(d)
    const day = date.getDay()
    const diff = date.getDate() - day + (day === 0 ? -6 : 1) // Adjust for Sunday (day 0)
    return new Date(date.setDate(diff))
  }
  
  /**
   * Function to get Sunday of the current week
   * @param {Date} d - The current date
   * @returns {Date} - The date corresponding to the Sunday of the week
   */
  export function getSunday(d: Date): Date {
    const monday = getMonday(d)
    return new Date(monday.getTime() + 6 * 24 * 60 * 60 * 1000) // Add 6 days to Monday
  }
  