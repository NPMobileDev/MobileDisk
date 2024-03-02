//
//  MDSrtSubtitle.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/9/4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//******************//
//class for paser srt subtitle
//add 9/4/2012
//support
//UTF-8 encdoing
//******************//

#import "MDSrtSubtitle.h"

@interface MDSrtSubtitle ()

-(NSUInteger)srtTimeFormateToSecond:(NSString*)timeFormate;

@end

@implementation MDSrtSubtitle{
    
    //point to subtitle file path
    NSString *srtFilePath;
    NSScanner *subtitleScanner;
    NSUInteger currentScanIndex;
    NSMutableArray *subtitleInfos;
    NSMutableArray *encodings;
    
    __weak id<MDSrtSubtitleDelegate> delegate;
    
    //store last subtitle found index
    NSUInteger lastFoundIndex;
    
}

-(id)initWithSrtSubtitleFile:(NSString*)path withDelegate:(id<MDSrtSubtitleDelegate>)theDelegate
{
    if(self = [super init])
    {
        NSError *error;
        
        delegate = theDelegate;
        srtFilePath = path;
        
        [self initEncoding];
        
        NSString *subtitleContent = nil;
        
        for(NSNumber *val in encodings)
        {
            NSUInteger encoding = [val unsignedIntValue];
            
            subtitleContent = [NSString stringWithContentsOfFile:path encoding:encoding error:&error];
            
            if(subtitleContent != nil)
                break;
            
            error = nil;
        }
        
        //NSString *subtitleContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        
        if(subtitleContent == nil || error != nil)
        {
            NSLog(@"loading subtitle content error");
            return nil;
        }
        
        subtitleScanner = [NSScanner scannerWithString:subtitleContent];
        currentScanIndex = 0;
        [subtitleScanner setScanLocation:currentScanIndex];
        [subtitleScanner setCharactersToBeSkipped:nil];
        
        subtitleInfos = [[NSMutableArray alloc] init];
        
        
        //[self paserSrtSubtitle];
        
    }
    
    return self;
}

-(void)initEncoding
{
    encodings = [NSMutableArray arrayWithObjects:
                 [NSNumber numberWithUnsignedInt:NSUTF8StringEncoding],
                 nil];
}

-(void)dealloc
{
    NSLog(@"subtitle paser dellocate");
}

#define kAdvance 2
-(void)paserSrtSubtitle
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
    
    while (![subtitleScanner isAtEnd]) 
    {
        //scan a section
        
        NSString *scannedStr;
        
        if([subtitleScanner scanUpToCharactersFromSet:characterSet intoString:&scannedStr])
        {
            //start to paser a subtitle section
            //NSLog(@"a section");
            
            NSUInteger sectionIndex = currentScanIndex;
            [subtitleScanner setScanLocation:sectionIndex];
            
            //create a info
            MDSrtSubtitleInfo *subInfo = [[MDSrtSubtitleInfo alloc] init];
            
            /**
            line of subtitle index
            **/
            if([subtitleScanner scanUpToCharactersFromSet:characterSet intoString:&scannedStr])
            {
                //NSLog(@"subtitle index: %@", scannedStr);
                
                //subtitle index
                subInfo.subtitleIndex = [scannedStr intValue];
                
            }
            
            //advance location with 2 because of /r/n
            sectionIndex = subtitleScanner.scanLocation+kAdvance;
            [subtitleScanner setScanLocation:sectionIndex];
            
            /**
             line of subtitle duration
             **/
            if([subtitleScanner scanUpToCharactersFromSet:characterSet intoString:&scannedStr])
            {
                //NSLog(@"subtitle duration %@", scannedStr);
                
                //subtitle start and end time
                NSArray *seprateTime = [scannedStr componentsSeparatedByString:@"-->"];
                
                if (seprateTime.count != 2) 
                {
                    NSString *title = NSLocalizedString(@"Load subtitle fail", @"Paser subtitle fail");
                    
                    NSString *msg = NSLocalizedString(@"There is a error while loading subtitle.\n Please, make sure the subtitle is \"SRT\" file format", @"There is a error while loading subtitle.\n Please, make sure the subtitle is \"SRT\" file format");
                    
                    UIAlertView *paserFailAlert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
                    
                    [paserFailAlert show];
                    
                    if(subtitleInfos != nil)
                    {
                        [subtitleInfos removeAllObjects];
                    }
                    
                    return;
                    
                }
                
                NSString *startTimeStr = [seprateTime objectAtIndex:0];
                NSString *endTimeStr = [seprateTime objectAtIndex:1];
                
                NSUInteger subStartTime = [self srtTimeFormateToSecond:startTimeStr];
                NSUInteger subEndTime = [self srtTimeFormateToSecond:endTimeStr];
                
                subInfo.subtitleStartTime = subStartTime;
                subInfo.subtitleEndTime = subEndTime;
                
            }
            
            //advance location with 2 because of /r/n
            sectionIndex = subtitleScanner.scanLocation+kAdvance;
            [subtitleScanner setScanLocation:sectionIndex];
            
            /**
             line of subtitle
             **/
            if([subtitleScanner scanUpToCharactersFromSet:characterSet intoString:&scannedStr])
            {
                NSUInteger sentences = 0;
                NSUInteger subIndex = sectionIndex;
                [subtitleScanner setScanLocation:subIndex];
                
                NSMutableString *subtitleContent = [[NSMutableString alloc] init];
                
                while([subtitleScanner scanUpToCharactersFromSet:characterSet intoString:&scannedStr])
                {
                    
                    //NSLog(@"%s\n", scannedStr);
                    
                    //subtitle content string
                    NSString *subtitle = [scannedStr stringByAppendingString:@" "];
                    [subtitleContent appendString:subtitle];
                    sentences++;
                    
                    if([subtitleScanner isAtEnd])
                        break;
                    
                    //advance location with 2 because of /r/n
                    subIndex = subtitleScanner.scanLocation+kAdvance;
                    [subtitleScanner setScanLocation:subIndex];
                    

                }
                
                subInfo.subtitleSentences = sentences;
                subInfo.subtitleContent = subtitleContent;
            }
            else
            {
                NSLog(@"section has no subtitle content");
            }
            
            [subtitleInfos addObject:subInfo];
        }
        else if([subtitleScanner isAtEnd])
            break;
        else
        {
            [subtitleScanner scanUpToCharactersFromSet:characterSet intoString:&scannedStr];
            currentScanIndex = subtitleScanner.scanLocation+1;
            [subtitleScanner setScanLocation:currentScanIndex];
        }
        
        //go to next line
        //currentScanIndex = subtitleScanner.scanLocation+2;
        //[subtitleScanner setScanLocation:currentScanIndex];
    }
    
    //send message to delegate to inform paser subtitle complete
    if([delegate respondsToSelector:@selector(MDSrtSubtitlePaserSubtitleFinished)])
    {
        [delegate MDSrtSubtitlePaserSubtitleFinished];
    }
    
    NSLog(@"srt subtitle paser end");
}

