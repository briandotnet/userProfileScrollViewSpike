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
@property (nonatomic, readwrite, assign) CGFloat headerViewHeight;
@property (nonatomic, readwrite, strong) NSArray *detailViewControllers;

@end

@implementation CHPagedDetailsViewController{
    // since pageController is linked to scrollViewDidScroll event, during rotation where view size is changed, pageControl.currentPage will be changed. We needed an ivar to keep track of current page.
    NSInteger pageIndexBeforeRotation;
}
static const CGFloat animationDurationAnimated = 0.3f;
static const CGFloat kDefaultHeaderViewHeight = 180.0f;
static const CGFloat kPageControlHeight = 20.0f;
static NSString *kContentOffsetKeyPath = @"contentOffset";

- (id)initWithViewControllerForHeader:(UIViewController*)headerViewController viewControllersForPagedDetails:(NSArray<CHScrollableViewController>*)detailsViewControllers{
    self = [self init];
    if (self) {
        self.headerViewShouldScrollAway = YES;
        _detailViewControllers = detailsViewControllers;
        _headerViewController = headerViewController;
    }
    return self;
}

-(void)loadView{
    [super loadView];
//    self.view.backgroundColor = [UIColor yellowColor];
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = view;
    CGFloat currentViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat currentViewHeight = CGRectGetHeight(self.view.bounds);
    NSInteger numberOfDetailsPages = _detailViewControllers.count;
    
    if (self.headerViewController) {
        // use header view to set the header view height first
        if (CGRectGetHeight(self.headerViewController.view.bounds) == 0.0f) {
            self.headerViewHeight = kDefaultHeaderViewHeight;
        }
        else{
            self.headerViewHeight = CGRectGetHeight(self.headerViewController.view.bounds);
        }
    }
    
    self.headerContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, currentViewWidth, self.headerViewHeight + kPageControlHeight)];
    self.headerContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.headerContentView];
    if (self.headerViewController) {
        [self addChildViewController: self.headerViewController];
        [self.headerContentView addSubview:self.headerViewController.view];
        self.headerViewController.view.frame = CGRectMake(0.0f, 0.0f, currentViewWidth, self.headerViewHeight);
        self.headerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.headerViewController didMoveToParentViewController:self];
    }
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, self.headerViewHeight, currentViewWidth, kPageControlHeight)];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.currentPage = 0;
    [self.headerContentView addSubview:self.pageControl];
    CGFloat pageControlScrollViewOverlap = self.pageControlShouldScrollAway ? 0.0f : kPageControlHeight;
    self.detailsPagedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.headerContentView.frame) - pageControlScrollViewOverlap, currentViewWidth, currentViewHeight - CGRectGetHeight(self.headerContentView.frame) + pageControlScrollViewOverlap)];
    self.detailsPagedScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.detailsPagedScrollView.delegate = self;
    self.detailsPagedScrollView.pagingEnabled = YES;
    self.detailsPagedScrollView.alpha = 1;
    self.detailsPagedScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.detailsPagedScrollView];
    
    self.detailsPagedContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, numberOfDetailsPages * currentViewWidth, CGRectGetHeight(self.detailsPagedScrollView.bounds))];
    self.detailsPagedContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.detailsPagedScrollView addSubview:self.detailsPagedContentView];
    
    for (NSInteger i = 0, count = self.detailViewControllers.count; i < count; i ++) {
        UIViewController *viewController = [self.detailViewControllers objectAtIndex:i];
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
    self.pageControl.numberOfPages = self.detailViewControllers.count;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // seems like there is an issue setting the contentSize before this point when navigation bar is present
    self.detailsPagedScrollView.contentSize = self.detailsPagedContentView.bounds.size;
    [self resizeDetailsPagesWithScrollViewSize:self.detailsPagedScrollView.bounds.size];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    pageIndexBeforeRotation = self.pageControl.currentPage;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self resizeDetailsPagesWithScrollViewSize:self.detailsPagedScrollView.bounds.size];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    // !!!: remove all details views and viewControllers that are not previouse, current or next from self.view and self.
}

