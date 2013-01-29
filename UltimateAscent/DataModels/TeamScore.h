//
//  TeamScore.h
//  UltimateAscent
//
//  Created by Kris Pettinger on 1/26/13.
//  Copyright (c) 2013 ROBONAUTS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchData, TeamData;

@interface TeamScore : NSManagedObject

@property (nonatomic, retain) NSNumber * autonHigh;
@property (nonatomic, retain) NSNumber * autonLow;
@property (nonatomic, retain) NSNumber * autonMid;
@property (nonatomic, retain) NSNumber * autonMissed;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSNumber * teleOpHigh;
@property (nonatomic, retain) NSNumber * teleOpLow;
@property (nonatomic, retain) NSNumber * teleOpMid;
@property (nonatomic, retain) NSNumber * teleOpMissed;
@property (nonatomic, retain) NSString * autonFieldDrawing;
@property (nonatomic, retain) NSString * teleOpFieldDrawing;
@property (nonatomic, retain) NSString * alliance;
@property (nonatomic, retain) MatchData *match;
@property (nonatomic, retain) TeamData *team;

@end
