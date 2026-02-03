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

package com.github.douglasjunior.reactNativeGetLocation.modules;

import static com.github.douglasjunior.reactNativeGetLocation.ReactNativeGetLocationImpl.REACT_MODULE_NAME;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.github.douglasjunior.reactNativeGetLocation.ReactNativeGetLocationImpl;

public class ReactNativeGetLocationModule extends ReactContextBaseJavaModule
        implements com.facebook.react.bridge.ActivityEventListener {

    private final ReactNativeGetLocationImpl impl;

    public ReactNativeGetLocationModule(ReactApplicationContext reactContext) {
        super(reactContext);
        impl = new ReactNativeGetLocationImpl(reactContext);
        reactContext.addActivityEventListener(this);
    }

    @NonNull
    @Override
    public String getName() {
        return REACT_MODULE_NAME;
    }

    @Override
    public void invalidate() {
        getReactApplicationContext().removeActivityEventListener(this);
        impl.clearPendingLocationPrompt();
        super.invalidate();
    }

    @ReactMethod
    public void getCurrentPosition(ReadableMap options, Promise promise) {
        impl.getCurrentPosition(options, promise);
    }

    @Override
    public void onNewIntent(Intent intent) {}

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        impl.onActivityResult(requestCode, resultCode);
    }
}
