//
//  MDSrtSubtitleInfo.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/9/4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//**********//
//class for holding info about a single srt subtitle
//add 9/4/2012
//**********//

#import <Foundation/Foundation.h>

@interface MDSrtSubtitleInfo : NSObject

@property (nonatomic, assign) NSUInteger subtitleIndex;
@property (nonatomic, assign) NSUInteger subtitleStartTime;
@property (nonatomic, assign) NSUInteger subtitleEndTime;
@property (nonatomic, assign) NSUInteger subtitleSentences;
@property (nonatomic, copy) NSString *subtitleContent;

@end
