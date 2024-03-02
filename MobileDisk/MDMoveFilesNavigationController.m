//
//  MDMoveFilesNavigationController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDMoveFilesNavigationController.h"
#import "MDMoveFilesViewController.h"
#import "MobileDiskAppDelegate.h"

@interface MDMoveFilesNavigationController ()



@end

@implementation MDMoveFilesNavigationController{
    
    
}

@synthesize theDelegate = _theDelegate;

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
    MDMoveFilesViewController *rootController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDMoveFilesViewController"];
    
    //set it's working path
    rootController.workingPath = [MobileDiskAppDelegate documentDirectory];
    //set controller title
    rootController.controllerTitle = NSLocalizedString(@"Root", @"Root");
    
    //set view controllers for navigation controller, here it's only root controller
    self.viewControllers = [NSArray arrayWithObject:rootController];
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


-(void)moveFilesTo:(NSString *)movingDest
{
    [self.theDelegate MDMoveFilesNavigationController:self DidMoveFilesToDestination:movingDest];
}

-(void)dismissNavigationController
{
    [self.theDelegate MDMoveFilesNavigationControllerDidCancelWithController:self];
}

@end
