//
//  CreateMatch.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/12/12.
//  Copyright (c) 2013 ROBONAUTS. All rights reserved.
//

#import "CreateMatch.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "TournamentData.h"
#import "CreateTeam.h"
#include "MatchTypeDictionary.h"

// Current Match Results File Order
/*
 1  Tournament
 2  Match Type
 3  Match Number
 4  Alliance
 5  Team Number
 6  Saved
 7  Driver Rating
 8  Defense Rating
 9  Auton High
10  Auton Mid
11  Auton Low
12  Auton Missed
13  Auton Made
14  Auton Total
15  TeleOp High
16  TeleOp Mid
17  TeleOp Low
18  TeleOp Missed
19  TeleOp Made
20  TeleOp Total
21  Climb Attempt
22  Climb Level
23  Climb Timer
24  Pyramid Goals
25  Passes
26  Blocks
27  Floor Pickup
28  Wall PickUp
 
 
 
 
29  Field Drawing
30  Notes
*/

@implementation CreateMatch {
    MatchTypeDictionary *matchDictionary;
    NSString *teamError;
}

@synthesize managedObjectContext;
@synthesize tournamentRecord;
@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(AddRecordResults)createMatchFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *matchNumber;
    NSString *type;
    NSString *tournament;

    if (![data count]) return DB_ERROR;
    
    if (!managedObjectContext) {
        if (_dataManager) {
            managedObjectContext = _dataManager.managedObjectContext;
        }
        else {
            _dataManager = [DataManager new];
            managedObjectContext = [_dataManager managedObjectContext];
        }
    }
    
    matchNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    type = [data objectAtIndex:7];
    tournament = [data objectAtIndex:8];
    tournamentRecord = [self getTournamentRecord:tournament];
    // NSLog(@"createMatchFromFile:Match Number = %@", matchNumber);
    MatchData *match = [self GetMatch:matchNumber forMatchType:type forTournament:tournament];
    if (match) {
        // NSLog(@"createMatchFromFile:Match %@ %@ already exists", matchNumber, type);
        if ([data count] == 11) {
            match.redScore = [NSNumber numberWithInt:[[data objectAtIndex: 9] intValue]];
            match.blueScore = [NSNumber numberWithInt:[[data objectAtIndex: 10] intValue]];
            NSError *error;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                return DB_ERROR;
            }
            return DB_MATCHED;
        }
    }
    else {
        if ([data count] != 11) return DB_ERROR;
        [self CreateMatch:matchNumber   // Match Number 
                     forTeam1:[data objectAtIndex: 1]   // Red 1
                     forTeam2:[data objectAtIndex: 2]   // Red 2  
                     forTeam3:[data objectAtIndex: 3]   // Red 3
                     forTeam4:[data objectAtIndex: 4]   // Blue 1
                     forTeam5:[data objectAtIndex: 5]   // Blue 2
                     forTeam6:[data objectAtIndex: 6]   // Blue 3
                     forMatch:[data objectAtIndex: 7]   // Match Type
                forTournament:tournament                // Tournament
                forRedScore:[NSNumber numberWithInt:[[data objectAtIndex: 9] intValue]] 
                forBlueScore:[NSNumber numberWithInt:[[data objectAtIndex: 10] intValue]]];
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return DB_ERROR;
        }
        else return DB_ADDED;
    }
}

