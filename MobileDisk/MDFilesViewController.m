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
#import "MDFileSupporter.h"


@interface MDFilesViewController ()

-(void)findContentInWorkingPath:(NSString *)path;
-(void)addSelectEditableCellAtIndexPath:(NSIndexPath *)indexPath;
-(void)deleteSelectEditableCellAtIndexPath:(NSIndexPath *)indexPath;
-(void)createToolBar;
-(void)customizedNavigationBar;
-(void)showToolBar;
-(void)hideToolBar;
-(void)addFolder;
-(void)reloadTableViewData;
-(void)renameFiles;
-(void)filesAction;
-(void)updateToolBar;
-(BOOL)doAddFolderAtPath:(NSString *)workingPath WithFolderName:(NSString *)folderName;
-(void)doRenameFileWithName:(NSString *)name;
-(void)doDeleteSelect;
-(void)doDeselectAll;
-(void)doSelectAll;
-(void)doMoveFiles;
-(void)doMoveFiles:(NSArray *)filesToMove ToDestinationPath:(NSString *)destPath;
-(void)prepareNavigationBarButtonsForEditTable;
-(void)prepareNavigationBarButtonsForDoneEditingTable;

@end

const float ToolBarAnimationDuration = 0.1f;

@implementation MDFilesViewController{
    
    
    id currentAction;
    
    //the content in current directory
    NSMutableArray *filesArray;
    
    //store selected indexpath
    NSMutableArray *selectedIndexPaths;
    
    //toolbar
    UIToolbar *toolbar;
    
    //flag determind if is in move file mode
    BOOL isMovingFiles;
    
    MDFileSupporter *fileSupporter;

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
    self.controllerTitle = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.title = self.controllerTitle;
    
    [self reloadTableViewData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     we do not create navigation bar's right buttons at viewDidLoad
     since at that point new controller's(this controller) navigation item has not 
     been added yet, therefore we done creation in viewDidAppear.
     
     When viewDidAppear new navigation item is already added
     **/
    [self customizedNavigationBar];
    
    /**
     we add tool bar to view here because we want it to be on this view controller
     then we add to navigation controller's view
     **/
    [self.navigationController.view addSubview:toolbar];
   
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(isMovingFiles != YES)
    {
        //self.title = NSLocalizedString(@"Back", @"Back");
        
        if(self.tableView.isEditing)
            [self doneEditTabelView];
        
    }
  
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
    
    
    /**
     We don't do "findContentInWorkingPath" but we call "reloadTableViewData"
      in viewWillAppear. This can avoid double processing. "findContentInWorkingPath"
     called in "reloadTableViewData"
     **/
    
    //find content in working path
    //[self findContentInWorkingPath:self.workingPath];
    
    //creat navigation right button
    //[self customizedNavigationBar];
    
    fileSupporter = [MDFileSupporter sharedFileSupporter];
    
    //create tool bar
    [self createToolBar];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress setDelegate:self];
    
    [self.tableView addGestureRecognizer:longPress];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    filesArray = nil;
    toolbar =nil;
    currentAction = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//used for UIMenuController
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Long press gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //get touch point
    CGPoint touchPoint = [gestureRecognizer locationInView:self.tableView];
    //get row index by touch point
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    if(indexPath == nil)
    {
        return NO;
    }
    
    
    MDFiles *file = [filesArray objectAtIndex:indexPath.row];
    
    //create UIMenuItem
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:file.fileName action:@selector(noActionSelector)];
    
    //show UIMenuController and setup 
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObject:menuItem]];
    [menu setTargetRect:CGRectMake(touchPoint.x, touchPoint.y, menu.menuFrame.size.width, menu.menuFrame.size.height) inView:self.tableView];

    [menu setMenuVisible:YES animated:YES];
    [menu update];
    
    return YES;
}

//used for create UIMenuItem
-(void)noActionSelector
{
    //a dummy selector
}

