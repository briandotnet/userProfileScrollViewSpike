//
//  CHAppDelegate.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHAppDelegate.h"

#import "CHPagedDetailsViewController.h"
#import "CHUserProfileViewModel.h"
#import "CHUserProfileTopView.h"
#import "CHSimpleTableViewController.h"
#import "CHPagedDetailsViewTestControlPanel.h"

@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    CHUserProfileViewModel *userProfile = [[CHUserProfileViewModel alloc] init];
    userProfile.userFirstName = @"Alicia";
    userProfile.userLastName = @"Burton";
    userProfile.jobTitle  = @"Account Executive";
    userProfile.profileImageURL = @"smile";
    userProfile.phoneNumber = @"1(415)888-7777";
    userProfile.emailAddress = @"sales@force.com";
    

    UIViewController *topViewController = [[UIViewController alloc] init];
    topViewController.view = [[CHUserProfileTopView alloc] initWithUserProfile:userProfile];
    topViewController.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 110)];

    CHSimpleTableViewController* tableviewController1;
    CHSimpleTableViewController* tableviewController2;
    CHSimpleTableViewController* tableviewController3;
    
    tableviewController1 = [[CHSimpleTableViewController alloc] init];
    tableviewController2 = [[CHSimpleTableViewController alloc] init];
    tableviewController3 = [[CHSimpleTableViewController alloc] init];
    
    UIViewController *newViewController = [[UIViewController alloc] init];
    newViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    newViewController.view.backgroundColor = [CHUtils randomColor];

    CHPagedDetailsViewController *pagedDetailsViewController = [[CHPagedDetailsViewController alloc] initWithViewControllerForHeader:topViewController viewControllersForPagedDetails:[NSArray arrayWithObjects: tableviewController1, tableviewController2, newViewController, tableviewController3, nil]];
    pagedDetailsViewController.pageControlShouldScrollAway = YES;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:pagedDetailsViewController];
    
    self.window.rootViewController = self.navigationController;

    // inject testing controls
    CHPagedDetailsViewTestControlPanel *testPanel = [[CHPagedDetailsViewTestControlPanel alloc] init];
    testPanel.testingTarget = pagedDetailsViewController;
    [pagedDetailsViewController.view addSubview:testPanel];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
