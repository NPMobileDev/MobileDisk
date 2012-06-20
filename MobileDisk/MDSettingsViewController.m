//
//  MDSettingsViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDSettingsViewController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "IPResolver.h"

@interface MDSettingsViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;

-(void)resolveIPAddress;
-(void)UpdateLabels;
-(void)createTableViewData;
-(void)configureCell:(UITableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath;
- (void)WifiSwitch:(id)sender;

@end

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation MDSettingsViewController{
    
    //store server address
    NSString *serverAddress;
    //indicate http server is on or off
    BOOL httpServerON;
    
    //hold section and row for cell identifier
    NSMutableArray *cellModels;
    //hold section header
    NSMutableArray *sectionHeaders;
}

@synthesize httpServer = _httpServer;
@synthesize tableView = _tableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.httpServer = nil;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self=[super initWithCoder:aDecoder]))
    {
        [self createTableViewData];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //update labels
    [self UpdateLabels];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
    return [cellModels count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSArray *rows = [cellModels objectAtIndex:section];
    
    if(section == 0)
    {
        if(httpServerON)
        {
            return [rows count];
        }
        else
        {
            return [rows count] - 1;
        }
    }
    
    return [rows count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    
    //get cell identifier
    NSArray *rows = [cellModels objectAtIndex:indexPath.section];
    NSString *cellIdentifier = [rows objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    [self configureCell:cell WithIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionHeaders objectAtIndex:section];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return nil;
    }
    
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 1)
        {
            return 99;
        }
    }
    
    return 44;
}

#pragma mark - Update labels
-(void)UpdateLabels
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Resolve IP address
-(void)resolveIPAddress
{
    /**register notification for resolve IP. When IP is resolved this 
     instance will be notifi showIP method will be called
     
     Related file IPResolver.h IPResolver.m
     **/ 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showIP:) name:kResolveIPNotification object:nil];
    
    //start to resolve IP
    [IPResolver resolveIP];
}

#pragma mark - Show IP
-(void)showIP:(NSNotification *)notification
{
    //extract notification object, the object is actually a dictionary
    //take look IPResolver.m
    NSDictionary *IPs = notification.object;
    NSString *ipStr = [IPs objectForKey:@"en1"];
    NSString *httpAddress = [NSString stringWithFormat:@"http://%@:%i", ipStr, self.httpServer.port];
    
    //store string 
    serverAddress = httpAddress;
    
    //update labels
    [self UpdateLabels];
}

#pragma mark - Create tableview data
-(void)createTableViewData
{
    cellModels = nil;
    cellModels = [[NSMutableArray alloc] init];
    sectionHeaders = nil;
    sectionHeaders = [[NSMutableArray alloc] init];

    
    //add prototype cell identifier for section 0
    [cellModels addObject:[NSArray arrayWithObjects:@"S0-R0-WifiStatus", @"S0-R1-Address", nil]];
    //add header for section 0
    [sectionHeaders addObject:@"Wi-Fi Transfer"];
    
}

#pragma mark - Configure cell
-(void)configureCell:(UITableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            UISwitch *wifiSwitch = (UISwitch*)[cell viewWithTag:1000];
            [wifiSwitch setOn:httpServerON];
            
            [wifiSwitch addTarget:self action:@selector(WifiSwitch:) forControlEvents:UIControlEventValueChanged];
        }
        else if(indexPath.row == 1)
        {
            UILabel *addressLabel = (UILabel*)[cell viewWithTag:1001];
            
            if(httpServerON && serverAddress != nil)
            {
                addressLabel.text = serverAddress;
            }
            else
            {
                addressLabel.text = @"";
            }
        }
    }
    
}

- (void)WifiSwitch:(id)sender {

    UISwitch *wifiSwitcher = sender;
    
    if([wifiSwitcher isOn])
    {
        NSError *serverError;
        
        //check if http server is already started
        if([self.httpServer isRunning])
        {
            //stop it first
            [self.httpServer stop];
        }
        
        //start http server
        if([self.httpServer start:&serverError])
        {
            httpServerON = YES;
            
            DDLogInfo(@"Started HTTP Server on port %hu", [self.httpServer listeningPort]);
            
            [self resolveIPAddress];
        }
        else
        {
            httpServerON = NO;
            DDLogError(@"Error starting HTTP Server: %@", serverError);
        }
    }
    else
    {
       //stop http server
        [self.httpServer stop]; 
        
        httpServerON = NO;
        
        //update labels
        [self UpdateLabels];
    }
}
@end
