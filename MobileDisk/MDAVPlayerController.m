//
//  MDAVPlayerController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDAVPlayerController.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPVolumeView.h>


@interface MDAVPlayerController ()

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UISlider *timeLineSlider;
@property (nonatomic, weak) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIView *timelineBackgroundView;
//this is only used to receive gesture purpose
@property (nonatomic, weak) IBOutlet UIView *gestureReceiverView;
//this is only used to contain video view
@property (nonatomic, weak) IBOutlet UIView *videoLayerView;

-(void)play;
-(void)pause;
-(IBAction)rewind:(id)sender;
-(IBAction)fastForward:(id)sender;
-(void)avPlayerFinish;
-(void)customizedNavigationBar;
-(void)changePauseButtonToPlay;
-(void)changePlayButtonToPause;
-(NSString *)secondsToString:(float)totalSeconds;
-(void)updateTimeline;
-(void)updateTimeLabels;
-(IBAction)beginChangeSlider:(id)sender;
-(IBAction)sliderValueChange:(id)sender;
-(IBAction)endChangeSlider:(id)sender;
-(void)customizedToolBar;
-(void)performUIAction;
-(void)fadeOutUI;
-(void)fadeInUI;
-(void)createGestureForView:(UIView *)view;

@end

@implementation MDAVPlayerController{
    
    MPMoviePlayerController *avPlayer;
    
    //timer for update timeline slider and labels
    NSTimer *updateTimer;
    
    //indicate that if can update for timeline slider and labels
    BOOL canUpdateTimeline;
    
    BOOL isUIVisible;
    
    BOOL isFadingUI;
    
    BOOL isScaled;
    
    CGRect videoLayerRect;
    
    UIDeviceOrientation lastDeviceOrientation;
}

@synthesize avFileURL =_avFileURL;
@synthesize navBar = _navBar;
@synthesize timeLineSlider = _timeLineSlider;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize timeLeftLabel = _timeLeftLabel;
@synthesize toolbar = _toolbar;
@synthesize timelineBackgroundView = _timelineBackgroundView;
@synthesize gestureReceiverView = _gestureReceiverView;
@synthesize videoLayerView = _videoLayerView;

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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    lastDeviceOrientation = [UIDevice currentDevice].orientation;

}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [avPlayer.view removeFromSuperview];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //create player
    avPlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.avFileURL];
    
    //set style and scaling mode
    avPlayer.controlStyle = MPMovieControlStyleNone;
    avPlayer.scalingMode = MPMovieScalingModeAspectFit;
    avPlayer.movieSourceType = MPMovieSourceTypeFile;
    
    [avPlayer prepareToPlay];
    
    videoLayerRect = self.videoLayerView.frame;
    
    //set video view's width and height equal to videoLayerView
    avPlayer.view.frame = CGRectMake(0, 0, self.videoLayerView.bounds.size.width, self.videoLayerView.bounds.size.height);
    
    //add video view to controller's view
    [self.videoLayerView addSubview:avPlayer.view];
    
    //create gesture
    [self createGestureForView:self.gestureReceiverView];
    
    //we also make gesture receiver view's background color clear
    [self.gestureReceiverView setBackgroundColor:[UIColor clearColor]];
    
    //set play button for action
    UIBarButtonItem *playButton = [self.toolbar.items objectAtIndex:1];
    playButton.target =self;
    playButton.action = @selector(play);
    
    [self customizedNavigationBar];
    [self customizedToolBar];
    [self createVolumeSlider];
    
    //make sure videoLayerView is at back
    [self.view sendSubviewToBack:self.videoLayerView];
    
    //bring ui to top
    [self.view bringSubviewToFront:self.gestureReceiverView];
    [self.view bringSubviewToFront:self.navBar];
    [self.view bringSubviewToFront:self.timelineBackgroundView];
    [self.view bringSubviewToFront:self.toolbar];
    

    
    //register a notification for playback finish
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerDidLoadContent:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    canUpdateTimeline = YES;
    isUIVisible = YES;
    isFadingUI = NO;
    isScaled = NO;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    lastDeviceOrientation = toInterfaceOrientation;
    
    if(toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown)
    {
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGRect newRect;
                
            //newRect.origin.x = 480/2 - self.videoLayerView.frame.size.width/2;
            newRect.origin.x = 0;
            newRect.origin.y = 0;
            //newRect.size.width = self.videoLayerView.frame.size.width;
            newRect.size.width = 480;
            //newRect.size.height = 300;
            newRect.size.height = 300;

            
            //if video is been scaled
            if(isScaled)
            {
                //newRect.origin.x = 480/2 - self.videoLayerView.frame.size.width/2;
                float scaledHeight = 480 * kVideoScale;
                newRect.origin.x = -((scaledHeight - 480) / 2);
                //newRect.origin.y = 300/2 - self.videoLayerView.frame.size.height/2;
                float scaledWidth = 320 * kVideoScale;
                newRect.origin.y = -((scaledWidth - 320) / 2);
                //newRect.size = self.videoLayerView.frame.size;
                float sizeWidth = 480 * kVideoScale;
                float sizeHeight = 320 * kVideoScale;
                newRect.size = CGSizeMake(sizeWidth, sizeHeight);
                
            }
            
            
            self.videoLayerView.frame = newRect;
            avPlayer.view.frame = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
            
        }
        
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait)
        {
            CGRect newRect = videoLayerRect;
            
            //if video is been scaled
            if(isScaled)
            {
                //newRect.origin.x = 320/2 - self.videoLayerView.frame.size.width/2;
                float scaledWidth = 320 * kVideoScale;
                newRect.origin.x = -((scaledWidth - 320) / 2);
                //newRect.origin.y = 460/2 - self.videoLayerView.frame.size.height/2;
                float scaledHeight = 480 * kVideoScale;
                newRect.origin.y = -((scaledHeight - 480) / 2);
                //newRect.size = self.videoLayerView.frame.size;
                float sizeWidth = 320 * kVideoScale;
                float sizeHeight = 480 * kVideoScale;
                newRect.size = CGSizeMake(sizeWidth, sizeHeight);
            }
            
            self.videoLayerView.frame = newRect;
            avPlayer.view.frame = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
        }
        
    }
}
     
