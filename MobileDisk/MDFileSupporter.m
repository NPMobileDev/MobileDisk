//
//  MDFileSupporter.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDFileSupporter.h"
#import "MDFilesViewController.h"
#import "MDPDFViewController.h"
#import "MDImageViewerController.h"
#import "MDAVPlayerController.h"

@interface MDFileSupporter()

-(void)loadSupportedFileExtensions;
-(id)findControllerForImageTypeFile:(CFStringRef)compareUTI;
-(id)findControllerForAudioVideoTypeFile:(CFStringRef)compareUTI;
-(id)findControllerForOtherTypeFile:(CFStringRef)compareUTI;
-(id)findImageViewerController;
-(id)findAudioVideoController;

@end

@implementation MDFileSupporter{
    
    
    NSDictionary *supportedExtensions;
    
    /**
     hold supported file extension
     extension will be convert to UTI(Uniform Type Indentifier)
     Check out UTType Reference
     **/ 
    NSMutableArray *supportedExtensionsUTI;
    
    NSString *operateFilePath;
    __weak UIStoryboard *operateStoryboard;
    
}

@synthesize supportLists = _supportLists;
@synthesize supportListInUTI = _supportListInUTI;

-(id)initFileSupporter
{
    if((self = [super init]))
    {
        [self loadSupportedFileExtensions];
        
    }
    return self;
}

-(void)dealloc
{
    if(supportedExtensionsUTI != nil)
    {
        for(NSValue *value in supportedExtensionsUTI)
        {
            CFStringRef uti = [value pointerValue];
            
            CFRelease(uti);
        }
    }

}

#pragma mark find controller to open specific file type
-(id)findControllerToOpenFile:(NSString *)filePath WithStoryboard:(UIStoryboard *)storyboard
{
    operateStoryboard = storyboard;
    
    id theController = nil;
    operateFilePath = filePath;
    NSString *filename = [filePath lastPathComponent];
    NSString *extension = [filename pathExtension];
    CFStringRef extensionTag = (__bridge CFStringRef)extension;
    
    if([extension isEqualToString:@""])
    {
        return nil;
    }
    
    //create UTI for file extension
    CFStringRef compareUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extensionTag, NULL);
    
    /*
    //get back UTI info
    CFDictionaryRef declareInfo = UTTypeCopyDeclaration(compareUTI);
    CFArrayRef conformType = CFDictionaryGetValue(declareInfo, kUTTypeConformsToKey);

    
    NSLog(@"declare info:%@", declareInfo);
    NSLog(@"conform types:%@", conformType);
    */
    
    
    if (UTTypeConformsTo(compareUTI, kUTTypeImage)) 
    {
        //file is image type abstract
        theController = [self findControllerForImageTypeFile:compareUTI];
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeAudiovisualContent))
    {
        //file is audio or video type abstract
        theController = [self findControllerForAudioVideoTypeFile:compareUTI];
    }
    else
    {
        //file is other type
        theController = [self findControllerForOtherTypeFile:compareUTI];
    }
    
    //free memory
    //CFRelease(declareInfo);
    CFRelease(compareUTI);
    
    return theController;
}

-(id)findControllerForImageTypeFile:(CFStringRef)compareUTI
{
    id controller = nil;
    
    if(UTTypeConformsTo(compareUTI, kUTTypePNG))
    {
        //is png image
        NSLog(@"return png controller");
        
        controller = [self findImageViewerController];
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeJPEG))
    {
        //is jpeg image
        NSLog(@"return jpeg controller");
        
        controller = [self findImageViewerController];
    }

    
    return controller; 
}

-(id)findControllerForAudioVideoTypeFile:(CFStringRef)compareUTI
{
    id controller = nil;
    
    if(UTTypeConformsTo(compareUTI, kUTTypeMPEG4))
    {
        //mp4 video
        controller = [self findAudioVideoController];
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeMP3))
    {
        //mp3 audio
        controller = [self findAudioVideoController];
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeQuickTimeMovie))
    {
        //quick time movie
        controller = [self findAudioVideoController];
    }
    
    return controller;
}

