//
//  MDFilesNavigationController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDFilesNavigationController.h"
#import "MDFilesViewController.h"
#import "HTTPServer.h"
#import "MobileDiskAppDelegate.h"

@interface MDFilesNavigationController ()

@end

@implementation MDFilesNavigationController


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
    
    //instantiate a root view controller from storyboard
    MDFilesViewController *rootController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDFilesViewController"];
    
    //set it's working path
    rootController.workingPath = [MobileDiskAppDelegate documentDirectory];
    rootController.controllerTitle = NSLocalizedString(@"Files", @"Files");
    
    //set view controllers for navigation controller, here it's only root controller
    [self setViewControllers:[NSArray arrayWithObject:rootController]];
    
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
