//
//  CHPagedDetailsViewTestControlPanel.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/31/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHPagedDetailsViewController.h"

@interface CHPagedDetailsViewTestControlPanel : UIView <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *indexTextField;
@property (nonatomic, weak) CHPagedDetailsViewController *testingTarget;


@end