-(MatchData *)AddMatchObjectWithValidate:(NSNumber *)number
                                forTeam1:(NSNumber *)red1
                                forTeam2:(NSNumber *)red2
                                forTeam3:(NSNumber *)red3
                                forTeam4:(NSNumber *)blue1
                                forTeam5:(NSNumber *)blue2
                                forTeam6:(NSNumber *)blue3
                                forMatch:(NSString *)matchType
                           forTournament:(NSString *)tournament
                             forRedScore:(NSNumber *)redScore
                            forBlueScore:(NSNumber *)blueScore
{
    if (!managedObjectContext) {
        if (_dataManager) {
            managedObjectContext = _dataManager.managedObjectContext;
        }
        else {
            _dataManager = [DataManager new];
            managedObjectContext = [_dataManager managedObjectContext];
        }
    }
    AddRecordResults results = [self ValidateMatch:number
                                          forMatch:matchType
                                     forTournament:tournament
                                          forTeam1:red1
                                          forTeam2:red2
                                          forTeam3:red3
                                          forTeam4:blue1
                                          forTeam5:blue2
                                          forTeam6:blue3];
    if (results == DB_GOOD) {
        MatchData *match = [NSEntityDescription insertNewObjectForEntityForName:@"MatchData"
                                                         inManagedObjectContext:managedObjectContext];
        matchDictionary = [[MatchTypeDictionary alloc] init];
        match.matchType = matchType;
        match.matchTypeSection = [matchDictionary getMatchTypeEnum:matchType];
        match.number = number;
        tournamentRecord = [self getTournamentRecord:tournament];
        
        [match addScoreObject:[self AddScore:red1 forAlliance:@"Red 1" forTournament:tournamentRecord]];
        [match addScoreObject:[self AddScore:red2 forAlliance:@"Red 2" forTournament:tournamentRecord]];
        [match addScoreObject:[self AddScore:red3 forAlliance:@"Red 3" forTournament:tournamentRecord]];
        [match addScoreObject:[self AddScore:blue1 forAlliance:@"Blue 1" forTournament:tournamentRecord]];
        [match addScoreObject:[self AddScore:blue2 forAlliance:@"Blue 2" forTournament:tournamentRecord]];
        [match addScoreObject:[self AddScore:blue3 forAlliance:@"Blue 3" forTournament:tournamentRecord]];
        match.tournament = tournament;
        match.redScore = redScore;
        match.blueScore = blueScore;
        //    NSLog(@"Adding New Match = %@, Tournament = %@, Type = %@, Section = %@", match.number, match.tournament, match.matchType, match.matchTypeSection);
        //  NSLog(@" Tournament = %@", match.tournament);
        // NSLog(@"   Team Score = %@", match.score);
        return match;
    }
    else return nil;
}

-(AddRecordResults)ValidateMatch:(NSNumber *)number
                        forMatch:(NSString *)matchType
                    forTournament:(NSString *)tournament
                        forTeam1:(NSNumber *)red1
                        forTeam2:(NSNumber *)red2
                        forTeam3:(NSNumber *)red3
                        forTeam4:(NSNumber *)blue1
                        forTeam5:(NSNumber *)blue2
                        forTeam6:(NSNumber *)blue3 {
    
    if (!managedObjectContext) {
        if (_dataManager) {
            managedObjectContext = _dataManager.managedObjectContext;
        }
        else {
            _dataManager = [DataManager new];
            managedObjectContext = [_dataManager managedObjectContext];
        }
    }
    
    MatchData *match = [self GetMatch:number forMatchType:matchType forTournament:tournament];
    if (match) {
        // NSLog(@"createMatchFromFile:Match %@ %@ already exists", matchNumber, type);
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Match Add Alert"
                                                          message:@"Match Already Exists"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        return DB_MATCHED;
    }
    // Validate each Team
    if ([self ValidateTeam:red1 forTournament:tournament] == DB_ERROR) return DB_ERROR;
    if ([self ValidateTeam:red2 forTournament:tournament] == DB_ERROR) return DB_ERROR;
    if ([self ValidateTeam:red3 forTournament:tournament] == DB_ERROR) return DB_ERROR;
    if ([self ValidateTeam:blue1 forTournament:tournament] == DB_ERROR) return DB_ERROR;
    if ([self ValidateTeam:blue2 forTournament:tournament] == DB_ERROR) return DB_ERROR;
    if ([self ValidateTeam:blue3 forTournament:tournament] == DB_ERROR) return DB_ERROR;
    
    return DB_GOOD;
}

-(AddRecordResults)ValidateTeam:(NSNumber *)team forTournament:(NSString *)tournament {
    if ([team intValue] == 0) return DB_GOOD;
    TeamData *teamRec = [self GetTeam:team];
    if (!teamRec) {
        teamError = [NSString stringWithFormat:@"Team %@ does not exist", team];
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Check Alert"
                                                          message:teamError
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        return DB_ERROR;
    }
    NSArray *tourneyList = [teamRec.tournament allObjects];
    for (int i=0; i<[tourneyList count]; i++) {
        TournamentData *tourney = [tourneyList objectAtIndex:i];
        if ([tourney.name isEqualToString:tournament]) return DB_GOOD;
    }
    teamError = [NSString stringWithFormat:@"Team %@ is not in this tournament", team];
    UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Check Alert"
                                                      message:teamError
                                                     delegate:nil
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
    [prompt setAlertViewStyle:UIAlertViewStyleDefault];
    [prompt show];
    return DB_ERROR;
}

