/**
 * MIT License
 * <p>
 * Copyright (c) 2019 Douglas Nassif Roma Junior
 * <p>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package com.github.douglasjunior.reactNativeGetLocation;

import android.app.Activity;
import android.content.Context;
import android.location.LocationManager;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.github.douglasjunior.reactNativeGetLocation.util.GetLocation;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.Task;

public class ReactNativeGetLocationImpl {
    public static final String REACT_MODULE_NAME = "RNGetLocation";
    static final int REQUEST_CODE_LOCATION_SETTINGS = 9001;

    private final ReactApplicationContext reactContext;
    private LocationManager locationManager;
    private GetLocation getLocation;
    private Promise pendingLocationPromptPromise;
    private ReadableMap pendingLocationPromptOptions;

    public ReactNativeGetLocationImpl(ReactApplicationContext reactContext) {
        this.reactContext = reactContext;
        try {
            locationManager = (LocationManager) reactContext.getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
        } catch (Exception ex) {
            if (BuildConfig.DEBUG) {
                ex.printStackTrace();
            }
        }
    }

    public void getCurrentPosition(ReadableMap options, Promise promise) {
        boolean enableLocationPrompt = options.hasKey("enableLocationPrompt") && options.getBoolean("enableLocationPrompt");

        if (!enableLocationPrompt) {
            doGetCurrentPosition(options, promise);
            return;
        }

        Activity activity = reactContext.getCurrentActivity();
        if (activity == null) {
            doGetCurrentPosition(options, promise);
            return;
        }

        reactContext.runOnUiQueueThread(() -> {
            Activity currentActivity = reactContext.getCurrentActivity();
            if (currentActivity == null) {
                doGetCurrentPosition(options, promise);
                return;
            }

            boolean enableHighAccuracy = options.hasKey("enableHighAccuracy") && options.getBoolean("enableHighAccuracy");
            int priority = enableHighAccuracy
                    ? LocationRequest.PRIORITY_HIGH_ACCURACY
                    : LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY;

            LocationRequest locationRequest = new LocationRequest.Builder(10000)
                    .setPriority(priority)
                    .setMinUpdateIntervalMillis(5000)
                    .build();

            LocationSettingsRequest request = new LocationSettingsRequest.Builder()
                    .addLocationRequest(locationRequest)
                    .setAlwaysShow(true)
                    .build();

            SettingsClient settingsClient = LocationServices.getSettingsClient(reactContext);
            Task<LocationSettingsResponse> task = settingsClient.checkLocationSettings(request);

            task.addOnSuccessListener(locationSettingsResponse -> doGetCurrentPosition(options, promise));

            task.addOnFailureListener(e -> {
                if (e instanceof ResolvableApiException) {
                    pendingLocationPromptPromise = promise;
                    pendingLocationPromptOptions = copyReadableMap(options);
                    try {
                        ((ResolvableApiException) e).startResolutionForResult(currentActivity, REQUEST_CODE_LOCATION_SETTINGS);
                    } catch (Exception ex) {
                        if (pendingLocationPromptPromise != null) {
                            pendingLocationPromptPromise.reject("UNAVAILABLE", "Location service is disabled or unavailable", ex);
                            pendingLocationPromptPromise = null;
                            pendingLocationPromptOptions = null;
                        }
                    }
                } else {
                    doGetCurrentPosition(options, promise);
                }
            });
        });
    }

    public void onActivityResult(int requestCode, int resultCode) {
        if (requestCode != REQUEST_CODE_LOCATION_SETTINGS || pendingLocationPromptPromise == null) {
            return;
        }

        Promise promise = pendingLocationPromptPromise;
        ReadableMap opts = pendingLocationPromptOptions;
        pendingLocationPromptPromise = null;
        pendingLocationPromptOptions = null;

        if (resultCode == Activity.RESULT_OK) {
            doGetCurrentPosition(opts, promise);
        } else {
            promise.reject("CANCELLED", "Location cancelled by user or by another request");
        }
    }

    public void clearPendingLocationPrompt() {
        if (pendingLocationPromptPromise != null) {
            pendingLocationPromptPromise.reject("CANCELLED", "Location cancelled by user or by another request");
            pendingLocationPromptPromise = null;
            pendingLocationPromptOptions = null;
        }
    }

    private void doGetCurrentPosition(ReadableMap options, Promise promise) {
        if (getLocation != null) {
            getLocation.cancel();
        }
        getLocation = new GetLocation(locationManager);
        getLocation.get(options, promise);
    }

    private static ReadableMap copyReadableMap(ReadableMap source) {
        WritableNativeMap copy = new WritableNativeMap();
        if (source.hasKey("enableHighAccuracy")) {
            copy.putBoolean("enableHighAccuracy", source.getBoolean("enableHighAccuracy"));
        }
        if (source.hasKey("timeout")) {
            copy.putDouble("timeout", source.getDouble("timeout"));
        }
        if (source.hasKey("enableLocationPrompt")) {
            copy.putBoolean("enableLocationPrompt", source.getBoolean("enableLocationPrompt"));
        }
        return copy;
    }
}
