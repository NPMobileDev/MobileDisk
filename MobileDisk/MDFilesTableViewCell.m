//
//  MDFilesTableViewCell.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDFilesTableViewCell.h"
#import "MDFiles.h"
#import "MDFileSupporter.h"

const NSInteger IMAGE_WIDTH = 30;
const NSInteger IMAGE_HEIGHT = 30;
const NSString *SelectedImageName = @"IsSelected";
const NSString *NotSelectedImageName = @"NotSelected";

@implementation MDFilesTableViewCell{
    
    __weak UITableView *theTableView;
}

@synthesize selectionIndicator = _selectionIndicator;
@synthesize selectedIndicatorName = _selectedIndicatorName;
@synthesize notSelectedIndicatorName = _notSelectedIndicatorName;

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}
*/

-(void)dealloc
{
    self.selectionIndicator = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTableView:(UITableView *)tableView
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        //create selection indicator image view
        self.selectionIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotSelected"]];
        
        //calculate height offset in cell
        NSInteger yOffset =((tableView.rowHeight/2) - (IMAGE_HEIGHT/2));
        
        //set frame
        self.selectionIndicator.frame = CGRectMake(-IMAGE_WIDTH, yOffset, IMAGE_WIDTH, IMAGE_HEIGHT);

        
        //add image view to cell's content view
        [self.contentView addSubview:self.selectionIndicator];
        
        //set background image view for cell
        UIImage *backgroundImage = [UIImage imageNamed:@"TableCellGradient"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
        self.backgroundView = imageView;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        theTableView = tableView;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [self setNeedsLayout];
    
    //set selection style by table status
    if(theTableView.isEditing)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //check if table view is in editing mode
    if(theTableView.isEditing)
    {
        //move cell's content view to right a bit for selection indicator to show up 
        CGRect cellFrame = self.contentView.frame;
        cellFrame.origin.x += IMAGE_WIDTH;
        self.contentView.frame = cellFrame;
    }
    else
    {
        //move cell's content view to origin position
        CGRect cellFrame = self.contentView.frame;
        cellFrame.origin.x = 0;
        self.contentView.frame = cellFrame;
    }
    
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThumbnailGenerateNotification object:nil];
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    self.imageView.image = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionIndicator.image = [UIImage imageNamed:self.notSelectedIndicatorName];
    
}

#pragma mark - Configure cell
//configure cell by given file
-(void)configureCellForFile:(MDFiles *)theFile
{
    MDFiles *file = theFile;
    
    //text label
    if(file.isFile)
    {
        self.textLabel.text = file.fileName;
    }
    else
    {
        //is a folder
        self.textLabel.text = [file.fileName stringByAppendingString:@" /"];
    }
    
    //detail text label
    if(file.isFile)
    {
        //is a file 
        self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"File size: %@", @"File size string format"), file.fileSizeString];
    }
    
    //accessory
    if(!file.isFile)
    {
        //is directory
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //set image for selected and not selected for edit mode
    UIImageView *selectIndicator = self.selectionIndicator;
    if(file.isSelected)
    {
        
        selectIndicator.image = [UIImage imageNamed:self.selectedIndicatorName];
    }
    else
    {
        selectIndicator.image = [UIImage imageNamed:self.notSelectedIndicatorName];
    }
    
    //thumbnail image
    if(file.isFile)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kThumbnailGenerateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thumbnailNotification:) name:kThumbnailGenerateNotification object:nil];

        MDFileSupporter *fileSupporter = [MDFileSupporter sharedFileSupporter];
       
        [fileSupporter findThumbnailImageForFileAtPath:file.filePath thumbnailSize:CGSizeMake(44, 44) WithObject:self];
        
       
        //self.imageView.image = thumbnailImage;
        
    }
    else
    {
        //a folder
    }
    
}

-(void)thumbnailNotification:(NSNotification *)notification
{
    NSDictionary *dic = notification.object;
    
    MDFilesTableViewCell *theCell = [dic objectForKey:kThumbnailCaller];
    
    if(theCell == self)
    {
        UIImage *theImage = [dic objectForKey:kThumbnailImage];
        
        self.imageView.image = theImage;
        [self setNeedsLayout];
    }
    
}

#pragma mark - getter
-(NSString *)selectedIndicatorName
{
    return (NSString *)SelectedImageName;
}

-(NSString *)notSelectedIndicatorName
{
    return (NSString *)NotSelectedImageName;
}

@end
