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

@implementation CalculateTeamStats
@synthesize dataManager = _dataManager;

-(id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(void)calculateMasonStats:(TeamData *)team forTournament:(NSString *)tournament {
    if (_dataManager == nil) {
        _dataManager = [DataManager new];
    }
    [self setDefaults];

    if (!team) {
        return;
    }
    
// fetch all score records for this tournament
    NSArray *allMatches = [team.match allObjects];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament.name = %@", tournament];
    NSArray *matches = [allMatches filteredArrayUsingPredicate:pred];
    
    int driving = 0;
    int defense = 0;
    int speed = 0;
    int hangLevel = 0;
    
    for (int i=0; i<[matches count]; i++) {
        TeamScore *match = [matches objectAtIndex:i];
        // Only use Seeding or Elimination matches that have been saved or synced
        if ( ([match.match.matchType isEqualToString:@"Seeding"]
              || [match.match.matchType isEqualToString:@"Elimination"])
            && ([match.saved intValue] || [match.synced intValue])) {
            _nmatches++;
            int points = [match.autonHigh intValue]*6 + [match.autonMid intValue]*5 + [match.autonLow intValue]*4;
            _autonPoints += points;
            points = [match.teleOpHigh intValue]*3 + [match.teleOpMid intValue]*2 + [match.teleOpLow intValue];
            _teleOpPoints += points;
            driving += [match.driverRating intValue];
            defense += [match.defenseRating intValue];
            speed += [match.robotSpeed intValue];
            hangLevel += [match.climbLevel floatValue];
            _hangs = _hangs || [match.climbLevel intValue];
        }
    }
    if (_nmatches) {
        _aveAuton = _autonPoints/_nmatches;
        _aveTeleOp = _teleOpPoints/_nmatches;
        _aveDriving = driving/_nmatches;
        _aveDefense = defense/_nmatches;
        _aveSpeed = speed/_nmatches;
        _aveClimbHeight = hangLevel/_nmatches;
    }
    
    return;
}

-(void)setDefaults {
    _nmatches = 0;
    _aveAuton = 0;
    _aveClimbHeight = 0.0;
    _aveClimbTime = 0.0;
    _aveTeleOp = 0;

    _autonAccuracy = 0.0;
    _autonPoints = 0;
    _teleOpAccuracy = 0.0;
    _teleOpPoints = 0;

    _aveDriving = 0.0;
    _aveDefense = 0.0;
    _aveSpeed = 0.0;
    
    _hangs = FALSE;
}


@end
