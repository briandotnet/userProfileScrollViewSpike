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
    self = [super initWithFrame:CGRectMake(5, 5, 300, 200)];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
        
        self.indexTextField = ({                    
            UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(5, 70, 20, 20)];
            text.backgroundColor= [UIColor whiteColor];
            text.text = @"1";
            text.delegate = self;
            text.returnKeyType = UIReturnKeyDone;
            text;
        });
        
        UILabel *animation = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 95, 20)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:10];
            label.text = @"animation";
            label;
        });
        UILabel *pageControl = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(105, 5, 95, 20)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:10];
            label.text = @"pager scroll away";
            label;
        });
        
        UILabel *headerControl = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(205, 5, 95, 20)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:10];
            label.text = @"header scroll away";
            label;
        });
        
        self.animationSwitch = ({
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchControl.on = YES;
            switchControl.frame = CGRectOffset(switchControl.frame, 5, 25);
            switchControl;
        });
        
        self.pageControlScrollAwaySwitch = ({
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchControl.on = YES;
            switchControl.frame = CGRectOffset(switchControl.frame, 100, 25);
            [switchControl addTarget:self action:@selector(updatePageControlScrollAway) forControlEvents:UIControlEventValueChanged];
            switchControl;
        });
        
        self.headerScrollAwaySwitch = ({
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchControl.on = YES;
            switchControl.frame = CGRectOffset(switchControl.frame, 200, 25);
            [switchControl addTarget:self action:@selector(updateHeaderScrollAway) forControlEvents:UIControlEventValueChanged];
            switchControl;
        });
        
        UIButton *insertDetailsViewButton = ({ 
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(35, 70, 120, 20);
            [button setTitle:@"Insert Page" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(testInsertChildViewController) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        UIButton *removeDetailsViewButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(170, 70, 120, 20);
            [button setTitle:@"Remove Page" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(testRemoveChildViewController) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        UIButton *swapHeaderViewButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(35, 100, 120, 20);
            [button setTitle:@"Swap Header" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(testSwapHeaderViewController) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        UIButton *removeHeaderViewButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(170, 100, 120, 20);
            [button setTitle:@"Remove Header" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(testRemoveHeaderViewController) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        UIButton *toggleNavBarButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(35, 130, 200, 20);
            [button setTitle:@"Toggle Nav Bar" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(testToggleNavBar) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        [self addSubview:animation];
        [self addSubview:pageControl];
        [self addSubview:headerControl];
        [self addSubview:self.indexTextField];
        [self addSubview:self.animationSwitch];
        [self addSubview:self.pageControlScrollAwaySwitch];
        [self addSubview:self.headerScrollAwaySwitch];
        [self addSubview:insertDetailsViewButton];
        [self addSubview:removeDetailsViewButton];
        [self addSubview:swapHeaderViewButton];
        [self addSubview:removeHeaderViewButton];
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
    switch ([self.indexTextField.text integerValue]) {
        case 0:
            topViewController.view = [[CHUserProfileTopView alloc] initWithUserProfile:userProfile];
            break;
        default:
            topViewController.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 110)];
            topViewController.view.backgroundColor = [CHUtils randomColor];
            break;
    }
    [self.testingTarget setHeaderViewController:topViewController animated:self.animationSwitch.on];

    [self.indexTextField resignFirstResponder];
}

- (void) testRemoveHeaderViewController{
    [self.testingTarget setHeaderViewController:nil animated: self.animationSwitch.on];
    [self.indexTextField resignFirstResponder];
}

-(void) testToggleNavBar{
    [self.indexTextField resignFirstResponder];
    self.testingTarget.navigationController.navigationBarHidden = !self.testingTarget.navigationController.navigationBarHidden;
}

-(void)updatePageControlScrollAway{
    self.testingTarget.pageControlShouldScrollAway = self.pageControlScrollAwaySwitch.on;
}
-(void)updateHeaderScrollAway{
    self.testingTarget.headerViewShouldScrollAway = self.headerScrollAwaySwitch.on;
}
@end
