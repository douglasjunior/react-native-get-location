#!/bin/bash

rm -rf ../node_modules/
rm -rf node_modules/
rm -rf ios/Pods/
yarn install
rm -rf node_modules/react-native-get-location/Sample/ 
rm -rf node_modules/react-native-get-location/.git/

npx -y pod-install
