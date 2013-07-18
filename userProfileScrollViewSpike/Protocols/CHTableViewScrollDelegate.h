//
//  CHTableViewScrollDelegate.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/17/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHTableViewScrollDelegate <NSObject>

@optional

- (void)tableViewDidScroll:(UIScrollView *)scrollView;

@end
