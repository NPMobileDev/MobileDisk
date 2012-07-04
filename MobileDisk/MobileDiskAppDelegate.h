//
//  MobileDiskAppDelegate.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define sysGenerateThumbnail @"GenerateThumbnail"

@interface MobileDiskAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(NSString *)documentDirectory;

@end
