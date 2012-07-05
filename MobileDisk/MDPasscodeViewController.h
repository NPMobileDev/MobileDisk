//
//  MDPasscodeViewController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDPasscodeViewController;

@protocol MDPasscodeViewControllerDelegate <NSObject>

-(void)MDPasscodeViewControllerDidCancel:(MDPasscodeViewController *)controller;

//call when passcodeToCheck is setted
-(void)MDPasscodeViewControllerInputPasscodeIsCorrect:(MDPasscodeViewController *)controller;
-(void)MDPasscodeViewControllerInputPasscodeIsIncorrect:(MDPasscodeViewController *)controller;

//call when passcodeToCheck is not setted
-(void)MDPasscodeViewController:(MDPasscodeViewController *)controller didReceiveNewPasscode:(NSString *)newPasscode;

@end

@interface MDPasscodeViewController : UIViewController<UITextFieldDelegate>

//false if do not want to show cancel button at right side of navigation bar
@property (nonatomic, assign) BOOL canShowCancelButton;

@property (nonatomic, weak) id<MDPasscodeViewControllerDelegate> theDelegate;

//give nil if require user to enter new passcode
@property (nonatomic, copy) NSString *passcodeToCheck;

-(void)resetPasscode;

@end
