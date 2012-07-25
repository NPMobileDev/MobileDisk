//
//  MDSelectedActionSheet.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDAction.h"

@class MDSelectedActionSheet;

@protocol MDSelectedActionSheetDelegate <NSObject>

-(void)MDSDidClickedDeleteButton:(MDSelectedActionSheet *)object;
-(void)MDSDidClickedDeselectAllButton:(MDSelectedActionSheet *)object;
-(void)MDSDidClickedSelectAllButton:(MDSelectedActionSheet *)object;
-(void)MDSDidClickedMoveButton:(MDSelectedActionSheet *)object;

@end

@interface MDSelectedActionSheet : MDAction<UIActionSheetDelegate>

-(id)initActionSheetWithDelegate:(id<MDSelectedActionSheetDelegate>)theDelegate;
-(void)showFromTabBar:(UITabBar *)tabbar;

@end