-(void)dealloc{
    // when PagedDetailsViewController gets deallocated, remove all observers
    for (UIViewController *detailsViewController in self.detailViewControllers) {
        if ([detailsViewController conformsToProtocol:@protocol(CHScrollableViewController)]) {
            [((UIViewController<CHScrollableViewController>*)detailsViewController).mainScrollView removeObserver:self forKeyPath:kContentOffsetKeyPath];
        }
    }
}

#pragma mark - customer setter and getter methods

- (void)setHeaderViewController:(UIViewController*)headerViewController{
    if (self.headerViewController == headerViewController){
        return;
    }
    else {
        [self setHeaderViewController:headerViewController animated:NO];
    }
}

#pragma mark - Public Methods

-(void)setHeaderViewController:(UIViewController*)headerViewController animated:(BOOL)animated{

    [self delegateWillReplaceHeaderViewController:self.headerViewController withNewHeaderViewController:headerViewController animated:animated];
    if (headerViewController) {
        if (CGRectGetHeight(headerViewController.view.bounds) == 0.0f) {
            self.headerViewHeight = kDefaultHeaderViewHeight;
        }
        else{
            self.headerViewHeight = CGRectGetHeight(headerViewController.view.bounds);
        }
    }
    else{
        self.headerViewHeight = 0.0f;
    }
    if(headerViewController){
        // add newHeaderViewController and its view
        [self addChildViewController: headerViewController];
        headerViewController.view.alpha = 0.0f;
        [self.headerContentView addSubview:headerViewController.view];
        headerViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.headerContentView.frame), self.headerViewHeight);
        headerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [headerViewController didMoveToParentViewController:self];
    }
    
    UIViewController *oldHeaderViewController = self.headerViewController;
    _headerViewController = headerViewController;
    
    void (^animation)(void)= ^{
        if (self.headerViewHeight > 0.0f) {
            self.headerContentView.frame = CGRectMake(CGRectGetMinX(self.headerContentView.frame), CGRectGetMinY(self.headerContentView.frame), CGRectGetWidth(self.headerContentView.frame), self.headerViewHeight + kPageControlHeight);
        }
        else{
            self.headerContentView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.headerContentView.frame), self.headerViewHeight + kPageControlHeight);
        }
        CGFloat pageControlScrollViewOverlap = self.pageControlShouldScrollAway ? 0.0f : kPageControlHeight;
        self.detailsPagedScrollView.frame = CGRectMake(CGRectGetMinX(self.detailsPagedScrollView.frame), CGRectGetMaxY(self.headerContentView.frame) - pageControlScrollViewOverlap, CGRectGetWidth(self.detailsPagedScrollView.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headerContentView.frame) + pageControlScrollViewOverlap);
        self.detailsPagedScrollView.contentSize = CGSizeMake(self.detailsPagedScrollView.contentSize.width, CGRectGetHeight(self.detailsPagedScrollView.bounds));
        oldHeaderViewController.view.alpha = 0.0f;
        headerViewController.view.alpha = 1.0f;
    };
    
    void (^completion)(BOOL finished) = ^(BOOL finished){
        [oldHeaderViewController willMoveToParentViewController:nil];
        [oldHeaderViewController.view removeFromSuperview];
        [oldHeaderViewController removeFromParentViewController];
        [self delegateDidReplaceHeaderViewController:oldHeaderViewController withNewHeaderViewController:self.headerViewController animated:animated];
    };
    if (animated) {
        [UIView animateWithDuration:animationDurationAnimated animations:animation completion:completion];
    }
    else{
        animation();
        completion(YES);
    }
}

