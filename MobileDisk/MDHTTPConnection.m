//
//  MDHTTPConnection.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "HTTPFileResponse.h"
#import "HTTPServer.h"

@interface MDHTTPConnection ()

-(NSData *)createWebDataWithRelativePath:(NSString *)relPath;

@end

@implementation MDHTTPConnection{
    
    NSMutableArray *multipartData;
    //This flag tell that if we need to keep reading header from post
    BOOL postHaderFinished;
    int bytePointer;
    BOOL isDiskFull;
}

-(void)dealloc
{
    multipartData = nil;
}

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig
{
    isDiskFull = NO;
    
    return [super initWithAsyncSocket:newSocket configuration:aConfig];
}


#pragma mark - Support method
/**
 * Returns whether or not the server will accept messages of a given method
 * at a particular URI.
 **/
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    
    
    //We support method POST 
    if([method isEqualToString:@"POST"])
    {
        //Only root path can support POST
        if([path isEqualToString:@"/"])
            return YES;
    }
    
    return [super supportsMethod:method atPath:path];
}

#pragma mark - Upload
/**
* This method is called after receiving all HTTP headers, but before reading any of the request body.
**/
- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	// Override me to allocate buffers, file handles, etc.
    NSLog(@"body size:%llu", contentLength);
    
    multipartData = [[NSMutableArray alloc] init];
    
    postHaderFinished = NO;
    bytePointer = 0;
    
    //check available disk space
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
    
    if(error == nil)
    {
        //NSNumber *totalSpaceInByte = [dic objectForKey:@"NSFileSystemSize"];
        NSNumber *availableSpaceInByte = [dic objectForKey:@"NSFileSystemFreeSize"];
        
        unsigned long long availableSpace = [availableSpaceInByte unsignedLongLongValue];
        
        if(contentLength >= availableSpace)
        {
            isDiskFull = YES;
        }
    }
    else
    {
        NSLog(@"Calculate disk space error:%@", error);
    }
}

/**
 * This method is called to handle data read from a POST / PUT.
 * The given data is part of the request body.
 **/
- (void)processBodyData:(NSData *)postDataChunk
{
    if(isDiskFull)
        return;
    
    NSLog(@"PostDataChunk:%@", [[NSString alloc] initWithData:postDataChunk encoding:NSUTF8StringEncoding]);
    
    /**Check if we need to keep reading header of not**/
    if(!postHaderFinished)
    {
        //0x0A0D indicate end of a line in bytes data
        UInt16 separatorBytes = 0x0A0D;
        /**Give 2 because 0x0A0D is 16 bits(UInt16) that equal to 2 bytes and length is byte unit
         0A 1byte 0D 1byte**/
        NSData *separatorData = [NSData dataWithBytes:&separatorBytes length:2];
        
        //Result is 2 since length is byte unit 
        int l = [separatorData length];
        
        for(int i=0; i<[postDataChunk length]-l; i++)
        {
            //We search 2 bytes at a time, first param is location to search
            //second param is numbers of bytes to search
            NSRange searchRange = {i, l};
            
            /**
             E.g
        
                byte data: 2d2d1b4a a76c8fa1 
                range:{0,2}
                result:2d2d
                elements:2d 2d 1b 4a a7 6c 8f a1
             
             **/
            //Get subdata from postDataChunk by range
            NSData *subData = [postDataChunk subdataWithRange:searchRange];
            
            //Compare with 0x0A0D to see if it is end of line, otherwise keep searching
            if([subData isEqualToData:separatorData])
            {
                //End of line and get byte data
                NSRange newRange = {bytePointer, i-bytePointer};
                
                /**
                 i=0, 0A0D=2bytes,
                 i+2= ignore 0A0D
                 **/
                //we set next start byte pointer
                bytePointer = i+l;
                i+=l-1;
                
                NSData *newData = [postDataChunk subdataWithRange:newRange];
                
                //Check if data has any bytes
                if([newData length])
                {
                    //add data to array
                    [multipartData addObject:newData];
                }
                else
                {
                    //header is finish
                    postHaderFinished = YES;
                    
                    //We get back the byte data post header info at second line
                    const void *byteData = [[multipartData objectAtIndex:1] bytes];
                    int byteLength = [[multipartData objectAtIndex:1] length];
                    
                    //Convert to string
                    NSString *postHeaderInfo = [[NSString alloc] initWithBytes:byteData length:byteLength encoding:NSUTF8StringEncoding];
                    
                    //We need to find filename
                    NSArray *componentsInfo = [postHeaderInfo componentsSeparatedByString:@"filename="];
                    
                    componentsInfo = [[componentsInfo lastObject] componentsSeparatedByString:@"\""];
					componentsInfo = [[componentsInfo objectAtIndex:1] componentsSeparatedByString:@"\\"];
                    
                    //actually a path append with file name
                    NSString *fileName = [[config documentRoot] stringByAppendingPathComponent:[componentsInfo lastObject]];
                    
                    NSRange fileDataRange = {bytePointer, [postDataChunk length] - bytePointer};

                    //create a file
                    BOOL saveFileSuccess = [[NSFileManager defaultManager] createFileAtPath:fileName contents:[postDataChunk subdataWithRange:fileDataRange] attributes:nil];
                    
                    if(saveFileSuccess)
                        NSLog(@"file saved");
                    else 
                        NSLog(@"file did not saved");
                    
                    
                    //we will use this file to write data
                    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
                    
                    if(file)
                    {
                        //put file pointer at the end of file
                        [file seekToEndOfFile];
                        //we add handler to array and use it later
                        [multipartData addObject:file];
                    }
                    
                    break;
                }
            }
        }
    }
    else
    {
        //header is finished, we  can write data
        [(NSFileHandle*)[multipartData lastObject] writeData:postDataChunk];
        NSLog(@"%@", [[NSString alloc] initWithData:postDataChunk encoding:NSUTF8StringEncoding]);
    }
}

