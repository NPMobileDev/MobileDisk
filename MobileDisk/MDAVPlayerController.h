//
//  MDAVPlayerController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRewindAmount 10.0f
#define kFastForwardAmount 10.0f
#define kFadeOutUIDuration 1.0f
#define kFadeInUIDuration 0.2f
#define kVideoScale 1.5f;

@interface MDAVPlayerController : UIViewController

@property (nonatomic, copy) NSURL *avFileURL;

@end
