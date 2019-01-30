import { NativeModules } from 'react-native';

const { ReactNativeGetLocation } = NativeModules;

function getCurrentPosition(options = {
    enableHighAccuracy: false,
    timeout: 0,
}) {
    return ReactNativeGetLocation.getCurrentPosition(options);
}

export default {
    getCurrentPosition,
};
