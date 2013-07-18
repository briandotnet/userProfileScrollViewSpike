//
//  CHUserProfileViewController.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHUserProfileViewModel.h"
#import "UIViewController+Scroll.h"

@interface CHUserProfileViewController : UIViewController <UIScrollViewDelegate, CHTableViewScrollDelegate>{
    
}

@property (nonatomic, strong) CHUserProfileViewModel *userProfile;

- (id)initWithUserProfileViewModel:(CHUserProfileViewModel *)theUserProfile viewControllerForTop:(UIViewController *)theTopViewController viewControllersForPagedDetails:(NSArray<CHTableViewScrollDelegate> *)theDetailsViewControllers;


@end
