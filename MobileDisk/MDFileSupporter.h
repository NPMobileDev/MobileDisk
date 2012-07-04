//
//  MDFileSupporter.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDFileSupporter : NSObject

@property (nonatomic, readonly, getter = supportLists) NSDictionary *supportLists;
@property (nonatomic, readonly, getter = supportListInUTI) NSArray *supportListInUTI;

-(id)initFileSupporter;
-(BOOL)isFileSupported:(NSString *)filePath;
-(id)findControllerToOpenFile:(NSString *)filePath WithStoryboard:(UIStoryboard *)storyboard;
+(BOOL)canShowFileName:(NSString *)fileName;
@end
