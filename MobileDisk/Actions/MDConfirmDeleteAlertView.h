//
//  MDConfirmDeleteAlertView.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDAction.h"

@class MDConfirmDeleteAlertView;

@protocol MDConfirmDeleteAlertViewDelegate <NSObject>

-(void)MDConfirmDeleteAlertViewDidCancel:(MDConfirmDeleteAlertView *)object;
-(void)MDConfirmDeleteAlertViewDidConfirmDelete:(MDConfirmDeleteAlertView *)object;

@end

@interface MDConfirmDeleteAlertView : MDAction<UIAlertViewDelegate>

-(id)initAlertViewWithDelegate:(id<MDConfirmDeleteAlertViewDelegate>)theDelegate;
-(void)showAlertView;

@end
