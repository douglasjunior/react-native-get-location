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

import {
    NativeModules, Platform, Linking,
    PermissionsAndroid,
} from 'react-native';

import LocationError from './LocationError';

const { OS } = Platform;
const Version = parseInt(Platform.Version);
const { ReactNativeGetLocation } = NativeModules;

async function openUrlIfCan(url) {
    if (await Linking.canOpenURL(url)) {
        await Linking.openURL(url);
        return true;
    }
    return false;
}

async function openIOSSettings(root, path = '') {
    if (await openUrlIfCan(`App-Prefs:root=${root}${path ? `&path=${path}` : ''}`)) {
        return true;
    }
    if (await openUrlIfCan('App-Prefs:')) {
        return true;
    }
    return false;
};

async function requestAndroidPermission(enableHighAccuracy = false) {
    const { PERMISSIONS, RESULTS } = PermissionsAndroid;
    const granted = await PermissionsAndroid.request(enableHighAccuracy
        ? PERMISSIONS.ACCESS_FINE_LOCATION
        : PERMISSIONS.ACCESS_COARSE_LOCATION);
    if (granted !== RESULTS.GRANTED) {
        throw new LocationError('UNAUTHORIZED', 'Authorization denied');
    }
    return true;
}

export default {
    async getCurrentPosition(options = {
        enableHighAccuracy: false,
        timeout: 0,
    }) {
        if (OS === 'android') {
            await requestAndroidPermission(options.enableHighAccuracy);
        }
        try {
            const location = await ReactNativeGetLocation.getCurrentPosition(options);
            return location;
        } catch (error) {
            const { code, message } = error;
            const locationError = new LocationError(code, message);
            locationError.stack = error.stack;
            throw locationError;
        }
    },

    // Extra functions

    openAppSettings() {
        return ReactNativeGetLocation.openAppSettings();
    },

    /**
     * Only for Android
     */
    async openWifiSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openWifiSettings();
        }

        if (await openIOSSettings('WIFI')) {
            return true;
        }

        return ReactNativeGetLocation.openAppSettings();
    },

    /**
     * Only for Android
     */
    async openCelularSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openCelularSettings();
        }

        if (await openIOSSettings('MOBILE_DATA_SETTINGS_ID')) {
            return true;
        }

        return ReactNativeGetLocation.openAppSettings();
    },

    /**
     * Only for Android
     */
    async openGpsSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openGpsSettings();
        }

        if (Version >= 10) {
            if (await openIOSSettings('Privacy', 'LOCATION')) {
                return true;
            }
        } else {
            if (await openIOSSettings('LOCATION_SERVICES')) {
                return true;
            }
        }

        return ReactNativeGetLocation.openAppSettings();
    },
};
