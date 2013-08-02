//
//  CHPagedDetailsViewController.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHPagedDetailsViewController.h"
#import "CHPagedDetailsViewController+Internal.h"

@interface CHPagedDetailsViewController (){
}
@property (nonatomic, readwrite, strong) UIPageControl *pageControl;
@property (nonatomic, readwrite, strong) UIScrollView *detailsPagedScrollView;
@property (nonatomic, readwrite, strong) NSArray *detailsViewControllers;

@end

@implementation CHPagedDetailsViewController{
    // since pageController is linked to scrollViewDidScroll event, during rotation where view size is changed, pageControl.currentPage will be changed. We needed an ivar to keep track of current page.
    NSInteger pageIndexBeforeRotation;
}
static const CGFloat animationDurationAnimated = 0.3f;
static const CGFloat animationDurationNotAnimated = 0.0f;
// TODO: get rid of fixed header view height
static const CGFloat kHeaderViewHeight = 180.0f;
// TODO: get rid of fixed page control height;
static const CGFloat kPageControlHeight = 20.0f;
static NSString *kContentOffsetKeyPath = @"contentOffset";

- (id)initWithViewControllerForHeader:(UIViewController *)headerViewController viewControllersForPagedDetails:(NSArray<CHScrollableViewController> *)detailsViewControllers{
    self = [self init];
    if (self) {
        _detailsViewControllers = detailsViewControllers;
        _headerViewController = headerViewController;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    CGFloat currentViewWidth = CGRectGetWidth(self.view.frame);
    CGFloat currentViewHeight = CGRectGetHeight(self.view.frame);
    NSInteger numberOfUserDetailsPages = _detailsViewControllers.count;
    
    self.headerContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, currentViewWidth, kHeaderViewHeight + kPageControlHeight)];
    self.headerContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.headerContentView];
    if (self.headerViewController) {
        [self addChildViewController: self.headerViewController];
        [self.headerContentView addSubview:self.headerViewController.view];
        self.headerViewController.view.frame = CGRectMake(0.0f, 0.0f, currentViewWidth, kHeaderViewHeight);
        self.headerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.headerViewController didMoveToParentViewController:self];
    }
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, kHeaderViewHeight, currentViewWidth, kPageControlHeight)];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.currentPage = 0;
    [self.headerContentView addSubview:self.pageControl];
    
    self.detailsPagedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.headerContentView.frame), currentViewWidth, currentViewHeight - CGRectGetHeight(self.headerContentView.frame))];
    self.detailsPagedScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.detailsPagedScrollView.delegate = self;
    self.detailsPagedScrollView.pagingEnabled = YES;
    self.detailsPagedScrollView.alpha = 1;
    self.detailsPagedScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.detailsPagedScrollView];
    
    self.detailsPagedContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, numberOfUserDetailsPages * currentViewWidth, self.detailsPagedScrollView.bounds.size.height)];
    self.detailsPagedContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.detailsPagedScrollView addSubview:self.detailsPagedContentView];
    
    for (int i = 0, count = self.detailsViewControllers.count; i < count; i ++) {
        UIViewController *viewController = [self.detailsViewControllers objectAtIndex:i];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        if([viewController conformsToProtocol:@protocol(CHScrollableViewController)]){
            UIViewController<CHScrollableViewController> *scrollableViewController = (UIViewController<CHScrollableViewController>*)viewController;
            [scrollableViewController.mainScrollView addObserver:self forKeyPath:kContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:nil];
        }
        [self.detailsPagedContentView addSubview:viewController.view];
        viewController.view.frame = CGRectMake(currentViewWidth * i, 0.0f, currentViewWidth, CGRectGetHeight(self.detailsPagedContentView.bounds));
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    [self.view bringSubviewToFront:self.headerContentView];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.pageControl.numberOfPages = self.detailsViewControllers.count;
}

-(void)viewWillAppear:(BOOL)animated{
    // seems like there is an issue setting the contentSize before this point when navigation bar is present
    self.detailsPagedScrollView.contentSize = self.detailsPagedContentView.bounds.size;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
        pageIndexBeforeRotation = self.pageControl.currentPage;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self resizeUserDetailsPagesWithScrollViewSize:self.detailsPagedScrollView.bounds.size];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

// TODO: remove all details views and viewControllers that are not previouse, current or next from self.view and self.
}

-(void)dealloc{
    // when PagedDetailsViewController gets deallocated, remove all observers
    for (UIViewController *detailsViewController in self.detailsViewControllers) {
        if ([detailsViewController conformsToProtocol:@protocol(CHScrollableViewController)]) {
            [((UIViewController<CHScrollableViewController> *)detailsViewController).mainScrollView removeObserver:self forKeyPath:kContentOffsetKeyPath];
        }
    }
    
}

#pragma mark - customer setter and getter methods

