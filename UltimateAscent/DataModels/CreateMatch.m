//
//  CreateMatch.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateMatch.h"
#import "DataManager.h"
#import "TeamData.h"
#import "MatchData.h"
//#import "TeamScore.h"
//#import "SpecificGameData.h"
//#import "EndGameData.h"
#import "CreateTeam.h"

@implementation CreateMatch
@synthesize managedObjectContext;

-(AddRecordResults)createMatchFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *matchNumber;
    NSString *type;
    
    if (![data count]) return DB_ERROR;
    
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }
    
    matchNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    type = [data objectAtIndex:7];
    // NSLog(@"createMatchFromFile:Match Number = %@", matchNumber);
    MatchData *match = [self GetMatch:matchNumber forMatchType:type];
    if (match) {
        // NSLog(@"createMatchFromFile:Match %@ %@ already exists", matchNumber, type);
        return DB_MATCHED;
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
                forTournament:[data objectAtIndex: 8]   // Tournament
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

-(AddRecordResults)addMatchResultsFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *matchNumber;
    NSString *type;
    NSNumber *teamNumber;
// DO NOT LEAVE THIS FUNCTION LIKE THIS    
    if (![data count]) return DB_ERROR;
    
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }
    
    matchNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    type = @"Seeding";
    // NSLog(@"createMatchFromFile:Match Number = %@", matchNumber);
    MatchData *match = [self GetMatch:matchNumber forMatchType:type];
    if (match) {
/*
        NSLog(@"team list: %@, %@, %@, %@, %@, %@", match.red1.teamInfo.number, 
              match.red2.teamInfo.number,
              match.red3.teamInfo.number,
              match.blue1.teamInfo.number,
              match.blue2.teamInfo.number,
              match.blue3.teamInfo.number); 
 */
      //TeamScore *teamScore;
        teamNumber = [NSNumber numberWithInt:[[data objectAtIndex: 1] intValue]];
        /*  if ([teamNumber intValue] == [match.red1.teamInfo.number intValue]) teamScore = match.red1;
        else if ([teamNumber intValue] == [match.red2.teamInfo.number intValue]) teamScore = match.red2;
        else if ([teamNumber intValue] == [match.red3.teamInfo.number intValue]) teamScore = match.red3;
        else if ([teamNumber intValue] == [match.blue1.teamInfo.number intValue]) teamScore = match.blue1;
        else if ([teamNumber intValue] == [match.blue2.teamInfo.number intValue]) teamScore = match.blue2;
        else if ([teamNumber intValue] == [match.blue3.teamInfo.number intValue]) teamScore = match.blue3;
//        NSLog(@"team = %@", teamScore);
        teamScore.autonScore.missedBaskets = [NSNumber numberWithInt:[[data objectAtIndex: 2] intValue]];
        teamScore.autonScore.lowBaskets = [NSNumber numberWithInt:[[data objectAtIndex: 3] intValue]];
        teamScore.autonScore.midBaskets = [NSNumber numberWithInt:[[data objectAtIndex: 4] intValue]];
        teamScore.autonScore.highBaskets = [NSNumber numberWithInt:[[data objectAtIndex: 5] intValue]];
        teamScore.teleOpScore.missedBaskets = [NSNumber numberWithInt:[[data objectAtIndex: 6] intValue]];
        teamScore.teleOpScore.lowBaskets = [NSNumber numberWithInt:[[data objectAtIndex: 7] intValue]];
        teamScore.teleOpScore.midBaskets = [NSNumber numberWithInt:[[data objectAtIndex: 8] intValue]];
        teamScore.teleOpScore.highBaskets = [NSNumber numberWithInt:[[data objectAtIndex: 9] intValue]];
        teamScore.teleOpScore.crossesHump = [NSNumber numberWithInt:[[data objectAtIndex: 10] intValue]];
        teamScore.driverRating = [NSNumber numberWithInt:[[data objectAtIndex: 11] intValue]];
        teamScore.endGameScore.modedRamp = [NSNumber numberWithInt:[[data objectAtIndex: 12] intValue]];
        teamScore.endGameScore.coopRamp = [NSNumber numberWithInt:[[data objectAtIndex: 13] intValue]];
        teamScore.endGameScore.balanced = [NSNumber numberWithInt:[[data objectAtIndex: 14] intValue]];
        teamScore.notes = [data objectAtIndex: 15];
//        NSLog(@"team = %@", teamScore);
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return DB_ERROR;
        }
        else return DB_ADDED;*/
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
    match.matchType = matchType;
    match.number = number;
/*  [match setRed1:[self CreateScore:red1]];
    [match setRed2:[self CreateScore:red2]];
    [match setRed3:[self CreateScore:red3]];
    [match setBlue1:[self CreateScore:blue1]];
    [match setBlue2:[self CreateScore:blue2]];
    [match setBlue3:[self CreateScore:blue3]]; 
    match.tournament = tournament; */
    match.redScore = redScore;
    match.blueScore = blueScore;
//    NSLog(@"Adding New Match = %@", match);
}

-(TeamScore *)CreateScore:(NSNumber *)teamNumber { 
    if ([teamNumber intValue] == 0) return nil;
   /* TeamScore *teamScore = [NSEntityDescription insertNewObjectForEntityForName:@"TeamScore" 
                                                         inManagedObjectContext:managedObjectContext];
    [teamScore setTeleOpScore:[NSEntityDescription insertNewObjectForEntityForName:@"SpecificGameData"
                                                           inManagedObjectContext:managedObjectContext]];
    [teamScore setAutonScore:[NSEntityDescription insertNewObjectForEntityForName:@"SpecificGameData"
                                                         inManagedObjectContext:managedObjectContext]];
    [teamScore setEndGameScore:[NSEntityDescription insertNewObjectForEntityForName:@"EndGameData"
                                                           inManagedObjectContext:managedObjectContext]];
    [teamScore setTeamInfo:[self GetTeam:teamNumber]]; // Set Relationship!!!
    if (!teamScore.teamInfo) {
        teamScore.teamInfo = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData" 
                                                       inManagedObjectContext:managedObjectContext];        
        [self setTeamDefaults:teamScore.teamInfo];
        teamScore.teamInfo.number = teamNumber;
    }*/
    
    return nil; //teamScore;
}

-(MatchData *)GetMatch:(NSNumber *)matchNumber forMatchType:(NSString *) type {
    MatchData *match;
    
//    NSLog(@"Searching for match = %@", matchNumber);
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"MatchData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"number == %@ AND matchType == %@", matchNumber, type];
    [fetchRequest setPredicate:predicate];   

    NSArray *matchData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchData) {
        NSLog(@"Karma disruption error");
        return Nil;
    } 
    else {
        if([matchData count] > 0) {  // Match Exists
            match = [matchData objectAtIndex:0];
            NSLog(@"Match %@ exists", match.number);
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
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
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
            NSLog(@"Team %@ exists", team.number);
            return team;
        }
        else {
            return Nil;
        }
    }
}

-(void)setTeamDefaults:(TeamData *)blankTeam {
    /*
    blankTeam.moding = [NSNumber numberWithInt:-1];
    blankTeam.brakes = [NSNumber numberWithInt:-1];
    blankTeam.drivetrain = @"";
    blankTeam.balance = [NSNumber numberWithInt:-1];
    blankTeam.name = @"";
    blankTeam.saved = [NSNumber numberWithInt:0];
    blankTeam.number = [NSNumber numberWithInt:0];
    blankTeam.orientation = [NSNumber numberWithInt:-1];
    blankTeam.notes = @""; */
}

@end
