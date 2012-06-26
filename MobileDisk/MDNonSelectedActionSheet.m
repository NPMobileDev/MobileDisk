//
//  MDNonSelectedActionSheet.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDNonSelectedActionSheet.h"

@interface MDNonSelectedActionSheet()

-(UIActionSheet *)createActionSheet;

@end

@implementation MDNonSelectedActionSheet{
    
    __weak id<MDNonSelectedActionSheetDelegate> delegate;
    
    UIActionSheet *theActionSheet;
}

-(id)initActionSheetWithDelegate:(id<MDNonSelectedActionSheetDelegate>)theDelegate
{
    if((self = [super init]))
    {
        delegate = theDelegate;
        
        theActionSheet = [self createActionSheet];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"MDNonSelectedActionSheet dealloc");
}

-(UIActionSheet *)createActionSheet
{
    NSString *selectAllButton = NSLocalizedString(@"Select all", @"Select all");

    UIActionSheet *nonSelectedActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Action", @"Action") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:selectAllButton, nil];
    
    return nonSelectedActionSheet;
}

-(void)showFromTabBar:(UITabBar *)tabbar
{
    [theActionSheet showFromTabBar:tabbar];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [delegate MDNSDidClickedSelectAllButton:self];
    }
}

@end
