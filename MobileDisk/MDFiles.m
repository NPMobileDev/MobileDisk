//
//  MDFiles.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDFiles.h"

@interface MDFiles()

-(void)configureFileByPath:(NSString *)path;
-(NSString *)fileSizeToStringWithByte:(unsigned long long)size;

@end

@implementation MDFiles

@synthesize isFile = _isFile;
@synthesize fileName = _fileName;
@synthesize filePath = _filePath;
@synthesize fileSizeString = _fileSizeString;
@synthesize fileSize = _fileSize;

-(void)dealloc
{
    self.fileName = nil;
    self.filePath = nil;
    self.fileSizeString = nil;
}

-(id)initWithFilePath:(NSString *)path FileName:(NSString *)filename
{
    if((self = [super init]))
    {
        self.fileName = filename;
        [self configureFileByPath:path];
    }
    
    return self;
}

-(void)configureFileByPath:(NSString *)path
{
    NSError *error;
    
    //set file type
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    
    NSString *fileType = [fileAttributes objectForKey:NSFileType];
    
    if([fileType isEqualToString:NSFileTypeRegular])
    {
        //is a file
        self.isFile = YES;
    }
    else if([fileType isEqualToString:NSFileTypeDirectory])
    {
        //is a directory
        self.isFile = NO;
    }
    else
    {
        //other type
        self.isFile = NO;
    }
    
    //set file path
    self.filePath = path;
    
    if(self.isFile)
    {
        //set file size
        NSNumber *fsize = [fileAttributes objectForKey:NSFileSize];
        
        self.fileSize = [fsize longLongValue];
        self.fileSizeString = [self fileSizeToStringWithByte:[fsize longLongValue]];
    }
    else
    {
        self.fileSizeString = nil;
    }
}

#pragma mark - File size to string
-(NSString *)fileSizeToStringWithByte:(unsigned long long)size
{
    //convert long long to float
    float convertSize = size;
    NSString *unitStr = @"Bytes";
    
    if(convertSize >= 1024)
    {
        //kb
        convertSize = convertSize / 1024;
        unitStr = @"KB";
    }
    
    if(convertSize >= 1024)
    {
        //mb
        convertSize = convertSize / 1024;
        unitStr = @"MB";
    }
    
    if(convertSize >= 1024)
    {
        //gb
        convertSize = convertSize / 1024;
        unitStr = @"GB";
    }
    
    return [NSString stringWithFormat:@"%.2f%@", convertSize, unitStr];
}

@end
