//
//  CreateTeam.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/24/12.
//  Copyright (c) 2013 ROBONAUTS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class DataManager;
@class TeamData;
@class TournamentData;
@class Regional;

@interface CreateTeam : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) DataManager *dataManager;

- (id)initWithDataManager:(DataManager *)initManager;

-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(AddRecordResults)addTeamHistoryFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(TeamData *)GetTeam:(NSNumber *)teamNumber;
-(void)setTeamDefaults:(TeamData *)blankTeam;
-(TournamentData *)getTournamentRecord:(NSString *)tournamentName;
-(Regional *)getRegionalRecord:(NSNumber *)week forRegionals:(NSArray *)regionalList;

@end
