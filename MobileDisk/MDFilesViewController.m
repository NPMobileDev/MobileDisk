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
-(void)createNaviRightButton;
-(void)showToolBar;
-(void)hideToolBar;
-(void)addFolder;
-(void)reloadTableViewData;
-(void)renameFiles;
-(void)filesAction;
-(void)updateToolBar;
-(BOOL)doAddFolderAtPath:(NSString *)workingPath WithFolderName:(NSString *)folderName;
-(void)doRenameFile;
-(void)doDeleteSelect;
-(void)doDeselectAll;
-(void)doSelectAll;

@end

const float ToolBarAnimationDuration = 0.1f;

@implementation MDFilesViewController{
    
    
    enum EditingStatus theStatus;
    
    //hold a set of string that is file name will be not be show on table view
    NSArray *hiddenFiles;
    
    //the content in current directory
    NSMutableArray *filesArray;
    
    //store selected indexpath
    NSMutableArray *selectedIndexPaths;
    
    //toolbar
    UIToolbar *toolbar;
    
    //text field to type in name for new folder
    UITextField *newFolderNameTextField;
    
    //text field to type in name for new folder
    UITextField *renameFileTextField;
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
    
    [self.tableView setEditing:NO animated:YES];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
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
    
    if(hiddenFiles == nil)
    {
        //add any file's name that will not show on table view
        hiddenFiles = [NSArray arrayWithObjects:@".DS_Store", nil];
    }
    
    if(filesArray == nil)
    {
        [self findContentInWorkingPath:self.workingPath];
    }
    
    //creat navigation right button
    [self createNaviRightButton];
    
    //create tool bar
    [self createToolBar];
    
    theStatus = StatusNone;
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

#pragma mark - Create navigation right button
-(void)createNaviRightButton
{
    /**we want two bar buttons on right side of navigation bar**/
    
    //edit button
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableView)];
    
    //refresh button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTableViewData)];
    
    //create a tool bar 
    UIToolbar *rightToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 90, 44.01)];
    rightToolBar.items = [NSArray arrayWithObjects:editButton, refreshButton, nil];
    
    //create right button with tool bar in it
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightToolBar];
    
    self.navigationItem.rightBarButtonItem = rightButton;
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
        //add Add folder item
        UIBarButtonItem *addFolderButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add folder", @"Add folder") style:UIBarButtonItemStyleDone target:self action:@selector(addFolder)];
        
        //add Rename item
        UIBarButtonItem *renameButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Rename", @"Rename") style:UIBarButtonSystemItemAction target:self action:@selector(renameFiles)];
        
        //add action item
        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(filesAction)];
               
        
        NSArray *buttonItems = [NSArray arrayWithObjects:addFolderButton, renameButton, actionButton, nil];
        toolbar.items = buttonItems;
    }
    
    [self updateToolBar];
}

-(void)updateToolBar
{
    UIBarButtonItem *renameButton = [toolbar.items objectAtIndex:1];
    
    if(selectedIndexPaths == nil || [selectedIndexPaths count] != 1)
    {
        
        renameButton.enabled = NO;
    }
    else
    {
        renameButton.enabled = YES;
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
    
    return [filesArray count];
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
    MDFiles *file = [filesArray objectAtIndex:indexPath.row];
    
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
        
        [self updateToolBar];
    }

}

#pragma mark - Find content in working path
-(void)findContentInWorkingPath:(NSString *)path
{
    NSError *error;
    
    filesArray = [[NSMutableArray alloc] init];
    
    //find contents
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if(error == nil)
    {
        //store content
        for(NSString *theContent in contents)
        {
            if([self canShowFileWithName:theContent])
            {
                //init file info object
                MDFiles *file = [[MDFiles alloc] initWithFilePath:self.workingPath FileName:theContent];
                
                //add to diectoryContents
                [filesArray addObject:file];
            }

        }
    }
    else
    {
        NSLog(@"There is a error while getting content at %@\n error:%@ ", self.workingPath, error);
    }
}

