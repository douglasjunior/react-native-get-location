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

#pragma mark - RNGLLocationRequest

// One instance per getCurrentPosition call. It owns everything the request needs (manager,
// timer, promise blocks) and is the delegate of its own manager and the owner of its own timer,
// so a callback can only ever reach the request it belongs to.
//
// Every end of the request (fix, failure, timeout, cancel) goes through -finish, which releases
// all state. A callback that arrives afterwards finds no state and does nothing.
//
// All methods run on the main thread, except +locationServicesEnabled, which is queried on a
// global queue and hops back to main.
@interface RNGLLocationRequest : NSObject <CLLocationManagerDelegate>

// completion is called once, as the last step of finishing, so the owner can drop the request.
- (instancetype)initWithHighAccuracy:(BOOL)highAccuracy
                             timeout:(double)timeout
                             resolve:(RCTPromiseResolveBlock)resolve
                              reject:(RCTPromiseRejectBlock)reject
                          completion:(void (^)(RNGLLocationRequest *request))completion;

// Creates the manager. Does not start updates: the authorization callback the manager fires
// right after creation (iOS 14+) is the only path that prompts or starts.
- (void)start;
- (void)cancel;
- (void)rejectWithCode:(NSString *)code message:(NSString *)message error:(NSError *)error;

@end

@implementation RNGLLocationRequest {
    BOOL _highAccuracy;
    double _timeout;
    CLLocationManager *_manager;
    NSTimer *_timer;
    RCTPromiseResolveBlock _resolve;
    RCTPromiseRejectBlock _reject;
    void (^_completion)(RNGLLocationRequest *);
}

- (instancetype)initWithHighAccuracy:(BOOL)highAccuracy
                             timeout:(double)timeout
                             resolve:(RCTPromiseResolveBlock)resolve
                              reject:(RCTPromiseRejectBlock)reject
                          completion:(void (^)(RNGLLocationRequest *request))completion {
    self = [super init];
    if (self) {
        _highAccuracy = highAccuracy;
        _timeout = timeout;
        _resolve = resolve;
        _reject = reject;
        _completion = completion;
    }
    return self;
}

- (void)start {
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    manager.delegate = self; // weak in the manager: the owner keeps this request alive
    manager.distanceFilter = kCLDistanceFilterNone;
    manager.desiredAccuracy = _highAccuracy ? kCLLocationAccuracyBest : kCLLocationAccuracyNearestTenMeters;
    _manager = manager;
}

- (void)cancel {
    [self rejectWithCode:@"CANCELLED" message:@"Location cancelled by user or by another request" error:nil];
}

#pragma mark Termination

// The only place where state is released. Idempotent. The timer is always invalidated here, which
// also drops its reference to this request. The completion runs last and nothing touches self after
// it, because it may release the last strong reference to this request.
- (void)finish {
    [_timer invalidate];
    _timer = nil;
    _manager.delegate = nil;
    [_manager stopUpdatingLocation];
    _manager = nil;
    _resolve = nil;
    _reject = nil;
    void (^completion)(RNGLLocationRequest *) = _completion;
    _completion = nil;
    if (completion != nil) {
        completion(self);
    }
}

- (void)resolveWithLocation:(CLLocation *)location {
    RCTPromiseResolveBlock resolve = _resolve;
    if (resolve == nil) {
        return; // already finished
    }
    NSDictionary *result = @{
        @"latitude": @(location.coordinate.latitude),
        @"longitude": @(location.coordinate.longitude),
        @"altitude": @(location.altitude),
        @"speed": @(location.speed),
        @"accuracy": @(location.horizontalAccuracy),
        @"time": @(location.timestamp.timeIntervalSince1970 * 1000),
        @"verticalAccuracy": @(location.verticalAccuracy),
        @"course": @(location.course),
    };
    [self finish];
    resolve(result);
}

- (void)rejectWithCode:(NSString *)code message:(NSString *)message error:(NSError *)error {
    RCTPromiseRejectBlock reject = _reject;
    if (reject == nil) {
        return; // already finished
    }
    [self finish];
    reject(code, message, error);
}

#pragma mark Authorization flow

// Delegate callbacks arrive on the main thread (the manager is created there). Only
// +locationServicesEnabled, which can block, is queried off the main thread.
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if (_manager == nil) {
        return; // finished
    }
    CLAuthorizationStatus status = [manager authorizationStatus];
    
    // The block holds this request strongly, on purpose: it must act on the request that got the
    // callback, and nothing retains the block, so there is no cycle. If the request finished
    // meanwhile, -handleAuthorizationStatus:servicesEnabled: finds no state and returns.
    RNGLLocationRequest *request = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL servicesEnabled = [CLLocationManager locationServicesEnabled];
        dispatch_async(dispatch_get_main_queue(), ^{
            [request handleAuthorizationStatus:status servicesEnabled:servicesEnabled];
        });
    });
}

