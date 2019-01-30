//
//  SettingsUtil.m
//  Lupa
//
//  Created by Douglas Nassif Roma Junior on 08/08/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "SettingsUtil.h"

@implementation SettingsUtil

+ (void) openAppSettings {
  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
  } else {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
  }
}

@end
