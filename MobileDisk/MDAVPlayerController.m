//
//  MDAVPlayerController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDAVPlayerController.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface MDAVPlayerController ()

-(void)avPlayerFinish;

@end

@implementation MDAVPlayerController{
    
    MPMoviePlayerController *avPlayer;
}

@synthesize avFileURL =_avFileURL;

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
    
    //play when view appear
    [avPlayer play];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [avPlayer.view removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //create player
    avPlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.avFileURL];
    
    //set style and scaling mode
    avPlayer.controlStyle = MPMovieControlStyleFullscreen;
    avPlayer.scalingMode = MPMovieScalingModeAspectFill;
    
    [avPlayer prepareToPlay];
    
    
    avPlayer.view.frame = self.view.bounds;
    
    //add view to controller's view
    [self.view addSubview:avPlayer.view];
    
    //register a notification for playback finish
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
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

-(void)avPlayerFinish
{
    //remove notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