- (void)setHeaderViewController:(UIViewController *)headerViewController{
    if (self.headerViewController == headerViewController){
        return;
    }
    else {
        [self setHeaderViewController:headerViewController animated:NO];
    }
}

#pragma mark - Public Methods

-(void)setHeaderViewController:(UIViewController*) headerViewController animated:(BOOL)animated{
    CGFloat animationDuration = animated ? animationDurationAnimated : animationDurationNotAnimated;
    if(headerViewController){
        if ([self.delegate respondsToSelector:@selector(pagedDetailsViewController:willReplaceHeaderViewController:withNewHeaderViewController:)]) {
            [self.delegate pagedDetailsViewController:self willReplaceHeaderViewController:self.headerViewController withNewHeaderViewController:headerViewController];
        }
        // add newHeaderViewController and its view
        [self addChildViewController: headerViewController];
        headerViewController.view.alpha = 0.0f;
        [self.headerContentView addSubview:headerViewController.view];
        headerViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.headerContentView.frame), kHeaderViewHeight);
        headerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [headerViewController didMoveToParentViewController:self];
    }
    
    UIViewController *oldHeaderViewController = self.headerViewController;
    _headerViewController = headerViewController;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         oldHeaderViewController.view.alpha = 0.0f;
                         headerViewController.view.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         [oldHeaderViewController willMoveToParentViewController:nil];
                         [oldHeaderViewController.view removeFromSuperview];
                         [oldHeaderViewController removeFromParentViewController];
                         if ([self.delegate respondsToSelector:@selector(pagedDetailsViewController:didReplaceHeaderViewController:withNewHeaderViewController:)]) {
                             [self.delegate pagedDetailsViewController:self didReplaceHeaderViewController:oldHeaderViewController withNewHeaderViewController:self.headerViewController];
                         }
                     }];
}

- (NSInteger)insertDetailsViewController:(UIViewController *)detailsViewController atIndex:(NSInteger)index animated:(BOOL)animated{
    if(detailsViewController == nil){
        return -1;
    }
    // constrain index to between 0 and page count
    if(index < 0){
        index = 0;
    }
    else if( index > self.detailsViewControllers.count){
        index = self.detailsViewControllers.count;
    }
    if ([self.delegate respondsToSelector:@selector(pagedDetailsViewController:willInsertPageAtIndex:)]) {
        [self.delegate pagedDetailsViewController:self willInsertPageAtIndex:index];
    }
    NSMutableArray *detailsViewControllersMutable = [NSMutableArray arrayWithArray:self.detailsViewControllers];
    [detailsViewControllersMutable insertObject:detailsViewController atIndex:index];
    self.detailsViewControllers = [NSArray arrayWithArray: detailsViewControllersMutable];
    
    [self addChildViewController:detailsViewController];
    if ([detailsViewController conformsToProtocol:@protocol(CHScrollableViewController)]) {
        UIViewController<CHScrollableViewController> *scrollableViewController = (UIViewController<CHScrollableViewController>*)detailsViewController;

        [scrollableViewController.mainScrollView addObserver:self forKeyPath:kContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    [detailsViewController didMoveToParentViewController:self];
    
    [self makeSpaceForNewDetailsPageAtIndex:index animated:animated completion:^(BOOL finished) {
        [self slideUpNewDetailsPage:detailsViewController.view atIndex:index animated:animated completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(pagedDetailsViewController:didInsertPageAtIndex:)]) {
                [self.delegate pagedDetailsViewController:self didInsertPageAtIndex:index];
            }
        }];
    }];
    
    return index;
}

- (void)removeDetailsViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    // do nothing if index is out of range
    if(index < 0 || index >= self.detailsViewControllers.count){
        return;
    }

    UIViewController *detailsPageControllerToRemove = (UIViewController *)[self.detailsViewControllers objectAtIndex:index];
    if ([self.delegate respondsToSelector:@selector(pagedDetailsViewController:willRemovePageAtIndex:)]) {
        [self.delegate pagedDetailsViewController:self willRemovePageAtIndex:index];
    }
    [self slideDownDetailsPage:detailsPageControllerToRemove.view atIndex:index animated:animated completion:^(BOOL finished) {
        [self removeSpaceForRemovedDetailsPageAtIndex:index animated:animated completion:^(BOOL finished) {
            if ([detailsPageControllerToRemove conformsToProtocol:@protocol(CHScrollableViewController)]) {
                [((UIViewController<CHScrollableViewController> *)detailsPageControllerToRemove).mainScrollView removeObserver:self forKeyPath:kContentOffsetKeyPath];
            }
            [detailsPageControllerToRemove willMoveToParentViewController:nil];
            [detailsPageControllerToRemove.view removeFromSuperview];
            [detailsPageControllerToRemove removeFromParentViewController];
            if ([self.delegate respondsToSelector:@selector(pagedDetailsViewController:didRemovePageAtIndex:)]) {
                    [self.delegate pagedDetailsViewController:self didRemovePageAtIndex:index];
            }
        }];
    }];
    
    NSMutableArray *detailsViewControllersMutable = [NSMutableArray arrayWithArray:_detailsViewControllers];
    [detailsViewControllersMutable removeObjectAtIndex:index];
    _detailsViewControllers = [NSArray arrayWithArray:detailsViewControllersMutable];
}

