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

@implementation LocationModuleImpl {
    NSTimer* mTimer;
    CLLocationManager* mLocationManager;
    RCTPromiseResolveBlock mResolve;
    RCTPromiseRejectBlock mReject;
    double mTimeout;
}

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
            
            self->mResolve = resolve;
            self->mReject = reject;
            self->mLocationManager = locationManager;
            self->mTimeout = timeout;
            
            // No start here: from iOS 14 the manager reports its authorization state through
            // locationManagerDidChangeAuthorization: right after it is created, and that
            // callback (handleAuthorizationStatus) is the only path that prompts or starts.
        }
        @catch (NSException *exception) {
            NSMutableDictionary * info = [NSMutableDictionary dictionary];
            [info setValue:exception.name forKey:@"ExceptionName"];
            [info setValue:exception.reason forKey:@"ExceptionReason"];
            [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
            [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
            [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
            
            NSError *error = [[NSError alloc] initWithDomain:@"Location service is disabled or unavailable" code:1 userInfo:info];
            [self clearReferences];
            reject(@"UNAVAILABLE", @"Location service is disabled or unavailable", error);
        }
    });
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0 && mResolve != nil) {
        CLLocation* location = locations.lastObject;
        
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
    if ([error.domain isEqualToString:kCLErrorDomain]) {
        if (error.code == kCLErrorLocationUnknown) {
            // Transient: Core Location has no fix yet but keeps trying. Keep waiting; the
            // timeout, when there is one, bounds the wait (same as Android).
            return;
        }
        if (error.code == kCLErrorDenied) {
            // Permission revoked while the request was pending.
            if (mReject != nil) {
                mReject(@"UNAUTHORIZED", @"Location permission denied by the user", error);
            }
            [self clearReferences];
            return;
        }
    }
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

// Must be called on the main thread, where the manager and the timer live.
- (void) clearReferences {
    if (mTimer != nil) {
        [mTimer invalidate];
    }
    if (mLocationManager != nil) {
        mLocationManager.delegate = nil;
        [mLocationManager stopUpdatingLocation];
    }
    mResolve = nil;
    mReject = nil;
    mLocationManager = nil;
    mTimer = nil;
    mTimeout = 0;
}

- (void) cancelPreviousRequest {
    if (mLocationManager != nil && mReject != nil) {
        mReject(@"CANCELLED", @"Location cancelled by user or by another request", nil);
    }
    [self clearReferences];
}

// Only called from handleAuthorizationStatus with an authorized status, on the main thread.
- (void) startUpdatingLocation {
    NSLog(@"[locationManager startUpdatingLocation]");
    [mLocationManager startUpdatingLocation];
    
    // One timer per request: a further authorized callback for the same manager
    // (e.g. WhenInUse -> Always) must not restart the timeout.
    if (mTimeout > 0 && mTimer == nil) {
        mTimer = [NSTimer scheduledTimerWithTimeInterval:mTimeout / 1000.0
                                                  target:self
                                                selector:@selector(runTimeout:)
                                                userInfo:nil
                                                 repeats:NO];
    }
}

// Delegate callbacks arrive on the main thread (the manager is created there). Only
// +locationServicesEnabled, which can block, is queried off the main thread.
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus status = [manager authorizationStatus];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL servicesEnabled = [CLLocationManager locationServicesEnabled];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleAuthorizationStatus:status servicesEnabled:servicesEnabled forManager:manager];
        });
    });
}

// Runs on the main thread. Single entry point of the request flow: the first callback
// follows the manager's creation and drives prompt, start or failure.
- (void) handleAuthorizationStatus:(CLAuthorizationStatus)status servicesEnabled:(BOOL)servicesEnabled forManager:(CLLocationManager *)manager {
    // The request this callback belonged to may have been finished or replaced while hopping queues.
    if (manager != mLocationManager) {
        return;
    }
    
    if (!servicesEnabled) {
        if (mReject != nil) {
            mReject(@"UNAVAILABLE", @"Location service is disabled or unavailable", nil);
        }
        [self clearReferences];
        return;
    }
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            [self startUpdatingLocation];
            break;
        }
        case kCLAuthorizationStatusNotDetermined: {
            // The prompt result arrives through locationManagerDidChangeAuthorization:.
            NSLog(@"[locationManager requestWhenInUseAuthorization]");
            [mLocationManager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        default: {
            if (mReject != nil) {
                mReject(@"UNAUTHORIZED", @"Location permission denied by the user", nil);
            }
            [self clearReferences];
            break;
        }
    }
}

@end