#pragma mark - Customized navigation bar
-(void)customizedNavigationBar
{
    /**we want two bar buttons on right side of navigation bar**/
    
    //get navigation item which current controller has
    UINavigationItem *navItem = [self.navigationController.navigationBar.items lastObject];
    
    navItem.title = self.controllerTitle;
    
    //prevent recreate button 
    if(navItem.rightBarButtonItem != nil)
        return;
    
    //edit button
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableView)];
    
    //refresh button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTableViewData)];
    refreshButton.style = UIBarButtonItemStyleBordered;
    
    //assign right buttons
    navItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton, editButton, nil];
    
    
    
    
    //old implement
    /*
    //create a tool bar 44.01 perfect fit
    UIToolbar *rightToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 90, 44.01)];
    rightToolBar.items = [NSArray arrayWithObjects:editButton, refreshButton, nil];
    
    //create right button with tool bar in it
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightToolBar];
    rightButton.style = UIBarButtonItemStylePlain;
    */
    
    //self.navigationItem.rightBarButtonItem = rightButton;
    
    
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
    static NSString *CellIdentifier = @"FilesCell";
    MDFilesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        //create cell
        cell = [[MDFilesTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withTableView:tableView];     
    }
    
    MDFiles *theFile = [filesArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell configureCellForFile:theFile];
    
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
        else
        {
            //is a file
            //check if file is supported
            if([fileSupporter isFileSupported:file.filePath])
            {
                UIViewController *theController = [fileSupporter findControllerToOpenFile:file.filePath WithStoryboard:self.storyboard];
                
                if(theController != nil)
                {
                    //present controller
                    [self.navigationController presentViewController:theController animated:YES completion:nil];
                    
                }
            }
            else
            {
                NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"The file \"%@\" can not be opened in this app", @"The file \"%@\" can not be opened in this app"), file.fileName];
                
                UIAlertView *notSupportAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Open file", @"Open file") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
                
                [notSupportAlert show];
            }
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    if(filesArray == nil)
    {
        //create one if needed
        filesArray = [[NSMutableArray alloc] init];
    }
    
    //we need to clear array each time we start to find content
    if([filesArray count] != 0)
    {
        //clear first
        [filesArray removeAllObjects];
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
    

    [self prepareNavigationBarButtonsForEditTable];
    
    //allow table selection while editing
    self.tableView.allowsSelectionDuringEditing = YES;
    
    //show tool bar
    [self showToolBar];
}

-(void)doneEditTabelView
{
    NSLog(@"Done editing table");
    
    [self.tableView setEditing:NO animated:YES];
    
    [self prepareNavigationBarButtonsForDoneEditingTable];
    
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
    
    [self updateToolBar];
}

-(void)prepareNavigationBarButtonsForEditTable
{
    //get topmost navigation item which current controller has
    UINavigationItem *navItem = [self.navigationController.navigationBar.items lastObject];
    
    //create done button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditTabelView)];
    
    //refresh button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTableViewData)];
    refreshButton.style = UIBarButtonItemStyleBordered;
    
    refreshButton.enabled = NO;
    
    NSArray *rightButtons = [NSArray arrayWithObjects:refreshButton, doneButton, nil];
    
    //reassign right buttons
    [navItem setRightBarButtonItems:rightButtons animated:YES];
    
    
    //old implement
    /**Here we cnage edit button to done button**/
    //get right tool bar on navigation bar
    //UIToolbar *rightToolBar = (UIToolbar*)self.navigationItem.rightBarButtonItem.customView;
    
    //disable refresh button
    //UIBarButtonItem *refreshButton = [rightToolBar.items objectAtIndex:1];
    //refreshButton.enabled = NO;
    
    //get back second button(refresh) from tool bar and create a items
    //NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:refreshButton, nil];
    
    //insert done button to first element in items
    //[items insertObject:doneButton atIndex:0];
    
    //reassign button to tool bar
    //[rightToolBar setItems:items animated:YES];
}

