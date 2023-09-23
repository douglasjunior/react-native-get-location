# React-Native Get Location

[![License MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/douglasjunior/react-native-get-location/blob/master/LICENSE)
[![npm version](https://img.shields.io/npm/v/react-native-get-location.svg)](https://www.npmjs.com/package/react-native-get-location)
[![npm downloads](https://img.shields.io/npm/dt/react-native-get-location.svg)](https://www.npmjs.com/package/react-native-get-location?activeTab=versions)

⚛ Simple to use React Native library to get native device location for Android and iOS.

## Requirements

- React Native >= 0.60.0
- iOS >= 9.0

## Install

Install dependency package
```bash
yarn add react-native-get-location
```
Or
```bash
npm i -S react-native-get-location
```

Go to the folder **your-project/ios** and run `pod install`, and you're done. 

## Android post install

For Android you need to define the location permissions on `AndroidManifest.xml`.

```xml
<!-- Define ACCESS_FINE_LOCATION if you will use enableHighAccuracy=true  -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>

<!-- Define ACCESS_COARSE_LOCATION if you will use enableHighAccuracy=false  -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## iOS post install

You need to define the permission [NSLocationWhenInUseUsageDescription](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW26) on `Info.plist`.

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs to get your location...</string>
```

## Usage

There is only one function that you need to use to get the user's current location.

```js
import GetLocation from 'react-native-get-location'

GetLocation.getCurrentPosition({
    enableHighAccuracy: true,
    timeout: 60000,
})
.then(location => {
    console.log(location);
})
.catch(error => {
    const { code, message } = error;
    console.warn(code, message);
})
```

For more details, see the [Sample Project](https://github.com/douglasjunior/react-native-get-location/blob/master/Sample/App.tsx).

## API

### function `GetLocation.getCurrentPosition(LocationConfig)`

**Parameters:**
   - [`LocationConfig`](#object-locationconfig): Configuration object to determine how to get the user current location.

**Return:**
   - `Promise<`[`Location`](#object-location)`>`: Promise thats resolve to a Location object.

### Object `LocationConfig`

**Properties:**
   - `enableHighAccuracy`: Set `true` to use 'fine location' (GPS) our `false` to use 'course location' (Wifi, Bluetooth, 3G). Default: `false`
   - `timeout`: The max time (in milliseconds) that you want to wait to receive a location. Default: `60000` (60 seconds)
   - `rationale?`: (Android only) See the [React Native docs](https://reactnative.dev/docs/permissionsandroid#request).

### Object `Location`

**Properties:**
   - `latitude`: The latitude, in degrees.
   - `longitude`: The longitude, in degrees.
   - `altitude`: The altitude if available, in meters above the WGS 84 reference ellipsoid.
   - `accuracy`: The estimated horizontal accuracy of this location, radial, in meters.
   - `speed`: The speed if it is available, in meters/second over ground.
   - `time`: The UTC time of this fix, in milliseconds since January 1, 1970.
   - `bearing`: *(Android only)* The bearing, in degrees.
   - `provider`: *(Android only)* The name of the provider that generated this fix.
   - `verticalAccuracy`: *(iOS only)* The vertical accuracy of the location. Negative if the altitude is invalid.
   - `course`: *(iOS only)* The course of the location in degrees true North. Negative if course is invalid. (0.0 - 359.9 degrees, 0 being true North)

### Error codes

|Code|Message|
|-|-|
|`CANCELLED`|Location cancelled by user or by another request|
|`UNAVAILABLE`|Location service is disabled or unavailable|
|`TIMEOUT`|Location request timed out|
|`UNAUTHORIZED`|Authorization denied|

## Contribute

New features, bug fixes and improvements are welcome! For questions and suggestions use the [issues](https://github.com/douglasjunior/react-native-get-location/issues).

<a href="https://www.patreon.com/douglasjunior"><img src="http://i.imgur.com/xEO164Z.png" alt="Become a Patron!" width="200" /></a>
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/douglasnassif)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=douglasjunior/react-native-get-location&type=Date)](https://star-history.com/#douglasjunior/react-native-get-location)

## License

```
The MIT License (MIT)

Copyright (c) 2019 Douglas Nassif Roma Junior
```

See the full [license file](https://github.com/douglasjunior/react-native-get-location/blob/master/LICENSE).
