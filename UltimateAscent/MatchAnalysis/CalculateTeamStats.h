//
//  CalculateTeamStats.h
//  UltimateAscent
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TeamData;

@interface CalculateTeamStats : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
-(void)calculateMason:(TeamData *)team forTournament:(NSString *)tournament;

@end
