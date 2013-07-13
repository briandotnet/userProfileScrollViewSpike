//
//  CHAppDelegate.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHUserProfileViewController;

@interface CHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CHUserProfileViewController *viewController;

@end
