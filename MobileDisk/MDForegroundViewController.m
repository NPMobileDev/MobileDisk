//
//  MDForegroundViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDForegroundViewController.h"
#import "MobileDiskAppDelegate.h"


@interface MDForegroundViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

-(void)presentPasscodeCheck;
-(void)shouldPresentPasscodeCheck;

@end

@implementation MDForegroundViewController

@synthesize logoImageView = _logoImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.logoImageView.image = [UIImage imageNamed:@"Default"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)appEnterForeground:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self shouldPresentPasscodeCheck];
}

-(void)appEnterBackground:(NSNotification*)notification
{
    UIViewController *parentViewController = self.presentingViewController;
    
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
    
        MDForegroundViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MDForegroundViewController"];
        
        [parentViewController presentModalViewController:controller animated:NO];
    }];
}

-(void)presentPasscodeCheck
{
    NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:sysPasscodeNumber];
    
    MDPasscodeViewController *passcodeController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDPasscodeViewController"];
    
    passcodeController.canShowCancelButton = NO;
    passcodeController.passcodeToCheck = passcode;
    passcodeController.theDelegate = self;
    
    [self presentViewController:passcodeController animated:YES completion:^{
        
    }];
}

-(void)shouldPresentPasscodeCheck
{
    BOOL passcodeStatus = [[NSUserDefaults standardUserDefaults] boolForKey:sysPasscodeStatus]; 
    
    if(passcodeStatus)
    {
        [self performSelector:@selector(presentPasscodeCheck) withObject:nil afterDelay:0];
        
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:sysApplicationEnterForeground object:nil];
        }];
    }
}

#pragma mark - MDPasscodeViewController delegate
-(void)MDPasscodeViewControllerInputPasscodeIsCorrect:(MDPasscodeViewController *)controller
{
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:sysApplicationEnterForeground object:nil];
    }];
}

-(void)MDPasscodeViewControllerInputPasscodeIsIncorrect:(MDPasscodeViewController *)controller
{
    NSString *msg = NSLocalizedString(@"Invalid passcode", @"Invalid passcode");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
    
    [alert show];
    
    [controller resetPasscode];
}

-(void)MDPasscodeViewControllerDidCancel:(MDPasscodeViewController *)controller
{
    
}

-(void)MDPasscodeViewController:(MDPasscodeViewController *)controller didReceiveNewPasscode:(NSString *)newPasscode
{
    
}

@end
