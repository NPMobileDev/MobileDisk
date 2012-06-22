//
//  MDFilesViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDFilesViewController.h"
#import "MDFiles.h"
#import "MDFilesTableViewCell.h"

@interface MDFilesViewController ()

-(void)findContentInWorkingPath:(NSString *)path;
-(void)configureCell:(MDFilesTableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath;
-(void)addSelectEditableCellAtIndexPath:(NSIndexPath *)indexPath;
-(void)deleteSelectEditableCellAtIndexPath:(NSIndexPath *)indexPath;
-(void)createToolBar;
-(void)showToolBar;
-(void)hideToolBar;
-(void)addFolder;
-(BOOL)AddFolderAtPath:(NSString *)path WithFolderName:(NSString *)folderName;
-(void)reloadTableViewData;

@end

const float ToolBarAnimationDuration = 0.1f;

@implementation MDFilesViewController{
    
    
    //the content in current directory
    NSMutableArray *directoryContents;
    
    //store selected indexpath
    NSMutableArray *selectedIndexPaths;
    
    //toolbar
    UIToolbar *toolbar;
    
    //text field to type in name for new folder
    UITextField *newFolderNameTextField;
}

@synthesize workingPath = _workingPath;
@synthesize controllerTitle = _controllerTitle;

#pragma mark - Override methods 
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.controllerTitle;
    
    [self findContentInWorkingPath:self.workingPath];
    
    [self.tableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     we add tool bar to view here because we want it to be on this view controller
     then we add to navigation controller's view
     **/
    [self.navigationController.view addSubview:toolbar];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.title = NSLocalizedString(@"Back", @"Back");
    
    //we need to remove tool bar
    [toolbar removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if(directoryContents == nil)
    {
        [self findContentInWorkingPath:self.workingPath];
    }
    
    //add edit right button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableView)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //create tool bar
    [self createToolBar];
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

#pragma mark - Create tool bar
-(void)createToolBar
{
    //create tool bar
    if(toolbar == nil)
    {
        /**
         use design tool to find out position 431=480(iphone height)-49(tabbar height)
         tool bar is behide tabbar at beginning
         **/
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 431, 320, 44)];
        
        //add tool bar items
        //add Add folder items
        UIBarButtonItem *addFolderButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add folder", @"Add folder") style:UIBarButtonItemStyleDone target:self action:@selector(addFolder)];
               
        
        NSArray *buttonItems = [NSArray arrayWithObjects:addFolderButton, nil];
        toolbar.items = buttonItems;
    }
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [directoryContents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MDFilesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        //create cell
        cell = [[MDFilesTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withTableView:tableView];     
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
/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return indexPath;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    MDFiles *file = [directoryContents objectAtIndex:indexPath.row];
    
    //check table is in editing mode
    if(!tableView.isEditing)
    {
        
        if(!file.isFile)
        {
            //is a directory
            //instantiate a MDFilesViewController
            MDFilesViewController *fileController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDFilesViewController"];
            
            //set property
            fileController.workingPath = [self.workingPath stringByAppendingPathComponent:file.fileName];
            fileController.controllerTitle = file.fileName;
            
            //push view controller
            [self.navigationController pushViewController:fileController animated:YES];
            
        }
    }
    else
    {
        //is in editing mode
        
        //get cell
        MDFilesTableViewCell *cell = (MDFilesTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        UIImageView *selectedIndicator = cell.selectionIndicator;
        
        if(file.isSelected) 
        {
           //file was selected make it deselected
            selectedIndicator.image = [UIImage imageNamed:cell.notSelectedIndicatorName];
            
           //make file deselected
            file.isSelected = NO;
            
            [self deleteSelectEditableCellAtIndexPath:indexPath];
        }
        else
        {
            //file was not selected make it selected
            selectedIndicator.image = [UIImage imageNamed:cell.selectedIndicatorName];
            
            //make file selected
            file.isSelected = YES;
            
            [self addSelectEditableCellAtIndexPath:indexPath];
        }
        
    }

}

#pragma mark - Find content in working path
-(void)findContentInWorkingPath:(NSString *)path
{
    NSError *error;
    
    directoryContents = [[NSMutableArray alloc] init];
    
    //find contents
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if(error == nil)
    {
        //store content
        for(NSString *theContent in contents)
        {
            NSString *filePath = [self.workingPath stringByAppendingPathComponent:theContent];
            
            //init file info object
            MDFiles *file = [[MDFiles alloc] initWithFilePath:filePath FileName:theContent];
            
            //add file object to array
            [directoryContents addObject:file];
        }
    }
    else
    {
        NSLog(@"There is a error while getting content at %@\n error:%@ ", self.workingPath, error);
    }
}

#pragma mark - Configure cell
-(void)configureCell:(MDFilesTableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
    MDFiles *file = [directoryContents objectAtIndex:indexPath.row];

    
    if(file.isFile)
    {
        cell.textLabel.text = file.fileName;
    }
    else
    {
        //is a folder
        cell.textLabel.text = [file.fileName stringByAppendingString:@" /"];
    }
    
    if(file.isFile)
    {
        //is a file 
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"File size: %@", @"File size string format"), file.fileSizeString];
    }
    
    if(!file.isFile)
    {
        //is directory
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //set image for selected and not selected for edit mode
    UIImageView *selectIndicator = cell.selectionIndicator;
    if(file.isSelected)
    {

        selectIndicator.image = [UIImage imageNamed:cell.selectedIndicatorName];
    }
    else
    {
        selectIndicator.image = [UIImage imageNamed:cell.notSelectedIndicatorName];
    }
    
}

-(void)addFileForTableViewWithFilePath:(NSString *)filePath AndFileName:(NSString *)filename
{
    //init file info object
    MDFiles *file = [[MDFiles alloc] initWithFilePath:filePath FileName:filename];
    
    //add file object to array
    [directoryContents addObject:file];
    
    //insert cell to table view
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[directoryContents count]-1 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Reload table view data
-(void)reloadTableViewData
{
    [self findContentInWorkingPath:self.workingPath];
    
    [self.tableView reloadData];
}

#pragma mark - Edit table view
-(void)editTableView
{
    NSLog(@"Editing table");
    [self.tableView setEditing:YES animated:YES];
    
    //add cancel right button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditTabelView)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //allow table selection while editing
    self.tableView.allowsSelectionDuringEditing = YES;
    
    //show tool bar
    [self showToolBar];
}

-(void)doneEditTabelView
{
    NSLog(@"Done editing table");
    
    [self.tableView setEditing:NO animated:YES];
    
    //add edit right button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableView)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.tableView.allowsSelectionDuringEditing = NO;
    
    //hide tool bar
    [self hideToolBar];
    
    
    //clear all selected cell index path from array
    if(selectedIndexPaths != nil)
    {
        for(NSIndexPath *indexPath in selectedIndexPaths)
        {
            //set file isSelected to NO
            MDFiles *file = [directoryContents objectAtIndex:indexPath.row];
            
            file.isSelected = NO;
            
            //reset cell selected indicator image as well
            MDFilesTableViewCell *cell = (MDFilesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            UIImageView *selectedIndicator = cell.selectionIndicator;
            
            selectedIndicator.image = [UIImage imageNamed:cell.notSelectedIndicatorName];
        }
        
        selectedIndexPaths = nil;
    }
}

//take care add  cell selection in table view edit mode
-(void)addSelectEditableCellAtIndexPath:(NSIndexPath *)indexPath
{
    //store selected index path in array
    if(selectedIndexPaths ==nil)
    {
        selectedIndexPaths = [[NSMutableArray alloc] init];
    }
    
    /**
        here logical is to remove object first to make sure there is no duplicated object
        then we add object into array
     **/
    [selectedIndexPaths removeObject:indexPath];
    [selectedIndexPaths addObject:indexPath];
    
}
//take care delete cell selection in table view edit mode
-(void)deleteSelectEditableCellAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedIndexPaths != nil)
    {
        [selectedIndexPaths removeObject:indexPath];
    }
}

//show tool bar
-(void)showToolBar
{
    //tool bar frame
    CGRect toolbarFrame = toolbar.frame;
    toolbarFrame.origin.y -= toolbar.frame.size.height;
    
    //table view frame
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height -= toolbar.frame.size.height;
    
    //give animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ToolBarAnimationDuration];
    
    toolbar.frame = toolbarFrame;
    self.tableView.frame = tableViewFrame;
    
    [UIView commitAnimations];
}

//hide tool bar
-(void)hideToolBar
{
    //tool bar frame
    CGRect toolbarFrame = toolbar.frame;
    toolbarFrame.origin.y += toolbar.frame.size.height;
    
    //table view frame
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height += toolbar.frame.size.height;

    //give animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ToolBarAnimationDuration];
    
    toolbar.frame = toolbarFrame;
    self.tableView.frame = tableViewFrame;
    
    [UIView commitAnimations];
}

#pragma mark - ToolBar items' method
-(void)addFolder
{
    /**
        create text field if needed
     **/
    if(newFolderNameTextField == nil)
    {
        newFolderNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        newFolderNameTextField.placeholder = NSLocalizedString(@"Folder name", @"Folder name");
        newFolderNameTextField.backgroundColor = [UIColor whiteColor];
        newFolderNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        newFolderNameTextField.text = nil;
    }
    
    //use alert view to let user to type in folder name
    UIAlertView *addFolderAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add folder", @"Add folder") message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Add", @"Add"), nil];
    
    [addFolderAlert addSubview:newFolderNameTextField];
    [addFolderAlert show];
    
    [newFolderNameTextField becomeFirstResponder];
}

#pragma mark - Add folder UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //check if text field's text is empty
        if([newFolderNameTextField.text isEqualToString:@""])
        {
            UIAlertView *invaildAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"You have to give a name for a new folder", @"You have to give a name for a new folder") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
            
            [invaildAlert show];
        }
        else
        {
            //create folder
            BOOL success =[self AddFolderAtPath:self.workingPath WithFolderName:newFolderNameTextField.text];
            
            if(success)
            {
                //reload table view data
                //[self reloadTableViewData];
                NSString *filePath = [self.workingPath stringByAppendingPathComponent:newFolderNameTextField.text];
                
                [self addFileForTableViewWithFilePath:filePath AndFileName:newFolderNameTextField.text];
            }
        }
        
        //clear text field
        newFolderNameTextField.text = nil;
        
    }
}

#pragma mark - Add folder method
//path should not contain folder name
-(BOOL)AddFolderAtPath:(NSString *)path WithFolderName:(NSString *)folderName
{
    NSError *error;
    
    NSString *fullPath = [path stringByAppendingPathComponent:folderName];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if(error != nil)
    {
        NSLog(@"There is an error while creating a directory %@, at path %@", folderName, path);
        
        return NO;
    }
    
    return YES;
    
}

@end
