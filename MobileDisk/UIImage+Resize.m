//
//  UIImage+Resize.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

-(UIImage *)resizeImageTo:(CGSize)size
{

    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

-(UIImage *)retinaResizeImageTo:(CGSize)size
{
    //retina support
    if([UIScreen mainScreen].scale == 2.0f)
    {
        size = CGSizeMake(size.width * 2.0f, size.height * 2.0f);
    }
    
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return theImage;
}

@end
