//
//  CHScrollViewController.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/15/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHScrollViewController.h"
#import "UIView+FLKAutoLayout.h"

@interface CHScrollViewController ()

@end

@implementation CHScrollViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view = [[UIScrollView alloc] init];
        self.view.backgroundColor = [UIColor grayColor];
        ((UIScrollView *)self.view).contentSize = CGSizeMake(200, 3000);
        
//        int r = arc4random() % 5 + 5; // rand between 5 and 10
//        NSMutableArray *subviews = [NSMutableArray arrayWithCapacity:r];
//        for (int i = 0; i <= r; i++) {
//            UIView* subview = [[UIView alloc] init];
//            subview.backgroundColor = [UIColor whiteColor];
//            [self.view addSubview:subview];
//            [subviews addObject:subview];
//        }
//        [subviews[0] constrainHeight:@"100"];
//        [subviews[0] alignTopEdgeWithView:self.view predicate:@"10"];
//        [subviews[0] alignLeading:@"10" trailing:@"10" toView:self.view];
//        [UIView equalHeightForViews:subviews];
//        [UIView alignLeadingAndTrailingEdgesOfViews:subviews];
//        [UIView alignTopEdgesOfViews:subviews];
        
//        [subviews[0] alignCenterXWithView:self.view predicate:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
