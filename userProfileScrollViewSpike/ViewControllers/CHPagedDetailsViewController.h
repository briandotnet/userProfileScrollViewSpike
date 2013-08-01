//
//  CHPagedDetailsViewController.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHUserProfileViewModel.h"
#import "CHScrollableViewController.h"


@class CHPagedDetailsViewController;

@protocol CHPagedDetailsViewControllerDelegate <NSObject>

@optional

-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController willScrollFromPageIndex:(NSInteger) fromPageIndex toPageIndex:(NSInteger)toPageIndex;

-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController didScrollToPageIndex:(NSInteger) toPageIndex fromPageIndex:(NSInteger)fromPageIndex;

-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController willRemovePageAtIndex:(NSInteger)indexOfPageToRemove;

-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController didRemovePageAtIndex:(NSInteger)indexOfPageRemoved;

-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController willInsertPageAtIndex:(NSInteger)indexOfPageToInsert;

-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController didInsertPageAtIndex:(NSInteger)indexOfPageInserted;

-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController willReplaceHeaderViewController:(UIViewController *)currentHeaderViewController withNewHeaderViewController:(UIViewController*)newHeaderViewController;

-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController didReplaceHeaderViewController:(UIViewController *)currentHeaderViewController withNewHeaderViewController:(UIViewController*)newHeaderViewController;

@end

@interface CHPagedDetailsViewController : UIViewController <UIScrollViewDelegate, CHScrollableViewControllerDelegate>{
    NSArray *_detailsViewControllers;
}

@property (nonatomic, readonly, strong) UIPageControl *pageControl;
@property (nonatomic, readonly, strong) UIScrollView *detailsPagedScrollView;
@property (nonatomic, setter = setHeaderViewController:, strong) UIViewController *headerViewController;
// custom setter - consider adding animation for add/remove hearder
@property (nonatomic, strong) NSArray *detailsViewControllers; // documentation to suggest which type of controllers this array expects

- (id)initWithViewControllerForTop:(UIViewController *)theTopViewController viewControllersForPagedDetails:(NSArray *)theDetailsViewControllers;


- (void)insertDetailsViewController:(UIViewController *)detailsViewController atIndex:(NSInteger)index animated:(BOOL)animated;


- (void)removeDetailsViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated;
// one way communication from parent to child view controller, use KVO pattern instead of delegate pattern

@end
