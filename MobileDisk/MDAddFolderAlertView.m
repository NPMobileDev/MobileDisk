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
    UITextField *newFolderNameTextField;
}

-(id)initAlertViewWithDelegate:(id<MDAddFolderAlertViewDelegate>)theDelegate
{
    if((self = [super init]))
    {
        delegate = theDelegate;
        
        theAlertView = [self createAlertView];
    }
    
    return self;
}

-(void)dealloc
{
    NSLog(@"MDAddFolderAlertView dealloc");
}

-(UIAlertView*)createAlertView
{
    if(newFolderNameTextField == nil)
    {
        newFolderNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        newFolderNameTextField.placeholder = NSLocalizedString(@"Folder name", @"Folder name");
        newFolderNameTextField.backgroundColor = [UIColor whiteColor];
        newFolderNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        newFolderNameTextField.text = nil;
    }
    
    //use alert view to let user to type in folder name
    UIAlertView *addFolderAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add folder", @"Add folder") message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Add", @"Add"), nil];
    
    [addFolderAlert addSubview:newFolderNameTextField];
    
    return addFolderAlert;
}

-(void)showAlertView
{
    [theAlertView show];
    
    [newFolderNameTextField becomeFirstResponder];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //check if text field's text is empty
        if([newFolderNameTextField.text isEqualToString:@""])
        {
            [delegate AddFolderInputNameWasEmpty:self];
        }
        else
        {
            [delegate MDAddFolderAlertView:self didAddFolderWithName:newFolderNameTextField.text];
        }
    }
}

@end