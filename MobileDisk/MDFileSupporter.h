//
//  MDFileSupporter.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//**MDFileSupporter is a singleton**//

#import <Foundation/Foundation.h>

#define kThumbnailCacheName @"ThumbnailCache"
#define kThumbnailCacheCountLimit 0 //0 == no limit

@interface MDFileSupporter : NSObject

@property (nonatomic, readonly, getter = supportLists) NSDictionary *supportLists;
@property (nonatomic, readonly, getter = supportListInUTI) NSArray *supportListInUTI;

+(MDFileSupporter *)sharedFileSupporter;
-(void)initFileSupporter;
-(BOOL)isFileSupported:(NSString *)filePath;
-(id)findControllerToOpenFile:(NSString *)filePath WithStoryboard:(UIStoryboard *)storyboard;
-(BOOL)canShowFileName:(NSString *)fileName;
-(UIImage*)findThumbnailImageForFileAtPath:(NSString *)filePath thumbnailSize:(CGSize)imageSize;
@end
