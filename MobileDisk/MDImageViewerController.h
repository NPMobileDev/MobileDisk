//
//  ImageViewerController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDImageViewerController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, copy) NSURL *imageURL;

@end
