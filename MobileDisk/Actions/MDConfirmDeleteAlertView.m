//
//  MDConfirmDeleteAlertView.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDConfirmDeleteAlertView.h"

@interface MDConfirmDeleteAlertView()

-(UIAlertView*)createAlertView;

@end

@implementation MDConfirmDeleteAlertView{
    
    __weak id<MDConfirmDeleteAlertViewDelegate> delegate;
    
    UIAlertView *theAlertView;
}

-(id)initAlertViewWithDelegate:(id<MDConfirmDeleteAlertViewDelegate>)theDelegate
{
    if((self = [super init]))
    {
        delegate = theDelegate;
        
        theAlertView = [self createAlertView];
        
        self.theUIAction = theAlertView;
        
    }
    return self;
}

-(UIAlertView*)createAlertView
{
    //use alert view to cinfirm
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete selected", @"Delete selected") message:NSLocalizedString(@"Do you want to delete selected items?", @"Do you want to delete selected items?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Delete", @"Delete"), nil];
    
    return confirmAlert;
}

-(void)showAlertView
{
    [theAlertView show];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [delegate MDConfirmDeleteAlertViewDidCancel:self];
    }
    else if(buttonIndex == 1)
    {
        [delegate MDConfirmDeleteAlertViewDidConfirmDelete:self];
    }
}

@end
