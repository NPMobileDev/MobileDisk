//
//  MDFilesViewController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/******
    This MDFilesViewController is a reuseable controller, which 
    present contents in a specific directory, no matter user pressed 
    a folder go into another directory this controller will be instantiated
    again a new one to present content in new directory.
 ******/

#import <UIKit/UIKit.h>

@interface MDFilesViewController : UITableViewController <UIAlertViewDelegate>

//current path
@property (nonatomic, copy) NSString *workingPath;
@property (nonatomic, copy) NSString *controllerTitle;

@end
