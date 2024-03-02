//
//  MDSrtSubtitleInfo.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/9/4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//**********//
//class for holding info about a single srt subtitle
//add 9/4/2012
//**********//

#import "MDSrtSubtitleInfo.h"

@implementation MDSrtSubtitleInfo

@synthesize subtitleIndex = _subtitleIndex;
@synthesize subtitleStartTime = _subtitleStartTime;
@synthesize subtitleEndTime = _subtitleEndTime;
@synthesize subtitleContent = _subtitleContent;
@synthesize subtitleSentences = _subtitleSentences;


-(void)dealloc
{
    //NSLog(@"subtitle info dellocate");
}

@end