//can given file name be shown on table view?
-(BOOL)canShowFileWithName:(NSString *)filename
{
    for(NSString *hiddenFile in hiddenFiles)
    {
        if([filename isEqualToString:hiddenFile])
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Configure cell
-(void)configureCell:(MDFilesTableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
    MDFiles *file = [filesArray objectAtIndex:indexPath.row];

    
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
    
    /**Here we cnage edit button to done button**/
    //get right tool bar on navigation bar
    UIToolbar *rightToolBar = (UIToolbar*)self.navigationItem.rightBarButtonItem.customView;
    
    //disable refresh button
    UIBarButtonItem *refreshButton = [rightToolBar.items objectAtIndex:1];
    refreshButton.enabled = NO;
    
    //get back second button(refresh) from tool bar and create a items
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:refreshButton, nil];
    
    //create done button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditTabelView)];
    
    //insert done button to first element in items
    [items insertObject:doneButton atIndex:0];
    
    //reassign button to tool bar
    [rightToolBar setItems:items animated:YES];
    
    
    //allow table selection while editing
    self.tableView.allowsSelectionDuringEditing = YES;
    
    //show tool bar
    [self showToolBar];
}

-(void)doneEditTabelView
{
    NSLog(@"Done editing table");
    
    [self.tableView setEditing:NO animated:YES];
    
    
    /**Here we cnage done button to edit button**/
    //get right tool bar on navigation bar
    UIToolbar *rightToolBar = (UIToolbar*)self.navigationItem.rightBarButtonItem.customView;
    
    //enable refresh button
    UIBarButtonItem *refreshButton = [rightToolBar.items objectAtIndex:1];
    refreshButton.enabled = YES;
    
    //get back second button(refresh) from tool bar and create a items
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:refreshButton, nil];
    
    //create edit button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableView)];
    
    //insert edit button to first element in items
    [items insertObject:rightButton atIndex:0];
    
    //reassign button to tool bar
    [rightToolBar setItems:items animated:YES];
    
    
    self.tableView.allowsSelectionDuringEditing = NO;
    
    //hide tool bar
    [self hideToolBar];
    
    
    //clear all selected cell index path from array
    if(selectedIndexPaths != nil)
    {
        for(NSIndexPath *indexPath in selectedIndexPaths)
        {
            //set file isSelected to NO
            MDFiles *file = [filesArray objectAtIndex:indexPath.row];
            
            file.isSelected = NO;
            
            //reset cell selected indicator image as well
            MDFilesTableViewCell *cell = (MDFilesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            UIImageView *selectedIndicator = cell.selectionIndicator;
            
            selectedIndicator.image = [UIImage imageNamed:cell.notSelectedIndicatorName];
        }
        
        [selectedIndexPaths removeAllObjects];
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
    
    //change status to add folder
    theStatus = StatusAddFolder;
}

-(void)renameFiles
{
    if(renameFileTextField == nil)
    {
        renameFileTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        renameFileTextField.placeholder = NSLocalizedString(@"New name", @"New name");
        renameFileTextField.backgroundColor = [UIColor whiteColor];
        renameFileTextField.borderStyle = UITextBorderStyleRoundedRect;
        renameFileTextField.text = nil;
    }
    
    //use alert view to let user to type in new name
    UIAlertView *renameAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rename", @"Rename") message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Rename", @"Rename"), nil];
    
    [renameAlert addSubview:renameFileTextField];
    [renameAlert show];
    
    [renameFileTextField becomeFirstResponder];
    
    //change status to rename
    theStatus = StatusRename;
}

