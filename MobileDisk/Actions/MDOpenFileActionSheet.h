//
//  MDOpenFileActionSheet.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/9/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDAction.h"

@class MDOpenFileActionSheet;

@protocol MDOpenFileActionSheetDelegate <NSObject>

-(void)MDOFDidClickedOpenFileButton:(MDOpenFileActionSheet *)object;
-(void)MDOFDidClickedOpenFileInButton:(MDOpenFileActionSheet *)object;

@end

@interface MDOpenFileActionSheet : MDAction<UIActionSheetDelegate>

-(id)initActionSheetWithDelegate:(id<MDOpenFileActionSheetDelegate>)theDelegate;
-(void)showFromView:(UIView*)view;

@end
