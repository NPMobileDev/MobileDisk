//
//  MDFilesNavigationController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/******
 We subclass navigation controller is because we need MDFilesViewController to
 be reuseable and independent not embeded in navigation controller. However, we 
 need to instantiate a root view controller manually. The root view controller which
 is a instance of MDFilesViewController.
 ******/

#import <UIKit/UIKit.h>

@class MDFileSupporter;

@interface MDFilesNavigationController : UINavigationController 

//@property (nonatomic, weak) MDFileSupporter *fileSupporter;
@end
