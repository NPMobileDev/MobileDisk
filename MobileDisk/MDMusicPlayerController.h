//
//  MDMusicPlayerController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>

#define kRewindAmount 10.0f
#define kFastForwardAmount 10.0f

@interface MDMusicPlayerController : UIViewController<AVAudioPlayerDelegate>

@property (nonatomic, copy) NSURL *musicFileURL;

@end
