//
//  CalculateTeamStats.m
//  UltimateAscent
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "CalculateTeamStats.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "TournamentData.h"
#import "Statistics.h"

@implementation CalculateTeamStats
@synthesize managedObjectContext = _managedObjectContext;

-(void)calculateMason:(TeamData *)team forTournament:(NSString *)tournament {
    if (!_managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        _managedObjectContext = [dataManager managedObjectContext];
    }
// fetch all score records for this tournament
    NSLog(@"team = %@", team);
    NSArray *matches = [team.match allObjects];
    NSArray *stats = [team.stats allObjects];
    Statistics *teamStats;
    if (![stats count]) {
        teamStats = [NSEntityDescription insertNewObjectForEntityForName:@"Statistics"
                                                         inManagedObjectContext:_managedObjectContext];
        [team addStatsObject:teamStats];
    }
    else {
        teamStats = [stats objectAtIndex:0];
    }
    
    int nmatches = [matches count];
    teamStats.stat1 = [NSNumber numberWithFloat:nmatches];
    NSLog(@"matches = %@", teamStats.stat1);
    
    int autonPoints = 0;
    int teleOpPoints = 0;
    float driving = 0;
    float defense = 0;
    float speed = 0;
    BOOL hangs = FALSE;
    
    for (int i=0; i<nmatches; i++) {
        TeamScore *match = [matches objectAtIndex:i];
        int points = [match.autonHigh intValue]*6 + [match.autonMid intValue]*5 + [match.autonLow intValue]*4;
        autonPoints += points;
        points = [match.teleOpHigh intValue]*3 + [match.teleOpMid intValue]*2 + [match.teleOpLow intValue];
        teleOpPoints += points;
        driving += [match.driverRating intValue];
        defense += [match.defenseRating intValue];
        speed += [match.robotSpeed intValue];
        hangs = hangs || [match.climbLevel intValue];
    }
    teamStats.autonPoints = [NSNumber numberWithInt:autonPoints];
    teamStats.teleOpPoints = [NSNumber numberWithInt:teleOpPoints];
    teamStats.stat2 = [NSNumber numberWithFloat:(driving/nmatches)];
    teamStats.stat3 = [NSNumber numberWithFloat:(defense/nmatches)];
    teamStats.stat4 = [NSNumber numberWithFloat:(speed/nmatches)];
    teamStats.stat5 = [NSNumber numberWithInt:hangs];
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

}

@end