-(void)filesAction
{
    NSString *deselectAllButton = NSLocalizedString(@"Deselect all", @"Deselect all");
    NSString *selectAllButton = NSLocalizedString(@"Select all", @"Select all");
    NSString *moveButton = NSLocalizedString(@"Move", @"Move");
    
    if([selectedIndexPaths count] != 0)
    {
        //user has select more than one file

        
        UIActionSheet *selectedActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Action", @"Action") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete", @"Delete") otherButtonTitles:deselectAllButton, selectAllButton, moveButton, nil];
        
        [selectedActionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    else
    {
        //user did not select any of file
        UIActionSheet *nonSelectedActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Action", @"Action") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:selectAllButton, nil];
        
        [nonSelectedActionSheet showFromTabBar:self.tabBarController.tabBar];
        
    }
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([selectedIndexPaths count] != 0)
    {
        /**user has select more than one file**/
        if(buttonIndex == 0)
        {
            /**delete selected**/
            [self doDeleteSelect];
        }
        else if(buttonIndex == 1)
        {
            /**deselect all**/
            [self doDeselectAll];
        }
        else if(buttonIndex == 2)
        {
            /**select all action**/
            [self doSelectAll];
        }
        else if(buttonIndex == 3)
        {
            //move files
        }
        
    }
    else
    {
        /**user did not select any of file**/
        if(buttonIndex == 0)
        {
            /**select all action**/
            [self doSelectAll];

        }
    }
}

#pragma mark - Add folder UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(theStatus == StatusAddFolder)
    {
        if(buttonIndex == 1)
        {
            //check if text field's text is empty
            if([newFolderNameTextField.text isEqualToString:@""])
            {
                UIAlertView *addFolderinvaildAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"You have to give a name for a new folder", @"You have to give a name for a new folder") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                
                [addFolderinvaildAlert show];
            }
            else
            {
                //create folder
                BOOL success =[self doAddFolderAtPath:self.workingPath WithFolderName:newFolderNameTextField.text];
                
                if(success)
                {
                    //reload table view data
                    //[self reloadTableViewData];
                    //we don't reload whole data instead of adding a new file to data and add a cell to table
                    MDFiles *file = [[MDFiles alloc] initWithFilePath:self.workingPath FileName:newFolderNameTextField.text];
                    
                    [filesArray addObject:file];
                    
                    //insert cell to table view
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[filesArray count]-1 inSection:0];
                    
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            
            //clear text field
            newFolderNameTextField.text = nil;
            
            //change status to none
            theStatus = StatusNone;
        }
    }
    else if(theStatus == StatusRename)
    {
        if(buttonIndex == 1)
        {
            //check if text field's text is empty
            if([renameFileTextField.text isEqualToString:@""])
            {
                UIAlertView *renameInvaildAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Name can not be blank", @"Name can not be blank") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                
                [renameInvaildAlert show];
            }
            else
            {
                
                NSString *checkedFilePath = [self.workingPath stringByAppendingPathComponent:renameFileTextField.text];
                
                //check if name has been used 
                if([[NSFileManager defaultManager] fileExistsAtPath:checkedFilePath])
                {
                    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"The name %@ had been used", @"The name %@ had been used"), renameFileTextField.text];
                    
                    UIAlertView *duplicateNameAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
                    
                    [duplicateNameAlert show];
                }
                else
                {
                    /**Rename**/
                    [self doRenameFile];

                }
            }
        }
        
        theStatus = StatusNone;
    }

}

#pragma mark - UIActionSheet delegate related methods
-(void)doDeleteSelect
{
    
    //check if there at least one file selected 
    if([selectedIndexPaths count] != 0)
    {
        //go through each selected IndexPath
        for(NSIndexPath *indexPath in selectedIndexPaths)
        {
            NSError *error;
            
            MDFiles *file = [filesArray objectAtIndex:indexPath.row];
            
            //delete file
            [[NSFileManager defaultManager] removeItemAtPath:file.filePath error:&error];
            
            if(error != nil)
            {
                NSLog(@"There is an error %@ while deleting file at path %@", error, file.filePath);
            }
        }
        
        //clrear selected IndexPaths
        [selectedIndexPaths removeAllObjects];
    }
    else
    {
        NSLog(@"no selected file IndexPath to perform delete action");
    }
    
    [self reloadTableViewData];
}

