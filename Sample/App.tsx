import React, {useState} from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  Button,
  ActivityIndicator,
  Linking,
} from 'react-native';

import GetLocation, {
  Location,
  LocationError,
  LocationErrorCode,
} from 'react-native-get-location';

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  location: {
    color: '#333333',
    marginBottom: 5,
  },
  button: {
    marginBottom: 8,
  },
});

function App(): JSX.Element {
  const [loading, setLoading] = useState(false);
  const [location, setLocation] = useState<Location | null>(null);
  const [error, setError] = useState<LocationErrorCode | null>(null);

  const requestLocation = () => {
    setLoading(true);
    setLocation(null);
    setError(null);

    GetLocation.getCurrentPosition({
      enableHighAccuracy: true,
      timeout: 30000,
      rationale: {
        title: 'Location permission',
        message: 'The app needs the permission to request your location.',
        buttonPositive: 'Ok',
      },
    })
      .then(newLocation => {
        setLoading(false);
        setLocation(newLocation);
      })
      .catch(ex => {
        if (ex instanceof LocationError) {
          const {code, message} = ex;
          console.warn(code, message);
          setError(code);
        } else {
          console.warn(ex);
        }
        setLoading(false);
        setLocation(null);
      });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.welcome}>Welcome to React Native!</Text>
      <Text style={styles.instructions}>
        To get location, press the button:
      </Text>
      <View style={styles.button}>
        <Button
          disabled={loading}
          title="Get Location"
          onPress={requestLocation}
        />
      </View>
      {loading ? <ActivityIndicator /> : null}
      {location ? (
        <Text style={styles.location}>{JSON.stringify(location, null, 2)}</Text>
      ) : null}
      {error ? <Text style={styles.location}>Error: {error}</Text> : null}
      <Text style={styles.instructions}>Extra functions:</Text>
      <View style={styles.button}>
        <Button
          title="Open App Settings"
          onPress={() => {
            GetLocation.openAppSettings();
          }}
        />
      </View>
      <View style={styles.button}>
        <Button
          title="Open Gps Settings"
          onPress={() => {
            GetLocation.openGpsSettings();
          }}
        />
      </View>
      <View style={styles.button}>
        <Button
          title="Open Wifi Settings"
          onPress={() => {
            GetLocation.openWifiSettings();
          }}
        />
      </View>
      <View style={styles.button}>
        <Button
          title="Open Mobile Data Settings"
          onPress={() => {
            GetLocation.openCelularSettings();
          }}
        />
      </View>
      <View style={styles.button}>
        <Button
          title="Open Linking Settings"
          onPress={() => {
            Linking.openSettings();
          }}
        />
      </View>
      <Text style={styles.instructions}>{instructions}</Text>
    </View>
  );
}

export default App;
