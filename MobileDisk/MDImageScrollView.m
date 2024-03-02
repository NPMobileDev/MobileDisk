//
//  MDImageScrollView.m
//  ScrollPic
//
//  Created by Mac-mini Nelson on 12/9/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MDImageScrollView.h"

@implementation MDImageScrollView{
    
    float qualitySwapThreadhold;
    BOOL isHighResImage;
    UIImageView *imageView;
}

@synthesize index = _index;
@synthesize imagePath = _imagePath;
@synthesize lowResImage = _lowResImage;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 10.0f;
        //self.backgroundColor = [UIColor blueColor];
        self.delegate = self;
        
        //self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //hardcore value
        qualitySwapThreadhold = 1.2f;
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    
    CGSize boundsSize = self.bounds.size;
    boundsSize.height -= 20;//status bar
    CGRect frameToCenter = imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    imageView.frame = frameToCenter;
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    CGPoint contentOffset = self.contentOffset;
    CGSize contentSize = self.contentSize;
    CGRect imageRect = imageView.frame;
    
    if(scale >= qualitySwapThreadhold && isHighResImage == NO)
    {
        
        //swap to high res image
        //[imageView removeFromSuperview];
        
        //high res
        UIImage *highResImage = [UIImage imageWithContentsOfFile:self.imagePath];
        imageView.image = highResImage;
        
        imageView.frame = imageRect;
        self.contentOffset = contentOffset;
        self.contentSize = contentSize;
        
        //[self addSubview:imageView];
        
        
        isHighResImage = YES;

        
    }
    else if(scale < qualitySwapThreadhold && isHighResImage == YES)
    {
        //swap to low res image
        //[imageView removeFromSuperview];
        
        imageView.image = self.lowResImage;
        
        imageView.frame = imageRect;
        self.contentOffset = contentOffset;
        self.contentSize = contentSize;
        
        //[self addSubview:imageView];
        
        isHighResImage = NO;
    }
    else
    {
        //mantain last image quality
    }
}

-(void)displayImage
{
    if(imageView == nil)
    {
        imageView = [[UIImageView alloc] init];
    }
    
    //imageView = [[UIImageView alloc] initWithImage:image];
    imageView.image = self.lowResImage;
    imageView.frame = CGRectMake(0, 0, self.lowResImage.size.width, self.lowResImage.size.height);
    self.contentSize = imageView.frame.size;
    
    
    [self addSubview:imageView];
    
    isHighResImage = NO;
}

-(void)prepareToRecycle
{
    [imageView removeFromSuperview];
    self.lowResImage = nil;
    imageView = nil;
    self.imagePath = nil;
}

@end
