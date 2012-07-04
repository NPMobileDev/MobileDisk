//
//  MDProgressGradientView.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDProgressGradientView.h"

@implementation MDProgressGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    /**draw radius**/
    const CGFloat components[8]= {0.0f, 0.0f, 0.0f, 0.3f, 0.0f, 0.0f, 0.0f, 0.7f};
    const CGFloat location[2] = {0.0f, 1.0f};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, location, 2);
    
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MAX(startCenter.x, startCenter.y);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawRadialGradient(context, gradient, startCenter, 0, startCenter, radius, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);
}


@end
