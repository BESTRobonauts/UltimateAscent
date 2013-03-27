//
//  MatchResultsObject.h
//  UltimateAscent
//
//  Created by FRC on 3/14/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TeamScore;

@interface MatchResultsObject : NSObject <NSCoding>
@property (nonatomic, copy) NSString * alliance;
@property (nonatomic, copy) NSNumber * autonHigh;
@property (nonatomic, copy) NSNumber * autonLow;
@property (nonatomic, copy) NSNumber * autonMid;
@property (nonatomic, copy) NSNumber * autonMissed;
@property (nonatomic, copy) NSNumber * autonShotsMade;
@property (nonatomic, copy) NSNumber * blocks;
@property (nonatomic, copy) NSNumber * climbAttempt;
@property (nonatomic, copy) NSNumber * climbLevel;
@property (nonatomic, copy) NSNumber * climbTimer;
@property (nonatomic, copy) NSNumber * defenseRating;
@property (nonatomic, copy) NSNumber * driverRating;
@property (nonatomic, copy) NSString * fieldDrawing;
@property (nonatomic, copy) NSNumber * floorPickUp;
@property (nonatomic, copy) NSString * notes;
@property (nonatomic, copy) NSNumber * otherRating;
@property (nonatomic, copy) NSNumber * passes;
@property (nonatomic, copy) NSNumber * pyramid;
@property (nonatomic, copy) NSNumber * robotSpeed;
@property (nonatomic, copy) NSNumber * saved;
@property (nonatomic, copy) NSNumber * synced;
@property (nonatomic, copy) NSNumber * teleOpHigh;
@property (nonatomic, copy) NSNumber * teleOpLow;
@property (nonatomic, copy) NSNumber * teleOpMid;
@property (nonatomic, copy) NSNumber * teleOpMissed;
@property (nonatomic, copy) NSNumber * teleOpShots;
@property (nonatomic, copy) NSNumber * totalAutonShots;
@property (nonatomic, copy) NSNumber * totalTeleOpShots;
@property (nonatomic, copy) NSNumber * wallPickUp;
@property (nonatomic, copy) NSNumber * wallPickUp1;
@property (nonatomic, copy) NSNumber * wallPickUp2;
@property (nonatomic, copy) NSNumber * wallPickUp3;
@property (nonatomic, copy) NSNumber * wallPickUp4;
@property (nonatomic, copy) NSNumber * allianceSection;
@property (nonatomic, copy) NSNumber * sc1;
@property (nonatomic, copy) NSNumber * sc2;
@property (nonatomic, copy) NSNumber * sc3;
@property (nonatomic, copy) NSNumber * sc4;
@property (nonatomic, copy) NSNumber * sc5;
@property (nonatomic, copy) NSNumber * sc6;
@property (nonatomic, copy) NSString * sc7;
@property (nonatomic, copy) NSString * sc8;
@property (nonatomic, copy) NSString * sc9;
@property (nonatomic, copy) NSData * fieldDrawingImage;
@property (nonatomic, copy) NSNumber *match;
@property (nonatomic, copy) NSString *matchType;
@property (nonatomic, copy) NSString *tournament;
@property (nonatomic, copy) NSNumber *team;
@property (nonatomic, copy) NSString *drawingPath;

- (id)initWithScore:(TeamScore *)score;

@end
