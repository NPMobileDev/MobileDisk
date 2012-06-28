//
//  MDScrollView.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDScrollView.h"

@implementation MDScrollView
{
    __weak UIImageView *theImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//whenever a new contentOffset we adjust image to fit on center of scrollview if it is smaller than scrollview on both width and height
//setter for property contentOffset
-(void)setContentOffset:(CGPoint)contentOffset
{

    if(theImageView != nil)
    {
        if(theImageView.frame.size.width < self.bounds.size.width)
        {
            contentOffset.x = - ((self.bounds.size.width - theImageView.frame.size.width) / 2);
        }
        
        if(theImageView.frame.size.height < self.bounds.size.height)
        {
            contentOffset.y = - ((self.bounds.size.height - theImageView.frame.size.height) / 2);
        }
    }

    
    super.contentOffset = contentOffset;
}

//we override addSubview method
-(void)addSubview:(UIView *)view
{
    [super addSubview:view];
    
    theImageView = (UIImageView*)view;
    self.contentOffset = CGPointZero;
}

@end
