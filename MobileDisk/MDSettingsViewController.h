//
//  MDSettingsViewController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDPasscodeViewController.h"
#import "MDChangePasscodeController.h"
#import "ColorPickerController.h"

@class HTTPServer;

@interface MDSettingsViewController : UITableViewController<MDPasscodeViewControllerDelegate, MDChangePasscodeControllerDelegate, ColorPickerDelegate>

@property (nonatomic, strong) HTTPServer *httpServer;

@end