- (NSUInteger)insertDetailsViewController:(UIViewController*)detailsViewController atIndex:(NSInteger)index animated:(BOOL)animated{
    if(detailsViewController == nil){
        return NSNotFound;
    }
    // constrain index to between 0 and page count
    if(index < 0){
        index = 0;
    }
    else if( index > self.detailViewControllers.count){
        index = self.detailViewControllers.count;
    }
    [self delegateWillInsertPageAtIndex:index];
    NSMutableArray *detailsViewControllersMutable = [NSMutableArray arrayWithArray:self.detailViewControllers];
    [detailsViewControllersMutable insertObject:detailsViewController atIndex:index];
    self.detailViewControllers = [NSArray arrayWithArray: detailsViewControllersMutable];
    
    [self addChildViewController:detailsViewController];
    if ([detailsViewController conformsToProtocol:@protocol(CHScrollableViewController)]) {
        UIViewController<CHScrollableViewController> *scrollableViewController = (UIViewController<CHScrollableViewController>*)detailsViewController;

        [scrollableViewController.mainScrollView addObserver:self forKeyPath:kContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    [detailsViewController didMoveToParentViewController:self];
    
    [self makeSpaceForNewDetailsPageAtIndex:index animated:animated completion:^(BOOL finished) {
        [self slideUpNewDetailsPage:detailsViewController.view atIndex:index animated:animated completion:^(BOOL finished) {
            [self delegateDidInsertPageAtIndex:index];
        }];
    }];
    
    return index;
}

- (void)removeDetailsViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    // do nothing if index is out of range
    if(index < 0 || index >= self.detailViewControllers.count){
        return;
    }

    UIViewController *detailsPageControllerToRemove = (UIViewController*)[self.detailViewControllers objectAtIndex:index];
    [self delegateWillRemovePageAtIndex:index];
    [self slideDownDetailsPage:detailsPageControllerToRemove.view atIndex:index animated:animated completion:^(BOOL finished) {
        [self removeSpaceForRemovedDetailsPageAtIndex:index animated:animated completion:^(BOOL finished) {
            if ([detailsPageControllerToRemove conformsToProtocol:@protocol(CHScrollableViewController)]) {
                [((UIViewController<CHScrollableViewController>*)detailsPageControllerToRemove).mainScrollView removeObserver:self forKeyPath:kContentOffsetKeyPath];
            }
            [detailsPageControllerToRemove willMoveToParentViewController:nil];
            [detailsPageControllerToRemove.view removeFromSuperview];
            [detailsPageControllerToRemove removeFromParentViewController];
            [self delegateDidRemovePageAtIndex:index];
        }];
    }];
    
    NSMutableArray *detailsViewControllersMutable = [NSMutableArray arrayWithArray:_detailViewControllers];
    [detailsViewControllersMutable removeObjectAtIndex:index];
    _detailViewControllers = [NSArray arrayWithArray:detailsViewControllersMutable];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView{
    if ([scrollView isEqual:self.detailsPagedScrollView]) {
        [self delegateWillBeginScrollFromPageIndex:self.pageControl.currentPage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    
    if([scrollView isEqual:self.detailsPagedScrollView]){
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
        NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView{
    if([scrollView isEqual:self.detailsPagedScrollView]){
        [self delegateDidScrollToPageIndex:self.pageControl.currentPage];
    }
}

#pragma mark - private helper method

- (void)runAnimationBlock:(void (^)(void))animationBlock andCompletionBlock:(void (^)(BOOL finished))completionBlock shouldAnimate:(BOOL)shouldAnimate{
    
    if (shouldAnimate) {
        [UIView animateWithDuration:animationDurationAnimated animations:animationBlock completion:completionBlock];
    }
    else{
        animationBlock();
        completionBlock(YES);
    }
}

- (void)makeSpaceForNewDetailsPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    CGFloat widthOfPage = CGRectGetWidth(self.detailsPagedScrollView.bounds);
//    CGFloat animationDuration = animated ? animationDurationAnimated : animationDurationNotAnimated;
    
    
    void (^animationBlock)(void)= ^{
        // resize the container and scroll view content size
        self.detailsPagedContentView.frame = CGRectMake(CGRectGetMinX(self.detailsPagedContentView.frame),
                                                        CGRectGetMinY(self.detailsPagedContentView.frame),
                                                        CGRectGetWidth(self.detailsPagedContentView.frame) + widthOfPage,
                                                        CGRectGetHeight(self.detailsPagedContentView.frame));
        self.detailsPagedScrollView.contentSize = self.detailsPagedContentView.bounds.size;
        
        // slide all pages to the right of the new page toward right
        for (UIViewController *detailsViewController in self.detailViewControllers) {
            NSInteger indexOfCurrentController = [self.detailViewControllers indexOfObject:detailsViewController];
            if (indexOfCurrentController >= index) {
                detailsViewController.view.frame = CGRectOffset(detailsViewController.view.frame, widthOfPage, 0.0f);
            }
        }
    };
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        self.pageControl.numberOfPages = self.detailViewControllers.count;
        if(completion){
            completion(finished);
        }
    };
    
    [self runAnimationBlock:animationBlock andCompletionBlock:completionBlock shouldAnimate:animated];
}

- (void)slideUpNewDetailsPage:(UIView*)newDetailsPage atIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    CGFloat widthOfPage = CGRectGetWidth(self.detailsPagedScrollView.bounds);
    CGFloat heightOfPage = CGRectGetHeight(self.detailsPagedScrollView.bounds);
    
    newDetailsPage.frame = CGRectMake(index * widthOfPage,
                                      heightOfPage,
                                      widthOfPage,
                                      heightOfPage);
    newDetailsPage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.detailsPagedContentView addSubview:newDetailsPage];
    
    
    void (^animationBlock)(void)= ^{
        newDetailsPage.frame = CGRectOffset(newDetailsPage.frame, 0.0f, -heightOfPage);
    };
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        if (completion) {
            completion(finished);
        }
    };
    [self runAnimationBlock:animationBlock andCompletionBlock:completionBlock shouldAnimate:animated];

}

- (void)removeSpaceForRemovedDetailsPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    CGFloat widthOfPage = CGRectGetWidth(self.detailsPagedScrollView.bounds);
    self.pageControl.numberOfPages = self.detailViewControllers.count;
    
    void (^animationBlock)(void)= ^{
        //slide all pages to the right of the index toward left
        for (UIViewController *detailsViewController in self.detailViewControllers) {
            NSInteger indexOfCurrentController = [self.detailViewControllers indexOfObject:detailsViewController];
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
    };
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        if (completion) {
            completion(finished);
        }
    };
    
    [self runAnimationBlock:animationBlock andCompletionBlock:completionBlock shouldAnimate:animated];
}

