//
//  SMTeamDataObject.h
//  UltimateAscent
//
//  Created by FRC on 3/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class TeamData;

@interface SMTeamDataObject : NSObject
@property (nonatomic, retain) DataManager *dataManager;

- (id)initWithDataManager:(DataManager *)initManager;
-(void)sendTeamDataToSM:(NSArray *)teamRecords;
-(void)setTeamRecord:(TeamData *)smTeam forLocalTeam:(TeamData *)team;
-(void)getTeamRecord:(TeamData *)smTeam forLocalTeam:(TeamData *)team;
-(void)retrieveTeamDataFromSM:(NSArray *)teamRecords;
@end
