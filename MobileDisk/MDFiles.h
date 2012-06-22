//
//  MDFiles.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/********
    This MDFiles hold all information about a file in directory.
    The file might be a regular file or folder.
 ********/

#import <Foundation/Foundation.h>

@interface MDFiles : NSObject

//is this a file or a folder
@property (nonatomic, assign) BOOL isFile;

//file name
@property (nonatomic, copy) NSString *fileName;

//file's path
@property (nonatomic, copy) NSString *filePath;

//the size of this file in string, if it is folder this will be nil
@property (nonatomic, copy) NSString *fileSizeString;

//the file size in byte
@property (nonatomic, assign) unsigned long long fileSize;

//determind if file was selected only used for tableView's edit mode
@property (nonatomic, assign) BOOL isSelected;

-(id)initWithFilePath:(NSString *)path FileName:(NSString *)filename;

@end
