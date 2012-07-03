//
//  MDProgressViewController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDProgressViewController : UIViewController

//0.0~1.0
-(void)setProgress:(float)value;
-(void)setStatusWithMessage:(NSString *)statusMsg;
-(void)presentInParentViewController:(UIViewController *)parentController;
-(void)dismiss;

@end
