//
//  MDProgressViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDProgressViewController.h"
#import "MDProgressGradientView.h"

@interface MDProgressViewController ()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *percentLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@end

@implementation MDProgressViewController{
    
    MDProgressGradientView *gradientView;
}

@synthesize percentLabel = _percentLabel;
@synthesize progressView = _progressView;
@synthesize statusLabel = _statusLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //**9/20/2012 4inch**//
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    if(UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        CGRect rect = CGRectMake(0, 20, height, width);
        self.view.frame = rect;
    }
    //**9/20/2012 4inch**//
    
    self.progressView.progress = 0.0f;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//**9/20/2012 4inch**//
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//**9/20/2012 4inch**//
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if(orientation == UIInterfaceOrientationPortraitUpsideDown)
        return UIInterfaceOrientationPortrait;
    
    return orientation;
}

-(void)setProgress:(float)value
{
    float theValue = value;
    
    /*
    if(theValue >= 0.9f)
        theValue = 1.0f;
    */
    
    NSLog(@"progress:%f", theValue);
    [self.progressView setProgress:theValue animated:YES];
    
    int percent = roundf(theValue * 100);
    
    self.percentLabel.text = [NSString stringWithFormat:@"%i%%", percent];
}

-(void)setStatusWithMessage:(NSString *)statusMsg
{
    self.statusLabel.text = statusMsg;
}

-(void)presentInParentViewController:(UIViewController *)parentController
{
    //**9/20/2012 4inch**//
    //gradient view
    gradientView = [[MDProgressGradientView alloc] initWithFrame:parentController.view.bounds];
    [parentController.view addSubview:gradientView];
    
    //[self.view addSubview:gradientView];
    //[self.view sendSubviewToBack:gradientView];
    

    //self.view.bounds = parentController.view.bounds;
    [parentController.view addSubview:self.view];
    [parentController addChildViewController:self];
    [self didMoveToParentViewController:parentController];
    
    //**9/20/2012 4inch**//
}

-(void)dismiss
{
    [self willMoveToParentViewController:nil];
    
    [gradientView removeFromSuperview];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)dealloc
{
    NSLog(@"MDProgressViewController dealloc");
}

@end
