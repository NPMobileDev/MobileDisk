//
//  MDForegroundViewController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*****
 this controller is used when app enter foreground
 check MobileDiskAppDelegate
 Undertake job to check if need to present passcode and post notification
 *****/

#import <UIKit/UIKit.h>
#import "MDPasscodeViewController.h"

@interface MDForegroundViewController : UIViewController<MDPasscodeViewControllerDelegate>

@end
