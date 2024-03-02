//
//  MDAVPlayerController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSrtSubtitle.h" /**add 9/4/2012**/
#import "MDSrtSubtitleInfo.h"/**add 9/4/2012**/

#define kRewindAmount 10.0f
#define kFastForwardAmount 10.0f
#define kFadeOutUIDuration 1.0f
#define kFadeInUIDuration 0.2f
#define kVideoScale 1.5f;

@interface MDAVPlayerController : UIViewController<MDSrtSubtitleDelegate>

@property (nonatomic, copy) NSURL *avFileURL;

@end
