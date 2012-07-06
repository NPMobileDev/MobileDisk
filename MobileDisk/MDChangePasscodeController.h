//
//  MDChangePasscode.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDPasscodeViewController.h"

@class MDChangePasscodeController;

@protocol MDChangePasscodeControllerDelegate <NSObject>

-(void)MDChangePasscodeControllerDidCancel:(MDChangePasscodeController *)controller;
-(void)MDChangePasscodeController:(MDChangePasscodeController *)controller shouldChangePasscodeTo:(NSString *)newPasscode;

@end

@interface MDChangePasscodeController : NSObject<MDPasscodeViewControllerDelegate>

@property (nonatomic, weak) id<MDChangePasscodeControllerDelegate> theDelegate;

-(id)initWithOldPasscode:(NSString *)oldPasscode;
-(void)presentInViewController:(UIViewController *)controller;

@end
