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
#import "MobileDiskAppDelegate.h"


@interface MDSettingsViewController ()


-(void)resolveIPAddress;
-(void)createTableViewData;
-(void)configureCell:(UITableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath;
- (void)wifiSwitch:(id)sender;
-(void)reloadTableViewSection:(NSUInteger)section WithAnimation:(BOOL)yesOrNO;
-(void)calculateDiskSpace;
-(void)passcodeStatusChange:(id)sender;
-(void)changePasscode;
-(void)generateThumbnail:(id)sender;

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
    
    //disk space string
    NSString *diskSpaceString;
    //free space string
    NSString *freeSpaceString;
    
    MDChangePasscodeController *changePasscodeController;
    
    
    //used to prevent ddlog add many times
    BOOL DDLogIsSet;
}

@synthesize httpServer = _httpServer;

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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self=[super initWithCoder:aDecoder]))
    {
        //we create tabel data
        //[self createTableViewData];
        
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self calculateDiskSpace];
    
    //we create tabel data
    [self createTableViewData];
    
    [self.tableView reloadData];
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
    if(!DDLogIsSet)
    {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        DDLogIsSet = YES;
    }
    
    cellModels = [[NSMutableArray alloc] init];
    
    //we calculate disk space
    //[self calculateDiskSpace];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
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

