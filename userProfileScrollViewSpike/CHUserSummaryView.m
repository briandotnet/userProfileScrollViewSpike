//
//  CHUserSummaryView.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/15/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHUserSummaryView.h"
#import "UIView+FLKAutoLayout.h"

@interface CHUserSummaryView (){
    UIImageView *profileImageView;
    UILabel     *userNameLabel;
    UILabel     *userJobTitleLabel;
}

@end

@implementation CHUserSummaryView

static float const k_fontSizeLarge = 15;
static float const k_fontSizeMedium = 12;

- (id)initWithUserProfile:(CHUserProfileViewModel *)theUserProfile
{
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blueColor];
        
        profileImageView = [[UIImageView alloc] init];
        profileImageView.backgroundColor = [UIColor brownColor];
        profileImageView.image = [UIImage imageNamed:theUserProfile.profileImageURL];
        
        userNameLabel = [[UILabel alloc] init];
        userNameLabel.text = [NSString stringWithFormat:@"%@ %@", theUserProfile.userFirstName, theUserProfile.userLastName];
        userNameLabel.font = [UIFont boldSystemFontOfSize:k_fontSizeLarge];
        userNameLabel.textColor = [UIColor whiteColor];
        userNameLabel.backgroundColor = [UIColor clearColor];
        
        userJobTitleLabel  = [[UILabel alloc] init];
        userJobTitleLabel.text = theUserProfile.jobTitle;
        userJobTitleLabel.font = [UIFont systemFontOfSize:k_fontSizeMedium];
        userJobTitleLabel.textColor = [UIColor whiteColor];
        userJobTitleLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:profileImageView];
        [self addSubview:userNameLabel];
        [self addSubview:userJobTitleLabel];

        [profileImageView alignCenterXWithView:self predicate:nil];
        [profileImageView alignTopEdgeWithView:self predicate:@"30"];
        [profileImageView constrainHeight:@"80"];
        [profileImageView constrainWidth:@"80"];
        [userNameLabel alignCenterXWithView:self predicate:nil];
        [userNameLabel constrainTopSpaceToView:profileImageView predicate:@"10"];
        [userJobTitleLabel alignCenterXWithView:self predicate:nil];
        [userJobTitleLabel constrainTopSpaceToView:userNameLabel predicate:@"5"];
        
        [self constrainHeight:@"==180"];

    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
