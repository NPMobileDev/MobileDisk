//
//  MDOpenFileActionSheet.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/9/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MDOpenFileActionSheet.h"

@interface MDOpenFileActionSheet()

-(UIActionSheet *)createActionSheet;

@end

@implementation MDOpenFileActionSheet{
    
    __weak id<MDOpenFileActionSheetDelegate> delegate;
    
    UIActionSheet *theActionSheet;

}

-(id)initActionSheetWithDelegate:(id<MDOpenFileActionSheetDelegate>)theDelegate
{
    if((self = [super init]))
    {
        delegate = theDelegate;
        
        theActionSheet = [self createActionSheet];
        
        self.theUIAction = theActionSheet;
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"MDOpenFileActionSheet dealloc");
}

-(UIActionSheet *)createActionSheet
{
    NSString *OpenFileButton = NSLocalizedString(@"Open", @"Open");
    NSString *OpenFileInButton = NSLocalizedString(@"Open in", @"Open in");
    
    UIActionSheet *openFileActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Action", @"Action") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:OpenFileButton otherButtonTitles:OpenFileInButton, nil];
    
    return openFileActionSheet;
}

-(void)showFromView:(UIView*)view
{
    [theActionSheet showInView:view];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [delegate MDOFDidClickedOpenFileButton:self];
    }
    else if(buttonIndex == 1)
    {
        [delegate MDOFDidClickedOpenFileInButton:self];
    }

}



@end
