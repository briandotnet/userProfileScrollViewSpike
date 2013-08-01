//
//  CHSimpleTableViewController.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/16/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHScrollableViewController.h"
#import "CHUtils.h"

@interface CHSimpleTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CHScrollableViewController>{

}
@property (nonatomic, weak) NSObject<CHScrollableViewControllerDelegate> *scrollDelegate;
@property (nonatomic, strong) UITableView *tableView;

@end
