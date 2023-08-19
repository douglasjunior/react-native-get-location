/**
 * MIT License
 *
 * Copyright (c) 2019 Douglas Nassif Roma Junior
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import {PermissionsAndroid, Rationale} from 'react-native';

import LocationError from './LocationError';

export type Location = {
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
};

export type GetCurrentPositionOptions = {
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
  timeout: number;
  /**
   * Android only
   * See the [React Native docs](https://reactnative.dev/docs/permissionsandroid#request)
   */
  rationale?: Rationale;
};

export async function requestAndroidPermission(
  enableHighAccuracy: boolean = false,
  rationale?: Rationale,
) {
  const {PERMISSIONS, RESULTS} = PermissionsAndroid;

  const granted = await PermissionsAndroid.request(
    enableHighAccuracy
      ? PERMISSIONS.ACCESS_FINE_LOCATION
      : PERMISSIONS.ACCESS_COARSE_LOCATION,
    rationale,
  );

  if (granted !== RESULTS.GRANTED) {
    throw new LocationError('UNAUTHORIZED', 'Authorization denied');
  }

  return true;
}
