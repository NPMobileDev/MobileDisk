//
//  SSZipArchive+SSZipArchiveExtension.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/8/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/**
 extension to SSZipArchive 8/28/2012
 **/

#import "SSZipArchive.h"


@interface SSZipArchive (SSZipArchiveExtension)

+(BOOL)isZipFileEncrypted:(NSString*)path;
+(BOOL)isZipFilePasswordCorrectFilePath:(NSString*)filePath WithPassword:(NSString*)password;

@end
