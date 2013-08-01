//
//  CHPagedDetailsViewController.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHPagedDetailsViewController.h"
#import "CHPagedDetailsViewController+Internal.h"
#import "UIView+FLKAutoLayout.h"

@interface CHPagedDetailsViewController (){
}
@property (nonatomic, readwrite, strong) UIPageControl *pageControl;
@property (nonatomic, readwrite, strong) UIScrollView *detailsPagedScrollView;


@end

@implementation CHPagedDetailsViewController{
}
static const CGFloat animationDurationAnimated = 0.5f;
static const CGFloat animationDurationNotAnimated = 0.0f;
static const CGFloat kHeaderViewHeight = 180.0f;
static const CGFloat kPageControlHeight = 20.0f;

- (id)initWithViewControllerForTop:(UIViewController *)theTopViewController viewControllersForPagedDetails:(NSArray<CHScrollableViewController> *)theDetailsViewControllers{
    self = [self init];
    if (self) {
        _detailsViewControllers = theDetailsViewControllers;
        _headerViewController = theTopViewController;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    CGFloat currentViewWidth = self.view.frame.size.width;
    CGFloat currentViewHeight = self.view.frame.size.height;
    NSInteger numberOfUserDetailsPages = _detailsViewControllers.count;
//    CGFloat navBarHeight = self.navigationController ? CGRectGetHeight(self.navigationController.navigationBar.frame) : 0.0f;
    
    self.headerContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, currentViewWidth, kHeaderViewHeight + kPageControlHeight)];
    self.headerContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerContentView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.headerContentView];
    
    [self addChildViewController: self.headerViewController];
    [self.headerContentView addSubview:self.headerViewController.view];
    //not sure why setting frame and autoresizingMasks directly causes resize issue, have to use autolayout here, maybe because the headerview is constructed with autolayout?
//    self.headerViewController.view.frame = CGRectMake(0.0f, 0.0f, currentViewWidth, kHeaderViewHeight);
//    self.headerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.headerViewController.view alignTop:@"0" leading:@"0" bottom:@"-20" trailing:@"0" toView:self.headerContentView];
    
    [self.headerViewController didMoveToParentViewController:self];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, kHeaderViewHeight, currentViewWidth, kPageControlHeight)];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.currentPage = 0;
    [self.headerContentView addSubview:self.pageControl];
    
    self.detailsPagedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.headerContentView.frame), currentViewWidth, currentViewHeight - kHeaderViewHeight)];
    self.detailsPagedScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.detailsPagedScrollView.delegate = self;
    self.detailsPagedScrollView.pagingEnabled = YES;
    self.detailsPagedScrollView.alpha = 1;
    self.detailsPagedScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.detailsPagedScrollView];
    
    self.detailsPagedContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, numberOfUserDetailsPages * currentViewWidth, self.detailsPagedScrollView.bounds.size.height)];
    self.detailsPagedContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.detailsPagedScrollView addSubview:self.detailsPagedContentView];
    
    for (int i = 0, count = self.detailsViewControllers.count; i < count; i ++) {
        UIViewController *viewController = [self.detailsViewControllers objectAtIndex:i];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        if([viewController conformsToProtocol:@protocol(CHScrollableViewController)]){
            ((UIViewController<CHScrollableViewController>*)viewController).scrollDelegate = self;
            // use KVO to observe the bounds of child view
        }
        [self.detailsPagedContentView addSubview:viewController.view];
        viewController.view.frame = CGRectMake(currentViewWidth * i, 0, currentViewWidth, CGRectGetHeight(self.detailsPagedContentView.bounds));
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.pageControl.numberOfPages = self.detailsViewControllers.count;

}

-(void)viewWillAppear:(BOOL)animated{
    // seems like there is an issue setting the content size before this point when navigation bar is present
    _detailsPagedScrollView.contentSize = _detailsPagedContentView.bounds.size;
}

