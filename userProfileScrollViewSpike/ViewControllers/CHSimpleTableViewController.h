//
//  CHSimpleTableViewController.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/16/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHSimpleTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

}

@property (nonatomic, strong) UITableView *tableView;

@end