-(void)prepareNavigationBarButtonsForDoneEditingTable
{
    //get topmost navigation item which current controller has
    UINavigationItem *navItem = [self.navigationController.navigationBar.items lastObject];
    
    
    //create edit button
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableView)];
    
    //refresh button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTableViewData)];
    refreshButton.style = UIBarButtonItemStyleBordered;
    
    refreshButton.enabled = YES;
    
    NSArray * rightButtons = [NSArray arrayWithObjects:refreshButton, editButton, nil];
    
    //reassign right buttons
    [navItem setRightBarButtonItems:rightButtons animated:YES];
    
    
    //old implement
    /**Here we cnage done button to edit button**/
    //get right tool bar on navigation bar
    //UIToolbar *rightToolBar = (UIToolbar*)self.navigationItem.rightBarButtonItem.customView;
    
    //enable refresh button
    //UIBarButtonItem *refreshButton = [rightToolBar.items objectAtIndex:1];
    //refreshButton.enabled = YES;
    
    //get back second button(refresh) from tool bar and create a items
    // NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:refreshButton, nil];
    
    //insert edit button to first element in items
    //[items insertObject:rightButton atIndex:0];
    
    //reassign button to tool bar
    //[rightToolBar setItems:items animated:YES];
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
    
    MDAddFolderAlertView *action = [[MDAddFolderAlertView alloc] initAlertViewWithDelegate:self];
    [action showAlertView];
    
    currentAction = action;
    
}

-(void)renameFiles
{
    MDRenameAlertView *action = [[MDRenameAlertView alloc] initAlertViewWithDelegate:self];
    [action showAlertView];
    
    currentAction = action;
}

-(void)filesAction
{
    /*
    NSString *deselectAllButton = NSLocalizedString(@"Deselect all", @"Deselect all");
    NSString *selectAllButton = NSLocalizedString(@"Select all", @"Select all");
    NSString *moveButton = NSLocalizedString(@"Move", @"Move");
    */
    
    if([selectedIndexPaths count] != 0)
    {
        //user has select more than one file

        /*
        UIActionSheet *selectedActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Action", @"Action") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Delete", @"Delete") otherButtonTitles:deselectAllButton, selectAllButton, moveButton, nil];
        
        [selectedActionSheet showFromTabBar:self.tabBarController.tabBar];
         */
        
        MDSelectedActionSheet *action = [[MDSelectedActionSheet alloc] initActionSheetWithDelegate:self];
        
        [action showFromTabBar:self.tabBarController.tabBar];
        
        currentAction = action;
    }
    else
    {
        //user did not select any of file
        /*
        UIActionSheet *nonSelectedActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Action", @"Action") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:selectAllButton, nil];
        
        [nonSelectedActionSheet showFromTabBar:self.tabBarController.tabBar];
         */
        MDNonSelectedActionSheet *action = [[MDNonSelectedActionSheet alloc] initActionSheetWithDelegate:self];
    
        [action showFromTabBar:self.tabBarController.tabBar];
        
        currentAction = action;
        
    }
}

/*
#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([selectedIndexPaths count] != 0)
    {
        
        if(buttonIndex == 0)
        {
            
            [self doDeleteSelect];
        }
        else if(buttonIndex == 1)
        {
            
            [self doDeselectAll];
        }
        else if(buttonIndex == 2)
        {
            
            [self doSelectAll];
        }
        else if(buttonIndex == 3)
        {
           
            theStatus = statusMoveFiles;
            [self MoveFiles];
        }
        
    }
    else
    {
        
        if(buttonIndex == 0)
        {
            
            [self doSelectAll];

        }
    }
}
 */

#pragma mark - MDSelectedActionSheet delegate
-(void)MDSDidClickedDeleteButton:(MDSelectedActionSheet *)object
{
    MDConfirmDeleteAlertView *action = [[MDConfirmDeleteAlertView alloc] initAlertViewWithDelegate:self];
    
    [action showAlertView];
    
    currentAction = action;
}

