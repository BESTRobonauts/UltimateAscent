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

-(Statistics *)calculateMason:(TeamData *)team forTournament:(NSString *)tournament {
    if (!_managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        _managedObjectContext = [dataManager managedObjectContext];
    }
    
    if (!team) {
        return nil;
    }
    
// fetch all score records for this tournament
    NSArray *allMatches = [team.match allObjects];
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
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament.name = %@", tournament];
    NSArray *matches = [allMatches filteredArrayUsingPredicate:pred];
    
    int nmatches = 0;
    int autonPoints = 0;
    int teleOpPoints = 0;
    float driving = 0;
    float defense = 0;
    float speed = 0;
    float hangLevel = 0.0;
    BOOL hangs = FALSE;
    
    for (int i=0; i<[matches count]; i++) {
        TeamScore *match = [matches objectAtIndex:i];
        // Only use Seeding or Elimination matches that have been saved or synced
        if ( ([match.match.matchType isEqualToString:@"Seeding"]
              || [match.match.matchType isEqualToString:@"Elimination"])
            && ([match.saved intValue] || [match.synced intValue])) {
            nmatches++;
            int points = [match.autonHigh intValue]*6 + [match.autonMid intValue]*5 + [match.autonLow intValue]*4;
            autonPoints += points;
            points = [match.teleOpHigh intValue]*3 + [match.teleOpMid intValue]*2 + [match.teleOpLow intValue];
            teleOpPoints += points;
            driving += [match.driverRating intValue];
            defense += [match.defenseRating intValue];
            speed += [match.robotSpeed intValue];
            hangLevel += [match.climbLevel floatValue];
            hangs = hangs || [match.climbLevel intValue];
        }
    }
    teamStats.stat1 = [NSNumber numberWithFloat:nmatches];
    teamStats.autonPoints = [NSNumber numberWithInt:autonPoints];
    teamStats.teleOpPoints = [NSNumber numberWithInt:teleOpPoints];
    teamStats.stat5 = [NSNumber numberWithInt:hangs];
    if (nmatches) {
        teamStats.aveAuton = [NSNumber numberWithFloat:(autonPoints/nmatches)];
        teamStats.aveTeleOp = [NSNumber numberWithFloat:(teleOpPoints/nmatches)];
        teamStats.stat2 = [NSNumber numberWithFloat:(driving/nmatches)];
        teamStats.stat3 = [NSNumber numberWithFloat:(defense/nmatches)];
        teamStats.stat4 = [NSNumber numberWithFloat:(speed/nmatches)];
        teamStats.aveClimbHeight = [NSNumber numberWithFloat:(hangLevel/nmatches)];
    }
    else {
        teamStats.aveAuton = [NSNumber numberWithFloat:0.0];
        teamStats.aveTeleOp = [NSNumber numberWithFloat:0.0];
        teamStats.stat2 = [NSNumber numberWithFloat:0.0];
        teamStats.stat3 = [NSNumber numberWithFloat:0.0];
        teamStats.stat4 = [NSNumber numberWithFloat:0.0];
        teamStats.aveClimbHeight = [NSNumber numberWithFloat:0.0];
    }
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

    return teamStats;
}

@end
