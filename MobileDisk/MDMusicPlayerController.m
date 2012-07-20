//
//  MDMusicPlayerController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDMusicPlayerController.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVMetadataItem.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MPVolumeView.h>
#import "MobileDiskAppDelegate.h"


@interface MDMusicPlayerController ()

@property (nonatomic, weak) IBOutlet UISlider *timeLineSlider;
@property (nonatomic, weak) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIImageView *musicImageView;
@property (nonatomic, weak) IBOutlet UIImageView *musicReflectionImageView;
@property (nonatomic, weak) IBOutlet UIView *gestureView;
@property (nonatomic, weak) IBOutlet UILabel *albumNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UITextView *lyricsTextView;
@property (nonatomic, weak) IBOutlet UIView *lyricsBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *timelineView;
@property (nonatomic, weak) IBOutlet UIView *timelineBackgroundView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;


-(IBAction)rewind:(id)sender;
-(IBAction)fastForward:(id)sender;
-(void)play;
-(void)pause;
-(void)stopMusic;
-(NSString *)secondsToString:(float)totalSeconds;
-(IBAction)doneListening:(id)sender;
-(void)updateTimeline;
-(void)updateTimeLabels;
-(void)changePauseButtonToPlay;
-(void)changePlayButtonToPause;
-(void)findMusicInfoWithMusicPath:(NSURL *)musicPath;
-(void)customizedNavigationBar;
-(void)CustomizedTimelineSlider;
-(void)hideTimelineAndLyrics;
-(void)showTimelineAndLyrics;
-(void)createGesture;
-(UIImage *)reflectionImage:(UIImage *)image WithSize:(CGSize)theSize;

@end

@implementation MDMusicPlayerController{
    
    //music player
    AVAudioPlayer *musicPlayer;
    
    //timer for update timeline slider and labels
    NSTimer *updateTimer;
    
    //indicate that if can update for timeline slider and labels
    BOOL canUpdateTimeline;
    
    /**music information**/
    NSString *musiclyrics;
    NSString *musicTitle;
    NSString *musicAuthor;
    NSString *musicPublisher;
    NSString *musicType;
    NSString *musicAlbumName;
    NSString *musicArtist;
    //should we preserved image data?
    UIImage *musicArtwork;
    
    BOOL wasEnterBackground;
    
}

@synthesize musicFileURL = _musicFileURL;
@synthesize timeLineSlider =_timeLineSlider;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize timeLeftLabel = _timeLeftLabel;
@synthesize toolbar = _toolbar;
@synthesize musicImageView = _musicImageView;
@synthesize musicReflectionImageView = _musicReflectionImageView;
@synthesize gestureView = _gestureView;
@synthesize albumNameLabel =_albumNameLabel;
@synthesize titleLabel = _titleLabel;
@synthesize artistLabel = _artistLabel;
@synthesize lyricsTextView = _lyricsTextView;
@synthesize lyricsBackgroundView = _lyricsBackgroundView;
@synthesize timelineView = _timelineView;
@synthesize timelineBackgroundView = _timelineBackgroundView;
@synthesize navBar = _navBar;


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
    
    if(!wasEnterBackground)
    {
        [self play];
    }
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
    
    //create music player
    musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicFileURL error:nil];
    musicPlayer.delegate = self;
    
    [musicPlayer prepareToPlay];
    
    [self customizedNavigationBar];
    
    //find info for music
    [self findMusicInfoWithMusicPath:self.musicFileURL];
    
    //half alpha for music image
    //self.musicImageView.alpha = 0.65f;
    self.musicImageView.image = musicArtwork;
    CGSize reflectionSize = CGSizeMake(self.musicImageView.bounds.size.width, self.musicImageView.bounds.size.height*0.65f);
    self.musicReflectionImageView.image = [self reflectionImage:self.musicImageView.image WithSize:reflectionSize];
    self.musicReflectionImageView.alpha = 0.90f;
    
    //self.lyricsTextView.alpha = 0.65f;
    self.lyricsTextView.backgroundColor = [UIColor clearColor];
    
    if(musicArtist)
    {
        self.artistLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Artist: %@", @"Artist: %@"), musicArtist];
    }
    else
    {
        self.artistLabel.text = NSLocalizedString(@"Artist: Unknow", @"Artist: Unknow");
    }
    
    if(musicTitle)
    {
        self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Title: %@", @"Title: %@"), musicTitle];
    }
    else
    {
        self.titleLabel.text = NSLocalizedString(@"Title: Unknow", @"Title: Unknow");
    }
    
    if(musicAlbumName)
    {
        self.albumNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Album: %@", @"Album: %@"), musicAlbumName];
    }
    else
    {
        self.albumNameLabel.text = NSLocalizedString(@"Album: Unknow", @"Album: Unknow");
    }
    
    
    if(musiclyrics == nil)
    {
        self.lyricsBackgroundView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.lyricsTextView.text = musiclyrics;
    }

    
    //self.timelineBackgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.timelineBackgroundView.layer.borderWidth = 1.0f;
    
    //set play button for action
    UIBarButtonItem *playButton = [self.toolbar.items objectAtIndex:1];
    playButton.target =self;
    playButton.action = @selector(play);
    
    
    [self createGesture];
    
    [self createVolumeSlider];
    
    [self CustomizedTimelineSlider];
    
    
    self.timeLineSlider.minimumValue = 0.0f;
    self.timeLineSlider.maximumValue = round(musicPlayer.duration);
    self.timeLineSlider.value = 0.0f;
    
    self.timeLeftLabel.text = [@"-" stringByAppendingString:[self secondsToString:self.timeLineSlider.maximumValue]];
    self.currentTimeLabel.text = [self secondsToString:0.0f];
    
    //register a notification for avaudioplayer when enter background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayerEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    //register a notification for avaudioplayer when  enter foreground
    //this notification will be posted from ApplicationDelegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayerEnterForeground:) name:sysApplicationEnterForeground object:nil];
    
    canUpdateTimeline = YES;
    
    wasEnterBackground= NO;
    
    //dont sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;

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

