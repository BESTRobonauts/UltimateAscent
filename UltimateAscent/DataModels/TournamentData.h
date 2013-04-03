//
//  TournamentData.h
//  UltimateAscent
//
//  Created by FRC on 3/29/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SettingsData, Statistics, TeamData, TeamScore;

@interface TournamentData : NSManagedObject

@property (nonatomic, retain) NSString * directory;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tournamentdataId;
@property (nonatomic, retain) NSSet *score;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, retain) NSSet *statistics;
@property (nonatomic, retain) NSSet *teams;
@end

@interface TournamentData (CoreDataGeneratedAccessors)

- (void)addScoreObject:(TeamScore *)value;
- (void)removeScoreObject:(TeamScore *)value;
- (void)addScore:(NSSet *)values;
- (void)removeScore:(NSSet *)values;

- (void)addStatisticsObject:(Statistics *)value;
- (void)removeStatisticsObject:(Statistics *)value;
- (void)addStatistics:(NSSet *)values;
- (void)removeStatistics:(NSSet *)values;

- (void)addTeamsObject:(TeamData *)value;
- (void)removeTeamsObject:(TeamData *)value;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

@end