-(void)enterForeground:(NSNotification*)notification
{
    [self resolveIPAddress];
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
    
    //get back row
    NSArray *rows = [cellModels objectAtIndex:section];
    
    /**
        check if section 0, the reason to check section is equal to 0 is because at section 0
        we have a row that act like drop down list, which mean it will be hidden from time to
        time
     
        setion 0 has two rows, take look settings view in storyboard
     **/
    NSInteger rowsCount = [rows count];
    
    if(section == 0)
    {
        //only to show the second row when http server is activate
        //otherwise hidden
        if(httpServerON == NO)
        {
            //http server is no activate, we hidden last row, there for total row is 1
            rowsCount -=1;
        }

    }
    
    if(section == 3)
    {
        NSString *passcodeNumber = [[NSUserDefaults standardUserDefaults] stringForKey:sysPasscodeNumber];
        
        //if passcode never setted
        if([passcodeNumber isEqualToString:@"-1"])
        {
            //hide change passcode row
            rowsCount -= 1;
        }
    }
    
    return rowsCount;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    
    /**get cell identifier depend on which section and row**/
    
    //find the rows in which section
    NSArray *rows = [cellModels objectAtIndex:indexPath.section];
    
    //find the identifier in which row
    NSString *cellIdentifier = [rows objectAtIndex:indexPath.row];
    
    //get back reusable prototype cell by identifier
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
    
    
    if(indexPath.section == 3)
    {
        //did select change passcode row
        if(indexPath.row == 1)
        {
            [self changePasscode];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    //section > 0 we don't want any rows to be selected
    if(indexPath.section > 1)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return nil;
    }
     */
    
    if(indexPath.section == 3)
    {
        //change passcode row can be selected
        if(indexPath.row == 1)
        {
            return indexPath;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //second cell's height at section 0 is 99 value is from design tool
    if(indexPath.section == 0)
    {
        if(indexPath.row == 1)
        {
            return 99;
        }
    }
    
    return 44;
}

#pragma mark - Reload table's specific section
-(void)reloadTableViewSection:(NSUInteger)section WithAnimation:(BOOL)yesOrNO
{
    if(yesOrNO)
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    }

    
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
    NSString *ipStr = nil;
    NSString *httpAddress;
    

    for(int i=0; i<4 ; i++)
    {
        ipStr = [IPs objectForKey:[NSString stringWithFormat:@"en%i", i]];
        
        if(ipStr != nil)
        {
            break;
        }
    }

    
    if(ipStr != nil)
    {
        httpAddress = [NSString stringWithFormat:@"http://%@:%i", ipStr, self.httpServer.port]; 
    }
    else
    {
        httpAddress = [NSString stringWithString:NSLocalizedString(@"No Wi-Fi connection", @"No Wi-Fi connection")];
    }

    
    //store string 
    serverAddress = httpAddress;
    
    //reload table section
    [self reloadTableViewSection:0 WithAnimation:YES];
}

#pragma mark - Create tableview data
-(void)createTableViewData
{

    /**
        Here we construct data for tableview, there are multiples prototype cells
        in in table view in settings view. Each Cells has it's own identifier, therefore,
        we need to construct a data that hold these identifiers so when tabel view is asking
        for a specific cell we can give coorespond indentifier. Table view use identifer to
        retrieve a proper reuseable prototype cell  by indentifier.
     
        To check identifier take look each prototype cell's indentifier field in settings view
        in storyboard.
        
        To expand more section headers and cells, you should design prototype cell in storyboard and then add indentifier and header in here
     **/
    
    /**
        cellModels contain many array which hold identifiers for prototype cells, those
        array are represent sections in table view and the elements in array represent the
        prototype cell
        
        Important: the order of array and array's emelents is equal to table view's order 
     **/
    cellModels = nil;
    cellModels = [[NSMutableArray alloc] init];
    
    /**
        sectionHeaders hold the headers for each sections in table view
        
        Important: the order is equal to table view's section order
     **/
    sectionHeaders = nil; 
    sectionHeaders = [[NSMutableArray alloc] init];

    
    //add prototype cell identifier for section 0, two row
    [cellModels addObject:[NSArray arrayWithObjects:@"S0-R0-WifiStatus", @"S0-R1-Address", nil]];
    
    //add prototype cell identifier for section 1, two row
    [cellModels addObject:[NSArray arrayWithObjects:@"S1-R0-DiskSpace", @"S1-R1-FreeSpace", nil]];
    
    //add prototype cell identifier for section 2, one row
    [cellModels addObject:[NSArray arrayWithObjects:@"S2-R0-GenerateThumbnail", nil]];
    
     //add prototype cell identifier for section 3, two row
    [cellModels addObject:[NSArray arrayWithObjects:@"S3-R0-Passcode", @"S3-R1-ChangePasscode", nil]];

    
    //add header for section 0
    [sectionHeaders addObject:NSLocalizedString(@"Wi-Fi Transfer", @"WiFi Transfer")];
    
    //add header for section 1
    [sectionHeaders addObject:NSLocalizedString(@"Usage", @"Usage")];
    
    //add header for section 2
    [sectionHeaders addObject:NSLocalizedString(@"File", @"File")];
    
    //add header for section 3
    [sectionHeaders addObject:NSLocalizedString(@"Passcode Protection", @"Passcode Protection")];
    
}

#pragma mark - Configure cell
-(void)configureCell:(UITableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
    /**
        all the tags are setted in UI design tool. Use tags to easy get any of UI elements
        in each cell.
        
        take look elements tag in cell in table view in settings view
     **/
    
    switch (indexPath.section) {
        
            /**
             configure cells at section 0
             **/
        case 0:
            if(indexPath.row == 0)
            {
                //get back switch by tag
                UISwitch *wifiSwitch = (UISwitch*)[cell viewWithTag:1000];
                
                //set switch's status by http server status
                [wifiSwitch setOn:httpServerON];
                
                //we add a action to switch which can turn on/off http server
                [wifiSwitch addTarget:self action:@selector(wifiSwitch:) forControlEvents:UIControlEventValueChanged];
            }
            else if(indexPath.row == 1)
            {
                //get back label by tag
                UILabel *addressLabel = (UILabel*)[cell viewWithTag:1001];
                
                
                //set label's text 
                if(httpServerON && serverAddress != nil)
                {
                    addressLabel.text = serverAddress;
                }
                else
                {
                    addressLabel.text = @"";
                }
            }
            
            break;
            
            /**
             configure cells at section 1
             **/
        case 1:
            if(indexPath.row == 0)
            {
                UILabel *diskSpaceLabel = (UILabel*)[cell viewWithTag:1002];
                
                diskSpaceLabel.text = diskSpaceString;
            }
            else if(indexPath.row == 1)
            {
                UILabel *freeSpaceLabel = (UILabel*)[cell viewWithTag:1003];
                
                freeSpaceLabel.text = freeSpaceString;
            }
            
            break;
            /**
             configure cells at section 2
             **/
        case 2:
            if(indexPath.row == 0)
            {
                //get value for generate thumbnail setting
                BOOL generateThumbnail = [[NSUserDefaults standardUserDefaults] boolForKey:sysGenerateThumbnail];
                
                UISwitch *theSwitch = (UISwitch*)[cell viewWithTag:1004];
                theSwitch.on = generateThumbnail;
                
                [theSwitch addTarget:self action:@selector(generateThumbnail:) forControlEvents:UIControlEventValueChanged];
            }
            
            break;
            /**
             configure cells at section 3
             **/
        case 3:
            if(indexPath.row == 0)
            {
                //get value for passcode status
                BOOL passcodeStatus = [[NSUserDefaults standardUserDefaults] boolForKey:sysPasscodeStatus];
                
                UISwitch *theSwitch = (UISwitch*)[cell viewWithTag:1005];
                theSwitch.on = passcodeStatus;
                
                [theSwitch addTarget:self action:@selector(passcodeStatusChange:) forControlEvents:UIControlEventValueChanged];
            }
            
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Usage calculation
-(void)calculateDiskSpace
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
    
    if(error == nil)
    {
        NSNumber *totalSpaceInByte = [dic objectForKey:@"NSFileSystemSize"];
        NSNumber *availableSpaceInByte = [dic objectForKey:@"NSFileSystemFreeSize"];
        
        diskSpaceString = [self sizeToStringWithByte:[totalSpaceInByte floatValue]];
        freeSpaceString = [self sizeToStringWithByte:[availableSpaceInByte floatValue]];
    }
    else
    {
        NSLog(@"Calculate disk space error:%@", error);
    }
    
   
}

//convert given size in byte to string e.g 1024bytes -> 1KB
-(NSString *)sizeToStringWithByte:(float)size
{
    float convertSize = size;
    NSString *unitStr = @"Bytes";
    
    if(convertSize >= 1024)
    {
        //kb
        convertSize = convertSize / 1024;
        unitStr = @"KB";
    }
    
    if(convertSize >= 1024)
    {
        //mb
        convertSize = convertSize / 1024;
        unitStr = @"MB";
    }
    
    if(convertSize >= 1024)
    {
        //gb
        convertSize = convertSize / 1024;
        unitStr = @"GB";
    }
    
    return [NSString stringWithFormat:@"%.2f%@", convertSize, unitStr];
}

#pragma mark - WiFi switcher
- (void)wifiSwitch:(id)sender {

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
        
        //reload table section
        [self reloadTableViewSection:0 WithAnimation:YES];
    }
}

#pragma mark - Generate thumbnail switcher
-(void)generateThumbnail:(id)sender
{
    UISwitch *theSwitch = sender;
    BOOL genThumb = theSwitch.on;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSNumber numberWithBool:genThumb] forKey:sysGenerateThumbnail];
    [userDefaults synchronize];
}

