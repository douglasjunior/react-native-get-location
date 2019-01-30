package com.github.douglasjunior.reactNativeGetLocation.modules;

import android.content.Context;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Looper;
import android.support.annotation.RequiresPermission;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.github.douglasjunior.reactNativeGetLocation.util.GetLocation;
import com.github.douglasjunior.reactNativeGetLocation.util.SettingsUtil;

import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by dougl on 07/08/2017.
 */
public class ReactNativeGetLocationModule extends ReactContextBaseJavaModule {

    public static final String NAME = "ReactNativeGetLocation";

    private LocationManager locationManager;

    public ReactNativeGetLocationModule(ReactApplicationContext reactContext) {
        super(reactContext);
        try {
            locationManager = (LocationManager) reactContext.getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @Override
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void openWifiSettings(final Promise primise) {
        try {
            SettingsUtil.openWifiSettings(getReactApplicationContext());
            primise.resolve(null);
        } catch (Throwable ex) {
            primise.reject(ex);
        }
    }

    @ReactMethod
    public void openCelularSettings(final Promise primise) {
        try {
            SettingsUtil.openCelularSettings(getReactApplicationContext());
            primise.resolve(null);
        } catch (Throwable ex) {
            primise.reject(ex);
        }
    }

    @ReactMethod
    public void openGpsSettings(final Promise primise) {
        try {
            SettingsUtil.openGpsSettings(getReactApplicationContext());
            primise.resolve(null);
        } catch (Throwable ex) {
            primise.reject(ex);
        }
    }

    @ReactMethod
    public void openAppSettings(final Promise promise) {
        try {
            SettingsUtil.openAppSettings(getReactApplicationContext());
            promise.resolve(null);
        } catch (Throwable ex) {
            promise.reject(ex);
        }
    }

    @ReactMethod
    public void getCurrentPosition(ReadableMap options, Promise promise) {
        new GetLocation(locationManager).get(options, promise);
    }

}
