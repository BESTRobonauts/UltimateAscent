//
//  TeamListViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@class TeamData;

@interface TeamListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (void)showTeam:(TeamData *)team animated:(BOOL)animated;
- (void)retrieveSettings;

@end
