//
//  MDPasscodeViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDPasscodeViewController.h"

@interface MDPasscodeViewController ()

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UITextField *p1;
@property (nonatomic, weak) IBOutlet UITextField *p2;
@property (nonatomic, weak) IBOutlet UITextField *p3;
@property (nonatomic, weak) IBOutlet UITextField *p4;
@property (nonatomic, weak) IBOutlet UITextField *vP1;
@property (nonatomic, weak) IBOutlet UITextField *vP2;
@property (nonatomic, weak) IBOutlet UITextField *vP3;
@property (nonatomic, weak) IBOutlet UITextField *vP4;

@end

@implementation MDPasscodeViewController{
    
    NSString *firstPasscode;
}

@synthesize navBar = _navBar;
@synthesize p1 = _p1;
@synthesize p2 = _p2;
@synthesize p3 = _p3;
@synthesize p4 = _p4;
@synthesize vP1 = _vP1;
@synthesize vP2 = _vP2;
@synthesize vP3 = _vP3;
@synthesize vP4 = _vP4;
@synthesize passcodeToCheck = _passcodeToCheck;
@synthesize theDelegate = _theDelegate;
@synthesize canShowCancelButton = _canShowCancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.canShowCancelButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *title;
    
    if(self.passcodeToCheck != nil)
    {
        title = NSLocalizedString(@"Enter passcode", @"Enter passcode");
    }
    else
    {
        title = NSLocalizedString(@"New passcode", @"New passcode");
    }
    
    
    if(self.canShowCancelButton)
    {
        //nav bar setup
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:title];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        
        navItem.rightBarButtonItem = cancelButton;
        
        self.navBar.items = [NSArray arrayWithObject:navItem];
    }
    else
    {
        //nav bar setup
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:title];
        
        self.navBar.items = [NSArray arrayWithObject:navItem];
    }

    /**
     doing @" " instead of given nil to make sure UITextFiled delegate
     get invocked when user tap backspace. 
    **/
    
    self.p1.text = @" ";
    self.p2.text = @" ";
    self.p3.text = @" ";
    self.p4.text = @" ";
    self.p1.delegate = self;
    self.p2.delegate = self;
    self.p3.delegate = self;
    self.p4.delegate = self;
    self.vP1.enabled = NO;
    self.vP2.enabled = NO;
    self.vP3.enabled = NO;
    self.vP4.enabled = NO;
    
    [self.p1 becomeFirstResponder];
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

#pragma mark UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.length == 0)
    {
        if(textField == self.p1)
        {
            self.p1.text = string;
            self.vP1.text = string;
            [self.p2 becomeFirstResponder];
            
        }
        else if(textField == self.p2)
        {
            
            self.p2.text = string;
            self.vP2.text = string;
            [self.p3 becomeFirstResponder];
            
        }
        else if(textField == self.p3)
        {
            
            self.p3.text = string;
            self.vP3.text = string;
            [self.p4 becomeFirstResponder];
            
        }
        else if(textField == self.p4)
        {
            self.p4.text = string;
            self.vP4.text = string;
            
            if(self.passcodeToCheck != nil)
            {
                [self performSelector:@selector(checkPasscode) withObject:nil afterDelay:0.1];
            }
            else
            {
                //new passcode
                if(firstPasscode == nil)
                {
                    //user was inputed first passcode
                    [self performSelector:@selector(completeFirstPasscode) withObject:nil afterDelay:0.1];
                    //[self completeFirstPasscode];
                }
                else
                {
                    [self performSelector:@selector(completeSecondPasscode) withObject:nil afterDelay:0.1];
                    
                    //[self completeSecondPasscode];
                }
            }
        }
    }
    else if(range.length == 1)
    {

        if (textField == self.p2)
        {
            self.p2.text = @" ";
            self.vP2.text = nil;
            self.p1.text = @" ";
            self.vP1.text = nil;
            [self.p1 becomeFirstResponder];
        }
        else if(textField == self.p3)
        {
            self.p3.text = @" ";
            self.vP3.text = nil;
            self.p2.text = @" ";
            self.vP2.text = nil;
            [self.p2 becomeFirstResponder];
        }
        else if(textField == self.p4)
        {
            self.p4.text = @" ";
            self.vP4.text = nil;
            self.p3.text = @" ";
            self.vP3.text = nil;
            [self.p3 becomeFirstResponder];
        }
    }

    
    return NO;
}

