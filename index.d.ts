import type { Rationale } from "react-native";

export class Location {
  /**
   * The latitude, in degrees
   */
  latitude: number;
  /**
   * The longitude, in degrees
   */
  longitude: number;
  /**
   * The altitude if available, in meters above the WGS 84 reference ellipsoid
   */
  altitude: number;
  /**
   * The estimated horizontal accuracy of this location, radial, in meters
   */
  accuracy: number;
  /**
   * The speed if it is available, in meters/second over ground
   */
  speed: any;
  /**
   * The UTC time of this fix, in milliseconds since January 1, 1970.
   */
  time: number;
  /**
   * (Android only) The bearing, in degrees
   */
  bearing?: number;
  /**
   * (Android only) The name of the provider that generated this fix
   */
  provider?: number;
  /**
   * (iOS only) The vertical accuracy of the location. Negative if the altitude is invalid
   */
  verticalAccuracy?: number;
  /**
   * (iOS only) The course of the location in degrees true North. Negative if course is invalid. (0.0 - 359.9 degrees, 0 being true North)
   */
  course?: number;
}

export interface GetCurrentPositionOptions {
  /**
   * Set `true` to use 'fine location' (GPS) our `false` to use 'course location' (Wifi, Bluetooth, 3G).
   */
  enableHighAccuracy: boolean;
  /**
   * The max time (in milliseconds) that you want to wait to receive a location.
   */
  timeout: number;
  /**
   * Android only
   * See the [React Native docs](https://reactnative.dev/docs/permissionsandroid#request)
   */
  rationale?: Rationale
}

export type LocationErrorCode =
  | "CANCELLED"
  | "UNAVAILABLE"
  | "TIMEOUT"
  | "UNAUTHORIZED";

export class LocationError extends Error {
  code: LocationErrorCode;
}

export default class GetLocation {
  /**
   * Request current device location. Can `throw` a LocationError.
   * 
   * @param options Configuration object to determine how to get the user current location.
   * @return Promise thats resolve to a Location object.
   */
  static getCurrentPosition(options: GetCurrentPositionOptions): Promise<Location>;

  /**
   * @deprecated use Linking.openSettings from React Native 
   */
  static openAppSettings();

  /**
   * @deprecated use Linking.openSettings from React Native 
   */
  static openWifiSettings();

  /**
   * @deprecated use Linking.openSettings from React Native 
   */
  static openCelularSettings();

  /**
   * @deprecated use Linking.openSettings from React Native 
   */
  static openGpsSettings();
}
