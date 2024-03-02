//
//  MDImageViewerController.h
//  ScrollPic
//
//  Created by Mac-mini Nelson on 12/9/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPadding 10

@class MDImageViewerController;

@protocol MDImageViewerControllerDelegate <NSObject>

-(NSUInteger)numberOfImage;
-(NSUInteger)beginWithPageIndex;
-(NSString*)imagePathForImageIndexToDisplay:(NSUInteger)index;
-(void)finishImageViewing;

@end

@interface MDImageViewerController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, weak) id<MDImageViewerControllerDelegate> theDelegate;

@end
