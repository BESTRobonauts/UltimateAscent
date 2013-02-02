//
//  TournamentData.h
//  UltimateAscent
//
//  Created by FRC on 2/1/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchData, SettingsData, TeamData, TeamScore;

@interface TournamentData : NSManagedObject

@property (nonatomic, retain) NSString * directory;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *match;
@property (nonatomic, retain) NSSet *score;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, retain) NSSet *teams;
@end

@interface TournamentData (CoreDataGeneratedAccessors)

- (void)addMatchObject:(MatchData *)value;
- (void)removeMatchObject:(MatchData *)value;
- (void)addMatch:(NSSet *)values;
- (void)removeMatch:(NSSet *)values;

- (void)addScoreObject:(TeamScore *)value;
- (void)removeScoreObject:(TeamScore *)value;
- (void)addScore:(NSSet *)values;
- (void)removeScore:(NSSet *)values;

- (void)addTeamsObject:(TeamData *)value;
- (void)removeTeamsObject:(TeamData *)value;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

@end
