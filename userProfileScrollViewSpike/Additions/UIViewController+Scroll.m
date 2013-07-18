//
//  UIViewController+Scroll.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/18/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "UIViewController+Scroll.h"

@implementation UIViewController (ScrollAdition)

static NSObject<CHTableViewScrollDelegate> *_scrollDelegate;

- (NSObject<CHTableViewScrollDelegate> *)scrollDelegate
{
    return _scrollDelegate; 
}

- (void)setScrollDelegate:(NSObject<CHTableViewScrollDelegate> *)scrollDelegate{
    _scrollDelegate = scrollDelegate;
}

#pragma mark - UIScrollViewDelegate methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(tableViewDidScroll:)]) {
        [self.scrollDelegate tableViewDidScroll:scrollView];
    }
}

@end

