//
//  MDMusicPlayerController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDMusicPlayerController.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVMetadataItem.h>


@interface MDMusicPlayerController ()

@property (nonatomic, weak) IBOutlet UISlider *timeLineSlider;
@property (nonatomic, weak) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *musicImageView;
@property (nonatomic, weak) IBOutlet UILabel *albumNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UITextView *lyricsTextView;


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
-(IBAction)volumeSliderChange:(id)sender;

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
    
}

@synthesize musicFileURL = _musicFileURL;
@synthesize timeLineSlider =_timeLineSlider;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize timeLeftLabel = _timeLeftLabel;
@synthesize toolbar = _toolbar;
@synthesize titleLabel = _titleLabel;
@synthesize musicImageView = _musicImageView;
@synthesize albumNameLabel =_albumNameLabel;
@synthesize authorLabel = _authorLabel;
@synthesize artistLabel = _artistLabel;
@synthesize lyricsTextView = _lyricsTextView;


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
    
    [self play];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.titleLabel.text = [self.musicFileURL lastPathComponent];
    
    //find info for music
    [self findMusicInfoWithMusicPath:self.musicFileURL];
    
    //half alpha for music image
    self.musicImageView.alpha = 0.3f;
    self.musicImageView.image = musicArtwork;
    
    self.lyricsTextView.backgroundColor = [UIColor clearColor];
    
    self.albumNameLabel.text = musicAlbumName;
    self.authorLabel.text = musicAuthor;
    self.artistLabel.text = musicArtist;
    self.lyricsTextView.text = musiclyrics;
    
    //create music player
    musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicFileURL error:nil];
    musicPlayer.delegate = self;
    
    [musicPlayer prepareToPlay];
    
    //set play button for action
    UIBarButtonItem *playButton = [self.toolbar.items objectAtIndex:1];
    playButton.target =self;
    playButton.action = @selector(play);
    
    
    [self createVolumeSlider];
    
    
    self.timeLineSlider.minimumValue = 0.0f;
    self.timeLineSlider.maximumValue = round(musicPlayer.duration);
    self.timeLineSlider.value = 0.0f;
    
    self.timeLeftLabel.text = [@"-" stringByAppendingString:[self secondsToString:self.timeLineSlider.maximumValue]];
    self.currentTimeLabel.text = [self secondsToString:0.0f];
    
    canUpdateTimeline = YES; 
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

-(void)createVolumeSlider
{
    //the rect need to design tool to measure
    UISlider *volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 158, 23)];
    volumeSlider.minimumValue = 0.0f;
    volumeSlider.maximumValue = 1.0f;
    
    /* this only can be used on real device it get back ipod volume
    MPMusicPlayerController *ipod = [MPMusicPlayerController iPodMusicPlayer];
    if(ipod != nil)
    {
         volumeSlider.value = ipod.volume;
         [musicPlayer setVolume:ipod.volume];
    }
    else
    {
        volumeSlider.value = 0.5f;
        [musicPlayer setVolume:ipod.volume];
    }
     */
    
    //test 
    volumeSlider.value = 0.5f;
    musicPlayer.volume = 0.5f;
    
    [volumeSlider addTarget:self action:@selector(volumeSliderChange:) forControlEvents:UIControlEventValueChanged];
    
    //create bar button with silder inside
    UIBarButtonItem *volumeButton = [[UIBarButtonItem alloc] initWithCustomView:volumeSlider];
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
            else
            {
                //give default image
            }
            
        }
    }
}

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
    [musicPlayer play];
    
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
    //change tool bar pause button to play
    [self changePauseButtonToPlay];
    
    //pause music
    [musicPlayer pause];
    
    //stop timer
    [updateTimer invalidate];
    updateTimer = nil;
    
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

-(void)updateTimeline
{
    if(canUpdateTimeline)
    {
        self.timeLineSlider.value = round(musicPlayer.currentTime);
        
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

-(IBAction)doneListening:(id)sender
{
    [self stopMusic];
    
    musicPlayer = nil;
    
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

-(IBAction)volumeSliderChange:(id)sender
{
    UISlider *slider = sender;
    musicPlayer.volume = slider.value;
}

#pragma mark - AVAudioPlayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self doneListening:nil];
}

@end
