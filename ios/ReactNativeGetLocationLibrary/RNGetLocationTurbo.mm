//
//  RNGetLocationSpec.m
//  ReactNativeGetLocation
//
//  Created by Douglas Junior on 22/09/25.
//

#ifdef RCT_NEW_ARCH_ENABLED

#import "RNGetLocationTurbo.h"

@implementation RNGetLocationTurbo

LocationModuleImpl* locationModuleImpl;

+ (NSString *)moduleName { 
    return @"RNGetLocation";
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params { 
    return std::make_shared<facebook::react::NativeRNGetLocationSpecJSI>(params);
}

- (void)getCurrentPosition:(JS::NativeRNGetLocation::NativeOptions &)options resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    if (locationModuleImpl == nil) {
        locationModuleImpl = [[LocationModuleImpl alloc] init];
    }
    NSDictionary* optionsDict = [self fromNativeOptions:options];
    [locationModuleImpl getCurrentPosition:optionsDict promise:resolve rejecter:reject];
}

- (NSDictionary *)fromNativeOptions:(JS::NativeRNGetLocation::NativeOptions &)options {
  return @{
    @"timeout": @(options.timeout()),
    @"enableHighAccuracy": @(options.enableHighAccuracy()),
  };
}

@end

#endif // RCT_NEW_ARCH_ENABLED