#pragma mark - music player enter background/foreground notification
-(void)musicPlayerEnterBackground:(NSNotification*)notification
{
    wasEnterBackground = YES;
    
    [self pause];
}

-(void)musicPlayerEnterForeground:(NSNotification*)notification
{
    wasEnterBackground = NO;
    
    [self play];
}

#pragma mark - AVAudioPlayer delegate
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    [self play];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSString *msg = NSLocalizedString(@"There is an error while decoding the audio", @"There is an error while decoding the audio");
    
    UIAlertView *decodeErrorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [decodeErrorAlert show];
}

#pragma mark - reflection image
-(UIImage *)reflectionImage:(UIImage *)image WithSize:(CGSize)theSize
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (NULL, theSize.width, theSize.height, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
    
    
    CGImageRef gradientMaskImage = createGradientImage(theSize.height);
    
    CGContextClipToMask(bitmapContext, CGRectMake(0.0, 0.0, theSize.width, theSize.height), gradientMaskImage);
    
    CGImageRelease(gradientMaskImage);
    
    CGContextTranslateCTM(bitmapContext, 0.0, theSize.height);
    CGContextScaleCTM(bitmapContext, 1.0, -1.0);
    
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, theSize.width, theSize.height), image.CGImage);
    
    CGImageRef reflectionImage = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease(bitmapContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
    CGImageRelease(reflectionImage);
    
    return theImage;
    
}

CGImageRef createGradientImage(CGFloat theHeight)
{
    CGImageRef theCGImage = NULL;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, 1, theHeight, 8, 0, colorSpace, kCGImageAlphaNone);
    
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    
    CGColorSpaceRelease(colorSpace);
    
    CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, theHeight);
    
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(grayScaleGradient);
    
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    
    CGContextRelease(gradientBitmapContext);
    
    return theCGImage;
}


#pragma mark - Show/Hide Timeline and lyrics
-(void)hideTimelineAndLyrics
{
    self.timelineView.hidden = YES;
    self.timelineBackgroundView.hidden= YES;
    self.lyricsTextView.hidden = YES;
    self.lyricsBackgroundView.hidden = YES;
}

-(void)showTimelineAndLyrics
{
    self.timelineView.hidden = NO;
    self.timelineBackgroundView.hidden= NO;
    self.lyricsTextView.hidden = NO;
    self.lyricsBackgroundView.hidden = NO;
}

#pragma mark - Create control
-(void)createGesture
{
    UITapGestureRecognizer *tapToHideTimelineAndLyrics = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTimelineAndLyrics)];
    
    [self.lyricsTextView addGestureRecognizer:tapToHideTimelineAndLyrics];
    
    UITapGestureRecognizer *tapToShowTimelineAndLyrics = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTimelineAndLyrics)];
    
    [self.gestureView addGestureRecognizer:tapToShowTimelineAndLyrics];
}

-(void)customizedNavigationBar
{
    UINavigationItem *title = [[UINavigationItem alloc] initWithTitle:[self.musicFileURL lastPathComponent]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneListening:)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 21)];
    titleLabel.text = [self.musicFileURL lastPathComponent];
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
}

