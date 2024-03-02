//
//  MDUnarchivePasswordAlertView.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/8/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//add support password input for unarchive file zip 8/28/2012

#import "MDUnarchivePasswordAlertView.h"

@implementation MDUnarchivePasswordAlertView{
    
    __weak id<MDUnarchivePasswordAlertViewDelegate> delegate;
    
    UIAlertView *theAlertView;
    
    //text field to type in password
    //UITextField *passwordTextField;
}


-(id)initAlertViewWithDelegate:(id<MDUnarchivePasswordAlertViewDelegate>)theDelegate
{
    if((self = [super init]))
    {
        delegate = theDelegate;
        
        theAlertView = [self createAlertView];
        
        self.theUIAction = theAlertView;
    }
    
    return self;
}

-(void)dealloc
{
    NSLog(@"MDUnarchivePasswordAlertView dealloc");
}

-(UIAlertView*)createAlertView
{
    /*
    if(passwordTextField == nil)
    {
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        passwordTextField.placeholder = NSLocalizedString(@"Enter password", @"Enter password");
        passwordTextField.backgroundColor = [UIColor whiteColor];
        passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
        passwordTextField.returnKeyType = UIReturnKeyDone;
        passwordTextField.text = nil;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.delegate = self;
    }
    
    //use alert view to let user to type in folder name
    UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypted file", @"Encrypted file") message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    
    [passwordAlert addSubview:passwordTextField];
     */
    
    UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encrypted file", @"Encrypted file") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    
    passwordAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    return passwordAlert;
}

-(void)showAlertView
{
    UITextField *textField = [(UIAlertView*)self.theUIAction textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"Enter password", @"Enter password");
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.returnKeyType = UIReturnKeyDone;
    textField.text = nil;
    textField.delegate = self;
    
    [theAlertView show];
    
    //[passwordTextField becomeFirstResponder];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [theAlertView dismissWithClickedButtonIndex:1 animated:YES];
    
    return NO;
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 1)
    {
        /*
        //check if text field's text is empty
        if([passwordTextField.text isEqualToString:@""])
        {
            [delegate MDUnarchivePasswordAlertView:self didInputPassword:nil];
        }
        else
        {
            [delegate MDUnarchivePasswordAlertView:self didInputPassword:passwordTextField.text];
        }
         */
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        if([textField.text isEqualToString:@""])
        {
            [delegate MDUnarchivePasswordAlertView:self didInputPassword:nil];
        }
        else
        {
            [delegate MDUnarchivePasswordAlertView:self didInputPassword:textField.text];
        }
    }
    else if(buttonIndex == 0)
    {
        [delegate MDUnarchivePasswordAlertViewCancel:self];
    }
}

@end
