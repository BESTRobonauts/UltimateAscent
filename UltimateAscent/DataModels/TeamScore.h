//
//  TeamScore.h
//  UltimateAscent
//
//  Created by FRC on 2/7/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchData, TeamData, TournamentData;

@interface TeamScore : NSManagedObject

@property (nonatomic, retain) NSString * alliance;
@property (nonatomic, retain) NSNumber * autonHigh;
@property (nonatomic, retain) NSNumber * autonLow;
@property (nonatomic, retain) NSNumber * autonMid;
@property (nonatomic, retain) NSNumber * autonMissed;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSString * fieldDrawing;
@property (nonatomic, retain) NSNumber * teleOpHigh;
@property (nonatomic, retain) NSNumber * teleOpLow;
@property (nonatomic, retain) NSNumber * teleOpMid;
@property (nonatomic, retain) NSNumber * teleOpMissed;
@property (nonatomic, retain) NSNumber * defenseRating;
@property (nonatomic, retain) NSNumber * otherRating;
@property (nonatomic, retain) NSNumber * climbLevel;
@property (nonatomic, retain) NSNumber * climbSuccess;
@property (nonatomic, retain) NSNumber * climbTimer;
@property (nonatomic, retain) MatchData *match;
@property (nonatomic, retain) TeamData *team;
@property (nonatomic, retain) TournamentData *tournament;

@end
