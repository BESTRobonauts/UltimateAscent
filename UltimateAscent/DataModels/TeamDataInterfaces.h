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

- (id)initWithDataManager:(DataManager *)initManager;
-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(void)setTeamValue:(TeamData *)team forHeader:header withValue:data;
-(AddRecordResults)addTeamHistoryFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(void)setRegionalValue:(Regional *)regional forHeader:(NSString *)header withValue:(NSString *)data;
-(TeamData *)getTeam:(NSNumber *)teamNumber;
-(NSArray *)getTeamListTournament:(NSString *)tournament;
-(Regional *)getRegionalRecord:(TeamData *)team forWeek:(NSNumber *)week;
-(TeamData *)addTeam:(NSNumber *)teamNumber forName:(NSString *)teamName forTournament:(NSString *)tournamentName;
-(void)createTeamDataCollection;
-(void)createRegionalCollection;
-(void)setTeamDefaults:(TeamData *)blankTeam;

#ifdef TEST_MODE
-(void)testTeamInterfaces;
#endif

@end
