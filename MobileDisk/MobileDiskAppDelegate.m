//
//  MobileDiskAppDelegate.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MobileDiskAppDelegate.h"
#import "HTTPServer.h"
#import "MDHTTPConnection.h"
#import "MDSettingsViewController.h"
#import "MDFilesNavigationController.h"
#import "MDFileSupporter.h"
#import <AVFoundation/AVAudioPlayer.h>



@implementation MobileDiskAppDelegate{
    
    HTTPServer *httpServer;
    
    MDFileSupporter *fileSupporter;
}


@synthesize window = _window;

#pragma mark - Configure http server
-(void)configureHttpServer
{
    if(httpServer == nil)
    {
        //Create server
        httpServer = [[HTTPServer alloc] init];
    }
    
    // Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_http._tcp."];
    
    //Tell the server to use our own custom HTTP connection class which is MDHTTPConnection
    //by default it is HTTPConnection
    [httpServer setConnectionClass:[MDHTTPConnection class]];
    
    // Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:kHttpServerPort];
    
    //Get document path
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [directories objectAtIndex:0];
    
    //Set document root
    [httpServer setDocumentRoot:docPath];
    NSLog(@"Setting document root:%@", docPath);
    
    NSLog(@"Http server configuration complete");
}

+(NSString *)documentDirectory
{
    //Get document path
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [directories objectAtIndex:0];
    
    return docPath;
}

-(void)initiateAudioPlayer
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dummy" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    /**
     initate AVAudioPlayer because it take time to init so we init when app start
     otherwise init of AVAudioPlayer will block any of view controller
     **/
    [self initiateAudioPlayer];
    
    //create file supporter
    fileSupporter = [[MDFileSupporter alloc] initFileSupporter];
    
    //configure and create http server
    [self configureHttpServer];
    
    //get settings controller and set http server
    UITabBarController *tabbarController = (UITabBarController*)self.window.rootViewController;
    
    //settings
    UINavigationController *navController = [tabbarController.viewControllers objectAtIndex:1];
    MDSettingsViewController *settingsController = [navController.viewControllers objectAtIndex:0];  
    
    settingsController.httpServer = httpServer;
    
    
    //files
    MDFilesNavigationController *filesNavController = [tabbarController.viewControllers objectAtIndex:0];
    
    filesNavController.fileSupporter = fileSupporter;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
