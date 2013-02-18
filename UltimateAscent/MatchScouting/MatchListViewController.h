//
//  MatchListViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsData;
@class MatchData;

@interface MatchListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, retain) NSArray *teamData;
@property (nonatomic, retain) NSMutableArray *teamOrder;

- (void)retrieveSettings;
-(void)setTeamList:(MatchData *)match;

@end