-(id)findControllerForOtherTypeFile:(CFStringRef)compareUTI
{
    if(UTTypeConformsTo(compareUTI, kUTTypePDF))
    {
        //file is pdf
        NSLog(@"return pdf controller");
        
        NSURL *pdfURL = [NSURL fileURLWithPath:operateFilePath];
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDPDFViewController"];
        
        MDPDFViewController * pdfController = [navController.viewControllers objectAtIndex:0];
        
        pdfController.pdfURL = pdfURL;
        
        return navController;
    }
    
    return nil;
}

-(id)findImageViewerController
{
    //find image viewer controller
    NSURL *imageURL = [NSURL fileURLWithPath:operateFilePath];
    
    UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDImageViewerController"];
    
    MDImageViewerController * imageController = [navController.viewControllers objectAtIndex:0];
    
    imageController.imageURL = imageURL;
    
    return navController;
}

-(id)findAudioVideoController
{
    NSURL *avFileURL = [NSURL fileURLWithPath:operateFilePath];
    
    MDAVPlayerController *avPlayerController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDAVPlayerController"];
    
    avPlayerController.avFileURL = avFileURL;
    
    return avPlayerController;
}


#pragma mark - load supported file extensions
-(void)loadSupportedFileExtensions
{
    //get support file from bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MobileDiskInfo" ofType:@"plist"];
    
    NSDictionary *mobileDiskInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //Since we only add support file extension to MobileDiskInfo.plist
    //Check .plist out
    NSDictionary *supporedFilesCategories = [mobileDiskInfo objectForKey:@"SupportedFileExtensions"];
    
    
    NSMutableArray *supportedFiles = [[NSMutableArray alloc] init];
    
    NSArray *keys =[supporedFilesCategories allKeys];
    
    for(NSString *key in keys)
    {
        NSArray *categroySupport = [supporedFilesCategories objectForKey:key];
        
        for(NSString *supportedStr in categroySupport)
        {
            [supportedFiles addObject:supportedStr];
        }
    }
    
    
    NSMutableArray *utis = [[NSMutableArray alloc] init];
    
    for(NSString *supportedStr in supportedFiles)
    {
        //create UTI for supported file extension
        CFStringRef extensionTag = (__bridge CFStringRef)supportedStr;
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extensionTag, NULL);
        
        NSLog(@"add support file :%@", uti);
        
        //convert to nsvalue to store it
        [utis addObject:[NSValue valueWithPointer:uti]];
    }
    
    supportedExtensions = [supporedFilesCategories copy];
    supportedExtensionsUTI = [utis copy];
}

#pragma mark - check file is support
-(BOOL)isFileSupported:(NSString *)filePath
{
    BOOL isSupport = NO;
    
    //get file extension .xxx -> xxx
    NSString *extension = [filePath pathExtension];
    
    //check extension is available
    if([extension isEqualToString:@""])
    {
        return isSupport;
    }
    
    //create UTI from extension
    CFStringRef extensionTag = (__bridge CFStringRef)extension;
    CFStringRef comparedUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extensionTag, NULL);
    
    //go through each support file extension and compare them
    for(NSValue *value in supportedExtensionsUTI)
    {
        CFStringRef suppoertedUTI = [value pointerValue];
        
        if(UTTypeEqual(comparedUTI, suppoertedUTI))
        {
            isSupport = YES;
            break;
        }
    }
    
    //must release UTI object
    CFRelease(comparedUTI);
    
    return isSupport;
}

#pragma mark - getter
-(NSDictionary *)supportLists
{
    NSDictionary *dic = [supportedExtensions copy];
    
    return dic;
}

-(NSArray *)supportListInUTI
{
    NSArray *listUTI = [supportedExtensionsUTI copy];
    
    return listUTI;
}

@end
