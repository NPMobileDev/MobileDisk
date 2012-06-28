//
//  ImageViewerController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDImageViewerController.h"
#import "UIImage+Resize.h"
#import "MDScrollView.h"

@interface MDImageViewerController ()

@property (nonatomic, weak) IBOutlet UIScrollView *imageScrolleView;

-(void)doneViewingImage;

@end

@implementation MDImageViewerController{
    
    UIImageView *imageView;


}

@synthesize imageURL = _imageURL;
@synthesize imageScrolleView = _imageScrolleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    self.imageURL = nil;
    NSLog(@"image viewer deallocate");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //set title
    self.title = [self.imageURL lastPathComponent];
    
    //load image
    UIImage *theImage = [UIImage imageWithContentsOfFile:[self.imageURL path]];
    
    //check if image width or height bigger than scroll view
    //if bigger then resize image
    if(theImage.size.width > self.imageScrolleView.frame.size.width)
    {
        theImage = [theImage resizeImageTo:self.imageScrolleView.frame.size];
    }
    else if(theImage.size.height > self.imageScrolleView.frame.size.height)
    {
        theImage = [theImage resizeImageTo:self.imageScrolleView.frame.size];
    }
    
    //create image view
    imageView = [[UIImageView alloc] initWithImage:theImage];
    

    //make scroll view's contentOffset and contentSize equal to image view
    self.imageScrolleView.contentSize = imageView.frame.size;

    
    //set zoom scale
    self.imageScrolleView.minimumZoomScale = 1.0f;
    self.imageScrolleView.maximumZoomScale = 10.0f;

    //add image view to scroll view
    [self.imageScrolleView addSubview:imageView];
    
    
    //give right button on navigation bar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneViewingImage)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [imageView removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)doneViewingImage
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //return image view to enable zoom
    return imageView;
}

-(void)launch
{
    NSLog(@"image viewer launch");
}


@end
