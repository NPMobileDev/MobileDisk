//
//  MDChangePasscode.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDChangePasscodeController.h"

@implementation MDChangePasscodeController{
    
    NSString *theOldPasscode;
}

@synthesize theDelegate = _theDelegate;

-(void)dealloc
{
    NSLog(@"change passcode controller deallocate");
}

-(id)initWithOldPasscode:(NSString *)oldPasscode
{
    if(self = [super init])
    {
        theOldPasscode = oldPasscode;
    }
    
    return self;
}

-(void)presentInViewController:(UIViewController *)controller
{
    MDPasscodeViewController *passcodeController = [controller.storyboard instantiateViewControllerWithIdentifier:@"MDPasscodeViewController"];
    
    passcodeController.passcodeToCheck = theOldPasscode;
    passcodeController.theDelegate = self;
    
    [controller presentViewController:passcodeController animated:YES completion:nil];
}

#pragma mark - MDPasscodeViewController delegate
-(void)MDPasscodeViewControllerDidCancel:(MDPasscodeViewController *)controller
{
    [self.theDelegate MDChangePasscodeControllerDidCancel:self];
}

-(void)MDPasscodeViewControllerInputPasscodeIsCorrect:(MDPasscodeViewController *)controller
{
    controller.passcodeToCheck = nil;
    [controller resetPasscode];
}

-(void)MDPasscodeViewControllerInputPasscodeIsIncorrect:(MDPasscodeViewController *)controller
{
    NSString *msg = NSLocalizedString(@"Invalid passcode", @"Invalid passcode");
    UIAlertView *incorrectAlert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
    
    [incorrectAlert show];
    
    //reset passcode
    [controller resetPasscode];
}

-(void)MDPasscodeViewController:(MDPasscodeViewController *)controller didReceiveNewPasscode:(NSString *)newPasscode
{
    [self.theDelegate MDChangePasscodeController:self shouldChangePasscodeTo:newPasscode];
}

@end
