//
//  MDUnarchivePasswordAlertView.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/8/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//add support password input for unarchive file zip 8/28/2012

#import "MDAction.h"

@class MDUnarchivePasswordAlertView;

@protocol MDUnarchivePasswordAlertViewDelegate <NSObject>

-(void)MDUnarchivePasswordAlertViewCancel:(MDUnarchivePasswordAlertView*)object;
-(void)MDUnarchivePasswordAlertView:(MDUnarchivePasswordAlertView*)object didInputPassword:(NSString*)password;

@end

@interface MDUnarchivePasswordAlertView : MDAction<UIAlertViewDelegate, UITextFieldDelegate>

-(id)initAlertViewWithDelegate:(id<MDUnarchivePasswordAlertViewDelegate>)theDelegate;
-(void)showAlertView;

@end
