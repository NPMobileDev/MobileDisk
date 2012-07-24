//
//  MDRenameAlertView.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDRenameAlertView;

@protocol MDRenameAlertViewDelegate <NSObject>

-(void)RenameInputNameWasEmpty:(MDRenameAlertView *)object;
-(void)MDRenameAlertView:(MDRenameAlertView *)object didInputNameWithName:(NSString *)inputName;

@end

@interface MDRenameAlertView : NSObject<UIAlertViewDelegate>

@property (nonatomic, copy, setter = setOriginalFilename:) NSString *originalFilename;

-(id)initAlertViewWithDelegate:(id<MDRenameAlertViewDelegate>)theDelegate;
-(void)showAlertView;

@end
