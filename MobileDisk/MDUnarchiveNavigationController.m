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
    //dont sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //archive file location to string
    NSString *pathOfArchive = [self.archiveFilePath path];
    
    __block BOOL success;
    
    progressView = [self.storyboard instantiateViewControllerWithIdentifier:@"MDProgressViewController"];
    
    [progressView presentInParentViewController:self];
    [progressView setStatusWithMessage:NSLocalizedString(@"Prepare to unarchive!", @"Prepare to unarchive!")];
    
    dispatch_async(unarchiveQueue, ^(void){
        
        success = [SSZipArchive unzipFileAtPath:pathOfArchive toDestination:unarchivePath delegate:self];
    
        
        if(!success)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                [progressView setStatusWithMessage:NSLocalizedString(@"Unarchive failed!", @"Unarchive failed!")];
            });
        }
        
         
    });

    
}

-(void)unarchiveFinished
{
    //can sleep
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
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
    __block BOOL completeUnarchive = NO;
    
    if((fileIndex+1) == totalFiles)
    {
        completeUnarchive = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
    
        [progressView setStatusWithMessage:@"Unarchiving..."];
        
        if(completeUnarchive)
        {
            [progressView setProgress:1.0f];
        }
        else
        {
            [progressView setProgress:progressValue];
        }
        
        
    });
    
    
    if(completeUnarchive)
    {
        NSLog(@"finish unarchive");
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
        
            [progressView setStatusWithMessage:NSLocalizedString(@"Unarchive successful!", @"Unarchive successful!")];
            
            [self performSelector:@selector(unarchiveFinished) withObject:nil afterDelay:1.5f];
        });

    }
}

@end
