//
//  MDImageViewerController.m
//  ScrollPic
//
//  Created by Mac-mini Nelson on 12/9/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MDImageViewerController.h"
#import "MDImageScrollView.h"
#import "MDFileSupporter.h"
#import <Twitter/Twitter.h>

@interface MDImageViewerController ()

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
-(IBAction)doneImageWatching:(id)sender;
-(IBAction)action:(id)sender; //add 9/19/2012

@end

@implementation MDImageViewerController{
    
    NSUInteger numberOfImage;
    
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    
    UIScrollView *pagingScrollView;
    
    //cache low resolution images
    NSCache *lowResImages;
    
    //9/19/2012
    id theAction;
}

@synthesize theDelegate = _theDelegate;
@synthesize navBar = _navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    /**
     create paging scroll view
     **/
    CGRect pagingFrame = [self frameForPagingScrollView];
    pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingFrame];
    pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.pagingEnabled = YES;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.showsVerticalScrollIndicator = NO;
    
    //pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if([self.theDelegate respondsToSelector:@selector(numberOfImage)])
    {
        numberOfImage = [self.theDelegate numberOfImage];
    }
    
    pagingScrollView.contentSize = CGSizeMake(pagingFrame.size.width*numberOfImage, pagingFrame.size.height);
    
    /**
     begin page index
     **/
    NSUInteger beginPageIndex = 0;
    
    if([self.theDelegate respondsToSelector:@selector(beginWithPageIndex)])
    {
        beginPageIndex = [self.theDelegate beginWithPageIndex];
    }
    
    if(beginPageIndex <= numberOfImage-1)
    {
        pagingScrollView.contentOffset = CGPointMake(pagingFrame.size.width*beginPageIndex, 0);
    }
    
    pagingScrollView.delegate = self;
    
    [self.view addSubview:pagingScrollView];
    

    
    /**
     create recycle and visible pages
     **/
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages = [[NSMutableSet alloc] init];
    
    lowResImages = [[NSCache alloc] init];
    
    
    //configure pages
    [self configurePages];
    
    //gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToShowBar:)];
    [tapGesture setNumberOfTapsRequired:1];
    [pagingScrollView addGestureRecognizer:tapGesture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [pagingScrollView removeFromSuperview];
    pagingScrollView = nil;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //dump all cache
    if(lowResImages != nil)
        [lowResImages removeAllObjects];
    
    [[MDFileSupporter sharedFileSupporter] clearThumbnailCache];
}

