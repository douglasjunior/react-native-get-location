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
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
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

import android.content.Context;
import android.location.LocationManager;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.github.douglasjunior.reactNativeGetLocation.util.GetLocation;

public class ReactNativeGetLocationImpl {
    public static final String REACT_MODULE_NAME = "RNGetLocation";
    private LocationManager locationManager;
    private GetLocation getLocation;

    public ReactNativeGetLocationImpl(ReactApplicationContext reactContext) {
        try {
            locationManager = (LocationManager) reactContext.getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
        } catch (Exception ex) {
            if (BuildConfig.DEBUG) {
                // noinspection CallToPrintStackTrace
                ex.printStackTrace();
            }
        }
    }

    public void getCurrentPosition(ReadableMap options, Promise promise) {
        if (getLocation != null) {
            getLocation.cancel();
        }
        getLocation = new GetLocation(locationManager);
        getLocation.get(options, promise);
    }
}
