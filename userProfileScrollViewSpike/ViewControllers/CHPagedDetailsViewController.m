//
//  CHPagedDetailsViewController.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHPagedDetailsViewController.h"
#import "UIView+FLKAutoLayout.h"
#import "CHUserProfileTopView.h"

@interface CHPagedDetailsViewController (){
}
@property (nonatomic, readwrite, strong) UIPageControl *pageControl;
@property (nonatomic, readwrite, strong) UIScrollView *detailsPagedScrollView;
@property (nonatomic, readwrite, strong) UIView *userDetailsPagedContentView; // put this in a category
@property (nonatomic, readwrite, strong) UIViewController *headerViewController;
@property (nonatomic, readwrite, strong) NSArray<CHScrollableViewController> *detailsViewControllers;

@end

@implementation CHPagedDetailsViewController{
}

- (id)initWithViewControllerForTop:(UIViewController *)theTopViewController viewControllersForPagedDetails:(NSArray<CHScrollableViewController> *)theDetailsViewControllers{
    self = [self init];
    if (self) {
//        self.userProfile = theUserProfile;
        self.headerViewController = theTopViewController;
        self.detailsViewControllers = theDetailsViewControllers;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    NSLog(@"loadview method");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        
    CGFloat currentViewWidth = self.view.frame.size.width;
    CGFloat currentViewHeight = self.view.frame.size.height;
    int numberOfUserDetailsPages = self.detailsViewControllers.count;
    
    [self addChildViewController:self.headerViewController];
    [self.view addSubview:self.headerViewController.view];
    [self.headerViewController didMoveToParentViewController:self];
    
    [self.headerViewController.view alignTopEdgeWithView:self.view predicate:@"0"];
    [self.headerViewController.view alignLeading:@"0" trailing:@"0" toView:self.view];
    
    // userSummaryView is using autolayout constrain for its height, and the height before rendering is 0, probably should redesign it to use frame directly
    CGFloat userSummaryViewHeight = 180.0;//CGRectGetHeight(topViewController.view.bounds);

    
    self.detailsPagedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, userSummaryViewHeight, currentViewWidth, currentViewHeight - userSummaryViewHeight)];
    self.detailsPagedScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.detailsPagedScrollView.delegate = self;
    self.detailsPagedScrollView.pagingEnabled = YES;
    self.detailsPagedScrollView.backgroundColor = [UIColor lightGrayColor];
    self.detailsPagedScrollView.alpha = 1;
    self.detailsPagedScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.detailsPagedScrollView];
    
    self.userDetailsPagedContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, numberOfUserDetailsPages*currentViewWidth, self.detailsPagedScrollView.bounds.size.height)];
    self.userDetailsPagedContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.detailsPagedScrollView addSubview:self.userDetailsPagedContentView];
    self.detailsPagedScrollView.contentSize = self.userDetailsPagedContentView.bounds.size;

    for (int i = 0; i < numberOfUserDetailsPages; i ++) {
        UIViewController<CHScrollableViewController> *viewController = [self.detailsViewControllers objectAtIndex:i];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        viewController.scrollDelegate = self; // use KVO to observe the bounds of child view 
        [self.userDetailsPagedContentView addSubview:viewController.view];
        viewController.view.frame = CGRectMake(currentViewWidth * i, 0, currentViewWidth, self.userDetailsPagedContentView.bounds.size.height);
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.userInteractionEnabled = NO; // I don't think anyone will try to tap the little dots, to avoid complication, turn them off
    self.pageControl.backgroundColor = [UIColor redColor];
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    [self.pageControl alignCenterXWithView:self.view predicate:nil];
    [self.pageControl alignBottomEdgeWithView:self.view predicate:@"-20"];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self resizeUserDetailsPagesWithScrollViewSize:self.detailsPagedScrollView.bounds.size];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    if([sender isEqual:self.detailsPagedScrollView]){
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = self.detailsPagedScrollView.frame.size.width;
        int page = floor((self.detailsPagedScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

#pragma mark - TableViewScrollDelegate 
-(void) tableViewDidScroll:(UIScrollView *)scrollView{
    [self scrollView:scrollView needToRelayoutTopView:self.headerViewController.view andBottomView:self.detailsPagedScrollView];
}

#pragma mark - private helper method

-(void)resizeUserDetailsPagesWithScrollViewSize:(CGSize)newSize{
    int numberOfUserDetailsPages = self.detailsViewControllers.count;
    self.userDetailsPagedContentView.frame = CGRectMake(0, 0, numberOfUserDetailsPages*newSize.width,  newSize.height);
    self.detailsPagedScrollView.contentSize = self.userDetailsPagedContentView.bounds.size;
    for (int i = 0, count = self.userDetailsPagedContentView.subviews.count; i < count; i ++) {
        ((UIView *)self.userDetailsPagedContentView.subviews[i]).frame = CGRectMake(i * newSize.width, 0, newSize.width,  newSize.height);
    }
}

-(void)scrollView:(UIScrollView *)scrollView needToRelayoutTopView:(UIView *)topView andBottomView:(UIView*)bottomView{
    CGFloat offsetY = scrollView.contentOffset.y;

    // these BOOLs are just for readibility
    BOOL isPullingDown = offsetY < 0;
    BOOL isPullingUp = offsetY > 0;
    BOOL userSummaryViewIsHidden = CGRectGetMaxY(topView.frame) <= 0;
    BOOL userSummaryViewIsHalfVisible =  (CGRectGetMaxY(topView.frame) > 0) && (CGRectGetMinY(topView.frame) < 0);
    BOOL userSummaryViewIsFullyVisible = CGRectGetMinY(topView.frame) >= 0;
    
    if (userSummaryViewIsHalfVisible || (userSummaryViewIsHidden && isPullingDown ) || (userSummaryViewIsFullyVisible && isPullingUp) ) {
        
        // shift the userSummaryView vertical according to the offset
        CGRect newFrameForTopView = CGRectOffset(topView.frame, 0, -offsetY);
        
        // on edge cases, we might overshift the top view, so we snap it to either 0 or negative height.
        if (offsetY > 0 && newFrameForTopView.origin.y + CGRectGetHeight(newFrameForTopView) < 0) {
            newFrameForTopView = CGRectMake(0, - CGRectGetHeight(newFrameForTopView), CGRectGetWidth(newFrameForTopView), CGRectGetHeight(newFrameForTopView));
        }
        if (offsetY < 0 && newFrameForTopView.origin.y > 0) {
            newFrameForTopView = CGRectMake(0, 0, CGRectGetWidth(newFrameForTopView), CGRectGetHeight(newFrameForTopView));
        }
        // take a note of the actual points we shifted the top view vertical
        float actualYDelta = topView.frame.origin.y - newFrameForTopView.origin.y ;
        topView.frame = newFrameForTopView;
        
        // shift and resize the paging scroll view
        bottomView.frame = CGRectMake(0, CGRectGetMinY(bottomView.frame) - actualYDelta, CGRectGetWidth(bottomView.frame), CGRectGetHeight(bottomView.frame) + actualYDelta);
        
        // reset the content offset to 0 so the content in the scorllview (table view or collection view) doesn't scroll
        scrollView.contentOffset = CGPointMake(0,0);
    }
}

@end
