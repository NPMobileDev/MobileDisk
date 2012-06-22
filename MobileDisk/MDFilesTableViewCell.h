//
//  MDFilesTableViewCell.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDFilesTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *selectionIndicator;
@property (nonatomic, readonly) NSString *selectedIndicatorName;
@property (nonatomic, readonly) NSString *notSelectedIndicatorName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTableView:(UITableView *)tableView;

@end
