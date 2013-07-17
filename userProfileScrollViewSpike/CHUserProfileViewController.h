//
//  CHViewController.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHUserProfileViewModel.h"
#import "CHSimpleTableViewController.h"

@interface CHUserProfileViewController : UIViewController <UIScrollViewDelegate, TableViewScrollDelegate>{
    CHUserProfileViewModel *userProfile;
}

- (id)initWithUserProfileViewModel:(CHUserProfileViewModel *)theUserProfile;

@end
