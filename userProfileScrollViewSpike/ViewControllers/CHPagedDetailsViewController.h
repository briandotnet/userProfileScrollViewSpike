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

/** The `CHPagedDetailsViewControllerDelegate` protocol defines methods a delegate of an
 `CHPagedDetailsViewController` instance can implement to customize the behavior, or to 
 respond to interactions caused on behalf of the user.
 */
@protocol CHPagedDetailsViewControllerDelegate <NSObject>

@optional

/** Sent to the receiver when the paged details scroll view will begin to scroll.
 
 @param pagedDetailsViewController  The paged details view controller sending this message.
 @param fromPageIndex               The page index the paged scroll view will scrol away from.
 */
-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController willBeginScrollFromPageIndex:(NSInteger) fromPageIndex;

/** Sent to the receiver when the paged details scroll view has stopped scrolling, and the 
 current page index after the scolling has stopped.
 
 @param pagedDetailsViewController  The paged details view controller sending this message.
 @param toPageIndex                 The page index the paged scroll view has scrolled to.
 */
-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController didScrollToPageIndex:(NSInteger) toPageIndex;

/** Sent to the receiver when a details page view controller indicated by the index will be removed.
 
 @param pagedDetailsViewController  The paged details view controller sending this message.
 @param indexOfPageToRemove         The index of the page to be removed.
 */
-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController willRemovePageAtIndex:(NSInteger)indexOfPageToRemove;

/** Sent to the receiver when a details page view controller indicated by the index has been removed.
 
 @param pagedDetailsViewController  The paged details view controller sending this message.
 @param indexOfPageRemoved          The index of the removed page before it has been removed.
 */
-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController didRemovePageAtIndex:(NSInteger)indexOfPageRemoved;

/** Sent to the receiver when a view controller will be inserted at the indicated index as a new details page.
 
 @param pagedDetailsViewController  The paged details view controller sending this message.
 @param indexOfPageToInsert         The index of the page to be inserted at.
 */
-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController willInsertPageAtIndex:(NSInteger)indexOfPageToInsert;

/** Sent to the receiver when a view controller has been inserted at the indicated index as a new details page.
 
 @param pagedDetailsViewController  The paged details view controller sending this message.
 @param indexOfPageInserted         The index of the inserted page after it has been insterted.
 */
-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController didInsertPageAtIndex:(NSInteger)indexOfPageInserted;

/** Sent to the receiver when the current header view controller will be replaced by a new header view controller.
 
 @param pagedDetailsViewController  The paged details view controller sending this message.
 @param currentHeaderViewController The current header view controller.
 @param newHeaderViewController     The new header view controller.
 */
-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController willReplaceHeaderViewController:(UIViewController *)currentHeaderViewController withNewHeaderViewController:(UIViewController*)newHeaderViewController;

/** Sent to the receiver when the current header view controller has been replaced by a new header view controller.
 
 @param pagedDetailsViewController  The paged details view controller sending this message.
 @param currentHeaderViewController The current header view controller.
 @param newHeaderViewController     The new header view controller.
 */
-(void)pagedDetailsViewController:(CHPagedDetailsViewController *)pagedDetailsViewController didReplaceHeaderViewController:(UIViewController *)currentHeaderViewController withNewHeaderViewController:(UIViewController*)newHeaderViewController;

@end


@interface CHPagedDetailsViewController : UIViewController <UIScrollViewDelegate>{
}

@property (nonatomic, readonly, strong) UIPageControl *pageControl;
@property (nonatomic, readonly, strong) UIScrollView *detailsPagedScrollView;

/** The view controller displays stationary on the top half of the view. 
 
 The vertical position of the header view will be adjusted base on the vertical
 scrolling of the details view controller that is displayed as the current page, 
 if said details view controller conforms to CHScrollableViewController protocal.
 
 Assigning a new view controller to this property is equivalent to calling the
 setHeaderViewController:animated method with the animated parameter
 set to `NO`.
 
 @see CHScrollableViewController
 @see setHeaderViewController:animated:
 */
@property (nonatomic, strong) UIViewController *headerViewController;