-(void)MDSDidClickedDeselectAllButton:(MDSelectedActionSheet *)object
{
    /**deselect all**/
    [self doDeselectAll];
}

-(void)MDSDidClickedSelectAllButton:(MDSelectedActionSheet *)object
{
    /**select all action**/
    [self doSelectAll];

}

-(void)MDSDidClickedMoveButton:(MDSelectedActionSheet *)object
{
    /**move files**/
    isMovingFiles = YES;
    [self doMoveFiles];
}

#pragma mark - MDConfirmDeleteAlertView delegate
-(void)MDConfirmDeleteAlertViewDidCancel:(MDConfirmDeleteAlertView *)object
{
    //do nothing
}

-(void)MDConfirmDeleteAlertViewDidConfirmDelete:(MDConfirmDeleteAlertView *)object
{
    /**delete selected**/
    [self doDeleteSelect];
}


#pragma mark - MDNonSelectedActionSheet delegate
-(void)MDNSDidClickedSelectAllButton:(MDNonSelectedActionSheet *)object
{
    /**select all action**/
    [self doSelectAll];
}

#pragma mark - MDAddFolderAlertView delegate
-(void)AddFolderInputNameWasEmpty:(MDAddFolderAlertView *)object
{
    //check if text field's text is empty
    UIAlertView *addFolderinvaildAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"You have to give a name for new folder", @"You have to give a name for new folder") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    
    [addFolderinvaildAlert show];
    
}
-(void)MDAddFolderAlertView:(MDAddFolderAlertView *)object didAddFolderWithName:(NSString *)folderName
{
    //create folder
    BOOL success =[self doAddFolderAtPath:self.workingPath WithFolderName:folderName];
    
    if(success)
    {
        //reload table view data
        //[self reloadTableViewData];
        //we don't reload whole data instead of adding a new file to data and add a cell to table
        MDFiles *file = [[MDFiles alloc] initWithFilePath:self.workingPath FileName:folderName];
        
        [filesArray addObject:file];
        
        //insert cell to table view
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[filesArray count]-1 inSection:0];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - MDRenameAlertView delegate
-(void)RenameInputNameWasEmpty:(MDRenameAlertView *)object
{
    //check if text field's text is empty
    UIAlertView *renameInvaildAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Name can not be blank", @"Name can not be blank") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    
    [renameInvaildAlert show];
}

-(void)MDRenameAlertView:(MDRenameAlertView *)object didInputNameWithName:(NSString *)inputName
{
    NSString *checkedFilePath = [self.workingPath stringByAppendingPathComponent:inputName];
    
    //check if name has been used 
    if([[NSFileManager defaultManager] fileExistsAtPath:checkedFilePath])
    {
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"The name %@ had been used", @"The name %@ had been used"), inputName];
        
        UIAlertView *duplicateNameAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        
        [duplicateNameAlert show];
    }
    else
    {
        /**Rename**/
        [self doRenameFileWithName:inputName];
        
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

-(void)doMoveFiles
{
    MDMoveFilesNavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"MDMoveFilesNavigationController"];
    
    navController.theDelegate = self;
    
    [self.navigationController presentModalViewController:navController animated:YES];

}

#pragma mark - AddFolder methods
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

