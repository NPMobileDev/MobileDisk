//
//  MDLicenseAgreementViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDLicenseAgreementViewController.h"
#import "MobileDiskAppDelegate.h"

@interface MDLicenseAgreementViewController ()

@end

@implementation MDLicenseAgreementViewController

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

//9/20/2012
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
//9/20/2012
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)agreeLicense:(id)sender
{
    NSString *msg = NSLocalizedString(@"You agree and understand these terms and conditions", @"License Agreement");
    UIAlertView *agreeAlert = [[UIAlertView alloc] initWithTitle:@"License Agreement" message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:@"Agree", nil];
    
    [agreeAlert show];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //user agree
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:sysLicenseAgree];
        [userDefaults synchronize];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
