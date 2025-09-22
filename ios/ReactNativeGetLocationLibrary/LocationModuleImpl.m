// MIT License
//
// Copyright (c) 2019 Douglas Nassif Roma Junior
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LocationModuleImpl.h"
#import <React/RCTLog.h>

@implementation LocationModuleImpl

NSTimer* mTimer;
CLLocationManager* mLocationManager;
RCTPromiseResolveBlock mResolve;
RCTPromiseRejectBlock mReject;
double mTimeout;

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) getCurrentPosition: (NSDictionary*) options
                    promise: (RCTPromiseResolveBlock) resolve
                   rejecter: (RCTPromiseRejectBlock) reject {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [self cancelPreviousRequest];
                       
            bool enableHighAccuracy = [RCTConvert BOOL:options[@"enableHighAccuracy"]];
            double timeout = [RCTConvert double:options[@"timeout"]];
            
            CLLocationManager *locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = enableHighAccuracy ? kCLLocationAccuracyBest : kCLLocationAccuracyNearestTenMeters;
            
            mResolve = resolve;
            mReject = reject;
            mLocationManager = locationManager;
            mTimeout = timeout;
            
            [self startUpdatingLocation];
        }
        @catch (NSException *exception) {
            NSMutableDictionary * info = [NSMutableDictionary dictionary];
            [info setValue:exception.name forKey:@"ExceptionName"];
            [info setValue:exception.reason forKey:@"ExceptionReason"];
            [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
            [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
            [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
            
            NSError *error = [[NSError alloc] initWithDomain:@"Location service is disabled or unavailable" code:1 userInfo:info];
            reject(@"UNAVAILABLE", @"Location service is disabled or unavailable", error);
        }
    });
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0 && mResolve != nil) {
        CLLocation* location = locations[0];
        
        NSDictionary* locationResult = @{
            @"latitude": @(location.coordinate.latitude),
            @"longitude": @(location.coordinate.longitude),
            @"altitude": @(location.altitude),
            @"speed": @(location.speed),
            @"accuracy": @(location.horizontalAccuracy),
            @"time": @(location.timestamp.timeIntervalSince1970 * 1000),
            @"verticalAccuracy": @(location.verticalAccuracy),
            @"course": @(location.course),
        };
        
        mResolve(locationResult);
    }
    [self clearReferences];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (mReject != nil) {
        mReject(@"UNAVAILABLE", @"Location service is disabled or unavailable", error);
    }
    [self clearReferences];
}

- (void) runTimeout:(id)sender {
    if (mReject != nil) {
        mReject(@"TIMEOUT", @"Location timed out", nil);
    }
    [self clearReferences];
}

- (void) clearReferences {
    if (mTimer != nil) {
        [mTimer invalidate];
    }
    if (mLocationManager != nil) {
        [mLocationManager stopUpdatingLocation];
    }
    mResolve = nil;
    mReject = nil;
    mLocationManager = nil;
    mTimer = nil;
    mTimeout = 0;
}

- (void) cancelPreviousRequest {
    if (mLocationManager != nil) {
        mReject(@"CANCELLED", @"Location cancelled by user or by another request", nil);
    }
    [self clearReferences];
}

- (void) startUpdatingLocation {
    if (![self isAuthorized]) {
        NSLog(@"[locationManager requestWhenInUseAuthorization]");
        [mLocationManager requestWhenInUseAuthorization];
        return;
    }
    
    NSLog(@"[locationManager startUpdatingLocation]");
    [mLocationManager startUpdatingLocation];
    
    if (mTimeout > 0) {
        NSTimeInterval timeoutInterval = mTimeout / 1000.0;
        mTimer = [NSTimer scheduledTimerWithTimeInterval:timeoutInterval
                                                  target:self
                                                selector:@selector(runTimeout:)
                                                userInfo:nil
                                                 repeats:NO];
    }
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![CLLocationManager locationServicesEnabled]) {
            mReject(@"UNAVAILABLE", @"Location service is disabled or unavailable", nil);
            [self clearReferences];
            return;
        }
        
        switch ([manager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse: {
                [self startUpdatingLocation];
                break;
            }
            case kCLAuthorizationStatusNotDetermined: {
                // user has not authorized ou denied yet
                break;
            }
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
            default: {
                mReject(@"UNAUTHORIZED", @"Location permission denied by the user", nil);
                [self clearReferences];
                break;
            }
        }
    });
}

- (BOOL) isAuthorized {
    int authorizationStatus = [mLocationManager authorizationStatus];
    
    return authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse
    || authorizationStatus == kCLAuthorizationStatusAuthorizedAlways;
}

@end
