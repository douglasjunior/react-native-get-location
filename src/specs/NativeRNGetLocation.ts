import type {TurboModule} from 'react-native';
import {TurboModuleRegistry} from 'react-native';
import {Float, Int32} from 'react-native/Libraries/Types/CodegenTypes';

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
  timeout: Int32;
};

export type Location = {
  /**
   * The latitude, in degrees
   */
  latitude: Float;
  /**
   * The longitude, in degrees
   */
  longitude: Float;
  /**
   * The altitude if available, in meters above the WGS 84 reference ellipsoid
   */
  altitude: Float;
  /**
   * The estimated horizontal accuracy of this location, radial, in meters
   */
  accuracy: Float;
  /**
   * The speed if it is available, in meters/second over ground
   */
  speed: Float;
  /**
   * The UTC time of this fix, in milliseconds since January 1, 1970.
   */
  time: Int32;
  /**
   * (Android only) The bearing, in degrees
   */
  bearing?: Float;
  /**
   * (Android only) The name of the provider that generated this fix
   */
  provider?: string;
  /**
   * (iOS only) The vertical accuracy of the location. Negative if the altitude is invalid
   */
  verticalAccuracy?: Float;
  /**
   * (iOS only) The course of the location in degrees true North. Negative if course is invalid. (0.0 - 359.9 degrees, 0 being true North)
   */
  course?: Float;
};

export interface Spec extends TurboModule {
  getCurrentPosition(options: NativeOptions): Promise<Location>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNGetLocation');
