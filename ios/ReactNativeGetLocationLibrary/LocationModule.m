//
//  LocationModule.m
//  GovFacilCidadao
//
//  Created by Douglas Nassif Roma Junior on 25/04/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "LocationModule.h"
#import <React/RCTLog.h>

@implementation LocationModule

RCT_EXPORT_MODULE(ReactNativeGetLocation);

NSTimer* timer;
CLLocationManager* mLocationManager;
RCTPromiseResolveBlock mResolve;
RCTPromiseRejectBlock mReject;

RCT_EXPORT_METHOD(getCurrentPosition: (NSDictionary*) options
                  promise: (RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject) {
  @try {
    NSLog(@"Location.getCurrentPosition: %@", options);
    dispatch_async(dispatch_get_main_queue(), ^{
      if (mLocationManager != nil) {
        [mLocationManager stopUpdatingLocation];
        if (mReject != nil) {
          mReject(@"4", @"Location cancelled by another request", nil);
        }
      }
      
      bool enableHighAccuracy = [RCTConvert BOOL:options[@"enableHighAccuracy"]];
      double timeout = [RCTConvert double:options[@"timeout"]];
      
      CLLocationManager *locationManager = [[CLLocationManager alloc] init];
      locationManager.delegate = self;
      locationManager.distanceFilter = kCLDistanceFilterNone;
      locationManager.desiredAccuracy = enableHighAccuracy ? kCLLocationAccuracyBest : kCLLocationAccuracyNearestTenMeters;
      
      mResolve = resolve;
      mReject = reject;
      mLocationManager = locationManager;
      
      [locationManager requestWhenInUseAuthorization];
      [locationManager startUpdatingLocation];
      
      if (timeout > 0) {
        NSTimeInterval timeoutInterval = timeout / 1000.0;
        timer = [NSTimer scheduledTimerWithTimeInterval:timeoutInterval
                                                 target:self
                                               selector:@selector(runTimeout:)
                                               userInfo:nil
                                                repeats:NO];
      }
    });
  }
  @catch (NSException *exception) {
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setValue:exception.name forKey:@"ExceptionName"];
    [info setValue:exception.reason forKey:@"ExceptionReason"];
    [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
    [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
    [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
    
    NSError *error = [[NSError alloc] initWithDomain:@"Location not available." code:1 userInfo:info];
    reject(@"1", @"Location not available", error);
  }
}

RCT_EXPORT_METHOD(openAppSettings: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  //dispatch_async(dispatch_get_main_queue(), ^{
  @try {
    [SettingsUtil openAppSettings];
    resolve(nil);
  }
  @catch (NSException *exception) {
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setValue:exception.name forKey:@"ExceptionName"];
    [info setValue:exception.reason forKey:@"ExceptionReason"];
    [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
    [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
    [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
    
    NSError *error = [[NSError alloc] initWithDomain:@"openAppSettings" code:0 userInfo:info];
    reject(@"openAppSettings", @"Could not open settings.", error);
  }
  //});
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
  [manager stopUpdatingLocation];
  NSLog(@"Location.didUpdateLocations: %@", locations);
  if (locations.count > 0) {
    if (mResolve != nil) {
      if (timer != nil) {
        [timer invalidate];
      }
      
      CLLocation* location = locations[0];
      
      NSDictionary* locationResult = @{
                                       @"latitude": @(location.coordinate.latitude),
                                       @"longitude": @(location.coordinate.longitude),
                                       @"altitude": @(location.altitude),
                                       @"speed": @(location.speed),
                                       @"accuracy": @(location.verticalAccuracy),
                                       };
      
      mResolve(locationResult);
    }
    [self clearReferences];
  }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  [manager stopUpdatingLocation];
  NSLog(@"Location.didFailWithError: %@", error);
  if (timer != nil) {
    [timer invalidate];
  }
  if (mReject != nil) {
    mReject(@"1", @"Location not available", error);
  }
  [self clearReferences];
}

- (void) runTimeout:(id)sender {
  if (timer != nil) {
    [timer invalidate];
  }
  if (mLocationManager != nil) {
    [mLocationManager stopUpdatingLocation];
  }
  if (mReject != nil) {
    mReject(@"3", @"Location timed out", nil);
  }
  [self clearReferences];
}

- (void) clearReferences {
  mResolve = nil;
  mReject = nil;
  mLocationManager = nil;
  timer = nil;
}

@end
