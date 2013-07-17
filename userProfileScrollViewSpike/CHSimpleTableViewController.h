//
//  CHSimpleTableViewController.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/16/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableViewScrollDelegate <NSObject>

@optional 

- (void)tableViewDidScroll:(UIScrollView *)scrollView;

@end

@interface CHSimpleTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

}

@property (nonatomic, weak) NSObject<TableViewScrollDelegate> *scrollDelegate;
@property (nonatomic, strong) UITableView *tableView;

@end
