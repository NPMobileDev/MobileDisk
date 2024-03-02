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
#import "MobileDiskAppDelegate.h"



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
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;//add 9/4/2012

-(void)beginPlayVideo;//add 9/4/2012
-(void)updateSubtitle;//add 9/4/2012
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
-(void)CustomizedTimelineSlider;
-(void)performUIAction;
-(void)fadeOutUI;
-(void)fadeInUI;
-(void)createGestureForView:(UIView *)view;

@end

@implementation MDAVPlayerController{
    
    __block MPMoviePlayerController *avPlayer;
    
    //timer for update timeline slider and labels
    NSTimer *updateTimer;
    
    //indicate that if can update for timeline slider and labels
    BOOL canUpdateTimeline;
    
    BOOL isUIVisible;
    
    BOOL isFadingUI;
    
    BOOL isScaled;
    
    //used to remember video layer rect in Portrait
    CGRect videoLayerRect;
    
    UIDeviceOrientation lastDeviceOrientation;
    
    __block MDSrtSubtitle *srtSubtitle;//add 9/4/2012
    
    MDSrtSubtitleInfo *currentSubtitle;//add 9/4/2012
    
    //only true if subtitle finish processing
    BOOL subtitleReady;//add 9/4/2012
    //only true if video finish processing
    BOOL videoReady;//add 9/4/2012
    
    UIColor *subtitleColor;//add 9/4/2012
    
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
@synthesize loadingIndicator = _loadingIndicator;
@synthesize subtitleLabel = _subtitleLabel;

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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:sysApplicationEnterForeground object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.subtitleLabel.text = nil;//add 9/4/2012
    subtitleReady = NO;//add 9/24/2012
    videoReady = NO;//add 9/24/2012
    
    //*********************************init srt subtitle*****************************//
    //add 9/4/2012
    CGFloat red = [[NSUserDefaults standardUserDefaults] floatForKey:sysSubtitleRedColor];
    CGFloat green = [[NSUserDefaults standardUserDefaults] floatForKey:sysSubtitleGreenColor];
    CGFloat blue = [[NSUserDefaults standardUserDefaults] floatForKey:sysSubtitleBlueColor];
    
    subtitleColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    
    self.subtitleLabel.textColor = subtitleColor;
    
    BOOL subtitleEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:sysVideoPlayerSubtitle];
    
    if(subtitleEnabled)
    {
        NSString *subtitleFilePath = [[self.avFileURL path] stringByDeletingPathExtension];
        subtitleFilePath = [subtitleFilePath stringByAppendingString:@".srt"];
        
        //if srt subtitle file exist at path
        if([[NSFileManager defaultManager] fileExistsAtPath:subtitleFilePath])
        {
            srtSubtitle = [[MDSrtSubtitle alloc] initWithSrtSubtitleFile:subtitleFilePath withDelegate:self];
            
            if(srtSubtitle != nil)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    
                    [srtSubtitle paserSrtSubtitle];
                });
            }

        }
        else
        {
            NSLog(@"srt sub title file dose not exist");
            srtSubtitle = nil;
        }
    }
    else
    {
        srtSubtitle = nil;
    }
    //*********************************init srt subtitle*****************************//
    
    //run in another thread so controller will present early 9/4/2012
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
    
        //create player
        avPlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.avFileURL];
        
        //set style and scaling mode
        avPlayer.controlStyle = MPMovieControlStyleNone;
        avPlayer.scalingMode = MPMovieScalingModeAspectFit;
        avPlayer.movieSourceType = MPMovieSourceTypeFile;
        
        [avPlayer prepareToPlay];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            //remember video layer rect in Portrait
            videoLayerRect = self.videoLayerView.frame;
            
            //set video view's width and height equal to videoLayerView
            avPlayer.view.frame = CGRectMake(0, 0, self.videoLayerView.bounds.size.width, self.videoLayerView.bounds.size.height);
            
            //add video view to controller's view
            [self.videoLayerView addSubview:avPlayer.view];
            
            
            //**9/20/2012 4inch**//
            //if present video controller in landscape, reposition
            if(UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
            {
                CGRect newRect;
                CGRect screenBounds = [UIScreen mainScreen].bounds;
                
                newRect.origin.x = 0;
                newRect.origin.y = 0;

                newRect.size.width = screenBounds.size.height;
                newRect.size.height = screenBounds.size.width-20;
                
                
                self.videoLayerView.frame = newRect;
                avPlayer.view.frame = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
            }

            
        });
        
        NSLog(@"avplayer ready");
    });
    /*
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
     */
    
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
    [self CustomizedTimelineSlider];
    
    //make sure videoLayerView is at back
    [self.view sendSubviewToBack:self.videoLayerView];
    
    //bring ui to top
    [self.view bringSubviewToFront:self.gestureReceiverView];
    [self.view bringSubviewToFront:self.navBar];
    [self.view bringSubviewToFront:self.timelineBackgroundView];
    [self.view bringSubviewToFront:self.toolbar];
    

    
    //register a notification for playback finish
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    //register a notification for playback content loaded
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerDidLoadContent:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    //register a notification for playback video duration is available
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerDurationAvailable:) name:MPMovieDurationAvailableNotification object:nil];
    
    //register a notification for playback when enter background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    //register a notification for playback when  enter foreground
    //this notification will be posted from ApplicationDelegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerEnterForeground:) name:sysApplicationEnterForeground object:nil];
    
    self.currentTimeLabel.text = @"0";
    self.timeLeftLabel.text = @"-0";
    self.timeLineSlider.value = 0.0f;
    
    canUpdateTimeline = YES;
    isUIVisible = YES;
    isFadingUI = NO;
    isScaled = NO;
    
    
    self.loadingIndicator.hidden = NO;
    [self.videoLayerView bringSubviewToFront:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
    
    
    //dont sleep
    [MobileDiskAppDelegate disableIdleTime];
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

//**9/20/2012 4inch**//
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //**9/20/2012 4inch**//
    
    lastDeviceOrientation = toInterfaceOrientation;
    
    if(toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown)
    {
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGRect newRect;
            CGRect screenBounds = [UIScreen mainScreen].bounds;
                
            //newRect.origin.x = 480/2 - self.videoLayerView.frame.size.width/2;
            newRect.origin.x = 0;
            newRect.origin.y = 0;
            //newRect.size.width = self.videoLayerView.frame.size.width;
            //newRect.size.height = self.videoLayerView.frame.size.height;
            //newRect.size.width = 480;
            //newRect.size.height = 300;
            //newRect.size.height = 300;
            newRect.size.width = screenBounds.size.height;
            newRect.size.height = screenBounds.size.width-20;

            
            //if video is been scaled
            if(isScaled)
            {
                //newRect.origin.x = 480/2 - self.videoLayerView.frame.size.width/2;
                //float scaledHeight = 480 * kVideoScale;
                float scaledHeight = screenBounds.size.height * kVideoScale;
                newRect.origin.x = -((scaledHeight - screenBounds.size.height) / 2);
                //newRect.origin.x = -((scaledHeight - 480) / 2);
                //newRect.origin.y = 300/2 - self.videoLayerView.frame.size.height/2;
                //float scaledWidth = 320 * kVideoScale;
                float scaledWidth = screenBounds.size.width * kVideoScale;
                newRect.origin.y = -((scaledWidth - screenBounds.size.width) / 2);
                //newRect.origin.y = -((scaledWidth - 320) / 2);
                //newRect.size = self.videoLayerView.frame.size;
                //float sizeWidth = 480 * kVideoScale;
                //float sizeHeight = 320 * kVideoScale;
                float sizeWidth = screenBounds.size.height * kVideoScale;
                float sizeHeight = screenBounds.size.width * kVideoScale;
                newRect.size = CGSizeMake(sizeWidth, sizeHeight);
                
            }
            
            
            self.videoLayerView.frame = newRect;
            avPlayer.view.frame = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
            
        }
        
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait)
        {
            CGRect newRect = videoLayerRect;
            CGRect screenBounds = [UIScreen mainScreen].bounds;
            
            //if video is been scaled
            if(isScaled)
            {
                //newRect.origin.x = 320/2 - self.videoLayerView.frame.size.width/2;
                //float scaledWidth = 320 * kVideoScale;
                float scaledWidth = screenBounds.size.width * kVideoScale;
                newRect.origin.x = -((scaledWidth - screenBounds.size.width) / 2);
                //newRect.origin.x = -((scaledWidth - 320) / 2);
                //newRect.origin.y = 460/2 - self.videoLayerView.frame.size.height/2;
                //float scaledHeight = 480 * kVideoScale;
                float scaledHeight = screenBounds.size.height * kVideoScale;
                newRect.origin.y = -((scaledHeight - screenBounds.size.height) / 2);
                //newRect.origin.y = -((scaledHeight - 480) / 2);
                //newRect.size = self.videoLayerView.frame.size;
                //float sizeWidth = 320 * kVideoScale;
                //float sizeHeight = 480 * kVideoScale;
                float sizeWidth = screenBounds.size.width * kVideoScale;
                float sizeHeight = screenBounds.size.height * kVideoScale;
                newRect.size = CGSizeMake(sizeWidth, sizeHeight);
            }
            
            self.videoLayerView.frame = newRect;
            avPlayer.view.frame = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
        }
        
    }
}