/** The collection of view controllers displayed on the bottom half of the 
 view in horizontally scrollable pages.
 
 If a view controll that conforms to CHScrollableViewController protocal is added to this collection, 
 the vertical scrolling of the main scroll view of the added view controller will cause the header view 
 to scroll vertically until it's off-screen to the top edge of the screen.
 
 To manipulate with the collection, use insertDetailsViewController:atIndex:animated: 
 and removeDetailsViewControllerAtIndex:animated:
 
 @see `CHScrollableViewController`.
 @see insertDetailsViewController:atIndex:animated:
 @see removeDetailsViewControllerAtIndex:animated:
 */
@property (nonatomic, readonly, strong) NSArray *detailsViewControllers;

/** The receiver's delegate, or `nil` if it doesn't have a delegate.
 
 See `CHPagedDetailsViewControllerDelegate` for the methods this delegate may implement.
 
 @see CHPagedDetailsViewControllerDelegate
 */
@property (nonatomic, assign) id<CHPagedDetailsViewControllerDelegate> delegate;

/** Whether the page control should scroll vertically with the header view off-screen to the top of the
 screen, or should stick to the top of the screen.
 
 By default the value is set to `NO` indicating the page control will stay visible during scroll.
 
 */
@property (nonatomic, assign) BOOL pageControlShouldScrollAway;

///---------------------------------------------------------------------------------------
/// @name Initializing a paged details view controller
///---------------------------------------------------------------------------------------

/** initialize a `CHPagedDetailsViewController` instance with the view controller used 
 as header view controller, and the controllers which views are used in the paged horizontal
 scroll view.
 
 @note When using view controlls that conform to `CHScrollableViewController` in the detailsViewControllers, 
 thevertical scrolling of the main scroll view of the view controller will cause the header view to scroll 
 vertically until it's off-screen to the top edge of the screen.
 
 @param headerViewController    view controller which view is to be displayed in header section.
 @param detailsViewControllers  view controllers which views are to be displayed in horizontally 
 scrollable pages.
 */
- (id)initWithViewControllerForHeader:(UIViewController *)headerViewController viewControllersForPagedDetails:(NSArray *)detailsViewControllers;

///---------------------------------------------------------------------------------------
/// @name Managing the header and details view controllers
///---------------------------------------------------------------------------------------

/** Replace the current header view controller and display its view in the header section.
 
 @param headerViewController    The new view controller for the header section.
 @param animated                Whether or not the transition between current and the new header
 view controller should animate.
 */
- (void)setHeaderViewController:(UIViewController*) headerViewController animated:(BOOL)animated;

/** Insert a new view controller in the details view controller collection at the index indicated, 
 and display its view as a page at the index.
 
 @note  If the detailsViewController is `nil`, -1 will be returned to indicate an error. If the
 index specified is out of range of the current details view controllers collection, the view
 controller will be inserted as the first page for the case where index is less than 0, or as
 last page for the case where index is larger than the total number of pages.
 
 @discussion pagedDetailsViewController:willInsertPageAtIndex: will be fired right after this call and
 before the insertion of the view controll and its view at the specified index.
 pagedDetailsViewController:didInsertPageAtIndex: will be fired after the completion of the insertion 
 of the view controller and its view. If animated, pagedDetailsViewController:didInsertPageAtIndex: 
 will only be fired after the animation has completed.
 
 @param detailsViewController   The new view controller for the header section.
 @param index                   The index of the new details page to be inserted at.
 @param animated                Whether or not the insertion should animate.
 
 @return The index of the new page inserted.
 */
- (NSInteger)insertDetailsViewController:(UIViewController *)detailsViewController atIndex:(NSInteger)index animated:(BOOL)animated;

/** Remove view controller from the details view controller collection at the index indicated.
 
 @note  If the index specified is out of range of the current details view controllers collection,
 nothing will be removed.
 
 @discussion pagedDetailsViewController:willRemovePageAtIndex: will be fired right after this call and
 before the removal of the view controll at the specified index and its view.
 pagedDetailsViewController:didRemovePageAtIndex: will be fired after the completion of the removal of
 the view controller and its view. If animated, pagedDetailsViewController:didRemovePageAtIndex: will 
 only be fired after the animation has completed.
 
 @param index                   The index of the details page to be removed.
 @param animated                Whether or not the removal should animate.
 */
- (void)removeDetailsViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
