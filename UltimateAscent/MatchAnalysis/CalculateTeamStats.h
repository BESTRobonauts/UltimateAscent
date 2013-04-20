//
//  CalculateTeamStats.h
//  UltimateAscent
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TeamData;
@class Statistics;

@interface CalculateTeamStats : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
-(Statistics *)calculateMason:(TeamData *)team forTournament:(NSString *)tournament;

@end
