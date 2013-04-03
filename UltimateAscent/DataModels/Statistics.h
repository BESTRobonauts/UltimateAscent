//
//  Statistics.h
//  UltimateAscent
//
//  Created by FRC on 3/29/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamData, TournamentData;

@interface Statistics : NSManagedObject

@property (nonatomic, retain) NSNumber * autonAccuracy;
@property (nonatomic, retain) NSNumber * autonPoints;
@property (nonatomic, retain) NSNumber * aveAuton;
@property (nonatomic, retain) NSNumber * aveClimbHeight;
@property (nonatomic, retain) NSNumber * aveClimbTime;
@property (nonatomic, retain) NSNumber * aveTeleOp;
@property (nonatomic, retain) NSNumber * recalcStats;
@property (nonatomic, retain) NSNumber * stat1;
@property (nonatomic, retain) NSNumber * stat2;
@property (nonatomic, retain) NSNumber * stat3;
@property (nonatomic, retain) NSNumber * stat4;
@property (nonatomic, retain) NSNumber * stat5;
@property (nonatomic, retain) NSNumber * stat6;
@property (nonatomic, retain) NSNumber * stat7;
@property (nonatomic, retain) NSNumber * stat8;
@property (nonatomic, retain) NSNumber * stat9;
@property (nonatomic, retain) NSNumber * stat10;
@property (nonatomic, retain) NSNumber * stat11;
@property (nonatomic, retain) NSNumber * stat12;
@property (nonatomic, retain) NSString * statisticsId;
@property (nonatomic, retain) NSNumber * teleOpAccuracy;
@property (nonatomic, retain) NSNumber * teleOpPoints;
@property (nonatomic, retain) TeamData *team;
@property (nonatomic, retain) TournamentData *tournament;

@end