-(void)doRenameFileWithName:(NSString *)name
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
        newFileName = [NSString stringWithFormat:@"%@.%@", name, fileExtension];
        newPath = [self.workingPath stringByAppendingPathComponent:newFileName];
    }
    else
    {
        //it is directory
        newPath = [self.workingPath stringByAppendingPathComponent:name];
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
        newfile = [[MDFiles alloc] initWithFilePath:self.workingPath FileName:name];
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

#pragma mark - MDMoveFilesNavigationController delegate
-(void)MDMoveFilesNavigationController:(MDMoveFilesNavigationController *)controller DidMoveFilesToDestination:(NSString *)folderDest
{
    NSMutableArray *filesToMove = [[NSMutableArray alloc] init];
    NSMutableArray *duplicateFiles = [[NSMutableArray alloc] init];
    
    /**if folder move into self or subfolder will no wronging***/

    //MDFiles *selfFiles = nil;
    NSArray *splitePath = [folderDest componentsSeparatedByString:@"/"];
    NSString *destFolderName = [splitePath lastObject];
    
    if([destFolderName isEqualToString:@"Documents"])
        destFolderName = @"Root";
    
    //check if file exist in path
    for(NSIndexPath *indexPath in selectedIndexPaths)
    {
        MDFiles *file = [filesArray objectAtIndex:indexPath.row];
        NSString *checkedPath = [folderDest stringByAppendingPathComponent:file.fileName];
        /*
        //check if folder move by it self
        if(file.isFile == NO)
        {
            if([splitePath containsObject:file.fileName])
            {
                selfFiles = file;
                
                int objectIndex = [splitePath indexOfObject:file.fileName];
                destFolderName = [splitePath objectAtIndex:objectIndex];
                
                break;
            }

        }
         */
        
        if([[NSFileManager defaultManager] fileExistsAtPath:checkedPath])
        {
            [duplicateFiles addObject:[file.fileName copy]];
        }
        else
        {
            [filesToMove addObject:file];
        }
    }
    
    /*
    if(selfFiles != nil)
    {
        //folder move into self folder or sub folder
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"You can not move the folder \"%@\" to the same folder \"%@\" or any subfolders of \"%@\"", @"You can not move the folder \"%@\" to the same folder \"%@\" or any subfolders of \"%@\""), selfFiles.fileName, destFolderName, destFolderName];
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
        
        [theAlert show];
    }
     */
    
    if([duplicateFiles count] != 0)
    {
        //there are some duplicate file at destination
        NSString *msg;
        
        if([duplicateFiles count] > 1)
        {
            msg = [NSString stringWithFormat:NSLocalizedString(@"There are some duplicate files or folders at destination folder \"%@\"", @"There are some duplicate files or folders at destination folder \"%@\""), destFolderName];
        }
        else
        {
            msg = [NSString stringWithFormat:NSLocalizedString(@"There is a duplicate file or folder at destination folder \"%@\"", @"There is a duplicate file or folder at destination folder \"%@\""), destFolderName];
        }
        
        UIAlertView *duplicateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles: nil];
        
        [duplicateAlert show];
    }
    else
    {
        //we are save to move files
        
        [self doneEditTabelView];
        
        [self doMoveFiles:filesToMove ToDestinationPath:folderDest];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        [self reloadTableViewData];
 
    }
    
    isMovingFiles = NO;
    
}

-(void)MDMoveFilesNavigationControllerDidCancelWithController:(MDMoveFilesNavigationController *)controller
{
    [self doneEditTabelView];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    isMovingFiles = NO;

    
}

#pragma mark - move file method
-(void)doMoveFiles:(NSArray *)filesToMove ToDestinationPath:(NSString *)destPath
{

    NSError *error;
    
    
    if([filesToMove count] == 0)
    {
        NSLog(@"No file selected to perform move action");
        return;
    }
    
    for(MDFiles *file in filesToMove)
    {
        //the destPath is directory not a file so we need to apped file's name to make full path
        NSString *targetPath = [destPath stringByAppendingPathComponent:file.fileName];
        
        //move file to dest path
        [[NSFileManager defaultManager] moveItemAtPath:file.filePath toPath:targetPath error:&error];
        
        if(error != nil)
        {
            NSLog(@"move file from %@ to %@ fail error:%@", file.filePath, targetPath, error);
        }
        
        
        int objectIndex = [filesArray indexOfObject:file];
        NSArray *deletedIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:objectIndex inSection:0]];
        
        //remove file representation
        [filesArray removeObject:file];
        
        //remove table row
        [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
    //remove all selected Indexpaths
    [selectedIndexPaths removeAllObjects];
    
}

@end
