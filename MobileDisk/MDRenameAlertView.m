//
//  MDRenameAlertView.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDRenameAlertView.h"

@interface MDRenameAlertView()

-(UIAlertView*)createAlertView;

@end

@implementation MDRenameAlertView{
    
    __weak id<MDRenameAlertViewDelegate> delegate;
    
    UIAlertView *theAlertView;
    
    //text field to type in name for new folder
    UITextField *renameFileTextField;
}

@synthesize originalFilename = _originalFilename;

-(id)initAlertViewWithDelegate:(id<MDRenameAlertViewDelegate>)theDelegate
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
    self.originalFilename = nil;
    NSLog(@"MDRenameAlertView dealloc");
}

-(UIAlertView*)createAlertView
{
    if(renameFileTextField == nil)
    {
        renameFileTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        renameFileTextField.placeholder = NSLocalizedString(@"New name", @"New name");
        renameFileTextField.backgroundColor = [UIColor whiteColor];
        renameFileTextField.borderStyle = UITextBorderStyleRoundedRect;
        renameFileTextField.text = nil;
    }
    
    //use alert view to let user to type in new name
    UIAlertView *renameAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rename", @"Rename") message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Rename", @"Rename"), nil];
    
    [renameAlert addSubview:renameFileTextField];
    
    return renameAlert;
}

-(void)showAlertView
{
    [theAlertView show];
    
    [renameFileTextField becomeFirstResponder];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //check if text field's text is empty
        if([renameFileTextField.text isEqualToString:@""])
        {
            [delegate RenameInputNameWasEmpty:self];
        }
        else
        {
            
            [delegate MDRenameAlertView:self didInputNameWithName:renameFileTextField.text];
        }
    }
}

#pragma mark - setter
-(void)setOriginalFilename:(NSString *)filename
{
    _originalFilename = filename;
    renameFileTextField.text = _originalFilename;
}

@end
