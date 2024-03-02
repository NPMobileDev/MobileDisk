//
//  SSZipArchive+SSZipArchiveExtension.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 12/8/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/**
 extension to SSZipArchive 8/28/2012
 **/

#import "SSZipArchive+SSZipArchiveExtension.h"
#include "unzip.h"
#include "zip.h"
#include <sys/stat.h>


@implementation SSZipArchive (SSZipArchiveExtension)

+(BOOL)isZipFileEncrypted:(NSString*)path
{
    
    /**
     http://secureartisan.wordpress.com/2008/11/04/analysis-of-encrypted-zip-files/
     Bytes 7 and 8 are called the General Purpose Bit Flags. They are read little-endian, and if bit 0 is set to 1, then the contents of the ZIP file are encrypted.
     
     General purpose bit flags:
     bit 0:    set - file is encrypted
     clear - file is not encrytped
     bit 1: if compression method 6 used (imploding)
     set - 8K sliding dictionary
     clear - 4K sliding dictionary
     bit 2: if compression method 6 used (imploding)
     set - 3 Shannon-Fano trees were used to  encode
     the sliding dictionary output
     clear - 2 Shannon-Fano trees were used
     
     For method 8 compression (deflate):
     bit 2  bit 1
     0      0    Normal (-en) compression
     0      1    Maximum (-ex) compression
     1      0    Fast (-ef) compression
     1      1    Super Fast (-es) compression
     
     Note:  Bits  1  and  2  are  undefined   if   the
     compression method is any other than 6 or 8.
     bit 3: if compression method 8 (deflate)
     set - the fields crc-32,  compressed  size  and
     uncompressed size are set to zero in  the
     local header. The correct values are  put
     in  the   data   descriptor   immediately
     following the compressed data.
     
     The upper three bits are reserved and used internally  by
     the software when processing the zipfile.  The  remaining
     bits are unused.
     **/
    
    NSData *zipFileData = [NSData dataWithContentsOfFile:path];
    NSData *bitFlag = [zipFileData subdataWithRange:NSMakeRange(6, 2)];
    NSString *bitFlagStr = [bitFlag description];
    
    int intVal = [bitFlagStr characterAtIndex:2];
    
    NSMutableString *str = [NSMutableString stringWithCapacity:10];
    
    for(NSInteger numberCopy = intVal; numberCopy > 0; numberCopy >>= 1)
    {
        // Prepend "0" or "1", depending on the bit
        [str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];
    }
    
    NSLog(@"encrypted:%@", [str substringFromIndex:0]);
    
    NSString *bit0 = [str substringFromIndex:[str length]-1];
    
    if([bit0 isEqualToString:@"1"])
    {
        return YES;
    }
    else if([bit0 isEqualToString:@"0"])
    {
        return NO;
    }
    else
    {
        return NO;
    }
    
}

+(BOOL)isZipFilePasswordCorrectFilePath:(NSString*)filePath WithPassword:(NSString*)password
{
    /**
     Return codes for the compression/decompression functions. Negative values are errors, positive values are used for special but normal events.
     #define Z_OK            0
     #define Z_STREAM_END    1
     #define Z_NEED_DICT     2
     #define Z_ERRNO        (-1)
     #define Z_STREAM_ERROR (-2)
     #define Z_DATA_ERROR   (-3)
     #define Z_MEM_ERROR    (-4)
     #define Z_BUF_ERROR    (-5)
     #define Z_VERSION_ERROR (-6)
     **/
    
    BOOL passwordCorrect = YES;
    int ret = 0;
    unsigned char buffer[1] = {0};
    
    //open zip file
    zipFile zip = unzOpen((const char*)[filePath UTF8String]); 
    
    if (zip == NULL) 
    {
        NSLog(@"zip is null when open zip file");
        
        unzClose(zip);
        
        return NO;
    }
    
    //go to first file 
    if(unzGoToFirstFile(zip) != UNZ_OK)
    {
        NSLog(@"zip go to first file fail");
        
        unzClose(zip);
        
        return NO;
    }

    //open file
    ret = unzOpenCurrentFilePassword(zip, [password cStringUsingEncoding:NSASCIIStringEncoding]);
    
    if(ret !=UNZ_OK)
    {
        unzCloseCurrentFile(zip);
        unzClose(zip);
        
        passwordCorrect = NO;
        return passwordCorrect;
    }

    /**
     check if we are able to read each file with given password
     if readByte is nagetive password is worng
     **/
    do
    {
        int readByte = unzReadCurrentFile(zip, buffer, 1);
        
        if(readByte == Z_DATA_ERROR)
        {
            unzCloseCurrentFile(zip);
            unzClose(zip);
            
            passwordCorrect = NO;
            
            return passwordCorrect;
        }
        else
        {
            unzCloseCurrentFile(zip);
            ret = unzGoToNextFile(zip);
            if(unzOpenCurrentFilePassword(zip, [password cStringUsingEncoding:NSASCIIStringEncoding]) != UNZ_OK)
            {
                passwordCorrect = NO;
                
                return passwordCorrect;
            }
        }
        
    }while(ret != UNZ_END_OF_LIST_OF_FILE);
    

    unzCloseCurrentFile(zip);
    unzClose(zip);
    
    return passwordCorrect;
}

@end
