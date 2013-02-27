//
//  TeamData.h
//  UltimateAscent
//
//  Created by FRC on 2/25/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore, TournamentData;

@interface TeamData : NSManagedObject

@property (nonatomic, retain) NSNumber * climbLevel;
@property (nonatomic, retain) NSNumber * driveTrainType;
@property (nonatomic, retain) NSString * history;
@property (nonatomic, retain) NSNumber * intake;
@property (nonatomic, retain) NSNumber * climbSpeed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSNumber * wheelDiameter;
@property (nonatomic, retain) NSNumber * cims;
@property (nonatomic, retain) NSNumber * minHeight;
@property (nonatomic, retain) NSNumber * maxHeight;
@property (nonatomic, retain) NSNumber * shooterHeight;
@property (nonatomic, retain) NSNumber * pyramidDump;
@property (nonatomic, retain) NSSet *match;
@property (nonatomic, retain) NSSet *tournament;
@end

@interface TeamData (CoreDataGeneratedAccessors)

- (void)addMatchObject:(TeamScore *)value;
- (void)removeMatchObject:(TeamScore *)value;
- (void)addMatch:(NSSet *)values;
- (void)removeMatch:(NSSet *)values;

- (void)addTournamentObject:(TournamentData *)value;
- (void)removeTournamentObject:(TournamentData *)value;
- (void)addTournament:(NSSet *)values;
- (void)removeTournament:(NSSet *)values;

@end
