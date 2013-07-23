//
//  TeamDataInterfaces.h
//  UltimateAscent
//
//  Created by FRC on 5/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class DataManager;
@class TeamData;

@interface TeamDataInterfaces : NSObject
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) NSMutableDictionary *teamDataDictionary;

- (id)initWithDataManager:(DataManager *)initManager;
-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(void)setTeamValue:(TeamData *)team forHeader:header withValue:data;
-(TeamData *)getTeam:(NSNumber *)teamNumber;
-(NSArray *)getTeamListTournament:(NSString *)tournament;
-(void) createTeamDataCollection;
-(void)setTeamDefaults:(TeamData *)blankTeam;

@end
