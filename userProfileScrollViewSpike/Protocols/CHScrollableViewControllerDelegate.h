//
//  CHScrollableViewControllerDelegate.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/17/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHScrollableViewControllerDelegate <NSObject>

@optional

- (void)scrollableViewDidScroll:(UIScrollView *)scrollView;

@end