#pragma mark - begin play check 9/4/2012
-(void)beginPlayVideo
{
    //if user disable subtitle
    if(srtSubtitle == nil)
    {
        if(videoReady)
        {

            [self play];
            [self performUIAction];
            
            return;
        }
    }
    
    if(subtitleReady && videoReady)
    {
        
        [self play];
        [self performUIAction];
    }
}

#pragma mark - MDSrtSubtitle delegate 9/4/2012
-(void)MDSrtSubtitlePaserSubtitleFinished
{
    subtitleReady = YES;
    [self beginPlayVideo];
}


#pragma mark - video player enter background/foreground notification
-(void)videoPlayerEnterBackground:(NSNotification*)notification
{
    [self pause];
}

-(void)videoPlayerEnterForeground:(NSNotification*)notification
{
    /*
    if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || lastDeviceOrientation == UIDeviceOrientationPortrait)
    {
        self.videoLayerView.frame = videoLayerRect;
    }
    else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight || lastDeviceOrientation == UIDeviceOrientationLandscapeLeft || lastDeviceOrientation == UIDeviceOrientationLandscapeRight)
    {
        
    }*/
    
    [self willRotateToInterfaceOrientation:[UIDevice currentDevice].orientation duration:0];
    
    avPlayer.view.frame = self.videoLayerView.bounds;
    [self.videoLayerView addSubview:avPlayer.view];
    [self play];
}

