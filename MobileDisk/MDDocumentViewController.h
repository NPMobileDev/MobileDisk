//
//  MDPDFViewController.h
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDDocumentViewController : UIViewController

@property (nonatomic, copy) NSString *controllerTitle;
@property (nonatomic, copy) NSURL *theDocumentURL;
@property (nonatomic, strong) NSData *theDocumentData;

@end