-(void)createVolumeSlider
{

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

-(void)CustomizedTimelineSlider
{
    UIImage *leftTrack = [[UIImage imageNamed:@"SliderTrackLeft"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    
    [self.timeLineSlider setMinimumTrackImage:leftTrack forState:UIControlStateNormal];
    
    UIImage *rightTrack = [[UIImage imageNamed:@"SliderTrackRight"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    
    [self.timeLineSlider setMaximumTrackImage:rightTrack forState:UIControlStateNormal];
    
    [self.timeLineSlider setThumbImage:[UIImage imageNamed:@"MusicThumb"] forState:UIControlStateNormal];
    
    [self.timeLineSlider setThumbImage:[UIImage imageNamed:@"MusicThumbHeightlight"] forState:UIControlStateHighlighted];
}

#pragma mark - Find music info
-(void)findMusicInfoWithMusicPath:(NSURL *)musicPath
{
    //get asset for music
    AVAsset *musicAsset = [AVAsset assetWithURL:self.musicFileURL];
    
    musiclyrics = musicAsset.lyrics;
    
    NSArray *metaData = musicAsset.commonMetadata;
    NSArray *metaDataItems = [AVMetadataItem metadataItemsFromArray:metaData withKey:nil keySpace:nil];
    
    for(AVMetadataItem *item in metaDataItems)
    {
        if([item.commonKey isEqualToString:@"title"])
        {
            musicTitle = (NSString*)item.value;
        }
        else if([item.commonKey isEqualToString:@"creator"])
        {
            musicAuthor = (NSString*)item.value;
        }
        else if([item.commonKey isEqualToString:@"publisher"])
        {
            musicPublisher = (NSString*)item.value;
        }
        else if([item.commonKey isEqualToString:@"type"])
        {
            musicType = (NSString*)item.value;
        }
        else if([item.commonKey isEqualToString:@"albumName"])
        {
            musicAlbumName = (NSString*)item.value;
        }
        else if([item.commonKey isEqualToString:@"artist"])
        {
            musicArtist = (NSString*)item.value;
        }
        else if([item.commonKey isEqualToString:@"artwork"])
        {
            NSDictionary *dic = (NSDictionary*)item.value;
            NSData *imageData = [dic objectForKey:@"data"];
            
            if(imageData != nil)
            {
                musicArtwork = [UIImage imageWithData:imageData];
            }
            
        }
    }
    
    //if image was nil
    if(musicArtwork == nil)
    {
        musicArtwork = [UIImage imageNamed:@"MusicCover"];
    }
}

#pragma mark - Control
-(void)play
{
    //change tool bar play button to pause
    [self changePlayButtonToPause];
    
    //if music is playing stop first
    if(musicPlayer.playing)
    {
        [musicPlayer stop];
    }
    
    //play music
    [musicPlayer prepareToPlay];
    [musicPlayer play];
    
    //create a update timer if needed
    if(updateTimer == nil)
    {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTimeline) userInfo:nil repeats:YES];
        
        //this way can make sure timer can perform it's selector without been blocked
        [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    }
    
    //start timer
    [updateTimer fire];
    
}

-(void)pause
{
    //change tool bar pause button to play
    [self changePauseButtonToPlay];
    
    //pause music
    [musicPlayer pause];
    
    //stop timer
    [updateTimer invalidate];
    updateTimer = nil;
    
}

-(void)stopMusic
{
    //change tool bar pause button to play
    [self changePauseButtonToPlay];
    
    //stop music
    [musicPlayer stop];
    
    //reset music current time to 0
    [musicPlayer setCurrentTime:0.0f];
    
    //change slider value to 0
    self.timeLineSlider.value = 0.0f;
    
    //stop timer
    [updateTimer invalidate];
    updateTimer = nil;
    
    
}

#pragma mark - Change tool bar control button
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

#pragma mark - Update UI
-(void)updateTimeline
{
    if(canUpdateTimeline)
    {
        if(self.timeLineSlider.value != round(musicPlayer.currentTime))
        {
            self.timeLineSlider.value = round(musicPlayer.currentTime);
            
            [self updateTimeLabels];
        }
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

#pragma mark - Converter
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

#pragma mark IBAction
-(IBAction)doneListening:(id)sender
{
    [self stopMusic];
    
    musicPlayer = nil;
    
    //can go to sleep
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [self dismissModalViewControllerAnimated:YES];
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
        //stop music
        [self stopMusic];
    }
    else
    {
        //reset current time for music player
        [musicPlayer setCurrentTime:self.timeLineSlider.value];
    }
    
    //update labels
    [self updateTimeLabels];
    
    //resume update
    canUpdateTimeline = YES;
}

-(IBAction)rewind:(id)sender
{
    
    [musicPlayer setCurrentTime:musicPlayer.currentTime - kRewindAmount];
    self.timeLineSlider.value = musicPlayer.currentTime;
    
    [self updateTimeLabels];
}

-(IBAction)fastForward:(id)sender
{
    [musicPlayer setCurrentTime:musicPlayer.currentTime + kFastForwardAmount];
    self.timeLineSlider.value = musicPlayer.currentTime;
    
    [self updateTimeLabels];
}

#pragma mark - AVAudioPlayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self doneListening:nil];
}

@end
