//
//  CreateTournament.h
//  UltimateAscent
//
//  Created by FRC on 1/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class TournamentData;
@class DataManager;

@interface CreateTournament : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) DataManager *dataManager;

- (id)initWithDataManager:(DataManager *)initManager;

-(AddRecordResults)createTournamentFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(TournamentData *)GetTournament:(NSString *)name;

@end
