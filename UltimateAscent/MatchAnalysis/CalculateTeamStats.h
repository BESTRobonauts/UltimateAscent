//
//  CalculateTeamStats.h
//  UltimateAscent
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TeamData;
@class DataManager;

@interface CalculateTeamStats : NSObject
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, assign) int nmatches;
@property (nonatomic, assign) float autonAccuracy;
@property (nonatomic, assign) int autonPoints;
@property (nonatomic, assign) int aveAuton;
@property (nonatomic, assign) float aveClimbHeight;
@property (nonatomic, assign) float aveClimbTime;
@property (nonatomic, assign) int aveTeleOp;
@property (nonatomic, assign) float aveDriving;
@property (nonatomic, assign) float aveDefense;
@property (nonatomic, assign) float aveSpeed;
@property (nonatomic, assign) BOOL hangs;
@property (nonatomic, assign) float teleOpAccuracy;
@property (nonatomic, assign) int teleOpPoints;
- (id)initWithDataManager:(DataManager *)initManager;
-(void)calculateMasonStats:(TeamData *)team forTournament:(NSString *)tournament;
-(void)setDefaults;

@end
