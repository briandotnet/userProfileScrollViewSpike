//
//  CHScrollableViewController.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/18/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHScrollableViewControllerDelegate.h"

@protocol CHScrollableViewController <NSObject>

@property (nonatomic, weak) NSObject<CHScrollableViewControllerDelegate> *scrollDelegate;

@required

-(void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end