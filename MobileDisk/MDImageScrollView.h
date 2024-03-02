//
//  MDImageScrollView.h
//  ScrollPic
//
//  Created by Mac-mini Nelson on 12/9/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDImageScrollView : UIScrollView<UIScrollViewDelegate>

//low resolution image
@property (nonatomic, strong) UIImage *lowResImage;
//image path to original image
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, assign) NSUInteger index;

-(void)displayImage;
-(void)prepareToRecycle;

@end