-(void)videoPlayerDidLoadContent:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    self.timeLineSlider.minimumValue = 0.0f;
    self.timeLineSlider.maximumValue = round(avPlayer.duration);
    self.timeLineSlider.value = 0.0f;
    
    self.timeLeftLabel.text = [@"-" stringByAppendingString:[self secondsToString:self.timeLineSlider.maximumValue]];
    self.currentTimeLabel.text = [self secondsToString:0.0f];
    
    //play video when content loaded
    [self play];
}

-(void)play
{
    [self changePlayButtonToPause];
    
    [avPlayer play];
    
    //create a update timer if needed
    if(updateTimer == nil)
    {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateTimeline) userInfo:nil repeats:YES];
        
        //this way can make sure timer can perform it's selector without been blocked
        [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    }
    
    //start timer
    [updateTimer fire];
}

-(void)pause
{
    [self changePauseButtonToPlay];
    
    [avPlayer pause];
    
    //stop timer
    [updateTimer invalidate];
    updateTimer = nil;
}

-(IBAction)rewind:(id)sender
{
    avPlayer.currentPlaybackTime -= kRewindAmount;
}

-(IBAction)fastForward:(id)sender
{
    avPlayer.currentPlaybackTime += kFastForwardAmount;
}

-(void)updateTimeline
{
    if(canUpdateTimeline)
    {
        self.timeLineSlider.value = round(avPlayer.currentPlaybackTime);
        [self updateTimeLabels];
        
    }
    
    //NSLog(@"total %f", self.timeLineSlider.maximumValue);
    //NSLog(@"current %f", self.timeLineSlider.value);
}

-(void)updateTimeLabels
{
    //current time
    self.currentTimeLabel.text = [self secondsToString:self.timeLineSlider.value];
    
    //time left
    float timeleft = self.timeLineSlider.maximumValue - self.timeLineSlider.value;
    self.timeLeftLabel.text = [@"-" stringByAppendingString:[self secondsToString:timeleft]];
}

-(IBAction)beginChangeSlider:(id)sender
{
    //when slider touch down we stop update slider and labels
    canUpdateTimeline = NO;
}

-(IBAction)sliderValueChange:(id)sender
{
    
    //when slider value change we need to update labels
    [self updateTimeLabels];
}

-(IBAction)endChangeSlider:(id)sender
{
    //when slider touch up we check if slider reach max value
    if(self.timeLineSlider.value == self.timeLineSlider.maximumValue)
    {
        //stop video
        [self stopVideo];
    }
    else
    {
        //reset current time for music player
        [avPlayer setCurrentPlaybackTime:self.timeLineSlider.value];
    }
    
    //update labels
    [self updateTimeLabels];
    
    //resume update
    canUpdateTimeline = YES;
}

-(void)createGestureForView:(UIView *)view
{

    //create gesture tap
    UITapGestureRecognizer *uiFadeInOutTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performUIAction)];
    
    //create gesture double tap
    UITapGestureRecognizer *scaleVideoDoubleTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scaleVideo)];
    
    scaleVideoDoubleTaps.numberOfTapsRequired = 2;
    
    
    //add gesture to view that used to receive gesture
    [view addGestureRecognizer:uiFadeInOutTap];
    [view addGestureRecognizer:scaleVideoDoubleTaps];
}