-(NSUInteger)srtTimeFormateToSecond:(NSString*)timeFormate
{
    NSUInteger second = 0;
    
    NSString *trimedTimeStrs = [[timeFormate componentsSeparatedByString:@","] objectAtIndex:0];
    NSArray *timeStrs = [trimedTimeStrs componentsSeparatedByString:@":"];
    
    NSString *hourStr = [timeStrs objectAtIndex:0];
    NSString *minStr = [timeStrs objectAtIndex:1];
    NSString *secStr = [timeStrs objectAtIndex:2];
    
    second += ([hourStr intValue]*3600);
    second += ([minStr intValue]*60);
    second += [secStr intValue];
    
    return second;
}

-(MDSrtSubtitleInfo *)querySubtitleByTime:(NSUInteger)time
{
    if([subtitleInfos count] == 0)
        return nil;
    /*
    for(MDSrtSubtitleInfo *subInfo in subtitleInfos)
    {
        if(time >= subInfo.subtitleStartTime && time <= subInfo.subtitleEndTime)
        {
            return subInfo;
        }
    }
    */
    
    MDSrtSubtitleInfo *result = nil;
    BOOL performBinarySearch = YES;
    
    //pre-search by checking next sub info
    if((lastFoundIndex+1) <= [subtitleInfos count]-1)
    {
        MDSrtSubtitleInfo *subInfo = [subtitleInfos objectAtIndex:lastFoundIndex+1];
        
        if(time >= subInfo.subtitleStartTime && time <= subInfo.subtitleEndTime)
        {
            result = subInfo;
            performBinarySearch = NO;
        }
    }

    
    if(performBinarySearch)
    {
        /*****
         Binary search for sub info
         ******/
        int left, mid, right = 0;
        
        left = 0;
        right = [subtitleInfos count]-1;
        
        while (result == nil && left <= right) 
        {
            mid = left + (right - left) / 2;
            
            MDSrtSubtitleInfo *subInfo = [subtitleInfos objectAtIndex:mid];
            
            if(time >= subInfo.subtitleStartTime && time <= subInfo.subtitleEndTime)
            {
                result = subInfo;
                break;
            }
            else if(time < subInfo.subtitleStartTime)
            {
                right = mid - 1;
            }
            else if(time > subInfo.subtitleEndTime)
            {
                left = mid + 1;
            }
        }
    }

    //assign result index
    if(result != nil)
    {
        lastFoundIndex = [subtitleInfos indexOfObject:result];
    }
    
    return result;
}

@end