-(TeamScore *)AddScore:(NSNumber *)teamNumber
           forAlliance:(NSString *)alliance
         forTournament:(TournamentData *)tournament
{
    TeamScore *teamScore = [NSEntityDescription insertNewObjectForEntityForName:@"TeamScore"
                                                         inManagedObjectContext:managedObjectContext];
    [teamScore setAlliance:alliance];
    teamScore.climbAttempt = [NSNumber numberWithInt:0];
    [teamScore setTeam:[self GetTeam:teamNumber]]; // Set Relationship!!!
    if (!teamScore.team && [teamNumber intValue] !=0) {
        teamError = [NSString stringWithFormat:@"Error Adding Team: %d", [teamNumber intValue]];
    }
    [teamScore setTournament:tournamentRecord]; // Set Relationship!!!
    // NSLog(@"   For Team = %@", teamScore.team);
    /*    if (!teamScore.teamInfo) {
     teamScore.teamInfo = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
     inManagedObjectContext:managedObjectContext];
     [self setTeamDefaults:teamScore.teamInfo];
     teamScore.teamInfo.number = teamNumber;
     }*/
    
    return teamScore;

}


-(AddRecordResults)addMatchResultsFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *matchNumber;
    NSString *type;
    NSString *tournament;
    int teamNumber;