-(void)checkPasscode
{
    //combine passcode as string
    NSMutableString *inputPasscode = [[NSMutableString alloc] init];
    [inputPasscode appendString:self.p1.text];
    [inputPasscode appendString:self.p2.text];
    [inputPasscode appendString:self.p3.text];
    [inputPasscode appendString:self.p4.text];
    
    if([self.passcodeToCheck isEqualToString:inputPasscode])
    {
        //passcode is correct
        [self.theDelegate MDPasscodeViewControllerInputPasscodeIsCorrect:self];
    }
    else
    {
        //passcode is incorrect
        [self.theDelegate MDPasscodeViewControllerInputPasscodeIsIncorrect:self];
    }
}

-(void)cancel
{
    [self.theDelegate MDPasscodeViewControllerDidCancel:self];
}

-(void)completeFirstPasscode
{
    NSMutableString *firstInputPasscode = [[NSMutableString alloc] init];
    [firstInputPasscode appendString:self.p1.text];
    [firstInputPasscode appendString:self.p2.text];
    [firstInputPasscode appendString:self.p3.text];
    [firstInputPasscode appendString:self.p4.text];
    
    firstPasscode = firstInputPasscode;
    
    UINavigationItem *item = [self.navBar.items lastObject];
    item.title = NSLocalizedString(@"Re-Enter passcode", @"Re-Enter passcode");
    
    self.p1.text = @" ";
    self.p2.text = @" ";
    self.p3.text = @" ";
    self.p4.text = @" ";
    self.vP1.text = nil;
    self.vP2.text = nil;
    self.vP3.text = nil;
    self.vP4.text = nil;
    
    [self.p1 becomeFirstResponder];
}

-(void)completeSecondPasscode
{
    NSMutableString *secondInputPasscode = [[NSMutableString alloc] init];
    [secondInputPasscode appendString:self.p1.text];
    [secondInputPasscode appendString:self.p2.text];
    [secondInputPasscode appendString:self.p3.text];
    [secondInputPasscode appendString:self.p4.text];
    
    if([firstPasscode isEqualToString:secondInputPasscode])
    {
        NSString *newPasscode = [firstPasscode copy];
        [self.theDelegate MDPasscodeViewController:self didReceiveNewPasscode:newPasscode];
    }
    else
    {
        NSString *title = NSLocalizedString(@"Invalid passcode", @"Invalid passcode");
        NSString *msg = NSLocalizedString(@"The passcode is not vaild", @"The passcode is not vaild");
        //alert
        UIAlertView *reEnterAlert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
        
        [reEnterAlert show];
        
        //reset
        [self resetPasscode];
    }
}

-(void)resetPasscode
{
    firstPasscode = nil;
    
    UINavigationItem *item = [self.navBar.items lastObject];
    
    if(self.passcodeToCheck != nil)
    {
        item.title = NSLocalizedString(@"Enter passcode", @"Enter passcode");
    }
    else
    {
        item.title = NSLocalizedString(@"New passcode", @"New passcode");
    }
    
    
    self.p1.text = @" ";
    self.p2.text = @" ";
    self.p3.text = @" ";
    self.p4.text = @" ";
    self.vP1.text = nil;
    self.vP2.text = nil;
    self.vP3.text = nil;
    self.vP4.text = nil;
    
    [self.p1 becomeFirstResponder];
}

@end
