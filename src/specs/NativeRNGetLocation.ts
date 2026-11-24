import type {TurboModule, CodegenTypes} from 'react-native';
import {TurboModuleRegistry} from 'react-native';

export type NativeOptions = {
  /**
   * Set `true` to use 'fine location' (GPS) our `false` to use 'course location' (Wifi, Bluetooth, 3G).
   *
   * Default: false
   */
  enableHighAccuracy: boolean;
  /**
   * The max time (in milliseconds) that you want to wait to receive a location.
   *
   * Default: 60000 (60 seconds)
   */
  timeout: CodegenTypes.Int32;
};

export type Location = {
  /**
   * The latitude, in degrees
   */
  latitude: CodegenTypes.Float;
  /**
   * The longitude, in degrees
   */
  longitude: CodegenTypes.Float;
  /**
   * The altitude if available, in meters above the WGS 84 reference ellipsoid
   */
  altitude: CodegenTypes.Float;
  /**
   * The estimated horizontal accuracy of this location, radial, in meters
   */
  accuracy: CodegenTypes.Float;
  /**
   * The speed if it is available, in meters/second over ground
   */
  speed: CodegenTypes.Float;
  /**
   * The UTC time of this fix, in milliseconds since January 1, 1970.
   */
  time: CodegenTypes.Int32;
  /**
   * (Android only) The bearing, in degrees
   */
  bearing?: CodegenTypes.Float;
  /**
   * (Android only) The name of the provider that generated this fix
   */
  provider?: string;
  /**
   * (Android only) `true` when Android has flagged this fix as coming from a mock provider
   */
  mocked?: boolean;
  /**
   * (iOS only) The vertical accuracy of the location. Negative if the altitude is invalid
   */
  verticalAccuracy?: CodegenTypes.Float;
  /**
   * (iOS only) The course of the location in degrees true North. Negative if course is invalid. (0.0 - 359.9 degrees, 0 being true North)
   */
  course?: CodegenTypes.Float;
};

export interface Spec extends TurboModule {
  getCurrentPosition(options: NativeOptions): Promise<Location>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNGetLocation');
