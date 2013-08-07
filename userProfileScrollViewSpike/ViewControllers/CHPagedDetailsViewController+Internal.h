//
//  CHPagedDetailsViewController+Internal.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/31/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHPagedDetailsViewController.h"

@interface CHPagedDetailsViewController ()

@property (nonatomic, strong) UIView *detailsPagedContentView;
@property (nonatomic, strong) UIView *headerContentView;

#pragma mark - delegate methods wrapper 

-(void)delegateHeaderViewDidScroll;

-(void)delegateHeaderViewWillBecomeHidden;

-(void)delegateHeaderViewDidBecomeHidden;

-(void)delegateHeaderViewWillBecomeFullyVisible;

-(void)delegateHeaderViewDidBecomeFullyVisible;

-(void)delegateWillBeginScrollFromPageIndex:(NSInteger) fromPageIndex;

-(void)delegateDidScrollToPageIndex:(NSInteger)toPageIndex;

-(void)delegateWillRemovePageAtIndex:(NSInteger)indexOfPageToRemove;

-(void)delegateDidRemovePageAtIndex:(NSInteger)indexOfPageRemoved;

-(void)delegateWillInsertPageAtIndex:(NSInteger)indexOfPageToInsert;

-(void)delegateDidInsertPageAtIndex:(NSInteger)indexOfPageToInsert;

-(void)delegateWillReplaceHeaderViewController:(UIViewController*)currentHeaderViewController withNewHeaderViewController:(UIViewController*)
newHeaderViewController animated:(BOOL)animated;

-(void)delegateDidReplaceHeaderViewController:(UIViewController*)replacedHeaderViewController withNewHeaderViewController:(UIViewController*)newHeaderViewController animated:(BOOL)animated;


@end