// DO NOT LEAVE THIS FUNCTION LIKE THIS    
    if (![data count]) return DB_ERROR;
    
    if (!managedObjectContext) {
        if (_dataManager) {
            managedObjectContext = _dataManager.managedObjectContext;
        }
        else {
            _dataManager = [DataManager new];
            managedObjectContext = [_dataManager managedObjectContext];
        }
    }
   
    tournament = [data objectAtIndex: 0];
    tournamentRecord = [self getTournamentRecord:tournament];
    type = [data objectAtIndex: 1];
    matchNumber = [NSNumber numberWithInt:[[data objectAtIndex: 2] intValue]];
    // NSLog(@"createMatchFromFile:Tournament = %@, Match Type = %@, Match Number = %@", tournament, type, matchNumber);
    MatchData *match = [self GetMatch:matchNumber forMatchType:type forTournament:tournament];
    if (match) {
        // NSLog(@"Match Exists");
        teamNumber = [[data objectAtIndex: 4] intValue];

        NSArray *teamScores = [match.score allObjects];
        TeamScore *score;
        BOOL found = NO;
        // NSLog(@"Team Number = %d", teamNumber);
        for (int i=0; i<[teamScores count]; i++) {
            score = [teamScores objectAtIndex:i];
            if ([score.team.number intValue] == teamNumber) {
                found = YES;
                break;
            };
        }
        if (found) {
            // NSLog(@"Count = %d", [data count]);
            // NSLog(@"30 %@", [data objectAtIndex:29]);
            // NSLog(@"29 %@", [data objectAtIndex:28]);
            // NSLog(@"28 %@", [data objectAtIndex:27]);
            switch ([data count]) {
                case 34:
                    score.notes = [data objectAtIndex: 33];
                case 33:
                    score.fieldDrawing = [data objectAtIndex: 32];
                case 32:
                    score.wallPickUp4 = [NSNumber numberWithInt:[[data objectAtIndex: 31] intValue]];
                case 31:
                    score.wallPickUp3 = [NSNumber numberWithInt:[[data objectAtIndex: 30] intValue]];
                case 30:
                    score.wallPickUp2 = [NSNumber numberWithInt:[[data objectAtIndex: 29] intValue]];
                case 29:
                    score.wallPickUp1 = [NSNumber numberWithInt:[[data objectAtIndex: 28] intValue]];
                case 28:
                    score.wallPickUp = [NSNumber numberWithInt:[[data objectAtIndex: 27] intValue]];
                case 27:
                    score.floorPickUp = [NSNumber numberWithInt:[[data objectAtIndex: 26] intValue]];
                case 26:
                    score.blocks = [NSNumber numberWithInt:[[data objectAtIndex: 25] intValue]];
                case 25:
                    score.passes = [NSNumber numberWithInt:[[data objectAtIndex: 24] intValue]];
                case 24:
                    score.pyramid = [NSNumber numberWithInt:[[data objectAtIndex: 23] intValue]];
                case 23:
                    score.climbTimer = [NSNumber numberWithFloat:[[data objectAtIndex: 22] floatValue]];
                case 22:
                    score.climbLevel = [NSNumber numberWithInt:[[data objectAtIndex: 21] intValue]];
                case 21:
                    score.climbAttempt = [NSNumber numberWithInt:[[data objectAtIndex: 20] intValue]];
                case 20:
                    score.totalTeleOpShots = [NSNumber numberWithInt:[[data objectAtIndex: 19] intValue]];
                case 19:
                    score.teleOpShots = [NSNumber numberWithInt:[[data objectAtIndex: 18] intValue]];
                case 18:
                    score.teleOpMissed = [NSNumber numberWithInt:[[data objectAtIndex: 17] intValue]];
                case 17:
                    score.teleOpLow = [NSNumber numberWithInt:[[data objectAtIndex: 16] intValue]];
                case 16:
                    score.teleOpMid = [NSNumber numberWithInt:[[data objectAtIndex: 15] intValue]];
                case 15:
                    score.teleOpHigh = [NSNumber numberWithInt:[[data objectAtIndex: 14] intValue]];
                case 14:
                    score.totalAutonShots = [NSNumber numberWithInt:[[data objectAtIndex: 13] intValue]];
                case 13:
                    score.autonShotsMade = [NSNumber numberWithInt:[[data objectAtIndex: 12] intValue]];
                case 12:
                    score.autonMissed = [NSNumber numberWithInt:[[data objectAtIndex: 11] intValue]];
                case 11:
                    score.autonLow = [NSNumber numberWithInt:[[data objectAtIndex: 10] intValue]];
                case 10:
                    score.autonMid = [NSNumber numberWithInt:[[data objectAtIndex: 9] intValue]];
                case 9:
                    score.autonHigh = [NSNumber numberWithInt:[[data objectAtIndex: 8] intValue]];
                case 8:
                    score.defenseRating = [NSNumber numberWithInt:[[data objectAtIndex: 7] intValue]];
                case 7:
                    score.driverRating = [NSNumber numberWithInt:[[data objectAtIndex: 6] intValue]];
                case 6:
                    score.saved = [NSNumber numberWithInt:[[data objectAtIndex: 5] intValue]];
                  
                default:
                    break;
            }
        }
// Assume any match results come in synced
        score.synced = [NSNumber numberWithInt:1];

        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return DB_ERROR;
        }
        else return DB_ADDED;
    }
    return DB_ADDED;
} 

       
-(void)CreateMatch:(NSNumber *)number forTeam1:(NSNumber *)red1 
                                      forTeam2:(NSNumber *)red2 
                                      forTeam3:(NSNumber *)red3
                                      forTeam4:(NSNumber *)blue1 
                                      forTeam5:(NSNumber *)blue2 
                                      forTeam6:(NSNumber *)blue3 
                                      forMatch:(NSString *)matchType
                                      forTournament:(NSString *)tournament 
                                      forRedScore:(NSNumber *)redScore
                                      forBlueScore:(NSNumber *)blueScore {
    
    MatchData *match = [NSEntityDescription insertNewObjectForEntityForName:@"MatchData" 
                                                     inManagedObjectContext:managedObjectContext];        
    matchDictionary = [[MatchTypeDictionary alloc] init];
    match.matchType = matchType;
    match.matchTypeSection = [matchDictionary getMatchTypeEnum:matchType];
    match.number = number;
    
    [match addScoreObject:[self CreateScore:red1 forAlliance:@"Red 1"]];
    [match addScoreObject:[self CreateScore:red2 forAlliance:@"Red 2"]];
    [match addScoreObject:[self CreateScore:red3 forAlliance:@"Red 3"]];
    [match addScoreObject:[self CreateScore:blue1 forAlliance:@"Blue 1"]];
    [match addScoreObject:[self CreateScore:blue2 forAlliance:@"Blue 2"]];
    [match addScoreObject:[self CreateScore:blue3 forAlliance:@"Blue 3"]];
    match.tournament = tournament;
    match.redScore = redScore;
    match.blueScore = blueScore;
//    NSLog(@"Adding New Match = %@, Tournament = %@, Type = %@, Section = %@", match.number, match.tournament, match.matchType, match.matchTypeSection);
//  NSLog(@" Tournament = %@", match.tournament);
// NSLog(@"   Team Score = %@", match.score);
}


