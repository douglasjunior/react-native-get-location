import { NativeModules, Platform } from 'react-native';

const { OS } = Platform;

const { ReactNativeGetLocation } = NativeModules;

const PREFS_WIFI = 'WIFI';
const PREFS_MOBILE_DATA = 'MOBILE_DATA_SETTINGS_ID';
const PREFS_LOCATION_SERVICES = 'LOCATION_SERVICES';

function openIOSSettings(key) {
    return Linking.openURL(`App-Prefs:root=${key}`)
        .catch(ex => {
            console.warn(ex);
            return Linking.openURL(`prefs:root=${key}`);
        }).catch(ex => {
            console.warn(ex);
            return Linking.openURL('App-Prefs:');
        }).catch(ex => {
            console.warn(ex);
            return Linking.openURL('prefs:');
        });
};

export default {
    getCurrentPosition(options = {
        enableHighAccuracy: false,
        timeout: 0,
    }) {
        return ReactNativeGetLocation.getCurrentPosition(options);
    },
    openWifiSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openWifiSettings();
        }
        return openIOSSettings(PREFS_WIFI);
    },
    openCelularSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openCelularSettings();
        }
        return openIOSSettings(PREFS_MOBILE_DATA);
    },
    openGpsSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openGpsSettings();
        }
        return openIOSSettings(PREFS_LOCATION_SERVICES);
    },
    openAppSettings() {
        return ReactNativeGetLocation.openAppSettings();
    }
};
