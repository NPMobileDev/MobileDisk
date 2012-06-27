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
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

-(IBAction)doneReadingPDF:(id)sender;

@end

@implementation MDPDFViewController

@synthesize webView = _webView;
@synthesize titleLabel = _titleLabel;
@synthesize pdfURL = _pdfURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *title = [self.pdfURL lastPathComponent];
    self.titleLabel.text = title;
    
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

-(IBAction)doneReadingPDF:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
