//
//  LocationModule.h
//  GovFacilCidadao
//
//  Created by Douglas Nassif Roma Junior on 25/04/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>
#import <CoreLocation/CoreLocation.h>
#import "SettingsUtilModule.h"

@interface LocationModule : NSObject <RCTBridgeModule, CLLocationManagerDelegate>

@end
