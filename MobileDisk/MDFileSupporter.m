//
//  MDFileSupporter.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDFileSupporter.h"
#import "MDFilesViewController.h"
#import "MDDocumentViewController.h"
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
-(id)findControllerForTextTypeFile:(CFStringRef)compareUTI;
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
const CFStringRef kUTTypeDoc = (__bridge CFStringRef)@"com.microsoft.word.doc";
//identify as archive type
const CFStringRef kUTTypeDocx = (__bridge CFStringRef)@"org.openxmlformats.openxml";
const CFStringRef kUTTypeExcel = (__bridge CFStringRef)@"com.microsoft.excel.xls";
const CFStringRef kUTTypePPT = (__bridge CFStringRef)@"com.microsoft.powerpoint.ppt";
const CFStringRef kUTTypeM4V = (__bridge CFStringRef)@"com.apple.m4v-video";

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
    
    /**
     thumbnail cache hold image of thumbnail in memory
     we don't actually save thumbnail in disk, so we use cache to hold it
     when memory is not enough and required extra memory by anyone
     the cache will automatic clear
     **/
    __block NSCache *thumbnailImageCache;
    
    /**
     the queue used to run generate thumbnail task
     **/
    dispatch_queue_t thumbnailGenQueue;
    
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
    thumbnailGenQueue = dispatch_queue_create("Thumbnail", NULL);
    
    [self loadHiddenFileName];
    [self loadSupportedFileExtensions];
    [self createThumbnailImageCache];
}

-(void)dealloc
{
    dispatch_release(thumbnailGenQueue);
    
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
    
    
    if([extension isEqualToString:@""])
    {
        return nil;
    }
    else if([extension isEqualToString:@"m4r"])
    {
        extension = @"m4a";
    }
    else if([extension isEqualToString:@"aac"])
    {
        extension = @"m4a";
    }
    
    CFStringRef extensionTag = (__bridge CFStringRef)extension;
    
    //create UTI for file extension
    CFStringRef compareUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extensionTag, NULL);
    
    
    //get back UTI info
    CFDictionaryRef declareInfo = UTTypeCopyDeclaration(compareUTI);
    CFArrayRef conformType = CFDictionaryGetValue(declareInfo, kUTTypeConformsToKey);

    
    NSLog(@"declare info:%@", declareInfo);
    NSLog(@"conform types:%@", conformType);
    
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
    else if(UTTypeConformsTo(compareUTI, kUTTypeText))
    {
        //file is text type
        theController = [self findControllerForTextTypeFile:compareUTI];
    }
    else
    {
        //file is other type
        theController = [self findControllerForOtherTypeFile:compareUTI];
    }
    
    //free memory
    CFRelease(declareInfo);
    CFRelease(compareUTI);
    
    return theController;
}