-(void)createVolumeSlider
{
    /*
    //the rect need to design tool to measure
    UISlider *volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 158, 23)];
    volumeSlider.minimumValue = 0.0f;
    volumeSlider.maximumValue = 1.0f;
    
    //this only can be used on real device it get back ipod volume
     MPMusicPlayerController *ipod = [MPMusicPlayerController iPodMusicPlayer];
     if(ipod != nil)
     {
         volumeSlider.value = ipod.volume;
         //[musicPlayer setVolume:ipod.volume];
         [[MPMusicPlayerController applicationMusicPlayer] setVolume:ipod.volume];
     }
     else
     {
         volumeSlider.value = 0.5f;
         [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
     }
     
    
    //test 
    //volumeSlider.value = 0.5f;
    //[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
    
    [volumeSlider addTarget:self action:@selector(volumeSliderChange:) forControlEvents:UIControlEventValueChanged];
     */
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 158, 23)];
    
    //create bar button with silder inside
    UIBarButtonItem *volumeButton = [[UIBarButtonItem alloc] initWithCustomView:volumeView];
    volumeButton.style = UIBarButtonItemStylePlain;
    
    /**reassign items**/
    NSArray *items = self.toolbar.items;
    
    UIBarButtonItem *rewindButton = [items objectAtIndex:0];
    UIBarButtonItem *thePlayButton = [items objectAtIndex:1];
    UIBarButtonItem *fastForwardButton = [items objectAtIndex:2];
    UIBarButtonItem *spaceLine = [items objectAtIndex:3];
    
    
    NSArray *newItems = [NSArray arrayWithObjects:rewindButton, thePlayButton, fastForwardButton, spaceLine, volumeButton, nil];
    
    [self.toolbar setItems:newItems animated:NO];
}

-(void)customizedNavigationBar
{
    UINavigationItem *title = [[UINavigationItem alloc] initWithTitle:[self.avFileURL lastPathComponent]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(avPlayerFinish)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 21)];
    titleLabel.text = [self.avFileURL lastPathComponent];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    title.titleView = titleLabel;
    title.rightBarButtonItem = doneButton;
    
    self.navBar.items = [NSArray arrayWithObject:title];
    
    self.navBar.barStyle = UIBarStyleBlackTranslucent;
}

-(void)customizedToolBar
{
    self.toolbar.barStyle = UIBarStyleBlackTranslucent;
}

-(void)changePauseButtonToPlay
{
    //change pause button to play
    UIBarButtonItem *playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play)];
    
    playButton.style = UIBarButtonItemStyleBordered;
    
    NSArray *items = self.toolbar.items;
    
    UIBarButtonItem *rewindButton = [items objectAtIndex:0];
    UIBarButtonItem *fastForwardButton = [items objectAtIndex:2];
    UIBarButtonItem *spaceLine = [items objectAtIndex:3];
    UIBarButtonItem *volumeButton = [items objectAtIndex:4];
    
    NSArray *newItems = [NSArray arrayWithObjects:rewindButton, playButton, fastForwardButton, spaceLine,volumeButton,  nil];
    
    [self.toolbar setItems:newItems animated:NO];
}

-(void)changePlayButtonToPause
{
    //change play button to pause
    UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause)];
    
    pauseButton.style = UIBarButtonItemStyleBordered;
    
    NSArray *items = self.toolbar.items;
    
    UIBarButtonItem *rewindButton = [items objectAtIndex:0];
    UIBarButtonItem *fastForwardButton = [items objectAtIndex:2];
    UIBarButtonItem *spaceLine = [items objectAtIndex:3];
    UIBarButtonItem *volumeButton = [items objectAtIndex:4];
    
    NSArray *newItems = [NSArray arrayWithObjects:rewindButton, pauseButton, fastForwardButton, spaceLine,volumeButton,  nil];
    
    [self.toolbar setItems:newItems animated:NO];
}

-(void)stopVideo
{
    //change tool bar pause button to play
    [self changePauseButtonToPlay];
    
    //stop video
    [avPlayer stop];
    
    //reset video current time to 0
    [avPlayer setCurrentPlaybackTime:0.0f];
    
    //change slider value to 0
    self.timeLineSlider.value = 0.0f;
    
    //stop timer
    [updateTimer invalidate];
    updateTimer = nil;
}

-(void)avPlayerFinish
{
    
    [self stopVideo];
    
    //remove notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self dismissModalViewControllerAnimated:YES];
}


