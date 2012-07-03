//
//  MDProgressViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDProgressViewController.h"

@interface MDProgressViewController ()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *percentLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@end

@implementation MDProgressViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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

-(void)setProgress:(float)value
{
    float theValue = value;
    
    if(theValue >= 0.9f)
        theValue = 1.0f;
    
    //NSLog(@"progress:%f", theValue);
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
    self.view.bounds = parentController.view.bounds;
    [parentController.view addSubview:self.view];
    [parentController addChildViewController:self];
}

-(void)dismiss
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