-(void)viewDidAppear:(BOOL)animated{

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    NSInteger currentPage = self.pageControl.currentPage;
    [self resizeUserDetailsPagesWithScrollViewSize:self.detailsPagedScrollView.bounds.size];
    // after resize, we need to resume correct scrolling position
    [self.detailsPagedScrollView setContentOffset:CGPointMake(currentPage * CGRectGetWidth(self.detailsPagedScrollView.bounds), 0.0f) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - customer setter and getter methods

- (void)setHeaderViewController:(UIViewController *)headerViewController{
    if (self.headerViewController == headerViewController){
        return;
    }
    else {
        [self displayNewHeaderViewController:headerViewController animated:YES];
    }
}

#pragma mark - Public Methods
- (void)insertDetailsViewController:(UIViewController *)detailsViewController atIndex:(NSInteger)index animated:(BOOL)animated{
    // constrain index to between 0 and page count
    if(index < 0){
        index = 0;
    }
    else if( index > self.detailsViewControllers.count){
        index = self.detailsViewControllers.count;
    }

    NSMutableArray *detailsViewControllersMutable = [NSMutableArray arrayWithArray:self.detailsViewControllers];
    [detailsViewControllersMutable insertObject:detailsViewController atIndex:index];
    self.detailsViewControllers = [NSArray arrayWithArray: detailsViewControllersMutable];
    
    [self addChildViewController:detailsViewController];
    if ([detailsViewController conformsToProtocol:@protocol(CHScrollableViewController)]) {
        ((UIViewController<CHScrollableViewController>*)detailsViewController).scrollDelegate = self;
    }
//    [self.detailsPagedContentView addSubview:detailsViewController.view];
    [detailsViewController didMoveToParentViewController:self];
    
    [self makeSpaceForNewDetailsPageAtIndex:index animated:animated completion:^(BOOL finished) {
        [self slideUpNewDetailsPage:detailsViewController.view atIndex:index animated:animated completion:^(BOOL finished) {

        }];
    }];

}

- (void)removeDetailsViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    // do nothing if index is out of range
    if(index < 0 || index >= _detailsViewControllers.count){
        return;
    }

    UIViewController *detailsPageControllerToRemove = (UIViewController *)[self.detailsViewControllers objectAtIndex:index];
    [self slideDownDetailsPage:detailsPageControllerToRemove.view atIndex:index animated:animated completion:^(BOOL finished) {
        [self removeSpaceForRemovedDetailsPageAtIndex:index animated:animated completion:^(BOOL finished) {
            [detailsPageControllerToRemove willMoveToParentViewController:nil];
            [detailsPageControllerToRemove.view removeFromSuperview];
            [detailsPageControllerToRemove removeFromParentViewController];
        }];
    }];
    
    NSMutableArray *detailsViewControllersMutable = [NSMutableArray arrayWithArray:_detailsViewControllers];
    [detailsViewControllersMutable removeObjectAtIndex:index];
    _detailsViewControllers = [NSArray arrayWithArray:detailsViewControllersMutable];
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
-(void) scrollableViewDidScroll:(UIScrollView *)scrollView{
    [self scrollView:scrollView needToRelayoutTopView:self.headerContentView andBottomView:self.detailsPagedScrollView];
}

#pragma mark - private helper method

-(void)displayNewHeaderViewController:(UIViewController*) newHeaderViewController animated:(BOOL)animated{
    CGFloat animationDuration = animated ? animationDurationAnimated : animationDurationNotAnimated;
    if(newHeaderViewController){
        // add newHeaderViewController and its view
        newHeaderViewController.view.alpha = 0.0f;
        [self addChildViewController: newHeaderViewController];
        [self.headerContentView addSubview:newHeaderViewController.view];
        //not sure why setting frame and autoresizingMasks directly causes resize issue, have to use autolayout here, maybe because the headerview is constructed with autolayout?
//        newHeaderViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.headerContentView.frame), kHeaderViewHeight);
//        newHeaderViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [newHeaderViewController.view alignTop:@"0" leading:@"0" bottom:@"-20" trailing:@"0" toView:self.headerContentView];
        [newHeaderViewController didMoveToParentViewController:self];
    }
    
    UIViewController *oldHeaderViewController = self.headerViewController;
    _headerViewController = newHeaderViewController;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         oldHeaderViewController.view.alpha = 0.0f;
                         newHeaderViewController.view.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [oldHeaderViewController willMoveToParentViewController:nil];
                         [oldHeaderViewController.view removeFromSuperview];
                         [oldHeaderViewController removeFromParentViewController];
                     }];
}

-(void)makeSpaceForNewDetailsPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    CGFloat widthOfPage = CGRectGetWidth(self.detailsPagedScrollView.bounds);
    CGFloat animationDuration = animated ? animationDurationAnimated : animationDurationNotAnimated;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         // resize the container and scroll view content size 
                         self.detailsPagedContentView.frame = CGRectMake(CGRectGetMinX(self.detailsPagedContentView.frame),
                                                                         CGRectGetMinY(self.detailsPagedContentView.frame),
                                                                         CGRectGetWidth(self.detailsPagedContentView.frame) + widthOfPage,
                                                                         CGRectGetHeight(self.detailsPagedContentView.frame));
                         self.detailsPagedScrollView.contentSize = self.detailsPagedContentView.bounds.size;
                         
                         // slide all pages to the right of the new page toward right
                         for (UIViewController *detailsViewController in self.detailsViewControllers) {
                             int indexOfCurrentController = [self.detailsViewControllers indexOfObject:detailsViewController];
                             if (indexOfCurrentController >= index) {
                                 detailsViewController.view.frame = CGRectOffset(detailsViewController.view.frame, widthOfPage, 0.0f);
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         self.pageControl.numberOfPages = self.detailsViewControllers.count;
                         completion(finished);
                     }];
}

-(void)slideUpNewDetailsPage:(UIView*)newDetailsPage atIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    CGFloat widthOfPage = CGRectGetWidth(self.detailsPagedScrollView.bounds);
    CGFloat heightOfPage = CGRectGetHeight(self.detailsPagedScrollView.bounds);
    CGFloat animationDuration = animated ? animationDurationAnimated : animationDurationNotAnimated;
    
    newDetailsPage.frame = CGRectMake(index * widthOfPage,
                                      heightOfPage,
                                      widthOfPage,
                                      heightOfPage);
    newDetailsPage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.detailsPagedContentView addSubview:newDetailsPage];
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         newDetailsPage.frame = CGRectOffset(newDetailsPage.frame, 0.0f, -heightOfPage);
                     }
                     completion:^(BOOL finished) {
                         completion(finished);
                     }];
}

-(void)removeSpaceForRemovedDetailsPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    CGFloat widthOfPage = CGRectGetWidth(self.detailsPagedScrollView.bounds);
    CGFloat animationDuration = animated ? animationDurationAnimated : animationDurationNotAnimated;
    self.pageControl.numberOfPages = self.detailsViewControllers.count;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         //slide all pages to the right of the index toward left
                         for (UIViewController *detailsViewController in self.detailsViewControllers) {
                             int indexOfCurrentController = [self.detailsViewControllers indexOfObject:detailsViewController];
                             if (indexOfCurrentController >= index) {
                                 detailsViewController.view.frame = CGRectOffset(detailsViewController.view.frame, -widthOfPage, 0.0f);
                             }
                         }
                         
                         // resize the container and scroll view content size
                         self.detailsPagedContentView.frame = CGRectMake(CGRectGetMinX(self.detailsPagedContentView.frame),
                                                                         CGRectGetMinY(self.detailsPagedContentView.frame),
                                                                         CGRectGetWidth(self.detailsPagedContentView.frame) - widthOfPage,
                                                                         CGRectGetHeight(self.detailsPagedContentView.frame));
                         self.detailsPagedScrollView.contentSize = self.detailsPagedContentView.bounds.size;
                     }
                     completion:^(BOOL finished) {
                         completion(finished);
                     }];
}

-(void)slideDownDetailsPage:(UIView*)detailsPageToRemove atIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    CGFloat heightOfPage = CGRectGetHeight(self.detailsPagedScrollView.bounds);
    CGFloat animationDuration = animated ? animationDurationAnimated : animationDurationNotAnimated;

    [UIView animateWithDuration:animationDuration
                     animations:^{
                         detailsPageToRemove.frame = CGRectOffset(detailsPageToRemove.frame, 0.0f, heightOfPage);
                     }
                     completion:^(BOOL finished) {
                         [detailsPageToRemove removeFromSuperview];
                         completion(finished);
                     }];
}

-(void)resizeUserDetailsPagesWithScrollViewSize:(CGSize)newSize{
    int numberOfUserDetailsPages = self.detailsViewControllers.count;
    self.detailsPagedContentView.frame = CGRectMake(0.0f, 0.0f, numberOfUserDetailsPages*newSize.width,  newSize.height);
    self.detailsPagedScrollView.contentSize = self.detailsPagedContentView.bounds.size;
    for (int i = 0, count = self.detailsPagedContentView.subviews.count; i < count; i ++) {
        ((UIView *)self.detailsPagedContentView.subviews[i]).frame = CGRectMake(i * newSize.width, 0.0f, newSize.width,  newSize.height);
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
