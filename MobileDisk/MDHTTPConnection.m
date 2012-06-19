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
    
    NSMutableString *relativePath;
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
    NSLog(@"%llu", contentLength);
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
    
    //Check method action
    if([method isEqualToString:@"GET"])
    {
        /**In GET method it might be requested a path of directory or a single file**/
        
        //We get back full path
        NSString *fullPath = [[config documentRoot] stringByAppendingPathComponent:path];
        
        /**Since the full path might be a directory or file, therefore, we need to retrieve
         attributes for this full path and we will check if it is a directory or file later**/
        //Get attributes by full path 
        NSDictionary *fileAtt = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
        
        /**Because attributes is stored in dictionary so we obtain the value by key to 
         check what kind of path is this file?, directory? etc**/
        if([[fileAtt objectForKey:NSFileType] isEqualToString:NSFileTypeRegular])
        {
            //This is a regular file, transfer file
            return [[HTTPFileResponse alloc] initWithFilePath:fullPath forConnection:self];
        }
        else if([[fileAtt objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory])
        {
            //This is a directory, create web data
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
        [htmlStrCode appendFormat:@"<a href=\"/\">root</a><br />\n"];
        
        //Back a level
        [htmlStrCode appendFormat:@"<a href=\"%@\">Back</a><br />\n", [relPath stringByDeletingLastPathComponent]];
    }

    
    //Construct each content
    NSError *attError;
    for(NSString *aContent in contents)
    {
        
        NSString *newContentPath = [fullPath stringByAppendingPathComponent:aContent];
        
        //Get attributes for a single content at path such as file type, file size.... 
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:newContentPath error:&attError];
        
        //Get file modification date
        NSString *fileModifiDate = [[fileAttributes objectForKey:NSFileModificationDate] description];
        
        if(fileModifiDate ==nil)
        {
            fileModifiDate = [[NSDate date] description];
        }
        
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
    
    //later we will support post
    
    [htmlStrCode appendString:@"</body></html>"];
    
    
    
    //Convert html code to a data
    NSData *webData = [htmlStrCode dataUsingEncoding:NSUTF8StringEncoding];
    return webData;
}

@end
