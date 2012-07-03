//
//  MDUnzipNavigationController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDUnarchiveNavigationController.h"
#import "MDUnarchiveViewController.h"
#import "MobileDiskAppDelegate.h"
#import "MDProgressViewController.h"
#import <dispatch/dispatch.h>


@interface MDUnarchiveNavigationController ()

-(void)doUnarchiveToPath:(NSString *)unarchivePath;
-(void)unarchiveFinished;

@end

@implementation MDUnarchiveNavigationController{
    
    /**check grand central dispatch(GCD)**/
    //a dispatch queue for unarchiving
    dispatch_queue_t unarchiveQueue;
    
    __block MDProgressViewController *progressView;
}

@synthesize archiveFilePath = _archiveFilePath;


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
   // NSLog(@"release dispatch queue");
    //GCD is not part of ACR we need to release it by ourself
    dispatch_release(unarchiveQueue);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //instantiate a root view controller from storyboard
    MDUnarchiveViewController *rootController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDUnarchiveViewController"];
    
    //set it's working path
    rootController.workingPath = [MobileDiskAppDelegate documentDirectory];
    //set controller title
    rootController.controllerTitle = NSLocalizedString(@"Root", @"Root");
    
    //set view controllers for navigation controller, here it's only root controller
    self.viewControllers = [NSArray arrayWithObject:rootController];
    
    unarchiveQueue = dispatch_queue_create("UnarchiveQueue", NULL);
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

-(void)unarchiveTo:(NSString *)unarchivePath
{
    [self doUnarchiveToPath:unarchivePath];
}

-(void)dismissNavigationController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)doUnarchiveToPath:(NSString *)unarchivePath
{
    //archive file location to string
    NSString *pathOfArchive = [self.archiveFilePath path];
    
    __block BOOL success;
    
    progressView = [self.storyboard instantiateViewControllerWithIdentifier:@"MDProgressViewController"];
    
    [progressView presentInParentViewController:self];
    
    dispatch_async(unarchiveQueue, ^(void){
        
        success = [SSZipArchive unzipFileAtPath:pathOfArchive toDestination:unarchivePath delegate:self];
    
        /*
        dispatch_async(dispatch_get_main_queue(), ^(void){
        
        });
         */
    });

    
}

-(void)unarchiveFinished
{
    [progressView dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SSZipArchive delegate
- (void)zipArchiveWillUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(unz_file_info)fileInfo
{
    
}

- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(unz_file_info)fileInfo
{
    __block float progressValue = (float)fileIndex / (float)totalFiles;
    //int percent = roundf(((float)fileIndex / (float)totalFiles) * 100);
    //NSLog(@"unarchive progress: %i", percent);
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
    
        [progressView setStatusWithMessage:@"Unarchiving..."];
        [progressView setProgress:progressValue];
        
    });
    
    
    if((fileIndex+1) == totalFiles)
    {
        NSLog(@"finish unarchive");
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
        
            [progressView setStatusWithMessage:@"Unarchive successful!"];
            
            [self performSelector:@selector(unarchiveFinished) withObject:nil afterDelay:2.0f];
        });

    }
}

@end
