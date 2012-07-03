//
//  MDUnzipNavigationController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSZipArchive.h"

@interface MDUnarchiveNavigationController : UINavigationController <SSZipArchiveDelegate>

@property (nonatomic, copy) NSURL *archiveFilePath;

//called from child view controller
-(void)unarchiveTo:(NSString *)unarchivePath;

//called from child view controller
-(void)dismissNavigationController;

@end