#pragma mark - notification video duration
-(void)videoPlayerDurationAvailable:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieDurationAvailableNotification object:nil];
    
    self.timeLineSlider.maximumValue = round(avPlayer.duration);
    self.timeLeftLabel.text = [@"-" stringByAppendingString:[self secondsToString:self.timeLineSlider.maximumValue]];
}

#pragma mark - notification video load content
/**modify 9/4/2012**/
-(void)videoPlayerDidLoadContent:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    self.timeLineSlider.minimumValue = 0.0f;
    self.timeLineSlider.maximumValue = round(avPlayer.duration);
    self.timeLineSlider.value = 0.0f;
    
    self.timeLeftLabel.text = [@"-" stringByAppendingString:[self secondsToString:self.timeLineSlider.maximumValue]];
    self.currentTimeLabel.text = [self secondsToString:0.0f];
    
    //play video when content loaded
    //[self play];
    videoReady = YES;
    [self beginPlayVideo];
     
}

#pragma mark - video control
-(void)play
{
    NSLog(@"avplayer play video");
    
    [self changePlayButtonToPause];

    //[avPlayer prepareToPlay];
    [avPlayer play];
    
    //create a update timer if needed
    if(updateTimer == nil)
    {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTimeline) userInfo:nil repeats:YES];
        
        //this way can make sure timer can perform it's selector without been blocked
        [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    }
    
    //start timer
    [updateTimer fire];
    
    //add 9/4/2012
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.hidden = YES;
     
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

