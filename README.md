# React-Native Get Location

[![Licence MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/douglasjunior/react-native-get-location/blob/master/LICENSE)
[![npm version](https://img.shields.io/npm/v/react-native-get-location.svg)](https://www.npmjs.com/package/react-native-get-location)
[![npm downloads](https://img.shields.io/npm/dt/react-native-get-location.svg)](#install-with-react-native-link)

⚛ Simple to use React Native library to get device location for Android and iOS.

## Requirements

- React Native >= 0.45.0
- React >= 16.0.0-alpha.8
- iOS >= 8.0

## Install with `react-native link`:

1. Install dependency package
    ```bash
    yarn add react-native-get-location
    ```
    Or
    ```bash
    npm i -S react-native-get-location
    ```

2. Link the native project
    ```bash
    react-native link react-native-get-location
    ```

## Android post install

For Android API < 23 you need to define the location permissions on `AndroidManifest.xml`.

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

For Android API >= 23, you need to ask for permission in runtime. You can use the React Native [PermissionsAndroid API](https://facebook.github.io/react-native/docs/permissionsandroid) or a universal library like [react-native-permissions](https://github.com/yonahforst/react-native-permissions).

## iOS post install

You need to define the permission [NSLocationWhenInUseUsageDescription](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW26) on `Info.plist`.

Also, you need to ask for permissions in runtime. You can use the React Native [Geolocation API](https://facebook.github.io/react-native/docs/geolocation) or a universal library like [react-native-permissions](https://github.com/yonahforst/react-native-permissions).

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs to get your location...</string>
```

## Usage

There is only one function that you need to use to get the user's current location.

```js
import GetLocation from 'react-native-keyboard-manager'

GetLocation.getCurrentPosition({
    enableHighAccuracy: true,
    timeout: 30,
})
.then(location => {
    console.log(location);
})
.catch(error => {
    const { code, message } = error;
    console.warn(code, message);
})
```

For more details, see the [Sample Project](https://github.com/douglasjunior/react-native-get-location/blob/master/Sample/App.js).

## API

### function `GetLocation.getCurrentPosition(LocationConfig)`

**Parameters:**
   - [`LocationConfig`](#object-locationconfig): Configuration object to determine how to get the user current location.

**Return:**
   - `Promise<`[`Location`](#object-location)`>`: Promise thats resolve to a Location object.

### Object `LocationConfig`

**Properties:**
   - `enableHighAccuracy`: Set `true` to use 'fine location' (GPS) our `false` to use 'course location' (Wifi, Bluetooth, 3G).
   - `timeout`: The max time (in seconds) that you want to wait for a location.

### Object `Location`

**Properties:**
   - `latitude`: The latitude, in degrees.
   - `longitude`: The longitude, in degrees.
   - `altitude`: The altitude if available, in meters above the WGS 84 reference ellipsoid.
   - `accuracy`: The estimated horizontal accuracy of this location, radial, in meters.
   - `speed`: The speed if it is available, in meters/second over ground.
   - `time`: *(Android only)* The UTC time of this fix, in milliseconds since January 1, 1970.
   - `bearing`: *(Android only)* The bearing, in degrees.
   - `provider`: *(Android only)* The name of the provider that generated this fix.

## Contribute

New features, bug fixes and improvements are welcome! For questions and suggestions use the [issues](https://github.com/douglasjunior/react-native-get-location/issues).

<a href="https://www.patreon.com/douglasjunior"><img src="http://i.imgur.com/xEO164Z.png" alt="Become a Patron!" width="200" /></a>
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=E32BUP77SVBA2)

## Licence

```
The MIT License (MIT)

Copyright (c) 2019 Douglas Nassif Roma Junior
```

See the full [licence file](https://github.com/douglasjunior/react-native-get-location/blob/master/LICENSE).
