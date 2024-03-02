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
@synthesize controllerTitle = _controllerTitle;

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
    
    //self.title = self.controllerTitle;

    //give right button on navigation bar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneReadingDocument)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //load document on web view
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

//**9/20/2012 4inch**//
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)doneReadingDocument
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    UINavigationItem *navItem = [self.navigationController.navigationBar.items lastObject];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(200, 0, 44, 44)];
    
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.text = self.controllerTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    UIView *theTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 294, 44)];
    [theTitleView addSubview:titleLabel];
    [theTitleView addSubview:indicator];
    
    
    navItem.titleView = theTitleView;
    
    
    [indicator startAnimating];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UINavigationItem *navItem = [self.navigationController.navigationBar.items lastObject];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 21)];
    titleLabel.text = self.controllerTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    
    navItem.titleView = titleLabel;
    
}

@end