/**
 * This method is called after the request body has been fully read but before the HTTP request is processed.
 **/
- (void)finishBody
{
    if(isDiskFull)
    {
        NSString *title = NSLocalizedString(@"Disk full", @"Disk full");
        NSString *msg = NSLocalizedString(@"Please clean some data on disk", @"Please clean some data on disk");
        
        UIAlertView *diskFull = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
        
        [diskFull show];
    }
    
    NSLog(@"finish body");
}


#pragma mark - HTTP respond for method
/**
 * This method is called to get a response for a request.
 * You may return any object that adopts the HTTPResponse protocol.
 * The HTTPServer comes with two such classes: HTTPFileResponse and HTTPDataResponse.
 * HTTPFileResponse is a wrapper for an NSFileHandle object, and is the preferred way to send a file response.
 * HTTPDataResponse is a wrapper for an NSData object, and may be used to send a custom response.
 **/
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    /**the path is a relative path not a full path**/
    
    //NSLog(@"Method: %@", method);
    //NSLog(@"Relatvie path: %@", path);
    
    if(isDiskFull == YES)
    {
        isDiskFull = NO;
        
    }
    else
    {
        //If there is a post with uploading file, requestContentLength will be greater thatn 0
        if(requestContentLength > 0)
        {
            
            if ([multipartData count] < 2) return nil;
            
            NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes]
                                                          length:[[multipartData objectAtIndex:1] length]
                                                        encoding:NSUTF8StringEncoding];
            
            NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"filename="];
            postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
            postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
            NSString* fileName = [postInfoComponents lastObject];
            
            if (![fileName isEqualToString:@""])
            {
                /**We need to trim the file at end**/
                UInt16 separatorBytes = 0x0A0D;
                NSMutableData* separatorData = [NSMutableData dataWithBytes:&separatorBytes length:2];
                [separatorData appendData:[multipartData objectAtIndex:0]];
                int l = [separatorData length];
                int count = 2;	//number of times the separator shows up at the end of file data
                
                NSFileHandle* dataToTrim = [multipartData lastObject];
                //NSLog(@"data: %@", dataToTrim);
                
                for (unsigned long long i = [dataToTrim offsetInFile] - l; i > 0; i--)
                {
                    [dataToTrim seekToFileOffset:i];
                    if ([[dataToTrim readDataOfLength:l] isEqualToData:separatorData])
                    {
                        [dataToTrim truncateFileAtOffset:i];
                        i -= l;
                        if (--count == 0) break;
                    }
                }
            }
            
            //clear buffer
            multipartData = nil;
            requestContentLength = 0; 
        }
    }

    
    /**We need to determind what kind of relative path is to do a proper respond**/
    //We get back full path
    NSString *str =[path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *fullPath = [[config documentRoot] stringByAppendingPathComponent:str];
    
    
    /**Since the full path might be a directory or file, therefore, we need to retrieve
     attributes for this full path and we will check if it is a directory or file later**/
    //Get attributes by full path 
    NSError *fileAttError;
    NSDictionary *fileAtt = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&fileAttError];
    
    /**Because attributes is stored in dictionary so we obtain the value by key to 
     check what kind of path is this file?, directory? etc**/
    if([[fileAtt objectForKey:NSFileType] isEqualToString:NSFileTypeRegular])
    {
        //This is a regular file, the request is try to download file. Transfer file
        return [[HTTPFileResponse alloc] initWithFilePath:fullPath forConnection:self];
    }
    else if([[fileAtt objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory])
    {
        //This is a directory, create web data, the request is try to access a directory
        NSData *webData = [self createWebDataWithRelativePath:path];
        
        //respond
        if(webData != nil)
            return [[HTTPDataResponse alloc] initWithData:webData];
    }
    else
    {
        //other unknow
        return nil;
    }
    
    return nil;
}

