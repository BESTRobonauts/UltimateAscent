//
//  MatchListViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMatchViewController.h"
#import "MatchDetailViewController.h"

@class DataManager;
@class SettingsData;
@class MatchData;

@interface MatchListViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate, AddMatchDelegate, MatchDetailDelegate>

@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, retain) NSArray *teamData;
@property (nonatomic, retain) NSMutableArray *teamOrder;
@property (nonatomic, retain) UIView *headerView;

-(void)retrieveSettings;
-(void)setTeamList:(MatchData *)match;

@end
