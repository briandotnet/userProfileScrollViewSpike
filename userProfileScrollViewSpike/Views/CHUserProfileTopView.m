//
//  CHUserSummaryView.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/15/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHUserProfileTopView.h"
#import "UIView+FLKAutoLayout.h"
#import "CHUtils.h"

@interface CHUserProfileTopView (){
}

@property (nonatomic, readwrite, strong) UIImageView *profileImageView;
@property (nonatomic, readwrite, strong) UILabel     *userNameLabel;
@property (nonatomic, readwrite, strong) UILabel     *userJobTitleLabel;

@end

@implementation CHUserProfileTopView

static float const k_fontSizeLarge = 15;
static float const k_fontSizeMedium = 12;

- (id)initWithUserProfile:(CHUserProfileViewModel *)theUserProfile
{
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundColor = [CHUtils randomColor];
        
        self.profileImageView = [[UIImageView alloc] init];
        self.profileImageView.image = [CHUtils imageWithColor:[CHUtils randomColor]];//[UIImage imageNamed:theUserProfile.profileImageURL];
        
        self.userNameLabel = [[UILabel alloc] init];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", theUserProfile.userFirstName, theUserProfile.userLastName];
        self.userNameLabel.font = [UIFont boldSystemFontOfSize:k_fontSizeLarge];
        self.userNameLabel.textColor = [UIColor whiteColor];
        self.userNameLabel.backgroundColor = [UIColor clearColor];
        
        self.userJobTitleLabel  = [[UILabel alloc] init];
        self.userJobTitleLabel.text = theUserProfile.jobTitle;
        self.userJobTitleLabel.font = [UIFont systemFontOfSize:k_fontSizeMedium];
        self.userJobTitleLabel.textColor = [UIColor whiteColor];
        self.userJobTitleLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.profileImageView];
        [self addSubview:self.userNameLabel];
        [self addSubview:self.userJobTitleLabel];

        [self.profileImageView alignCenterXWithView:self predicate:nil];
        [self.profileImageView alignTopEdgeWithView:self predicate:@"30"];
        [self.profileImageView constrainHeight:@"80"];
        [self.profileImageView constrainWidth:@"80"];
        [self.userNameLabel alignCenterXWithView:self predicate:nil];
        [self.userNameLabel constrainTopSpaceToView:self.profileImageView predicate:@"10"];
        [self.userJobTitleLabel alignCenterXWithView:self predicate:nil];
        [self.userJobTitleLabel constrainTopSpaceToView:self.userNameLabel predicate:@"5"];
        
        [self constrainHeight:@"==180"];
        [self constrainWidth:@">=320"];

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
