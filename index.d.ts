
export class Location {
  latitude: number;
  longitude: number;
  altitude: number;
  accuracy: number;
  speed: any;
  time: number;
  bearing?: number;
  provider?: number;
  verticalAccuracy?: number;
  course?: number;
}

export interface GetCurrentPositionOptions {
  enableHighAccuracy: boolean;
  timeout: number;
}

export type LocationErrorCode =
  | "CANCELLED"
  | "UNAVAILABLE"
  | "TIMEOUT"
  | "UNAUTHORIZED";

export class LocationError extends Error {
  code: LocationErrorCode;
}

function getCurrentPosition(
  options: GetCurrentPositionOptions
): Promise<Location>;

export default {
  getCurrentPosition
}
