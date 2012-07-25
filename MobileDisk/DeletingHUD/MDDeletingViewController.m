//
//  MDDeletingViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDDeletingViewController.h"
#import "MDProgressGradientView.h"

@interface MDDeletingViewController ()

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation MDDeletingViewController{
    
    MDProgressGradientView *gradientView;
}

@synthesize messageLabel = _messageLabel;
@synthesize activityView = _activityView;

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
     [gradientView removeFromSuperview];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //gradient view
    gradientView = [[MDProgressGradientView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:gradientView];
    [self.view sendSubviewToBack:gradientView];
    
    self.messageLabel.text = NSLocalizedString(@"Deleting...", @"Deleting...");
    self.activityView.hidden = NO;
    [self.activityView startAnimating];

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



@end
