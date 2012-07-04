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
#import "MDMusicPlayerController.h"
#import "MDUnarchiveNavigationController.h"
#import "MDUnarchiveViewController.h"
#import "UIImage+Resize.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <CoreMedia/CMTime.h>
#import "MobileDiskAppDelegate.h"

@interface MDFileSupporter()

-(void)loadSupportedFileExtensions;
-(id)findControllerForImageTypeFile:(CFStringRef)compareUTI;
-(id)findControllerForAudioVideoTypeFile:(CFStringRef)compareUTI;
-(id)findControllerForArchiveTypeFile:(CFStringRef)compareUTI;
-(id)findControllerForOtherTypeFile:(CFStringRef)compareUTI;
-(id)findImageViewerController;
-(id)findAudioVideoController;
-(id)findAudioController;
-(void)loadHiddenFileName;
-(UIImage*)generateMovieThumbnailImageAtPath:(NSURL*)moviePath;
-(void)createThumbnailImageCache;

@end

/**define our own UTI type**/
//zip archive
const CFStringRef kUTTypeZipArchive = (__bridge CFStringRef)@"com.pkware.zip-archive";

static MDFileSupporter *fileSupporterInstance;
static NSArray *hiddenFileName;

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
    
    NSCache *thumbnailImageCache;
    
}

@synthesize supportLists = _supportLists;
@synthesize supportListInUTI = _supportListInUTI;

+(MDFileSupporter *)sharedFileSupporter
{
    //create one if needed
    if(fileSupporterInstance == nil)
    {
        fileSupporterInstance = [MDFileSupporter alloc];
        
        if(fileSupporterInstance)
        {
            //init 
            [fileSupporterInstance initFileSupporter];
            
            return fileSupporterInstance;
        }
        else
        {
            return nil;
        }
    }
    
    return fileSupporterInstance;
}

-(void)initFileSupporter
{
    [self loadHiddenFileName];
    [self loadSupportedFileExtensions];
    [self createThumbnailImageCache];
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

-(void)loadHiddenFileName
{

    NSString *path = [[NSBundle mainBundle] pathForResource:@"MobileDiskInfo" ofType:@"plist"];
    
    NSDictionary *mobileDiskInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    
    hiddenFileName = [[mobileDiskInfo objectForKey:@"HiddenFlieName"] copy];
}

-(BOOL)canShowFileName:(NSString *)fileName
{
    for(NSString *hiddenName in hiddenFileName)
    {
        if([fileName isEqualToString:hiddenName])
        {
            return NO;
        }
    }
    
    return YES;
}

-(void)createThumbnailImageCache
{
    if(thumbnailImageCache == nil)
    {
        thumbnailImageCache = [[NSCache alloc] init];
        [thumbnailImageCache setName:kThumbnailCacheName];
        [thumbnailImageCache setCountLimit:kThumbnailCacheCountLimit];
        
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
    else if(UTTypeConformsTo(compareUTI, kUTTypeArchive))
    {
        theController = [self findControllerForArchiveTypeFile:compareUTI];
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
        controller = [self findAudioController];
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeQuickTimeMovie))
    {
        //quick time movie
        controller = [self findAudioVideoController];
    }
    
    return controller;
}

-(id)findControllerForArchiveTypeFile:(CFStringRef)compareUTI
{
    id controller = nil;
    
    if(UTTypeConformsTo(compareUTI, kUTTypeZipArchive))
    {
        //zip archive
        NSLog(@"return zip archive controller");
        
        NSURL *archiveFileURL = [NSURL fileURLWithPath:operateFilePath];
        
        MDUnarchiveNavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDUnarchiveNavigationController"];
        
        navController.archiveFilePath = archiveFileURL;
        
        controller = navController;
    }
    
    return controller;
}

-(id)findControllerForOtherTypeFile:(CFStringRef)compareUTI
{
    id controller = nil;
    
    if(UTTypeConformsTo(compareUTI, kUTTypePDF))
    {
        //file is pdf
        NSLog(@"return pdf controller");
        
        NSURL *pdfURL = [NSURL fileURLWithPath:operateFilePath];
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDPDFViewController"];
        
        MDPDFViewController * pdfController = [navController.viewControllers objectAtIndex:0];
        
        pdfController.pdfURL = pdfURL;
        
        controller = navController;
    }
    
    return controller;
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

-(id)findAudioController
{
    NSURL *audioFileURL = [NSURL fileURLWithPath:operateFilePath];
    
    MDMusicPlayerController *musicPlayerController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDMusicPlayerController"];
    
    musicPlayerController.musicFileURL = audioFileURL;
    
    return musicPlayerController;
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

#pragma mark - Find thumbnail for file
-(UIImage*)findThumbnailImageForFileAtPath:(NSString *)filePath thumbnailSize:(CGSize)imageSize
{
    BOOL canGenerateThumbnail;
    UIImage *thumbnailImage = nil;
    NSURL *fileURLPath = [NSURL fileURLWithPath:filePath];
    NSString *filename = [filePath lastPathComponent];
    NSString *extension = [filename pathExtension];
    CFStringRef extensionTag = (__bridge CFStringRef)extension;
    
    if([extension isEqualToString:@""])
        return nil;
    
    //is system allow to generate thumbnail
    canGenerateThumbnail = [[NSUserDefaults standardUserDefaults] boolForKey:sysGenerateThumbnail];
    
    if(canGenerateThumbnail)
    {
        //check if thumbnail is existed
        UIImage *thumb = [thumbnailImageCache objectForKey:filePath];
        
        if(thumb != nil)
            return thumb;
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
        if(canGenerateThumbnail)
        {
            //file is image type abstract
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            //resize
            thumbnailImage = [image resizeImageTo:imageSize];
        }
        else
        {
            //default image for image type
        }
        
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeAudiovisualContent))
    {
        //file is audio or video type abstract
        
        
        if(UTTypeConformsTo(compareUTI, kUTTypeAudio))
        {
            //audio only
            //return audio image
        }
        else
        {
            if(canGenerateThumbnail)
            {
                //movie only
                thumbnailImage = [self generateMovieThumbnailImageAtPath:fileURLPath];
                
                //resize
                thumbnailImage = [thumbnailImage resizeImageTo:imageSize];
                
                //stored in cache
                [thumbnailImageCache setObject:thumbnailImage forKey:filePath];
            }
            else
            {
                //default image for move type
            }

        }
        
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeArchive))
    {
        //file is archive type
    }
    else
    {
        //file is other type
        
    }
    
    //free memory
    //CFRelease(declareInfo);
    CFRelease(compareUTI);
        
    
    return thumbnailImage;
}

-(UIImage*)generateMovieThumbnailImageAtPath:(NSURL*)moviePath
{
    NSError *error;
    UIImage *thumbImage = nil;
    AVAsset *asset = [AVAsset assetWithURL:moviePath];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime thumbnailTime = CMTimeMake(0, 30);
    
    CGImageRef cgThumbnailImage = [generator copyCGImageAtTime:thumbnailTime actualTime:nil error:&error];
    if(cgThumbnailImage == nil || error != nil)
    {
        //fail
        NSLog(@"fail to generate thumbnail for file %@ error:%@", [moviePath path], error);
        
        return nil;
    }
    
    thumbImage = [UIImage imageWithCGImage:cgThumbnailImage];
    
    return  thumbImage;
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