-(void)slideDownDetailsPage:(UIView*)detailsPageToRemove atIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    CGFloat heightOfPage = CGRectGetHeight(self.detailsPagedScrollView.bounds);

    
    void (^animationBlock)(void)= ^{
        detailsPageToRemove.frame = CGRectOffset(detailsPageToRemove.frame, 0.0f, heightOfPage);
    };
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        [detailsPageToRemove removeFromSuperview];
        if (completion) {
            completion(finished);
        }
    };
    
    [self runAnimationBlock:animationBlock andCompletionBlock:completionBlock shouldAnimate:animated];
}

- (void)resizeDetailsPagesWithScrollViewSize:(CGSize)newSize{
    if (newSize.width == CGRectGetWidth(self.detailsPagedContentView.bounds)) {
        return;
    }
    NSInteger numberOfDetailsPages = self.detailViewControllers.count;
    self.detailsPagedContentView.frame = CGRectMake(0.0f, 0.0f, numberOfDetailsPages*newSize.width,  newSize.height);

    for (NSInteger i = 0, count = self.detailsPagedContentView.subviews.count; i < count; i ++) {
        UIView *subview = (UIView*)self.detailsPagedContentView.subviews[i];
        subview.frame = CGRectMake(i * newSize.width, 0.0f, newSize.width,  newSize.height);
    }
    self.detailsPagedScrollView.contentSize = self.detailsPagedContentView.bounds.size;
    self.detailsPagedScrollView.contentOffset = CGPointMake(pageIndexBeforeRotation * newSize.width, 0);
}

