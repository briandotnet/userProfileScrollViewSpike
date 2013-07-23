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
//@property (nonatomic, readonly, strong) UIView *userDetailsPagedContentView; 
@property (nonatomic, readonly, strong) UIViewController *headerViewController; // rename it to header
// custom setter - consider adding animation for add/remove hearder
@property (nonatomic, readonly, strong) NSArray *detailsViewControllers; // documentation to suggest which type of controllers this array expects
// custom setter, insert atIndex, remove atIndex - take a look at SFOverlayController (best example)

- (id)initWithViewControllerForTop:(UIViewController *)theTopViewController viewControllersForPagedDetails:(NSArray *)theDetailsViewControllers;


// one way communication from parent to child view controller

@end
