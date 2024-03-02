//
//  MDUnzipViewController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDUnarchiveViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *workingPath;
@property (nonatomic, copy) NSString *controllerTitle;

@end
