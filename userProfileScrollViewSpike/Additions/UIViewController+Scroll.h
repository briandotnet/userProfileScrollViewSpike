//
//  UIViewController+Scroll.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/18/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTableViewScrollDelegate.h"

@interface UIViewController (ScrollAdition)

@property (nonatomic, weak) NSObject<CHTableViewScrollDelegate> *scrollDelegate;

@end