#pragma mark - Passcode enable/disable
-(void)passcodeStatusChange:(id)sender
{
    
    //get passcode 
    NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:sysPasscodeNumber];
    
    if([passcode isEqualToString:@"-1"])
    {
        //passcode is never setted we want to set new passcode
        MDPasscodeViewController *passcodeController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDPasscodeViewController"];
        
        passcodeController.theDelegate = self;
        
        [self.navigationController presentViewController:passcodeController animated:YES completion:nil];
        
    }
    else
    {
        //ask user to input last passcode for futher action
        MDPasscodeViewController *passcodeController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDPasscodeViewController"];
        
        passcodeController.passcodeToCheck =passcode;
        passcodeController.theDelegate = self;
        
        [self.navigationController presentViewController:passcodeController animated:YES completion:nil];
    }
    
}

#pragma mark - Change Passcode
-(void)changePasscode
{
    NSString *oldPasscode = [[NSUserDefaults standardUserDefaults] stringForKey:sysPasscodeNumber];
    
    changePasscodeController = [[MDChangePasscodeController alloc] initWithOldPasscode:oldPasscode];
    
    changePasscodeController.theDelegate = self;
    
    [changePasscodeController presentInViewController:self.navigationController];
}

#pragma mark - MDPasscodeViewController delegate
-(void)MDPasscodeViewControllerDidCancel:(MDPasscodeViewController *)controller
{
    //[self.tableView reloadData];
    [self reloadTableViewSection:3 WithAnimation:YES];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)MDPasscodeViewControllerInputPasscodeIsCorrect:(MDPasscodeViewController *)controller
{
    //get old passcode status
    BOOL statusNow = [[NSUserDefaults standardUserDefaults] boolForKey:sysPasscodeStatus];
    
    //set new passcode status
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:!statusNow] forKey:sysPasscodeStatus];
    [userDefaults synchronize];
    
    //[self.tableView reloadData];
    [self reloadTableViewSection:3 WithAnimation:YES];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)MDPasscodeViewControllerInputPasscodeIsIncorrect:(MDPasscodeViewController *)controller
{
    NSString *msg = NSLocalizedString(@"Invalid passcode", @"Invalid passcode");
    UIAlertView *incorrectAlert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
    
    [incorrectAlert show];
    
    //reset passcode
    [controller resetPasscode];
}

-(void)MDPasscodeViewController:(MDPasscodeViewController *)controller didReceiveNewPasscode:(NSString *)newPasscode
{
   //get old passcode status
    BOOL statusNow = [[NSUserDefaults standardUserDefaults] boolForKey:sysPasscodeStatus];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //set new passcode status
    [userDefaults setObject:[NSNumber numberWithBool:!statusNow] forKey:sysPasscodeStatus];
    
    //set new passcode number
    [userDefaults setObject:newPasscode forKey:sysPasscodeNumber];
    [userDefaults synchronize];
    
    //[self.tableView reloadData];
    [self reloadTableViewSection:3 WithAnimation:YES];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MDChangePasscodeController delegate
-(void)MDChangePasscodeControllerDidCancel:(MDChangePasscodeController *)controller
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    changePasscodeController = nil;
}

-(void)MDChangePasscodeController:(MDChangePasscodeController *)controller shouldChangePasscodeTo:(NSString *)newPasscode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:newPasscode forKey:sysPasscodeNumber];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    changePasscodeController = nil;
}

@end