- (void)scrollView:(UIScrollView*)scrollView needToRelayoutHeaderView:(UIView*)headerView andDetailsPagedScrollView:(UIScrollView*)detailsPagedScrollView{
    if(self.headerViewHeight > 0.0f){
        if (!self.headerViewShouldScrollAway) {
            return;
        }
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat headerContentViewBottomOffset = self.pageControlShouldScrollAway ? 0.0f : CGRectGetHeight(self.pageControl.bounds);
        
        // these BOOLs are just for readibility
        BOOL isPullingDown = offsetY < 0.0f;
        BOOL isPullingUp = offsetY > 0.0f;
        BOOL headerViewIsHidden = CGRectGetMaxY(headerView.frame) <= headerContentViewBottomOffset;
        BOOL headerViewIsHalfVisible =  (CGRectGetMaxY(headerView.frame) > headerContentViewBottomOffset) && (CGRectGetMinY(headerView.frame) < 0.0f);
        BOOL headerViewIsFullyVisible = CGRectGetMinY(headerView.frame) >= 0.0f;

        if (headerViewIsHalfVisible || (headerViewIsHidden && isPullingDown ) || (headerViewIsFullyVisible && isPullingUp)) {
            
            // first calculate the new frame for the headerView vertical according to the content y offset
            CGRect newFrameForHeaderView = CGRectOffset(headerView.frame, 0.0f, - offsetY);
            
            // on edge cases, we might overshift the top view, so we snap it to the correct position
            CGFloat pointsOverShifted = 0.0f;
            if (isPullingDown && newFrameForHeaderView.origin.y > 0.0f) {
                pointsOverShifted = 0.0f - CGRectGetMinY(newFrameForHeaderView);
            }
            else if (isPullingUp && CGRectGetMaxY(newFrameForHeaderView) < headerContentViewBottomOffset) {
                pointsOverShifted = headerContentViewBottomOffset - CGRectGetMaxY(newFrameForHeaderView);
            }
            if (pointsOverShifted != 0.0f) {
                newFrameForHeaderView = CGRectOffset(newFrameForHeaderView, 0.0f, pointsOverShifted);
            }
            
            if (CGRectGetMaxY(newFrameForHeaderView) <= headerContentViewBottomOffset) {
                [self delegateHeaderViewWillBecomeHidden];
            }
            if (CGRectGetMinY(newFrameForHeaderView) >= 0.0f) {
                [self delegateHeaderViewWillBecomeFullyVisible];
            }
            // take a note of the actual points we shifted the header view vertically
            float actualYDelta = headerView.frame.origin.y - newFrameForHeaderView.origin.y;
            headerView.frame = newFrameForHeaderView;
            [self delegateHeaderViewDidScroll];
            if (CGRectGetMaxY(headerView.frame) <= headerContentViewBottomOffset) {
                [self delegateHeaderViewDidBecomeHidden];
            }
            if (CGRectGetMinY(headerView.frame) >= 0.0f) {
                [self delegateHeaderViewDidBecomeFullyVisible];
            }
            
            // reset the content offset to 0 so the content in the scorll view doesn't scroll
            // note: do this before set the frame of any of the super views of the scroll view or contentOffset will be updated twice!
            scrollView.contentOffset = CGPointZero;
            
            // shift and resize the paging scroll view
            detailsPagedScrollView.frame = CGRectMake(0.0f, CGRectGetMinY(detailsPagedScrollView.frame) - actualYDelta, CGRectGetWidth(detailsPagedScrollView.frame), CGRectGetHeight(detailsPagedScrollView.frame) + actualYDelta);
            detailsPagedScrollView.contentSize = CGSizeMake(detailsPagedScrollView.contentSize.width, CGRectGetHeight(detailsPagedScrollView.bounds));
        }
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context{
    if([object isKindOfClass:[UIScrollView class]] && [keyPath isEqualToString:kContentOffsetKeyPath]){
        UIScrollView *scrollView = (UIScrollView*)object;
        if (!CGPointEqualToPoint(scrollView.contentOffset, CGPointZero)) {
            [self scrollView:scrollView needToRelayoutHeaderView:self.headerContentView andDetailsPagedScrollView:self.detailsPagedScrollView];
        }
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Delegate wrapper methods

-(void)delegateHeaderViewDidScroll{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:headerViewDidScroll:)]) {
        return [self.delegate pagedDetailsViewController:self headerViewDidScroll:self.headerViewController.view];
    }
}

-(void)delegateHeaderViewWillBecomeHidden{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:headerViewWillBecomeHidden:)]) {
        return [self.delegate pagedDetailsViewController:self headerViewWillBecomeHidden:self.headerViewController.view];
    }
}

