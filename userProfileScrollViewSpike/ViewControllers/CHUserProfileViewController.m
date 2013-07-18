//
//  CHViewController.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHUserProfileViewController.h"
#import "UIView+FLKAutoLayout.h"
#import "CHUserProfileTopView.h"

@interface CHUserProfileViewController (){
//    CHUserSummaryView *topView;
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
    
    
//    topView = [[CHUserSummaryView alloc] initWithUserProfile:self.userProfile];
    [self addChildViewController:topViewController];
    [self.view addSubview:topViewController.view];
    [topViewController didMoveToParentViewController:self];
    
    [topViewController.view alignTopEdgeWithView:self.view predicate:@"0"];
    [topViewController.view alignLeading:@"0" trailing:@"0" toView:self.view];
    
    // userSummaryView is using autolayout constrain for its height, there and the height before rendering is 0, probably should redesign it to use frame directly
    CGFloat userSummaryViewHeight = 180.0;

    
    userDetailsPagedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, userSummaryViewHeight, currentViewWidth, currentViewHeight - userSummaryViewHeight)];
    userDetailsPagedScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    userDetailsPagedScrollView.delegate = self;
    userDetailsPagedScrollView.pagingEnabled = YES;
    userDetailsPagedScrollView.backgroundColor = [UIColor lightGrayColor];
    userDetailsPagedScrollView.alpha = 1;
    userDetailsPagedScrollView.showsHorizontalScrollIndicator = YES;
    userDetailsPagedScrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:userDetailsPagedScrollView];
    
    userDetailsPagesContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, numberOfUserDetailsPages*currentViewWidth, userDetailsPagedScrollView.bounds.size.height)];
    userDetailsPagesContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [userDetailsPagedScrollView addSubview:userDetailsPagesContentView];
    userDetailsPagedScrollView.contentSize = userDetailsPagesContentView.bounds.size;

    for (int i = 0; i < numberOfUserDetailsPages; i ++) {
        UIViewController<CHTableViewScrollDelegate> *viewController = [detailsViewControllers objectAtIndex:i];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        ((CHSimpleTableViewController*)viewController).scrollDelegate = self; // todo: this needs more clean up 
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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    NSLog(@"%@", userDetailsPagingView);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    NSLog(@"%@", userDetailsPagingView);

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self resizeUserDetailsPagesWithScrollViewSize:userDetailsPagedScrollView.bounds.size];
}

-(void)resizeUserDetailsPagesWithScrollViewSize:(CGSize)newSize{
    int numberOfUserDetailsPages = detailsViewControllers.count;
    userDetailsPagesContentView.frame = CGRectMake(0, 0, numberOfUserDetailsPages*newSize.width,  newSize.height);
    userDetailsPagedScrollView.contentSize = userDetailsPagesContentView.bounds.size;
    for (int i = 0, count = userDetailsPagesContentView.subviews.count; i < count; i ++) {
        ((UIView *)userDetailsPagesContentView.subviews[i]).frame = CGRectMake(i * newSize.width, 0, newSize.width,  newSize.height);
    }
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
    CGFloat offsetY = scrollView.contentOffset.y;

    // these BOOLs are just for readibility
    BOOL isPullingDown = offsetY < 0;
    BOOL isPullingUp = offsetY > 0;
    BOOL userSummaryViewIsHidden = topViewController.view.frame.origin.y + topViewController.view.frame.size.height <= 0;
    BOOL userSummaryViewIsHalfVisible =  (0 < (topViewController.view.frame.origin.y + topViewController.view.frame.size.height) && (topViewController.view.frame.origin.y + topViewController.view.frame.size.height) < topViewController.view.frame.size.height);
    BOOL userSummaryViewIsFullyVisible = topViewController.view.frame.origin.y >= 0;
    
    if (userSummaryViewIsHalfVisible || (userSummaryViewIsHidden && isPullingDown ) || (userSummaryViewIsFullyVisible && isPullingUp) ) {
        
        // shift the userSummaryView vertical according to the offset
        CGRect newFrame = CGRectOffset(topViewController.view.frame, 0, -offsetY);
        
        // on edge cases, we might overshift the top view, so we snap it to either 0 or negative height.
        if (offsetY > 0 && newFrame.origin.y + newFrame.size.height < 0) {
            newFrame = CGRectMake(0, -newFrame.size.height, newFrame.size.width, newFrame.size.height);
        }
        if (offsetY < 0 && newFrame.origin.y > 0) {
            newFrame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
        }
        // take a note of the actual points we shifted the top view vertical
        float actualYDelta = topViewController.view.frame.origin.y - newFrame.origin.y ;
        topViewController.view.frame = newFrame;
        
        // shift and resize the paging scroll view
        userDetailsPagedScrollView.frame = CGRectMake(0, userDetailsPagedScrollView.frame.origin.y - actualYDelta, CGRectGetWidth(userDetailsPagedScrollView.frame), CGRectGetHeight(userDetailsPagedScrollView.frame) + actualYDelta);
        
        // reset the content offset to 0 so the content in the scorllview (table view or collection view) doesn't scroll
        scrollView.contentOffset = CGPointMake(0,0);
    }
}

@end