-(TeamScore *)CreateScore:(NSNumber *)teamNumber forAlliance:(NSString *)alliance { 

    TeamScore *teamScore = [NSEntityDescription insertNewObjectForEntityForName:@"TeamScore"
                                                         inManagedObjectContext:managedObjectContext];
    [teamScore setAlliance:alliance];
    teamScore.climbAttempt = [NSNumber numberWithInt:0];
    // Some day do better error checking
    [teamScore setTeam:[self GetTeam:teamNumber]]; // Set Relationship!!!
    if (!teamScore.team && [teamNumber intValue] !=0) {
        teamError = [NSString stringWithFormat:@"Error Adding Team: %d", [teamNumber intValue]];
    } 
    [teamScore setTournament:tournamentRecord]; // Set Relationship!!!
     // NSLog(@"   For Team = %@", teamScore.team);
/*    if (!teamScore.teamInfo) {
        teamScore.teamInfo = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData" 
                                                       inManagedObjectContext:managedObjectContext];        
        [self setTeamDefaults:teamScore.teamInfo];
        teamScore.teamInfo.number = teamNumber;
    }*/
    
    return teamScore;
}

-(MatchData *)GetMatch:(NSNumber *)matchNumber forMatchType:(NSString *) type forTournament:(NSString *) tournament {
    MatchData *match;
    
//    NSLog(@"Searching for match = %@", matchNumber);
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"MatchData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"number == %@ AND matchType == %@ and tournament CONTAINS %@", matchNumber, type, tournament];
    [fetchRequest setPredicate:predicate];   

    NSArray *matchData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchData) {
        NSLog(@"Karma disruption error");
        return Nil;
    } 
    else {
        if([matchData count] > 0) {  // Match Exists
            match = [matchData objectAtIndex:0];
        //    NSLog(@"Match %@ exists", match.number);
            return match;
        }
        else {
            return Nil;
        }
    }
}

-(TeamData *)GetTeam:(NSNumber *)teamNumber {
    TeamData *team;
    
//    NSLog(@"Searching for team = %@", teamNumber);
    NSError *error;
    if (!managedObjectContext) {
        if (_dataManager) {
            managedObjectContext = _dataManager.managedObjectContext;
        }
        else {
            _dataManager = [DataManager new];
            managedObjectContext = [_dataManager managedObjectContext];
        }
    }
   
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", teamNumber];    
    [fetchRequest setPredicate:pred];   
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        NSLog(@"Karma disruption error");
        return Nil;
    } 
    else {
        if([teamData count] > 0) {  // Team Exists
            team = [teamData objectAtIndex:0];
          //  NSLog(@"Team %@ exists", team.number);
            return team;
        }
        else {
            return Nil;
        }
    }
}

-(TournamentData *)getTournamentRecord:(NSString *)tournamentName {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TournamentData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", tournamentName];
    [fetchRequest setPredicate:pred];
    
    NSArray *tournamentData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        NSLog(@"Karma disruption error");
        return Nil;
    }
    else {
        if([tournamentData count] > 0) {  // Tournament Exists
            tournamentRecord = [tournamentData objectAtIndex:0];
            // NSLog(@"Tournament %@ exists", tournamentRecord.name);
            return tournamentRecord;
        }
        else return Nil;
    }
}

-(NSArray *)getMatchListTournament:(NSNumber *)teamNumber forTournament:(NSString *)tournament {
    NSArray *sortedMatches = nil;
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament.name = %@ AND team.number = %@", tournament, teamNumber];
    [fetchRequest setPredicate:pred];
    NSArray *matchData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    sortedMatches = [matchData sortedArrayUsingDescriptors:sortDescriptors];
    
    for (int i=0; i<[sortedMatches count]; i++) {
        TeamScore *score = [sortedMatches objectAtIndex:i];
        NSLog(@"Match = %@, Type = %@", score.match.number, score.match.matchType);
    }

    return sortedMatches;
}

-(void)setTeamDefaults:(TeamData *)blankTeam {
    blankTeam.number = [NSNumber numberWithInt:0];
    blankTeam.name = @"";
    blankTeam.climbLevel = [NSNumber numberWithInt:-1];
    blankTeam.driveTrainType = [NSNumber numberWithInt:-1];
    blankTeam.history = @"";
    blankTeam.intake = [NSNumber numberWithInt:-1];
    blankTeam.climbSpeed = [NSNumber numberWithFloat:0.0];
    blankTeam.notes = @"";
    blankTeam.wheelDiameter = [NSNumber numberWithFloat:0.0];
    blankTeam.cims = [NSNumber numberWithInt:0];
    blankTeam.minHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.maxHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.shooterHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.pyramidDump = [NSNumber numberWithInt:-1];
    blankTeam.saved = [NSNumber numberWithInt:0];
}

@end
