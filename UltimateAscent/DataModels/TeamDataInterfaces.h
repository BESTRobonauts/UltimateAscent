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
@class Regional;

@interface TeamDataInterfaces : NSObject
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSMutableDictionary *teamDataDictionary;
@property (nonatomic, strong) NSMutableDictionary *regionalDictionary;

-(id)initWithDataManager:(DataManager *)initManager;
-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(void)setTeamValue:(TeamData *)team forHeader:header withValue:data withProperties:(NSDictionary *)properties;
-(void)setAttributeValue:record forValue:data forAttribute:(id) attribute;
-(AddRecordResults)addTeamHistoryFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(void)setRegionalValue:(Regional *)regional forHeader:(NSString *)header withValue:(NSString *)data withProperties:(NSDictionary *)properties;
-(TeamData *)getTeam:(NSNumber *)teamNumber;
-(NSArray *)getTeamListTournament:(NSString *)tournament;
-(Regional *)getRegionalRecord:(TeamData *)team forWeek:(NSNumber *)week;
-(TeamData *)addTeam:(NSNumber *)teamNumber forName:(NSString *)teamName forTournament:(NSString *)tournamentName;
-(id)checkAlternateKeys:(NSDictionary *)keyList forEntry:header;
-(NSString *) exportTeamsToCSV:(NSString *)tournament;
-(void)setTeamDefaults:(TeamData *)blankTeam;

#ifdef TEST_MODE
-(void)testTeamInterfaces;
#endif

@end
