//
//  MDAddFolderAlertView.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDAddFolderAlertView.h"

@interface MDAddFolderAlertView()

-(UIAlertView*)createAlertView;

@end

@implementation MDAddFolderAlertView{
    
    __weak id<MDAddFolderAlertViewDelegate> delegate;
    
    UIAlertView *theAlertView;
    
    //text field to type in name for new folder
    //UITextField *newFolderNameTextField;
}

-(id)initAlertViewWithDelegate:(id<MDAddFolderAlertViewDelegate>)theDelegate
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
    NSLog(@"MDAddFolderAlertView dealloc");
}

-(UIAlertView*)createAlertView
{

    /*
    if(newFolderNameTextField == nil)
    {
        newFolderNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        newFolderNameTextField.placeholder = NSLocalizedString(@"Folder name", @"Folder name");
        newFolderNameTextField.backgroundColor = [UIColor whiteColor];
        newFolderNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        newFolderNameTextField.clearButtonMode = UITextFieldViewModeAlways;
        newFolderNameTextField.returnKeyType = UIReturnKeyDone;
        newFolderNameTextField.text = nil;
        newFolderNameTextField.delegate = self;
    }

    
    //use alert view to let user to type in folder name

    UIAlertView *addFolderAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add folder", @"Add folder") message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Add", @"Add"), nil];

    
    [addFolderAlert addSubview:newFolderNameTextField];
     */
    UIAlertView *addFolderAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add folder", @"Add folder") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Add", @"Add"), nil];
    
    addFolderAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    

    
    return addFolderAlert;
}

-(void)showAlertView
{
    UITextField *textField = [(UIAlertView*)self.theUIAction textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"Folder name", @"Folder name");
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.returnKeyType = UIReturnKeyDone;
    textField.text = nil;
    textField.delegate = self;
    
    [theAlertView show];
    
    //[newFolderNameTextField becomeFirstResponder];
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
        if([newFolderNameTextField.text isEqualToString:@""])
        {
            [delegate AddFolderInputNameWasEmpty:self];
        }
        else
        {
            [delegate MDAddFolderAlertView:self didAddFolderWithName:newFolderNameTextField.text];
        }
         */
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        if([textField.text isEqualToString:@""])
        {
            [delegate AddFolderInputNameWasEmpty:self];
        }
        else
        {
            [delegate MDAddFolderAlertView:self didAddFolderWithName:textField.text];
        }
        
    }
}

@end