-(NSData *)createWebDataWithRelativePath:(NSString *)relPath
{
    NSString *fullPath = [[config documentRoot] stringByAppendingPathComponent:relPath];
    
    //Search directories, files or symbolic links under given path
    NSError *searchError;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:&searchError];
    
    //Error will always occur when there is no favico.ico file in document
    //Web will always ask for that
    //NSLog(@"search error code: %@", searchError);
    
    if([contents count] == 0)
    {
        //Nothing found
       // NSLog(@"Path: %@ has nothing in it", fullPath);
    }
    
    //Create a mutable string contain html code, this is actually a long long long string
    NSMutableString *htmlStrCode = [[NSMutableString alloc] init];
    
    //Start to construct html code
    [htmlStrCode appendString:@"<html><head>"];
    //charset must use UTF-8 to support other language
    [htmlStrCode appendString:@"<META http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">"];
    [htmlStrCode appendFormat:@"<title>File from %@</title>", [config server].name];
    [htmlStrCode appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [htmlStrCode appendString:@"</head><body>"];
    [htmlStrCode appendFormat:@"<h1>Files from %@</h1>", [config server].name];
    [htmlStrCode appendString:@"<bq>The following files are hosted live from the iPhone's Docs folder.</bq>"];
    [htmlStrCode appendString:@"<p>"];
    
    //We dont show root and back if we are in root
    if(![relPath isEqualToString:@"/"])
    {
        //Root hyper link
        [htmlStrCode appendFormat:@"<a href=\"/\">Root</a><br />\n"];
        
        //Back a level
        [htmlStrCode appendFormat:@"<a href=\"%@\">Back</a><br />\n", [relPath stringByDeletingLastPathComponent]];
    }

    
    //Construct each content
    NSError *attError;
    for(NSString *aContent in contents)
    {
        /**contents contain the name of directory or file not path we need to append them**/
        NSString *newContentPath = [fullPath stringByAppendingPathComponent:aContent];
        
        //Get attributes for a single content at path such as file type, file size.... 
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:newContentPath error:&attError];
        
        //Get file modification date
        NSString *fileModifiDate = [[fileAttributes objectForKey:NSFileModificationDate] description];
        
        if(fileModifiDate ==nil)
        {
            fileModifiDate = [[NSDate date] description];
        }
        
        /**We can reuse newContentPath**/
        //If content is a directory
        if([[fileAttributes objectForKey:NSFileType] isEqualToString:@"NSFileTypeDirectory"])
        {
            //A directory. We add slash at end of path 
            newContentPath = [aContent stringByAppendingString:@"/"];
            
            [htmlStrCode appendFormat:@"<a href=\"%@\">%@/</a>     (Folder, %@)<br />\n", [relPath stringByAppendingPathComponent:newContentPath], aContent, fileModifiDate]; 
        }
        else if([[fileAttributes objectForKey:NSFileType] isEqualToString:NSFileTypeRegular])
        {
            //A file
            newContentPath= aContent;

            [htmlStrCode appendFormat:@"<a href=\"%@\">%@</a>     (%8.1f Kb, %@)<br />\n", [relPath stringByAppendingPathComponent:newContentPath], aContent, [[fileAttributes objectForKey:NSFileSize] floatValue]/1024, fileModifiDate];
        }
        

        
    }
    
    [htmlStrCode appendString:@"</p>"];
    
    //A form for upload file 
    if ([self supportsMethod:@"POST" atPath:relPath])
	{
		[htmlStrCode appendString:@"<form action=\"\" method=\"post\" enctype=\"multipart/form-data\" name=\"form1\" id=\"form1\">"];
		[htmlStrCode appendString:@"<label>upload file"];
		[htmlStrCode appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
		[htmlStrCode appendString:@"</label>"];
		[htmlStrCode appendString:@"<label>"];
		[htmlStrCode appendString:@"<input type=\"submit\" name=\"button\" id=\"button\" value=\"Submit\" />"];
		[htmlStrCode appendString:@"</label>"];
		[htmlStrCode appendString:@"</form>"];
	}
    
    [htmlStrCode appendString:@"</body></html>"];
    
    
    
    //Convert html code to a data
    NSData *webData = [htmlStrCode dataUsingEncoding:NSUTF8StringEncoding];
    return webData;
}

@end
