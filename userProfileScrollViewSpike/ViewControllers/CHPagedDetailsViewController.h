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

@interface CHPagedDetailsViewController : UIViewController <UIScrollViewDelegate, CHScrollableViewControllerDelegate>{    
}

@property (nonatomic, readonly, strong) UIPageControl *pageControl;
@property (nonatomic, readonly, strong) UIScrollView *detailsPagedScrollView;
@property (nonatomic, readonly, strong) UIView *userDetailsPagedContentView;
@property (nonatomic, readonly, strong) UIViewController *topViewController;
@property (nonatomic, readonly, strong) NSArray<CHScrollableViewController> *detailsViewControllers;

- (id)initWithViewControllerForTop:(UIViewController *)theTopViewController viewControllersForPagedDetails:(NSArray<CHScrollableViewController> *)theDetailsViewControllers;


@end
