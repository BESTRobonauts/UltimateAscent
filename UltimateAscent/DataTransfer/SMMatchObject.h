//
//  SMMatchObject.h
//  UltimateAscent
//
//  Created by FRC on 4/8/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class TeamScore;
@class MatchData;

@interface SMMatchObject : NSObject
@property (nonatomic, retain) DataManager *dataManager;

- (id)initWithDataManager:(DataManager *)initManager;
-(void)sendMatchDataToSM:(NSArray *)matchRecords;
-(void)setMatchRecord:(MatchData *)smMatch forLocalMatch:(MatchData *)match;

@end
