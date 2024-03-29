//
//  MDNonSelectedActionSheet.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDAction.h"

@class MDNonSelectedActionSheet;

@protocol MDNonSelectedActionSheetDelegate <NSObject>

-(void)MDNSDidClickedSelectAllButton:(MDNonSelectedActionSheet *)object;

@end

@interface MDNonSelectedActionSheet : MDAction<UIActionSheetDelegate>

-(id)initActionSheetWithDelegate:(id<MDNonSelectedActionSheetDelegate>)theDelegate;
-(void)showFromTabBar:(UITabBar *)tabbar;

@end
