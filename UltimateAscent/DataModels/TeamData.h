//
//  TeamData.h
//  UltimateAscent
//
//  Created by FRC on 3/31/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Regional, Statistics, TeamScore, TournamentData;

@interface TeamData : NSManagedObject

@property (nonatomic, retain) NSNumber * auton;
@property (nonatomic, retain) NSNumber * climbLevel;
@property (nonatomic, retain) NSNumber * climbSpeed;
@property (nonatomic, retain) NSNumber * driveTrainType;
@property (nonatomic, retain) NSNumber * fthing1;
@property (nonatomic, retain) NSNumber * fthing2;
@property (nonatomic, retain) NSNumber * fthing3;
@property (nonatomic, retain) NSNumber * fthing4;
@property (nonatomic, retain) NSNumber * fthing5;
@property (nonatomic, retain) NSString * history;
@property (nonatomic, retain) NSNumber * intake;
@property (nonatomic, retain) NSNumber * minHeight;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * nwheels;
@property (nonatomic, retain) NSNumber * pyramidDump;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSNumber * shooterHeight;
@property (nonatomic, retain) NSString * shootsTo;
@property (nonatomic, retain) NSNumber * stacked;
@property (nonatomic, retain) NSString * sthing1;
@property (nonatomic, retain) NSString * sthing3;
@property (nonatomic, retain) NSString * sthing4;
@property (nonatomic, retain) NSString * sthing5;
@property (nonatomic, retain) NSString * sting2;
@property (nonatomic, retain) NSString * teamdataId;
@property (nonatomic, retain) NSNumber * thing1;
@property (nonatomic, retain) NSNumber * thing2;
@property (nonatomic, retain) NSNumber * thing3;
@property (nonatomic, retain) NSNumber * thing4;
@property (nonatomic, retain) NSNumber * thing5;
@property (nonatomic, retain) NSNumber * wheelDiameter;
@property (nonatomic, retain) NSString * wheelType;
@property (nonatomic, retain) NSNumber * cims;
@property (nonatomic, retain) NSNumber * maxHeight;
@property (nonatomic, retain) NSSet *match;
@property (nonatomic, retain) NSSet *regional;
@property (nonatomic, retain) NSSet *stats;
@property (nonatomic, retain) NSSet *tournament;
@end

@interface TeamData (CoreDataGeneratedAccessors)

- (void)addMatchObject:(TeamScore *)value;
- (void)removeMatchObject:(TeamScore *)value;
- (void)addMatch:(NSSet *)values;
- (void)removeMatch:(NSSet *)values;

- (void)addRegionalObject:(Regional *)value;
- (void)removeRegionalObject:(Regional *)value;
- (void)addRegional:(NSSet *)values;
- (void)removeRegional:(NSSet *)values;

- (void)addStatsObject:(Statistics *)value;
- (void)removeStatsObject:(Statistics *)value;
- (void)addStats:(NSSet *)values;
- (void)removeStats:(NSSet *)values;

- (void)addTournamentObject:(TournamentData *)value;
- (void)removeTournamentObject:(TournamentData *)value;
- (void)addTournament:(NSSet *)values;
- (void)removeTournament:(NSSet *)values;

@end
