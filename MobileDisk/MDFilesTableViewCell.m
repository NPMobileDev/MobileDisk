//
//  MDFilesTableViewCell.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDFilesTableViewCell.h"

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
