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

import static com.github.douglasjunior.reactNativeGetLocation.ReactNativeGetLocationImpl.REACT_MODULE_NAME;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.BaseReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.model.ReactModuleInfo;
import com.facebook.react.module.model.ReactModuleInfoProvider;
import com.github.douglasjunior.reactNativeGetLocation.modules.ReactNativeGetLocationModule;

import java.util.HashMap;

public class ReactNativeGetLocationPackage extends BaseReactPackage {

    @Nullable
    @Override
    public NativeModule getModule(@NonNull String name, @NonNull ReactApplicationContext reactContext) {
        if (name.equals(REACT_MODULE_NAME)) {
            return new ReactNativeGetLocationModule(reactContext);
        } else {
            return null;
        }
    }

    @NonNull
    @Override
    public ReactModuleInfoProvider getReactModuleInfoProvider() {
        return () -> {
            var map = new HashMap<String, ReactModuleInfo>();
            map.put(REACT_MODULE_NAME, new ReactModuleInfo(
                    REACT_MODULE_NAME,                              // name
                    ReactNativeGetLocationModule.class.getName(),   // className
                    false,                                          // canOverrideExistingModule
                    false,                                          // needsEagerInit
                    false,                                          // isCXXModule
                    true                                            // isTurboModule
            ));
            return map;
        };
    }
}