-(void)doDeselectAll
{
    //check if there at least one file selected
    if([selectedIndexPaths count] != 0)
    {
        //go through each selected IndexPath
        for(NSIndexPath *indexPath in selectedIndexPaths)
        {
            MDFiles *file = [filesArray objectAtIndex:indexPath.row];
            file.isSelected = NO;
            
            MDFilesTableViewCell *cell = (MDFilesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            UIImageView *selectedIndicator = cell.selectionIndicator;
            
            selectedIndicator.image = [UIImage imageNamed:cell.notSelectedIndicatorName];
        }
        
        //clrear selected IndexPaths
        [selectedIndexPaths removeAllObjects];
    }
    else
    {
        NSLog(@"no file selected to perform deselect all action");
    }
}

-(void)doSelectAll
{
    if(selectedIndexPaths == nil)
    {
        selectedIndexPaths = [[NSMutableArray alloc] init];
    }
    
    if([selectedIndexPaths count] != 0)
    {
        //clear selected IndexPaths first
        [selectedIndexPaths removeAllObjects];
    }
    
    //go through each file
    for(int i=0; i<[filesArray count]; i++)
    {
        //make file selected
        MDFiles *file = [filesArray objectAtIndex:i];
        file.isSelected = YES;
        
        //store into selected indexs
        
        NSIndexPath *selectedIndex = [NSIndexPath indexPathForRow:i inSection:0];
        
        [self addSelectEditableCellAtIndexPath:selectedIndex];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UIAlertView delegate related methods
//path should not contain folder name
-(BOOL)doAddFolderAtPath:(NSString *)workingPath WithFolderName:(NSString *)folderName
{
    NSError *error;
    
    NSString *fullPath = [workingPath stringByAppendingPathComponent:folderName];
    
    //check if folder name exists or not
    if([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
    {
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"The folder %@ already exists", @"The folder exists"), folderName];
        //file exists
        UIAlertView *existAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
        
        [existAlert show];
        
        return NO;
    }
    else 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if(error != nil)
        {
            NSLog(@"There is an error while creating a directory %@, at path %@", folderName, workingPath);
            
            return NO;
        }
        
        return YES;
    }
    
}

-(void)doRenameFile
{
    NSError *error;
    NSIndexPath *indexPath = [selectedIndexPaths lastObject];
    MDFiles *file = [filesArray objectAtIndex:indexPath.row];
    NSString *fileExtension = nil;
    NSString *newPath;
    NSString *newFileName;
    
    //if it is file get back file extension that mean .xxx
    if(file.isFile)
    {
        NSArray *splitString = [file.filePath componentsSeparatedByString:@"."];
        fileExtension = [splitString lastObject];
    }
    
    //find new file path
    if(fileExtension != nil)
    {
        //it is file 
        newFileName = [NSString stringWithFormat:@"%@.%@", renameFileTextField.text, fileExtension];
        newPath = [self.workingPath stringByAppendingPathComponent:newFileName];
    }
    else
    {
        //it is directory
        newPath = [self.workingPath stringByAppendingPathComponent:renameFileTextField.text];
    }
    
    //use move item to rename
    [[NSFileManager defaultManager] moveItemAtPath:file.filePath toPath:newPath error:&error];
    
    if(error != nil)
    {
        NSLog(@"There is an error while rename file error:%@", error);
    }
    
    //since move item will create new file we need to delete old one
    [[NSFileManager defaultManager] removeItemAtPath:file.filePath error:&error];
    
    
    MDFiles *newfile;
    //create a new file representation
    if(fileExtension != nil)
    {
        newfile = [[MDFiles alloc] initWithFilePath:self.workingPath FileName:newFileName];
    }
    else
    {
        newfile = [[MDFiles alloc] initWithFilePath:self.workingPath FileName:renameFileTextField.text];
    }
    
    int objectIndex = [filesArray indexOfObject:[filesArray objectAtIndex:indexPath.row]];
    
    //remove old file representation from files array
    [filesArray removeObjectAtIndex:indexPath.row];
    
    //delete cell
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    //insert new file representation
    [filesArray insertObject:newfile atIndex:indexPath.row];
    
    NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:objectIndex inSection:0]];
    
    //insert cell
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    
    //finally we remove selected IndexPath
    [selectedIndexPaths removeAllObjects];
}

@end
