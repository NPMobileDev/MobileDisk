//
//  MDMoveFilesNavigationController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDMoveFilesNavigationController;

@protocol MDMoveFilesNavigationControllerDelegate <NSObject>

-(void)MDMoveFilesNavigationController:(MDMoveFilesNavigationController *)controller DidMoveFilesToDestination:(NSString *)folderDest;
-(void)MDMoveFilesNavigationControllerDidCancelWithController:(MDMoveFilesNavigationController *)controller;

@end

@interface MDMoveFilesNavigationController : UINavigationController

@property (nonatomic, weak) id<MDMoveFilesNavigationControllerDelegate> theDelegate;

//called from child view controller
-(void)moveFilesTo:(NSString *)movingDest;

//called from child view controller
-(void)dismissNavigationController;

@end
