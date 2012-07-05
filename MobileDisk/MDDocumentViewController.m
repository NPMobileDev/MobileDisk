//
//  MDPDFViewController.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MDDocumentViewController.h"

@interface MDDocumentViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;


@end

@implementation MDDocumentViewController

@synthesize webView = _webView;
@synthesize theDocumentURL = _theDocumentURL;
@synthesize theDocumentData = _theDocumentData;

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
    NSLog(@"document view deallocate");
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.title = [self.theDocumentURL lastPathComponent];

    //give right button on navigation bar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneReadingPDF)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //load pdf on web view
    if(self.theDocumentURL)
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.theDocumentURL]];
    else if(self.theDocumentData)
        [self.webView loadData:self.theDocumentData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    
    
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
