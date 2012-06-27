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

@interface MDFileSupporter()

-(void)loadSupportedFileExtensions;
-(id)findControllerForImageTypeFile:(CFStringRef)compareUTI WithStoryboard:(UIStoryboard *)storyboard;
-(id)findControllerForAudioVideoTypeFile:(CFStringRef)compareUTI WithStoryboard:(UIStoryboard *)storyboard;
-(id)findControllerForOtherTypeFile:(CFStringRef)compareUTI WithStoryboard:(UIStoryboard *)storyboard;

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
        theController = [self findControllerForImageTypeFile:compareUTI WithStoryboard:storyboard];
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeAudiovisualContent))
    {
        //file is audio or video type abstract
        theController = [self findControllerForAudioVideoTypeFile:compareUTI WithStoryboard:storyboard];
    }
    else
    {
        //file is other type
        theController = [self findControllerForOtherTypeFile:compareUTI WithStoryboard:storyboard];
    }
    
    //free memory
    //CFRelease(declareInfo);
    CFRelease(compareUTI);
    
    return theController;
}

-(id)findControllerForImageTypeFile:(CFStringRef)compareUTI WithStoryboard:(UIStoryboard *)storyboard
{
    if(UTTypeConformsTo(compareUTI, kUTTypePNG))
    {
        NSLog(@"return png controller");
    }
    else if(UTTypeConformsTo(compareUTI, kUTTypeJPEG))
    {
        NSLog(@"return jpeg controller");
    }
    
    return nil; 
}

-(id)findControllerForAudioVideoTypeFile:(CFStringRef)compareUTI WithStoryboard:(UIStoryboard *)storyboard
{
    return nil;
}

-(id)findControllerForOtherTypeFile:(CFStringRef)compareUTI WithStoryboard:(UIStoryboard *)storyboard
{
    if(UTTypeConformsTo(compareUTI, kUTTypePDF))
    {
        //file is pdf
        NSLog(@"return pdf controller");
        
        NSURL *pdfURL = [NSURL fileURLWithPath:operateFilePath];
        
        MDPDFViewController *pdfController = [storyboard instantiateViewControllerWithIdentifier:@"MDPDFViewController"];
        
        pdfController.pdfURL = pdfURL;
        
        return pdfController;
    }
    
    return nil;
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
