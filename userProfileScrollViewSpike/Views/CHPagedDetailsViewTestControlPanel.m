//
//  CHPagedDetailsViewTestControlPanel.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/31/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHPagedDetailsViewTestControlPanel.h"
#import "CHPagedDetailsViewController.h"
#import "CHSimpleTableViewController.h"
#import "CHUserProfileTopView.h"

@implementation CHPagedDetailsViewTestControlPanel

- (id)init
{
    self = [super initWithFrame:CGRectMake(5, 5, 200, 200)];
    if (self) {
        
        UIButton *insertDetailsViewButton;
        UIButton *removeDetailsViewButton;
        UIButton *swapHeaderViewButton;
        UIButton *toggleNavBarButton;
        
        self.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
        
        self.indexTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 70, 20, 20)];
        self.indexTextField.backgroundColor= [UIColor whiteColor];
        self.indexTextField.text = @"1";
        self.indexTextField.delegate = self;
        self.indexTextField.returnKeyType = UIReturnKeyDone;
        
        UILabel *animation = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 95, 20)];
            label.text = @"animation";
            label;
        });
        UILabel *pageControl = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(105, 5, 95, 20)];
            label.text = @"scroll away";
            label;
        });
        [self addSubview:animation];
        [self addSubview:pageControl];
        
        self.animationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.animationSwitch.on = YES;
        self.animationSwitch.frame = CGRectOffset(self.animationSwitch.frame, 5, 25);
        
        self.pageControlScrollAwaySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.pageControlScrollAwaySwitch.on = NO;
        self.pageControlScrollAwaySwitch.frame = CGRectOffset(self.pageControlScrollAwaySwitch.frame, 100, 25);
        [self.pageControlScrollAwaySwitch addTarget:self action:@selector(updatePageControlScrollAway) forControlEvents:UIControlEventValueChanged];
        
        insertDetailsViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        insertDetailsViewButton.frame = CGRectMake(35, 70, 140, 20);
        [insertDetailsViewButton setTitle:@"Insert" forState:UIControlStateNormal];
        [insertDetailsViewButton addTarget:self action:@selector(testInsertChildViewController) forControlEvents:UIControlEventTouchUpInside];
        
        removeDetailsViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        removeDetailsViewButton.frame = CGRectMake(35, 95, 140, 20);
        [removeDetailsViewButton setTitle:@"Remove" forState:UIControlStateNormal];
        [removeDetailsViewButton addTarget:self action:@selector(testRemoveChildViewController) forControlEvents:UIControlEventTouchUpInside];
        
        swapHeaderViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        swapHeaderViewButton.frame = CGRectMake(35, 120, 140, 20);
        [swapHeaderViewButton setTitle:@"Swap Header" forState:UIControlStateNormal];
        [swapHeaderViewButton addTarget:self action:@selector(testSwapHeaderViewController) forControlEvents:UIControlEventTouchUpInside];
        
        toggleNavBarButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        toggleNavBarButton.frame = CGRectMake(35, 145, 140, 20);
        [toggleNavBarButton setTitle:@"Toggle Nav Bar" forState:UIControlStateNormal];
        [toggleNavBarButton addTarget:self action:@selector(testToggleNavBar) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.indexTextField];
        [self addSubview:self.animationSwitch];
        [self addSubview:self.pageControlScrollAwaySwitch];
        [self addSubview:insertDetailsViewButton];
        [self addSubview:removeDetailsViewButton];
        [self addSubview:swapHeaderViewButton];
        [self addSubview:toggleNavBarButton];
        
        self.alpha = 0.7f;
        
    }
    return self;
}

#pragma mark - testing methods
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void) testInsertChildViewController{
    UIViewController *newViewController;
    int caseNumber = arc4random() % 2;
    
    switch (caseNumber) {
        case 0:
            newViewController = [[CHSimpleTableViewController alloc] init];
            break;
        case 1:
        default:
            newViewController = [[UIViewController alloc] init];
            newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            newViewController.view.backgroundColor = [CHUtils randomColor];
            break;
    }
    [self.testingTarget insertDetailsViewController:newViewController atIndex:[self.indexTextField.text integerValue] animated:self.animationSwitch.on];
    [self.indexTextField resignFirstResponder];
}

-(void) testRemoveChildViewController{
    [self.testingTarget removeDetailsViewControllerAtIndex:[self.indexTextField.text integerValue] animated:self.animationSwitch.on];
    [self.indexTextField resignFirstResponder];
}

-(void) testSwapHeaderViewController{
    CHUserProfileViewModel *userProfile = [[CHUserProfileViewModel alloc] init];
    userProfile.userFirstName = [NSString stringWithFormat: @"User %d", arc4random() % 10];
    userProfile.userLastName = @"last name";
    userProfile.jobTitle  = [NSString stringWithFormat: @"Project Manager %d", arc4random() % 10];    
    
    UIViewController *topViewController = [[UIViewController alloc] init];
    topViewController.view = [[CHUserProfileTopView alloc] initWithUserProfile:userProfile];
    switch ([self.indexTextField.text integerValue]) {
        case 0:
            [self.testingTarget setHeaderViewController:nil animated: self.animationSwitch.on];
            break;
        default:
            [self.testingTarget setHeaderViewController:topViewController animated:self.animationSwitch.on];
            break;
    }
    [self.indexTextField resignFirstResponder];
}

-(void) testToggleNavBar{
    [self.indexTextField resignFirstResponder];
    self.testingTarget.navigationController.navigationBarHidden = !self.testingTarget.navigationController.navigationBarHidden;
}

-(void)updatePageControlScrollAway{
    self.testingTarget.pageControlShouldScrollAway = self.pageControlScrollAwaySwitch.on;
}
@end
