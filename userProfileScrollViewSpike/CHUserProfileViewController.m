//
//  CHViewController.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHUserProfileViewController.h"
#import "UIView+FLKAutoLayout.h"
#import "CHUserSummaryView.h"

@interface CHUserProfileViewController (){
    CHUserSummaryView *userSummaryView;
    UIPageControl *pageControl;
    UIScrollView *userDetailsPagingView;
    UIView *userDetailsPagesContainerView;

    CHSimpleTableViewController* tableviewController1;
    CHSimpleTableViewController* tableviewController2;
    CHSimpleTableViewController* tableviewController3;
    
    CGFloat currentViewWidth, currentViewHeight;
    int numberOfUserDetailsPages;
}

@end

@implementation CHUserProfileViewController

- (id)initWithUserProfileViewModel:(CHUserProfileViewModel *)theUserProfile{
    self = [self init];
    if (self) {
        userProfile = theUserProfile;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // scroll view auto layout setup
    //http://developer.apple.com/library/ios/#releasenotes/General/RN-iOSSDK-6_0/index.html
        
    currentViewWidth = self.view.frame.size.width;
    currentViewHeight = self.view.frame.size.height;
    numberOfUserDetailsPages = 3;
    
    
    userSummaryView = [[CHUserSummaryView alloc] initWithUserProfile:userProfile];
    [self.view addSubview:userSummaryView];
    [userSummaryView alignTopEdgeWithView:self.view predicate:@"0"];
    [userSummaryView alignLeading:@"0" trailing:@"0" toView:self.view];
    userSummaryView.alpha = 0.5;
    
    // userSummaryView is using autolayout constrain for its height, there and the height before rendering is 0, probably should redesign it to use frame directly
    CGFloat userSummaryViewHeight = 180.0;

    
    userDetailsPagingView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, userSummaryViewHeight, currentViewWidth, currentViewHeight - userSummaryViewHeight)];
    userDetailsPagingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    userDetailsPagingView.delegate = self;
    userDetailsPagingView.pagingEnabled = YES;
    userDetailsPagingView.backgroundColor = [UIColor lightGrayColor];
    userDetailsPagingView.alpha = 1;
    userDetailsPagingView.showsHorizontalScrollIndicator = YES;
    userDetailsPagingView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:userDetailsPagingView];
    

    userDetailsPagesContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, numberOfUserDetailsPages*currentViewWidth, userDetailsPagingView.bounds.size.height)];
    userDetailsPagesContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [userDetailsPagingView addSubview:userDetailsPagesContainerView];
    userDetailsPagingView.contentSize = userDetailsPagesContainerView.bounds.size;

    
    tableviewController1 = [[CHSimpleTableViewController alloc] init];
    tableviewController1.scrollDelegate = self;
    [self addChildViewController:tableviewController1];
    [userDetailsPagesContainerView addSubview:tableviewController1.tableView];
    tableviewController1.tableView.frame = CGRectMake(0, 0, currentViewWidth, userDetailsPagesContainerView.bounds.size.height);
    tableviewController1.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    tableviewController2 = [[CHSimpleTableViewController alloc] init];
    tableviewController2.scrollDelegate = self;
    [self addChildViewController:tableviewController2];
    [userDetailsPagesContainerView addSubview:tableviewController2.tableView];
    tableviewController2.tableView.frame = CGRectMake(currentViewWidth, 0, currentViewWidth, userDetailsPagesContainerView.bounds.size.height);
    tableviewController2.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    tableviewController3 = [[CHSimpleTableViewController alloc] init];
    tableviewController3.scrollDelegate = self;
    [self addChildViewController:tableviewController3];
    [userDetailsPagesContainerView addSubview:tableviewController3.tableView];
    tableviewController3.tableView.frame = CGRectMake(currentViewWidth*2, 0, currentViewWidth, userDetailsPagesContainerView.bounds.size.height);
    tableviewController3.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    
    pageControl = [[UIPageControl alloc] init];
    pageControl.userInteractionEnabled = NO;
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
    [self resizeUserDetailsPagesWithScrollViewSize:userDetailsPagingView.bounds.size];
}

-(void)resizeUserDetailsPagesWithScrollViewSize:(CGSize)newSize{
    NSLog(@"new size: w - %f , h - %f", newSize.width, newSize.height);
    userDetailsPagesContainerView.frame = CGRectMake(0, 0, numberOfUserDetailsPages*newSize.width,  newSize.height);
    userDetailsPagingView.contentSize = userDetailsPagesContainerView.bounds.size;
    for (int i = 0, count = userDetailsPagesContainerView.subviews.count; i < count; i ++) {
        ((UIView *)userDetailsPagesContainerView.subviews[i]).frame = CGRectMake(i * newSize.width, 0, newSize.width,  newSize.height);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    if([sender isEqual:userDetailsPagingView]){
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = userDetailsPagingView.frame.size.width;
        int page = floor((userDetailsPagingView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;
    }
}

#pragma mark - TableViewScrollDelegate 
-(void) tableViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;

    BOOL isPullingDown = offsetY < 0;
    BOOL isPullingUp = offsetY > 0;
    BOOL userSummaryViewIsHidden = userSummaryView.frame.origin.y + userSummaryView.frame.size.height <= 0;
    BOOL userSummaryViewIsHalfVisible =  (0 < (userSummaryView.frame.origin.y + userSummaryView.frame.size.height) && (userSummaryView.frame.origin.y + userSummaryView.frame.size.height) < userSummaryView.frame.size.height);
    BOOL userSummaryViewIsFullyVisible = userSummaryView.frame.origin.y >= 0;
    
    if (userSummaryViewIsHalfVisible || (userSummaryViewIsHidden && isPullingDown ) || (userSummaryViewIsFullyVisible && isPullingUp) ) {
        
        CGRect newFrame = CGRectOffset(userSummaryView.frame, 0, -offsetY);
        if (offsetY > 0 && newFrame.origin.y + newFrame.size.height < 0) {
            newFrame = CGRectMake(0, -newFrame.size.height, newFrame.size.width, newFrame.size.height);
        }
        if (offsetY < 0 && newFrame.origin.y > 0) {
            newFrame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
        }
        float actualYDelta = userSummaryView.frame.origin.y - newFrame.origin.y ;
        userSummaryView.frame = newFrame;

        userDetailsPagingView.frame = CGRectMake(0, userDetailsPagingView.frame.origin.y - actualYDelta, CGRectGetWidth(userDetailsPagingView.frame), CGRectGetHeight(userDetailsPagingView.frame) + actualYDelta);
//        scrollView.frame = CGRectMake(0, scrollView.frame.origin.y - actualYDelta, scrollView.frame.size.width, scrollView.frame.size.height + actualYDelta);
        scrollView.contentOffset = CGPointMake(0,0);
    }
}

@end
