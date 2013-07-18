//
//  CHSimpleTableViewController.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/16/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTableViewScrollDelegate.h"

@interface CHSimpleTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

}

@property (nonatomic, weak) NSObject<CHTableViewScrollDelegate> *scrollDelegate;
@property (nonatomic, strong) UITableView *tableView;

@end
