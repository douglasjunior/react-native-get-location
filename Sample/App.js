import React, { Component } from 'react';
import {
  Platform, StyleSheet, Text, View,
  Button,
} from 'react-native';

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
});


export default class App extends Component {

  state = {
    location: null,
    loading: false,
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get location, press the button!</Text>
        <Button disabled={loading} title="Get Location" />
        {location ? (
          <Text style={styles.instructions}>
            {JSON.stringify(location, 0, 2)}
          </Text>
        ) : null}
        <Text style={styles.instructions}>{instructions}</Text>
      </View>
    );
  }
}
