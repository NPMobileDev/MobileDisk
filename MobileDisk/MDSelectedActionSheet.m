//
//  MDSelectedActionSheet.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDSelectedActionSheet.h"

@interface MDSelectedActionSheet()

-(UIActionSheet *)createActionSheet;

@end

@implementation MDSelectedActionSheet{
    
    __weak id<MDSelectedActionSheetDelegate> delegate;
    
    UIActionSheet *theActionSheet;
}

-(id)initActionSheetWithDelegate:(id<MDSelectedActionSheetDelegate>)theDelegate
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
    NSLog(@"MDSelectedActionSheet dealloc");
}

-(UIActionSheet *)createActionSheet
{
    NSString *deselectAllButton = NSLocalizedString(@"Deselect all", @"Deselect all");
    NSString *selectAllButton = NSLocalizedString(@"Select all", @"Select all");
    NSString *moveButton = NSLocalizedString(@"Move", @"Move");
    
    UIActionSheet *selectedActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Action", @"Action") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete", @"Delete") otherButtonTitles:deselectAllButton, selectAllButton, moveButton, nil];
    
    return selectedActionSheet;
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
        /**delete selected**/
        [delegate MDSDidClickedDeleteButton:self];
    }
    else if(buttonIndex == 1)
    {
        /**deselect all**/
        [delegate MDSDidClickedDeselectAllButton:self];
    }
    else if(buttonIndex == 2)
    {
        /**select all action**/
        [delegate MDSDidClickedSelectAllButton:self];
    }
    else if(buttonIndex == 3)
    {
        /**move files**/
        [delegate MDSDidClickedMoveButton:self];
    }
}

@end