-(void)scaleVideo
{
    if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
    {
         NSLog(@"device orientation: UIDeviceOrientationLandscape");
    }
    else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait)
    {
        NSLog(@"device orientation: UIDeviceOrientationPortrait");
    }
    else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        NSLog(@"device orientation: UIDeviceOrientationPortraitUpsideDown");
    }
   
    
    if(isScaled)
    {
        //scale video layer to original size
        CGRect newRect = videoLayerRect;
        
        //if device in landscape
        if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight || lastDeviceOrientation == UIDeviceOrientationLandscapeLeft || lastDeviceOrientation == UIDeviceOrientationLandscapeRight)
        {
            
            
            //newRect.origin.x = 480/2 - videoLayerRect.size.width/2;
            newRect.origin.x = 0;
            //newRect.origin.y = 0;
            newRect.origin.y = 0;
            //newRect.size.width = videoLayerRect.size.width;
            newRect.size.width = self.view.bounds.size.width;
            //newRect.size.height = 300;
            newRect.size.height = self.view.bounds.size.height -20;
            
        }
        
        self.videoLayerView.frame = newRect;
        
        avPlayer.view.frame = CGRectMake(0, 0, self.videoLayerView.frame.size.width, self.videoLayerView.frame.size.height);
        
        //show status bar
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        CGRect rect = [UIScreen mainScreen].applicationFrame;
        self.view.frame = rect;
        [self.view setNeedsLayout];
         
        
        isScaled = NO;
    }
    else
    {
        //scale video layer to double size
        //CGRect videoFrame = self.videoLayerView.frame;
        
        //CGPoint center = CGPointMake(self.view.bounds.size.width/2, (self.view.bounds.size.height+20)/2);
        
        //CGFloat newWidth = videoFrame.size.width * kVideoScale;
        CGFloat newWidth = self.view.bounds.size.width * kVideoScale;
        //CGFloat newHeight = videoFrame.size.height * kVideoScale;
        CGFloat newHeight = (self.view.bounds.size.height+20) * kVideoScale;
        
        //CGFloat newX = center.x - newWidth / 2;
        CGFloat newX = -((newWidth - self.view.bounds.size.width) / 2);
        //CGFloat newY = center.y - newHeight / 2;
        CGFloat newY = -((newHeight - self.view.bounds.size.height) / 2);
        
        //if device in landscape
        if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight || lastDeviceOrientation == UIDeviceOrientationLandscapeLeft || lastDeviceOrientation == UIDeviceOrientationLandscapeRight)
        {
            //center = CGPointMake(480/2, 320/2);
            
            newWidth = 480 * kVideoScale;
            newHeight = 320 * kVideoScale;
            
            newX = -((newWidth - 480) / 2);
            newY = -((newHeight - 320) / 2);
        }
        


        
        self.videoLayerView.frame = CGRectMake(newX, newY, newWidth, newHeight); 
        
        avPlayer.view.frame = CGRectMake(0, 0, self.videoLayerView.frame.size.width, self.videoLayerView.frame.size.height);
        
        //hide status bar
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        CGRect rect = [UIScreen mainScreen].applicationFrame;
        self.view.frame = rect;
        [self.view setNeedsLayout];
        
        
        isScaled = YES;
    }
    
    

}

-(void)performUIAction
{
    if(isFadingUI)
    {
        return;
    }
    
    if(isUIVisible)
    {
        //make it invisible
        [self fadeOutUI];
    }
    else
    {
        //make it visible
        [self fadeInUI];
        
    }
    
    isUIVisible = !isUIVisible;
    isFadingUI = YES;
}

-(void)fadeOutUI
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kFadeOutUIDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didFadeOutUI)];
    
    self.navBar.alpha = 0.0f;
    self.timelineBackgroundView.alpha = 0.0f;
    self.toolbar.alpha = 0.0f;
    
    [UIView commitAnimations];
}

-(void)didFadeOutUI
{
    isFadingUI = NO;
}

-(void)fadeInUI
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kFadeInUIDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didFadeInUI)];
    
    self.navBar.alpha = 1.0f;
    self.timelineBackgroundView.alpha = 1.0f;
    self.toolbar.alpha = 1.0f;
    
    [UIView commitAnimations];
}

-(void)didFadeInUI
{
    isFadingUI = NO;
}

//input seconds return hh:mm:ss string
//most is hours
-(NSString *)secondsToString:(float)totalSeconds
{
    int totalSec = totalSeconds;
    
    int seconds = totalSec % 60;
    int minutes = (totalSec / 60) % 60;
    int hours = totalSec / 3600;
    
    NSMutableString * currentTimeStr = [[NSMutableString alloc] init];
    
    if(hours)
    {
        [currentTimeStr appendFormat:@"%i:", hours];
    }
    
    if(minutes)
    {
        [currentTimeStr appendFormat:@"%i:", minutes];
    }
    
    if(seconds)
    {
        [currentTimeStr appendFormat:@"%i", seconds];
    }
    else
    {
        [currentTimeStr appendString:@"0"];
    }
    
    return currentTimeStr;
}

@end