-(void)delegateHeaderViewDidBecomeHidden{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:headerViewDidBecomeHidden:)]) {
        return [self.delegate pagedDetailsViewController:self headerViewDidBecomeHidden:self.headerViewController.view];
    }
}

-(void)delegateHeaderViewWillBecomeFullyVisible{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:headerViewWillBecomeFullyVisible:)]) {
        return [self.delegate pagedDetailsViewController:self headerViewWillBecomeFullyVisible:self.headerViewController.view];
    }
}

-(void)delegateHeaderViewDidBecomeFullyVisible{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:headerViewDidBecomeFullyVisible:)]) {
        return [self.delegate pagedDetailsViewController:self headerViewDidBecomeFullyVisible:self.headerViewController.view];
    }
}

- (void)delegateWillBeginScrollFromPageIndex:(NSInteger) fromPageIndex {
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:willBeginScrollFromPageIndex:)]){
        return [self.delegate pagedDetailsViewController:self willBeginScrollFromPageIndex:fromPageIndex];
    }
}
- (void)delegateDidScrollToPageIndex:(NSInteger) toPageIndex {
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:didScrollToPageIndex:)]){
        return [self.delegate pagedDetailsViewController:self didScrollToPageIndex:toPageIndex];
    }
}
- (void)delegateWillRemovePageAtIndex:(NSInteger) indexOfPageToRemove {
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:willRemovePageAtIndex:)]){
        return [self.delegate pagedDetailsViewController:self willRemovePageAtIndex:indexOfPageToRemove];
    }
}
- (void)delegateDidRemovePageAtIndex:(NSInteger) indexOfPageRemoved {
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:didRemovePageAtIndex:)]){
        return [self.delegate pagedDetailsViewController:self didRemovePageAtIndex:indexOfPageRemoved];
    }
}
- (void)delegateWillInsertPageAtIndex:(NSInteger)indexOfPageToInsert{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:willInsertPageAtIndex:)]){
        return [self.delegate pagedDetailsViewController:self willInsertPageAtIndex:indexOfPageToInsert];
    }
}
- (void)delegateDidInsertPageAtIndex:(NSInteger)indexOfPageToInsert{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:didInsertPageAtIndex:)]){
        return [self.delegate pagedDetailsViewController:self didInsertPageAtIndex:indexOfPageToInsert];
    }
}
- (void)delegateWillReplaceHeaderViewController:(UIViewController*)currentHeaderViewController withNewHeaderViewController:(UIViewController*)
newHeaderViewController animated:(BOOL)animated{
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:willReplaceHeaderViewController:withNewHeaderViewController:animated:)]){
        return [self.delegate pagedDetailsViewController:self willReplaceHeaderViewController:currentHeaderViewController withNewHeaderViewController:newHeaderViewController animated:(BOOL)animated];
    }
}
- (void)delegateDidReplaceHeaderViewController:(UIViewController*)replacedHeaderViewController withNewHeaderViewController:(UIViewController*)newHeaderViewController animated:(BOOL)animated{
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(pagedDetailsViewController:didReplaceHeaderViewController:withNewHeaderViewController:animated:)]){
        return [self.delegate pagedDetailsViewController:self didReplaceHeaderViewController:replacedHeaderViewController withNewHeaderViewController:newHeaderViewController animated:(BOOL)animated];
    }
}


@end
