//
//  MDUnzipViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDUnarchiveViewController.h"
#import "MDUnarchiveNavigationController.h"
#import "MDFileSupporter.h"

@interface MDUnarchiveViewController ()

-(void)findContentDirectoriesInWorkingPath:(NSString *)path;
-(void)configureCell:(UITableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath;
-(void)customizedNavigationBar;
-(void)createToolBar;
-(void)cancel;
-(void)unarchive;

@end

@implementation MDUnarchiveViewController{
    
    MDFileSupporter *fileSupporter;
    
    //contain string directory name
    NSMutableArray *directoryArray;
    
    UIToolbar *theToolBar;
}

@synthesize workingPath = _workingPath;
@synthesize controllerTitle = _controllerTitle;

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

-(void)dealloc
{
    self.workingPath = nil;
    self.controllerTitle = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.title = self.controllerTitle;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     we add tool bar to view here because we want it to be on this view controller
     then we add to navigation controller's view
     **/
    
    [self.navigationController.view addSubview:theToolBar];
    
    /**
     we do not create navigation bar's right buttons at viewDidLoad
     since at that point new controller's(this controller) navigation item has not 
     been added yet, therefore we done creation in viewDidAppear.
     
     When viewDidAppear new navigation item is already added
     **/
    [self customizedNavigationBar];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //self.title = NSLocalizedString(@"Back", @"Back");
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //we need to remove tool bar
    [theToolBar removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    fileSupporter = [MDFileSupporter sharedFileSupporter];
    
    [self findContentDirectoriesInWorkingPath:self.workingPath];
    
    //[self customizedNavigationBar];
    
    [self createToolBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    directoryArray = nil;
    theToolBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [directoryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UnarchiveCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        //create one if needed
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [self configureCell:cell WithIndexPath:indexPath];
    
    return cell;
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
    
    //get selected directory full path
    NSString *selectedDirectoryName = [directoryArray objectAtIndex:indexPath.row];
    NSString *directoryPath = [self.workingPath stringByAppendingPathComponent:selectedDirectoryName];
    
    MDUnarchiveViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MDUnarchiveViewController"];
    
    //set working path
    controller.workingPath = directoryPath;
    //set controller title
    controller.controllerTitle = selectedDirectoryName;
    
    //push view controller
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Configure cell
-(void)configureCell:(UITableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
    //get directory name
    NSString *cellText =[directoryArray objectAtIndex:indexPath.row];
    cellText = [cellText stringByAppendingString:@" /"];
    
    cell.textLabel.text = cellText;
    
    //set accessory type since there are all directory DisclosureIndicator will be fine
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Find content directories in working path
-(void)findContentDirectoriesInWorkingPath:(NSString *)path
{
    NSError *error;
    
    if(directoryArray == nil)
    {
        //create one if needed
        directoryArray = [[NSMutableArray alloc] init];
    }
    
    //we need to clear array each time we start to find content directories
    if([directoryArray count] != 0)
    {
        //clear first
        [directoryArray removeAllObjects];
    }
    
    //find contents
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if(error == nil)
    {
        //store content
        for(NSString *theContent in contents)
        {
            if([fileSupporter canShowFileName:theContent])
            {
                NSString *filePath = [self.workingPath stringByAppendingPathComponent:theContent];
                
                //check filePath is a directory or not
                //get file attributes
                NSDictionary *fileAttributs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                
                if(error != nil)
                {
                    NSLog(@"There is an error while check the path is a directory path: %@", filePath);
                    return;
                }
                
                if([[fileAttributs objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory])
                {
                    //file is directory path add directory name to array
                    [directoryArray addObject:[NSString stringWithString:theContent]];
                }
            }
            
        }
    }
    else
    {
        NSLog(@"There is a error while getting content directories at %@\n error:%@ ", self.workingPath, error);
    }
}

#pragma mark - Customized navigation bar
-(void)customizedNavigationBar
{
    //get navigation item which current controller has
    UINavigationItem *navItem = [self.navigationController.navigationBar.items lastObject];
    
    navItem.title = self.controllerTitle;
    
    if(navItem.rightBarButtonItem != nil)
        return;
    
    //create cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    navItem.rightBarButtonItem = cancelButton;
}

#pragma mark - Create tool bar
-(void)createToolBar
{
    if(theToolBar == nil)
    {
        //436 = 480 - 44
        theToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 436, 320, 44)];
        
        UIBarButtonItem *moveToButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Unarchive here", @"Unarchive here") style:UIBarButtonItemStyleDone target:self action:@selector(unarchive)];
        
        NSArray *items = [NSArray arrayWithObjects:moveToButton, nil];
        
        theToolBar.items = items;
    }
}

#pragma mark - cancel method
-(void)cancel
{
    //tell navigation controller to dismiss
    MDUnarchiveNavigationController *controller = (MDUnarchiveNavigationController*)self.navigationController;
    
    [controller dismissNavigationController];
}

#pragma mark - unarchive method
-(void)unarchive
{
    //tell navigation controller to unarchive file
    MDUnarchiveNavigationController *controller = (MDUnarchiveNavigationController*)self.navigationController;
    
    [controller unarchiveTo:self.workingPath];
}

@end
