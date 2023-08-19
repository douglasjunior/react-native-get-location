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

import {Linking, NativeModules, Platform} from 'react-native';

import {
  GetCurrentPositionOptions,
  Location,
  requestAndroidPermission,
} from './utils';
import LocationError, {isLocationError} from './LocationError';

export {default as LocationError, isLocationError} from './LocationError';
export type {LocationErrorCode} from './LocationError';
export type {GetCurrentPositionOptions, Location} from './utils';

const {OS} = Platform;
const {ReactNativeGetLocation} = NativeModules;

const DEFAULT_OPTIONS: GetCurrentPositionOptions = {
  enableHighAccuracy: false,
  timeout: 60000,
};

const GetLocation = {
  async getCurrentPosition(
    options: GetCurrentPositionOptions = DEFAULT_OPTIONS,
  ): Promise<Location> {
    const opts = {...DEFAULT_OPTIONS, ...options};
    if (OS === 'android') {
      await requestAndroidPermission(opts.enableHighAccuracy, opts.rationale);
    }

    try {
      return ReactNativeGetLocation.getCurrentPosition(opts);
    } catch (error) {
      if (isLocationError(error)) {
        throw new LocationError(error.code, error.message);
      }
      throw error;
    }
  },

  openSettings() {
    return Linking.openSettings();
  },
};

export default GetLocation;
