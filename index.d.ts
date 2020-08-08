declare module "react-native-get-location" {
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

  export function getCurrentPosition(
    options: GetCurrentPositionOptions
  ): Promise<Location>;
}