#pragma mark - Time line labels update
-(void)updateTimeline
{
    if(canUpdateTimeline)
    {
        if(self.timeLineSlider.value != round(avPlayer.currentPlaybackTime))
        {
            self.timeLineSlider.value = round(avPlayer.currentPlaybackTime);
            [self updateTimeLabels];
        }

        [self updateSubtitle];//add 9/4/2012
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

#pragma mark - Subtitle update 9/4/2012
-(void)updateSubtitle
{
    
    if(srtSubtitle ==nil)
        return;
    
    NSUInteger playbackTime = round(avPlayer.currentPlaybackTime);
    BOOL shouldUpdateUI = NO;

    
    if(currentSubtitle != nil)
    {
        if(playbackTime > currentSubtitle.subtitleEndTime || playbackTime < currentSubtitle.subtitleStartTime)
        {
            self.subtitleLabel.text = nil;
            
            //have to update subtitle
            currentSubtitle = [srtSubtitle querySubtitleByTime:playbackTime];
            
            //update subtitle ui
            shouldUpdateUI = YES;
        }
    }
    else
    {
        currentSubtitle = [srtSubtitle querySubtitleByTime:playbackTime];
        
        if(currentSubtitle != nil)
        {
            self.subtitleLabel.text = nil;
            
            //update subtitle ui
            shouldUpdateUI = YES;
        }

    }
    
    if(shouldUpdateUI && currentSubtitle != nil)
    {
        NSLog(@"subtitle index:%i", currentSubtitle.subtitleIndex);
        NSLog(@"subtitle content:%@", currentSubtitle.subtitleContent);
        NSLog(@"subtitle characters:%i",[currentSubtitle.subtitleContent length]);
        NSLog(@"subtitle sentence:%i", currentSubtitle.subtitleSentences);
        NSLog(@"\n\n");
        
        /**adjust subtitle label frame 9/4/2012**/
        NSUInteger characters = [currentSubtitle.subtitleContent length];
        CGFloat characterSize = self.subtitleLabel.font.pointSize;
        
        float stringlong = characters *characterSize;
        int height = stringlong/self.subtitleLabel.frame.size.width;
        
        if(height == 0)
        {
            CGRect frame = self.subtitleLabel.frame;
            frame.size.height = self.subtitleLabel.font.pointSize;
            if(!isScaled)
            {
                frame.origin.y = (self.videoLayerView.frame.origin.y+self.videoLayerView.frame.size.height-self.toolbar.frame.size.height)-frame.size.height;
            }

            
            self.subtitleLabel.frame = frame;
        }
        else
        {
            CGRect frame = self.subtitleLabel.frame;
            
            if(((int)stringlong % (int)self.subtitleLabel.frame.size.width)!=0)
            {
                height++;
                
                frame.size.height = height*self.subtitleLabel.font.pointSize;
                if(!isScaled)
                {
                    frame.origin.y = (self.videoLayerView.frame.origin.y+self.videoLayerView.frame.size.height-self.toolbar.frame.size.height)-frame.size.height;
                }
            }
            else
            {

                frame.size.height = height*self.subtitleLabel.font.pointSize;
                if(!isScaled)
                {
                    frame.origin.y = (self.videoLayerView.frame.origin.y+self.videoLayerView.frame.size.height-self.toolbar.frame.size.height)-frame.size.height;
                }
            }

            self.subtitleLabel.frame = frame;
        }
        /**adjust subtitle label frame 9/4/2012**/ 
        
        /*
        //update subtitle ui
        if(currentSubtitle.subtitleSentences > 1)
        {
            self.subtitleLabel.textAlignment = UITextAlignmentLeft;
        }
        else
        {
            self.subtitleLabel.textAlignment = UITextAlignmentCenter;
        }
         */
        self.subtitleLabel.textAlignment = UITextAlignmentCenter;
        
        self.subtitleLabel.text = currentSubtitle.subtitleContent;
    }
}

#pragma mark - Timeline slider event
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
        //reset current time for movie player
        [avPlayer setCurrentPlaybackTime:self.timeLineSlider.value];
    }
    
    //update labels
    [self updateTimeLabels];
    
    //update subtitle 9/4/2012
    [self updateSubtitle];
    
    //resume update
    canUpdateTimeline = YES;
}

#pragma mark - create gesture receiver view
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

#pragma mark - create volume slider
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
    
    //set volume slider's thumb image for normal and heightlighted
    for(UIView *aView in [volumeView subviews])
    {
        if([[[aView class] description] isEqualToString:@"MPVolumeSlider"])
        {
            UISlider *volumeSlider = (UISlider*)aView;
            
            [volumeSlider setThumbImage:[UIImage imageNamed:@"SoundVolumeThumb"] forState:UIControlStateNormal];
            
            [volumeSlider setThumbImage:[UIImage imageNamed:@"SoundVolumeThumbHeightlight"] forState:UIControlStateHighlighted];
        }
    }
    
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

#pragma mark - customized timeline slider
-(void)CustomizedTimelineSlider
{
    UIImage *leftTrack = [[UIImage imageNamed:@"SliderTrackLeft"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    
    [self.timeLineSlider setMinimumTrackImage:leftTrack forState:UIControlStateNormal];
    
    UIImage *rightTrack = [[UIImage imageNamed:@"SliderTrackRight"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    
    [self.timeLineSlider setMaximumTrackImage:rightTrack forState:UIControlStateNormal];
    
    [self.timeLineSlider setThumbImage:[UIImage imageNamed:@"VideoThumb"] forState:UIControlStateNormal];
    
    [self.timeLineSlider setThumbImage:[UIImage imageNamed:@"VideoThumbHeightlight"] forState:UIControlStateHighlighted];
}

#pragma mark - customized UI
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

#pragma mark - change toolbar play/pause button
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

#pragma mark - video methods
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
    
    //can sleep
    [MobileDiskAppDelegate enableIdleTime];
    
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
            //**9/20/2012 4inch**//
            //center = CGPointMake(480/2, 320/2);
            CGRect screenBounds = [UIScreen mainScreen].bounds;
            
            /*
            newWidth = 480 * kVideoScale;
            newHeight = 320 * kVideoScale;
            
            newX = -((newWidth - 480) / 2);
            newY = -((newHeight - 320) / 2);
             */
            newWidth = screenBounds.size.height * kVideoScale;
            newHeight = screenBounds.size.width * kVideoScale;
            
            newX = -((newWidth - screenBounds.size.height) / 2);
            newY = -((newHeight - screenBounds.size.width) / 2);
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

#pragma mark - UI animation
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
