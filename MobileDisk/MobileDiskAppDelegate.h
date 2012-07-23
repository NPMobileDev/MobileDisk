//
//  MobileDiskAppDelegate.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDPasscodeViewController.h"

#define sysGenerateThumbnail @"GenerateThumbnail"
#define sysPasscodeStatus @"PasscodeStatus"
#define sysPasscodeNumber @"PasscodeNumber"
#define sysApplicationEnterForeground @"ApplicationEnterForeground"

@interface MobileDiskAppDelegate : UIResponder <UIApplicationDelegate, MDPasscodeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

+(NSString *)documentDirectory;
+(void)disableIdleTime;
+(void)enableIdleTime;

@end
