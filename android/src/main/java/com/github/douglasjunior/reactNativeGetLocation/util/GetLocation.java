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

package com.github.douglasjunior.reactNativeGetLocation.util;

import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Looper;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeMap;

import java.util.Timer;
import java.util.TimerTask;

public class GetLocation {

    private final LocationManager locationManager;

    private Timer timer;
    private LocationListener listener;

    public GetLocation(LocationManager locationManager) {
        this.locationManager = locationManager;
    }

    public void get(ReadableMap options, final Promise promise) {
        try {
            Log.d("Location", String.format("getCurrentPosition: %b", options));

            if (!isLocationEnabled()) {
                promise.reject("1", "Location not available");
                return;
            }

            boolean enableHighAccuracy = options.hasKey("enableHighAccuracy") && options.getBoolean("enableHighAccuracy");
            long timeout = options.hasKey("timeout") ? (long) options.getDouble("timeout") : 0;

            Criteria criteria = new Criteria();
            criteria.setAccuracy(enableHighAccuracy ? Criteria.ACCURACY_FINE : Criteria.ACCURACY_COARSE);

            Log.d("Location", String.format("getBestProvider: %b", locationManager.getBestProvider(criteria, true)));

            listener = new LocationListener() {
                private boolean locationFound = false;

                @Override
                public synchronized void onLocationChanged(Location location) {
                    Log.d("Location", String.format("onLocationChanged: %b", location));
                    if (location != null && !locationFound) {
                        locationFound = true;
                        cancelTimer();
                        locationManager.removeUpdates(this);
                        WritableNativeMap resultLocation = new WritableNativeMap();
                        resultLocation.putString("provider", location.getProvider());
                        resultLocation.putDouble("latitude", location.getLatitude());
                        resultLocation.putDouble("longitude", location.getLongitude());
                        resultLocation.putDouble("accuracy", location.getAccuracy());
                        resultLocation.putDouble("altitude", location.getAltitude());
                        resultLocation.putDouble("speed", location.getSpeed());
                        resultLocation.putDouble("bearing", location.getBearing());
                        resultLocation.putDouble("time", location.getTime());
                        promise.resolve(resultLocation);
                    }
                }

                @Override
                public void onStatusChanged(String provider, int status, Bundle extras) {
                    Log.d("Location", String.format("onStatusChanged: %b - %b", provider, status));
                }

                @Override
                public void onProviderEnabled(String provider) {
                    Log.d("Location", String.format("onProviderEnabled: %b", provider));
                }

                @Override
                public void onProviderDisabled(String provider) {
                    Log.d("Location", String.format("onProviderDisabled: %b", provider));
                }
            };

            locationManager.requestLocationUpdates(0L, 0F, criteria, listener, Looper.myLooper());

            if (timeout > 0) {
                timer = new Timer();
                timer.schedule(new TimerTask() {
                    @Override
                    public void run() {
                        try {
                            promise.reject("3", "Location timed out");
                            locationManager.removeUpdates(listener);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }
                }, timeout);
            }
        } catch (SecurityException ex) {
            ex.printStackTrace();
            cancelTimer();
            promise.reject("5", "Location permission denied", ex);
        } catch (Exception ex) {
            ex.printStackTrace();
            cancelTimer();
            promise.reject("1", "Location not available", ex);
        }
    }

    private void cancelTimer() {
        if (timer != null) {
            timer.cancel();
        }
    }

    private boolean isLocationEnabled() {
        try {
            return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                    locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }
}
