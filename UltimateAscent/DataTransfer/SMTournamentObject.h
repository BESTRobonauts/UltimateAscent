//
//  SMTournamentObject.h
//  UltimateAscent
//
//  Created by FRC on 3/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;

@interface SMTournamentObject : NSObject
@property (nonatomic, retain) DataManager *dataManager;

- (id)initWithDataManager:(DataManager *)initManager;
-(void)sendTournamentDataToSM:(NSArray *)tournamentRecords;
@end
