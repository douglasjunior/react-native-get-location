import { NativeModules, Platform, Linking } from 'react-native';

const { OS } = Platform;
const { ReactNativeGetLocation } = NativeModules;

async function openUrlIfCan(url) {
    console.log('openUrlIfCan', url);
    if (await Linking.canOpenURL(url)) {
        await Linking.openURL(url);
        return true;
    }
    return false;
}

async function openIOSSettings(root, path = '') {
    if (await openUrlIfCan(`prefs:root=${root}&path=${path}`)) {
        return true;
    }
    if (await openUrlIfCan(`App-Prefs:root=${root}&path=${path}`)) {
        return true;
    }
    if (await openUrlIfCan('prefs:')) {
        return true;
    }
    if (await openUrlIfCan('App-Prefs:')) {
        return true;
    }
    return false;
};

export default {
    getCurrentPosition(options = {
        enableHighAccuracy: false,
        timeout: 0,
    }) {
        return ReactNativeGetLocation.getCurrentPosition(options);
    },

    // Extra functions

    async openWifiSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openWifiSettings();
        }
        if (await openIOSSettings('WIFI')) {
            return true;
        }
        return ReactNativeGetLocation.openAppSettings();
    },

    async openCelularSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openCelularSettings();
        }
        if (await openIOSSettings('MOBILE_DATA_SETTINGS_ID')) {
            return true;
        }
        return ReactNativeGetLocation.openAppSettings();
    },

    async openGpsSettings() {
        if (OS === 'android') {
            return ReactNativeGetLocation.openGpsSettings();
        }
        // if (await openIOSSettings('Privacy', 'LOCATION')) {
        //     return true;
        // }
        if (await openIOSSettings('LOCATION_SERVICE', 'LOCATION')) {
            return true;
        }
        return ReactNativeGetLocation.openAppSettings();
    },

    openAppSettings() {
        return ReactNativeGetLocation.openAppSettings();
    }
};
