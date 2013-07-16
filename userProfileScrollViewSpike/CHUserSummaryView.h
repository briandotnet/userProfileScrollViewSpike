//
//  CHUserSummaryView.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/15/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHUserProfileViewModel.h"

@interface CHUserSummaryView : UIView

@property (nonatomic, weak) CHUserProfileViewModel *userProfile;

- (id)initWithUserProfile:(CHUserProfileViewModel *)theUserProfile;

@end
