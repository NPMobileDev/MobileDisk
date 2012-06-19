//
//  MobileDiskViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MobileDiskViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "HTTPServer.h"
#import "MDHTTPConnection.h"

@interface MobileDiskViewController ()

-(IBAction)httpServerSwitch:(id)sender;
-(void)configureHttpServer;
-(NSString *)documentPath;

@end

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation MobileDiskViewController{
    
    
    //Http server 
    HTTPServer *httpServer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        //Configure server
         [self configureHttpServer];
    }
    
    return self;
}

-(NSString *)documentPath
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [directories objectAtIndex:0];
    
    return docPath;
}

#pragma mark - http server
-(void)configureHttpServer
{
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //Create server
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_http._tcp."];
    
    //Tell the server to use our own custom HTTP connection class which is MDHTTPConnection
    //by default it is HTTPConnection
    [httpServer setConnectionClass:[MDHTTPConnection class]];
    
    // Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:12345];
    
    //Document path
    NSString *rootPath = [self documentPath];
    
    //Set document root
    [httpServer setDocumentRoot:rootPath];
    NSLog(@"Setting document root:%@", rootPath);
    
}

#pragma mark - IBAction
-(IBAction)httpServerSwitch:(id)sender
{
    UISwitch *serverSwitch = sender;
    NSError *error;
    
    if([serverSwitch isOn])
    {
        /**Start http server**/
        
        //If server is running we stop it
        if([httpServer isRunning])
        {
            [httpServer stop];
        }
        
        
        //Start server
        if([httpServer start:&error])
        {
            DDLogInfo(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
        }
        else
        {
            DDLogError(@"Error starting HTTP Server: %@", error);
        }
        
    }
    else
    {
        /**Stop http server**/
        
        //Stop server
        [httpServer stop];
    }
}

@end