// Main thread. Single entry point of the request flow: the first callback follows the manager's
// creation and drives prompt, start or failure.
- (void)handleAuthorizationStatus:(CLAuthorizationStatus)status servicesEnabled:(BOOL)servicesEnabled {
    if (_manager == nil) {
        return; // finished
    }
    
    if (!servicesEnabled) {
        [self rejectWithCode:@"UNAVAILABLE" message:@"Location service is disabled or unavailable" error:nil];
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
            [_manager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        default: {
            [self rejectWithCode:@"UNAUTHORIZED" message:@"Location permission denied by the user" error:nil];
            break;
        }
    }
}

// Only called from -handleAuthorizationStatus:servicesEnabled: with an authorized status.
- (void)startUpdatingLocation {
    NSLog(@"[locationManager startUpdatingLocation]");
    [_manager startUpdatingLocation];
    
    // One timer per request: a further authorized callback for the same manager
    // (e.g. WhenInUse -> Always) must not restart the timeout.
    if (_timeout > 0 && _timer == nil) {
        // The block captures only a weak reference, so the timer does not retain the request.
        // -finish also invalidates the timer on every path, so it never outlives the request.
        __weak RNGLLocationRequest *weakSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeout / 1000.0
                                                 repeats:NO
                                                   block:^(NSTimer *timer) {
            [weakSelf rejectWithCode:@"TIMEOUT" message:@"Location timed out" error:nil];
        }];
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject; // most recent; Core Location orders oldest to newest
    if (location == nil) {
        return; // keep waiting; the timeout, when there is one, bounds the wait
    }
    [self resolveWithLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error.domain isEqualToString:kCLErrorDomain]) {
        if (error.code == kCLErrorLocationUnknown) {
            // Transient: Core Location has no fix yet but keeps trying. Keep waiting; the
            // timeout, when there is one, bounds the wait (same as Android).
            return;
        }
        if (error.code == kCLErrorDenied) {
            // Permission revoked while the request was pending.
            [self rejectWithCode:@"UNAUTHORIZED" message:@"Location permission denied by the user" error:error];
            return;
        }
    }
    [self rejectWithCode:@"UNAVAILABLE" message:@"Location service is disabled or unavailable" error:error];
}

@end

#pragma mark - LocationModuleImpl

@implementation LocationModuleImpl {
    // Keeps the current request alive (the manager holds its delegate weakly). Main thread only.
    RNGLLocationRequest *_currentRequest;
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
        RNGLLocationRequest *request = nil;
        @try {
            // Strong local: cancelling runs the completion, which drops the module's reference.
            RNGLLocationRequest *previous = self->_currentRequest;
            [previous cancel];
            
            bool enableHighAccuracy = [RCTConvert BOOL:options[@"enableHighAccuracy"]];
            double timeout = [RCTConvert double:options[@"timeout"]];
            
            __weak LocationModuleImpl *weakSelf = self;
            request = [[RNGLLocationRequest alloc] initWithHighAccuracy:enableHighAccuracy
                                                                timeout:timeout
                                                                resolve:resolve
                                                                 reject:reject
                                                             completion:^(RNGLLocationRequest *finished) {
                // Release only if it is still the current one: an old request finishing must
                // not drop a newer one.
                LocationModuleImpl *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf->_currentRequest == finished) {
                    strongSelf->_currentRequest = nil;
                }
            }];
            self->_currentRequest = request;
            [request start];
        }
        @catch (NSException *exception) {
            NSMutableDictionary * info = [NSMutableDictionary dictionary];
            [info setValue:exception.name forKey:@"ExceptionName"];
            [info setValue:exception.reason forKey:@"ExceptionReason"];
            [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
            [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
            [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
            
            NSError *error = [[NSError alloc] initWithDomain:@"Location service is disabled or unavailable" code:1 userInfo:info];
            if (request != nil) {
                // Releases its state and the module's reference; no-op if already settled.
                [request rejectWithCode:@"UNAVAILABLE" message:@"Location service is disabled or unavailable" error:error];
            } else {
                reject(@"UNAVAILABLE", @"Location service is disabled or unavailable", error);
            }
        }
    });
}

@end
