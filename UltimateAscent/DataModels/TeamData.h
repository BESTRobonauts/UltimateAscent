//
//  TeamData.h
//  UltimateAscent
//
//  Created by FRC on 2/7/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore, TournamentData;

@interface TeamData : NSManagedObject

@property (nonatomic, retain) NSNumber * climbType;
@property (nonatomic, retain) NSString * history;
@property (nonatomic, retain) NSNumber * intakeFloor;
@property (nonatomic, retain) NSNumber * intakeInverted;
@property (nonatomic, retain) NSNumber * intakeStation;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSString * driveTrainNotes;
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
