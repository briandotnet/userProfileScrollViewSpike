//
//  CHViewController.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHUserProfileViewController.h"
#import "UIView+FLKAutoLayout.h"
#import "CHUserSummaryView.h"
#import "CHScrollViewController.h"

@interface CHUserProfileViewController (){
    UIPageControl *pageControl;
    UIScrollView *scrollViewsContainerView;
    CHUserSummaryView *userSummaryView;
}

@end

@implementation CHUserProfileViewController

- (id)initWithUserProfileViewModel:(CHUserProfileViewModel *)theUserProfile{
    self = [self init];
    if (self) {
        userProfile = theUserProfile;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    scrollViewsContainerView = [[UIScrollView alloc] init];
    scrollViewsContainerView.backgroundColor = [UIColor whiteColor];
    scrollViewsContainerView.showsHorizontalScrollIndicator = YES;
    scrollViewsContainerView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:scrollViewsContainerView];
    [scrollViewsContainerView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.view];

    
    userSummaryView = [[CHUserSummaryView alloc] initWithUserProfile:userProfile];
    [self.view addSubview:userSummaryView];
    [userSummaryView alignTopEdgeWithView:self.view predicate:@"0"];
    [userSummaryView alignLeading:@"0" trailing:@"0" toView:self.view];
    userSummaryView.alpha = 1;
    
    
    
    UIView *feedContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 2000)];
    feedContentView.backgroundColor = [UIColor grayColor];
    [scrollViewsContainerView addSubview:feedContentView];
//http://developer.apple.com/library/ios/#releasenotes/General/RN-iOSSDK-6_0/index.html
//    [feedContentView constrainHeight:@"==2000"];
//    [feedContentView constrainWidth:@"==320"];
//    [feedContentView alignTop:@"0" leading:@"0" toView:scrollViewsContainerView];
    scrollViewsContainerView.contentSize = feedContentView.frame.size;
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.backgroundColor = [UIColor redColor];
    pageControl.numberOfPages = 3;
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
    [pageControl alignCenterXWithView:self.view predicate:nil];
    [pageControl alignBottomEdgeWithView:self.view predicate:@"-20"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