#pragma mark - Scroll View Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.detailsPagedScrollView]) {
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:willBeginScrollFromPageIndex:)])
            return [self.delegate pagedDetailsViewController:self didInsertPageAtIndex:self.pageControl.currentPage];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if([scrollView isEqual:self.detailsPagedScrollView]){
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if([scrollView isEqual:self.detailsPagedScrollView]){
        if ([self.delegate respondsToSelector:@selector(pagedDetailsViewController:didScrollToPageIndex:)]) {
            return [self.delegate pagedDetailsViewController:self didScrollToPageIndex:self.pageControl.currentPage];
        }
    }
}

#pragma mark - private helper method

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

    for (int i = 0, count = self.detailsPagedContentView.subviews.count; i < count; i ++) {
        ((UIView *)self.detailsPagedContentView.subviews[i]).frame = CGRectMake(i * newSize.width, 0.0f, newSize.width,  newSize.height);
    }
    self.detailsPagedScrollView.contentSize = self.detailsPagedContentView.bounds.size;
    self.detailsPagedScrollView.contentOffset = CGPointMake(pageIndexBeforeRotation * newSize.width, 0);
}

-(void)scrollView:(UIScrollView *)scrollView needToRelayoutHeaderView:(UIView *)headerView andDetailsPagedScrollView:(UIScrollView*)detailsPagedScrollView{
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat headerContentViewBottomOffset = self.pageControlShouldScrollAway ? 0.0f : CGRectGetHeight(self.pageControl.bounds);
    // these BOOLs are just for readibility
    BOOL isPullingDown = offsetY < 0.0f;
    BOOL isPullingUp = offsetY > 0.0f;
    BOOL headerViewIsHidden = CGRectGetMaxY(headerView.frame) <= headerContentViewBottomOffset;
    BOOL headerViewIsHalfVisible =  (CGRectGetMaxY(headerView.frame) > headerContentViewBottomOffset) && (CGRectGetMinY(headerView.frame) < 0.0f);
    BOOL headerViewIsFullyVisible = CGRectGetMinY(headerView.frame) >= 0.0f;

    if (headerViewIsHalfVisible || (headerViewIsHidden && isPullingDown ) || (headerViewIsFullyVisible && isPullingUp)) {
        
        // shift the headerView vertical according to the offset
        CGRect newFrameForTopView = CGRectOffset(headerView.frame, 0.0f, - offsetY);
        
        // on edge cases, we might overshift the top view, so we snap it to either 0 or -(height-headerContentViewBottomOffset).
        if (isPullingUp && newFrameForTopView.origin.y + CGRectGetHeight(newFrameForTopView) < headerContentViewBottomOffset) {
            newFrameForTopView = CGRectMake(0.0f, - (CGRectGetHeight(newFrameForTopView) - headerContentViewBottomOffset), CGRectGetWidth(newFrameForTopView), CGRectGetHeight(newFrameForTopView));
        }
        if (isPullingDown && newFrameForTopView.origin.y > 0.0f) {
            newFrameForTopView = CGRectMake(0.0f, 0.0f, CGRectGetWidth(newFrameForTopView), CGRectGetHeight(newFrameForTopView));
        }
        // take a note of the actual points we shifted the top view vertical
        float actualYDelta = headerView.frame.origin.y - newFrameForTopView.origin.y ;
        headerView.frame = newFrameForTopView;
        
        // reset the content offset to 0 so the content in the scorll view doesn't scroll
        // !Do this before set the frame of any of the super views of the scroll view or contentOffset will be updated twice!
        scrollView.contentOffset = CGPointZero;
        
        // shift and resize the paging scroll view
        detailsPagedScrollView.frame = CGRectMake(0.0f, CGRectGetMinY(detailsPagedScrollView.frame) - actualYDelta, CGRectGetWidth(detailsPagedScrollView.frame), CGRectGetHeight(detailsPagedScrollView.frame) + actualYDelta);
        detailsPagedScrollView.contentSize = CGSizeMake(detailsPagedScrollView.contentSize.width, detailsPagedScrollView.bounds.size.height);
    }
}

#pragma - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([object isKindOfClass:[UIScrollView class]] && [keyPath isEqualToString:kContentOffsetKeyPath]){
        UIScrollView *scrollView = (UIScrollView *)object;
        if (!CGPointEqualToPoint(scrollView.contentOffset, CGPointZero)) {
            [self scrollView:scrollView needToRelayoutHeaderView:self.headerContentView andDetailsPagedScrollView:self.detailsPagedScrollView];
        }
    }
}

@end
