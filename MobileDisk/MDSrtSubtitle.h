//
//  MDSrtSubtitle.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/9/4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//******************//
//class for paser srt subtitle
//add 9/4/2012
//******************//

#import <Foundation/Foundation.h>
#import "MDSrtSubtitleInfo.h"

@protocol MDSrtSubtitleDelegate <NSObject>

@optional
-(void)MDSrtSubtitlePaserSubtitleFinished;

@end

@interface MDSrtSubtitle : NSObject

-(id)initWithSrtSubtitleFile:(NSString*)path withDelegate:(id<MDSrtSubtitleDelegate>)theDelegate;
-(void)paserSrtSubtitle;
-(MDSrtSubtitleInfo *)querySubtitleByTime:(NSUInteger)time; 

@end
