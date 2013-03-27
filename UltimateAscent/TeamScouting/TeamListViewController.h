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
@class SettingsData;

@interface TeamListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, assign) BOOL dataChange;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (void)showTeam:(TeamData *)team animated:(BOOL)animated;
- (void)retrieveSettings;

@end
