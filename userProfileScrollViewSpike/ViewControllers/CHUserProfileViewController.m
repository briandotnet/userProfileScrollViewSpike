//
//  CHUserProfileViewController.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHUserProfileViewController.h"
#import "UIView+FLKAutoLayout.h"
#import "CHUserProfileTopView.h"

@interface CHUserProfileViewController (){

    UIPageControl *pageControl;
    UIScrollView *userDetailsPagedScrollView;
    UIView *userDetailsPagesContentView;

    UIViewController *topViewController;
    NSArray<CHTableViewScrollDelegate>* detailsViewControllers;
}

@end

@implementation CHUserProfileViewController{
}

- (id)initWithUserProfileViewModel:(CHUserProfileViewModel *)theUserProfile viewControllerForTop:(UIViewController *)theTopViewController viewControllersForPagedDetails:(NSArray<CHTableViewScrollDelegate> *)theDetailsViewControllers{
    self = [self init];
    if (self) {
        self.userProfile = theUserProfile;
        topViewController = theTopViewController;
        detailsViewControllers = theDetailsViewControllers;
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
    int numberOfUserDetailsPages = detailsViewControllers.count;
    
    [self addChildViewController:topViewController];
    [self.view addSubview:topViewController.view];
    [topViewController didMoveToParentViewController:self];
    
    [topViewController.view alignTopEdgeWithView:self.view predicate:@"0"];
    [topViewController.view alignLeading:@"0" trailing:@"0" toView:self.view];
    
    // userSummaryView is using autolayout constrain for its height, and the height before rendering is 0, probably should redesign it to use frame directly
    CGFloat userSummaryViewHeight = 180.0;//CGRectGetHeight(topViewController.view.bounds);

    
    userDetailsPagedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, userSummaryViewHeight, currentViewWidth, currentViewHeight - userSummaryViewHeight)];
    userDetailsPagedScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    userDetailsPagedScrollView.delegate = self;
    userDetailsPagedScrollView.pagingEnabled = YES;
    userDetailsPagedScrollView.backgroundColor = [UIColor lightGrayColor];
    userDetailsPagedScrollView.alpha = 1;
    userDetailsPagedScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:userDetailsPagedScrollView];
    
    userDetailsPagesContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, numberOfUserDetailsPages*currentViewWidth, userDetailsPagedScrollView.bounds.size.height)];
    userDetailsPagesContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [userDetailsPagedScrollView addSubview:userDetailsPagesContentView];
    userDetailsPagedScrollView.contentSize = userDetailsPagesContentView.bounds.size;

    for (int i = 0; i < numberOfUserDetailsPages; i ++) {
        UIViewController<CHTableViewScrollDelegate> *viewController = [detailsViewControllers objectAtIndex:i];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        viewController.scrollDelegate = self;
        [userDetailsPagesContentView addSubview:viewController.view];
        viewController.view.frame = CGRectMake(currentViewWidth * i, 0, currentViewWidth, userDetailsPagesContentView.bounds.size.height);
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.userInteractionEnabled = NO; // I don't think anyone will try to tap the little dots, to avoid complication, turn them off
    pageControl.backgroundColor = [UIColor redColor];
    pageControl.numberOfPages = 3;
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
    [pageControl alignCenterXWithView:self.view predicate:nil];
    [pageControl alignBottomEdgeWithView:self.view predicate:@"-20"];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self resizeUserDetailsPagesWithScrollViewSize:userDetailsPagedScrollView.bounds.size];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    if([sender isEqual:userDetailsPagedScrollView]){
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = userDetailsPagedScrollView.frame.size.width;
        int page = floor((userDetailsPagedScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;
    }
}

#pragma mark - TableViewScrollDelegate 
-(void) tableViewDidScroll:(UIScrollView *)scrollView{
    [self scrollView:scrollView needToRelayoutTopView:topViewController.view andBottomView:userDetailsPagedScrollView];
}

#pragma mark - private helper method

-(void)resizeUserDetailsPagesWithScrollViewSize:(CGSize)newSize{
    int numberOfUserDetailsPages = detailsViewControllers.count;
    userDetailsPagesContentView.frame = CGRectMake(0, 0, numberOfUserDetailsPages*newSize.width,  newSize.height);
    userDetailsPagedScrollView.contentSize = userDetailsPagesContentView.bounds.size;
    for (int i = 0, count = userDetailsPagesContentView.subviews.count; i < count; i ++) {
        ((UIView *)userDetailsPagesContentView.subviews[i]).frame = CGRectMake(i * newSize.width, 0, newSize.width,  newSize.height);
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
