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
#import "MDForegroundViewController.h"


static int idleTimeCount = 0;

@implementation MobileDiskAppDelegate{
    
    HTTPServer *httpServer;
    UIImageView *LogoImageView;
}


@synthesize window = _window;

#pragma enable/disable idle time
+(void)disableIdleTime
{
    idleTimeCount++;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

+(void)enableIdleTime
{
    idleTimeCount--;
    
    if(idleTimeCount == 0)
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    
}

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
    
    [httpServer setName:@"mobile disk app"];
    
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

-(void)registerUserDefaults
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], sysGenerateThumbnail, [NSNumber numberWithBool:NO], sysPasscodeStatus, @"-1", sysPasscodeNumber, nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
}

-(void)initilizeAppliaction
{
    [self registerUserDefaults];
    
    /**
     initate AVAudioPlayer because it take time to init so we init when app start
     otherwise init of AVAudioPlayer will block any of view controller
     **/
    [self initiateAudioPlayer];
    
    //configure and create http server
    [self configureHttpServer];
    
    //get settings controller and set http server
    UITabBarController *tabbarController = (UITabBarController*)self.window.rootViewController;
    
    //settings
    UINavigationController *navController = [tabbarController.viewControllers objectAtIndex:1];
    MDSettingsViewController *settingsController = [navController.viewControllers objectAtIndex:0];  
    
    settingsController.httpServer = httpServer;
}

-(void)presentPasscodeCheck
{
    NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:sysPasscodeNumber];
    
    UITabBarController *tabbarController = (UITabBarController*)self.window.rootViewController;
    
    MDPasscodeViewController *passcodeController = [tabbarController.storyboard instantiateViewControllerWithIdentifier:@"MDPasscodeViewController"];
    
    passcodeController.canShowCancelButton = NO;
    passcodeController.passcodeToCheck = passcode;
    passcodeController.theDelegate = self;
    
    [tabbarController presentViewController:passcodeController animated:YES completion:^{
    
        [LogoImageView removeFromSuperview];
    }];
}

-(void)shouldPresentPasscodeCheck
{
    BOOL passcodeStatus = [[NSUserDefaults standardUserDefaults] boolForKey:sysPasscodeStatus]; 
    
    if(passcodeStatus)
    {
        [self performSelector:@selector(presentPasscodeCheck) withObject:nil afterDelay:0];

    }
    else
    {
        [LogoImageView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:sysApplicationEnterForeground object:nil];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    UITabBarController *tabbarController = (UITabBarController*)self.window.rootViewController;
    LogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    LogoImageView.image = [UIImage imageNamed:@"Default"];
    [tabbarController.view addSubview:LogoImageView];
    
    [self initilizeAppliaction];
    [self performSelector:@selector(shouldPresentPasscodeCheck) withObject:nil afterDelay:0];
    
    
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

    
    UITabBarController *tabbarController = (UITabBarController*)self.window.rootViewController;
    
    //files
    UINavigationController *navController = [tabbarController.viewControllers objectAtIndex:0];
    
    MDForegroundViewController *controller = [tabbarController.storyboard instantiateViewControllerWithIdentifier:@"MDForegroundViewController"];
    
    if(navController.presentedViewController != nil)
    {
        
        [navController.presentedViewController presentModalViewController:controller animated:NO];
    }
    else
    {
        [tabbarController presentModalViewController:controller animated:NO];
    }
     
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSError *error;
    //restart http server if needed
    if(httpServer.isRunning)
    {
        [httpServer stop:YES];
        [httpServer start:&error];
    }
    
    if(error != nil)
    {
        NSLog(@"An error occur when app enter foreground and restart http server error:%@", error);
    }
    
    //check if need passcode check
    //[self shouldPresentPasscodeCheck];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [httpServer stop];
}

#pragma mark - MDPasscodeViewController delegate
-(void)MDPasscodeViewControllerInputPasscodeIsCorrect:(MDPasscodeViewController *)controller
{
        UITabBarController *tabbarController = (UITabBarController*)self.window.rootViewController;
    
        //[tabbarController dismissModalViewControllerAnimated:YES];
        [tabbarController dismissViewControllerAnimated:YES completion:^{
    
            [[NSNotificationCenter defaultCenter] postNotificationName:sysApplicationEnterForeground object:nil];
        }];
}

-(void)MDPasscodeViewControllerInputPasscodeIsIncorrect:(MDPasscodeViewController *)controller
{
    NSString *msg = NSLocalizedString(@"Invalid passcode", @"Invalid passcode");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
    
    [alert show];
    
    [controller resetPasscode];
}

-(void)MDPasscodeViewControllerDidCancel:(MDPasscodeViewController *)controller
{
    
}

-(void)MDPasscodeViewController:(MDPasscodeViewController *)controller didReceiveNewPasscode:(NSString *)newPasscode
{
    
}

@end
