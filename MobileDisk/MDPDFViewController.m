//
//  MDPDFViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDPDFViewController.h"

@interface MDPDFViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;


@end

@implementation MDPDFViewController

@synthesize webView = _webView;
@synthesize pdfURL = _pdfURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"pdf view deallocate");
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.title = [self.pdfURL lastPathComponent];

    //give right button on navigation bar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneReadingPDF)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //load pdf on web view
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.pdfURL]];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)doneReadingPDF
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
