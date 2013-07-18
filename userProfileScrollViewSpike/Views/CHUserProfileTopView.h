//
//  CHUserSummaryView.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/15/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHUserProfileViewModel.h"

@interface CHUserProfileTopView : UIView

@property (nonatomic, weak) CHUserProfileViewModel *userProfile;

#pragma mark - UI elements
@property (nonatomic, readonly, strong) UIImageView *profileImageView;
@property (nonatomic, readonly, strong) UILabel     *userNameLabel;
@property (nonatomic, readonly, strong) UILabel     *userJobTitleLabel;

- (id)initWithUserProfile:(CHUserProfileViewModel *)theUserProfile;

@end