-(id)findControllerForImageTypeFile:(CFStringRef)compareUTI
{
    id controller = nil;
    
    /*
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
     */
    controller = [self findImageViewerController];

    
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
    else if(UTTypeConformsTo(compareUTI, kUTTypeM4V))
    {
        //m4v video
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
    else if(UTTypeConformsTo(compareUTI, kUTTypeAudio))
    {
        controller = [self findAudioController];
    }
    
    return controller;
}

-(id)findControllerForArchiveTypeFile:(CFStringRef)compareUTI
{
    id controller = nil;
    
    if(UTTypeConformsTo(compareUTI, kUTTypeDocx))
    {
        //docx document text file (been recognized as archive file)
        NSURL *docxURL = [NSURL fileURLWithPath:operateFilePath];
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDDocumentViewController"];
        
        MDDocumentViewController * docxController = [navController.viewControllers objectAtIndex:0];
        
        docxController.controllerTitle = [docxURL lastPathComponent];
        docxController.theDocumentURL = docxURL;
        
        controller = navController;
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeZipArchive))
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

-(id)findControllerForTextTypeFile:(CFStringRef)compareUTI
{
    id controller = nil;
    
    
    if(UTTypeConformsTo(compareUTI, kUTTypeRTF))
    {
        //file is RTF
        NSURL *textURL = [NSURL fileURLWithPath:operateFilePath];
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDDocumentViewController"];
        
        MDDocumentViewController * docController = [navController.viewControllers objectAtIndex:0];
        
        docController.controllerTitle = [textURL lastPathComponent];
        docController.theDocumentURL = textURL;
        
        controller = navController;
    }
    else
    {
        NSURL *textURL = [NSURL fileURLWithPath:operateFilePath];
        NSData *textData = [NSData dataWithContentsOfURL:textURL];
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDDocumentViewController"];
        
        MDDocumentViewController * docController = [navController.viewControllers objectAtIndex:0];
        
        docController.controllerTitle = [textURL lastPathComponent];
        docController.theDocumentData = textData;
        
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
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDDocumentViewController"];
        
        MDDocumentViewController * pdfController = [navController.viewControllers objectAtIndex:0];
        
        pdfController.controllerTitle = [pdfURL lastPathComponent];
        pdfController.theDocumentURL = pdfURL;
        
        controller = navController;
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeExcel))
    {
        //file is microsoft excel
        NSURL *excelURL = [NSURL fileURLWithPath:operateFilePath];
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDDocumentViewController"];
        
        MDDocumentViewController * excelController = [navController.viewControllers objectAtIndex:0];
        
        excelController.controllerTitle = [excelURL lastPathComponent];
        excelController.theDocumentURL = excelURL;
        
        controller = navController;
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeDoc))
    {
        //file is microsoft doc
        NSURL *docURL = [NSURL fileURLWithPath:operateFilePath];
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDDocumentViewController"];
        
        MDDocumentViewController * docController = [navController.viewControllers objectAtIndex:0];
        
        docController.controllerTitle = [docURL lastPathComponent];
        docController.theDocumentURL = docURL;
        
        controller = navController;
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypePPT))
    {
        //PPT
        NSURL *pptURL = [NSURL fileURLWithPath:operateFilePath];
        
        UINavigationController *navController = [operateStoryboard instantiateViewControllerWithIdentifier:@"MDDocumentViewController"];
        
        MDDocumentViewController * docController = [navController.viewControllers objectAtIndex:0];
        
        docController.controllerTitle = [pptURL lastPathComponent];
        docController.theDocumentURL = pptURL;
        
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
            NSString *newStr = [supportedStr copy];
            
            [supportedFiles addObject:newStr];
        }
    }
    
    
    NSMutableArray *utis = [[NSMutableArray alloc] init];
    
    for(NSString *supportedStr in supportedFiles)
    {
        //create UTI for supported file extension
        CFStringRef extensionTag = (__bridge CFStringRef)supportedStr;
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extensionTag, NULL);
        
        NSLog(@"add support file :%@", uti);
        
        NSString *utiStr = (__bridge NSString *)uti;
        
        //convert to nsvalue to store it
        //[utis addObject:[NSValue valueWithPointer:uti]];
        [utis addObject:[utiStr copy]];
        
        CFRelease(uti);
        
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
    else if([extension isEqualToString:@"m4r"])
    {
        //rington m4r == m4a
        extension = @"m4a";
    }
    else if([extension isEqualToString:@"aac"])
    {
        extension = @"m4a";
    }
    
    //create UTI from extension
    CFStringRef extensionTag = (__bridge CFStringRef)extension;
    CFStringRef comparedUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extensionTag, NULL);
    
    //go through each support file extension and compare them
    for(NSString *utiStr in supportedExtensionsUTI)
    {
        //CFStringRef suppoertedUTI = [value pointerValue];
        CFStringRef supportedUTI = (__bridge CFStringRef)utiStr;
        
        if(UTTypeEqual(comparedUTI, supportedUTI))
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
-(void)findThumbnailImageForFileAtPath:(NSString *)filePath thumbnailSize:(CGSize)imageSize WithObject:(id)object
{
    /**
     we generate thumbnail on the fly not perserved thumbnail on disk
     and thumbnails are held in cache.
     we don't want to cost disk free space.
     It's a bit slow to generate thumbnail depend on the size of source image.
     
     some thumbnails will be dumped from cache for new thumbnail if cache
     is full, therefore, when dumped thumbnail is required it will be regenerated
     and stored in cache
     **/
    
    __block BOOL canGenerateThumbnail;
    //the object who invok this method
    __block id theObject = object;
    UIImage *thumbnailImage = nil;
    __block NSURL *fileURLPath = [NSURL fileURLWithPath:filePath];
    NSString *filename = [filePath lastPathComponent];
    NSString *extension = [filename pathExtension];
    
    
    
    if([extension isEqualToString:@""])
    {
        thumbnailImage = [UIImage imageNamed:@"UnknowIcon"];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:thumbnailImage, kThumbnailImage, theObject, kThumbnailCaller, filePath, kThumbnailGeneratedFrom, nil];
        
        //post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kThumbnailGenerateNotification object:dic];
        
        return;
    }
    
    //is system allow to generate thumbnail
    canGenerateThumbnail = [[NSUserDefaults standardUserDefaults] boolForKey:sysGenerateThumbnail];
    
    /**
     From this point we try to get thumbnail from cache if thumbnail generator is
     active
     **/
    if(canGenerateThumbnail)
    {
        //check if thumbnail is existed in cache
        UIImage *thumb = [thumbnailImageCache objectForKey:filePath];
        
        if(thumb != nil)
        {
            NSLog(@"thumbnail is in cache");
            thumbnailImage = thumb;
            
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:thumbnailImage, kThumbnailImage, theObject, kThumbnailCaller, filePath, kThumbnailGeneratedFrom, nil];
            
            //post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kThumbnailGenerateNotification object:dic];
            
            return;
        }
    }
    
    /**
     From this point we try to get default thumbnail icon for file if generatot is 
     deactive
     **/
    
    CFStringRef preExtensionTag = (__bridge CFStringRef)extension;
    //create UTI for file extension
    CFStringRef preCompareUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, preExtensionTag, NULL);
    
    if(UTTypeConformsTo(preCompareUTI, kUTTypeImage))
    {
        //if generate thumb not active give default icon
        if(!canGenerateThumbnail)
        {
            thumbnailImage = [UIImage imageNamed:@"ImageIcon"];
        }
    }
    else if(UTTypeConformsTo(preCompareUTI, kUTTypeAudiovisualContent))
    {
        if(UTTypeConformsTo(preCompareUTI, kUTTypeAudio))
        {
            //audio can not generate thumbnail only default icon
            thumbnailImage = [UIImage imageNamed:@"AudioIcon"];
        }
        else
        {
            //if generate thumb not active give default icon
            if(!canGenerateThumbnail)
            {
                thumbnailImage = [UIImage imageNamed:@"FilmIcon"];
            }
        }
    }
    else if(UTTypeConformsTo(preCompareUTI, kUTTypeText))
    {
        //text thumb
        thumbnailImage = [UIImage imageNamed:@"TextDocumentIcon"];
    }
    else if(UTTypeConformsTo(preCompareUTI, kUTTypePDF))
    {
        //document thumb
        thumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
    }
    else if(UTTypeConformsTo(preCompareUTI, kUTTypeArchive))
    {
        //file is archive type
        
        //docx is archive type return document thumb
        if(UTTypeConformsTo(preCompareUTI, kUTTypeDocx))
        {
            thumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
        }
        else
        {
            thumbnailImage = [UIImage imageNamed:@"ZipIcon"];
        }
    }
    else
    {
        //file is other type
        if(UTTypeConformsTo(preCompareUTI, kUTTypeDoc))
        {
            //doc return document icon
            thumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
        }
        else if(UTTypeConformsTo(preCompareUTI, kUTTypeExcel))
        {
            //excel return document icon
            thumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
        }
        else if(UTTypeConformsTo(preCompareUTI, kUTTypePPT))
        {
            //ppt return document icon
            thumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
        }
        else if([extension isEqualToString:@"m4r"])
        {
            thumbnailImage = [UIImage imageNamed:@"AudioIcon"];
        }
        else if([extension isEqualToString:@"aac"])
        {
            thumbnailImage = [UIImage imageNamed:@"AudioIcon"];
        }
        else
        {
            //unknow icon
            thumbnailImage = [UIImage imageNamed:@"UnknowIcon"];
        }
    }
    
    //free UTI
    CFRelease(preCompareUTI);
    
    if(thumbnailImage != nil)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:thumbnailImage, kThumbnailImage, theObject, kThumbnailCaller, filePath, kThumbnailGeneratedFrom, nil];
        
        //post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kThumbnailGenerateNotification object:dic];
        
        return;
    }
    
    
    


    /**
     From this point we have to generate thumbnail for file that is able to generate thumbnail
     thumbnail is not in cache we need to generate a thumbnail
     because generate thumbnail take heavy task we run it on differet
     thread
     **/
    dispatch_async(thumbnailGenQueue, ^{
        
        id GCDTheObject = theObject;
        UIImage *GCDThumbnailImage = nil;
        NSString *GCDFilePath = filePath;
        NSURL *GCDFileURLPath = fileURLPath;
        //NSString *GCDFileExtension = extension;
    
        CFStringRef extensionTag = (__bridge CFStringRef)extension;
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
                UIImage *image = [UIImage imageWithContentsOfFile:GCDFilePath];
                
                //resize
                GCDThumbnailImage = [image retinaResizeImageTo:imageSize];
                
                //stored in cache
                if(GCDThumbnailImage != nil)
                    [thumbnailImageCache setObject:GCDThumbnailImage forKey:GCDFilePath];
                else
                    GCDThumbnailImage = [UIImage imageNamed:@"ImageIcon"];
            }
            /*
            else
            {
                //default thumb for image type
                GCDThumbnailImage = [UIImage imageNamed:@"ImageIcon"];
            }
             */
            
        }
        else if(UTTypeConformsTo(compareUTI, kUTTypeAudiovisualContent))
        {
            //file is audio or video type abstract
            
            /*
            if(UTTypeConformsTo(compareUTI, kUTTypeAudio))
            {
                //audio only
                //return default thumb image
                GCDThumbnailImage = [UIImage imageNamed:@"AudioIcon"];
            }
             
            else
             */
            
            //if not audio then it is video
            if(!UTTypeConformsTo(compareUTI, kUTTypeAudio))
            {
                if(canGenerateThumbnail)
                {
                    //movie only
                    UIImage *image = [self generateMovieThumbnailImageAtPath:GCDFileURLPath];
                    
                    //resize
                    GCDThumbnailImage = [image retinaResizeImageTo:imageSize];
                    
                    //stored in cache
                    if(GCDThumbnailImage != nil)
                        [thumbnailImageCache setObject:GCDThumbnailImage forKey:GCDFilePath];
                    else
                        GCDThumbnailImage = [UIImage imageNamed:@"FilmIcon"];
                }
                /*
                else
                {
                    //default thumb for move type
                    GCDThumbnailImage = [UIImage imageNamed:@"FilmIcon"];
                }
                */
            }
            
        }
        /*
        else if(UTTypeConformsTo(compareUTI, kUTTypeText))
        {
            //text thumb
            GCDThumbnailImage = [UIImage imageNamed:@"TextDocumentIcon"];
        }
        else if(UTTypeConformsTo(compareUTI, kUTTypePDF))
        {
            //document thumb
            GCDThumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
        }
        else if(UTTypeConformsTo(compareUTI, kUTTypeArchive))
        {
            //file is archive type
            
            //docx is archive type return document thumb
            if(UTTypeConformsTo(compareUTI, kUTTypeDocx))
            {
                GCDThumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
            }
        }
        else
        {
            //file is other type
            if(UTTypeConformsTo(compareUTI, kUTTypeDoc))
            {
                //doc return document icon
                GCDThumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
            }
            else if(UTTypeConformsTo(compareUTI, kUTTypeExcel))
            {
                //excel return document icon
                GCDThumbnailImage = [UIImage imageNamed:@"DocumentIcon"];
            }
            else if([GCDFileExtension isEqualToString:@"m4r"])
            {
                GCDThumbnailImage = [UIImage imageNamed:@"AudioIcon"];
            }
            else if([GCDFileExtension isEqualToString:@"aac"])
            {
                GCDThumbnailImage = [UIImage imageNamed:@"AudioIcon"];
            }
            else
            {
                //unknow icon
                GCDThumbnailImage = [UIImage imageNamed:@"UnknowIcon"];
            }
        }
         */
        
        //free memory
        //CFRelease(declareInfo);
        CFRelease(compareUTI);
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:GCDThumbnailImage, kThumbnailImage, GCDTheObject, kThumbnailCaller, GCDFilePath, kThumbnailGeneratedFrom, nil];
            
            //post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kThumbnailGenerateNotification object:dic];
        });

    });
    

        
}

-(UIImage*)generateMovieThumbnailImageAtPath:(NSURL*)moviePath
{
    NSError *error;
    UIImage *thumbImage = nil;
    AVAsset *asset = [AVAsset assetWithURL:moviePath];
    CMTime duration = asset.duration;
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime thumbnailTime = CMTimeMake(duration.value / 4.0f, duration.timescale);
    
    CGImageRef cgThumbnailImage = [generator copyCGImageAtTime:thumbnailTime actualTime:nil error:&error];
    if(cgThumbnailImage == nil || error != nil)
    {
        //fail
        NSLog(@"fail to generate thumbnail for file %@ error:%@", [moviePath path], error);
        
        return nil;
    }
    
    thumbImage = [UIImage imageWithCGImage:cgThumbnailImage];
    
    CGImageRelease(cgThumbnailImage);
    
    return  [thumbImage copy];
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
