//
//  TeamListViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TeamData;

@interface TeamListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, assign) BOOL dataChange;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (void)showTeam:(TeamData *)team animated:(BOOL)animated;

@end