-(void)dealloc
{
    
    for(MDImageScrollView *page in visiblePages)
    {
        [page removeFromSuperview];
    }
    
    [pagingScrollView removeFromSuperview];
    
    NSLog(@"image viewer deallocate");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//9/20/2012
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
//9/20/2012
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Get low resolution image
-(UIImage*)getLowResImagesByFilePath:(NSString*)path
{
    UIImage *lowResImage = [lowResImages objectForKey:path];
    
    if(lowResImage!= nil)
    {
        return lowResImage;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    CGRect boundSize = [[UIScreen mainScreen] bounds];
    CGFloat xScale = boundSize.size.width/image.size.width;
    CGFloat yScale = boundSize.size.height/image.size.height;
    CGFloat minScale = MIN(xScale, yScale);
    minScale = MIN(minScale, 1);
    
    image = [self lowResImage:image WithSize:CGSizeMake(image.size.width*minScale, image.size.height*minScale)];
    
    [lowResImages setObject:image forKey:path];
    
    return image;
}

#pragma mark - generate low resolution image
-(UIImage*)lowResImage:(UIImage*)image WithSize:(CGSize)newSize
{
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    return newImage;
     

}

#pragma mark - ScrollView frame
-(CGRect)frameForPagingScrollView
{
    CGRect frame = [[UIScreen mainScreen] bounds];

    frame.origin.x -= kPadding;
    frame.size.width += (2*kPadding);
    
    return frame;
}

#pragma mark - Configure pages
-(void)configurePages
{
    CGRect visibleBound = pagingScrollView.bounds;
    int firstNeededIndex = floorf(CGRectGetMinX(visibleBound)/CGRectGetWidth(visibleBound));
    int lastNeededIndex = floorf((CGRectGetMaxX(visibleBound)-1)/CGRectGetWidth(visibleBound));
    firstNeededIndex = MAX(firstNeededIndex, 0);
    lastNeededIndex = MIN(lastNeededIndex, numberOfImage-1);
    
    //recycle no longer visible page
    for(MDImageScrollView *page in visiblePages)
    {
        if(page.index < firstNeededIndex || page.index > lastNeededIndex)
        {
            [page prepareToRecycle];
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    //add missing page
    for(int index = firstNeededIndex; index <= lastNeededIndex; index++)
    {
        if(![self isDisplayingPageForIndex:index])
        {
            MDImageScrollView *page = [self dequeueRecycledPage];
            
            if(page == nil)
            {
                
                NSString *theImagePath;
                if([self.theDelegate respondsToSelector:@selector(imagePathForImageIndexToDisplay:)])
                {
                    theImagePath = [self.theDelegate imagePathForImageIndexToDisplay:index];
                }
                
                UIImage *image = [self getLowResImagesByFilePath:theImagePath];
                
                if(firstNeededIndex == lastNeededIndex)
                {
                    NSString *title = [theImagePath lastPathComponent];
                    UINavigationItem *item = [self.navBar.items lastObject];
                    item.title = title;
                }
                
                page = [[MDImageScrollView alloc] init];
                page.lowResImage = image;
                page.imagePath = theImagePath;
                page.index = index;
                [self configureFrameForPage:page];
                
                [visiblePages addObject:page];
                [pagingScrollView addSubview:page];
            }
        }
    }
    
    [self.view bringSubviewToFront:self.navBar];
}

-(void)configureFrameForPage:(MDImageScrollView*)page
{
    CGRect pagingFrame = [self frameForPagingScrollView];
    
    CGRect pageFrame = pagingFrame;
    pageFrame.size.width -= (2*kPadding);
    pageFrame.origin.x = (pagingFrame.size.width * page.index)+kPadding;
    
    page.frame = pageFrame;
    
    [page displayImage];
}

-(BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL isDisplaying = NO;
    
    for(MDImageScrollView *page in visiblePages)
    {
        if(index == page.index)
        {
            isDisplaying = YES;
            break;
        }
    }
    
    return isDisplaying;
}

-(MDImageScrollView*)dequeueRecycledPage
{
    MDImageScrollView *page = [recycledPages anyObject];
    
    if(page)
    {
        [recycledPages removeObject:page];
    }
    
    return page;
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.navBar.hidden = YES;
    
    [self configurePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(visiblePages && visiblePages.count == 1)
    {
        MDImageScrollView *page = [visiblePages anyObject];
        
        if(page)
        {
            NSString *title = [page.imagePath lastPathComponent];
            UINavigationItem *item = [self.navBar.items lastObject];
            item.title = title;
        }
    }
}

#pragma mark - tap gesture handler
-(void)tapToShowBar:(UIGestureRecognizer*)gesture
{
    if(self.navBar.hidden)
    {
        self.navBar.hidden = NO;
    }
    else
    {
        self.navBar.hidden = YES;
    }
}

#pragma mark - done watching
-(IBAction)doneImageWatching:(id)sender
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    if([self.theDelegate respondsToSelector:@selector(finishImageViewing)])
    {
        [self.theDelegate finishImageViewing];
    }
}

#pragma mark - action for social service 9/19/2012
-(IBAction)action:(id)sender
{
    
    MDImageScrollView *page = [visiblePages anyObject];
    NSString *imagePath = [self.theDelegate imagePathForImageIndexToDisplay:page.index];
    
    UIImage *tweetImage;
    
    if(lowResImages!=nil)
    {
        tweetImage = [lowResImages objectForKey:imagePath];
        
        if(tweetImage == nil)
            tweetImage = [self getLowResImagesByFilePath:imagePath];
    }
    
    UIActivityViewController *socialServiceController = [[UIActivityViewController alloc] initWithActivityItems:@[tweetImage] applicationActivities:nil];
    
    [self presentViewController:socialServiceController animated:YES completion:nil];
}

@end
