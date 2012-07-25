//
//  MDAddFolderAlertView.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDAddFolderAlertView;

@protocol MDAddFolderAlertViewDelegate <NSObject>

-(void)AddFolderInputNameWasEmpty:(MDAddFolderAlertView *)object;
-(void)MDAddFolderAlertView:(MDAddFolderAlertView *)object didAddFolderWithName:(NSString *)folderName;

@end


@interface MDAddFolderAlertView : NSObject<UIAlertViewDelegate, UITextFieldDelegate>

-(id)initAlertViewWithDelegate:(id<MDAddFolderAlertViewDelegate>)theDelegate;
-(void)showAlertView;

@end
