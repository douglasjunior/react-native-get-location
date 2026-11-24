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

#ifdef RCT_NEW_ARCH_ENABLED

#import "RNGetLocationTurbo.h"

@implementation RNGetLocationTurbo {
    // Each module instance owns its implementation, so hosts do not share requests and the
    // implementation lives and dies with the module.
    LocationModuleImpl *_impl;
}

+ (NSString *)moduleName { 
    return @"RNGetLocation";
}

// The initializer only allocates; it does not need the main thread. Without this, React Native
// assumes that a module with a custom init must be created on the main thread.
+ (BOOL)requiresMainQueueSetup {
    return NO;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _impl = [[LocationModuleImpl alloc] init];
    }
    return self;
}

// React Native calls this when the host/instance is invalidated (e.g. reload).
- (void)invalidate {
    [_impl invalidate];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params { 
    return std::make_shared<facebook::react::NativeRNGetLocationSpecJSI>(params);
}

- (void)getCurrentPosition:(JS::NativeRNGetLocation::NativeOptions &)options resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    NSDictionary* optionsDict = [self fromNativeOptions:options];
    [_impl getCurrentPosition:optionsDict promise:resolve rejecter:reject];
}

- (NSDictionary *)fromNativeOptions:(JS::NativeRNGetLocation::NativeOptions &)options {
  return @{
    @"timeout": @(options.timeout()),
    @"enableHighAccuracy": @(options.enableHighAccuracy()),
  };
}

@end

#endif // RCT_NEW_ARCH_ENABLED
